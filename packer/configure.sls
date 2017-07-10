{% set default_user = pillar['secret']['default_user'] %}
{% set default_password = pillar['secret']['default_password'] %}

mako_template_engine:
  pip.installed:
    - name: mako

copy_packer_boot_files:
  file.recurse:
    - name: /srv/packer/boot
    - source: salt://packer/files/boot
    - include_empty: True
    - user: root
    {% if grains['os'] == 'Debian' %}
    - group: kvm
    {% endif %}
    {% if grains['os'] == 'Ubuntu' %}
    - group: libvirtd
    {% endif %}
    - dir_mode: 0775
    - file_mode: 0775


{% set output_subdir = pillar['packer']['output_subdir'] | default('dist') %}
{% if pillar['packer']['template'] is defined %}
{% for template_name, args in pillar['packer']['template'].items() %}

{% set abstract_template = args.abstract_template %}
{% set disk_image_name = args.disk_image_name %}
{% set disk_size = args.disk_size %}
{% set hostname = args.hostname | default(template_name) %}
{% set domain = args.domain | default('') %}

generate_packer_template_file_{{template_name}}:
  file.managed:
    - name: /srv/packer/{{template_name}}.json
    - source: salt://packer/files/{{abstract_template}}.json
    - template: mako
    - context:
        template_name: {{ template_name }}
        disk_image_name: {{ disk_image_name }}
        disk_size: {{ disk_size }}
        default_user: {{ default_user }}
        default_password: {{ default_password }}
        hostname: {{ hostname }}
        domain: {{ domain }}
        output_dir: {{output_subdir}}/{{template_name}}
    - user: root
    {% if grains['os'] == 'Debian' %}
    - group: kvm
    {% endif %}
    {% if grains['os'] == 'Ubuntu' %}
    - group: libvirtd
    {% endif %}
    - mode: 0775
    - require:
        - pip: mako

{% endfor %}
{% endif %}
