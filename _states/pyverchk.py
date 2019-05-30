import os

def compare(name, target):
    ret = {'name': name, 'changes': {}, 'result': True, 'comment': ''}

    if not os.path.isfile(name):
        ret['result'] = False
        ret['comment'] = 'name={0} is not a file.'.format(name)
        return ret

    if not os.path.isfile(target):
        ret['changes']['missing'] = 'target={0} is not a file'.format(target)
        return ret

    # if either of these version checks fail, does the state just crash?
    # we should probably check that eventually
    nv = __salt__['cmd.run']([name, '--version'], output_loglevel='quiet')
    tv = __salt__['cmd.run']([target, '--version'], output_loglevel='quiet')

    if nv != tv:
        ret['changes']['mismatch'] = '{target} version ({tv}) mismatch ({nv}).'.format(
            target=target, nv=nv, tv=tv)

    return ret
