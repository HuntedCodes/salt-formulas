iptables-persistent:
  pkg.installed


# Loopback allowed
allow_ipv4_loopback_in:
  iptables.append:
    - table: filter
    - chain: INPUT
    - in-interface: lo
    - jump: ACCEPT
    - save: True

allow_ipv4_loopback_out:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - out-interface: lo
    - jump: ACCEPT
    - save: True

allow_ipv6_loopback_in:
  iptables.append:
    - family: ipv6
    - table: filter
    - chain: INPUT
    - in-interface: lo
    - jump: ACCEPT
    - save: True

allow_ipv6_loopback_out:
  iptables.append:
    - family: ipv6
    - table: filter
    - chain: OUTPUT
    - out-interface: lo
    - jump: ACCEPT
    - save: True


# LOGDROP defined here, to be available for other rules.
create_ipv4_logdrop_chain:
  iptables.chain_present:
    - name: LOGDROP
    - table: filter

logdrop_ipv4_log_packets:
  iptables.append:
    - table: filter
    - chain: LOGDROP
    - jump: LOG
    - log-prefix: "[iptables-dropped] "
    - log-level: warning
    - match: limit
    - limit: 30/min
    - limit-burst: 10
    - save: True

logdrop_ipv4_drop_packets:
  iptables.append:
    - table: filter
    - chain: LOGDROP
    - jump: DROP
    - save: True

create_ipv6_logdrop_chain:
  iptables.chain_present:
    - name: LOGDROP
    - family: ipv6
    - table: filter

logdrop_ipv6_log_packets:
  iptables.append:
    - family: ipv6
    - table: filter
    - chain: LOGDROP
    - jump: LOG
    - log-prefix: "[ip6tables-dropped] "
    - log-level: warning
    - match: limit
    - limit: 30/min
    - limit-burst: 10
    - save: True

logdrop_ipv6_drop_packets:
  iptables.append:
    - family: ipv6
    - table: filter
    - chain: LOGDROP
    - jump: DROP
    - save: True
