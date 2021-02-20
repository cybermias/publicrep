#!/bin/sh
export SPLUNK_HOME=/opt/splunk



sudo mkdir /opt/splunk/etc/apps/inputs_wef
sudo mkdir /opt/splunk/etc/apps/inputs_wef/local


sudo echo '[wef]
homePath = $SPLUNK_DB/wefdb/db
coldPath = $SPLUNK_DB/wefdb/colddb
thawedPath = $SPLUNK_DB/wefdb/thaweddb' >> /opt/splunk/etc/system/local/indexes.conf

sudo echo '[udp://:10514]
index=wef
sourcetype=wef
disabled = 0' >> /opt/splunk/etc/apps/inputs_wef/local/inputs.conf


