# TMDB ID Resolver

`resolve_tmdb_ids.py` converts an iTunes movie CSV export into a CSV accepted by Movie DB.
It searches TMDB using title, year, director, and runtime. Ambiguous matches are kept out of
the import and written to a separate review CSV.

## Usage

Create a TMDB API read access token, then run:

```sh
TMDB_READ_TOKEN="..." python3 Scripts/resolve_tmdb_ids.py \
  ~/Downloads/export.csv \
  --output ~/Downloads/movie-db-import.csv \
  --review ~/Downloads/tmdb-review.csv
```

Responses are cached beside the input as `export.tmdb-cache.json`. Repeating the command
resumes from that cache. Use `--limit 20` for an initial sample or `--refresh-cache` to ignore
cached responses.

The import contains only accepted unique movies. Alternate editions that resolve to the same
TMDB ID, ambiguous matches, and unmatched rows appear in the review CSV.

## Overrides

Resolve review rows manually with an override CSV:

```csv
Name;Year;tmdb_id
12 Monkeys;1998;63
```

Then rerun with `--overrides ~/Downloads/tmdb-overrides.csv`. `Year` is optional; include it
when titles may repeat.

Run tests with:

```sh
python3 -m unittest discover -s Scripts/tests
```
