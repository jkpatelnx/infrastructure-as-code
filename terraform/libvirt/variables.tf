variable "libvirt_uri" {
  description = "Libvirt connection URI"
  type        = string
  default     = "qemu:///system"
}

variable "vm_count" {
  description = "Number of virtual machines to create (minimum: 1)"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count must be at least 1."
  }
}

variable "vm_name_prefix" {
  description = "Prefix used for VM names"
  type        = string
  default     = "ubuntu-test"
}

variable "vm_memory" {
  description = "Memory per VM in MB"
  type        = number
  default     = 2048
}

variable "vm_vcpu" {
  description = "vCPU count per VM"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Disk size per VM (example: 30, 40, 100) in GB" 
  type        = number
  default     = 30
}

variable "storage_pool" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

variable "base_image_name" {
  description = "Base cloud image name in libvirt pool"
  type        = string
  default     = "ubuntu-noble-base.qcow2"
}

variable "bridge_name" {
  description = "Bridge interface for VM networking"
  type        = string
  default     = "br0"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key"
  type        = string
  sensitive   = true
}

variable "vm_username" {
  description = "Default VM user"
  type        = string
  default     = "ubuntu"
}

variable "hostname_prefix" {
  description = "Prefix for hostname generated from Tailscale IP"
  type        = string
  default     = "ip"
}

variable "timezone" {
  description = "System timezone"
  type        = string
  default     = "Asia/Kolkata"
}
