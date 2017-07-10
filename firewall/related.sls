{% if pillar['firewall']['ipv4']['related_in'] is defined %}

  {%- for interface in pillar['firewall']['ipv4']['related_in'] %}
  add_ipv4_related_in_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: INPUT
      - position: 1
      - in-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {%- endfor %}

  {%- for interface in grains['ip_interfaces'] %}
  {% if interface not in pillar['firewall']['ipv4']['related_in'] %}
  delete_ipv4_related_in_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: INPUT
      - in-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}


{% if pillar['firewall']['ipv4']['related_out'] is defined %}

  {%- for interface in pillar['firewall']['ipv4']['related_out'] %}
  add_ipv4_related_out_{{interface}}:
    iptables.insert:
      - table: filter
      - chain: OUTPUT
      - position: 1
      - in-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {%- endfor %}

  {%- for interface in grains['ip_interfaces'] %}
  {% if interface not in pillar['firewall']['ipv4']['related_out'] %}
  delete_ipv4_related_out_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: OUTPUT
      - out-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}
{% if pillar['firewall']['ipv6']['related_in'] is defined %}

  {%- for interface in pillar['firewall']['ipv6']['related_in'] %}
  add_ipv6_related_in_{{interface}}:
    iptables.insert:
      - family: ipv6
      - table: filter
      - chain: INPUT
      - position: 1
      - in-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {%- endfor %}

  {%- for interface in grains['ip_interfaces'] %}
  {% if interface not in pillar['firewall']['ipv6']['related_in'] %}
  delete_ipv6_related_in_{{interface}}:
    iptables.delete:
      - family: ipv6
      - table: filter
      - chain: INPUT
      - in-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}


{% if pillar['firewall']['ipv6']['related_out'] is defined %}

  {%- for interface in pillar['firewall']['ipv6']['related_out'] %}
  add_ipv6_related_out_{{interface}}:
    iptables.insert:
      - family: ipv6
      - table: filter
      - chain: OUTPUT
      - position: 1
      - in-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {%- endfor %}

  {%- for interface in grains['ip_interfaces'] %}
  {% if interface not in pillar['firewall']['ipv6']['related_out'] %}
  delete_ipv6_related_out_{{interface}}:
    iptables.delete:
      - family: ipv6
      - table: filter
      - chain: OUTPUT
      - out-interface: {{interface}}
      - match: conntrack
      - ctstate: 'RELATED,ESTABLISHED'
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}
