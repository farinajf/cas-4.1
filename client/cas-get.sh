#!/bin/bash

#Usage: cas-get.sh {url} {username} {password}

DEST="$1"
USERNAME="$2"
PASSWORD="$3"

ENCODED_DEST=`echo "$DEST" | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg' | sed 's/%2E/./g' | sed 's/%0A//g'`

CAS_HOST_PORT=wso2:8443

COOKIE_JAR=.cookieJar
HEADER_DUMP_DEST=.headers
rm $COOKIE_JAR
rm $HEADER_DUMP_DEST

#GET login form
curl -s -k -c $COOKIE_JAR https://$CAS_HOST_PORT/cas/login?service=$ENCODED_DEST > login.txt

H_LT=`cat login.txt | grep name=.lt | sed 's/.*value..//' | sed 's/\".*//'`
H_EXECUTION=`cat login.txt | grep name=.execution | sed 's/.*value..//' | sed 's/\".*//'`
H_EVENTID=`cat login.txt | grep name=._eventId | sed 's/.*value..//' | sed 's/\".*//'`

echo H_LT       : $H_LT
echo H_EXECUTION: $H_EXECUTION
echo H_EVENTID  : $H_EVENTID


#Submit the login form.
#We keep the headers from this request as the return value should be a 302 including a "ticket" param which we'll need in the next request
curl -v -k -X POST --data "username=$USERNAME&password=$PASSWORD&lt=$H_LT&execution=$H_EXECUTION&_eventId=$H_EVENTID" -i -b $COOKIE_JAR -c $COOKIE_JAR \
         https://$CAS_HOST_PORT/cas/login?service=$ENCODED_DEST -D $HEADER_DUMP_DEST -o /dev/null

TGC=`cat $HEADER_DUMP_DEST | grep TGC= | sed 's/Set-Cookie: TGC=//' | sed 's/;Path.*//'`
TICKET=`cat $HEADER_DUMP_DEST | grep Location | grep ticket=ST | sed 's/.*ticket.//'`

echo "*-------------------------------------------------------*"
echo "*                                                       *"
echo \* TGC   : $TGC
echo "*                                                       *"
echo \* TICKET: $TICKET
echo "*                                                       *"
echo "*-------------------------------------------------------*"

