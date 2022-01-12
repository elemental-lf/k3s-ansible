module "k3s_ansible" {
  source = "./.."

  servers = [
    "192.168.177.101",
    "192.168.177.102",
    "192.168.177.103",
  ]
  agents  = [
    "192.168.177.201",
    "192.168.177.202",
  ]

  ansible_user        = "vagrant"
  k3s_release_channel = "v1.22"
  fetch_kubeconfig    = true

  extra_server_args   = ["-v 0"]
  extra_agent_args    = ["-v 0"]

  extra_files = {
    "/etc/test123" = {
      content = "test123content"
      mode = "0444"
    }
  }
}
