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

  // app install
  metadata_startup_script = <<EOT
#!/bin/sh 

# yum update -y 
# yum install -y httpd php 
# systemctl enable httpd.service 
# systemctl start httpd.service 
# firewall-cmd --add-service=http --permanent 
# firewall-cmd --reload 
# yum install -y git  

# install base
sudo apt-get update -y  
sudo apt-get install -y apache2  
sudo apt-get install -y php  
sudo systemctl apache2 restart  
sudo apt-get install -y git  

# install server-app
git clone https://github.com/shinonome128/devops-example-server.git  
cd devops-example-server  
sudo cp example.php /var/www/html/  

# install travics cli
sudo apt-get install -y ruby ruby-dev  
sudo apt-get install -y gcc  
sudo apt-get install -y libffi-dev  
sudo apt-get install -y make  
sudo gem install travis  

EOT

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
