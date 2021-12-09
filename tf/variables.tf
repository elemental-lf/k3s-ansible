variable "servers" {
  type        = list(string)
  description = "List of K3s server host names or IP addresses"

  validation {
    condition = length(var.servers) >= 1
    error_message = "At least one K3s server must be defined."
  }
}

variable "agents" {
  type        = list(string)
  description = "List of K3s agent host names or IP addresses"
  default     = []
}

variable "ansible_user" {
  type    = string
  default = null
}

variable "ansible_ssh_private_key_file" {
  type    = string
  default = null
}

variable "systemd_dir" {
  type    = string
  default = null
}

variable "apiserver_endpoint" {
  type    = string
  default = null
}

variable "k3s_version" {
  type    = string
  default = null
}

variable "k3s_token" {
  type    = string
  default = null
}

variable "extra_server_args" {
  type    = string
  default = null
}

variable "extra_agent_args" {
  type    = string
  default = null
}

variable "k3s_release_channel_url" {
  type    = string
  default = null
}

variable "k3s_release_channel" {
  type    = string
  default = null
}

variable "k3s_download_url" {
  type    = string
  default = null
}

variable "rancher_rpm_site" {
  type    = string
  default = null
}

variable "rancher_rpm_channel" {
  type    = string
  default = null
}

variable "k3s_selinux_enable" {
  type    = bool
  default = null
}

variable "keepalived_enabled" {
  type    = bool
  default = null
}

variable "keepalived_interface" {
  type    = string
  default = null
}

variable "fetch_kubeconfig" {
  type    = bool
  default = false
}
