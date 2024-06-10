#!/bin/bash

# Check if the correct number of parameters is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_xml_file>"
    exit 1
fi

XML_FILE="$1"
OUTPUT_FILE="artist_album_links.html"

# Check if the XML file exists
if [ ! -f "$XML_FILE" ]; then
    echo "File not found: $XML_FILE"
    exit 1
fi

# Create or clear the output file
> "$OUTPUT_FILE"

# Initialize the HTML file with basic structure
echo "<!DOCTYPE html>" >> "$OUTPUT_FILE"
echo "<html lang=\"en\">" >> "$OUTPUT_FILE"
echo "<head><meta charset=\"UTF-8\"><title>Artist and Album Links</title></head>" >> "$OUTPUT_FILE"
echo "<body>" >> "$OUTPUT_FILE"
echo "<h1>Artist and Album Links</h1>" >> "$OUTPUT_FILE"
echo "<ul>" >> "$OUTPUT_FILE"

# Initialize an array to store unique combinations
declare -a seen_combinations

# Function to check if a combination exists in the array
function combination_exists {
    local comb="$1"
    for i in "${seen_combinations[@]}"; do
        if [ "$i" == "$comb" ]; then
            return 0
        fi
    done
    return 1
}

# Parse the XML file to extract unique artist and album combinations
artist=""
album=""

while IFS= read -r line; do
    if [[ $line =~ \<key\>Artist\<\/key\>\<string\>(.*)\<\/string\> ]]; then
        artist="${BASH_REMATCH[1]}"
    fi
    if [[ $line =~ \<key\>Album\<\/key\>\<string\>(.*)\<\/string\> ]]; then
        album="${BASH_REMATCH[1]}"
        combination="$artist - $album"
        if ! combination_exists "$combination"; then
            seen_combinations+=("$combination")
            # Replace spaces, dashes, and plus signs with spaces, then with plus signs for the URL
            artist_url=$(echo "$artist" | sed 's/[ -+]/ /g' | sed 's/ /+/g')
            album_url=$(echo "$album" | sed 's/[ -+]/ /g' | sed 's/ /+/g')
            echo "<li><a href=\"https://www.google.com/search?q=bandcamp+$artist_url+$album_url\" target=\"_blank\">$artist - $album</a></li>" >> "$OUTPUT_FILE"
        fi
        # Reset artist and album for the next track
        artist=""
        album=""
    fi
done < "$XML_FILE"

# Close the HTML tags
echo "</ul>" >> "$OUTPUT_FILE"
echo "</body>" >> "$OUTPUT_FILE"
echo "</html>" >> "$OUTPUT_FILE"

echo "Output written to $OUTPUT_FILE"