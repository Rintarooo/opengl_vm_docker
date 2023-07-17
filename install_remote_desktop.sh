#!/bin/bash

# https://medium.com/@kumon/instant-nerf-on-google-compute-engine-via-chrome-remote-desktop-eee4fd98df56
# https://cloud.google.com/architecture/chrome-desktop-remote-on-compute-engine?hl=ja#xfce
sudo apt update
sudo apt install --assume-yes wget tasksel
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb

# 低速なネットワーク経由のリモート接続には、グラフィクの要素が最小限でアニメーションが少ない Xfce をおすすめします。
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'
sudo systemctl disable lightdm.service

# https://remotedesktop.google.com/headless?pli=1
# [承認] をクリックする -> Debian Linuxのコマンドラインをコピーして、SSHで接続してるVMのインスタンスに貼り付ける
DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="4/0AZEOvhV11s6OUNEny8DNOBikpdKok7vwBoKmbMwwUuRdNSGxxM3Lormw86n5tAbwzDrjwQ" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)