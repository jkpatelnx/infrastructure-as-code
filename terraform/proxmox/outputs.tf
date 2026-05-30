############################################################
# Classify the guest-agent reported IPs for each VM.
#
# ipv4_addresses is a list-of-lists (one inner list per NIC).
# We flatten and bucket by range:
#   127.x          -> loopback   (ignored)
#   100.x          -> Tailscale  (CGNAT range 100.64.0.0/10)
#   anything else  -> LAN/DHCP   (eth0)
############################################################
locals {
  vm_ips = {
    for vm in proxmox_virtual_environment_vm.ubuntu_vm :
    vm.name => {
      lan       = try([for ip in flatten(vm.ipv4_addresses) : ip if !startswith(ip, "127.") && !startswith(ip, "100.")][0], "pending")
      tailscale = try([for ip in flatten(vm.ipv4_addresses) : ip if startswith(ip, "100.")][0], "pending")
    }
  }
}

############################################################
# One-line report per VM:
#   VM-ip-100-120-247-73  192.168.10.151 , 100.120.247.73
############################################################
output "vm_report" {
  description = "Per-VM line: name + LAN IP , Tailscale IP"
  value = [
    for name, ips in local.vm_ips :
    format("VM-%s-%s  %s , %s", var.hostname_prefix, replace(ips.tailscale, ".", "-"), ips.lan, ips.tailscale)
  ]
}

############################################################
# Structured version (name -> { lan, tailscale })
############################################################
output "vms" {
  description = "LAN and Tailscale IP per VM"
  value       = local.vm_ips
}
