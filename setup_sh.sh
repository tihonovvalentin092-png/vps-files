#!/bin/bash
echo "=== Установка cloudflared ==="
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm cloudflared-linux-amd64.deb

echo "=== Настройка службы ==="
TOKEN="eyJhIjoiZDA5YWIwNjBjYmI1MDU3MDViNmI1YWFlZWRkY2Y3MmIiLCJ0IjoiOGE1NzQ2NjMtMmEwYS00MGQ4LTg0OTMtYjM1ZDM2YmQzNDExIiwicyI6Ik0yTTRObVl4TjJZdFkyRTBPUzAwT0RrekxXSm1NMlF0T0dJMU0yWmtObUUyTnpBd01tWTVPVGhqTWpFdE1XUmlNaTAwWWpKakxUZzFObUV0WkRobU56Z3pOamxsTlRCaSJ9"
sudo cloudflared service install $TOKEN
sudo systemctl restart cloudflared
sleep 3
sudo systemctl status cloudflared --no-pager
