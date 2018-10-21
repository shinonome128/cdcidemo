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
apt-get update -y  
apt-get install -y apache2  
apt-get install -y php  
systemctl apache2 restart  
apt-get install -y git  

# install server-app
git clone https://github.com/shinonome128/devops-example-server.git  
cd devops-example-server  
cp example.php /var/www/html/  
chmod 777 -R /devops-example-server  
chmod 777 -R /var/www/html

# install travics cli
apt-get install -y ruby ruby-dev  
apt-get install -y gcc  
apt-get install -y libffi-dev  
apt-get install -y make  
gem install travis  

EOT

  // ssh-key
  metadata {  
    # sshKeys = "shinonome128:${file(C:\Users\shino\doc\cicddemo\identity.pub)}"  
    sshKeys = "shinonome128:${file("C:/Users/shino/doc/cicddemo/identity.pub")}"  
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
