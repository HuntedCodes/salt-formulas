
{% set phys_nic =  pillar['hypervisor']['external_nic'] %}
{% set vnet_dir =  '/etc/libvirt/qemu/networks' %}
{% if pillar['hypervisor']['vnet'] is defined %}

  create_libvirt_xml_dir:
    file.directory:
      - name: {{vnet_dir}}
      - user: root
      - group: root
      - mode: 0755

  {% for vnet, args in pillar['hypervisor']['vnet'].items() %}
  generate_libvirt_vnet_xml_{{vnet}}:
    file.managed:
      - name: {{vnet_dir}}/{{vnet}}.xml
      - source: salt://libvirt/files/vnet.xml
      - template: jinja
      - context:
          vnet: {{vnet}}
          mode: {{args.mode}}
          phys_nic: {{phys_nic}}
          bridge_nic: {{args.bridge_nic}}
          mac: {{args.mac}}
          ipv4: {{args.ipv4}}
          dhcp_start: {{args.dhcp_start}}
          dhcp_end: {{args.dhcp_end}}
          uuid: {{ salt['cmd.run']('cat /proc/sys/kernel/random/uuid') }}
      - unless: virsh --connect qemu:///system net-list --all | sed 's/ \+/\t/g' | cut -f2 | grep ^{{vnet}}$
    cmd.run:
      - name: virsh --connect qemu:///system net-define {{vnet_dir}}/{{vnet}}.xml
      - unless: virsh --connect qemu:///system net-list --all | sed 's/ \+/\t/g' | cut -f2 | grep ^{{vnet}}$

  {% if args.auto is defined and args.auto == true %}
  enable_autostart_vnet_{{vnet}}:
    cmd.run:
      - name: "virsh --connect qemu:///system net-autostart {{vnet}}"
      - unless: virsh --connect qemu:///system net-info {{vnet}} | grep ^Autostart | grep yes$
  {% endif %}
  {% if args.auto is not defined or args.auto == false %}
  disable_autostart_vnet_{{vnet}}:
    cmd.run:
      - name: "virsh --connect qemu:///system net-autostart {{vnet}} --disable"
      - unless: virsh --connect qemu:///system net-info {{vnet}} | grep ^Autostart | grep no$
  {% endif %}


  start_vnet_{{vnet}}:
    cmd.run:
      - name: "virsh --connect qemu:///system net-start {{vnet}}"
      - unless: virsh --connect qemu:///system net-info {{vnet}} | grep ^Active | grep yes$


  {%- endfor %}

{% endif %}
