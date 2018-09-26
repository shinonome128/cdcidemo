# gcp_instances.tf

resource "google_compute_instance" "development" {
  name         = "development"
  machine_type = "n1-standard-1"
  zone         = "us-east1-b"
  description  = "gcp-2016-advent-calendar"
  tags         = ["development", "mass"]

#  disk {
#    image = "ubuntu-os-cloud/ubuntu-1404-lts"
#  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1404-lts"
    }
  }

#  // Local SSD disk
#  disk {
#    type        = "local-ssd"
#    scratch     = true
#    auto_delete = true
#  }

  scratch_disk {
  }

  network_interface {
    access_config {
      // Ephemeral IP
    }

    subnetwork = "${google_compute_subnetwork.development.name}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro", "bigquery", "monitoring"]
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
  }
}
