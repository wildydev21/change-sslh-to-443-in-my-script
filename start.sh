#!/bin/bash

cat > /lib/systemd/system/sslh.service << END
[Unit]
Description=SSLH Server
Documentation=https://wildydev21.com
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/sbin/sslh --foreground --user root --listen 0.0.0.0:443 --tls 127.0.0.1:777 --ssh 127.0.0.1:22 --openvpn 127.0.0.1:1194 --http 127.0.0.1:80
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END


cat > /etc/wildydev21/ws-epro.conf << END
# WS-ePro Config By WildyDev21
# ============================================================
# Please do not try to change / modif this config
# This config is tag to xray if you modified this
# Xray will Error / Crash
# ============================================================
# (C) Copyright 2022-2023 By WildyDev21

# // Start Config
verbose: 0
listen:

# // WebSocket NonTLS
- target_host: 127.0.0.1
  target_port: 22
  listen_port: 80

# // WebSocket TLS
- target_host: 127.0.0.1
  target_port: 22
  listen_port: 2083
END

cat > /etc/stunnel/stunnel.conf << END
# Stunnel4 Config By WildyDev21
# ============================================================
# Please do not try to change / modif this config
# This config is connection to sslh & proxy
# if you changes it maybe stunnel & openssh will error
# ============================================================
# (C) Copyright 2022-2023 By WildyDev21

# // Start Config
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[openssh]
accept = 777
connect = 127.0.0.1:443

[dropbear]
accept = 990
connect = 127.0.0.1:110

[openvpn-ssl]
accept = 1196
connect = 127.0.0.1:1194
END

sed -i "s/443/8443/g" /etc/xray-mini/tls.json
sed -i "s/80/8881/g" /etc/xray-mini/nontls.json

systemctl stop xray-mini@tls
systemctl stop xray-mini@nontls
systemctl daemon-reload
systemctl restart sslh
systemctl restart stunnel4
systemctl restart ws-epro
systemctl restart xray-mini@tls
systemctl restart xray-mini@nontls

clear; echo "Done ! | Successfull Changed SSH To 443"
