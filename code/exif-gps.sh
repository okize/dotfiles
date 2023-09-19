#!/usr/bin/env sh

if [ -f "$1" ]; then
  file "$1"
else
  echo "Error: file not found!"
  exit 1
fi

echo "\ngetting GPS coordinates from $1... \n"

# pull GPS coordinates from image with exiftool
# { coords=$(exiftool -c "%+.6f" "$1" | grep "GPS Position" | cut -d":" -f2 | tr -d ' '); } 2>/dev/null
{ coords=$(exiftool  -c "%d° %d' %.2f"\" "$1" | grep "GPS Position" | cut -d":" -f2 | tr -d ' '); } 2>/dev/null

[[ -z "$coords" ]] && { echo "Error: no GPS data found!"; exit 2; }

coords_for_gmaps=$(echo $coords | jq -sRr @uri)

echo $coords;

echo "\nhttps://www.google.com/maps/place/$coords_for_gmaps/"

exit 0
