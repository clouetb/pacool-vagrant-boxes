#/bin/sh
packer build --force -on-error=abort -only=centos8-postgresql13-vmware postgresql-vmware-from-generic.json
