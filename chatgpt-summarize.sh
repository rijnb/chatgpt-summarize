#!/usr/bin/env zsh
#
# This file uses ChatGPT to summarize text from stdin.
# If CHATGPT_APIKEY is defined, it will be picked up.

APIKEY=${CHATGPT_APIKEY}
LENGTH=3-5
REQUEST=
for ARG in "$@"
do
    case "$ARG" in

        --apikey=*)
            APIKEY="${ARG#*=}"
            ;;
        --length=*)
            LENGTH="${ARG#*=}"
            ;;
        --ask=*)
            REQUEST="${ARG#*=}"
            ;;
        *)
            echo "Invalid argument: $arg"
            exit 1
            ;;
    esac
done

if [[ -z "$APIKEY" ]]
then
    echo "Usage: $(basename $0) --apikey=<APIKEY> [--length=<min-max>]"
    echo ""
    echo "  --apikey=<APIKEY> : Supply your ChatGPT API key, or set the environment variable CHATGPT_APIKEY."
    echo "  --length=<range>  : Specify range for number of sentences of summary, like 3-5, or 10."
    echo "  --ask=\"<request>\" : Specify your own additional request, to be executed on the text. For example:"
    echo "                             --ask \"Specify the urgency or importancy of the following text before the summary.\""
    exit -1
fi

if [ -t 0 ]
then
    echo "ERROR: No stdin input available"
    exit -1
fi

# Strip newlines and quotes.
TEXT=$(cat | tr '\n' ' ' | tr '\"' ' ')

if [ -z "$TEXT" ]
then
    echo "ERROR: Empty input"
    exit -1
fi

# Call ChatGPT, prefix text with request.
REPLY=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $APIKEY" \
    -d "{\"model\": \"gpt-3.5-turbo\", \"messages\": [{\"role\": \"user\", \"content\": \"Summarize the following text in $LENGTH sentences. $REQUEST. Here's the text: $TEXT\"}]}" | tr -cd '\11\12\15\40-\176')

# Parse JSON for 'content'.
JSON=$(echo "$REPLY" | jq ".choices[0].message.content")
if [[ "$JSON" == "null" ]]
then
    echo "ERROR: ChatGPT produced an error."
    echo "$REPLY"
    exit 1
fi

# Cut off first and last character.
echo "$JSON" | cut -c2- | rev | cut -c2- | rev
