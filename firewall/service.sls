{% set unpriv_ports = '1025:65535' %}
{% if pillar['firewall']['ipv4']['interface'] is defined %}
{% set interfaces = pillar['firewall']['ipv4']['interface'] %}

  {%- for interface in interfaces %}
  {% if 'http' in pillar['firewall']['ipv4']['interface'][interface]['services'] %}
  allow_ipv4_http_service_in_{{interface}}:
    iptables.append:
      - table: filter
      - chain: INPUT
      - in-interface: {{interface}}
      - proto: tcp
      - sport: {{ unpriv_ports }}
      - dport: 80
      - jump: ACCEPT
      - save: True
  allow_ipv4_http_service_out_{{interface}}:
    iptables.append:
      - table: filter
      - chain: OUTPUT
      - out-interface: {{interface}}
      - proto: tcp
      - sport: 80
      - dport: {{ unpriv_ports }}
      - jump: ACCEPT
      - save: True
  {% else %}
  delete_ipv4_http_service_in_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: INPUT
      - in-interface: {{interface}}
      - proto: tcp
      - sport: {{ unpriv_ports }}
      - dport: 80
      - jump: ACCEPT
      - save: True
  delete_ipv4_http_service_out_{{interface}}:
    iptables.delete:
      - table: filter
      - chain: OUTPUT
      - out-interface: {{interface}}
      - proto: tcp
      - sport: 80
      - dport: {{ unpriv_ports }}
      - jump: ACCEPT
      - save: True
  {% endif %}
  {%- endfor %}

{% endif %}
