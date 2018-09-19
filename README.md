# cdcidemo  
  
## 目的  
  
CICD環境の構築  
プロトタイピング  
全GCP上で作る  
  
## 参考  
  
ドキュメント・コード管理  
https://github.com/shinonome128/cdcidemo  
  
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
  
## サーバ側のデプロイの自動化  
  
ここから再開  
  
以上  
