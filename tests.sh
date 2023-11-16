#!/usr/bin/env bash

set -euxo pipefail

function run_test() {
  local playbook="$1"
  local scenario="$2"
  local step="$3"

  if [[ ! -f inventory/vagrant-${scenario}/hosts-step-${step}.ini ]]; then
    return
  fi

  # Create temporary file for passing the test configuration
  local tmpfile="$(mktemp -t k3s-ansible-tests.XXXXXX)"
  trap "rm -f -- \"${tmpfile}\"" INT TERM HUP EXIT RETURN

  cat >"$tmpfile"

  cat <<EOF
########################################################################################################################
# Playbook: ${playbook}
# Scenario: ${scenario}
# Step    : ${step}
# Additional Ansible variables:
$(sed -e 's/^/#   /;' <"$tmpfile")
########################################################################################################################
EOF

  vagrant upload "$tmpfile" /vagrant/test-config.yml mgmt
  vagrant ssh mgmt -c "cd /vagrant; ansible-playbook -v "${playbook}" -i inventory/vagrant-${scenario}/hosts-step-${step}.ini -e@test-config.yml"
  vagrant ssh mgmt -c "cd /vagrant; ansible-playbook -v -C "${playbook}" -i inventory/vagrant-${scenario}/hosts-step-${step}.ini -e@test-config.yml"

  cat <<EOF
########################################################################################################################
EOF

}


# Provide a clean slate
vagrant destroy --force

export VAGRANT_BOX
for VAGRANT_BOX in almalinux/8 generic/centos8s; do
  case "$VAGRANT_BOX" in
    generic/centos8s)
      keepalived_interface=eth1
      ;;
    almalinux/8)
      keepalived_interface=ens5
      ;;
    *)
      echo "keepalived interface for box $VAGRANT_BOX is unknown." 1>&2
      exit 1
      ;;
  esac
  for scenario in single-server control-plane-ha keepalived-ha topolvm; do
    for k3s_selinux_enable in true false; do
      if [[ ${k3s_selinux_enable} == "true" ]]; then
        selinux_state=""
      else
        selinux_state="disabled"
      fi
      for datastore_endpoint in '' 'mysql://k3s:secret@tcp(192.168.177.10)/k3s'; do
        vagrant up

        run_test site.yml "${scenario}" 1 <<EOF
k3s_version: v1.26.10-rc1+k3s1
k3s_selinux_enable: ${k3s_selinux_enable}
selinux_state: "${selinux_state}"
datastore_endpoint: "${datastore_endpoint}"
keepalived_interface: "${keepalived_interface}"
EOF
        run_test site.yml "${scenario}" 2 <<EOF
k3s_version: v1.26.10-rc1+k3s1
k3s_selinux_enable: ${k3s_selinux_enable}
selinux_state: "${selinux_state}"
datastore_endpoint: "${datastore_endpoint}"
keepalived_interface: "${keepalived_interface}"
EOF
        run_test site.yml "${scenario}" 3 <<EOF
k3s_version: v1.26.10-rc1+k3s1
k3s_selinux_enable: ${k3s_selinux_enable}
selinux_state: "${selinux_state}"
datastore_endpoint: "${datastore_endpoint}"
keepalived_interface: "${keepalived_interface}"
EOF
        run_test site.yml "${scenario}" 3 <<EOF
k3s_version: ""
k3s_release_channel: v1.27
k3s_selinux_enable: ${k3s_selinux_enable}
selinux_state: "${selinux_state}"
datastore_endpoint: "${datastore_endpoint}"
keepalived_interface: "${keepalived_interface}"
EOF
        run_test reset.yml "${scenario}" 3 <<EOF
{}
EOF

        vagrant destroy --force
      done
    done
  done
done
