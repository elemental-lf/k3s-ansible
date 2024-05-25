# These are passed as variables directly to Ansible and as such their
# default should be null so that they are not rendered into the variable
# file passed to ansible-playbook and the k3s-ansible internal default is
# used.

variable "ansible_user" {
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

variable "keepalived_apiserver_vip" {
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
  type    = list(string)
  default = null
}

variable "extra_agent_args" {
  type    = list(string)
  default = null
}

variable "extra_files" {
  type    = map(map(string))
  default = null
}

variable "datastore_endpoint" {
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

variable "selinux_state" {
  type    = string
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

variable "keepalived_vrrp_id" {
  type    = number
  default = null
}

variable "rt_enabled" {
  type    = bool
  default = false
}

variable "reboot_allowed" {
  type        = bool
  description = "Allow automated reboots during installation of K3s"
  default     = null
}
