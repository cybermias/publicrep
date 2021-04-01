#!/bin/bash


sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install docker-ce docker-compose -y

# Pulling mysql first, because this lame-ass orchestration takes time to load once docker is run
sudo docker pull mysql
sudo docker pull guacamole/guacamole
sudo mkdir /tmp/mysql
sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > /tmp/mysql/initdb.sql
sudo docker run --name guac-mysql -v /tmp/mysql:/tmp/mysql -e MYSQL_ROOT_PASSWORD=guacNGr00tPass -d mysql:latest

sudo docker pull linuxserver/openvpn-as
sudo docker pull guacamole/guacd
sleep 5

# Hopefuly after so long - mysql is running properly
# [FUTURE] add ping to mysql service to verify it runs (to optimize waiting time)
sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"CREATE DATABASE guacamole; CREATE USER 'guacamole' IDENTIFIED BY 'guacNGguacPass'; GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole.* TO 'guacamole'; FLUSH PRIVILEGES;\" && cat /tmp/mysql/initdb.sql | mysql -u root -p'guacNGr00tPass' guacamole;"

docker run --name guacd -d guacamole/guacd

docker run --name guacamole --link guacd:guacd --link guac-mysql:mysql \
-e MYSQL_DATABASE='guacamole' \
-e MYSQL_USER='guacamole' \
-e MYSQL_PASSWORD='guacNGguacPass' \
-d -p 8080:8080 guacamole/guacamole

# Harden some of the guacamole Tomcat configurations
sudo docker exec -it guacamole bash -c "sed -i 's/redirectPort=\"8443\"/redirectPort=\"8443\" server=\"\" secure=\"true\"/g' /usr/local/tomcat/conf/server.xml && sed -i 's/<Server port=\"8005\" shutdown=\"SHUTDOWN\">/<Server port=\"-1\" shutdown=\"SHUTDOWN\">/g' /usr/local/tomcat/conf/server.xml && rm -Rf /usr/local/tomcat/webapps/docs/ && rm -Rf /usr/local/tomcat/webapps/examples/ && rm -Rf /usr/local/tomcat/webapps/manager/ && rm -Rf /usr/local/tomcat/webapps/host-manager/ && chmod -R 400 /usr/local/tomcat/conf"

## Rest for a moment
sleep 2

## guacamole mysql change guacadmin (master administrator to the server)
#change password
sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SET @salt = UNHEX(SHA2(UUID(), 256)); update guacamole_user set password_salt = @salt, password_hash = UNHEX(SHA2(CONCAT('@guacAdmin@', HEX(@salt)), 256)) where entity_id = '1';\" guacamole;"

#change username (kept unchanged during this phase of the LabGate - must remain available though)
#sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"update guacamole_entity set name = 'cmtsadmin' where name = 'guacadmin';\" guacamole;"


## Create Envario user acount (notice permissions on connections)
# [FUTURE] In the future, consider argumenting these variables to be recieved directly from the dashboard
envUser='cmtsadmin'
envPass='cmtsAdmin12#'

# mysql commands to create the user, the salted hashed password and provide a universal permission to *CREATE* connections
# (From apache docs https://guacamole.apache.org/doc/gug/jdbc-auth.html#jdbc-auth-schema-users - Apperantly no "UPDATE" connections??
sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SET @salt = UNHEX(SHA2(UUID(), 256)); INSERT INTO guacamole_entity (name, type) VALUES ('${envUser}', 'USER'); INSERT INTO guacamole_user (entity_id,password_salt,password_hash,password_date) SELECT entity_id,@salt,UNHEX(SHA2(CONCAT('${envPass}', HEX(@salt)), 256)),CURRENT_TIMESTAMP FROM guacamole_entity WHERE name = '${envUser}' AND type = 'USER'; INSERT INTO guacamole_system_permission (entity_id,permission) SELECT entity_id,'CREATE_CONNECTION' FROM guacamole_entity WHERE name = '${envUser}';\" guacamole;"

## Create the connection list
# [FUTURE] Enrich with a conditioned loop
demoConnection='DESKTOP1 [RDP]'
demoProtocol='rdp'

# Create the connection (keep copy of the connection_id), add attributes (hostname, port) - enrich with relevant username/password
sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"INSERT INTO guacamole_connection (connection_name, protocol) VALUES ('${demoConnection}', '${demoProtocol}'); SELECT connection_id into @connection_id FROM guacamole_connection WHERE connection_name = '${demoConnection}' AND parent_id IS NULL; INSERT INTO guacamole_connection_parameter VALUES (@connection_id, 'hostname', 'localhost'); INSERT INTO guacamole_connection_parameter VALUES (@connection_id, 'port', '5902'); INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission) SELECT entity_id,@connection_id,'READ' FROM guacamole_entity WHERE name = '${envUser}'; INSERT INTO guacamole_connection_permission (entity_id, connection_id, permission) SELECT entity_id,@connection_id,'UPDATE' FROM guacamole_entity WHERE name = '${envUser}';\" guacamole;"

## If needed, manually listed "generic" commands to examine some values.
# Command to get all entities
#sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT entity_id FROM guacamole_entity;\" guacamole;"

# Command to get all users
#sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT * FROM guacamole_user;\" guacamole;"

# Command to get all connection
# sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT * FROM guacamole_connection;\" guacamole;"

# Command to get permissions
# sudo docker exec -it guac-mysql bash -c "mysql -u root -p'guacNGr00tPass' -e \"SELECT * FROM guacamole_connection_permission;\" guacamole;"
