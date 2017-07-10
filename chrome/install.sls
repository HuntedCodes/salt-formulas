google_repo:
  pkgrepo.managed:
   - humanname: Official Google Repository
   - name: deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
   - file: /etc/apt/sources.list.d/google.list
   - key_url: https://dl-ssl.google.com/linux/linux_signing_key.pub
   - refresh_db: True

#https://askubuntu.com/questions/79280/how-to-install-chrome-browser-properly-via-command-line
google_chrome_packages:
  pkg.installed:
    - pkgs:
        - libxss1
        - libappindicator1
        - libindicator7
        - google-chrome-stable
