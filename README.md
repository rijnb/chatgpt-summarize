# Summarize with ChatGPT

Script to summarize text using ChatGPT. This can be used, for example, to summarize mails.

## Installing and executing

To use this script, simply clone this Github repo to your
machine, like:

```
git clone https://github.com/rijnb/chatgpt-summarize
```

## Usage

For the latest usage info, type:

```
$ chatgpt-summarize.sh
Usage: usage --apikey=<APIKEY> [--sentences=<min-max>]

  --apikey=<APIKEY>  : Supply your ChatGPT API key, or set the environment variable CHATGPT_APIKEY.
  --sentences=<range>: Specify range for number of sentences of summary, like 3-5, or 10.
  --silent           : Do not output progress to stderr
  --ask="<request>"  : Specify your own additional request, to be executed on the text. For example:
                             --ask "Specify the urgency or importancy of the following text before the summary."

The script must be used with text supplied from stdin.
```

