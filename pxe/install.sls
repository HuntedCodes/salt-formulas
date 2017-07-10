# pxe.install

# Specify parameters:
# - Listening interface
# - Address range
# - PXE boot target (pxelinux.0)
# Docker compose up
# Verifiy container is running


copy_docker_pxe:
  file.recurse:
    - name: /srv/docker/pxe
    - source: salt://pxe/docker_pxe
    - template: jinja
    - include_empty: True
    - user: root
    - group: docker
    - dir_mode: 0755
    - file_mode: 0755


# TODO: Workaround until dockerng bug is fixed.
# States and modules aren't working. Giving exception.
# All packages are up to date.
compose_pxe:
  cmd.run:
    - name: docker-compose up -d
    - cwd: /srv/docker/pxe
    - unless: docker container ls | grep "pxe"


restart_pxe_services:
  cmd.run:
    - name: docker container restart pxe

# Link pxelinux.cfg/default, default PXE configuration.
