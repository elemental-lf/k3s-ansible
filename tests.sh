#!/usr/bin/env bash

set -euxo pipefail

function run_test() {
  local playbook="$1"
  local scenario="$2"
  local step="$3"
  shift 3
  local ansible_flags=("$@")

  if [[ ! -f inventory/vagrant-${scenario}/hosts-step-${step}.ini ]]; then
    return
  fi

  cat <<EOF
########################################################################################################################
# Playbook: ${playbook}
# Scenario: ${scenario}
# Step    : ${step}
# Additional Ansible flags: ${ansible_flags[@]}
########################################################################################################################
EOF

  vagrant ssh mgmt -c "cd /vagrant; ansible-playbook -v "${playbook}" -i inventory/vagrant-${scenario}/hosts-step-${step}.ini ${ansible_flags[*]}"
  vagrant ssh mgmt -c "cd /vagrant; ansible-playbook -v -C "${playbook}" -i inventory/vagrant-${scenario}/hosts-step-${step}.ini ${ansible_flags[*]}"

  cat <<EOF
########################################################################################################################
EOF

}

# Provide a clean slate
vagrant destroy --force

export VAGRANT_BOX
for VAGRANT_BOX in centos/8 almalinux/8; do
  for scenario in single-server control-plane-ha keepalived-ha; do
    for k3s_selinux_enable in true false; do
      for datastore_endpoint in '' 'mysql://k3s:secret@tcp\(192.168.177.10\)/k3s'; do
        vagrant up
        run_test site.yml "${scenario}" 1 -ek3s_version=v1.21.5+k3s2 -ek3s_selinux_enable="${k3s_selinux_enable}" -edatastore_endpoint="${datastore_endpoint}"
        run_test site.yml "${scenario}" 2 -ek3s_version=v1.21.5+k3s2 -ek3s_selinux_enable="${k3s_selinux_enable}" -edatastore_endpoint="${datastore_endpoint}"
        run_test site.yml "${scenario}" 3 -ek3s_version=v1.21.5+k3s2 -ek3s_selinux_enable="${k3s_selinux_enable}" -edatastore_endpoint="${datastore_endpoint}"
        run_test site.yml "${scenario}" 3 -ek3s_version=v1.22.2+k3s2 -ek3s_selinux_enable="${k3s_selinux_enable}" -edatastore_endpoint="${datastore_endpoint}"
        run_test site.yml "${scenario}" 3 -ek3s_version="" -ek3s_release_channel=v1.22 -ek3s_selinux_enable="${k3s_selinux_enable}" -edatastore_endpoint="${datastore_endpoint}"
        run_test reset.yml "${scenario}" 3
        vagrant destroy --force
      done
    done
  done
done
