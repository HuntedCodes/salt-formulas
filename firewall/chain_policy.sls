{% if pillar['firewall']['ipv4']['policy_drop'] is defined %}
  {%- for chain in pillar['firewall']['ipv4']['policy_drop'] %}
  set_ipv4_policy_drop_{{chain}}:
    iptables.set_policy:
      - chain: {{chain}}
      - policy: DROP
      - save: True
  {%- endfor %}
{% endif %}

{% if pillar['firewall']['ipv4']['policy_accept'] is defined %}
  {%- for chain in pillar['firewall']['ipv4']['policy_accept'] %}
  set_ipv4_policy_accept_{{chain}}:
    iptables.set_policy:
      - chain: {{chain}}
      - policy: ACCEPT
      - save: True
  {%- endfor %}
{% endif %}


{% if pillar['firewall']['ipv6']['policy_drop'] is defined %}
  {%- for chain in pillar['firewall']['ipv6']['policy_drop'] %}
  set_ipv6_policy_drop_{{chain}}:
    iptables.set_policy:
      - family: ipv6
      - chain: {{chain}}
      - policy: DROP
      - save: True
  {%- endfor %}
{% endif %}

{% if pillar['firewall']['ipv6']['policy_accept'] is defined %}
  {%- for chain in pillar['firewall']['ipv6']['policy_accept'] %}
  set_ipv6_policy_accept_{{chain}}:
    iptables.set_policy:
      - family: ipv6
      - chain: {{chain}}
      - policy: ACCEPT
      - save: True
  {%- endfor %}
{% endif %}
