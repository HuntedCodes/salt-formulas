FROM debian
MAINTAINER Jack Sullivan

RUN apt-get update
RUN apt-get install -y dnsmasq

# DHCP and TFTP
EXPOSE 67/udp
EXPOSE 69/udp

ENTRYPOINT [ \
  "dnsmasq", \
  "--no-daemon", \
  "--conf-file=/data/etc/dnsmasq.conf", \
  "--dhcp-leasefile=/data/dhcp/dhcp.leases", \
  "--dhcp-broadcast" \
]
