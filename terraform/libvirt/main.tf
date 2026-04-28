terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

############################################################
# Configure libvirt provider connection
############################################################
provider "libvirt" {
  uri = var.libvirt_uri
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
# Create VM disks from base cloud image
############################################################
resource "libvirt_volume" "ubuntu_disk" {
  count = var.vm_count

  name             = "${var.vm_name_prefix}-${count.index + 1}.qcow2"
  pool             = var.storage_pool
  base_volume_name = var.base_image_name
  base_volume_pool = var.storage_pool
  size             = var.vm_disk_size * 1024 * 1024 * 1024
}

############################################################
# Create cloud-init seed ISO for each VM
############################################################
resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.vm_count

  name = "seed-${var.vm_name_prefix}-${count.index + 1}.iso"
  pool = var.storage_pool

  user_data = local.rendered_user_data

  meta_data = <<EOF
instance-id: ${var.vm_name_prefix}-${count.index + 1}
local-hostname: ${var.vm_name_prefix}-${count.index + 1}
EOF
}

############################################################
# Create and configure libvirt virtual machines
############################################################
resource "libvirt_domain" "ubuntu_vm" {
  count = var.vm_count

  name   = "${var.vm_name_prefix}-${count.index + 1}"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  ############################################################
  # Expose host CPU features directly to guest
  ############################################################
  cpu {
    mode = "host-passthrough"
  }

  ############################################################
  # Attach VM root disk
  ############################################################
  disk {
    volume_id = libvirt_volume.ubuntu_disk[count.index].id
  }

  ############################################################
  # Attach VM network interface to host bridge
  ############################################################
  network_interface {
    bridge = var.bridge_name
  }

  ############################################################
  # Enable serial console access
  ############################################################
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  ############################################################
  # Enable VNC graphics console
  ############################################################
  graphics {
    type        = "vnc"
    autoport    = true
    listen_type = "address"
  }

  ############################################################
  # Use virtio video device
  ############################################################
  video {
    type = "virtio"
  }
}
