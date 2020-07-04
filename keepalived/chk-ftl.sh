#!/bin/sh

STATUS='0'

# check for pihole service status
FTLCHECK=$(ps ax | grep -v grep | grep 'pihole-FTL')
if [ "$FTLCHECK" != "" ]
then
	STATUS=$((STATUS+0))
else
	STATUS=$((STATUS+1))
fi

# check for unbound service status
UNBCHECK=$(ps ax | grep -v grep | grep 'unbound -d')
if [ "$UNBCHECK" != "" ]
then
	STATUS=$((STATUS+0))
else
	STATUS=$((STATUS+1))
fi

# compare results
if [ "$STATUS" = "0" ]
then
    exit 0
else
    exit 1
fi