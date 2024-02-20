#! /bin/bash

apt update
apt install wireguard -y
apt install resolvconf

wg genkey | tee /etc/wireguard/private.key
chmod go= /etc/wireguard/private.key

cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key

cat << EOF > /etc/wireguard/wg0.conf
# Do not alter the commented lines
# They are used by wireguard-install

[Interface]
Address = 10.7.0.1/24
DNS = 1.1.1.1, 1.0.0.1
PrivateKey = $(cat /etc/wireguard/private.key)
ListenPort = 51820

EOF


echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

echo 'PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE' >> /etc/wireguard/wg0.conf

ufw allow 51820/udp
ufw allow OpenSSH
ufw disable -y
ufw enable -y
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service


key=$(wg genkey)
psk=$(wg genpsk)

client='client1'
cat << EOF >> /etc/wireguard/wg0.conf
# BEGIN_PEER $client
[Peer]
PublicKey = $(wg pubkey <<< $key)
PresharedKey = $psk
AllowedIPs = 10.7.0.2/32

EOF

public_ip=$(grep -m 1 -oE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$(wget -T 10 -t 1 -4qO- "http://ip1.dynupdate.no-ip.com/" || curl -m 10 -4Ls "http://ip1.dynupdate.no-ip.com/")")


# Create client configuration
cat << EOF > /home/ubuntu/"$client".conf
[Interface]
Address = 10.7.0.2/24
DNS = 1.1.1.1, 1.0.0.1
PrivateKey = $key

[Peer]
PublicKey = $(grep PrivateKey /etc/wireguard/wg0.conf | cut -d " " -f 3 | wg pubkey)
PresharedKey = $psk
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${public_ip}:51820
PersistentKeepalive = 25
EOF

chown ubuntu /home/ubuntu/"$client".conf

systemctl enable --now wg-quick@wg0.service
wg addconf wg0 <(sed -n "/^# BEGIN_PEER $client/,/^# END_PEER $client/p" /etc/wireguard/wg0.conf)
