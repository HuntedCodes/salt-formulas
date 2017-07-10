{% if pillar['firewall']['ipv4']['interface'] is defined %}
{% set interfaces = pillar['firewall']['ipv4']['interface'] %}

  {%- for interface in interfaces %}
  {% if 'dhcp' in pillar['firewall']['ipv4']['interface'][interface]['services'] %}
  allow_ipv4_dhcp_service_in_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: INPUT
      - position: 1
      - in-interface: {{interface}}
      - proto: udp
      - sport: 67:68
      - dport: 67:68
      - jump: ACCEPT
      - save: True
  allow_ipv4_dhcp_service_out_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: OUTPUT
      - position: 1
      - out-interface: {{interface}}
      - proto: udp
      - sport: 67:68
      - dport: 67:68
      - jump: ACCEPT
      - save: True
  {% else %}
  delete_ipv4_dhcp_service_in_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: INPUT
      - in-interface: {{interface}}
      - proto: udp
      - sport: 67:68
      - dport: 67:68
      - jump: ACCEPT
      - save: True
  delete_ipv4_dhcp_service_out_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: OUTPUT
      - out-interface: {{interface}}
      - proto: udp
      - sport: 67:68
      - dport: 67:68
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}
