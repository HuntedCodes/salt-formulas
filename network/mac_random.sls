/etc/NetworkManager/conf.d/mac-randomization.conf:
  file.managed:
    - source: salt://network/files/mac-randomization.conf
    - user: root
    - group: root
    - mode: 755
