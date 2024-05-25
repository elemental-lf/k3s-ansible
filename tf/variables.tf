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

variable "ansible_ssh_private_key_file" {
  type    = string
  default = null
}

variable "fetch_kubeconfig" {
  type    = bool
  default = false
}

variable "ansible_check_mode" {
  type        = bool
  description = "Run ansible-playbook in check mode"
  default     = false
}

variable "ansible_playbook" {
  type        = string
  description = "Ansible playbook to run"
  default     = "site.yml"
}
