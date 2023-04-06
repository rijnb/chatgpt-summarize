#!/usr/bin/env zsh
#
# This file uses ChatGPT to summarize text from stdin.

APIKEY=
for ARG in "$@"
do
    case "$ARG" in

        --apikey=*)
            APIKEY="${ARG#*=}"
            ;;
        *)
            echo "Invalid argument: $arg"
            exit 1
            ;;
    esac
done

if [[ -z "$APIKEY" ]]
then
    echo "Usage: $(basename $0) --apikey=<APIKEY>"
    echo ""
    echo "  --apikey <APIKEY>: Supply your ChatGPT API key."
    exit -1
fi

if [ -t 0 ]
then
    echo "ERROR: No stdin input available"
    exit -1
fi

TEXT=$(cat | tr '\n' ' ' | tr '\"' ' ' | tr "'" ' ')

if [ -z "$TEXT" ]
then
    echo "ERROR: Empty input"
    exit -1
fi

curl -s -X POST "https://api.openai.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $APIKEY" \
    -d '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "'$TEXT'"}]}' |
    /usr/local/bin/jq '.choices[0].message.content' |
    perl -pe 's/^.(.*?).$/$1/m'
