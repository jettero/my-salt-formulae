{% set SLV = salt['pillar.get']('salt:pure:ver', 'v2018.3.3') %}
# XXX: see pip<18.1 below for salt 2018.3.3; 2018.3.4 fixes
#  AttributeError: type object 'InstallRequirement' has no attribute 'from_line'

{%- set build_pkgs = salt['grains.filter_by']({
    'Ubuntu': [ 'build-essential', 'libzmq-dev' ],
    'Arch':   [ 'gcc', 'make', 'zeromq' ],
}, grain='os', default='Arch') %}


{% from 'pure-python/map.jinja' import python2_venv %}

include:
  - dl-repo
  - pure-python
  {%- if 'salt-master' in grains.get('role', []) %}
  - pure-salt.pygit2
  {%- endif %}

{% if build_pkgs %}
salt-build-pkgs:
  pkg.installed:
    - pkgs: {{ build_pkgs }}
{%- endif %}

# salt 2018.3.3 needs pip<18.1 to do pip install right
{{ python2_venv('salt', pip_pkgs='pip<18.1 ipython python-dateutil boto boto3 botocore gnupg'.split()) }}

{%- if grains.os == 'Ubuntu' %}
/usr/bin/install-pure-salt-python-apt.sh:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - contents: |
        #!/bin/bash
        cd /root/dlds || exit 1
        apt-get install -y libapt-pkg-dev
        apt-get source python-apt
        cd python-apt-* || exit 1
        source /opt/venv/salt/bin/activate
        umask 022
        /opt/venv/salt/bin/python setup.py install
    - require_in:
      - file: /usr/bin/reinstall-pure-salt.sh
{%- endif %}

/usr/bin/opt-env-process-current:
  file.managed:
    - user: root
    - group: salt-data
    - mode: '0755'
    - source: salt://salt/pure/opt-env-process-current.sh

/usr/bin/reinstall-pure-salt.sh:
  file.managed:
    - user: root
    - group: root
    - mode: '0700'
    - source: salt://salt/pure/reinstall-pure-salt.sh
    - require:
      - file: /opt/venv/salt/bin/python

'reinstall-salt-{{SLV}}-onchanges':
  cmd.wait:
    - name: '/usr/bin/reinstall-pure-salt.sh {{SLV}}'
    - cwd: /root
    - env:
        HOME: /root
    - require:
      - file: /etc/profile.d/dl-repo.sh
      - file: /opt/venv/salt/bin/python
      - pkg: salt-build-pkgs
    - watch:
      - file: /usr/bin/reinstall-pure-salt.sh

'reinstall-salt-{{SLV}}-notexist':
  cmd.run:
    - name: '/usr/bin/reinstall-pure-salt.sh {{SLV}}'
    - cwd: /root
    - unless: '/opt/venv/salt/bin/salt-call --version | grep -q {{SLV.replace('v','')}}'
    - require:
      - file: /etc/profile.d/dl-repo.sh
      - file: /opt/venv/salt/bin/python
      - cmd: reinstall-salt-{{SLV}}-onchanges
      - pkg: salt-build-pkgs

{%- if not pillar.get('no-vsalt') %}
/usr/bin/vsalt:
  file.managed:
    - user: root
    - group: root
    - mode: '0755'
    - source: salt://salt/pure/vsalt.sh

{%- if not pillar.get('no-vsalt-links') %}
vsalt-links:
  cmd.run:
    - name: /usr/bin/vsalt
    - cwd: /root
    - env:
        WANTED: vsalt-links
    - stateful: true
    - require:
      - file: /usr/bin/vsalt
{%- endif %}
{%- endif %}

{%- if grains.get('osx') == 'ubuntu-trusty' %}
realpath:
  pkg.installed:
    - require_in:
      - cmd: vsalt-links
{%- endif %}
