#!/bin/bash
set -e

function usage {
    printf "%s\n" \
      "USAGE"\
      "    ./fix.sh DIR"\
      ""\
      "DESCRIPTION"\
      "    Finds *-sync-conflict-* files then compares the word count with"\
      "    original file. If the original file has 0 and sync-conflict has"\
      "    more then the conflict will overwrite the original."\
      ""\
      "OPTIONS"\
      "    -i      interactive mode - requires interaction for each overwrite"\
      "    -h      print usage"\
      ""
}

optspec=":ih:"
while getopts "$optspec" optchar; do
    case "${optspec}" in
        i)
            INTERACTIVE=True
            echo "interactive mode enabled"
            ;;
        h)
            usage
            exit
            ;;
        ?)
            usage
            exit
            ;;
    esac
    #echo "$OPTARG is $VARNAME"
done

# remove args processed by getopts
shift $((OPTIND-1))

# No args or arg isnt a dir
if [[ $# -eq 0 || ! -d $1 ]]; then
    usage
    exit
fi


find $1 -iname "*sync-conflict*" -print0 | while IFS= read -d '' -r -d $'\0' FILE; do
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
        if [[ "$2" == "-i" ]]; then
              read input </dev/tty
        fi
        rm "$BASE"
        mv "$FILE" "$BASE"

    fi
done
