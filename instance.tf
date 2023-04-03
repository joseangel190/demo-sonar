resource "google_compute_instance" "google_instance" {
  name         = "sonar"
  machine_type = "e2-standard-2"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.google_network.name
    access_config {
      nat_ip = google_compute_address.google_address.address
    }
  }

  tags = [
    "http-server",
    "https-server"
  ]

  metadata_startup_script = file("./init.sh")

  depends_on = [google_compute_firewall.google_firewall]
}
