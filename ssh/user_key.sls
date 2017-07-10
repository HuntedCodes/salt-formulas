{% set user = 'root' %}
create_{{user}}_ssh_key:
  cmd.run:
    - name: ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
    - unless: ls $HOME/.ssh/id_rsa
    - runas: {{user}}
