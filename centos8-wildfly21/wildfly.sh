#!/bin/bash
echo "Installing Java"
sudo yum install -y java-latest-openjdk-headless

echo "Creating wildfly group, user and homedir"
sudo groupadd -r wildfly
sudo useradd -r -g wildfly -d /opt/wildfly -s /sbin/nologin wildfly

echo "Downloading and installing wildfly"
wget https://download.jboss.org/wildfly/21.0.1.Final/wildfly-21.0.1.Final.tar.gz -P /tmp
sudo tar xvfz /tmp/wildfly-21.0.1.Final.tar.gz -C /opt/
sudo ln -s /opt/wildfly-21.0.1.Final /opt/wildfly

echo "Deploying wildfly as a service"
sudo mkdir -p /etc/wildfly
sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.conf /etc/wildfly/
sudo cp /opt/wildfly/docs/contrib/scripts/systemd/launch.sh /opt/wildfly/bin/

echo "Enabling management console on public interface"
sudo sed -i "s/\$WILDFLY_HOME\/bin\/standalone.sh -c \$2 -b \$3/\$WILDFLY_HOME\/bin\/standalone.sh -c \$2 -bmanagement=0.0.0.0 -b \$3/g" /opt/wildfly/bin/launch.sh

sudo chown -RH wildfly: /opt/wildfly
sudo chmod a+x /opt/wildfly/bin/*.sh
sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/

echo "Enabling the service and launching"
sudo systemctl daemon-reload
sudo systemctl start wildfly
sudo systemctl enable wildfly

echo "Adding admin user vagrant with password vagrant"
sudo /opt/wildfly/bin/add-user.sh -u vagrant -p vagrant -r "ManagementRealm" -e

echo "Opening ports (8080 and admin console 9990)"
sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
sudo firewall-cmd --zone=public --permanent --add-port=9990/tcp

echo "Finished"