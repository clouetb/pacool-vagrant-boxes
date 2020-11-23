#/bin/sh
packer build --force -on-error=abort -only=centos8-wildfly21-vmware wildfly-vmware-from-generic.json
