# Packer export start
{% set output_subdir = pillar['packer']['output_subdir'] | default('dist') %}
{% if pillar['packer']['template'] is defined %}
{% for template_name, args in pillar['packer']['template'].items() %}

{% set disk_image_name = args.disk_image_name %}
{% set source_image_dir = '/srv/packer/'+output_subdir+'/'+template_name %}
{% set source_image_path = source_image_dir+'/'+disk_image_name %}
{% set final_image_dir = '/srv/salt-images/'+template_name %}
{% set final_image_path = final_image_dir+'/'+disk_image_name %}

packer_move_image_{{disk_image_name}}:
  file.rename:
    - name: {{final_image_dir}}
    - source: {{source_image_dir}}
    - makedirs: true
    - force: true
    - unless: ls {{final_image_path}}

packer_dir_perm_{{final_image_dir}}:
  file.directory:
    - name: {{final_image_dir}}
    - user: root
    {% if grains['os'] == 'Debian' %}
    - group: kvm
    {% endif %}
    {% if grains['os'] == 'Ubuntu' %}
    - group: libvirtd
    {% endif %}
    - dir_mode: 770
    - file_mode: 660
    - recurse:
      - user
      - group

packer_image_perm_{{disk_image_name}}:
  file.managed:
    - name: {{final_image_path}}
    - user: root
    {% if grains['os'] == 'Debian' %}
    - group: kvm
    {% endif %}
    {% if grains['os'] == 'Ubuntu' %}
    - group: libvirtd
    {% endif %}
    - mode: 775

{% endfor %}
{% endif %}
# Packer export end

# Libvirt import start
{% if pillar['hypervisor']['vm_template'] is defined %}
{% for vm_template, args in pillar['hypervisor']['vm_template'].items() %}

{% set disk_image_name = args.disk_image_name %}
{% set final_image_path = '/srv/salt-images/'+vm_template+'/'+disk_image_name %}

{% set os = args.os | default('generic') %}
{% set distro = args.distro | default('generic') %}
{% set cpu = args.cpu | default(1) %}
{% set mem = args.mem | default(512) %}
{% set vnet = args.vnet | default('') %}
{% set bridge = args.bridge | default('') %}

cloud_libvirt_import_{{vm_template}}:
  cmd.script:
    - name: salt://cloud/files/libvirt_import.py
    - env:
      - LIBVIRT_IMPORT_VM_NAME: {{vm_template}}
      - LIBVIRT_IMPORT_OS: {{os}}
      - LIBVIRT_IMPORT_DISTRO: {{distro}}
      - LIBVIRT_IMPORT_CPU: "{{cpu}}"
      - LIBVIRT_IMPORT_MEM: "{{mem}}"
      - LIBVIRT_IMPORT_DISK_PATH: {{final_image_path}}
      - LIBVIRT_IMPORT_VNET: {{vnet}}
      - LIBVIRT_IMPORT_BRIDGE: {{bridge}}
    - unless : virsh --connect qemu:///system list --all | sed 's/ \+/\t/g' | cut -f3 | grep '^{{vm_template}}$'


{% endfor %}
{% endif %}
