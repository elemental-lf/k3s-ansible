#!/usr/bin/env bash

set -euxo pipefail

function run_test() {
  local playbook="$1"
  local scenario="$2"
  shift 2
  local ansible_flags=("$@")

  cat <<EOF
########################################################################################################################
# Playbook: ${playbook}
# Scenario: ${scenario}
# Additional Ansible flags: ${ansible_flags[@]}
########################################################################################################################
EOF

  vagrant ssh mgmt -c "cd /vagrant; ansible-playbook -v "${playbook}" -i inventory/vagrant-${scenario}/hosts.ini ${ansible_flags[*]}"

  cat <<EOF
########################################################################################################################
EOF

}

# Provide a clean slate
vagrant destroy --force

for scenario in single-server control-plane-ha keepalived-ha; do
  for k3s_selinux_enable in true false; do
    vagrant up
    run_test site.yml "${scenario}" -ek3s_version=v1.21.5+k3s2 -ek3s_selinux_enable="${k3s_selinux_enable}"
    run_test site.yml "${scenario}" -ek3s_version=v1.22.2+k3s2 -ek3s_selinux_enable="${k3s_selinux_enable}"
    run_test reset.yml "${scenario}"
    vagrant destroy --force
  done
done
