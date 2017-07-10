binary_analysis_apt:
  pkg.installed:
    - pkgs:
      - hexedit

binary_analysis_pip:
  pip.installed:
    - name: capstone
