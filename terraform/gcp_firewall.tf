# gcp_firewall.tf

resource "google_compute_firewall" "development" {
  name    = "development"
  network = "${google_compute_network.gcp-2016-advent-calendar.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  target_tags = ["${google_compute_instance.development.tags}"]
}
