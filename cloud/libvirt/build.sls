# Build a disk image, and create a VM with packer and libvirt.

# If no disk image
#   packer build
#   move disk image
# If no VM
#   create VM and import disk image


{% if pillar['hypervisor']['vm_instance'] is defined %}
{% for vm_name, args in pillar['hypervisor']['vm_instance'].items() %}

# Build or use the specified VM disk image.
{% set packer = args.packer | default(False) %}
{% if packer == True %}

{% set packer_dir = pillar['packer']['packer_dir'] | default('/srv/packer') %}
{% set disk_image_dir = pillar['hypervisor']['disk_image_dir'] | default('/srv/salt-images') %}
{% set packer_out_subdir = pillar['packer']['output_subdir'] | default('dist') %}

{% set packer_args = pillar['packer']['template'][vm_name] %}
{% set disk_image_name = packer_args.disk_image_name %}

{% set source_image_dir = packer_dir+'/'+packer_out_subdir+'/'+vm_name %}
{% set source_image_path = source_image_dir+'/'+disk_image_name %}

{% set final_image_dir = disk_image_dir+'/'+vm_name %}
{% set final_image_path = final_image_dir+'/'+disk_image_name %}

packer_build_{{vm_name}}:
  cmd.run:
    - name: packer build {{vm_name}}.json
    - cwd: {{packer_dir}}
    - unless: ls {{source_image_path}} || ls {{final_image_path}}
  file.rename:
    - name: {{final_image_dir}}
    - source: {{source_image_dir}}
    - makedirs: true
    - force: true
    - unless: ls {{final_image_path}}

{% else %}

{% set source_image_path = args.disk_image_path %}
# Not implemented

{% endif %}


# Enforce disk image file permissions.
disk_image_permission_{{vm_name}}:
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


# Build the VM.
{% set os = args.os | default('generic') %}
{% set distro = args.distro | default('generic') %}
{% set cpu = args.cpu | default(1) %}
{% set mem = args.mem | default(512) %}
{% set vnet = args.vnet | default('') %}
{% set bridge = args.bridge | default('') %}
{% set direct_nic = args.direct_nic | default('') %}
{% set auto_start = args.auto_start | default(True) %}
cloud_libvirt_import_{{vm_name}}:
  cmd.script:
    - name: salt://cloud/files/libvirt_import.py
    - env:
      - LIBVIRT_IMPORT_VM_NAME: {{vm_name}}
      - LIBVIRT_IMPORT_OS: {{os}}
      - LIBVIRT_IMPORT_DISTRO: {{distro}}
      - LIBVIRT_IMPORT_CPU: "{{cpu}}"
      - LIBVIRT_IMPORT_MEM: "{{mem}}"
      - LIBVIRT_IMPORT_DISK_PATH: {{final_image_path}}
      - LIBVIRT_IMPORT_VNET: {{vnet}}
      - LIBVIRT_IMPORT_BRIDGE: {{bridge}}
      - LIBVIRT_IMPORT_DIRECT_NIC: {{direct_nic}}
    - unless : virsh --connect qemu:///system list --all | sed 's/ \+/\t/g' | cut -f3 | grep '^{{vm_name}}$'


{% endfor %}
{% endif %}
