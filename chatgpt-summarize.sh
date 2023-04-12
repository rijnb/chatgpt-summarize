#!/usr/bin/env zsh
#
# This file uses ChatGPT to summarize text from stdin.
# If CHATGPT_APIKEY is defined, it will be picked up.

function usage() {
    echo "Usage: $(basename $0) --apikey=<APIKEY> [--sentences=<min-max>]"
    echo ""
    echo "  --apikey=<APIKEY>  : Supply your ChatGPT API key, or set the environment variable CHATGPT_APIKEY."
    echo "  --sentences=<range>: Specify range for number of sentences of summary, like 3-5, or 10."
    echo "  --silent           : Do not output progress to stderr"
    echo "  --ask=\"<request>\"  : Specify your own additional request, to be executed on the text. For example:"
    echo "                             --ask \"Specify the urgency or importancy of the following text before the summary.\""
    echo ""
    echo "The script must be used with text supplied from stdin."
}

APIKEY=${CHATGPT_APIKEY}
SENTENCES=3-5
REQUEST=
SILENT=
for ARG in "$@"
do
    case "$ARG" in

        --apikey=*)
            APIKEY="${ARG#*=}"
            ;;
        --sentences=*)
            SENTENCES="${ARG#*=}"
            ;;
        --silent*)
            SILENT=1
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
    usage
    exit -1
fi

if [ -t 0 ]
then
    usage
    exit -1
fi


# Strip newlines and quotes.
if [[ -z "$SILENT" ]]
then
    echo "Stripping newlines and quotes..." 1>&2
fi
TEXT=$(cat | tr '\n' ' ' | tr '\"' ' ')

if [ -z "$TEXT" ]
then
    echo "ERROR: Empty input"
    exit -1
fi

if [[ -z "$SILENT" ]]
then
    echo "Summarizing to $SENTENCES sentences using ChatGPT..." 1>&2
fi
# Call ChatGPT, prefix text with request.
REPLY=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $APIKEY" \
    -d "{\"model\": \"gpt-3.5-turbo\", \"messages\": [{\"role\": \"user\", \"content\": \"Summarize the following text in $SENTENCES sentences. $REQUEST. Here's the text: $TEXT\"}]}" | tr -cd '\11\12\15\40-\176')

if [[ -z "$SILENT" ]]
then
    echo "Extracting summary..." 1>&2
fi
# Parse JSON for 'content'.
JSON=$(echo "$REPLY" | jq ".choices[0].message.content")
if [[ "$JSON" == "null" ]]
then
    echo "ERROR: ChatGPT produced an error."
    echo "$REPLY"
    exit 1
fi

# Cut off first and last character.
if [[ -z "$SILENT" ]]
then
    echo "Summary" 1>&2
fi
echo "$JSON" | cut -c2- | rev | cut -c2- | rev
