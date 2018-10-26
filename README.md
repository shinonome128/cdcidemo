  
# cicddemo  
  
## 目的  
  
CICD環境の構築と動作確認  
プロトタイピング  
全GCP上で作る  
  
## 参考  
  
ドキュメント・コード  
https://github.com/shinonome128/cicddemo  
  
サーバアプリ  
https://github.com/shinonome128/devops-example-server  
  
クライアントアプリ  
https://github.com/shinonome128/devops-example-client  
  
travis ci サーバアプリのディプロイのステータス確認  
https://travis-ci.org/shinonome128/devops-example-server  
  
## やること  
  
最低限、遠い将来、同じものを作るときに必要な起動手順を記載する  
  
ローカルで node.js / npm インスト  
クライアントアプリ準備と起動  
  
  
## ローカルで node.js / npm インスト  
  
本家からダウンロードしてインスト  
```  
node-v8.12.0-x64.msi  
```  
  
インストディレクトリ、ディフォルト  
```  
C:\Program Files\nodejs  
```  
  
パス通しておく  
```  
X:\Users\0002289\AppData\Local\Programs\Python\Python36\Scripts\;X:\Users\0002289\AppData\Local\Programs\Python\Python36\;C:\Program Files (x86)\Nmap;X:\Users\0002289\AppData\Roaming\npm;C:\Program Files\nodejs  
```  
あれー、環境変数変わってない、多分VDI再起動すればいけるかもね、後回し  
  
起動確認とバージョン確認  
```  
cd C:\Program Files\nodejs  
node -v  
npm -v  
```  
  
## クライアントアプリ準備と起動  
  
ローカルPCで実行、npmパスが通っていないとダメ  
```  
cd C:\Users\shino\doc  
git clone https://github.com/yamamoto-febc/devops-example-client-skel devops-example-client  
```  
  
アプリケーション起動テスト  
```  
cd C:\Users\shino\doc\devops-example-client  
npm install && npm start  
```  
  
  
  
ここから再開  
  
  
  
  
## Terraformインスト  
  
Terraform をローカルにダウンロード  
zip なので回答して配置  
パスを通しておく  
Woxからコマンドプロンプトを呼び出す場合は、Evrything / Wox を再起動する  
```  
C:\Users\shino\bin\terraform_0.11.8_windows_amd64\  
```  
  
起動確認  
```  
terraform --version  
```  
OK  
  
## Terraform gcp セットアップ  
  
GCPコンソールからAPIとサービスを選択  
対象プｒジェクトを選択  
Compute Engine API を検索して有効化する  
  
terraform 設定フォルダ作成  
```  
mkdir terraform  
```  
  
terraform 設定ファイルの作成  
```  
echo # gcp_provider.tf >> gcp_provider.tf  
echo # gcp_network.tf >> gcp_network.tf  
echo # gcp_firewall.tf >> gcp_firewall.tf  
echo # gcp_instances.tf >> gcp_instances.tf  
```  
  
コミットとプッシュ  
強制プッシュ  
```  
git push -f  
```  
  
ここから再開、tf ファイルの中身から書き始める  
まずはサンプルから開始、そのあと、環境を最適化する  
その前にGCPのプロジェクトでクレデンシャルファイルの作成が必要そう  
  
## GCPでのクレデンシャルファイルの作成  
  
全部、GUIから作成  
GCP コンソール上からプロジェクト選択  
APIとサービス 選択  
認証情報を選択  
認証情報を作成 クリック  
サービスアカントキー クリック  
Compute Engine default service account を選択  
JSON をチェック  
作成をクリック  
クレデンシャルファイルがブラウザ経由でダウンロードされる  
```  
cicd-demo-707b32bf1a7f.json  
```  
  
.gitignore にクレデンシャルを追加  
完了  
  
クレデンシャルキーを移動  
```  
move C:\Users\shino\Downloads\cicd-demo-707b32bf1a7f.json C:\Users\shino\doc\cdcidemo  
```  
  
## gcp_provider.tf 作成  
  
クレデンシャルファイル  
```  
cicd-demo-707b32bf1a7f.json  
```  
  
プロジェクト  
```  
cicd-demo  
```  
  
リージョン  
```  
us-east1  
```  
  
下記を書き換える  
```  
# gcp_provider.tf  
// Configure the Google Cloud provider  
provider "google" {  
  credentials = "${file("#{service_account_json_file}")}"  
  project     = "mass-gcp-2016-advent-calendar"  
  region      = "asia-northeast1"  
}  
```  
完了  
  
## gcp_network.tf 作成  
  
下記を書き換える  
```  
# gcp_network.tf  
resource "google_compute_network" "gcp-2016-advent-calendar" {  
  name = "gcp-2016-advent-calendar"  
}  
resource "google_compute_subnetwork" "development" {  
  name          = "development"  
  ip_cidr_range = "10.30.0.0/16"  
  network       = "${google_compute_network.gcp-2016-advent-calendar.name}"  
  description   = "development"  
  region        = "asia-northeast1"  
}  
  
```  
  
リージョン  
```  
us-east1  
```  
完了  
  
## gcp_firewall.tf 作成  
  
下記を書き換える  
```  
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
```  
いや、変える部分がないのでOK  
  
## gcp_instances.tf 作成  
  
下記を書き換える  
```  
# gcp_instances.tf  
  
resource "google_compute_instance" "development" {  
  name         = "development"  
  machine_type = "n1-standard-1"  
  zone         = "asia-northeast1-c"  
  description  = "gcp-2016-advent-calendar"  
  tags         = ["development", "mass"]  
  
  disk {  
    image = "ubuntu-os-cloud/ubuntu-1404-lts"  
  }  
  
  // Local SSD disk  
  disk {  
    type        = "local-ssd"  
    scratch     = true  
    auto_delete = true  
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
```  
  
ゾーンを書き換える  
自分のGCPコンソールの所属するus-east1 で、ubuntu-os が使えるゾーンを指定するはず  
GCPコンソールからインスタンス作成時にゾーン選択がありヘルプでゾーン名がわかる  
cicdデモ用のインスタンス配置場所  
```  
us-east1-b  
```  
完了  
  
## Terraform でプラン  
  
tf ファイルを terraform ディレクトリに配置してチェック  
```  
terraform plan terraform  
```  
  
今回は、terraform はパスを通してある、  
サービスアカントは絶対パスで書いている  
```  
C:\Users\shino\doc\cdcidemo>dir /b /s terraform  
C:\Users\shino\doc\cdcidemo\terraform\gcp_firewall.tf  
C:\Users\shino\doc\cdcidemo\terraform\gcp_instances.tf  
C:\Users\shino\doc\cdcidemo\terraform\gcp_network.tf  
C:\Users\shino\doc\cdcidemo\terraform\gcp_provider.tf  
```  
  
プラグイン足りないと怒られる  
```  
C:\Users\shino\doc\cdcidemo>terraform plan terraform  
Plugin reinitialization required. Please run "terraform init".  
Reason: Could not satisfy plugin requirements.  
  
Plugins are external binaries that Terraform uses to access and manipulate  
resources. The configuration provided requires plugins which can't be located,  
don't satisfy the version constraints, or are otherwise incompatible.  
  
1 error(s) occurred:  
  
* provider.google: no suitable version installed  
  version requirements: "(any version)"  
  versions installed: none  
  
Terraform automatically discovers provider requirements from your  
configuration, including providers used in child modules. To see the  
requirements and constraints from each module, run "terraform providers".  
  
  
Error: error satisfying plugin requirements  
```  
  
初期セットアップコマンドを実行  
```  
terraform init terraform  
```  
完了  
terraform ディレクトリが作成されて、ここにプラグインが管理される  
後で、これは管理しないので.gitignore に追加すること  
  
リトライ  
```  
terraform plan terraform  
```  
```  
C:\Users\shino\doc\cdcidemo>terraform plan terraform  
  
Error: Error asking for user input: 1 error(s) occurred:  
  
* provider.google: file: open ../cicd-demo-707b32bf1a7f.json: The system cannot find the file specified. in:  
  
${file("../cicd-demo-707b32bf1a7f.json")}  
```  
サービスアカントのクレデンシャル読み取れないとエラーが出る  
  
方針  
絶対パスにしてみる  
パスをバックスラッシュにしてみる  
tf と同じディレクトリに配置して、.gitignore に記載する  
  
絶対パスにしてみる  
```  
C:\Users\shino\doc\cdcidemo\cicd-demo-707b32bf1a7f.json  
```  
  
リトライ  
```  
terraform plan terraform  
```  
```  
C:\Users\shino\doc\cdcidemo>terraform plan terraform  
  
Error: Error parsing terraform\gcp_provider.tf: At 5:54: illegal char escape  
```  
5行目でエラー？  
  
パスをUNIX表記のスラッシュにしてみる  
```  
  credentials = "${file("C:/Users/shino/doc/cdcidemo/cicd-demo-707b32bf1a7f.json")}"  
```  
  
リトライ  
```  
terraform plan terraform  
```  
```  
C:\Users\shino\doc\cdcidemo>terraform plan terraform  
  
Error: google_compute_instance.development: "boot_disk": required field is not set  
```  
クレデンシャルファイル問題はクリア  
今度はインスタンス設定ファイルでboot_disk 引数が無くて怒られている  
  
方針  
参照元の設定ファイルでもboot_disk 引数が無いことを確認  
tf ファイルのboot_disk 引数の意味を調査  
  
参照元の設定ファイルでもboot_disk 引数が無いことを確認  
ないすね、terraform のテンプレが古いとおおわれる  
GCPコンソールから確認すると、どうやら、OSのタイプと10Gの永続ディスクをしているっポイ  
  
tf ファイルのboot_disk 引数の意味を調査  
terraform テンプレだと、boot_disk があるね、多分これが最新、せいかいなので、ここだけ変更する  
```  
resource "google_compute_instance" "default" {  
  name         = "test"  
  machine_type = "n1-standard-1"  
  zone         = "us-central1-a"  
  
  tags = ["foo", "bar"]  
  
  boot_disk {  
    initialize_params {  
      image = "debian-cloud/debian-9"  
    }  
  }  
  
  // Local SSD disk  
  scratch_disk {  
  }  
  
  network_interface {  
    network = "default"  
  
    access_config {  
      // Ephemeral IP  
    }  
  }  
  
  metadata {  
    foo = "bar"  
  }  
  
  metadata_startup_script = "echo hi > /test.txt"  
  
  service_account {  
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]  
  }  
}  
```  
  
リトライ  
```  
terraform plan terraform  
```  
```  
C:\Users\shino\doc\cdcidemo>terraform plan terraform  
  
Error: google_compute_instance.development: "disk": [REMOVED] Use boot_disk, scratch_disk, and attached_disk instead  
```  
違うエラーがでた、ブートディスク指定したら、今度は、スクラッチディスク、アタッチディスクを使えと来た  
  
ディスク部分も書き換える  
```  
  // Local SSD disk  
  scratch_disk {  
  }  
```  
  
リトライ  
```  
terraform plan terraform  
```  
  
成功時の出力  
```  
C:\Users\shino\doc\cdcidemo>terraform plan terraform  
Refreshing Terraform state in-memory prior to plan...  
The refreshed state will be used to calculate this plan, but will not be  
persisted to local or remote state storage.  
  
  
------------------------------------------------------------------------  
  
An execution plan has been generated and is shown below.  
Resource actions are indicated with the following symbols:  
  + create  
  
Terraform will perform the following actions:  
  
  + google_compute_firewall.development  
      id:                                                  <computed>  
      allow.#:                                             "2"  
      allow.1367131964.ports.#:                            "0"  
      allow.1367131964.protocol:                           "icmp"  
      allow.827249178.ports.#:                             "3"  
      allow.827249178.ports.0:                             "22"  
      allow.827249178.ports.1:                             "80"  
      allow.827249178.ports.2:                             "443"  
      allow.827249178.protocol:                            "tcp"  
      creation_timestamp:                                  <computed>  
      destination_ranges.#:                                <computed>  
      direction:                                           <computed>  
      name:                                                "development"  
      network:                                             "gcp-2016-advent-calendar"  
      priority:                                            "1000"  
      project:                                             <computed>  
      self_link:                                           <computed>  
      source_ranges.#:                                     <computed>  
      target_tags.#:                                       "2"  
      target_tags.1812159334:                              "mass"  
      target_tags.3235258666:                              "development"  
  
  + google_compute_instance.development  
      id:                                                  <computed>  
      boot_disk.#:                                         "1"  
      boot_disk.0.auto_delete:                             "true"  
      boot_disk.0.device_name:                             <computed>  
      boot_disk.0.disk_encryption_key_sha256:              <computed>  
      boot_disk.0.initialize_params.#:                     "1"  
      boot_disk.0.initialize_params.0.image:               "ubuntu-os-cloud/ubuntu-1404-lts"  
      boot_disk.0.initialize_params.0.size:                <computed>  
      boot_disk.0.initialize_params.0.type:                <computed>  
      can_ip_forward:                                      "false"  
      cpu_platform:                                        <computed>  
      create_timeout:                                      "4"  
      deletion_protection:                                 "false"  
      description:                                         "gcp-2016-advent-calendar"  
      guest_accelerator.#:                                 <computed>  
      instance_id:                                         <computed>  
      label_fingerprint:                                   <computed>  
      machine_type:                                        "n1-standard-1"  
      metadata_fingerprint:                                <computed>  
      name:                                                "development"  
      network_interface.#:                                 "1"  
      network_interface.0.access_config.#:                 "1"  
      network_interface.0.access_config.0.assigned_nat_ip: <computed>  
      network_interface.0.access_config.0.nat_ip:          <computed>  
      network_interface.0.access_config.0.network_tier:    <computed>  
      network_interface.0.address:                         <computed>  
      network_interface.0.name:                            <computed>  
      network_interface.0.network_ip:                      <computed>  
      network_interface.0.subnetwork:                      "development"  
      network_interface.0.subnetwork_project:              <computed>  
      project:                                             <computed>  
      scheduling.#:                                        "1"  
      scheduling.0.automatic_restart:                      "true"  
      scheduling.0.on_host_maintenance:                    "MIGRATE"  
      scheduling.0.preemptible:                            "false"  
      scratch_disk.#:                                      "1"  
      scratch_disk.0.interface:                            "SCSI"  
      self_link:                                           <computed>  
      service_account.#:                                   "1"  
      service_account.0.email:                             <computed>  
      service_account.0.scopes.#:                          "5"  
      service_account.0.scopes.1277378754:                 "https://www.googleapis.com/auth/monitoring"  
      service_account.0.scopes.1632638332:                 "https://www.googleapis.com/auth/devstorage.read_only"  
      service_account.0.scopes.2401844655:                 "https://www.googleapis.com/auth/bigquery"  
      service_account.0.scopes.2428168921:                 "https://www.googleapis.com/auth/userinfo.email"  
      service_account.0.scopes.2862113455:                 "https://www.googleapis.com/auth/compute.readonly"  
      tags.#:                                              "2"  
      tags.1812159334:                                     "mass"  
      tags.3235258666:                                     "development"  
      tags_fingerprint:                                    <computed>  
      zone:                                                "us-east1-b"  
  
  + google_compute_network.gcp-2016-advent-calendar  
      id:                                                  <computed>  
      auto_create_subnetworks:                             "true"  
      gateway_ipv4:                                        <computed>  
      name:                                                "gcp-2016-advent-calendar"  
      project:                                             <computed>  
      routing_mode:                                        <computed>  
      self_link:                                           <computed>  
  
  + google_compute_subnetwork.development  
      id:                                                  <computed>  
      creation_timestamp:                                  <computed>  
      description:                                         "development"  
      fingerprint:                                         <computed>  
      gateway_address:                                     <computed>  
      ip_cidr_range:                                       "10.30.0.0/16"  
      name:                                                "development"  
      network:                                             "gcp-2016-advent-calendar"  
      project:                                             <computed>  
      region:                                              "us-east1"  
      secondary_ip_range.#:                                <computed>  
      self_link:                                           <computed>  
  
  
Plan: 4 to add, 0 to change, 0 to destroy.  
  
------------------------------------------------------------------------  
  
Note: You didn't specify an "-out" parameter to save this plan, so Terraform  
can't guarantee that exactly these actions will be performed if  
"terraform apply" is subsequently run.  
  
  
C:\Users\shino\doc\cdcidemo>  
```  
  
## Terraform プラグインの非管理  
  
.gitignore に追加  
```  
.terraform/  
```  
  
## Terraform でアプライ  
  
環境構築  
```  
terraform apply terraform  
```  
```  
Error: Error applying plan:  
  
1 error(s) occurred:  
  
* google_compute_network.gcp-2016-advent-calendar: 1 error(s) occurred:  
  
* google_compute_network.gcp-2016-advent-calendar: Error creating network: googleapi: Error 404: Failed to find project cicd-demo, notFound  
  
Terraform does not automatically rollback in the face of errors.  
Instead, your Terraform state file has been partially updated with  
any resources that successfully completed. Please address the error  
above and apply again to incrementally change your infrastructure.  
```  
アプライ失敗、cicd-demo のプロジェクト名が無い？？  
  
方針  
GCPコンソールからプロジェクト名を調査  
  
GCPコンソールからプロジェクト名を調査  
```  
プロジェクト名  
cicd-demo  
プロジェクト ID  
cicd-demo-215605  
```  
  
名とID、二つある、terraform の tf だとどちらをしているするのか調査  
本家テンプレみると、project パラメータにはIDを指定する  
```  
// Configure the Google Cloud provider  
provider "google" {  
  credentials = "${file("account.json")}"  
  project     = "my-gce-project-id"  
  region      = "us-central1"  
}  
```  
  
リトライ  
```  
terraform apply terraform  
```  
  
成功時のログ  
```  
C:\Users\shino\doc\cdcidemo>terraform apply terraform  
  
An execution plan has been generated and is shown below.  
Resource actions are indicated with the following symbols:  
  + create  
  
Terraform will perform the following actions:  
  
  + google_compute_firewall.development  
      id:                                                  <computed>  
      allow.#:                                             "2"  
      allow.1367131964.ports.#:                            "0"  
      allow.1367131964.protocol:                           "icmp"  
      allow.827249178.ports.#:                             "3"  
      allow.827249178.ports.0:                             "22"  
      allow.827249178.ports.1:                             "80"  
      allow.827249178.ports.2:                             "443"  
      allow.827249178.protocol:                            "tcp"  
      creation_timestamp:                                  <computed>  
      destination_ranges.#:                                <computed>  
      direction:                                           <computed>  
      name:                                                "development"  
      network:                                             "gcp-2016-advent-calendar"  
      priority:                                            "1000"  
      project:                                             <computed>  
      self_link:                                           <computed>  
      source_ranges.#:                                     <computed>  
      target_tags.#:                                       "2"  
      target_tags.1812159334:                              "mass"  
      target_tags.3235258666:                              "development"  
  
  + google_compute_instance.development  
      id:                                                  <computed>  
      boot_disk.#:                                         "1"  
      boot_disk.0.auto_delete:                             "true"  
      boot_disk.0.device_name:                             <computed>  
      boot_disk.0.disk_encryption_key_sha256:              <computed>  
      boot_disk.0.initialize_params.#:                     "1"  
      boot_disk.0.initialize_params.0.image:               "ubuntu-os-cloud/ubuntu-1404-lts"  
      boot_disk.0.initialize_params.0.size:                <computed>  
      boot_disk.0.initialize_params.0.type:                <computed>  
      can_ip_forward:                                      "false"  
      cpu_platform:                                        <computed>  
      create_timeout:                                      "4"  
      deletion_protection:                                 "false"  
      description:                                         "gcp-2016-advent-calendar"  
      guest_accelerator.#:                                 <computed>  
      instance_id:                                         <computed>  
      label_fingerprint:                                   <computed>  
      machine_type:                                        "n1-standard-1"  
      metadata_fingerprint:                                <computed>  
      name:                                                "development"  
      network_interface.#:                                 "1"  
      network_interface.0.access_config.#:                 "1"  
      network_interface.0.access_config.0.assigned_nat_ip: <computed>  
      network_interface.0.access_config.0.nat_ip:          <computed>  
      network_interface.0.access_config.0.network_tier:    <computed>  
      network_interface.0.address:                         <computed>  
      network_interface.0.name:                            <computed>  
      network_interface.0.network_ip:                      <computed>  
      network_interface.0.subnetwork:                      "development"  
      network_interface.0.subnetwork_project:              <computed>  
      project:                                             <computed>  
      scheduling.#:                                        "1"  
      scheduling.0.automatic_restart:                      "true"  
      scheduling.0.on_host_maintenance:                    "MIGRATE"  
      scheduling.0.preemptible:                            "false"  
      scratch_disk.#:                                      "1"  
      scratch_disk.0.interface:                            "SCSI"  
      self_link:                                           <computed>  
      service_account.#:                                   "1"  
      service_account.0.email:                             <computed>  
      service_account.0.scopes.#:                          "5"  
      service_account.0.scopes.1277378754:                 "https://www.googleapis.com/auth/monitoring"  
      service_account.0.scopes.1632638332:                 "https://www.googleapis.com/auth/devstorage.read_only"  
      service_account.0.scopes.2401844655:                 "https://www.googleapis.com/auth/bigquery"  
      service_account.0.scopes.2428168921:                 "https://www.googleapis.com/auth/userinfo.email"  
      service_account.0.scopes.2862113455:                 "https://www.googleapis.com/auth/compute.readonly"  
      tags.#:                                              "2"  
      tags.1812159334:                                     "mass"  
      tags.3235258666:                                     "development"  
      tags_fingerprint:                                    <computed>  
      zone:                                                "us-east1-b"  
  
  + google_compute_network.gcp-2016-advent-calendar  
      id:                                                  <computed>  
      auto_create_subnetworks:                             "true"  
      gateway_ipv4:                                        <computed>  
      name:                                                "gcp-2016-advent-calendar"  
      project:                                             <computed>  
      routing_mode:                                        <computed>  
      self_link:                                           <computed>  
  
  + google_compute_subnetwork.development  
      id:                                                  <computed>  
      creation_timestamp:                                  <computed>  
      description:                                         "development"  
      fingerprint:                                         <computed>  
      gateway_address:                                     <computed>  
      ip_cidr_range:                                       "10.30.0.0/16"  
      name:                                                "development"  
      network:                                             "gcp-2016-advent-calendar"  
      project:                                             <computed>  
      region:                                              "us-east1"  
      secondary_ip_range.#:                                <computed>  
      self_link:                                           <computed>  
  
  
Plan: 4 to add, 0 to change, 0 to destroy.  
  
Do you want to perform these actions?  
  Terraform will perform the actions described above.  
  Only 'yes' will be accepted to approve.  
  
  Enter a value: yes  
  
google_compute_network.gcp-2016-advent-calendar: Creating...  
  auto_create_subnetworks: "" => "true"  
  gateway_ipv4:            "" => "<computed>"  
  name:                    "" => "gcp-2016-advent-calendar"  
  project:                 "" => "<computed>"  
  routing_mode:            "" => "<computed>"  
  self_link:               "" => "<computed>"  
google_compute_network.gcp-2016-advent-calendar: Still creating... (10s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Still creating... (20s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Still creating... (30s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Creation complete after 38s (ID: gcp-2016-advent-calendar)  
google_compute_subnetwork.development: Creating...  
  creation_timestamp:   "" => "<computed>"  
  description:          "" => "development"  
  fingerprint:          "" => "<computed>"  
  gateway_address:      "" => "<computed>"  
  ip_cidr_range:        "" => "10.30.0.0/16"  
  name:                 "" => "development"  
  network:              "" => "gcp-2016-advent-calendar"  
  project:              "" => "<computed>"  
  region:               "" => "us-east1"  
  secondary_ip_range.#: "" => "<computed>"  
  self_link:            "" => "<computed>"  
google_compute_subnetwork.development: Still creating... (10s elapsed)  
google_compute_subnetwork.development: Creation complete after 19s (ID: us-east1/development)  
google_compute_instance.development: Creating...  
  boot_disk.#:                                         "" => "1"  
  boot_disk.0.auto_delete:                             "" => "true"  
  boot_disk.0.device_name:                             "" => "<computed>"  
  boot_disk.0.disk_encryption_key_sha256:              "" => "<computed>"  
  boot_disk.0.initialize_params.#:                     "" => "1"  
  boot_disk.0.initialize_params.0.image:               "" => "ubuntu-os-cloud/ubuntu-1404-lts"  
  boot_disk.0.initialize_params.0.size:                "" => "<computed>"  
  boot_disk.0.initialize_params.0.type:                "" => "<computed>"  
  can_ip_forward:                                      "" => "false"  
  cpu_platform:                                        "" => "<computed>"  
  create_timeout:                                      "" => "4"  
  deletion_protection:                                 "" => "false"  
  description:                                         "" => "gcp-2016-advent-calendar"  
  guest_accelerator.#:                                 "" => "<computed>"  
  instance_id:                                         "" => "<computed>"  
  label_fingerprint:                                   "" => "<computed>"  
  machine_type:                                        "" => "n1-standard-1"  
  metadata_fingerprint:                                "" => "<computed>"  
  name:                                                "" => "development"  
  network_interface.#:                                 "" => "1"  
  network_interface.0.access_config.#:                 "" => "1"  
  network_interface.0.access_config.0.assigned_nat_ip: "" => "<computed>"  
  network_interface.0.access_config.0.nat_ip:          "" => "<computed>"  
  network_interface.0.access_config.0.network_tier:    "" => "<computed>"  
  network_interface.0.address:                         "" => "<computed>"  
  network_interface.0.name:                            "" => "<computed>"  
  network_interface.0.network_ip:                      "" => "<computed>"  
  network_interface.0.subnetwork:                      "" => "development"  
  network_interface.0.subnetwork_project:              "" => "<computed>"  
  project:                                             "" => "<computed>"  
  scheduling.#:                                        "" => "1"  
  scheduling.0.automatic_restart:                      "" => "true"  
  scheduling.0.on_host_maintenance:                    "" => "MIGRATE"  
  scheduling.0.preemptible:                            "" => "false"  
  scratch_disk.#:                                      "" => "1"  
  scratch_disk.0.interface:                            "" => "SCSI"  
  self_link:                                           "" => "<computed>"  
  service_account.#:                                   "" => "1"  
  service_account.0.email:                             "" => "<computed>"  
  service_account.0.scopes.#:                          "" => "5"  
  service_account.0.scopes.1277378754:                 "" => "https://www.googleapis.com/auth/monitoring"  
  service_account.0.scopes.1632638332:                 "" => "https://www.googleapis.com/auth/devstorage.read_only"  
  service_account.0.scopes.2401844655:                 "" => "https://www.googleapis.com/auth/bigquery"  
  service_account.0.scopes.2428168921:                 "" => "https://www.googleapis.com/auth/userinfo.email"  
  service_account.0.scopes.2862113455:                 "" => "https://www.googleapis.com/auth/compute.readonly"  
  tags.#:                                              "" => "2"  
  tags.1812159334:                                     "" => "mass"  
  tags.3235258666:                                     "" => "development"  
  tags_fingerprint:                                    "" => "<computed>"  
  zone:                                                "" => "us-east1-b"  
google_compute_instance.development: Still creating... (10s elapsed)  
google_compute_instance.development: Still creating... (20s elapsed)  
google_compute_instance.development: Creation complete after 30s (ID: development)  
google_compute_firewall.development: Creating...  
  allow.#:                   "" => "2"  
  allow.1367131964.ports.#:  "" => "0"  
  allow.1367131964.protocol: "" => "icmp"  
  allow.827249178.ports.#:   "" => "3"  
  allow.827249178.ports.0:   "" => "22"  
  allow.827249178.ports.1:   "" => "80"  
  allow.827249178.ports.2:   "" => "443"  
  allow.827249178.protocol:  "" => "tcp"  
  creation_timestamp:        "" => "<computed>"  
  destination_ranges.#:      "" => "<computed>"  
  direction:                 "" => "<computed>"  
  name:                      "" => "development"  
  network:                   "" => "gcp-2016-advent-calendar"  
  priority:                  "" => "1000"  
  project:                   "" => "<computed>"  
  self_link:                 "" => "<computed>"  
  source_ranges.#:           "" => "<computed>"  
  target_tags.#:             "" => "2"  
  target_tags.1812159334:    "" => "mass"  
  target_tags.3235258666:    "" => "development"  
google_compute_firewall.development: Still creating... (10s elapsed)  
google_compute_firewall.development: Creation complete after 12s (ID: development)  
  
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.  
  
C:\Users\shino\doc\cdcidemo>  
```  
  
GCPコンソールからインスタンスが作成されているかを確認  
OK、きちんと作成されている  
外部IPにも直接公開されてるっぽい  
  
## Terraform によるデストロイ  
  
作成環境の削除前チェックと削除  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
削除時のログ  
```  
C:\Users\shino\doc\cdcidemo>terraform plan -destroy terraform  
Refreshing Terraform state in-memory prior to plan...  
The refreshed state will be used to calculate this plan, but will not be  
persisted to local or remote state storage.  
  
google_compute_network.gcp-2016-advent-calendar: Refreshing state... (ID: gcp-2016-advent-calendar)  
google_compute_subnetwork.development: Refreshing state... (ID: us-east1/development)  
google_compute_instance.development: Refreshing state... (ID: development)  
google_compute_firewall.development: Refreshing state... (ID: development)  
  
------------------------------------------------------------------------  
  
An execution plan has been generated and is shown below.  
Resource actions are indicated with the following symbols:  
  - destroy  
  
Terraform will perform the following actions:  
  
  - google_compute_firewall.development  
  
  - google_compute_instance.development  
  
  - google_compute_network.gcp-2016-advent-calendar  
  
  - google_compute_subnetwork.development  
  
  
Plan: 0 to add, 0 to change, 4 to destroy.  
  
------------------------------------------------------------------------  
  
Note: You didn't specify an "-out" parameter to save this plan, so Terraform  
can't guarantee that exactly these actions will be performed if  
"terraform apply" is subsequently run.  
  
  
C:\Users\shino\doc\cdcidemo>  
C:\Users\shino\doc\cdcidemo>  
C:\Users\shino\doc\cdcidemo>terraform destroy terraform  
google_compute_network.gcp-2016-advent-calendar: Refreshing state... (ID: gcp-2016-advent-calendar)  
google_compute_subnetwork.development: Refreshing state... (ID: us-east1/development)  
google_compute_instance.development: Refreshing state... (ID: development)  
google_compute_firewall.development: Refreshing state... (ID: development)  
  
An execution plan has been generated and is shown below.  
Resource actions are indicated with the following symbols:  
  - destroy  
  
Terraform will perform the following actions:  
  
  - google_compute_firewall.development  
  
  - google_compute_instance.development  
  
  - google_compute_network.gcp-2016-advent-calendar  
  
  - google_compute_subnetwork.development  
  
  
Plan: 0 to add, 0 to change, 4 to destroy.  
  
Do you really want to destroy all resources?  
  Terraform will destroy all your managed infrastructure, as shown above.  
  There is no undo. Only 'yes' will be accepted to confirm.  
  
  Enter a value: yes  
  
google_compute_firewall.development: Destroying... (ID: development)  
google_compute_firewall.development: Still destroying... (ID: development, 10s elapsed)  
google_compute_firewall.development: Destruction complete after 12s  
google_compute_instance.development: Destroying... (ID: development)  
google_compute_instance.development: Still destroying... (ID: development, 10s elapsed)  
google_compute_instance.development: Still destroying... (ID: development, 20s elapsed)  
google_compute_instance.development: Still destroying... (ID: development, 30s elapsed)  
google_compute_instance.development: Still destroying... (ID: development, 40s elapsed)  
google_compute_instance.development: Still destroying... (ID: development, 50s elapsed)  
google_compute_instance.development: Still destroying... (ID: development, 1m0s elapsed)  
google_compute_instance.development: Destruction complete after 1m8s  
google_compute_subnetwork.development: Destroying... (ID: us-east1/development)  
google_compute_subnetwork.development: Still destroying... (ID: us-east1/development, 10s elapsed)  
google_compute_subnetwork.development: Destruction complete after 18s  
google_compute_network.gcp-2016-advent-calendar: Destroying... (ID: gcp-2016-advent-calendar)  
google_compute_network.gcp-2016-advent-calendar: Still destroying... (ID: gcp-2016-advent-calendar, 10s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Still destroying... (ID: gcp-2016-advent-calendar, 20s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Still destroying... (ID: gcp-2016-advent-calendar, 30s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Still destroying... (ID: gcp-2016-advent-calendar, 40s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Still destroying... (ID: gcp-2016-advent-calendar, 50s elapsed)  
google_compute_network.gcp-2016-advent-calendar: Destruction complete after 59s  
  
Destroy complete! Resources: 4 destroyed.  
  
C:\Users\shino\doc\cdcidemo>  
```  
  
GCPコンソール上から削除されているかを確認  
インスタンスは削除というよりも無効化されている、多分、プロジェクト削除時と同じで、24時間後に完全削除されると思われる  
ディスクは削除されている  
ネットワークは削除されている  
  
## git のリポジトリ名変更  
  
変更前  
```  
https://github.com/shinonome128/cdcidemo.git  
```  
  
変更後  
```  
https://github.com/shinonome128/cicddemo.git  
```  
  
Gitハブ上のGUIからリポジトリを変更  
完了  
  
ローカルGitクライアントの事前確認  
```  
git remote -v  
```  
  
ローカルのGitクライアントの向け先を変更  
```  
git remote set-url origin https://github.com/shinonome128/cicddemo.git  
```  
  
## Terrafrom によるステート管理方法  
  
tf ファイルで指定したディレクトリ名にドット付きのファイル名が生成される  
```  
2018/09/27  19:38    <DIR>          terraform  
2018/09/27  19:50               317 terraform.tfstate  
2018/09/27  19:48            11,846 terraform.tfstate.backup  
```  
  
環境削除前の状態  
```  
{  
    "version": 3,  
    "terraform_version": "0.11.8",  
    "serial": 3,  
    "lineage": "131bdbc2-582c-862a-da65-b8923e3806a1",  
    "modules": [  
        {  
            "path": [  
                "root"  
            ],  
            "outputs": {},  
            "resources": {  
                "google_compute_firewall.development": {  
                    "type": "google_compute_firewall",  
                    "depends_on": [  
                        "google_compute_instance.development",  
                        "google_compute_network.gcp-2016-advent-calendar"  
                    ],  
                    "primary": {  
                        "id": "development",  
                        "attributes": {  
                            "allow.#": "2",  
                            "allow.1367131964.ports.#": "0",  
                            "allow.1367131964.protocol": "icmp",  
                            "allow.827249178.ports.#": "3",  
                            "allow.827249178.ports.0": "22",  
                            "allow.827249178.ports.1": "80",  
                            "allow.827249178.ports.2": "443",  
                            "allow.827249178.protocol": "tcp",  
                            "creation_timestamp": "2018-09-27T03:27:14.849-07:00",  
                            "deny.#": "0",  
                            "description": "",  
                            "destination_ranges.#": "0",  
                            "direction": "INGRESS",  
                            "disabled": "false",  
                            "enable_logging": "false",  
                            "id": "development",  
                            "name": "development",  
                            "network": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/global/networks/gcp-2016-advent-calendar",  
                            "priority": "1000",  
                            "project": "cicd-demo-215605",  
                            "self_link": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/global/firewalls/development",  
                            "source_ranges.#": "1",  
                            "source_ranges.1080289494": "0.0.0.0/0",  
                            "source_service_accounts.#": "0",  
                            "source_tags.#": "0",  
                            "target_service_accounts.#": "0",  
                            "target_tags.#": "2",  
                            "target_tags.1812159334": "mass",  
                            "target_tags.3235258666": "development"  
                        },  
                        "meta": {  
                            "e2bfb730-ecaa-11e6-8f88-34363bc7c4c0": {  
                                "create": 240000000000,  
                                "delete": 240000000000,  
                                "update": 240000000000  
                            },  
                            "schema_version": "1"  
                        },  
                        "tainted": false  
                    },  
                    "deposed": [],  
                    "provider": "provider.google"  
                },  
                "google_compute_instance.development": {  
                    "type": "google_compute_instance",  
                    "depends_on": [  
                        "google_compute_subnetwork.development"  
                    ],  
                    "primary": {  
                        "id": "development",  
                        "attributes": {  
                            "attached_disk.#": "0",  
                            "boot_disk.#": "1",  
                            "boot_disk.0.auto_delete": "true",  
                            "boot_disk.0.device_name": "persistent-disk-0",  
                            "boot_disk.0.disk_encryption_key_raw": "",  
                            "boot_disk.0.disk_encryption_key_sha256": "",  
                            "boot_disk.0.initialize_params.#": "1",  
                            "boot_disk.0.initialize_params.0.image": "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-1404-trusty-v20180913",  
                            "boot_disk.0.initialize_params.0.size": "10",  
                            "boot_disk.0.initialize_params.0.type": "pd-standard",  
                            "boot_disk.0.source": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/zones/us-east1-b/disks/development",  
                            "can_ip_forward": "false",  
                            "cpu_platform": "Intel Haswell",  
                            "create_timeout": "4",  
                            "deletion_protection": "false",  
                            "description": "gcp-2016-advent-calendar",  
                            "guest_accelerator.#": "0",  
                            "id": "development",  
                            "instance_id": "2571438154032680585",  
                            "label_fingerprint": "42WmSpB8rSM=",  
                            "labels.%": "0",  
                            "machine_type": "n1-standard-1",  
                            "metadata.%": "0",  
                            "metadata_fingerprint": "kSzwCHeRbWU=",  
                            "metadata_startup_script": "",  
                            "min_cpu_platform": "",  
                            "name": "development",  
                            "network_interface.#": "1",  
                            "network_interface.0.access_config.#": "1",  
                            "network_interface.0.access_config.0.assigned_nat_ip": "35.229.95.157",  
                            "network_interface.0.access_config.0.nat_ip": "35.229.95.157",  
                            "network_interface.0.access_config.0.network_tier": "PREMIUM",  
                            "network_interface.0.access_config.0.public_ptr_domain_name": "",  
                            "network_interface.0.address": "10.30.0.2",  
                            "network_interface.0.alias_ip_range.#": "0",  
                            "network_interface.0.name": "nic0",  
                            "network_interface.0.network": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/global/networks/gcp-2016-advent-calendar",  
                            "network_interface.0.network_ip": "10.30.0.2",  
                            "network_interface.0.subnetwork": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/regions/us-east1/subnetworks/development",  
                            "network_interface.0.subnetwork_project": "cicd-demo-215605",  
                            "project": "cicd-demo-215605",  
                            "scheduling.#": "1",  
                            "scheduling.0.automatic_restart": "true",  
                            "scheduling.0.on_host_maintenance": "MIGRATE",  
                            "scheduling.0.preemptible": "false",  
                            "scratch_disk.#": "1",  
                            "scratch_disk.0.interface": "SCSI",  
                            "self_link": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/zones/us-east1-b/instances/development",  
                            "service_account.#": "1",  
                            "service_account.0.email": "824533405532-compute@developer.gserviceaccount.com",  
                            "service_account.0.scopes.#": "5",  
                            "service_account.0.scopes.1277378754": "https://www.googleapis.com/auth/monitoring",  
                            "service_account.0.scopes.1632638332": "https://www.googleapis.com/auth/devstorage.read_only",  
                            "service_account.0.scopes.2401844655": "https://www.googleapis.com/auth/bigquery",  
                            "service_account.0.scopes.2428168921": "https://www.googleapis.com/auth/userinfo.email",  
                            "service_account.0.scopes.2862113455": "https://www.googleapis.com/auth/compute.readonly",  
                            "tags.#": "2",  
                            "tags.1812159334": "mass",  
                            "tags.3235258666": "development",  
                            "tags_fingerprint": "HGyaLRKG3mY=",  
                            "zone": "us-east1-b"  
                        },  
                        "meta": {  
                            "e2bfb730-ecaa-11e6-8f88-34363bc7c4c0": {  
                                "create": 360000000000,  
                                "delete": 360000000000,  
                                "update": 360000000000  
                            },  
                            "schema_version": "6"  
                        },  
                        "tainted": false  
                    },  
                    "deposed": [],  
                    "provider": "provider.google"  
                },  
                "google_compute_network.gcp-2016-advent-calendar": {  
                    "type": "google_compute_network",  
                    "depends_on": [],  
                    "primary": {  
                        "id": "gcp-2016-advent-calendar",  
                        "attributes": {  
                            "auto_create_subnetworks": "true",  
                            "description": "",  
                            "gateway_ipv4": "",  
                            "id": "gcp-2016-advent-calendar",  
                            "ipv4_range": "",  
                            "name": "gcp-2016-advent-calendar",  
                            "project": "cicd-demo-215605",  
                            "routing_mode": "REGIONAL",  
                            "self_link": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/global/networks/gcp-2016-advent-calendar"  
                        },  
                        "meta": {},  
                        "tainted": false  
                    },  
                    "deposed": [],  
                    "provider": "provider.google"  
                },  
                "google_compute_subnetwork.development": {  
                    "type": "google_compute_subnetwork",  
                    "depends_on": [  
                        "google_compute_network.gcp-2016-advent-calendar"  
                    ],  
                    "primary": {  
                        "id": "us-east1/development",  
                        "attributes": {  
                            "creation_timestamp": "2018-09-27T03:26:26.147-07:00",  
                            "description": "development",  
                            "enable_flow_logs": "false",  
                            "fingerprint": "7HGno5zKSJE=",  
                            "gateway_address": "10.30.0.1",  
                            "id": "us-east1/development",  
                            "ip_cidr_range": "10.30.0.0/16",  
                            "name": "development",  
                            "network": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/global/networks/gcp-2016-advent-calendar",  
                            "private_ip_google_access": "false",  
                            "project": "cicd-demo-215605",  
                            "region": "us-east1",  
                            "secondary_ip_range.#": "0",  
                            "self_link": "https://www.googleapis.com/compute/v1/projects/cicd-demo-215605/regions/us-east1/subnetworks/development"  
                        },  
                        "meta": {  
                            "e2bfb730-ecaa-11e6-8f88-34363bc7c4c0": {  
                                "create": 360000000000,  
                                "delete": 360000000000,  
                                "update": 360000000000  
                            }  
                        },  
                        "tainted": false  
                    },  
                    "deposed": [],  
                    "provider": "provider.google"  
                }  
            },  
            "depends_on": []  
        }  
    ]  
}  
```  
  
環境削除時の状態  
```  
{  
    "version": 3,  
    "terraform_version": "0.11.8",  
    "serial": 3,  
    "lineage": "131bdbc2-582c-862a-da65-b8923e3806a1",  
    "modules": [  
        {  
            "path": [  
                "root"  
            ],  
            "outputs": {},  
            "resources": {},  
            "depends_on": []  
        }  
    ]  
}  
```  
  
複数人でリリース作業が重複する可能性がある場合は、外部ストレージにおいて、terraform からリモート参照させることで管理する  
多分、CICD環境作るときは、CIツールとterraformを動作させるので、そこでステートファイルを参照できるようにしておく  
秘匿性の高い情報が含まれるの公開バージョン管理はしない  
なので.gitignore に追記しておく  
```  
*.tfstate  
*.tfstate.backup  
```  
  
## サーバ側のデプロイの自動化  
  
方針  
tf ファイルを編集してゆく  
centos を最も小さいサイズで起動  
GCPのfirewall で自宅からのアクセスに制限する  
ネットワーク名とかインスタンス名は適当に変更する  
サーバインフラ構築後、yum で apacheインスト、 firewall許可  
  
gcp_provider.tf  
東京リージョンに変更  
```  
asia-northeast1  
```  
  
gcp_network.tf  
ネットワーク名をcicddemo に変更  
東京リージョンに変更  
```  
cicddemo  
```  
```  
asia-northeast1  
```  
  
gcp_firewall.tf  
ネットワーク名をcicddemo に変更  
グローバルIPを追加  
```  
cicddemo  
```  
```  
116.220.197.54  
```  
  
gcp_instances.tf  
東京リージョンのゾーンに変更  
ディスクリプションを変更  
centos に変更  
```  
asia-northeast1-b  
```  
```  
cicddemo  
```  
```  
projects/centos-cloud/global/images/centos-7-v20180911  
```  
OSのパラメータはそのまま、tf がGCP APIに渡しているので、GCPコンソールからイメージ作成メニューを開き、REST 取得する、ACIと同じだね  
  
変更確認  
```  
terraform plan terraform  
```  
モーマンタイ  
  
gcp_instances.tf  
サーバインフラ構築後、yum で apacheインスト  
下記の部分の制御を追加する  
```  
resource "sakuracloud_note" "init" {  
  name  = "install-php"  
  class = "shell"  
  
  content = << EOF  
#!/bin/sh  
  
yum update -y  
yum install -y httpd php  
systemctl enable httpd.service  
systemctl start httpd.service  
firewall-cmd --add-service=http --permanent  
firewall-cmd --reload  
EOF  
}  
```  
読み込み先  
```  
  startup_script_ids = ["${sakuracloud_note.init.id}"]  
```  
tf 本家でスタートアップで使っているので、モジュール化すればよい  
```  
  metadata_startup_script = "echo hi > /test.txt"  
```  
GMOでのお手本、リソースの中にベタ打ち  
```  
  metadata_startup_script = <<EOT  
yum install -y policycoreutils-python  
semanage port -a -t ssh_port_t -p tcp 10022  
sed -i 's/^#Port 22/Port 22\nPort 10022/' /etc/ssh/sshd_config  
systemctl restart sshd  
timedatectl set-timezone Asia/Tokyo  
EOT  
```  
  
変更確認  
```  
terraform init  
terraform plan terraform  
```  
モーマンタイ  
  
ディプロイ  
```  
terraform apply terraform  
```  
```  
Error: Error applying plan:  
  
1 error(s) occurred:  
  
* google_compute_instance.development: 1 error(s) occurred:  
  
* google_compute_instance.development: Error creating instance: googleapi: Error 400: Invalid value for field 'resource.networkInterfaces[0].subnetwork': 'projects/cicd-demo-215605/regions/us-east1/subnetworks/development'. The referenced subnetwork resource cannot be found., invalid  
  
Terraform does not automatically rollback in the face of errors.  
Instead, your Terraform state file has been partially updated with  
any resources that successfully completed. Please address the error  
above and apply again to incrementally change your infrastructure.  
```  
あらー、なんか問題発生しとる、us-east1 のリージョン名が間違ってる  
  
リトライ  
```  
terraform apply terraform  
```  
  
成功時のログ  
```  
C:\Users\shino\doc\cicddemo>terraform apply terraform  
google_compute_network.cicddemo: Refreshing state... (ID: cicddemo)  
google_compute_subnetwork.development: Refreshing state... (ID: asia-northeast1/development)  
  
An execution plan has been generated and is shown below.  
Resource actions are indicated with the following symbols:  
  + create  
  
Terraform will perform the following actions:  
  
  + google_compute_firewall.development  
      id:                                                  <computed>  
      allow.#:                                             "2"  
      allow.1367131964.ports.#:                            "0"  
      allow.1367131964.protocol:                           "icmp"  
      allow.827249178.ports.#:                             "3"  
      allow.827249178.ports.0:                             "22"  
      allow.827249178.ports.1:                             "80"  
      allow.827249178.ports.2:                             "443"  
      allow.827249178.protocol:                            "tcp"  
      creation_timestamp:                                  <computed>  
      destination_ranges.#:                                <computed>  
      direction:                                           <computed>  
      name:                                                "development"  
      network:                                             "cicddemo"  
      priority:                                            "1000"  
      project:                                             <computed>  
      self_link:                                           <computed>  
      source_ranges.#:                                     "1"  
      source_ranges.3425672128:                            "116.220.197.54/32"  
      target_tags.#:                                       "2"  
      target_tags.1812159334:                              "mass"  
      target_tags.3235258666:                              "development"  
  
  + google_compute_instance.development  
      id:                                                  <computed>  
      boot_disk.#:                                         "1"  
      boot_disk.0.auto_delete:                             "true"  
      boot_disk.0.device_name:                             <computed>  
      boot_disk.0.disk_encryption_key_sha256:              <computed>  
      boot_disk.0.initialize_params.#:                     "1"  
      boot_disk.0.initialize_params.0.image:               "projects/centos-cloud/global/images/centos-7-v20180911"  
      boot_disk.0.initialize_params.0.size:                <computed>  
      boot_disk.0.initialize_params.0.type:                <computed>  
      can_ip_forward:                                      "false"  
      cpu_platform:                                        <computed>  
      create_timeout:                                      "4"  
      deletion_protection:                                 "false"  
      description:                                         "cicddemo"  
      guest_accelerator.#:                                 <computed>  
      instance_id:                                         <computed>  
      label_fingerprint:                                   <computed>  
      machine_type:                                        "n1-standard-1"  
      metadata_fingerprint:                                <computed>  
      metadata_startup_script:                             "#!/bin/sh \n\nyum update -y \nyum install -y httpd php \nsystemctl enable httpd.service \nsystemctl start httpd.service \nfirewall-cmd --add-service=http --permanent \nfirewall-cmd --reload \n"  
      name:                                                "development"  
      network_interface.#:                                 "1"  
      network_interface.0.access_config.#:                 "1"  
      network_interface.0.access_config.0.assigned_nat_ip: <computed>  
      network_interface.0.access_config.0.nat_ip:          <computed>  
      network_interface.0.access_config.0.network_tier:    <computed>  
      network_interface.0.address:                         <computed>  
      network_interface.0.name:                            <computed>  
      network_interface.0.network_ip:                      <computed>  
      network_interface.0.subnetwork:                      "development"  
      network_interface.0.subnetwork_project:              <computed>  
      project:                                             <computed>  
      scheduling.#:                                        "1"  
      scheduling.0.automatic_restart:                      "true"  
      scheduling.0.on_host_maintenance:                    "MIGRATE"  
      scheduling.0.preemptible:                            "false"  
      scratch_disk.#:                                      "1"  
      scratch_disk.0.interface:                            "SCSI"  
      self_link:                                           <computed>  
      service_account.#:                                   "1"  
      service_account.0.email:                             <computed>  
      service_account.0.scopes.#:                          "5"  
      service_account.0.scopes.1277378754:                 "https://www.googleapis.com/auth/monitoring"  
      service_account.0.scopes.1632638332:                 "https://www.googleapis.com/auth/devstorage.read_only"  
      service_account.0.scopes.2401844655:                 "https://www.googleapis.com/auth/bigquery"  
      service_account.0.scopes.2428168921:                 "https://www.googleapis.com/auth/userinfo.email"  
      service_account.0.scopes.2862113455:                 "https://www.googleapis.com/auth/compute.readonly"  
      tags.#:                                              "2"  
      tags.1812159334:                                     "mass"  
      tags.3235258666:                                     "development"  
      tags_fingerprint:                                    <computed>  
      zone:                                                "asia-northeast1-b"  
  
  
Plan: 2 to add, 0 to change, 0 to destroy.  
  
Do you want to perform these actions?  
  Terraform will perform the actions described above.  
  Only 'yes' will be accepted to approve.  
  
  Enter a value: yes  
  
google_compute_instance.development: Creating...  
  boot_disk.#:                                         "" => "1"  
  boot_disk.0.auto_delete:                             "" => "true"  
  boot_disk.0.device_name:                             "" => "<computed>"  
  boot_disk.0.disk_encryption_key_sha256:              "" => "<computed>"  
  boot_disk.0.initialize_params.#:                     "" => "1"  
  boot_disk.0.initialize_params.0.image:               "" => "projects/centos-cloud/global/images/centos-7-v20180911"  
  boot_disk.0.initialize_params.0.size:                "" => "<computed>"  
  boot_disk.0.initialize_params.0.type:                "" => "<computed>"  
  can_ip_forward:                                      "" => "false"  
  cpu_platform:                                        "" => "<computed>"  
  create_timeout:                                      "" => "4"  
  deletion_protection:                                 "" => "false"  
  description:                                         "" => "cicddemo"  
  guest_accelerator.#:                                 "" => "<computed>"  
  instance_id:                                         "" => "<computed>"  
  label_fingerprint:                                   "" => "<computed>"  
  machine_type:                                        "" => "n1-standard-1"  
  metadata_fingerprint:                                "" => "<computed>"  
  metadata_startup_script:                             "" => "#!/bin/sh \n\nyum update -y \nyum install -y httpd php \nsystemctl enable httpd.service \nsystemctl start httpd.service \nfirewall-cmd --add-service=http --permanent \nfirewall-cmd --reload \n"  
  name:                                                "" => "development"  
  network_interface.#:                                 "" => "1"  
  network_interface.0.access_config.#:                 "" => "1"  
  network_interface.0.access_config.0.assigned_nat_ip: "" => "<computed>"  
  network_interface.0.access_config.0.nat_ip:          "" => "<computed>"  
  network_interface.0.access_config.0.network_tier:    "" => "<computed>"  
  network_interface.0.address:                         "" => "<computed>"  
  network_interface.0.name:                            "" => "<computed>"  
  network_interface.0.network_ip:                      "" => "<computed>"  
  network_interface.0.subnetwork:                      "" => "development"  
  network_interface.0.subnetwork_project:              "" => "<computed>"  
  project:                                             "" => "<computed>"  
  scheduling.#:                                        "" => "1"  
  scheduling.0.automatic_restart:                      "" => "true"  
  scheduling.0.on_host_maintenance:                    "" => "MIGRATE"  
  scheduling.0.preemptible:                            "" => "false"  
  scratch_disk.#:                                      "" => "1"  
  scratch_disk.0.interface:                            "" => "SCSI"  
  self_link:                                           "" => "<computed>"  
  service_account.#:                                   "" => "1"  
  service_account.0.email:                             "" => "<computed>"  
  service_account.0.scopes.#:                          "" => "5"  
  service_account.0.scopes.1277378754:                 "" => "https://www.googleapis.com/auth/monitoring"  
  service_account.0.scopes.1632638332:                 "" => "https://www.googleapis.com/auth/devstorage.read_only"  
  service_account.0.scopes.2401844655:                 "" => "https://www.googleapis.com/auth/bigquery"  
  service_account.0.scopes.2428168921:                 "" => "https://www.googleapis.com/auth/userinfo.email"  
  service_account.0.scopes.2862113455:                 "" => "https://www.googleapis.com/auth/compute.readonly"  
  tags.#:                                              "" => "2"  
  tags.1812159334:                                     "" => "mass"  
  tags.3235258666:                                     "" => "development"  
  tags_fingerprint:                                    "" => "<computed>"  
  zone:                                                "" => "asia-northeast1-b"  
google_compute_instance.development: Still creating... (10s elapsed)  
google_compute_instance.development: Still creating... (20s elapsed)  
google_compute_instance.development: Creation complete after 30s (ID: development)  
google_compute_firewall.development: Creating...  
  allow.#:                   "" => "2"  
  allow.1367131964.ports.#:  "" => "0"  
  allow.1367131964.protocol: "" => "icmp"  
  allow.827249178.ports.#:   "" => "3"  
  allow.827249178.ports.0:   "" => "22"  
  allow.827249178.ports.1:   "" => "80"  
  allow.827249178.ports.2:   "" => "443"  
  allow.827249178.protocol:  "" => "tcp"  
  creation_timestamp:        "" => "<computed>"  
  destination_ranges.#:      "" => "<computed>"  
  direction:                 "" => "<computed>"  
  name:                      "" => "development"  
  network:                   "" => "cicddemo"  
  priority:                  "" => "1000"  
  project:                   "" => "<computed>"  
  self_link:                 "" => "<computed>"  
  source_ranges.#:           "" => "1"  
  source_ranges.3425672128:  "" => "116.220.197.54/32"  
  target_tags.#:             "" => "2"  
  target_tags.1812159334:    "" => "mass"  
  target_tags.3235258666:    "" => "development"  
google_compute_firewall.development: Still creating... (10s elapsed)  
google_compute_firewall.development: Creation complete after 12s (ID: development)  
  
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.  
  
C:\Users\shino\doc\cicddemo>  
```  
  
GCPコンソールから確認  
ブラウザベースのSSHができない・・・  
IPソースレンジを開放してブラウザベースで接続してからnetstat  
```  
[shinonome128@development ~]$ netstat -na | grep ES  
tcp        0     64 10.30.0.2:22            173.194.93.35:54274     ESTABLISHED  
tcp        0      0 10.30.0.2:44238         169.254.169.254:80      ESTABLISHED  
tcp        0      0 10.30.0.2:44236         169.254.169.254:80      ESTABLISHED  
tcp        0      0 10.30.0.2:44240         169.254.169.254:80      ESTABLISHED  
[shinonome128@development ~]$  
```  
173.194.93.54 はGoogle LLC　これがルールに必要  
173.194.92.0/23 - GOOGLE  
```  
173.194.92.0/23  
```  
  
一度環境削除  
  
作成環境の削除前チェックと削除  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
再構築  
```  
terraform plan terraform  
terraform apply terraform  
```  
解消！！  
  
最後は壊す  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## サーバアプリケーションの展開  
  
再構築  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
インフラ構築完了したらGCPコンソール経由でサーバにログイン  
Gitでサーバアプリを展開  
```  
git clone https://github.com/yamamoto-febc/devops-example-server-skel devops-example-server  
cd devops-example-server  
cp example.php /var/www/html/  
```  
```  
[shinonome128@development ~]$ git clone https://github.com/yamamoto-febc/devops-example-server-skel devops-example-  
server  
-bash: git: command not found  
[shinonome128@development ~]$ sudo git  
sudo: git: command not found  
[shinonome128@development ~]$  
```  
なんと、Git が入っとらん。。  
  
Git をインストール  
```  
sudo yum install -y git  
```  
  
リトライ  
Gitでサーバアプリを展開  
```  
git clone https://github.com/yamamoto-febc/devops-example-server-skel devops-example-server  
cd devops-example-server  
sudo cp example.php /var/www/html/  
```  
  
アクセステスト  
```  
curl http://10.30.0.2/example.php  
curl http://35.221.101.2/example.php  
```  
グローバルからアクセスできない、多分フィルタに引っかかっている  
自宅グローバルで再度テストすること  
  
スタートスクリプトにGit インストールを追加  
```  
yum install -y git  
```  
  
リトライ  
再構築  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
アプリ展開  
```  
git clone https://github.com/yamamoto-febc/devops-example-server-skel devops-example-server  
cd devops-example-server  
sudo cp example.php /var/www/html/  
```  
  
サーバローカルのアクセステスト  
```  
curl http://10.30.0.2/example.php  
curl http://localhost/example.php  
```  
  
最後は壊す  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## クライアントアプリの修正  
  
クライアント起動  
```  
npm install && npm start  
```  
  
クライアントアプリの修正  
```  
const hostname = '<サーバのグローバルIPアドレス>'  
const remote = require('electron').remote  
  
document.querySelector('#btn').addEventListener('click', getData);  
  
function getData() {  
    const net = remote.net;  
    const request = net.request({  
        method: 'GET',  
        protocol: 'http:',  
        hostname: hostname,  
        port: 80,  
        path: '/example.php'  
    })  
  
    request.on('response', (response) => {  
        document.querySelector('#result').innerHTML  = ""  
        response.on('data', (chunk) => {  
            document.querySelector('#result').innerHTML += chunk  
        })  
    })  
    request.on('error', (err) => {  
        document.querySelector('#result').innerHTML = `ERROR: ${JSON.stringify(err)}`  
    })  
    request.end()  
}  
```  
```  
35.221.101.2  
```  
ユーザ名が無くて、コミットできない  
そもそも、他のリポジトリからクローンしたものが管理対象になているので、一度ローカルでリポジトリを作り直す  
```  
cd C:\Users\shino\doc\cicddemo  
rmdir /q /s devops-example-client  
git commit -a -m "Delete devops"  
git push  
```  
  
クローンしてコピー  
```  
git clone https://github.com/yamamoto-febc/devops-example-client-skel devops-example-client  
```  
  
非管理対象を追記  
```  
node_modules  
.swp  
```  
  
不要ファイルを削除  
```  
cd devops-example-client  
rmdir /q /s .git  
```  
  
ステージングとコミット、プル  
```  
cd C:\Users\shino\doc\cicddemo  
git add devops-example-client/  
git commit -a -m "Add devops-example-client"  
git push  
```  
  
クライアント起動  
```  
npm install && npm start  
```  
  
npmでのモジュールがGitで管理されていない事の確認  
```  
git staus  
```  
OK、これで何とかできそだね  
  
クライアントアプリの修正  
renderer.js  
```  
const hostname = '<サーバのグローバルIPアドレス>'  
const remote = require('electron').remote  
  
document.querySelector('#btn').addEventListener('click', getData);  
  
function getData() {  
    const net = remote.net;  
    const request = net.request({  
        method: 'GET',  
        protocol: 'http:',  
        hostname: hostname,  
        port: 80,  
        path: '/example.php'  
    })  
  
    request.on('response', (response) => {  
        document.querySelector('#result').innerHTML  = ""  
        response.on('data', (chunk) => {  
            document.querySelector('#result').innerHTML += chunk  
        })  
    })  
    request.on('error', (err) => {  
        document.querySelector('#result').innerHTML = `ERROR: ${JSON.stringify(err)}`  
    })  
    request.end()  
}  
```  
```  
35.221.101.2  
```  
  
  
ファイヤウォールルールにモバイルグローバルIPを追加してアクセステスト  
gcp_firewall.tf  
```  
49.239.66.40  
```  
```  
  source_ranges = ["116.220.197.54/32", "173.194.92.0/23", "49.239.66.40/32"]  
```  
  
アクセステスト  
再構築  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
アプリ展開  
```  
git clone https://github.com/yamamoto-febc/devops-example-server-skel devops-example-server  
cd devops-example-server  
sudo cp example.php /var/www/html/  
```  
SSHアクセスができても、スタートスクリプトが完了していないとgitコマンドでエラーがでる  
1分ぐらいかかる・・・・  
  
サーバローカルのアクセステスト  
```  
curl http://10.30.0.2/example.php  
curl http://localhost/example.php  
```  
  
なんと、グローバルIP、エフェメラルIPが構築のたびにちがう・・・  
クライアントアプリを修正  
```  
35.189.130.250  
```  
  
クライアントアプリのアクセステスト  
```  
cd devops-example-client  
npm install && npm start  
```  
OK、モーマンタイ！！  
  
最後は壊す  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## TravisCIでデプロイの自動化  
  
NOSグローバルIPをfirewall rule に追加  
```  
126.112.246.62  
```  
  
再構築  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
アプリ展開  
```  
git clone https://github.com/yamamoto-febc/devops-example-server-skel devops-example-server  
cd devops-example-server  
sudo cp example.php /var/www/html/  
```  
  
手動でGitHub上から管理変更用のサーバアプリのリポジトリ作成  
```  
devops-example-server  
```  
  
サーバアプリ用のGitリポジトリを作成  
```  
git remote add origin https://github.com/shinonome128/devops-example-server.git  
git push -u origin master  
```  
  
TravisCIの管理画面からこのリポジトリとの連携をONに設定  
GUI上から設定  
  
サーバアプリのルートディレクトリにtravis ci の設定ファイル作成  
```  
cd devops-example-server  
vi .travis.yml  
```  
```  
language: php  
script:  
- echo "Start CI"  
deploy:  
  provider: script  
  script:  
  - bash deploy.sh  
  skip_cleanup: true  
  on:  
    branch: master  
```  
  
ディプロイ用シェルを作成  
```  
cd devops-example-server  
vi deploy.sh  
```  
```  
#!/bin/sh  
  
chmod 0600 id_rsa  
scp -q -o "StrictHostKeyChecking no" -i id_rsa example.php root@$REMOTE_HOST:/var/www/html/  
```  
  
travis インストール  
```  
sudo yum install -y ruby  
sudo gem install travis -v 1.8.8 --no-rdoc --no-ri  
```  
```  
Results logged to /usr/local/share/gems/gems/ffi-1.9.25/ext/ffi_c/gem_make.out  
[shinonome128@development devops-example-server]$ sudo gem install travis  
Building native extensions.  This could take a while...  
ERROR: Error installing travis:  
ERROR: Failed to build gem native extension.  
    /usr/bin/ruby extconf.rb  
mkmf.rb can't find header files for ruby at /usr/share/include/ruby.h  
Gem files will remain installed in /usr/local/share/gems/gems/ffi-1.9.25 for inspection.  
Results logged to /usr/local/share/gems/gems/ffi-1.9.25/ext/ffi_c/gem_make.out  
```  
gem コマンドでインストールがコケル  
  
gem をアップデート  
```  
sudo gem update --system  
```  
  
リトライ  
```  
sudo gem install travis -v 1.8.8 --no-rdoc --no-ri  
```  
だめ・・・  
  
方針  
エラーメッセージとtravis で調査  
gem アップデートしてからインストール  
apt-get が使えるOSにする(Debian にする)  
  
エラーメッセージとtravis で調査  
Ruby 環境が整理されていないらしい・・・  
Fedra の場合は下記になるらしい  
```  
$ sudo yum install ruby ruby-devel  
```  
  
  
再構築  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
アプリ展開  
```  
git clone https://github.com/shinonome128/devops-example-server.git  
cd devops-example-server  
sudo cp example.php /var/www/html/  
```  
  
ruby と travis ci インスト  
```  
sudo yum install -y ruby ruby-devel  
sudo gem install travis  
```  
```  
[shinonome128@development ~]$ sudo gem install travis  
Building native extensions.  This could take a while...  
ERROR:  Error installing travis:  
        ERROR: Failed to build gem native extension.  
    /usr/bin/ruby extconf.rb  
Could not create Makefile due to some reason, probably lack of necessary  
libraries and/or headers.  Check the mkmf.log file for more details.  You may  
need configuration options.  
Provided configuration options:  
        --with-opt-dir  
        --without-opt-dir  
        --with-opt-include  
        --without-opt-include=${opt-dir}/include  
        --with-opt-lib  
        --without-opt-lib=${opt-dir}/lib64  
        --with-make-prog  
        --without-make-prog  
        --srcdir=.  
        --curdir  
        --ruby=/usr/bin/ruby  
        --with-ffi_c-dir  
        --without-ffi_c-dir  
        --with-ffi_c-include  
        --without-ffi_c-include=${ffi_c-dir}/include  
        --with-ffi_c-lib  
        --without-ffi_c-lib=${ffi_c-dir}/  
        --with-libffi-config  
        --without-libffi-config  
        --with-pkg-config  
        --without-pkg-config  
/usr/share/ruby/mkmf.rb:434:in `try_do': The compiler failed to generate an executable file. (RuntimeError)  
You have to install development tools first.  
        from /usr/share/ruby/mkmf.rb:565:in `try_cpp'  
        from /usr/share/ruby/mkmf.rb:1038:in `block in have_header'  
        from /usr/share/ruby/mkmf.rb:889:in `block in checking_for'  
        from /usr/share/ruby/mkmf.rb:340:in `block (2 levels) in postpone'  
        from /usr/share/ruby/mkmf.rb:310:in `open'  
        from /usr/share/ruby/mkmf.rb:340:in `block in postpone'  
        from /usr/share/ruby/mkmf.rb:310:in `open'  
        from /usr/share/ruby/mkmf.rb:336:in `postpone'  
        from /usr/share/ruby/mkmf.rb:888:in `checking_for'  
        from /usr/share/ruby/mkmf.rb:1037:in `have_header'  
        from extconf.rb:16:in `<main>'  
Gem files will remain installed in /usr/local/share/gems/gems/ffi-1.9.25 for inspection.  
Results logged to /usr/local/share/gems/gems/ffi-1.9.25/ext/ffi_c/gem_make.out  
[shinonome128@development ~]$  
```  
開発ツールを先に入れろとな・・・  
Ruby のコードが出ないとつらそうなので、方針展開  
  
  
作成環境の削除前チェックと削除  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## apt-get が使えるOSにする(Debian にする)  
  
やること  
教則本でどのOSを使っているか再度確認  
tfファイルの修正  
OS変更  
インフラ再構築  
コマンドを拾う手動  
スタートスクリプトで yum を使っているので修正  
アプリケーション配置を追加  
apt-get で travis cle をインストしてテスト  
破棄  
自動構築して再テスト  
  
教則本でどのOSを使っているか再度確認  
```  
  os_type            = "centos"  
```  
  
あれ、Centos？？ apt-get は使ってる？  
つかってない、yum で apache 入れてる。。  
  
OS変更  
tfファイルの修正  
debian は、、、GCP REST から取得  
```  
 "sourceImage": "projects/debian-cloud/global/images/debian-9-stretch-v20180911",  
```  
スタートスクリプト部分をコメントアウト、多分、 yum ないから。。  
  
インフラ再構築  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
コマンドを拾う手動  
スタートスクリプトで yum を使っているので修正  
yumの場合  
```  
yum update -y  
yum install -y httpd php  
systemctl enable httpd.service  
systemctl start httpd.service  
firewall-cmd --add-service=http --permanent  
firewall-cmd --reload  
yum install -y git  
```  
```  
sudo apt-get update -y  
sudo apt-get install -y apache2  
sudo apt-get install -y php  
sudo systemctl apache2 restart  
sudo apt-get install -y git  
```  
  
アプリケーション配置を追加  
```  
git clone https://github.com/shinonome128/devops-example-server.git  
cd devops-example-server  
sudo cp example.php /var/www/html/  
```  
  
apt-get で travis cle をインストしてテスト  
```  
sudo apt-get install -y ruby ruby-dev  
sudo apt-get install -y gcc  
sudo apt-get install -y libffi-dev  
sudo apt-get install -y make  
sudo gem install travis  
```  
  
travis の動作確認  
```  
travis version  
```  
```  
shinonome128@development:~/devops-example-server$ travis version  
1.8.9  
```  
うごいたー！  
  
  
破棄  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
スタートシェルの修正  
完了  
  
自動構築して再テスト  
```  
terraform plan terraform  
terraform apply terraform  
```  
```  
shinonome128@development:~$ ls -l /  
drwxr-xr-x  3 root root  4096 Oct  4 04:08 devops-example-server  
```  
Git クローンがルート直下に作成されている  
コンソールログ見ると、スタートアップスクリプト完了後に、ユーザアカントが作られているのが原因  
サーバ、travis cli 動作に問題なさそうなので対処しない  
  
破棄  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## travis cli セットアップ  
  
ローカルサーバアプリのGit管理をクローンして初期セットアップ  
```  
mkdir C:\Users\shino\doc\devops-example-server  
cd C:\Users\shino\doc\devops-example-server  
git clone https://github.com/shinonome128/devops-example-server.git C:\Users\shino\doc\devops-example-server  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
echo *.swp >> .gitignore  
git add *  
git commit -m "Add ignore""  
git push  
```  
  
travis.cli 設定ファイルを作成  
```  
cd C:\Users\shino\doc\devops-example-server  
echo hoge >> .travis.yml  
```  
```  
language: php  
script:  
- echo "Start CI"  
deploy:  
  provider: script  
  script:  
  - bash deploy.sh  
  skip_cleanup: true  
  on:  
    branch: master  
```  
  
ディプロイ用スクリプトを作成  
```  
cd C:\Users\shino\doc\devops-example-server  
echo hoge >> deploy.sh  
```  
```  
#!/bin/sh  
  
chmod 0600 id_rsa  
scp -q -o "StrictHostKeyChecking no" -i id_rsa *.php root@$REMOTE_HOST:/var/www/html/  
```  
  
自動構築して再テスト  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
travis ci にログイン  
```  
cd /devops-example-server  
travis login  
```  
```  
shinonome128@development:/devops-example-server$ travis login  
We need your GitHub login to identify you.  
This information will not be sent to Travis CI, only to api.github.com.  
The password will not be displayed.  
Try running with --github-token or --auto if you don't want to enter your password anyway.  
Username: shinonome128@gmail.com  
Successfully logged in as shinonome128!  
shinonome128@development:/devops-example-server$  
```  
GitHub のクレデンシャルを求められるので入力  
  
ディプロイしたあとグローバルIPを暗号化  
```  
sudo travis encrypt REMOTE_HOST=35.200.69.130 -a  
```  
  
暗号化した値を yml に保存  
```  
sudo travis encrypt-file hoge.secret -w id_rsa -a  
```  
あー、だめだ、秘密鍵を指定する必要があるみたい  
  
  
破棄  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
tf ファイルを編集してディプロイ時に秘密鍵が生成されるようにする  
サンプル、これをGCPで利用できるようにリバイズする  
まずはそのままで・・・・  
```  
resource "null_resource" "store_private_key" {  
  triggers {  
    ssh_key_id = "${module.server.ssh_key_id}"  
  }  
  provisioner "local-exec" {  
    command = "echo '${module.server.ssh_private_key}' > ${path.root}/id_rsa ; chmod 0600 ${path.root}/id_rsa"  
  }  
  provisioner "local-exec" {  
    when    = "destroy"  
    command = "rm -f ${path.root}/id_rsa"  
  }  
}  
  
output ipaddress {  
  value = "${module.server.server_ipaddress}"  
}  
  
output ssh_private_key {  
  value = "${module.server.ssh_private_key}"  
}  
```  
  
文法チェック  
```  
terraform plan terraform  
```  
```  
C:\Users\shino\doc\cicddemo>terraform plan terraform  
Error: output 'ipaddress': unknown module referenced: server  
Error: resource 'null_resource.store_private_key' provisioner local-exec (#1): unknown module referenced: server  
Error: resource 'null_resource.store_private_key' config: unknown module referenced: server  
Error: output 'ssh_private_key': unknown module referenced: server  
Error: resource 'null_resource.store_private_key' config: reference to undefined module "server"  
Error: output 'ipaddress': reference to undefined module "server"  
Error: resource 'null_resource.store_private_key' provisioner local-exec (#1): reference to undefined module "server"  
Error: output 'ssh_private_key': reference to undefined module "server"  
```  
うん、だよね・・・・、  
  
方針  
コマンドラインで生成し、スタートスクリプトに反映する  
GCP用のSSH用鍵生成まで準備されたtfファイルを探す  
  
## コマンドラインで生成し、スタートスクリプトに反映する  
  
インフラ構築  
```  
terraform apply terraform  
```  
  
キーペア作成(-C [USERNAME]を付けるとGCP側で自動でユーザーを追加してくれる)  
パスフレーズは無し  
```  
ssh-keygen -t rsa -f ~/.ssh/my-ssh-key -C shinonome128  
```  
  
権限を設定  
```  
chmod 400 ~/.ssh/my-ssh-key  
```  
  
公開鍵を表示  
コピーしておく  
```  
cat ~/.ssh/my-ssh-key.pub  
```  
  
秘密鍵を表示  
コピーしておく  
  
GCPメタデータ設定を実施  
メタデータで公開鍵を削除するとアクセスできなくなる、ここを自動化する必要がある  
ブラウザ側でSSH鍵認証の設定  
左ペインのメタデータをクリック  
表示された画面でSSH認証鍵タブを選択  
SSH鍵認証の追加  
切り替わった画面で公開鍵をコピペ  
  
ローカルに作成  
秘密鍵を張り付け  
```  
cd C:\Users\shino\Desktop  
echo hoge >> identity  
```  
  
GUIでTeraterm側でSSH鍵認証の設定  
```  
35.200.69.130  
```  
```  
shinonome128  
```  
```  
C:\Users\shino\Desktop\identity  
```  
  
teraterm で接続、問題なし  
  
破棄  
```  
terraform destroy terraform  
```  
  
## GCP用のSSH用鍵生成まで準備されたtfファイルを探す  
  
やること  
GCP上であらかじめ秘密鍵と公開鍵を作成  
秘密鍵ファイルはGitHub管理しないようにする  
公開鍵ファイルもGitHub管理しないようにする  
公開鍵をインつタンス作成のtfに絶対パスで指定  
```  
  metadata {  
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"  
  }  
```  
  
## GCP上であらかじめ秘密鍵と公開鍵を作成  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
インスタンス上で鍵作成  
```  
ssh-keygen -t rsa -f ~/.ssh/identity -C shinonome128  
```  
  
公開鍵を表示  
出力をコピー  
```  
cat ~/.ssh/identity.pub  
```  
  
秘密鍵を表示  
出力をコピー  
```  
cat ~/.ssh/identity  
```  
  
ローカルで公開鍵を作成  
ファイルを開いてコピーした内容を張り付け  
```  
cd C:\Users\shino\doc\cicddemo  
echo hoge >> identity.pub  
```  
  
ローカルで秘密鍵を作成  
ファイルを開いてコピーした内容を張り付け  
```  
cd C:\Users\shino\doc\cicddemo  
echo hoge >> identity  
```  
  
ディストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## 秘密鍵ファイルはGitHub管理しないようにする  
  
ignore に下記を追記  
```  
cd C:\Users\shino\doc\cicddemo  
echo identity>>.gitignore  
```  
  
## 公開鍵ファイルもGitHub管理しないようにする  
  
ignore に下記を追記  
```  
cd C:\Users\shino\doc\cicddemo  
echo identity.pub>>.gitignore  
```  
  
## 公開鍵をインつタンス作成のtfに絶対パスで指定  
  
インタンス作成のtfファイルににユーザ名と公開鍵ファイル絶対パス指定  
```  
sshKeys = "shinonome128:${file(C:\Users\shino\doc\cicddemo\identity.pub)}"  
```  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
```  
C:\Users\shino\doc\cicddemo>terraform plan terraform  
Error: Error parsing terraform\gcp_instances.tf: At 69:64: illegal char escape  
```  
文法エラーが出てる  
JSONファイル指定時の方法と比較  
サンプルコードとの比較  
  
  
JSONファイル指定時の方法と比較  
```  
    sshKeys = "shinonome128:${file(C:\Users\shino\doc\cicddemo\identity.pub)}"  
```  
```  
  credentials = "${file("C:/Users/shino/doc/cicddemo/cicd-demo-707b32bf1a7f.json")}"  
```  
ああ、パスはUnix 表記でないと読み込まないらしい。。  
修正完了  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
```  
Error: Error loading terraform\gcp_instances.tf: Error reading config for google_compute_instance[development]: parse error at 1:22: expected ")" but found ":"  
```  
あー、ファイル名ダブルクゥートでかこまなくちゃね。。  
修正完了  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
teraterm で接続確認  
35.200.23.217  
shinonome128  
identity  
問題なし、初期構築で秘密鍵の登録ができてアクセスも完了  
  
公開鍵が .ssh フォルダに登録されていることを確認  
```  
ls -la .ssh/  
```  
```  
shinonome128@development:~$ ls -la .ssh/  
total 12  
drwx------ 2 shinonome128 shinonome128 4096 Oct 15 10:03 .  
drwxr-xr-x 3 shinonome128 shinonome128 4096 Oct 15 10:07 ..  
-rw------- 1 shinonome128 shinonome128  412 Oct 15 10:03 authorized_keys  
```  
この authorized_keys の中身を開くと、terraform 経由でメタデータに設定されてたSSH公開鍵と同じになる  
  
デストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## インストール後のTravis CIの設定  
  
サーバアプリの .gitignore ファイルに秘密鍵と公開鍵を追加する  
```  
cd C:\Users\shino\doc\devops-example-server  
echo identity>>.gitignore  
echo identity.pub>>.gitignore  
```  
  
ここから再開予定  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
Travis CIログイン  
```  
travis login  
```  
  
グローバルIPを暗号化して travis.yml に落とす  
ディプロイが終わった後、GCPコンソールから拾う  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.221.110.3 -a  
```  
```  
shinonome128@development:/devops-example-server$ travis encrypt REMOTE_HOST=35.221.110.3 -a  
Detected repository as shinonome128/devops-example-server, is this correct? |yes| yes  
error: could not lock config file .git/config: Permission denied  
Permission denied @ rb_sysopen - /devops-example-server/.travis.yml  
for a full error report, run travis report --org  
```  
アクセス権限がない  
  
devops-exaple-server ディレクトリへのアクセス権限を追加  
```  
sudo chmod 777 /devops-example-server  
```  
  
リトライ  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.221.110.3 -a  
```  
```  
shinonome128@development:/devops-example-server$ travis encrypt REMOTE_HOST=35.221.110.3 -a  
Detected repository as shinonome128/devops-example-server, is this correct? |yes| yes  
error: could not lock config file .git/config: Permission denied  
Permission denied @ rb_sysopen - /devops-example-server/.travis.yml  
for a full error report, run travis report --org  
```  
あれ？？再帰的にパーミッションを変更する必要がある？  
  
devops-exaple-server ディレクトリへのアクセス権限を再帰的に追加  
```  
sudo chmod 777 -R /devops-example-server  
```  
  
リトライ  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.221.110.3 -a  
```  
```  
shinonome128@development:/devops-example-server$ cat .travis.yml  
language: php  
script:  
- echo "Start CI"  
deploy:  
  provider: script  
  script:  
  - bash deploy.sh  
  skip_cleanup: true  
  on:  
    branch: master  
env:  
  global:  
    secure: SW3PB1PIpfnrpWpGO2vrtZgZQ+Be24bW7qOFSxjhN9Tn/mjfNn4wSz/mNDI2bjTSOO8lqMDlJEeIZ4muWTki/JVVXOTbgFWvRRH7zFdPqYYwxKWVhad43QQh0VDcDnIjvZqHrcr+t/gwDC7nH3BSqm0KhobO77+Xx2FDMwvQEYLNN0GLAfTsbTMMrw1OOc/RmK4R4nN2dUtOliP0rrzx0iLgfhmFK  
X5p4D6XJhYs0s2sATiMvL+ot27MqK6tiLvYPhlTPaLFCorjE0Sp9NBODJhsuz0yEnPIw0vCoPy6N8x2jLCkSKoKVvChvJK+jHsyqFhJW4z2M1OQWZnqyi6+Hh3FAv22HP7gEeCdoE5m4t6wbIgAw1PcazBMvbh+oZsbWYkdthzqm5R5wWv7QKo1nXxa83pnSLgAgSs2W/eaDgHPUBDIsH7W6LEH5ldy3BWBtKaN03  
yuU4PSHR32Bov52Tz3/AsSZ6CydeDDYPFw+LH06weZ/dOca7nQy3Ra+hwQyIw8eLHAUoj9i1BztvRlXeSM0kCsLesY1zo2QJyj8yn0kqdCakM1YNhcuaXuhM/t0TwMvdRzjiMEw8GnZ8MCNEBvVElU6Ay8diod3lBmdx17emVTFyJmyPtPL0/2gMXv2JMAs7VwsPlL+qoEtenvHjteoPOVdUVNYdvPMWxiFNY=  
shinonome128@development:/devops-example-server$  
```  
IPアドレスが暗号化された global 変数が追加される  
  
ブラウザ経由SCPでローカルから秘密鍵をサーバにアップロードする  
  
秘密鍵を travis.yml に落とす  
```  
cd /devops-example-server/  
travis encrypt-file ~/identity -w id_rsa -a  
```  
```  
shinonome128@development:/devops-example-server$ travis encrypt-file ~/identity -w id_rsa -a  
encrypting /home/shinonome128/identity for shinonome128/devops-example-server  
storing result as identity.enc  
storing secure env variables for decryption  
Make sure to add identity.enc to the git repository.  
Make sure not to add /home/shinonome128/identity to the git repository.  
Commit all changes to your .travis.yml.  
```  
identity.enc と .travis.yml をレポジトリにコミットするように指示される  
  
  
identity.enc , .travis.yml をレポジトリにコミット、プッシュ  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
## 手順整理と問題点整理  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
devops-exaple-server ディレクトリへのアクセス権限を再帰的に追加  
ここは自動化できる  
```  
sudo chmod 777 -R /devops-example-server  
```  
  
travis ci にログイン  
ここがコード管理できない  
```  
cd /devops-example-server  
travis login  
```  
  
グローバルIPを暗号化して travis.yml に落とす  
ここがコード管理できない  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.221.110.3 -a  
```  
  
ブラウザ経由SCPでローカルから秘密鍵をサーバにアップロードする  
ここがコード管理できない  
初回のみ、travis.yml と identity.enc が生成されれば二回目以降は不要  
  
秘密鍵を travis.yml に落とす  
初回のみ、travis.yml と identity.enc が生成されれば二回目以降は不要  
```  
cd /devops-example-server/  
travis encrypt-file ~/identity -w id_rsa -a  
```  
  
identity.enc , .travis.yml をレポジトリにコミット、プッシュ  
ここがコード管理できない  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
デストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
ディプロイ自動化の問題点  
travis で ログインするときに、GitHubのクレデンシャルが必要  
travis で グローバルIP を .travis.yml に落とし、コミット、プッシュする必要がある  
travis 設定後、GitHubにプッシュする時にGitHub のクレデンシャルが必要  
  
対策  
いいや、今回は無視、イシューに登録して拡張してゆく  
  
  
## スタートスクリプトの修正  
  
サーバアプリインスト後の権限変更  
完了  
  
## コード変更をリアルタイムでディプロイする  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
travis ci にログイン  
```  
cd /devops-example-server  
travis login  
```  
  
グローバルIPを暗号化して travis.yml に落とす  
IPが変わる場合は、env 部分を一度全削除  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.200.5.159 -a  
```  
  
identity.enc , .travis.yml をレポジトリにコミット、プッシュ  
ここがコード管理できない  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
ローカルでサーバアプリのコード変更 、コミット、プッシュ  
example.php  
```  
      'msg' => "Updated"  // この行を追加  
```  
  
クライアントアプリのグローバルIP変更  
render.js  
```  
const hostname = '35.200.5.159'  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
だめ、メッセージが変わっていない、  
多分、Travis CI からのSSHアクセスが失敗してるんだと思われる、Git の Webhook ログを確認する  
  
  
GitHub Webhook ログ  
とくなし、とゆーか、正直よくわからん  
  
Travis CI ログ  
```  
Deploying application  
deploy.sh: line 2: $'\r': command not found  
chmod: cannot access ‘id_rsa\r’: No such file or directory  
lost connection  
Script failed with status 1  
```  
あー、deploy.sh が正しく動作していない  
  
コマンド内の秘密鍵ファイル名を修正  
id_rsa を identity にする  
```  
Deploying application  
deploy.sh: line 2: $'\r': command not found  
chmod: cannot access ‘identity\r’: No such file or directory  
Warning: Identity file identity not accessible: No such file or directory.  
lost connection  
Script failed with status 1  
failed to deploy  
```  
やっぱりだめ。。  
  
きちんと秘密鍵を配置してみる  
ブラウザ経由SCPでローカルから秘密鍵をサーバにアップロードする  
ここがコード管理できない  
初回のみ、travis.yml と identity.enc が生成されれば二回目以降は不要  
  
秘密鍵を travis.yml に落とす  
初回のみ、travis.yml と identity.enc が生成されれば二回目以降は不要  
```  
cd /devops-example-server/  
mv ~/identity /devops-example-server/  
travis encrypt-file ~/identity -w identity -a  
```  
  
deploy.sh が動作しているので、単純に最新の example.php を置き換えるようにしてみる  
全然わからん、一度解体してもう一度積み上げる  
  
  
デストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## アプリケーション変更時のディプロイ管理、リトライ  
  
サーバアプリで不要なアプリファイルを削除し、push  
完了  
  
サーバアプリを綺麗な状態にする  
完了  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
サーバアプリをGitにプッシュ  
terraform で構築するので省略可能  
  
サーバアプリのディレクトリに .travis.yml を作成  
初期設定で完了  
  
ディプロイ用スクリプト deploy.sh を作成  
masterブランチの変更を検知すると、scpコマンドを用いて拡張子が.phpのファイルをサーバにアップロード  
この動作を変更する  
今回は、CI サーバと Webサーバが同一なので、Git でレポジトリを取得を取得後、php ファイルを Web サーバのディレクトリに移動  
  
scp時に利用する宛先グローバルIPアドレスや秘密鍵の指定  
scpしないので不要  
  
TravisCIのCLIをインストール  
terraformに組み込んだので対応不要  
  
travis ログイン  
```  
cd /devops-example-server  
travis login  
```  
  
宛先グローバルIPアドレスを暗号化  
.travis.ymlファイルに暗号化した内容が追記され環境変数として参照可能  
不要  
  
秘密鍵を暗号化  
.travis.ymlファイルのポインタと暗号化されたファイルとして利用可能  
秘密鍵はファイルのまま扱いたいのでencrypt_fileサブコマンドを利用  
不要  
  
.travis.ymlファイルをコミットし、GitHubへpush  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
クライアントアプリのグローバルIP変更  
render.js  
```  
const hostname = '35.200.5.159'  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
  
ローカルでPullしてから、サーバアプリのexample.phpのコード変更 、コミット、プッシュ  
example.php  
```  
      'msg' => "Updated"  // この行を追加  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
変化なし、、、  
Travis CI のログを参照する  
  
デストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
Travis CI のログを参照する  
```  
Deploying application  
cp: cannot create regular file ‘/var/www/html/’: No such file or directory  
Script failed with status 1  
failed to deploy  
```  
deploy.sh で cp コマンドが失敗している  
  
一度、ディプロイしたら、シェル単体で動作するか確認する  
他に、サーバ上でコードを変更してみる  
  
## アプリケーション変更時のディプロイ管理、リトライ  
  
今回のリトライで切り分ける内容  
一度、ディプロイしたら、シェル単体で動作するか確認する  
他に、サーバ上でコードを変更してみる  
  
サーバアプリを綺麗な状態にする  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
一度、ディプロイしたら、シェル単体で動作するか確認する  
```  
cd /devops-example-server  
./deploy.sh  
```  
問題なく動作する  
  
travis ログイン  
```  
cd /devops-example-server  
travis login  
```  
  
.travis.ymlファイルをコミットし、GitHubへpush  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
クライアントアプリのグローバルIP変更  
render.js  
```  
const hostname = '35.200.5.159'  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
  
サーバアプリのexample.phpのコード変更 、コミット、プッシュ  
example.php  
```  
      'msg' => "Updated"  // この行を追加  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
やっぱり駄目だね  
  
デストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
Travis CIログ  
```  
Deploying application  
cp: cannot create regular file ‘/var/www/html/’: No such file or directory  
Script failed with status 1  
failed to deploy  
```  
アパッチのルートディレクトリが無いと言っている  
  
対策  
単体でdeploy.shが動作していることとログ内容からCI動作はTravisCI上のVMで実行されている  
もともとはSCP動作だったの Travis CI VM からのSCPが失敗していると思われる  
次回は秘密鍵、 SCP コマンドが成功するように作成する  
  
## アプリケーション変更時のディプロイ管理、リトライ  
  
ここから再開、やっぱり Travis CI VM上でCI動作が行われているのでその検証が必要  
  
やること  
単体でdeploy.shが動作していることとログ内容からCI動作はTravisCI上のVMで実行されている  
もともとはSCP動作だったの Travis CI VM からのSCPが失敗していると思われる  
deploy.sh で、秘密鍵、 SCP コマンドが成功するように作成する  
firewall のルールを一度解除する  
  
Travis CI 設定ファイルを綺麗にする  
対象ファイルは　.travis.yml  
  
firewall のルールを一度解除する  
全許可  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
travis ログイン  
```  
cd /devops-example-server  
travis login  
```  
  
ブラウザでサーバに秘密鍵をアップロードし、サーバアプリのルートディレクトリに移動  
```  
mv ~/identity /devops-example-server/  
```  
  
ディプロイ用スクリプト deploy.sh を修正  
masterブランチの変更を検知すると、scpコマンドを用いて拡張子が.phpのファイルをサーバにアップロード  
chmod は不要  
アクセス時のユーザアカントを変更  
これ、事前でOKだったかも  
  
宛先グローバルIPアドレスを暗号化  
.travis.ymlファイルに暗号化した内容が追記され環境変数として参照可能  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.221.80.249 -a  
```  
  
秘密鍵を暗号化  
.travis.ymlファイルのポインタと暗号化されたファイルとして利用可能  
秘密鍵はファイルのまま扱いたいのでencrypt_fileサブコマンドを利用  
```  
cd /devops-example-server/  
travis encrypt-file identity -w identity -a  
```  
  
.travis.ymlファイルをコミットし、GitHubへpush  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
クライアントアプリのグローバルIP変更  
render.js  
```  
const hostname = '35.200.5.159'  // ここの部分を変更する  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
  
ローカルでPullしてから、サーバアプリのexample.phpのコード変更 、コミット、プッシュ  
example.php  
```  
      'msg' => "Updated"  // この行を追加したり、コメントアウトしたりする  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
失敗  
  
デストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
Travis CI のログ  
```  
Deploying application  
lost connection  
Script failed with status 1  
```  
おそらく SCP が失敗している  
shinonome128 でログイン SCP をやっていて、 /var/www/html 配下に php ファイルを置こうとしている  
一度、deploy.sh のSCP のディレクトリ変更してみる  
次回ここから再開、これが上手くいけば、  
構築時に /var/www/html の権限変や、root 権限で鍵の作成を実行すればよい  
  
## アプリケーション変更時のディプロイ管理、リトライ  
  
shinonome128 でログイン SCP をやっていて、 /var/www/html 配下に php ファイルを置こうとしている  
一度、deploy.sh のSCP のディレクトリ変更してみる  
構築時に /var/www/html の権限変や、root 権限で鍵の作成を実行すればよい  
  
Terraform の instans 構築時に、スタートスクリプトで/var/www/html に権限を付与する  
```  
chmod 777 -R /var/www/html  
```  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
travis ログイン  
```  
cd /devops-example-server  
travis login  
```  
  
Travis CI 設定ファイルを綺麗にする  
対象ファイルは　.travis.yml  
  
宛先グローバルIPアドレスを暗号化  
.travis.ymlファイルに暗号化した内容が追記され環境変数として参照可能  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.200.36.65 -a  
```  
  
.travis.ymlファイルをコミットし、GitHubへpush  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
クライアントアプリのグローバルIP変更  
render.js  
```  
const hostname = '35.200.36.65'  // ここの部分を変更する  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
  
ローカルでPullしてから、サーバアプリのexample.phpのコード変更 、コミット、プッシュ  
example.php  
```  
      'msg' => "Updated"  // この行を追加したり、コメントアウトしたりする  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
かわらん・・・  
  
デストロイ  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
Trabis CI ログを確認  
```  
Deploying application  
lost connection  
Script failed with status 1  
```  
やっぱり失敗してる・・、いちど、SCPができるかどうかを確認する  
  
秘密鍵をアップロードしSCPができるか確認  
```  
mv ~/identity /devops-example-server/  
cd /devops-example-server/  
scp -q -o "StrictHostKeyChecking no" -i identity *.php shinonome128@35.200.36.65:/var/www/html/  
```  
```  
shinonome128@development:/devops-example-server$ scp -q -o "StrictHostKeyChecking no" -i identity *.php shinonome128@35.200.36.65:/var/www/html/  
lost connection  
```  
あー、同じエラーが出ているのでコマンドラインが間違っていると思われる  
  
エラーメッセージを検索、  
  
普通にSSHを実行  
```  
ssh -i identity shinonome128@35.200.36.65  
```  
```  
shinonome128@development:/devops-example-server$ ssh -i identity shinonome128@35.200.36.65  
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @  
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
Permissions 0644 for 'identity' are too open.  
It is required that your private key files are NOT accessible by others.  
This private key will be ignored.  
Load key "identity": bad permissions  
Permission denied (publickey).  
```  
chmod やれと怒られる  
  
chmod やって、 SSH 成功と SCP のロストコネクションが解消されるか確認  
```  
cd /devops-example-server/  
sudo chmod 0600 identity  
ssh -i identity shinonome128@35.200.36.65  
scp -q -o "StrictHostKeyChecking no" -i identity *.php shinonome128@35.200.36.65:/var/www/html/  
*.  
```  
解消した・・・・、まじかー  
  
結論  
deploy.sh で秘密鍵の権限変更をしないと、SCPが失敗する  
次回は deploy.sh にこれを盛り込んディプロイテストする  
  
## アプリケーション変更時のディプロイ管理、リトライ  
  
やること  
deploy.sh で秘密鍵の権限変更をしないと、SCPが失敗する  
次回は deploy.sh にこれを盛り込んディプロイテストする  
  
deploy.sh で SCP 前に権限変更するように修正  
完了  
  
Travis CI 設定ファイルを綺麗にする  
対象ファイルは　.travis.yml  これをロールバックする  
完了、ロールバックは使わなかった、次回、 test start までロールバックする  
  
ディプロイ  
```  
terraform plan terraform  
terraform apply terraform  
```  
  
travis ログイン  
```  
cd /devops-example-server  
travis login  
```  
  
宛先グローバルIPアドレスを暗号化  
.travis.ymlファイルに暗号化した内容が追記され環境変数として参照可能  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.200.27.47 -a  
```  
  
.travis.ymlファイルをコミットし、GitHubへpush  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
クライアントアプリのグローバルIP変更  
render.js  
```  
const hostname = '35.200.36.65'  // ここの部分を変更する  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
  
ローカルでPullしてから、サーバアプリのexample.phpのコード変更 、コミット、プッシュ  
example.php  
```  
      'msg' => "Updated"  // この行を追加したり、コメントアウトしたりする  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
あれー？うまくいとらん。。とりあえず Travis のログ見る  
Travis CI は成功してる、30秒以上かかるらしい・・・  
もう一度、クライアントアプリ起動する、あー、成功！！！  
  
デストロイ  
```  
cd C:\Users\shino\doc\cicddemo  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
  
## クライアントアプリーションのレポジトリを作り手順には反映する  
  
目的  
コード管理をなるべく簡単にする  
Git で分割したほうが再利用しやすい  
  
やること  
クライアントのディレクトリ作成、コピー  
GitHubレポジトリの作成  
レポジトリへの移動  
リードミーの編集  
  
クライアントのディレクトリ作成、コピー  
```  
mkdir C:\Users\shino\doc\devops-example-client  
copy C:\Users\shino\doc\cicddemo\devops-example-client\* C:\Users\shino\doc\devops-example-client\  
```  
  
GitHubレポジトリの作成  
```  
devops-example-client  
```  
  
レポジトリへ登録  
```  
cd C:\Users\shino\doc\devops-example-client  
git init  
git add .gitignore  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add first commit"  
git remote add origin https://github.com/shinonome128/devops-example-client.git  
git push -u origin master  
```  
  
Gitアクセステスト  
render.js  
適当に変更して GitHub に反映されることを確認  
```  
cd C:\Users\shino\doc\devops-example-client  
git add *  
git commit -m "Add codes"  
git push -u origin master  
```  
  
アプリケーション起動テスト  
```  
cd C:\Users\shino\doc\devops-example-client  
npm install && npm start  
```  
  
## クライアントアプリの整理  
  
移設先のアプリケーション起動テスト  
```  
cd C:\Users\shino\doc\devops-example-client  
npm install && npm start  
```  
  
cicd 配下のクライアントアプリを削除、動機  
```  
cd C:\Users\shino\doc\cicddemo  
rmdir /q /s devops-example-client  
git commit -a -m "Delete devops"  
git push  
```  
  
クライアントアプリのお手本と管理レポジトリを比較して不要ファイルを整理  
```  
node_modules  
```  
ないね、node_modules ディレクトリだけ追記すればよい  
  
非管理ファイルを .gitignore に登録  
```  
node_modules  
```  
もう、追加されてた  
  
不要ファイル一度削除してレポジトリと同期  
```  
cd C:\Users\shino\doc\devops-example-client  
git commit -a -m "Delete files"  
git push  
```  
  
アプリケーション起動テスト  
```  
cd C:\Users\shino\doc\devops-example-client  
npm install && npm start  
```  
  
## リードミーの編集  
  
目的  
参照先  
事前準備  
起動方法  
  
## メモ作成  
  
既存のREAD.md の名前の変更  
```  
cd C:\Users\shino\doc\cicddemo  
copy README.md memo.md  
git add *  
git commit -m "Add memo"  
git push  
```  
  
今後は memo.md を開いて編集してゆく  
  
## リードミー作成  
  
## イシュー作成  
  
firewall rule で Travis CI のグローバルアドレスで絞りたい  
Terraform のスタートスクリプトでサーバアプリをインストするとルートユーザになってしまう、shinonome128ユーザにしたい  
travis login 時の GitHub クレデンシャルの入力を求められるので自動化したい  
エフェメラル IP を .travis.yml に落とす時に GCP コンソールからアドレスを拾う作業を自動化したい  
.travis.yml を GibHub にプッシュする時に GitHub のクレデンシャルを求められるで自動化したい  
.travis.yml を使えば、環境変数、ファイルを暗号化した状態で使えそう  
  
以上  
