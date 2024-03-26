#MIT License

#Copyright (c) 2024 Andreas Ullrich

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

#!/bin/bash

# Replace this with your actual OpenAI API key
OPENAI_API_KEY="ENTR YOUR GPT-API-KEY HERE"

dirs=($(ls -d */ | sed 's#/##'))

# Function to split directories into batches of 1000
split_dirs() {
    local idx=0
    for dir in "${dirs[@]}"; do
        let batch_idx=idx/1000
        batches[batch_idx]+="$dir\n"
        let idx+=1
    done
}

# Split directories into batches
split_dirs

# Process each batch
for batch in "${batches[@]}"; do
    # Prepare the JSON payload for the current batch
    JSON_PAYLOAD=$(jq -n \
                      --arg dirs "$batch" \
                      '{
                        "model": "gpt-4-0125-preview",
                        "messages": [
                          {
                            "role": "system",
                            "content":  "Your task involves processing a list of folder names. The List look like this: [\"FOLDERNAME1\",\"FOLDERNAME2\", ...] Your objective is to identify folders with names that are too similar to each other and decide on the most appropriate one among them.  When responding, your output should be formatted as a JSON list. Each element of this list will be a sub-list containing a single object.  This object should have a 'correct' key pointing to the name of the chosen folder, and a 'duplicates' key pointing to an array of names considered too similar.  The structure of your JSON response should look like this: [[{\"correct\": \"SUGGESTED_FOLDERNAME\",\"duplicates\": [\"DUP1\", ...]}], ...]."
                          },
                          {
                            "role": "user",
                            "content": $dirs
                          }
                        ]
                      }')

    # Send the request to ChatGPT for the current batch
    CORRECTED_TEXT=$(curl -s "https://api.openai.com/v1/chat/completions" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d "$JSON_PAYLOAD" | jq -r '.choices[0].message.content')

    echo "$CORRECTED_TEXT"

 # First, extract the JSON part
JSON_PART=$(echo "$CORRECTED_TEXT" | sed -n '/^```json$/,/^```$/p' | sed '1d;$d')

# Process the JSON part with jq and the rest of the script
echo "$JSON_PART" | jq -c '.[][]' | while read i; do
    correct=$(echo $i | jq -r '.correct')
    duplicates=$(echo $i | jq -r '.duplicates[]')
    
    # Ensure the correct folder exists
    echo "$correct"
    mkdir -p "$correct"

    # Loop over each duplicate
    for dup in $duplicates; do
        if [ -d "$dup" ]; then
            # Recursively move the contents to the correct folder, not overwriting existing files
            echo "Moving contents of $dup to $correct"
            mv -n "$dup"/* "$correct"/ 2>/dev/null

            # Check if subfolders are similar and need to be combined
            for subfolder in "$dup"/*/; do
                subfolder_name=$(basename "$subfolder")
                # Check if the corresponding subfolder exists in the correct folder
                if [ -d "$correct/$subfolder_name" ]; then
                    echo "Merging subfolder $subfolder_name of $dup into $correct"
                    mv -n "$subfolder"/* "$correct/$subfolder_name"/ 2>/dev/null
                    # Remove the now-empty subfolder
                    rmdir "$subfolder" 2>/dev/null
                else
                    # Move the subfolder if it does not exist in the correct folder
                    mv -n "$subfolder" "$correct/" 2>/dev/null
                fi
            done

            # Forcefully remove the duplicate folder if it's empty
            echo "Removing directory $dup"
            rmdir "$dup" 2>/dev/null
        fi
    done
done

echo "Batch folders consolidation complete."

done

echo "All batches processed. Folders consolidation complete."
