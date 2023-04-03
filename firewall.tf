resource "google_compute_firewall" "google_firewall" {
  name    = "sonar"
  network = google_compute_network.google_network.name
  source_ranges = ["181.66.164.185"]

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "9000", "80"]
  }

  depends_on = [google_compute_network.google_network]
}

