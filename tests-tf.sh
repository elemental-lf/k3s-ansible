#!/usr/bin/env bash

set -euxo pipefail

# Provide a clean slate
vagrant destroy --force

vagrant up
vagrant ssh mgmt -c "cd /vagrant/tf/example && terraform init && terraform apply -auto-approve"
vagrant destroy --force
