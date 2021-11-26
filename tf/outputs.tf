output "kubeconfig_path" {
  value = local.k3s_config_yaml["kubeconfig_path"]
}

output "hosts_ini_path" {
  value = local_file.hosts_ini.filename
}

output "k3s_config_yaml_path" {
  value = local_file.k3s_config_yaml.filename
}
