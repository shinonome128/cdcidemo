  
# cicddemo  
  
## 目的  
  
CICD環境の構築と動作確認、プロトタイピング、全GCP上で作る  
  
以下の3点を実装  
インフラとサーバアプリ自動展開  
サーバアプリのコード変更を検知して自動展開  
インフラとサーバアプリ自動削除  
  
## 参考  
  
ドキュメントと Terraform 設定管理  
https://github.com/shinonome128/cicddemo  
  
クライアントアプリ  
https://github.com/shinonome128/devops-example-client  
  
サーバアプリと Travis CI 設定管理  
https://github.com/shinonome128/devops-example-server  
  
Travis CI サーバアプリのディプロイステータス確認  
https://travis-ci.org/shinonome128/devops-example-server  
  
Trraform本家、インストレーションガイド  
https://www.terraform.io/intro/getting-started/install.html  
  
## 手順  
  
ローカルで node.js / npm インスト  
クライアントアプリ準備と起動  
Terraformインスト  
Terraform 設定ファイル作成  
GCP クレデンシャルファイルの作成  
gcp_provider.tf 作成  
gcp_network.tf 作成  
gcp_firewall.tf 作成  
gcp_instances.tf 作成  
Terraform 初期セットアップ  
Terraform 設定ファイルチェック  
Terraform プラグインを Git 非管理  
Terraform の状態管理ファイルを Git 非管理  
Terraform でアプライ  
Terraform によるデストロイ  
GCP上であらかじめ秘密鍵と公開鍵を作成  
秘密鍵と公開鍵ファイルはGitHub管理しないようにする  
Travic CI の初期設定  
アプリケーション変更時のディプロイ管理  
  
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
Woxからコマンドプロンプトを呼び出す場合は、Evrything / Wox を再起動する  
```  
X:\Users\0002289\AppData\Local\Programs\Python\Python36\Scripts\;X:\Users\0002289\AppData\Local\Programs\Python\Python36\;C:\Program Files (x86)\Nmap;X:\Users\0002289\AppData\Roaming\npm;C:\Program Files\nodejs  
```  
  
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
git clone https://github.com/shinonome128/devops-example-client devops-example-client  
```  
  
アプリケーション起動テスト  
```  
cd C:\Users\shino\doc\devops-example-client  
npm install && npm start  
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
  
## Terraform 設定ファイル作成  
  
GCPコンソールからAPIとサービスを選択  
対象プｒジェクトを選択  
Compute Engine API を検索して有効化する  
  
terraform 設定フォルダ作成  
```  
cd C:\Users\shino\doc\cicddemo  
mkdir terraform  
```  
  
terraform 設定ファイルの作成  
tf ファイルの中身から書き始める  
```  
cd C:\Users\shino\doc\cicddemo\terraform  
echo # gcp_provider.tf>> gcp_provider.tf  
echo # gcp_network.tf>> gcp_network.tf  
echo # gcp_firewall.tf>> gcp_firewall.tf  
echo # gcp_instances.tf>> gcp_instances.tf  
```  
  
コミットとプッシュ  
強制プッシュ  
```  
git push -f  
```  
  
## GCP クレデンシャルファイルの作成  
  
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
```  
cd C:\Users\shino\doc\cicddemo  
echo *.json>> .gitignore  
```  
  
クレデンシャルキーを移動  
```  
move C:\Users\shino\Downloads\cicd-demo-707b32bf1a7f.json C:\Users\shino\doc\cicddemo  
```  
  
## gcp_provider.tf 作成  
  
コード参照  
  
## gcp_network.tf 作成  
  
コード参照  
  
## gcp_firewall.tf 作成  
  
コード参照  
  
## gcp_instances.tf 作成  
  
コード参照  
  
## Terraform 初期セットアップ  
  
初期セットアップコマンドを実行  
.terraform ディレクトリが作成されここにプラグインが管理される  
```  
cd C:\Users\shino\doc\cicddemo  
terraform init terraform  
```  
  
## Terraform 設定ファイルチェック  
  
プラン  
```  
cd C:\Users\shino\doc\cicddemo  
terraform plan terraform  
```  
  
## Terraform プラグインを Git 非管理  
  
.gitignore に追加  
```  
cd C:\Users\shino\doc\cicddemo  
echo .terraform/>>.gitignore  
```  
  
## Terraform の状態管理ファイルを Git 非管理  
  
tf ファイルで指定したディレクトリ名にドット付きのファイル名が生成される  
```  
2018/09/27  19:38    <DIR>          terraform  
2018/09/27  19:50               317 terraform.tfstate  
2018/09/27  19:48            11,846 terraform.tfstate.backup  
```  
  
複数人でリリース作業が重複する可能性がある場合は、外部ストレージにおいて、terraform からリモート参照させることで管理する  
多分、CICD環境作るときは、CIツールとterraformを動作させるので、そこでステートファイルを参照できるようにしておく  
秘匿性の高い情報が含まれるの公開バージョン管理はしない  
なので.gitignore に追記しておく  
```  
cd C:\Users\shino\doc\cicddemo  
echo *.tfstate>> .gitignore  
echo *.tfstate.backup>> .gitignore  
```  
  
## Terraform でアプライ  
  
環境構築  
```  
cd C:\Users\shino\doc\cicddemo  
terraform apply terraform  
```  
  
## Terraform によるデストロイ  
  
作成環境の削除前チェックと削除  
cd C:\Users\shino\doc\cicddemo  
```  
terraform plan -destroy terraform  
terraform destroy terraform  
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
  
## 秘密鍵と公開鍵ファイルはGitHub管理しないようにする  
  
.gitignore に秘密鍵と公開鍵を追記  
```  
cd C:\Users\shino\doc\cicddemo  
echo identity>> .gitignore  
echo identity.pub>>.gitignore  
```  
  
## Travic CI の初期設定  
  
Travis CI 設定  
Travis CI の GUI からサーバアプリの GitHub レポジトリを連携設定  
  
コード参照  
```  
deploy.sh  
.travis.yml  
```  
  
## アプリケーション変更時のディプロイ管理  
  
ディプロイ  
```  
cd C:\Users\shino\doc\cicddemo  
terraform plan terraform  
terraform apply terraform  
```  
  
インスタンス上で travis ログイン  
```  
cd /devops-example-server  
travis login  
```  
  
インスタンス上で宛先グローバルIPアドレスを暗号化  
.travis.ymlファイルに暗号化した内容が追記され環境変数として参照可能  
```  
cd /devops-example-server/  
travis encrypt REMOTE_HOST=35.200.27.47 -a  
```  
  
インスタンス上で .travis.yml ファイルをコミットしプッシュ  
```  
git add *  
git add .gitignore  
git add .travis.yml  
git config --local user.email shinonome128@gmail.com  
git config --local user.name "shinonome128"  
git commit -m "Add travis config"  
git push  
```  
  
ローカルのクライアントアプリのグローバルIP変更  
render.js  
```  
const hostname = '35.200.36.65'  // ここの部分を変更する  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
  
サーバアプリのコード変更  
ローカルでPullしてからサーバアプリのコード変更 、コミット、プッシュ  
リアルタイムでインスタンス上のアプリがディプロイされる  
example.php  
```  
      'msg' => "Updated"  // この行を追加したり、コメントアウトしたりする  
```  
  
クライアントアプリの起動、アクセステスト  
```  
cd C:\Users\shino\doc\cicddemo\devops-example-client  
npm install && npm start  
```  
  
デストロイ  
```  
cd C:\Users\shino\doc\cicddemo  
terraform plan -destroy terraform  
terraform destroy terraform  
```  
  
## イシュー作成  
  
firewall rule で Travis CI のグローバルアドレスで絞りたい  
Terraform のスタートスクリプトでサーバアプリをインストするとルートユーザになってしまう、shinonome128ユーザにしたい  
travis login 時の GitHub クレデンシャルの入力を求められるので自動化したい  
エフェメラル IP を .travis.yml に落とす時に GCP コンソールからアドレスを拾う作業を自動化したい  
.travis.yml を GibHub にプッシュする時に GitHub のクレデンシャルを求められるで自動化したい  
.travis.yml を使えば、環境変数、ファイルを暗号化した状態で使えそう  
  
以上  
