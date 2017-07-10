{% if pillar['firewall']['ipv4']['policy_drop'] is defined %}
  {%- for chain in pillar['firewall']['ipv4']['policy_drop'] %}
  add_ipv4_logdrop_{{chain}}:
    iptables.append:
      - table: filter
      - chain: {{chain}}
      - jump: LOGDROP
      - save: True
  {%- endfor %}
{% endif %}


{% if pillar['firewall']['ipv6']['policy_drop'] is defined %}
  {%- for chain in pillar['firewall']['ipv6']['policy_drop'] %}
  add_ipv6_logdrop_{{chain}}:
    iptables.append:
      - family: ipv6
      - table: filter
      - chain: {{chain}}
      - jump: LOGDROP
      - save: True
  {%- endfor %}
{% endif %}
