
/etc/profile.d/dl-repo.sh:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - source: salt://dl-repo/snip.sh
