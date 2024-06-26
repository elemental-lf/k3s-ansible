locals {
  name                      = var.context.name == null && var.name == null ? "cluster" : var.name

  k3s_config_yaml           = {
    ansible_user             = var.ansible_user
    systemd_dir              = var.systemd_dir
    apiserver_endpoint       = var.apiserver_endpoint
    keepalived_apiserver_vip = var.keepalived_apiserver_vip
    k3s_version              = var.k3s_version
    k3s_token                = var.k3s_token != null ? var.k3s_token : random_password.k3s_token.result
    extra_server_args        = var.extra_server_args
    extra_agent_args         = var.extra_agent_args
    extra_files              = var.extra_files
    datastore_endpoint       = var.datastore_endpoint
    k3s_release_channel_url  = var.k3s_release_channel_url
    k3s_release_channel      = var.k3s_release_channel
    k3s_download_url         = var.k3s_download_url
    rancher_rpm_site         = var.rancher_rpm_site
    rancher_rpm_channel      = var.rancher_rpm_channel
    k3s_selinux_enable       = var.k3s_selinux_enable
    selinux_state            = var.selinux_state
    keepalived_enabled       = var.keepalived_enabled
    keepalived_interface     = var.keepalived_interface
    keepalived_vrrp_id       = var.keepalived_vrrp_id
    kubeconfig_path          = var.fetch_kubeconfig ? "${path.root}/k3s-ansible/${module.this.id}/kubeconfig.yaml" : null
    rt_enabled               = var.rt_enabled
    reboot_allowed           = var.reboot_allowed
  }
  # So that we will only render non-default values in the input to Ansible
  k3s_config_yaml_non_default = {for k, v in local.k3s_config_yaml : k => v if v != null}

  ansible_ssh_private_key_file = var.ansible_ssh_private_key_file

  hosts_ini = <<-EOT
    [server]
    %{ for server in var.servers ~}
    ${~server}%{ if local.ansible_ssh_private_key_file != null } ansible_ssh_private_key_file="${local.ansible_ssh_private_key_file}"%{ endif }
    %{ endfor ~}

    [agent]
    %{ for agent in var.agents ~}
    ${~agent}%{ if local.ansible_ssh_private_key_file != null } ansible_ssh_private_key_file="${local.ansible_ssh_private_key_file}"%{ endif }
    %{ endfor ~}

    [k3s_cluster:children]
    server
    agent
  EOT

  ansible_check_mode = var.ansible_check_mode
  ansible_playbook   = var.ansible_playbook
  ansible_command    = "ANSIBLE_HOST_KEY_CHECKING=False OUTPUT_BASE_PATH='${path.cwd}' ansible-playbook %{if local.ansible_check_mode}--check --diff%{endif} -e '@${local_file.k3s_config_yaml.filename}' -i '${local_file.hosts_ini.filename}' '${path.module}/../${local.ansible_playbook}'"
}
