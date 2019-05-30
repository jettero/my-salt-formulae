#!jinja|yaml

{% set py3 = '3.6' %}
{% set py2 = '2.7' %}

python:
  default: '{{ py3 }}'
  pure:
    - '{{ py2 }}'
    - '{{ py3 }}'

  {# user/developer python dumpsters #}
  landing_dirs:
    '/usr/local/python':
      user: jettero
      group: jettero

  {# drop some pure python venvs into the dumpster.
  ## jettero will be able to modify these willy nilly.
  #}
  venv:
    my-python-{{ py2 }}:
      py: {{ py2 }}
      loc: /usr/local/python/python{{ py2 }}
      user: jettero
    my-python-{{ py3 }}:
      py: {{ py3 }}
      loc: /usr/local/python/python{{ py3 }}
      user: jettero
