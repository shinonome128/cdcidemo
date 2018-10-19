# gcp_firewall.tf

resource "google_compute_firewall" "development" {
  name    = "development"
  # network = "${google_compute_network.gcp-2016-advent-calendar.name}"
  network = "${google_compute_network.cicddemo.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  # source_ranges = ["116.220.197.54/32"]
  # source_ranges = ["116.220.197.54/32", "173.194.92.0/23"]
  # source_ranges = ["116.220.197.54/32", "173.194.92.0/23", "49.239.66.40/32"]
  # source_ranges = ["116.220.197.54/32", "173.194.92.0/23", "49.239.66.40/32", "126.112.246.62/32"]

  target_tags = ["${google_compute_instance.development.tags}"]
}
