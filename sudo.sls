sudo:
  pkg.installed: []

sudo_group:
  group.present:
    - name: sudo
    - addusers:
      - {{pillar['admin_user']}}
