#!/bin/sh
export SPLUNK_HOME=/opt/splunk

echo '[wef]
homePath = $SPLUNK_DB/wefdb/db
coldPath = $SPLUNK_DB/wefdb/colddb
thawedPath = $SPLUNK_DB/wefdb/thaweddb' >> /opt/splunk/etc/system/local/indexes.conf

echo '[udp://:10514]
index=wef
sourcetype=wef
disabled = 0' >> /opt/splunk/etc/apps/inputs_pf/local/inputs.conf


