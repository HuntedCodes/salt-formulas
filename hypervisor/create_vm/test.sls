# Disk profiles don't work with KVM yet.
#   "virt.init does not support disk profiles in conjunction with
#   qemu/kvm at this time, use image template instead."
#
# Workaround 1:
# 1. Download the `virtng` salt module.
#    https://github.com/salt-formulas/salt-formula-salt/blob/master/_modules/virtng.py
# 2. Modify `virtng` to use local templates.
# 3. Modify the libvirt salt templates, and store them locally.
# 4. Use the `qemu_image.make_image` module in a state, to create the disk image.
# 5. Use the `virtng.init` module in a state to create the VM.

# Workaround 2:
# 1. Create a VM manually.
# 2. Dump the XML with virsh: virsh dumpxml <mydomain> > /path/to/salt.
# 3. Use the `qemu_image.make_image` module in a state, to create the disk image.
# 4. Import the XML with the `virt.define_xml_path` state, creating the VM.

{% set image_root = salt['config.option']('virt.images') %}

{% for vm, args in pillar['hypervisor']['vm'].items() %}

create_vm_path_{{vm}}:
  file.directory:
    - name: {{ image_root }}/{{vm}}
    - user: root
    - group: kvm
    - dir_mode: 0775


create_vm_disk_{{vm}}:
  module.run:
    - name: qemu_img.make_image
    - location: {{ image_root }}/{{vm}}/system.qcow2
    - size: {{ args.disk_size }}
    - fmt: qcow2
    - unless: ls {{ image_root }}/{{vm}}/system.qcow2


create_vm_{{vm}}:
  module.run:
    - name: virtng.init
    - m_name: {{vm}}
    - cpu: {{ args.cpu }}
    - mem: {{ args.mem }}
    - image: {{ image_root }}/{{vm}}/system.qcow2
    - nic: {{ args.nic }}
    - start: False
    - kwargs: {
        boot_dev: 'hd cdrom network'
      }
    - unless: virsh list --all --name | grep "^{{vm}}$"


ensure_vm_disk_permission_{{vm}}:
  file.managed:
    - name: {{ image_root }}/{{vm}}/system.qcow2
    - user: root
    - group: kvm
    - mode: 0664


# SYSLINUX and preseed files, that target machine's MAC address, for PXE boot.
{% set tftp_root = '/srv/docker/pxe/dnsmasq/tftp' %}
{% set distribution = 'debian' %}
{% set release = 'jessie' %}

{% set pxe_server = pillar['network']['management']['ipv4']['ip'] %}
{% set file_target = '{0}-{1}'.format(distribution, release) %}
{% set syslinux_filename = '{0}-{1}-syslinux.cfg'.format(vm, file_target) %}
{% set preseed_filename = '{0}-{1}-preseed.cfg'.format(vm, file_target) %}


syslinux_config_{{vm}}:
  file.managed:
    - name: {{tftp_root}}/pxelinux.cfg/{{syslinux_filename}}
    - source: salt://templates/syslinux/{{distribution}}-{{release}}-syslinux.jinja
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 0644
    - context:
        hostname: {{vm}}
        preseed_url: tftp://{{pxe_server}}/preseed/{{preseed_filename}}


syslinux_link_config_{{vm}}:
  syslinux.target_vm_mac:
    - name: {{vm}}
    - config: {{tftp_root}}/pxelinux.cfg/{{syslinux_filename}}


preseed_config_{{vm}}:
  file.managed:
    - name: {{tftp_root}}/preseed/{{preseed_filename}}
    - source: salt://templates/preseed/{{distribution}}-{{release}}-preseed.jinja
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 0644


{{vm}}:
  virt.running

{% endfor %}
