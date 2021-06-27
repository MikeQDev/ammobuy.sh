#!/bin/bash
AVAIL=(9mm 45-acp-auto 223-556-nato 12-gauge)
MAILTO="your@email.com"
AMMO_TYPE="$1"
EXTRAS=""
START_DATE=`date`
if [[ ! " ${AVAIL[@]} " =~ " $AMMO_TYPE " ]]; then
	echo "!!! ===Unknown ammo type '$AMMO_TYPE' @ $START_DATE (try: '${AVAIL[@]}') === !!!"
	exit 1
fi
if [ "$AMMO_TYPE" == "223-556-nato" ]; then
	EXTRAS="kw=556"
elif [ "$AMMO_TYPE" == "12-gauge" ]; then
	EXTRAS="type=00buck"
fi
URL="https://www.ammobuy.com/ammo/$AMMO_TYPE&ret=20&$EXTRAS"
RESP=`curl -f -s "$URL" \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'Accept: text/html, */*; q=0.01' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/83.0.4103.61 Chrome/83.0.4103.61 Safari/537.36' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H "Referer: https://www.ammobuy.com/ammo/$AMMO_TYPE&ret=20" \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed`
if [ $? -ne 0 ]; then
  echo "Non-0 curl exit code at $START_DATE" # potential internet issue
  exit 1
fi

sendMessage(){
	MESSAGE_BODY="$1"
	/usr/sbin/ssmtp "$MAILTO" <<_EOF_
To: $MAILTO
From: $MAILTO
Subject: $AMMO_TYPE

$MESSAGE_BODY
_EOF_

}

if ! [[ `echo "$RESP" | grep -i "Sorry. We couldn't find"` ]]; then # TODO: add 200-check here
	sendMessage "Found $AMMO_TYPE! $URL"
	if [[ $? -ne 0 ]]; then
	  # Retry
	  sendMessage "Found $AMMO_TYPE! $URL"
	fi
	echo "===Found $AMMO_TYPE @ $START_DATE==="
	mkdir capture 2>/dev/null
	echo "$RESP" > capture/$AMMO_TYPE-`date +%s`.html
else
	echo "===Nothing @ $START_DATE for $AMMO_TYPE==="
fi
