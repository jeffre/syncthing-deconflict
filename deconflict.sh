#!/bin/bash
set -e

function usage {
    printf "%s\n" \
      "USAGE"\
      "    $0 DIR"\
      ""\
      "DESCRIPTION"\
      "    Finds *-sync-conflict-* files then compares the word count with"\
      "    original file. If the original file has 0 and sync-conflict has"\
      "    more, then the conflict will overwrite the original."\
      ""\
      "OPTIONS"\
      "    -i      require interaction before making each change"\
      "    -h      print usage (this)"\
      "    -d      deletes extraneous conflict files (when original file has"\
      "                greater than 0 words but the conflict has exactly 0)"\
      ""
}

function maybe_wait {
    if [[ "$INTERACTIVE" == "True" ]]; then
        read input </dev/tty
    fi
}

while getopts ":ihd" optchar; do
    case "${optchar}" in
        i)
            INTERACTIVE="True"
            echo " * ENABLED interactive mode"
            ;;
        h)
            usage
            exit
            ;;
        d)
            DELETE="True"
            echo " * ENABLED delete extraneous conflicts mode"
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

# remove args processed by getopts
shift $((OPTIND-1))

# No args
if [[ $# -eq 0 ]]; then
    usage
    exit
fi

# Arg isnt a dir
if [[ ! -d "$1" ]]; then
    echo "\"$1\" is not a directory"
    exit
fi


find $1 -iname "*sync-conflict*" -print0 | while IFS= read -d '' -r -d $'\0' CONFLICT; do
    # Path to expected original name (before conflict)
    ORIGINAL=$(echo "$CONFLICT" | sed "s|\.sync-conflict-[0-9]*-[0-9]*||g")
    if [[ ! -f "$ORIGINAL" ]]; then
        echo "\"$ORIGINAL\" not found "
        continue
    fi

    # Get word counts
    ORIGINAL_WC=$(wc -w < "$ORIGINAL")
    CONFLICT_WC=$(wc -w < "$CONFLICT")

    # If ORIGINAL file is empty but CONFLICT isn't then restore it.
    # If -d flag is invoked and CONFLICT has 0 words and ORIGINAL has more 
    #    than 0 then delete CONFLICT
    #  Require current file to have 0 words
    if [[ $CONFLICT_WC -gt "0"  && $ORIGINAL_WC == "0" ]]; then
        # Restore the sync-conflict
        echo "Restoring \"$CONFLICT\" ($CONFLICT_WC vs $ORIGINAL_WC)"
        if [[ "$INTERACTIVE" == "True" ]]; then
              read input </dev/tty
        fi
        maybe_wait
        rm "$ORIGINAL"
        mv "$CONFLICT" "$ORIGINAL"
    elif [[ "$DELETE" == "True" && $CONFLICT_WC == "0" && $ORIGINAL_WC -gt "0" ]]; then
        echo "Deleting $DELETE \"$CONFLICT\" ($CONFLICT_WC vs $ORIGINAL_WC)"
        maybe_wait
        rm "$CONFLICT"
    fi
done
