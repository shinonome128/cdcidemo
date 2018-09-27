# gcp_provider.tf
// Configure the Google Cloud provider
provider "google" {
  # credentials = "${file("../cicd-demo-707b32bf1a7f.json")}"
  # credentials = "${file("C:\Users\shino\doc\cdcidemo\cicd-demo-707b32bf1a7f.json")}"
  # credentials = "${file("C:/Users/shino/doc/cdcidemo/cicd-demo-707b32bf1a7f.json")}"
  credentials = "${file("C:/Users/shino/doc/cicddemo/cicd-demo-707b32bf1a7f.json")}"
  # project     = "cicd-demo"
  project     = "cicd-demo-215605"
  # region      = "us-east1"
  region      = "asia-northeast1"
}
