{% set LG2V = salt['pillar.get']('salt:pure:libgit2_ver', 'v0.27.1') %}

include:
  - dl-repo
  - pure-python

/usr/bin/reinstall-pure-pygit2.sh:
  file.managed:
    - user: root
    - group: root
    - mode: '0700'
    - source: salt://salt/pure/reinstall-pure-pygit2.sh

'reinstall-pygit2-{{ LG2V }}-onchanges':
  cmd.wait:
    - name: '/usr/bin/reinstall-pure-pygit2.sh {{ LG2V }}'
    - cwd: /root
    - require:
      - file: /etc/profile.d/dl-repo.sh
      - file: /opt/venv/salt/bin/python
    - watch:
      - file: /usr/bin/reinstall-pure-pygit2.sh

{%- set printv = 'import pygit2; print(pygit2.__version__)' %}
{%- set py = 'PYTHONPATH= /opt/venv/salt/bin/python' %}
'reinstall-pygit2-{{ LG2V }}-notexist':
  cmd.run:
    - name: '/usr/bin/reinstall-pure-pygit2.sh {{ LG2V }}'
    - cwd: /root
    - unless: 'test v$({{ py }} -c "{{ printv }}") = {{ LG2V }}'
    - require:
      - file: /etc/profile.d/dl-repo.sh
      - file: /opt/venv/salt/bin/python
      - cmd: reinstall-pygit2-{{ LG2V }}-onchanges
