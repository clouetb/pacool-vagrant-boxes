#!/bin/sh
packer build --force -on-error=abort -only=ubuntu20.04-docker-compose-vmware docker-compose-vmware-from-generic.json
