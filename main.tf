provider "proxmox" {
  endpoint = "https://192.168.111.191:8006/"
  username = "root@pam"
  password = "Par240XXX"
  insecure = true
 }

  ssh {
    agent = true
    # Uncomment below for using api_token
    # username = "root"
  }

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}


resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = "test-ubuntu"
  node_name = "pve"

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.111.191/24"
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
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}