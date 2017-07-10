{% set unpriv_ports = '1025:65535' %}
{% if pillar['firewall']['ipv4']['interface'] is defined %}
{% set interfaces = pillar['firewall']['ipv4']['interface'] %}

  {%- for interface in interfaces %}
  {% if 'tftp' in pillar['firewall']['ipv4']['interface'][interface]['services'] %}
  allow_ipv4_tftp_service_in_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: INPUT
      - position: 1
      - in-interface: {{interface}}
      - proto: udp
      - sport: {{ unpriv_ports }}
      - dport: 69
      - jump: ACCEPT
      - save: True
  allow_ipv4_tftp_service_out_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: OUTPUT
      - position: 1
      - out-interface: {{interface}}
      - proto: udp
      - sport: 69
      - dport: {{ unpriv_ports }}
      - jump: ACCEPT
      - save: True
  {% else %}
  delete_ipv4_tftp_service_in_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: INPUT
      - in-interface: {{interface}}
      - proto: udp
      - sport: {{ unpriv_ports }}
      - dport: 69
      - jump: ACCEPT
      - save: True
  delete_ipv4_tftp_service_out_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: OUTPUT
      - out-interface: {{interface}}
      - proto: udp
      - sport: 69
      - dport: {{ unpriv_ports }}
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}
