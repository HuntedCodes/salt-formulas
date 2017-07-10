{% if pillar['hypervisor']['vm_instance'] is defined %}
{% for vm_instance, args in pillar['hypervisor']['vm_instance'].items() %}


# Create VM, and bootstrap the salt minion.
{% if args.vm_template is defined %}
{% set vm_template = args.vm_template %}
create_cloud_vm_{{vm_instance}}:
  cloud.profile:
    - name: {{vm_instance}}
    - profile: {{vm_template}}
    - unless: virsh list --all --name | grep "^{{vm_instance}}$"
{% endif %}


# Tailor the VM to specification.
# configure_cloud_vm_{{vm_instance}}:
#   libvirtng.present:
#     - name: {{vm_instance}}
#     {% if args.cpu is defined %}
#     - cpu: {{args.cpu}}
#     {% endif %}
#     {% if args.mem is defined %}
#     - mem: {{args.mem}}
#     {% endif %}
#     {% if args.network is defined %}
#     - network:
#       {% for network in args.network %}
#       - {{network}}
#       {% endfor %}
#     {% endif %}
#     {% if args.bridge is defined %}
#     - bridge:
#       {% for bridge in args.bridge %}
#       - {{bridge}}
#       {% endfor %}
#     {% endif %}
#     {% if args.auto is defined %}
#     - auto: {{args.auto}}
#     {% endif %}
#     {% if args.force is defined %}
#     - force: {{args.force}}
#     {% endif %}


{% endfor %}
{% endif %}
