resource "random_password" "k3s_token" {
  length  = 30
  special = false
}

resource "local_file" "hosts_ini" {
  content  = local.hosts_ini
  filename = "${path.root}/k3s-ansible/${module.this.id}/hosts.ini"
}

resource "local_file" "k3s_config_yaml" {
  content  = yamlencode(local.k3s_config_yaml_non_default)
  filename = "${path.root}/k3s-ansible/${module.this.id}/k3s-config.yaml"
}

resource "null_resource" "k3s" {
  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False OUTPUT_BASE_PATH='${path.cwd}' ansible-playbook -e '@${local_file.k3s_config_yaml.filename}' -i '${local_file.hosts_ini.filename}' '${path.module}/../site.yml'"
  }

  triggers = {
    (local_file.hosts_ini.filename) = sha256(local_file.hosts_ini.content)
    (local_file.k3s_config_yaml.filename) = sha256(local_file.k3s_config_yaml.content)
  }
}
