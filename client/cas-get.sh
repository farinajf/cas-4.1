#!/bin/bash

#Usage: as-get.sh {url} {username} {password}

DEST="$1"
ENCODED_DEST=`echo "$DEST" | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg' | sed 's/%2E/./g' | sed 's/%0A//g'`

CAS_HOSTNAME=wso2

USERNAME=admin
PASSWORD=temporal

COOKIE_JAR=.cookieJar
HEADER_DUMP_DEST=.headers
rm $COOKIE_JAR
rm $HEADER_DUMP_DEST

#Visit CAS and get a login form. This includes a unique ID for the form, which we will store in CAS_ID and attach to our form submission. jsessionid cookie will be set here
CAS_ID=`curl -s -k -c $COOKIE_JAR https://$CAS_HOSTNAME:8443/cas/login?service=$ENCODED_DEST | grep name=.lt | sed 's/.*value..//' | sed 's/\".*//'`

#Submit the login form, using the cookies saved in the cookie jar and the form submission ID just extracted. We keep the headers from this request as the return value should be a 302 including a "ticket" param which we'll need in the next request
curl -v -k --data "username=$USERNAME&password=$PASSWORD&lt=$CAS_ID&_eventId=submit" -i -b $COOKIE_JAR -c $COOKIE_JAR https://$CAS_HOSTNAME:8443/cas/login?service=$ENCODED_DEST -D $HEADER_DUMP_DEST -o /dev/null


