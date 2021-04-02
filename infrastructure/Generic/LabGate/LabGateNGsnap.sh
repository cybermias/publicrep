#!/bin/bash

## BASH Script for LabGateNG (docker-compose based) - meant for "snapshot U1804" (after noticing an image and all required installations
## take more than 4 minutes before docker even gets spawned)

## Pull Dockers (**CAUTION** - requires FUTURE-PROOF validation that newer docker versions at docker-hub won't trash this deal)
sudo docker pull mysql
sudo docker pull guacamole/guacamole
sudo docker pull linuxserver/openvpn-as
sudo docker pull guacamole/guacd

## Prepare for docker-compose inside newly generated guacamole folder
sudo mkdir /opt/labGateNG
cd /opt/labGateNG

## Pre-made Docker-Compose file (notice the init-mysql crap)
sudo wget https://raw.githubusercontent.com/cybermias/publicrep/master/infrastructure/Generic/docker-compose-mysql.yml

## guacamole mysql instance must be initialized. Docker-compose will shove the .sql file inside, but to not dig too deep into how docker-compose works, forked https://github.com/gustonator/guacamole
## This requires init-mysql to exist (as the volume: inside docker-compose-mysql.yml file targets the db inside there (see next lines)
sudo mkdir init-mysql

# Next command runs outide the docker-compose scope - just to create the initdb file.
sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > /opt/labGateNG/init-mysql/initdb.sql

#sudo docker exec -it guacamole bash -c "sed -i 's/redirectPort=\"8443\"/redirectPort=\"8443\" server=\"\" secure=\"true\"/g' /usr/local/tomcat/conf/server.xml && sed -i 's/<Server port=\"8005\" shutdown=\"SHUTDOWN\">/<Server port=\"-1\" shutdown=\"SHUTDOWN\">/g' /usr/local/tomcat/conf/server.xml && rm -Rf /usr/local/tomcat/webapps/docs/ && rm -Rf /usr/local/tomcat/webapps/examples/ && rm -Rf /usr/local/tomcat/webapps/manager/ && rm -Rf /usr/local/tomcat/webapps/host-manager/ && chmod -R 400 /usr/local/tomcat/conf"

sudo docker-compose -f docker-compose-mysql.yml up -d

## guacamole mysql change guacadmin (master administrator to the server)
#change password
sudo docker-compose -f docker-compose-mysql.yml exec -T mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SET @salt = UNHEX(SHA2(UUID(), 256)); update guacamole_user set password_salt = @salt, password_hash = UNHEX(SHA2(CONCAT('@guacAdmin@', HEX(@salt)), 256)) where entity_id = '1';\" guacamole;"

#change username (kept unchanged during this phase of the LabGate - must remain available though)
#sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"update guacamole_entity set name = 'cmtsadmin' where name = 'guacadmin';\" guacamole;"


## Create Envario user acount (notice permissions on connections)
# [FUTURE] In the future, consider argumenting these variables to be recieved directly from the dashboard
envUser='cmtsadmin'
envPass='cmtsAdmin12#'

# mysql commands to create the user, the salted hashed password and provide a universal permission to *CREATE* connections
# (From apache docs https://guacamole.apache.org/doc/gug/jdbc-auth.html#jdbc-auth-schema-users - Apperantly no "UPDATE" connections??
sudo docker-compose -f docker-compose-mysql.yml exec -T mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SET @salt = UNHEX(SHA2(UUID(), 256)); INSERT INTO guacamole_entity (name, type) VALUES ('${envUser}', 'USER'); INSERT INTO guacamole_user (entity_id,password_salt,password_hash,password_date) SELECT entity_id,@salt,UNHEX(SHA2(CONCAT('${envPass}', HEX(@salt)), 256)),CURRENT_TIMESTAMP FROM guacamole_entity WHERE name = '${envUser}' AND type = 'USER'; INSERT INTO guacamole_system_permission (entity_id,permission) SELECT entity_id,'CREATE_CONNECTION' FROM guacamole_entity WHERE name = '${envUser}';\" guacamole;"

## Create the connection list
# [FUTURE] Enrich with a conditioned loop
demoConnection='DESKTOP1 [RDP]'
demoProtocol='rdp'

# Create the connection (keep copy of the connection_id), add attributes (hostname, port) - enrich with relevant username/password
sudo docker-compose -f docker-compose-mysql.yml exec -T mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"INSERT INTO guacamole_connection (connection_name, protocol) VALUES ('${demoConnection}', '${demoProtocol}'); SELECT connection_id into @connection_id FROM guacamole_connection WHERE connection_name = '${demoConnection}' AND parent_id IS NULL; INSERT INTO guacamole_connection_parameter VALUES (@connection_id, 'hostname', 'localhost'); INSERT INTO guacamole_connection_parameter VALUES (@connection_id, 'port', '5902'); INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission) SELECT entity_id,@connection_id,'READ' FROM guacamole_entity WHERE name = '${envUser}'; INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission) SELECT entity_id,@connection_id,'UPDATE' FROM guacamole_entity WHERE name = '${envUser}';\" guacamole;"


## Harden Tomcat (with docker-compose)
sudo docker-compose -f docker-compose-mysql.yml exec -T guacamole bash -c "sed -i 's/redirectPort=\"8443\"/redirectPort=\"8443\" server=\"\" secure=\"true\"/g' /usr/local/tomcat/conf/server.xml && sed -i 's/<Server port=\"8005\" shutdown=\"SHUTDOWN\">/<Server port=\"-1\" shutdown=\"SHUTDOWN\">/g' /usr/local/tomcat/conf/server.xml && rm -Rf /usr/local/tomcat/webapps/docs/ && rm -Rf /usr/local/tomcat/webapps/examples/ && rm -Rf /usr/local/tomcat/webapps/manager/ && rm -Rf /usr/local/tomcat/webapps/host-manager/ && chmod -R 400 /usr/local/tomcat/conf"
## If needed, manually listed "generic" commands to examine some values.
# Command to get all entities
#sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT entity_id FROM guacamole_entity;\" guacamole;"

# Command to get all users
#sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT * FROM guacamole_user;\" guacamole;"

# Command to get all connection
# sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT * FROM guacamole_connection;\" guacamole;"

# Command to get permissions
# sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT * FROM guacamole_connection_permission;\" guacamole;"
