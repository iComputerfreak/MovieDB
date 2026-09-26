#!/usr/bin/env python3
# Copyright © 2026 Jonas Frey. All rights reserved.

"""Resolve TMDB movie IDs for an iTunes semicolon-delimited CSV export."""

from __future__ import annotations

import argparse
import csv
from dataclasses import dataclass, field
from difflib import SequenceMatcher
import json
import os
from pathlib import Path
import re
import sys
import time
from typing import Any, Iterable, Mapping, Protocol, Sequence
import unicodedata
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


TMDB_BASE_URL = "https://api.themoviedb.org/3"
REQUIRED_COLUMNS = {"Name", "Year"}
EDITION_MARKERS = {
    "anniversary",
    "cut",
    "edition",
    "extended",
    "restored",
    "theatrical",
    "uncut",
    "unrated",
    "version",
}


class ResolverError(Exception):
    """Expected resolver failure suitable for display to the user."""


@dataclass(frozen=True)
class SourceMovie:
    record_number: int
    values: dict[str, str]
    title: str
    year: int | None
    directors: tuple[str, ...]
    runtime_minutes: int | None


@dataclass
class Candidate:
    tmdb_id: int
    title: str
    original_title: str
    year: int | None
    popularity: float
    details: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class ScoredCandidate:
    candidate: Candidate
    score: float
    exact_title: bool
    year_close: bool
    director_match: bool
    runtime_close: bool

    @property
    def corroborated(self) -> bool:
        return self.year_close or self.director_match or self.runtime_close


@dataclass(frozen=True)
class MatchResult:
    status: str
    reason: str
    candidates: tuple[ScoredCandidate, ...] = ()

    @property
    def selected(self) -> ScoredCandidate | None:
        return self.candidates[0] if self.status == "accepted" and self.candidates else None


@dataclass(frozen=True)
class ProcessedMovie:
    source: SourceMovie
    result: MatchResult


class TMDBProviding(Protocol):
    def search_movie(self, query: str) -> Sequence[Mapping[str, Any]]:
        """Search TMDB for a movie title."""

    def movie_details(self, tmdb_id: int) -> Mapping[str, Any]:
        """Fetch movie details and credits."""


class TMDBClient:
    def __init__(
        self,
        token: str,
        cache_path: Path,
        language: str = "en-US",
        refresh_cache: bool = False,
    ) -> None:
        self.token = token
        self.cache_path = cache_path
        self.language = language
        self.refresh_cache = refresh_cache
        self.cache: dict[str, Any] = self._load_cache()
        self.dirty_requests = 0

    def search_movie(self, query: str) -> Sequence[Mapping[str, Any]]:
        response = self._get_json(
            "/search/movie",
            {
                "query": query,
                "include_adult": "false",
                "language": self.language,
                "page": "1",
            },
        )
        results = response.get("results", [])
        return results if isinstance(results, list) else []

    def movie_details(self, tmdb_id: int) -> Mapping[str, Any]:
        return self._get_json(
            f"/movie/{tmdb_id}",
            {"append_to_response": "credits", "language": self.language},
            allow_not_found=True,
        )

    def flush(self) -> None:
        if self.dirty_requests == 0:
            return
        self.cache_path.parent.mkdir(parents=True, exist_ok=True)
        temporary_path = self.cache_path.with_suffix(self.cache_path.suffix + ".tmp")
        with temporary_path.open("w", encoding="utf-8") as file:
            json.dump(self.cache, file, ensure_ascii=False, separators=(",", ":"))
        os.replace(temporary_path, self.cache_path)
        self.dirty_requests = 0

    def _load_cache(self) -> dict[str, Any]:
        if not self.cache_path.exists():
            return {}
        try:
            with self.cache_path.open(encoding="utf-8") as file:
                value = json.load(file)
            return value if isinstance(value, dict) else {}
        except (OSError, json.JSONDecodeError) as error:
            raise ResolverError(f"Could not read cache {self.cache_path}: {error}") from error

    def _get_json(
        self,
        path: str,
        parameters: Mapping[str, str],
        allow_not_found: bool = False,
    ) -> Mapping[str, Any]:
        query = urlencode(sorted(parameters.items()))
        cache_key = f"{path}?{query}"
        if not self.refresh_cache and cache_key in self.cache:
            cached = self.cache[cache_key]
            return cached if isinstance(cached, dict) else {}

        request = Request(
            f"{TMDB_BASE_URL}{path}?{query}",
            headers={
                "Accept": "application/json",
                "Authorization": f"Bearer {self.token}",
                "User-Agent": "Movie-DB-iTunes-Importer/1.0",
            },
        )
        last_error: Exception | None = None
        for attempt in range(4):
            try:
                with urlopen(request, timeout=30) as response:
                    value = json.load(response)
                if not isinstance(value, dict):
                    raise ResolverError(f"TMDB returned an unexpected response for {path}")
                self.cache[cache_key] = value
                self.dirty_requests += 1
                if self.dirty_requests >= 50:
                    self.flush()
                return value
            except HTTPError as error:
                last_error = error
                if error.code == 404 and allow_not_found:
                    self.cache[cache_key] = {}
                    self.dirty_requests += 1
                    return {}
                if error.code != 429 and error.code < 500:
                    message = error.read().decode("utf-8", errors="replace")
                    raise ResolverError(f"TMDB request failed ({error.code}): {message}") from error
                retry_after = error.headers.get("Retry-After")
                delay = float(retry_after) if retry_after else 2**attempt
            except (URLError, TimeoutError) as error:
                last_error = error
                delay = 2**attempt
            if attempt < 3:
                time.sleep(delay)
        raise ResolverError(f"TMDB request failed after retries: {last_error}")


class MovieResolver:
    def __init__(
        self,
        client: TMDBProviding,
        minimum_score: float = 80,
        minimum_margin: float = 10,
        details_candidates: int = 3,
    ) -> None:
        self.client = client
        self.minimum_score = minimum_score
        self.minimum_margin = minimum_margin
        self.details_candidates = details_candidates

    def resolve(self, source: SourceMovie) -> MatchResult:
        candidates_by_id: dict[int, Candidate] = {}
        for query in title_variants(source.title):
            for result in self.client.search_movie(query):
                candidate = candidate_from_search_result(result)
                if candidate is not None:
                    candidates_by_id[candidate.tmdb_id] = candidate

        if not candidates_by_id:
            return MatchResult("unmatched", "TMDB search returned no movie candidates")

        candidates = list(candidates_by_id.values())
        base_scores = sorted(
            ((score_candidate(source, candidate), candidate) for candidate in candidates),
            key=lambda item: (item[0].score, item[1].popularity),
            reverse=True,
        )
        for _, candidate in base_scores[: self.details_candidates]:
            candidate.details = self.client.movie_details(candidate.tmdb_id)

        scored = tuple(
            sorted(
                (score_candidate(source, candidate) for candidate in candidates),
                key=lambda item: (item.score, item.candidate.popularity),
                reverse=True,
            )
        )
        best = scored[0]
        margin = best.score - scored[1].score if len(scored) > 1 else best.score

        failures: list[str] = []
        if best.score < self.minimum_score:
            failures.append(f"score {best.score:.0f} below {self.minimum_score:.0f}")
        if margin < self.minimum_margin:
            failures.append(f"margin {margin:.0f} below {self.minimum_margin:.0f}")
        if not best.exact_title:
            failures.append("title is not an exact normalized match")
        if not best.corroborated:
            failures.append("year, director, and runtime do not corroborate title")

        if failures:
            return MatchResult("ambiguous", "; ".join(failures), scored[:5])
        return MatchResult("accepted", evidence_description(best), scored[:5])


def normalize(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value.casefold())
    ascii_like = "".join(character for character in decomposed if not unicodedata.combining(character))
    ascii_like = ascii_like.replace("&", " and ")
    return " ".join(re.sub(r"[^a-z0-9]+", " ", ascii_like).split())


def title_variants(title: str) -> tuple[str, ...]:
    variants = [title.strip()]
    stripped = title.strip()
    while True:
        match = re.search(r"\s*[\[(]([^\])]+)[\])]\s*$", stripped)
        if match is None:
            break
        label = normalize(match.group(1))
        words = set(label.split())
        if not re.fullmatch(r"(?:19|20)\d{2}", label) and not words.intersection(EDITION_MARKERS):
            break
        stripped = stripped[: match.start()].rstrip()
        if stripped:
            variants.append(stripped)

    without_suffix = re.sub(
        r"\s*[-–:]\s*(?:unrated|uncut|extended|special|theatrical|director'?s)\b.*$",
        "",
        stripped,
        flags=re.IGNORECASE,
    ).strip()
    if without_suffix:
        variants.append(without_suffix)

    return tuple(dict.fromkeys(variant for variant in variants if variant))


def parse_directors(value: str) -> tuple[str, ...]:
    if not value or normalize(value) == "unknown":
        return ()
    names = re.split(r"\s+(?:&|and)\s+|\s*,\s*", value)
    return tuple(name.strip() for name in names if name.strip())


def parse_runtime(value: str) -> int | None:
    try:
        parts = value.split(":")
        if len(parts) == 3:
            hours, minutes, seconds = parts
            total_minutes = int(hours) * 60 + int(minutes) + float(seconds) / 60
        elif len(parts) == 2 and "." in parts[1]:
            minutes, seconds = parts
            total_minutes = int(minutes) + float(seconds) / 60
        elif len(parts) == 2:
            hours, minutes = parts
            total_minutes = int(hours) * 60 + int(minutes)
        else:
            return None
    except ValueError:
        return None
    return round(total_minutes)


def parse_year(value: str) -> int | None:
    try:
        year = int(value)
    except (TypeError, ValueError):
        return None
    return year if 1800 <= year <= 2200 else None


def candidate_from_search_result(value: Mapping[str, Any]) -> Candidate | None:
    tmdb_id = value.get("id")
    title = value.get("title")
    if not isinstance(tmdb_id, int) or not isinstance(title, str):
        return None
    original_title = value.get("original_title")
    release_date = value.get("release_date")
    popularity = value.get("popularity")
    return Candidate(
        tmdb_id=tmdb_id,
        title=title,
        original_title=original_title if isinstance(original_title, str) else title,
        year=parse_year(release_date[:4]) if isinstance(release_date, str) else None,
        popularity=float(popularity) if isinstance(popularity, (int, float)) else 0,
    )


def score_candidate(source: SourceMovie, candidate: Candidate) -> ScoredCandidate:
    variants = title_variants(source.title)
    normalized_variants = [normalize(value) for value in variants]
    candidate_titles = {normalize(candidate.title), normalize(candidate.original_title)}

    raw_exact = normalized_variants[0] in candidate_titles
    cleaned_exact = any(value in candidate_titles for value in normalized_variants[1:])
    exact_title = raw_exact or cleaned_exact
    if raw_exact:
        score = 60.0
    elif cleaned_exact:
        score = 56.0
    else:
        similarity = max(
            (
                SequenceMatcher(None, source_title, candidate_title).ratio()
                for source_title in normalized_variants
                for candidate_title in candidate_titles
                if source_title and candidate_title
            ),
            default=0.0,
        )
        score = 44.0 if similarity >= 0.92 else 28.0 if similarity >= 0.82 else 0.0

    year_close = False
    if source.year is not None and candidate.year is not None:
        difference = abs(source.year - candidate.year)
        if difference == 0:
            score += 24
            year_close = True
        elif difference == 1:
            score += 14
            year_close = True
        elif difference == 2:
            score += 7
        elif difference <= 5:
            score += 1
        else:
            score -= 4

    source_directors = tuple(normalize_person(value) for value in source.directors)
    candidate_directors = tuple(
        normalize_person(person.get("name", ""))
        for person in candidate.details.get("credits", {}).get("crew", [])
        if isinstance(person, dict) and person.get("job") == "Director"
    )
    director_match = any(
        people_match(source_director, candidate_director)
        for source_director in source_directors
        for candidate_director in candidate_directors
    )
    if director_match:
        score += 30
    elif source_directors and candidate_directors:
        score -= 8

    runtime_close = False
    candidate_runtime = candidate.details.get("runtime")
    if source.runtime_minutes is not None and isinstance(candidate_runtime, int):
        difference = abs(source.runtime_minutes - candidate_runtime)
        if difference <= 3:
            score += 8
            runtime_close = True
        elif difference <= 10:
            score += 5
            runtime_close = True
        elif difference <= 20:
            score += 2
        elif difference > 60:
            score -= 3

    return ScoredCandidate(candidate, score, exact_title, year_close, director_match, runtime_close)


def normalize_person(value: str) -> tuple[str, ...]:
    words = normalize(value).split()
    return tuple(words)


def people_match(left: tuple[str, ...], right: tuple[str, ...]) -> bool:
    if not left or not right:
        return False
    if left == right or "".join(left) == "".join(right):
        return True
    return left[-1] == right[-1] and left[0][0] == right[0][0]


def evidence_description(candidate: ScoredCandidate) -> str:
    evidence = ["exact title"]
    if candidate.year_close:
        evidence.append("release year")
    if candidate.director_match:
        evidence.append("director")
    if candidate.runtime_close:
        evidence.append("runtime")
    return f"score {candidate.score:.0f}: " + ", ".join(evidence)


def read_source(path: Path, limit: int | None = None) -> tuple[list[str], list[SourceMovie]]:
    try:
        file = path.open(encoding="utf-8-sig", newline="")
    except OSError as error:
        raise ResolverError(f"Could not open {path}: {error}") from error
    with file:
        reader = csv.DictReader(file, delimiter=";")
        if reader.fieldnames is None:
            raise ResolverError("Input CSV has no header")
        missing = REQUIRED_COLUMNS.difference(reader.fieldnames)
        if missing:
            raise ResolverError(f"Input CSV is missing columns: {', '.join(sorted(missing))}")

        sources: list[SourceMovie] = []
        for record_number, values in enumerate(reader, start=1):
            if limit is not None and len(sources) >= limit:
                break
            if None in values:
                raise ResolverError(f"Record {record_number} has more values than the header")
            title = values.get("Name", "").strip()
            if not title:
                raise ResolverError(f"Record {record_number} has no Name")
            sources.append(
                SourceMovie(
                    record_number=record_number,
                    values=dict(values),
                    title=title,
                    year=parse_year(values.get("Year", "")),
                    directors=parse_directors(values.get("Artist", "")),
                    runtime_minutes=parse_runtime(values.get("Total Time", "")),
                )
            )
        return list(reader.fieldnames), sources


def read_overrides(path: Path | None) -> dict[tuple[str, str], int]:
    if path is None:
        return {}
    try:
        with path.open(encoding="utf-8-sig", newline="") as file:
            sample = file.read(4096)
            file.seek(0)
            try:
                delimiter = csv.Sniffer().sniff(sample, delimiters=";,\t").delimiter
            except csv.Error:
                delimiter = ";"
            reader = csv.DictReader(file, delimiter=delimiter)
            if reader.fieldnames is None or not {"Name", "tmdb_id"}.issubset(reader.fieldnames):
                raise ResolverError("Overrides CSV requires Name and tmdb_id columns")
            overrides: dict[tuple[str, str], int] = {}
            for index, row in enumerate(reader, start=1):
                try:
                    tmdb_id = int(row.get("tmdb_id", ""))
                except ValueError as error:
                    raise ResolverError(f"Invalid tmdb_id in override record {index}") from error
                overrides[(normalize(row.get("Name", "")), row.get("Year", "").strip())] = tmdb_id
            return overrides
    except OSError as error:
        raise ResolverError(f"Could not read overrides {path}: {error}") from error


def override_for(source: SourceMovie, overrides: Mapping[tuple[str, str], int]) -> int | None:
    name = normalize(source.title)
    year = str(source.year) if source.year is not None else ""
    return overrides.get((name, year), overrides.get((name, "")))


def process_sources(
    sources: Iterable[SourceMovie],
    resolver: MovieResolver,
    overrides: Mapping[tuple[str, str], int] | None = None,
    progress: bool = False,
) -> tuple[list[ProcessedMovie], list[ProcessedMovie]]:
    accepted: list[ProcessedMovie] = []
    review: list[ProcessedMovie] = []
    used_ids: dict[int, SourceMovie] = {}
    overrides = overrides or {}

    for index, source in enumerate(sources, start=1):
        manual_id = override_for(source, overrides)
        if manual_id is not None:
            manual_candidate = Candidate(manual_id, source.title, source.title, source.year, 0)
            scored = ScoredCandidate(manual_candidate, 999, True, True, True, True)
            result = MatchResult("accepted", "manual override", (scored,))
        else:
            result = resolver.resolve(source)

        selected = result.selected
        if selected is not None and selected.candidate.tmdb_id in used_ids:
            first = used_ids[selected.candidate.tmdb_id]
            result = MatchResult(
                "duplicate",
                f"TMDB ID already selected by record {first.record_number}: {first.title}",
                result.candidates,
            )
            review.append(ProcessedMovie(source, result))
        elif selected is not None:
            used_ids[selected.candidate.tmdb_id] = source
            accepted.append(ProcessedMovie(source, result))
        else:
            review.append(ProcessedMovie(source, result))

        if progress and (index % 25 == 0):
            print(f"Resolved {index} records...", file=sys.stderr, flush=True)
    return accepted, review


def write_import(path: Path, source_columns: Sequence[str], rows: Sequence[ProcessedMovie]) -> None:
    columns = [column for column in source_columns if column not in {"tmdb_id", "type"}]
    columns.extend(("tmdb_id", "type"))
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=columns, delimiter=";", lineterminator="\n")
        writer.writeheader()
        for processed in rows:
            selected = processed.result.selected
            if selected is None:
                continue
            values = {column: processed.source.values.get(column, "") for column in columns}
            values["tmdb_id"] = str(selected.candidate.tmdb_id)
            values["type"] = "movie"
            writer.writerow(values)


def write_review(path: Path, rows: Sequence[ProcessedMovie]) -> None:
    columns = [
        "record",
        "Name",
        "Year",
        "Artist",
        "status",
        "reason",
        "suggested_tmdb_id",
        "suggested_title",
        "suggested_year",
        "score",
        "candidates",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=columns, delimiter=";", lineterminator="\n")
        writer.writeheader()
        for processed in rows:
            candidates = processed.result.candidates
            suggested = candidates[0] if candidates else None
            writer.writerow(
                {
                    "record": processed.source.record_number,
                    "Name": processed.source.title,
                    "Year": processed.source.values.get("Year", ""),
                    "Artist": processed.source.values.get("Artist", ""),
                    "status": processed.result.status,
                    "reason": processed.result.reason,
                    "suggested_tmdb_id": suggested.candidate.tmdb_id if suggested else "",
                    "suggested_title": suggested.candidate.title if suggested else "",
                    "suggested_year": suggested.candidate.year if suggested and suggested.candidate.year else "",
                    "score": f"{suggested.score:.0f}" if suggested else "",
                    "candidates": " || ".join(format_candidate(value) for value in candidates),
                }
            )


def format_candidate(value: ScoredCandidate) -> str:
    year = str(value.candidate.year) if value.candidate.year is not None else "?"
    return f"{value.candidate.tmdb_id}: {value.candidate.title} ({year}), score {value.score:.0f}"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="iTunes semicolon-delimited CSV export")
    parser.add_argument("--output", type=Path, help="Movie DB import CSV path")
    parser.add_argument("--review", type=Path, help="Ambiguous/unmatched review CSV path")
    parser.add_argument("--cache", type=Path, help="TMDB response cache path")
    parser.add_argument("--overrides", type=Path, help="CSV containing Name, optional Year, and tmdb_id")
    parser.add_argument("--language", default="en-US", help="TMDB language (default: en-US)")
    parser.add_argument("--limit", type=int, help="Resolve only first N records")
    parser.add_argument("--minimum-score", type=float, default=80)
    parser.add_argument("--minimum-margin", type=float, default=10)
    parser.add_argument("--details-candidates", type=int, default=3)
    parser.add_argument("--refresh-cache", action="store_true")
    return parser


def main(arguments: Sequence[str] | None = None) -> int:
    options = build_parser().parse_args(arguments)
    input_path: Path = options.input.expanduser()
    output_path = (options.output or input_path.with_suffix(".movie-db-import.csv")).expanduser()
    review_path = (options.review or input_path.with_suffix(".tmdb-review.csv")).expanduser()
    cache_path = (options.cache or input_path.with_suffix(".tmdb-cache.json")).expanduser()

    token = os.environ.get("TMDB_READ_TOKEN", "").strip()
    if not token:
        print("Error: TMDB_READ_TOKEN is not set.", file=sys.stderr)
        return 2

    client: TMDBClient | None = None
    try:
        source_columns, sources = read_source(input_path, options.limit)
        overrides = read_overrides(options.overrides.expanduser() if options.overrides else None)
        client = TMDBClient(token, cache_path, options.language, options.refresh_cache)
        resolver = MovieResolver(
            client,
            minimum_score=options.minimum_score,
            minimum_margin=options.minimum_margin,
            details_candidates=max(1, options.details_candidates),
        )
        accepted, review = process_sources(sources, resolver, overrides, progress=True)
        client.flush()
        write_import(output_path, source_columns, accepted)
        write_review(review_path, review)
    except (ResolverError, OSError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("\nInterrupted. Cached responses were preserved.", file=sys.stderr)
        return 130
    finally:
        if client is not None:
            client.flush()

    duplicate_count = sum(value.result.status == "duplicate" for value in review)
    unresolved_count = len(review) - duplicate_count
    print(f"Accepted unique movies: {len(accepted)}")
    print(f"Needs review: {unresolved_count}")
    print(f"Duplicate editions: {duplicate_count}")
    print(f"Import CSV: {output_path}")
    print(f"Review CSV: {review_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
