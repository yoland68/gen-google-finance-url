#!/bin/bash

if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq from https://stedolan.github.io/jq/download/"
    exit
fi

BASE_URL="https://www.google.com/finance/quote/"
PROCESSED_BASE_STOCK="NDAQ:NASDAQ"
BASE_STOCK=""
PARAMS="?comparison="
MAX_NUM=100
CORRECTIONS=(
    's/OTC Markets/OTCMKTS/g'
    's/Industry/NASDAQ/g'
    's/VGT:NYSE/VGT:NYSEARCA/g'
    's/NYSE:VGT/NYSEARCA:VGT/g'
    's/WISH:OTCMKTS/WISH:NASDAQ/g'
    's/OTCMKTS:WISH/NASDAQ:WISH/g'
)

main() {
    if [[ ! -z "$BASE_STOCK" ]]; then
        if [[ "$BASE_STOCK" == *"-USD" ]]; then
            PROCESSED_BASE_STOCK=$BASE_STOCK
        else
            PROCESSED_BASE_STOCK=$(curl -s "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=$BASE_STOCK&region=1&lang=e" | jq '.["ResultSet"]["Result"][0] | "\(.symbol):\(.exchDisp)"' | tr -d '"')
        fi
    fi
    URL="${BASE_URL}${PROCESSED_BASE_STOCK}${PARAMS}"
    if [ -z "$PROCESSED_INPUT_FILE" ]; then
        for stock in "${STOCK[@]}"; do
            if [[ "$stock" == *"-USD" ]]; then
                PROCESSED_STOCK=${stock}
            else
                PROCESSED_STOCK=$(curl -s "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=$stock&region=1&lang=e" | jq '.["ResultSet"]["Result"][0] | "\(.exchDisp):\(.symbol)"' | tr -d '"')
            fi
            URL="${URL}${PROCESSED_STOCK},"
            sleep 0.1
        done
    else
        mkfifo temp_pipe
        cat "${PROCESSED_INPUT_FILE}" | shuf > temp_pipe &
        x=1
        while read LINE; do
            if [ $x -le $MAX_NUM ]; then
                URL="${URL}${LINE},"
            fi
            x=$(( $x + 1 ))
        done < temp_pipe
        rm temp_pipe
    fi
    for i in "${CORRECTIONS[@]}"; do
        URL=$(echo $URL | sed -e "$i")
    done
    echo $URL
    #echo $URL | sed -e 's/OTC Markets/OTCMKTS/g' | sed -e 's/Industry/NASDAQ/g'
}

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -m|--max)
            MAX_NUM=$2;
            shift
            shift
            ;;
        -b|--base-stock)
            BASE_STOCK="$2";
            shift
            shift
            ;;
        -f|--file)
            PROCESSED_INPUT_FILE="$2"
            shift
            shift
            ;;
        *)
            STOCK+=("$1")
            shift
            ;;
    esac
done

main
