# gcp_network.tf 

resource "google_compute_network" "gcp-2016-advent-calendar" {
  name = "gcp-2016-advent-calendar"
}
resource "google_compute_subnetwork" "development" {
  name          = "development"
  ip_cidr_range = "10.30.0.0/16"
  network       = "${google_compute_network.gcp-2016-advent-calendar.name}"
  description   = "development"
  region        = "us-east1"
}
