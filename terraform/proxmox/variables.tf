variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL (example: https://pve.example.com:8006/)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the form 'user@realm!tokenid=uuid'"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for the Proxmox endpoint"
  type        = bool
  default     = false
}

variable "proxmox_ssh_username" {
  description = "SSH username used to upload cloud-init snippets to the node"
  type        = string
  default     = "root"
}

variable "proxmox_ssh_private_key_file" {
  description = "Path to the private SSH key used to upload files to the Proxmox node"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "target_node" {
  description = "Proxmox node name where VMs are created"
  type        = string
  default     = "pve"
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

variable "vm_id_start" {
  description = "Starting VMID; leave null to let Proxmox auto-assign the next free ID"
  type        = number
  default     = null
}

variable "vm_memory" {
  description = "Memory per VM in MB"
  type        = number
  default     = 2048
}

variable "vm_vcpu" {
  description = "vCPU (cores) count per VM"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Disk size per VM (example: 30, 40, 100) in GB"
  type        = number
  default     = 30
}

variable "datastore_id" {
  description = "Proxmox storage for VM disks and cloud-init drive"
  type        = string
  default     = "local-lvm"
}

variable "snippet_datastore_id" {
  description = "Proxmox storage that has the 'snippets' content type enabled"
  type        = string
  default     = "local"
}

# Where the cloud image currently lives on the Proxmox node's filesystem (the
# file you downloaded with wget/curl). This is the SOURCE that gets uploaded.
variable "source_image_path" {
  description = "Local path on the Proxmox node to the pre-downloaded Ubuntu cloud image (source)"
  type        = string
  default     = "/root/images/noble-server-cloudimg-amd64.img"
}

# The name the image is stored as INSIDE the Proxmox datastore after upload.
# Stored as 'iso' content, so it must end in .img (or .iso). The Ubuntu .img is
# really qcow2 internally, but Proxmox handles that when building the disk.
variable "imported_image_name" {
  description = "File name to store the image as inside the Proxmox datastore (destination, must end in .img/.iso)"
  type        = string
  default     = "ubuntu-noble-base.img"
}

variable "image_datastore_id" {
  description = "Proxmox storage with the 'iso' content type enabled (holds the cloud image)"
  type        = string
  default     = "local"
}

variable "bridge_name" {
  description = "Bridge interface for VM networking"
  type        = string
  default     = "vmbr0"
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
