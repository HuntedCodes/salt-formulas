{% set docker_root = '/srv/docker' %}
{% if pillar['docker'] is defined %}
{% set docker = pillar['docker'] %}

############
# Swarm mode
############
{% if docker['swarm'] is defined %}
{% set adv_addr = docker['swarm']['advertise_addr'] %}
docker_swarm_on:
  cmd.run:
    - name: "docker swarm init --advertise-addr {{adv_addr}}"
    - unless: "docker info | grep '^Swarm: active$'"
{% else %}
docker_swarm_off:
  cmd.run:
    - name: "docker swarm leave"
    - unless: "docker info | grep '^Swarm: inactive$'"
{% endif %}


##########
# Services
##########
{% if docker['service'] is defined %}
{% for service, args in docker['service'].items() %}

# Get service repo
{% if 'git' in args %}
docker_git_{{service}}:
  git.latest:
    - name: {{args.git}}
    - target: {{docker_root}}/{{args.local_dir}}
    - user: {{pillar['admin_user']}}
    - onchanges_in:
      - dockerng: docker_rebuild_image_{{service}}
{% endif %}

# Configure templates
{% if 'template_file' in args %}
{% for file_name, file_args in args.template_file.items() %}
docker_{{service}}_template_{{file_name}}:
  file.managed:
    - name: {{file_args.target}}
    - source: {{file_args.source}}
    {% if 'type' in file_args %}
    - template: {{file_args.type}}
    {% endif %}
    - onchanges_in:
      - dockerng: docker_rebuild_image_{{service}}
      - cmd: docker_restart_service_{{service}}
{% endfor %}
{% endif %}

# Bulid repo images
{% if 'build' in args %}
{% for image, dockerfile in args.build.items() %}
docker_build_image_{{image}}:
  dockerng.image_present:
    - name: {{image}}
    - dockerfile: {{dockerfile}}
    - build: {{docker_root}}/{{args.local_dir}}
    - onchanges_in:
      - cmd: docker_restart_service_{{service}}
{% endfor %}
{% endif %}

# Rebuild repo images (set with onchanges_in)
{% if 'build' in args %}
docker_rebuild_image_{{service}}:
{% for image, dockerfile in args.build.items() %}
  dockerng.image_present:
    - name: {{image}}
    - dockerfile: {{dockerfile}}
    - build: {{docker_root}}/{{args.local_dir}}
    - force: True
    - onchanges_in:
      - cmd: docker_restart_service_{{service}}
{% endfor %}
{% endif %}

# Create service
docker_create_service_{{service}}:
  cmd.run:
    - cwd: {{docker_root}}/{{args.local_dir}}
    {% if args.service_type == 'swarm' %}
    - name: docker stack deploy -c {{args.compose_file}} {{service}}
    - unless: "docker service ps {{service}}"
    {% else %}
    - name: docker-compose --file {{args.compose_file}} up -d
    - unless: "docker container inspect {{service}}"
    {% endif %}

# Restart service (set with onchanges_in)
docker_restart_service_{{service}}:
  cmd.run:
    - cwd: {{docker_root}}/{{args.local_dir}}
    {% if args.service_type == 'swarm' %}
    - name: docker service scale {{service}}=0 && docker service scale {{service}}=1
    {% else %}
    - name: docker-compose --file {{args.compose_file}} up -d --force-recreate
    {% endif %}

{% endfor %}
{% endif %}   # End service config

{% endif %}  # End docker
