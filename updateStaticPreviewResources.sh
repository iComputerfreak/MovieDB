#!/bin/sh

set -e

cd "$(dirname "$0")"

cd Movie\ DB/Preview\ Content/Resources

function downloadMovie {
	local id=$1
	curl --header "Authorization: Bearer $TMDB_API_KEY" -s "https://api.themoviedb.org/3/movie/$id?append_to_response=keywords,translations,videos,watch/providers,credits,external_ids,release_dates&language=en-US&region=US" | jq
}

function downloadShow {
	local id=$1
	curl --header "Authorization: Bearer $TMDB_API_KEY" -s "https://api.themoviedb.org/3/tv/$id?append_to_response=keywords,translations,videos,watch/providers,credits,external_ids,content_ratings&language=en-US&region=US" | jq
}

echo "Updating The Matrix..."
downloadMovie 603 > Matrix.json

echo "Updating Fight Club..."
downloadMovie 550 > FightClub.json

echo "Updating Game of Thrones..."
downloadShow 1399 > GameOfThrones.json

echo "Updating The Blacklist..."
downloadShow 46952 > Blacklist.json
