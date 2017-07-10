configure_network_interfaces:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://network/files/interfaces.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: networking


{% if pillar['network']['network_manager'] is defined %}
{% if pillar['network']['network_manager'] == False %}
removing_network_manager:
  pkg.removed:
    - pkgs:
      - network-manager
{% endif %}
{% endif %}


networking:
  service.running:
    - enable: True
