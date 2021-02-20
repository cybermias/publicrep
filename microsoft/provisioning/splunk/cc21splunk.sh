#!/bin/sh
export SPLUNK_HOME=/opt/splunk

sudo mkdir /opt/splunk/etc/apps/inputs_wef
sudo mkdir /opt/splunk/etc/apps/inputs_wef/local

## Fixing the snapshot of splunk 812 (already containing pf configus on "fw" - but trippled in indexes.conf)
## We remove the current indexes.conf first and fix it with only one [fw]. The app was already installed before snapshot.
## Notice we dont delete the file but append it with '>'.

sudo echo '[fw]
homePath = $SPLUNK_DB/fwdb/db
coldPath = $SPLUNK_DB/fwdb/colddb
thawedPath = $SPLUNK_DB/fwdb/thaweddb' > /opt/splunk/etc/system/local/indexes.conf

sudo echo '[wef]
homePath = $SPLUNK_DB/wefdb/db
coldPath = $SPLUNK_DB/wefdb/colddb
thawedPath = $SPLUNK_DB/wefdb/thaweddb' >> /opt/splunk/etc/system/local/indexes.conf

sudo echo '[udp://:10514]
index=wef
sourcetype=windows_snare_syslog
disabled = 0' >> /opt/splunk/etc/apps/inputs_wef/local/inputs.conf


