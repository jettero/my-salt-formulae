{% from 'python/map.jinja' import pure_python, build_packages %}

include:
  - dl-repo

build_packages:
  pkg.installed:
    - pkgs: {{ build_packages }}

/usr/bin/reinstall-pure-python.sh:
  file.managed:
    - user: root
    - group: root
    - mode: '0700'
    - source: salt://python/reinstall-pure-python.sh

{% for PYV in pure_python %}
'reinstall-python{{PYV}}-onchanges':
  cmd.wait:
    - name: '/usr/bin/reinstall-pure-python.sh {{PYV}}'
    - cwd: /root
    - env:
        HOME: /root
    - require:
      - file: /etc/profile.d/dl-repo.sh
      - pkg: build_packages
    - watch:
      - file: /usr/bin/reinstall-pure-python.sh

'reinstall-python{{PYV}}-notexist':
  cmd.run:
    - name: '/usr/bin/reinstall-pure-python.sh {{PYV}}'
    - cwd: /root
    - env:
        HOME: /root
    - unless: 'test -x /opt/pure/python/{{PYV}}/bin/python'
    - require:
      - file: /etc/profile.d/dl-repo.sh
      - file: /usr/bin/reinstall-pure-python.sh
      - cmd: reinstall-python{{PYV}}-onchanges

/opt/pure/python/{{PYV}}/bin/python:
  file.exists:
    - require:
        - cmd: reinstall-python{{PYV}}-onchanges
        - cmd: reinstall-python{{PYV}}-notexist

/opt/pure/python/{{PYV}}/bin/pip:
  file.exists:
    - require:
        - cmd: reinstall-python{{PYV}}-onchanges
        - cmd: reinstall-python{{PYV}}-notexist
{%- endfor %}
