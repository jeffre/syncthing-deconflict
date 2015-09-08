#!/bin/bash

set -e
HOME="$1"

function about {
    echo "Scans a path that syncthing has mucked up and "
    echo "deletes empty files that have a *sync-conflict*"
    echo "counter-part that should replace them"
}

if [[ $# -ne 1 || ! -d $1 ]]; then
  about
fi

find $HOME -iname "*sync-conflict*" -print0 | while IFS= read -d '' -r -d $'\0' FILE; do
    # Path to expected original name (before conflict)
    BASE=$(echo $FILE | sed "s|\.sync-conflict-[0-9]*-[0-9]*||g")
    if [[ ! -f $BASE ]]; then
        echo "\"$BASE\" not found "
        continue
    fi

    # Compare which has the greater word cound
    # Require current file to have 0 words
    BASE_WC=$(wc -w < "$BASE")
    FILE_WC=$(wc -w < "$FILE")
    if [[ $FILE_WC -gt $BASE_WC && $BASE_WC == "0" ]]; then
        # Restore the sync-conflict
        echo "Restoring \"$FILE\" ($FILE_WC vs $BASE_WC)"
        rm "$BASE"
        mv "$FILE" "$BASE"
        #read input </dev/tty
    fi
done
