#!/bin/bash

if [ $# -lt 2 ]; then
    echo "usage: " $0 "website dump_folder"
    exit 0
fi

site="$1"
folder="$2"

if [ "${site: -1}" != '/' ]; then
    site="$site/"
fi
if [ "${folder: -1}" != '/' ]; then
    folder="$folder/"
fi

list="list.txt"
#allowed_ext=pdf

regex[0]='/<pre>/,/<\/pre>/p'
regex[1]='s@<a .*><img .* alt=\(.*\) width.*><\/a> <a .*>\(.*\)<\/a>.*@\1;\2@p'

user_agent="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; \
              rv:32.0) Gecko/20100101 Firefox/32.0"
wget_user_agent="--user-agent=$user_agent"

if [ ! -d "$folder" ]; then
    mkdir "$folder" || (echo "impossible to create folder"; exit 1;)
fi

# 1=site
function download_and_filter_page {
    page=page.html
    wget -q  --max-redirect=0 "$wget_user_agent"  "$1" -O "$page" \
        || (echo "error with url: $1"; exit 1)
    # filter the page
    for ((i = 0; i < ${#regex[@]}; i++)); do
        cat "$page" | sed -n -e "${regex[$i]}" > "$page.tmp"
        mv "$page.tmp" "$page"
    done
    mv "$page" "$list"
}

(
    cd "$folder"
    download_and_filter_page "$site" || (echo "exit cause invalid url"; exit 1);

    while IFS=';' read type name
    do
        name=$(echo $name | html2text -ascii)
        if [ "$type" == '"[DIR]"' ]; then
            if [ "$name" != "Parent Directory" ]; then
                echo "recurring on $site$name"
                ../$0 "$site$name" "$name"
            fi
        else
            ext="${name: -3}"
            if [ "$allowed_ext"x == ""x ]; then
                wget -nv "$wget_user_agent" "$site$name" -O "$name"
            else
                if [ "$ext" == "$allowed_ext" ]; then
                    wget -nv -A $allowed_ext "$wget_user_agent" "$site$name" -O "$name"
                fi
            fi
        fi
    done < "$list"
    rm "$list"
)
