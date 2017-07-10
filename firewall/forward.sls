{% if pillar['firewall']['ipv4']['forward_all'] is defined %}

  {%- for interface in pillar['firewall']['ipv4']['forward_all'] %}
  add_ipv4_forward_all_in_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: FORWARD
      - position: 1
      - in-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  add_ipv4_forward_all_out_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: FORWARD
      - position: 1
      - out-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  {%- endfor %}

  {%- for interface in grains['ip_interfaces'] %}
  {% if interface not in pillar['firewall']['ipv4']['forward_all'] %}
  delete_ipv4_forward_all_in_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: FORWARD
      - in-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  delete_ipv4_forward_all_out_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: FORWARD
      - out-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}


{% if pillar['firewall']['ipv6']['forward_all'] is defined %}

  {%- for interface in pillar['firewall']['ipv6']['forward_all'] %}
  add_ipv6_forward_all_in_{{interface}}:
    iptables.insert:
      - family: ipv6
      - table: filter
      - chain: FORWARD
      - position: 1
      - in-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  add_ipv6_forward_all_out_{{interface}}:
    iptables.insert:
      - family: ipv6
      - table: filter
      - chain: FORWARD
      - position: 1
      - out-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  {%- endfor %}

  {%- for interface in grains['ip_interfaces'] %}
  {% if interface not in pillar['firewall']['ipv6']['forward_all'] %}
  delete_ipv6_forward_all_in_{{interface}}:
    iptables.delete:
      - family: ipv6
      - table: filter
      - chain: FORWARD
      - in-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  delete_ipv6_forward_all_out_{{interface}}:
    iptables.delete:
      - family: ipv6
      - table: filter
      - chain: FORWARD
      - out-interface: {{interface}}
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}
