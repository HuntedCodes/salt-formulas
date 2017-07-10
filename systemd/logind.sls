/etc/systemd/logind.conf:
  file.managed:
    - source: salt://systemd/files/logind.conf
