{% if pillar['firewall']['nat'] is defined %}

  {%- for interface in pillar['firewall']['nat'] %}
  add_nat_{{interface}}:
    iptables.insert:
      - table: nat
      - chain: POSTROUTING
      - position: 1
      - jump: MASQUERADE
      - out-interface: {{interface}}
      - save: True
  {%- endfor %}

  {%- for interface in grains['ip_interfaces'] %}
  {% if interface not in pillar['firewall']['nat'] %}
  delete_nat_{{interface}}:
    iptables.delete:
      - table: nat
      - chain: POSTROUTING
      - jump: MASQUERADE
      - out-interface: {{interface}}
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}
