#/bin/sh
packer build --force -on-error=abort -only=centos8-rabbitmq3-vmware rabbitmq-vmware-from-generic.json
