resource "google_compute_address" "google_address" {
  name = "sonar-address"
  depends_on = [google_compute_network.google_network]
}
