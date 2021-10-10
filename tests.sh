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

  vagrant ssh mgmt -c "cd /vagrant; ansible-playbook -v "${playbook}" -i inventory/vagrant-${scenario}/hosts.ini ${ansible_flags[@]}"

  cat <<EOF
########################################################################################################################
EOF

}

# Provide a clean slate
vagrant destroy --force

vagrant up
run_test site.yml single-server
run_test reset.yml single-server
vagrant destroy --force

vagrant up
run_test site.yml control-plane-ha
run_test reset.yml single-server
vagrant destroy --force

vagrant up
run_test site.yml keepalived-ha -ek3s_version=v1.21.5+k3s2
run_test site.yml keepalived-ha -ek3s_version=v1.22.2+k3s2
run_test reset.yml single-server
vagrant destroy --force

# vagrant up
# run_test site.yml keepalived-ha -ek3s_selinux_enable=true
# run_test reset.yml  keepalived-ha
# vagrant destroy --force
