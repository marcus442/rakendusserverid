provider "proxmox" {
  endpoint = "https://192.168.111.191:8006/"
  username = "root@pam"
  password = "Par240XXX"
  insecure = true

  ssh {
    agent = true
    
  }
 }


resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_host

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count = 3
  name  = "ubuntu-vm-${count.index + 1}"
  node_name = var.proxmox_host

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.111.${192 + count.index}/24"
        gateway = "192.168.111.1"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_key]
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    #file_id     = "local:iso/ubuntu-cloudimg-jammy.img" 
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}
