/etc/NetworkManager/dispatcher.d/vpn-up:
  file.managed:
    - name: /etc/NetworkManager/dispatcher.d/vpn-up
    - source: salt://openvpn/network_manager/vpn-up
    - template: jinja
    - user: root
    - group: root
    - mode: 0755
