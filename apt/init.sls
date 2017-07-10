{% if pillar['apt'] is defined %}
include:
  - apt.backports.present
{% endif %}


apt_packages:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - gnupg2
      - debian-keyring
      - python-pip
    - refresh: True
