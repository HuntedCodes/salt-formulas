{% if pillar['apt']['backports'] == true %}
{% if grains['oscodename'] == 'jessie' %}
apt_backports:
  file.managed:
    - name: /etc/apt/sources.list
    - source: salt://apt/files/debian8-backports.list
    - owner: root
    - group: root
    - mode: 644
{% endif %}
{% endif %}
