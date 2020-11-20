#/bin/sh
packer build --force -on-error=abort -only=centos8-postgresql12-vmware postgresql-vmware-from-generic.json
