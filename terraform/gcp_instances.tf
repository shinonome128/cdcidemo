# gcp_instances.tf

resource "google_compute_instance" "development" {
  name         = "development"
  machine_type = "n1-standard-1"
  # zone         = "us-east1-b"
  zone         = "asia-northeast1-b"
  # description  = "gcp-2016-advent-calendar"
  description  = "cicddemo"
  tags         = ["development", "mass"]

#  disk {
#    image = "ubuntu-os-cloud/ubuntu-1404-lts"
#  }

  boot_disk {
    initialize_params {
      # image = "ubuntu-os-cloud/ubuntu-1404-lts"
      # image = "projects/centos-cloud/global/images/centos-7-v20180911"
      image = "projects/debian-cloud/global/images/debian-9-stretch-v20180911"
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

/* temp invalid
  // app install
  metadata_startup_script = <<EOT
#!/bin/sh 

yum update -y 
yum install -y httpd php 
systemctl enable httpd.service 
systemctl start httpd.service 
firewall-cmd --add-service=http --permanent 
firewall-cmd --reload 
yum install -y git  
EOT
*/

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
