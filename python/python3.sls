python3_packages:
  pkg.installed:
    - pkgs:
      - python3
      - python3-dev
      - python3-pip

update_pip3:
  pip.installed:
    - name: pip
    - bin_env: /usr/bin/pip3
    - upgrade: True
