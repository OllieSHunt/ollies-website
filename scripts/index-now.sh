#!/usr/bin/env bash

# This script takes an IndexNow key as the first arg and a list of paths
# relative to https://olliehunt.dev as all subsequent args (must start with "/").
#
# It should be run every time you change a page.

# Check args given
if [[ -z "$1" || -z "$2" ]]; then
    echo 'ERROR: Not all arguments defined'
    exit 1
fi

website="olliehunt.dev"
key="$1"
paths="${@:2}"

# Assemble HTTP request to send
request="{
    \"host\": \"$website\",
    \"key\": \"$key\",
    \"keyLocation\": \"https://$website/$key.txt\",
    \"urlList\": [
"

# List of URLs to index
for path in $paths; do
    request+="        \"https://$website$path\",
"
done

request+='    ]
}'

echo "REQUEST:"
echo "$request"
echo ""
echo "--------------------------------------------------------------------------------"
echo ""
echo "RESPONSE:"
curl -o - -i -X POST -H 'Content-Type: application/json' -d "$request" 'https://www.bing.com/indexnow'
