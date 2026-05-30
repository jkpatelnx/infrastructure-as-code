terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.3"
    }
  }
}

############################################################
# Configure Proxmox provider connection
############################################################
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure

  ############################################################
  # SSH is required for uploading cloud-init snippet files.
  # Use an explicit private key (no ssh-agent dependency).
  ############################################################
  ssh {
    agent       = false
    username    = var.proxmox_ssh_username
    private_key = file(pathexpand(var.proxmox_ssh_private_key_file))
  }
}

############################################################
# Render cloud-init user-data with Terraform variables
############################################################
locals {
  rendered_user_data = templatefile("${path.module}/../../cloud-init/user-data", {
    ssh_public_key     = var.ssh_public_key
    tailscale_auth_key = var.tailscale_auth_key
    vm_username        = var.vm_username
    hostname_prefix    = var.hostname_prefix
    timezone           = var.timezone
  })
}

############################################################
# Upload a locally downloaded Ubuntu cloud image (stored as
# 'iso' content; attached to the VM disk via file_id below)
############################################################
resource "proxmox_virtual_environment_file" "ubuntu_cloud_image" {
  node_name    = var.target_node
  datastore_id = var.image_datastore_id
  content_type = "iso"

  source_file {
    path      = var.source_image_path   # file on the node's disk (source)
    file_name = var.imported_image_name  # name inside the datastore (destination, .img)
  }
}

############################################################
# Upload rendered cloud-init user-data as a snippet per VM
############################################################
resource "proxmox_virtual_environment_file" "user_data" {
  count = var.vm_count

  node_name    = var.target_node
  datastore_id = var.snippet_datastore_id
  content_type = "snippets"

  source_raw {
    data      = local.rendered_user_data
    file_name = "${var.vm_name_prefix}-${count.index + 1}-user-data.yaml"
  }
}

############################################################
# Create and configure Proxmox virtual machines
############################################################
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count = var.vm_count

  name      = "${var.vm_name_prefix}-${count.index + 1}"
  vm_id     = var.vm_id_start != null ? var.vm_id_start + count.index : null
  node_name = var.target_node

  ############################################################
  # Expose host CPU features directly to guest
  ############################################################
  cpu {
    cores = var.vm_vcpu
    type  = "host"
  }

  ############################################################
  # Memory allocation
  ############################################################
  memory {
    dedicated = var.vm_memory
  }

  ############################################################
  # Build the root disk from the uploaded cloud image
  ############################################################
  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_virtual_environment_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = var.vm_disk_size
  }

  ############################################################
  # Attach VM network interface to host bridge
  ############################################################
  network_device {
    bridge = var.bridge_name
  }

  ############################################################
  # Attach rendered cloud-init user-data and request DHCP
  ############################################################
  initialization {
    datastore_id      = var.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data[count.index].id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  ############################################################
  # Enable QEMU guest agent reporting
  ############################################################
  agent {
    enabled = true
  }

  ############################################################
  # Enable serial console (required by Ubuntu cloud images)
  ############################################################
  serial_device {}

  ############################################################
  # Use serial as the VGA display for console access
  ############################################################
  vga {
    type = "serial0"
  }
}
