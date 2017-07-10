python3_support:
  pkg.installed:
    - pkgs:
      {% if grains['os'] == 'Debian' %}
      - python3-ipython  # Backports
      - python3-ipdb
      {% endif %}
      {% if grains['os'] == 'Ubuntu' %}
      - ipython3
      - python3-ipdb
      {% endif %}
