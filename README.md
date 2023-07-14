# Build OpenGL environment on M1 Mac

## Usage

### 1. Build Docker image and Run on localhost

---

ビルドする Docker イメージのイメージ名を、`src/docker_app/docker-compose.yaml`の image の項目に追加

```bash
    image: [ビルドするDockerイメージのイメージ名]
```

次に、ビルドしてローカルホストで動作確認

```bash
# ビルド
docker-compose build
docker-compose build --no-cache
# コンテナ起動
docker-compose up
# ターミナル別タブで開いてcurlコマンド叩く
time curl -d '{}' http://localhost:9000/2015-03-31/functions/function/invocations

# コンテナ起動（バックグランド起動）
docker-compose up -d
# 起動しているか確認
docker-compose ps

# ログ出し、デバッグ
docker-compose logs -f
# コンテナ入る
# docker-compose exec (service名) (command)
docker-compose exec opengl-tutorial /bin/bash

# コンテナ停止
docker-compose down
```

```bash
## コンテナ内でxeyesコマンドを実行したときに以下のエラーが出る場合
# root@docker-desktop:/opt# xeyes
# Authorization required, but no authorization protocol specified
# Error: Can't open display: host.docker.internal:0
# 
$ xhost +localhost
localhost being added to access control list

# $ xhost + local:
# non-network local connections being added to access control list

# $ /usr/X11/bin/xeyes

# $ /usr/X11/bin/xhost +           
# access control disabled, clients can connect from any host
```

build and run
```bash
./build.sh
./build/main
```
