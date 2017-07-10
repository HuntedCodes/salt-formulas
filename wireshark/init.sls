{% set admin_user = pillar['admin_user'] %}

wireshark:
  pkg.installed: []


wireshark_group:
  group.present:
    - name: wireshark
    - addusers:
      - {{pillar['admin_user']}}


wireshark_directory:
  file.directory:
    - name: /home/{{admin_user}}/.wireshark
    - owner: {{admin_user}}
    - group: {{admin_user}}
    - mode: 700


wireshark_preferences:
  file.managed:
    {% if grains['os'] == 'Debian' %}
    - name: /home/{{admin_user}}/.wireshark/preferences
    {% endif %}
    {% if grains['os'] == 'Ubuntu' %}
    - name: /home/{{admin_user}}/.config/wireshark/preferences
    {% endif %}
    - source: salt://wireshark/files/preferences
    - owner: {{admin_user}}
    - group: {{admin_user}}
    - mode: 755
