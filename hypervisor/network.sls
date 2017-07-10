management_bridge:
  network.managed:
    - name: {{pillar['network']['management']['nic']}}
    - enabled: True
    - type: bridge
    - proto: none
    - ipaddr: {{pillar['network']['management']['ipv4']['ip']}}
    - netmask: 255.255.255.0
    - bridge: {{pillar['network']['management']['nic']}}
    - delay: 0
    - ports: none
    - bypassfirewall: True


server_bridge:
  network.managed:
    - name: {{pillar['network']['server']['nic']}}
    - enabled: True
    - type: bridge
    - proto: none
    - ipaddr: {{pillar['network']['server']['ipv4']['ip']}}
    - netmask: 255.255.255.0
    - bridge: {{pillar['network']['server']['nic']}}
    - delay: 0
    - ports: none
    - bypassfirewall: True


client_bridge:
  network.managed:
    - name: {{pillar['network']['client']['nic']}}
    - enabled: True
    - type: bridge
    - proto: none
    - ipaddr: {{pillar['network']['client']['ipv4']['ip']}}
    - netmask: 255.255.255.0
    - bridge: {{pillar['network']['client']['nic']}}
    - delay: 0
    - ports: none
    - bypassfirewall: True
