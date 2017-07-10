{% if pillar['dlna']['dleyna'] is defined and pillar['dlna']['dleyna'] == 'enable' %}
dleyna-renderer:
  pkg.installed
{% else %}
dleyna-renderer:
  pkg.removed
{% endif %}
