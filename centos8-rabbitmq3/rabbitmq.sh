#!/bin/bash

echo "Setting up hostname resolution"
sudo sed -i  "s/127\.0\.0\.1.*/127.0.0.1\tlocalhost\tlocalhost.localdomain \t$(hostname -f)\t$(hostname -s)/g" /etc/hosts

echo "Setup repositories"
cat > bintray-rabbitmq-rpm.repo << __EOF__
[bintray-rabbitmq-server]
name=bintray-rabbitmq-rpm
baseurl=https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/v3.8.x/el/8/
gpgcheck=0
repo_gpgcheck=0
enabled=1
__EOF__
sudo mv bintray-rabbitmq-rpm.repo /etc/yum.repos.d/

cat > bintray-rabbitmq-erlang-rpm.repo << __EOF__
[bintray-rabbitmq-erlang-server]
name=bintray-rabbitmq-erlang-rpm
baseurl=https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/23/el/8/
gpgcheck=0
repo_gpgcheck=0
enabled=1
__EOF__
sudo mv bintray-rabbitmq-erlang-rpm.repo /etc/yum.repos.d/
sudo yum makecache

echo "Install rabbitmq-server and dependencies"
sudo yum install -y erlang rabbitmq-server

echo "Configuring limits"
sudo mkdir -p /etc/systemd/system/rabbitmq-server.service.d
cat > limits.conf << __EOF__
[Service]
LimitNOFILE=64000
__EOF__
sudo mv limits.conf /etc/systemd/system/rabbitmq-server.service.d

echo "Enable rabbitmq-server autostart"
sudo chkconfig rabbitmq-server on
sudo service rabbitmq-server start

echo "Opening ports"
for PORT in 4369 5672 5671 25672 15672 61613 61614 1883 8883 15674 15675 15692
  do sudo firewall-cmd --permanent --zone=public --add-port=${PORT}/tcp
done

