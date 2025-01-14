FROM golang:1.23
RUN apt update && apt install -y wireguard-tools iproute2 iptables curl
CMD ["/src/init.sh"]
