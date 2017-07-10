tmux:
  pkg:
    - installed

python-pip:
  pkg:
    - installed

tmuxp:
  pip.installed:
    - require:
      - pkg: python-pip  
