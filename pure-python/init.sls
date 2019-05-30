{# NOTE: to require a specific python that should have been installed by pure-python

blah:
  various.things:
    - etc, etc
    - require:
      - file: /opt/venv/salt/bin/python
#}

include:
  - pure-python.pure

py-build-pkgs:
  pkg.installed:
    - pkgs:
       - gcc
       - make

{%- from 'pure-python/map.jinja' import python3_venv, python2_venv %}

{%- set venvs  = salt['pillar.get']('python:venv', {}) %}
{%- set def_py = salt['pillar.get']('python:default', 3.6) %}

{%- for vname in salt['pillar.get']('python:venv', {}) %}
  {%- set vdir    = venvs[vname].loc     | default('/opt/venv/{0}'.format(vname)) %}
  {%- set vuser   = venvs[vname].user    | default('root') %}
  {%- set vgroup  = venvs[vname].group   | default(vuser)  %}
  {%- set vpy     = venvs[vname].py      | default(3)      %}

  {%- if vpy >= 3 %}
    {{- python3_venv(vname, base=vdir, user=vuser, group=vgroup) }}
  {%- else %}
    {{- python2_venv(vname, base=vdir, user=vuser, group=vgroup) }}
  {%- endif %}
{%- endfor %}
