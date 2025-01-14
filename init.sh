#!/usr/bin/env bash

set -e -x

export LOG_LEVEL=debug

/src/wireguard-go wg0

echo "Starting $WG_ROLE"

function google() {
	until curl https://google.com
	do
		echo "trying again"
		sleep 2
	done
}

if [ "$WG_ROLE" == "client" ]
then
	echo "inside client"
	ip addr add 192.168.1.2 dev wg0
	wg set wg0 listen-port 51820 private-key /src/keys/client peer $(cat /src/keys/server.pub) allowed-ips 0.0.0.0/0 endpoint server:51820
	ip link set up dev wg0
	ip route add default dev wg0

	google
fi

if [ "$WG_ROLE" == "server" ]
then
	echo "inside server"
	ip addr add 192.168.1.1/24 dev wg0
	wg set wg0 listen-port 51820 private-key /src/keys/server
	ip link set up dev wg0
	iptables -t nat -A POSTROUTING -s 192.168.1.1/24 -o eth0 -j MASQUERADE
	iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT
fi



sleep 10000
