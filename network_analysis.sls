network_analysis_apt:
  pkg.installed:
    - pkgs:
      - tcpdump
      - nmap
      - hping3

network_analysis_pip:
  pip.installed:
    - name: scapy
    - name: speedtest-cli
