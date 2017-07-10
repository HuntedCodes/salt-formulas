docker_repo:
  pkgrepo.managed:
   - humanname: Official Docker Repository
   - name: deb https://apt.dockerproject.org/repo {{grains.os|lower}}-{{ grains.lsb_distrib_codename|lower }} main
   - file: /etc/apt/sources.list.d/docker.list
   - keyid: 58118E89F3A912897C070ADBF76221572C52609D
   - keyserver: hkp://p80.pool.sks-keyservers.net:80
   - refresh_db: True

docker_pkgs:
  pkg.latest:
    - name: docker-engine
    - refresh: True

docker_users:
  group.present:
    - name: docker
    - addusers:
      - {{pillar['admin_user']}}

/srv/docker:
  file.directory:
    - user: root
    - group: docker
    - mode: 775
    - makedirs: True
