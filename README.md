# GCP VM+Docker+OpenGL+CMake

* GCP VM(+Chrome Remote Desktop)
* Docker(docker-compose, nvidia-docker)
* OpenGL(+CUDA)
* CMake

<img src="https://github.com/Rintarooo/VRP_DRL_MHA/assets/51239551/c8e2484b-da02-4f95-9812-16ad8c2c7f0e" width="500px">

## Usage

### 0. Set up

clone repo
```bash
git clone https://github.com/Rintarooo/opengl_vm_docker
cd opengl_vm_docker
```


`.env`ファイルを作成し、GCPのプロジェクト・VMのインスタンス名を入れる
```bash
vim .env
```

`.env` 
```bash
# GCP project name
export PROJECT="###"
# VM instance name
export INSTANCE="###"
```

VM作成&起動＆接続
```bash
# 作成
./gcould.sh create
# 起動
./gcould.sh start
# 接続
./gcould.sh ssh

# ssh connect to chrome desktop
https://remotedesktop.google.com/access

# 起動中は課金されるので、使わない時は停止
./gcould.sh stop
```


VM初回起動時：docker-compose のインストール＆アプデ

（Deep Leanring VMにデフォルトで入るdocker-composeのバージョンが1.25.0と古いため）

```bash
./update_docker-compose.sh
```

### 1. Build Docker image and Run container
次に、docker imageをビルド

```bash
# VM上でビルド
docker-compose build
# docker-compose build --no-cache

# VMのremote chrome desktop上でコンテナ起動（-dオプションでバックグランド起動）
docker-compose up -d

# 起動しているか確認
docker-compose ps

# # ログ出し、デバッグ
# docker-compose logs -f

# コンテナ入る
# docker-compose exec (service名) (command)
docker-compose exec opengl-tutorial /bin/bash

# GUI表示出来るか確認
xeyes

# コンテナ停止
docker-compose down
```

コンテナ内でxeyesコマンドを実行したときに以下のエラーが出る場合
```bash
# root@docker-desktop:/opt# xeyes
# No protocol specified
# Error: Can't open display: :20.0
$ xhost +localhost
localhost being added to access control list

$ xhost + local:
non-network local connections being added to access control list
```


### 2. Build c++ code and Run

コンテナ内で、build and run
```bash
./build.sh
./build/main
```
