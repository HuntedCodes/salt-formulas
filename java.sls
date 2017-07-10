java_packages:
  pkg.installed:
    - pkgs:
      - default-jdk

krakatau:
  git.latest:
    - name: https://github.com/Storyyeller/Krakatau
    - target: /usr/local/bin/krakatau

/usr/local/bin/java_assemble:
  file.symlink:
    - target: /usr/local/bin/krakatau/assemble.py

/usr/local/bin/java_disassemble:
  file.symlink:
    - target: /usr/local/bin/krakatau/disassemble.py

/usr/local/bin/java_decompile:
  file.symlink:
    - target: /usr/local/bin/krakatau/decompile.py
