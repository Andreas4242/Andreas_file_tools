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

# Function to replace umlauts and special characters  
replace_chars() {  
    local input="$1"  
    local is_file="$2"
    local base_name
    local extension

    if [[ "$is_file" -eq 1 ]]; then
        base_name="${input%.*}"  
        extension="${input##*.}"
    else
        base_name="$input"
        extension=""
    fi

    # Replace common umlauts and non-alphanumeric characters (except underscores, hyphens, and periods)  
    local cleaned_base_name=$(echo "$base_name" | sed 's/ä/ae/g' | sed 's/ö/oe/g' | sed 's/ü/ue/g' | sed 's/Ä/Ae/g' | sed 's/Ö/Oe/g' | sed 's/Ü/Ue/g' | sed 's/ß/ss/g' | sed 's/[^A-Za-z0-9_-]/_/g')

    # For directories and files, replace periods with underscores  
    cleaned_base_name=$(echo "$cleaned_base_name" | sed 's/\./_/g')  

    # If it's a file and has an extension, append the extension to the cleaned base name
    if [[ "$is_file" -eq 1 && "$input" != "$base_name" ]]; then
        echo "${cleaned_base_name}.${extension}"
    else
        echo "$cleaned_base_name"
    fi
}

# Function to make names FAT32 compatible  
make_fat32_compatible() {  
    local path="$1"  
    local is_file="$2"  
    if [[ "$path" == "./" || "$path" == "." ]]; then  
        # Skip the current directory  
        return  
    fi

    local dir=$(dirname "$path")  
    local fullname=$(basename "$path")  

    # Replace umlauts and special characters  
    local clean_name=$(replace_chars "$fullname" "$is_file")

    # Construct the new full path  
    local new_full_path="$dir/$clean_name"

    # Skip renaming if the new name is the same as the old one  
    if [[ "$path" == "$new_full_path" ]]; then  
        return  
    fi

    # Debug: Print the new path  
    echo "Renaming: $path to $new_full_path"

    # Rename the file or directory if necessary  
    mv -n "$path" "$new_full_path"  
}

export -f make_fat32_compatible  
export -f replace_chars

# Handle directories and files separately  
find . -depth ! -name '._*' -type d -exec bash -c 'make_fat32_compatible "$0" 0' {} \;  
find . -depth ! -name '._*' -type f -exec bash -c 'make_fat32_compatible "$0" 1' {} \;
