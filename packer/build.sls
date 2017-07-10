{% set output_subdir = pillar['packer']['output_subdir'] | default('dist') %}
{% if pillar['packer']['template'] is defined %}
{% for template_name, args in pillar['packer']['template'].items() %}

{% set disk_image_name = args.disk_image_name %}
{% set source_image_dir = '/srv/packer/'+output_subdir+'/'+template_name %}
{% set source_image_path = source_image_dir+'/'+disk_image_name %}
{% set final_image_dir = '/srv/salt-images/'+template_name %}
{% set final_image_path = final_image_dir+'/'+disk_image_name %}

packer_build_{{template_name}}:
  cmd.run:
    - name: packer build {{template_name}}.json
    - cwd: /srv/packer
    - unless: ls {{source_image_path}} || ls {{final_image_path}}

{% endfor %}
{% endif %}
