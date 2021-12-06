resource "random_password" "k3s_token" {
  length  = 30
  special = false
}

resource "local_file" "hosts_ini" {
  content  = format("%s%s", local.full_path_warning, local.hosts_ini)
  filename = "${path.cwd}/k3s-ansible/${module.this.id}/hosts.ini"
}

resource "local_file" "k3s_config_yaml" {
  content  = format("%s%s", local.full_path_warning, yamlencode(local.k3s_config_yaml_non_default))
  filename = "${path.cwd}/k3s-ansible/${module.this.id}/k3s-config.yaml"
}

resource "null_resource" "k3s" {
  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -e @${local_file.k3s_config_yaml.filename} -i ${local_file.hosts_ini.filename} site.yml"
    working_dir = "${path.module}/.."
  }
}
