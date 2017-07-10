{% if pillar['network']['forward_ipv4'] is defined %}
  {% if pillar['network']['forward_ipv4'] == True %}
    enable_ipv4_forwarding:
      sysctl.present:
        - name: net.ipv4.ip_forward
        - value: 1
        - config: /etc/sysctl.conf
  {% else %}
    disable_ipv4_forwarding:
      sysctl.present:
        - name: net.ipv4.ip_forward
        - value: 0
        - config: /etc/sysctl.conf
  {% endif %}
{% else %}
  disable_ipv4_forwarding:
    sysctl.present:
      - name: net.ipv4.ip_forward
      - value: 0
      - config: /etc/sysctl.conf
{% endif %}
