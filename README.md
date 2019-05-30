
# pure-python

The pure python formula requires some pillar (see
`example-pillar/pure-python.sls`), a state plugin (`_states/pyverchk.py`) and
the various statelists and templates in `pure-python/`

When it's invoked and applied, it'll setup pythons in /opt/pure/python/ and
possibly add more as virtualenv links to those pure pythons to landing locations
defined in pillar.

# pure-salt

Requires and uses the pure-pythons described above. Like the pure-python
formula, this requires some supporting pillar (see
`example-pillar/pure-salt.sls`)

# dl-repo

Just a handy little tool for downloading repos. Used to simplify build scripts
for both the pure-salt and pure-python.
