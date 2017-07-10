{% set default_user = pillar['hypervisor']['default_user'] %}
{% set default_password = pillar['hypervisor']['default_password'] %}

{% set salt_master_host = pillar['hypervisor']['salt_master_host'] %}

{% if pillar['hypervisor']['vm_template'] is defined %}
{% for vm_template, args in pillar['hypervisor']['vm_template'].items() %}
cloud_profile_libvirt_{{vm_template}}:
  file.managed:
    - name: /etc/salt/cloud.profiles.d/{{vm_template}}.conf
    - source: salt://cloud/files/libvirt-cloud-profile.conf
    - template: jinja
    - context:
        vm_profile: {{vm_template}}
        base_domain: {{vm_template}}
        default_user: {{ default_user }}
        default_password: {{ default_password }}
        salt_master_host: {{ salt_master_host }}
{% endfor %}
{% endif %}
