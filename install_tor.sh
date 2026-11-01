#!/bin/bash

# ==========================================
# Скрипт установки и настройки Tor (Snowflake) на VPS
# ==========================================

set -e # Останавливаться при ошибках

echo "=== 1. Установка зависимостей ==="
sudo apt update
sudo apt install -y apt-transport-https wget gpg snowflake-client

echo "=== 2. Добавление официального репозитория Tor ==="
# Скачиваем ключ
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null

# Добавляем репозиторий
echo "deb [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tor.list

# Обновляем и ставим Tor
sudo apt update
sudo apt install -y tor

echo "=== 3. Настройка мостов Snowflake ==="
# Создаем резервную копию конфига, если ее нет
if [ ! -f /etc/tor/torrc.bak ]; then
    sudo cp /etc/tor/torrc /etc/tor/torrc.bak
fi

# Перезаписываем конфиг с настройками Snowflake
sudo tee /etc/tor/torrc > /dev/null << 'EOF'
SocksPort 9050
UseBridges 1
ClientTransportPlugin snowflake exec /usr/bin/snowflake-client
Bridge snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA url=https://snowflake-broker.torproject.net/ fronts=www.cdn77.com,www.phpmyadmin.net
EOF

echo "=== 4. Перезапуск и проверка ==="
sudo systemctl restart tor
sleep 5
sudo systemctl status tor --no-pager

echo "=== ГОТОВО. Проверка через curl ==="
# Проверяем, работает ли Tor (ожидаем "IsTor": true)
curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/api/ip || echo "Проверка не удалась (возможно, мост не подключился)"