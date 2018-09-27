# cicddemo  
  
## 目的  
  
CICD環境の構築  
プロトタイピング  
全GCP上で作る  
  
## 参考  
  
ドキュメント・コード管理  
https://github.com/shinonome128/cicddemo  
  
山本和道さんの道場、ハンズオン形式でわかりやすい、全11回  
https://knowledge.sakura.ad.jp/author/kazumichi_yamamoto/  
  
第9回、CICDサンプルで流す  
https://knowledge.sakura.ad.jp/15425/  
  
GCPコンソール  
https://console.cloud.google.com/home/dashboard  
  
GCEスタートガイド  
https://cloud.google.com/compute/docs/?hl=ja  
  
Linux VM の使用に関するクイックスタート  
https://cloud.google.com/compute/docs/quickstart-linux?hl=ja  
  
Debian パッケージ管理  
http://q.hatena.ne.jp/1142714688  
  
Node.js と npm の使い方  
https://qiita.com/megane42/items/2ab6ffd866c3f2fda066  
  
Deb 9のリポジトリから、Node.jsにnpm がつかなくなった、代わりに8系のリポジトリを使う方法  
http://atomiyama.com/linux/page/debian-9-2-node-npm/  
  
node.js 本家  
https://nodejs.org/en/download/  
  
GCPインスタンスでDockerインスタンスが起動しない、自動的にプロセス起動させる方法  
https://forums.docker.com/t/failure-to-start-docker-on-an-amazon-linux-machine/44003/15  
  
docker が php 叩けない、selnux が邪魔するケース  
https://devops.stackexchange.com/questions/3083/apache-container-cant-access-php-files-mounted-in-var-www-403-error  
  
GCP、Terraform 連携  
https://gist.github.com/MisaKondo/cb46b0ecd106e9c824a641b14954b8e1  
  
Trraform本家、インストレーションガイド  
https://www.terraform.io/intro/getting-started/install.html  
  
GCP サービスアカント、クレデンシャルファイル作成方法  
https://www.magellanic-clouds.com/blocks/guide/create-gcp-service-account-key/  
  
Terraform本家、GCPインスタンスのtfファイルのテンプレ  
https://www.terraform.io/docs/providers/google/index.html  
  
Gitクライアントでリポジトリの向け先を変更する方法  
https://qiita.com/minoringo/items/917e325892733e0d606e  
  
terraform ステート管理をバージョンコントロールすべきかの議論  
https://stackoverflow.com/questions/38486335/should-i-commit-tfstate-files-to-git  
  
## やること  
  
最低限動くクライアント側アプリ開発  
ローカルでクライアントアプリ起動確認  
GCP上にインスタンスの立ち上げ  
サーバ側アプリケーションの開発〜配置  
サーバ側のデプロイの自動化  
  
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
  
## ローカルでクライアントアプリ起動確認  
  
ローカルPCで実行、npmパスが通っていないとダメ  
```  
z:  
cd work  
git clone https://github.com/yamamoto-febc/devops-example-client-skel devops-example-client  
cd devops-example-client  
npm install  
npm start  
```  
起動完了  
  
## GCPにインスタンスの立ち上げ  
  
プロジェクト作成  
```  
cicd-demo  
```  
  
インスタンスをGCPコンソールから作成、Centos 7 , 64bit 、起動  
```  
cat /proc/version  
cat /proc/cpuinfo  
cat /proc/meminfo  
df -h  
```  
  
## サーバ側アプリケーションの開発〜配置  
  
インスタンスで実行  
```  
sudo yum install git  
sudo yum install docker  
git clone https://github.com/yamamoto-febc/devops-example-server-skel devops-example-server  
cd devops-example-server  
docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
```  
```  
[shinonome128@instance-2 devops-example-server]$ docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
/usr/bin/docker-current: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?.  
See '/usr/bin/docker-current run --help'.  
```  
コンテナが起動しない、、なんでだろう・・・・  
  
エラーメッセージ調査  
権限がないので sudo してから実行する  
```  
sudo docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
```  
```  
[shinonome128@instance-2 devops-example-server]$ sudo docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
/usr/bin/docker-current: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?.  
See '/usr/bin/docker-current run --help'.  
```  
解消せず  
もうちょっとエラーメッセージの調査が必要そう  
だめなら、docker 単体起動の調査を開始する  
  
Check the status:  
```  
sudo service docker status  
```  
```  
[shinonome128@instance-2 ~]$ sudo service docker status  
Redirecting to /bin/systemctl status docker.service  
● docker.service - Docker Application Container Engine  
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)  
   Active: inactive (dead)  
     Docs: http://docs.docker.com  
```  
あー、プロセス死んでる・・・  
  
  
If there isn’t running:  
```  
sudo service docker start  
```  
```  
[shinonome128@instance-2 ~]$ sudo service docker status  
Redirecting to /bin/systemctl status docker.service  
● docker.service - Docker Application Container Engine  
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)  
   Active: active (running) since Thu 2018-09-13 13:17:57 UTC; 13s ago  
     Docs: http://docs.docker.com  
 Main PID: 2023 (dockerd-current)  
   CGroup: /system.slice/docker.service  
           ├─2023 /usr/bin/dockerd-current --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current --d...  
           └─2027 /usr/bin/docker-containerd-current -l unix:///var/run/docker/libcontainerd/docker-containerd.s...  
Sep 13 13:17:55 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:55.609187061Z" level=info msg="libc...027"  
Sep 13 13:17:56 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:56.730267340Z" level=info msg="Grap...nds"  
Sep 13 13:17:56 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:56.731530981Z" level=info msg="Load...rt."  
Sep 13 13:17:56 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:56.761865986Z" level=info msg="Fire...rue"  
Sep 13 13:17:56 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:56.940321129Z" level=info msg="Defa...ess"  
Sep 13 13:17:57 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:57.150492743Z" level=info msg="Load...ne."  
Sep 13 13:17:57 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:57.315683369Z" level=info msg="Daem...ion"  
Sep 13 13:17:57 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:57.316247424Z" level=info msg="Dock...13.1  
Sep 13 13:17:57 instance-2 systemd[1]: Started Docker Application Container Engine.  
Sep 13 13:17:57 instance-2 dockerd-current[2023]: time="2018-09-13T13:17:57.333527557Z" level=info msg="API ...ock"  
Hint: Some lines were ellipsized, use -l to show in full.  
```  
スタートできたね・・  
  
And then to auto-start after reboot:  
```  
sudo systemctl enable docker  
```  
```  
[shinonome128@instance-2 ~]$ sudo systemctl enable docker  
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.  
```  
次回再起動時のも有効になるようする  
  
再起動  
```  
sudo reboot  
```  
  
プロセスが動いているか確認  
```  
sudo service docker status  
```  
OK、解消  
  
リトライ  
```  
cd devops-example-server  
docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
```  
```  
[shinonome128@instance-2 devops-example-server]$ docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
/usr/bin/docker-current: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.26/containers/create: dial unix /var/run/docker.sock: connect: permission denied.  
See '/usr/bin/docker-current run --help'.  
```  
うーん、だめ？さっきと違う？？今度は権限がないので、sudo でやってみる  
  
リトライ  
```  
sudo docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
```  
```  
[shinonome128@instance-2 devops-example-server]$ cd devops-example-server  
-bash: cd: devops-example-server: No such file or directory  
[shinonome128@instance-2 devops-example-server]$  
[shinonome128@instance-2 devops-example-server]$ sudo docker run -it --rm -p 80:80 -v $PWD:/var/www/html php:7.0-ap  
ache  
Unable to find image 'php:7.0-apache' locally  
Trying to pull repository docker.io/library/php ...  
7.0-apache: Pulling from docker.io/library/php  
802b00ed6f79: Pull complete  
59f5a5a895f8: Pull complete  
6898b2dbcfeb: Pull complete  
8e0903aaa47e: Pull complete  
2961af1e196a: Pull complete  
71f7016f79a0: Pull complete  
5e1a48e5719c: Pull complete  
7ae5291984f3: Pull complete  
725b65166f31: Pull complete  
d45206e9f6b6: Pull complete  
d171671ace32: Pull complete  
2e580cc39a4d: Pull complete  
6a030f0f9c2b: Pull complete  
267967602263: Pull complete  
Digest: sha256:cfa493c6ddb463165872cb88828ad2b1041bad4cf895c1516aa030031cbcf338  
Status: Downloaded newer image for docker.io/php:7.0-apache  
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the  
'ServerName' directive globally to suppress this message  
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the  
'ServerName' directive globally to suppress this message  
[Thu Sep 13 13:32:21.361188 2018] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.25 (Debian) PHP/7.0.31 configure  
d -- resuming normal operations  
[Thu Sep 13 13:32:21.361251 2018] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'  
```  
お？起動したっぽい、けど、バックグランド実行ではないので、操作ができん・・・  
  
  
一度、殺して、バックグランド実行にする、-d をつける  
```  
sudo docker run -itd --rm -p 80:80 -v $PWD:/var/www/html php:7.0-apache  
```  
  
バックグランドの状態確認  
```  
sudo docker ps  
```  
```  
[shinonome128@instance-2 devops-example-server]$ sudo docker ps  
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS  
           NAMES  
f868bf569a38        php:7.0-apache      "docker-php-entryp..."   6 minutes ago       Up 6 minutes        0.0.0.0:80->80/tcp   boring_lichterman  
```  
OKっす、tcp 80 でまちうけてるね  
  
サービス確認  
```  
curl http://localhost/example.php  
```  
```  
[shinonome128@instance-2 ~]$ curl http://localhost/example.php  
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">  
<html><head>  
<title>403 Forbidden</title>  
</head><body>  
<h1>Forbidden</h1>  
<p>You don't have permission to access /example.php  
on this server.<br />  
</p>  
<hr>  
<address>Apache/2.4.25 (Debian) Server at localhost Port 80</address>  
</body></html>  
```  
だめだね、localhost がだめ？  
  
コンテナ名で実行  
```  
curl http://boring_lichterman/example.php  
```  
```  
[shinonome128@instance-2 ~]$ curl http://boring_lichterman/example.php  
curl: (6) Could not resolve host: boring_lichterman; Unknown error  
```  
関係なし・・・  
  
docker 起動時のアクセス制限調べる、localhostはだめらしい、環境変数でIPを調べる  
```  
ifconfig  
```  
```  
[shinonome128@instance-2 ~]$ ifconfig  
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500  
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0  
        inet6 fe80::42:3aff:fe26:3e3a  prefixlen 64  scopeid 0x20<link>  
        ether 02:42:3a:26:3e:3a  txqueuelen 0  (Ethernet)  
        RX packets 26  bytes 2472 (2.4 KiB)  
        RX errors 0  dropped 0  overruns 0  frame 0  
        TX packets 22  bytes 1708 (1.6 KiB)  
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0  
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1460  
        inet 10.142.0.2  netmask 255.255.255.255  broadcast 10.142.0.2  
        inet6 fe80::4001:aff:fe8e:2  prefixlen 64  scopeid 0x20<link>  
        ether 42:01:0a:8e:00:02  txqueuelen 1000  (Ethernet)  
        RX packets 6701  bytes 134735844 (128.4 MiB)  
        RX errors 0  dropped 0  overruns 0  frame 0  
        TX packets 4486  bytes 431149 (421.0 KiB)  
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0  
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536  
        inet 127.0.0.1  netmask 255.0.0.0  
        inet6 ::1  prefixlen 128  scopeid 0x10<host>  
        loop  txqueuelen 1000  (Local Loopback)  
        RX packets 32  bytes 3560 (3.4 KiB)  
        RX errors 0  dropped 0  overruns 0  frame 0  
        TX packets 32  bytes 3560 (3.4 KiB)  
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0  
veth83f836d: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500  
        inet6 fe80::84f5:5fff:fed1:6ec2  prefixlen 64  scopeid 0x20<link>  
        ether 86:f5:5f:d1:6e:c2  txqueuelen 0  (Ethernet)  
        RX packets 18  bytes 2188 (2.1 KiB)  
        RX errors 0  dropped 0  overruns 0  frame 0  
        TX packets 22  bytes 1708 (1.6 KiB)  
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0  
```  
172.17.0.1  
10.142.0.2  
127.0.0.1  
  
リトライ  
```  
curl http://localhost/example.php  
curl http://172.17.0.1/example.php  
curl http://10.142.0.2/example.php  
curl http://127.0.0.1/example.php  
```  
結果、全部同じ  
  
あー、わかた、公開ディレクトリが起動時に間違えている  
  
フルIDを取得  
```  
sudo docker ps --no-trunc  
```  
  
IDをして、詳細を確認  
```  
sudo docker inspect 57f4ca6b390ae16579125527fffb83724412d367ff857e686fe09c9128a2ff5c  
```  
```  
       "HostConfig": {  
            "Binds": [  
                "/home/shinonome128:/var/www/html"  
            ],  
```  
/home/shinonome128 が　/var/www/html になっている  
  
停止  
```  
sudo docker stop 57f4ca6b390ae16579125527fffb83724412d367ff857e686fe09c9128a2ff5c  
sudo docker ps -a  
```  
  
ディレクトリを移動して、起動  
```  
sudo docker run -itd --rm -p 80:80 -v /home/shinonome128/devops-example-server:/var/www/html php:7.0-apache  
```  
```  
curl http://localhost/example.php  
curl http://172.17.0.1/example.php  
curl http://10.142.0.2/example.php  
curl http://127.0.0.1/example.php  
```  
だめ・・・・  
  
SE Linux が邪魔するらしい・・・  
```  
sudo setenforce 0  
```  
```  
[shinonome128@instance-2 devops-example-server]$ curl http://localhost/example.php  
{"date":"2018-09-19T09:57:07+00:00"}[shinonome128@instance-2 devops-example-server]$  
```  
OK、成功  
  
## ドキュメント管理をGitに移す  
  
レポジトリ作成  
```  
echo # cdcidemo >> README.md  
echo # cdcidemo >> .gitignore.md  
git init  
git add *  
git config --global user.email shinonome128@gmail.com  
git config --global user.name "shinonome128"  
git commit -m "first commit"  
git remote add origin https://github.com/shinonome128/cdcidemo.git  
git push -u origin master  
```  
  
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
  
以上  
