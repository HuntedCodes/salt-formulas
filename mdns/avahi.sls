{% if pillar['mdns']['avahi'] is defined and pillar['mdns']['avahi'] == 'enable' %}
avahi-daemon.service:
  service.running:
    - enable: True
avahi-daemon.socket:
  service.running:
    - enable: True
{% else %}
avahi-daemon.service:
  service.dead:
    - enable: False
avahi-daemon.socket:
  service.dead:
    - enable: False
{% endif %}
