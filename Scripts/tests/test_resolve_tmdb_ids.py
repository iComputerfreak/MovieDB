# Copyright © 2026 Jonas Frey. All rights reserved.

import csv
from pathlib import Path
import tempfile
import unittest

from Scripts.resolve_tmdb_ids import (
    MovieResolver,
    SourceMovie,
    parse_directors,
    parse_runtime,
    process_sources,
    read_source,
    title_variants,
    write_import,
)


class FakeTMDBClient:
    def __init__(self, searches, details):
        self.searches = searches
        self.details = details

    def search_movie(self, query):
        return self.searches.get(query, [])

    def movie_details(self, tmdb_id):
        return self.details.get(tmdb_id, {})


def source(title, year, director="Unknown", runtime=120, record=1):
    return SourceMovie(
        record_number=record,
        values={
            "Name": title,
            "Year": str(year),
            "Artist": director,
            "Total Time": f"{runtime // 60}:{runtime % 60:02}:00.000",
        },
        title=title,
        year=year,
        directors=parse_directors(director),
        runtime_minutes=runtime,
    )


def result(tmdb_id, title, year, popularity=10):
    return {
        "id": tmdb_id,
        "title": title,
        "original_title": title,
        "release_date": f"{year}-01-01",
        "popularity": popularity,
    }


def details(director, runtime):
    return {
        "runtime": runtime,
        "credits": {"crew": [{"job": "Director", "name": director}]},
    }


class TitleVariantTests(unittest.TestCase):
    def test_removes_year_and_edition_suffixes(self):
        self.assertEqual(
            title_variants("King Kong (Extended Version) (2005)"),
            (
                "King Kong (Extended Version) (2005)",
                "King Kong (Extended Version)",
                "King Kong",
            ),
        )

    def test_preserves_meaningful_parentheses(self):
        self.assertEqual(title_variants("(500) Days of Summer"), ("(500) Days of Summer",))

    def test_parses_itunes_fractional_runtime(self):
        self.assertEqual(parse_runtime("1:59:16.157"), 119)
        self.assertEqual(parse_runtime("47:33.953"), 48)
        self.assertEqual(parse_runtime("1:16"), 76)


class ResolverTests(unittest.TestCase):
    def test_accepts_edition_title(self):
        movie = source("The Abyss (Special Edition)", 1989, "James Cameron", 171)
        client = FakeTMDBClient(
            {
                "The Abyss (Special Edition)": [],
                "The Abyss": [result(2756, "The Abyss", 1989)],
            },
            {2756: details("James Cameron", 140)},
        )

        match = MovieResolver(client).resolve(movie)

        self.assertEqual(match.status, "accepted")
        self.assertEqual(match.selected.candidate.tmdb_id, 2756)

    def test_director_and_runtime_overcome_wrong_year(self):
        movie = source("12 Monkeys", 1998, "Terry Gilliam", 129)
        client = FakeTMDBClient(
            {"12 Monkeys": [result(63, "12 Monkeys", 1995)]},
            {63: details("Terry Gilliam", 129)},
        )

        match = MovieResolver(client).resolve(movie)

        self.assertEqual(match.status, "accepted")
        self.assertIn("director", match.reason)

    def test_rejects_tied_candidates(self):
        movie = source("Example", 2020, runtime=100)
        client = FakeTMDBClient(
            {"Example": [result(1, "Example", 2020), result(2, "Example", 2020)]},
            {1: {"runtime": 100}, 2: {"runtime": 100}},
        )

        match = MovieResolver(client).resolve(movie)

        self.assertEqual(match.status, "ambiguous")
        self.assertIn("margin", match.reason)

    def test_ignores_candidate_with_non_latin_only_title(self):
        movie = source("Example", 2020, runtime=100)
        client = FakeTMDBClient(
            {"Example": [result(1, "映画", 2020), result(2, "Example", 2020)]},
            {1: {"runtime": 100}, 2: {"runtime": 100}},
        )

        match = MovieResolver(client).resolve(movie)

        self.assertEqual(match.status, "accepted")
        self.assertEqual(match.selected.candidate.tmdb_id, 2)

    def test_moves_repeated_tmdb_id_to_review(self):
        movies = [
            source("Example", 2020, runtime=100, record=1),
            source("Example (Unrated)", 2020, runtime=110, record=2),
        ]
        client = FakeTMDBClient(
            {
                "Example": [result(1, "Example", 2020)],
                "Example (Unrated)": [],
            },
            {1: {"runtime": 100}},
        )

        accepted, review = process_sources(movies, MovieResolver(client))

        self.assertEqual(len(accepted), 1)
        self.assertEqual(len(review), 1)
        self.assertEqual(review[0].result.status, "duplicate")


class CSVTests(unittest.TestCase):
    def test_reads_quoted_multiline_field_and_writes_import_columns(self):
        with tempfile.TemporaryDirectory() as directory:
            input_path = Path(directory) / "input.csv"
            output_path = Path(directory) / "output.csv"
            input_path.write_text(
                'Name;Year;Artist;Total Time;Content Rating\n'
                'Example;2020;Jane Director;1:40:00.000;"First line\nSecond line"\n',
                encoding="utf-8",
            )
            columns, movies = read_source(input_path)
            client = FakeTMDBClient(
                {"Example": [result(10, "Example", 2020)]},
                {10: details("Jane Director", 100)},
            )
            accepted, _ = process_sources(movies, MovieResolver(client))

            write_import(output_path, columns, accepted)

            with output_path.open(encoding="utf-8", newline="") as file:
                rows = list(csv.DictReader(file, delimiter=";"))
            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0]["tmdb_id"], "10")
            self.assertEqual(rows[0]["type"], "movie")
            self.assertEqual(rows[0]["Content Rating"], "First line\nSecond line")


if __name__ == "__main__":
    unittest.main()
