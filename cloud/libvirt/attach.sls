{% if pillar['hypervisor']['vm_instance'] is defined %}
{% for vm_name, args in pillar['hypervisor']['vm_instance'].items() %}

{% set hostname = pillar['packer']['template'][vm_name]['hostname'] | default(vm_name) %}
{% set domain = pillar['packer']['template'][vm_name]['domain'] | default('') %}

# Start the VM.
cloud_libvirt_start_{{vm_name}}:
  cmd.run:
    - name: 'virsh --connect qemu:///system start {{vm_name}}'
    - unless : '[ $(virsh --connect qemu:///system domstate {{vm_name}}) = "running" ]'


accept_libvirt_salt_key_{{vm_name}}:
  cmd.script:
    - name: salt://cloud/files/salt_accept.py
    - env:
      - LIBVIRT_VM_NAME: {{vm_name}}
      - LIBVIRT_DOMAIN: {{domain}}
    - unless: salt-key -l accepted | grep ^{{vm_name}}$

{% endfor %}
{% endif %}
