#!/usr/bin/env python

import os, shutil, subprocess
from waflib import Options, Utils

APPNAME = 'MCI'
VERSION = '1.0'

TOP = '.'
OUT = 'build'

def options(opt):
    opt.recurse('libffi-d')

    opt.add_option('--vim', action='store', default=None, help='Include Vim syntax files (prefix)')

def configure(conf):
    conf.recurse('libffi-d')

    conf.env.VIM = conf.options.vim

    def add_option(option):
        conf.env.append_value('DFLAGS', option)

    conf.load('dmd')

    add_option('-w')
    add_option('-wi')
    add_option('-ignore')
    add_option('-property')
    add_option('-gc')

    if conf.options.lp64 == 'true':
        add_option('-m64')
    elif conf.options.lp64 == 'false':
        add_option('-m32')
    else:
        conf.fatal('--lp64 must be either true or false.')

    if conf.options.mode == 'debug':
        add_option('-debug')
    elif conf.options.mode == 'release':
        add_option('-release')
        add_option('-O')
        add_option('-inline')
    else:
        conf.fatal('--mode must be either debug or release.')

    conf.env.LIB_FFI = ['ffi']

    if not Utils.unversioned_sys_platform().lower().endswith('bsd'):
        conf.env.LIB_DL = ['dl']

    conf.check_dlibrary()

def build(bld):
    bld.recurse('libffi-d')

    def search_paths(path):
        return [os.path.join(path, '*.d'), os.path.join(path, '**', '*.d')]

    includes = ['src', 'libffi-d']
    src = os.path.join('src', 'mci')

    def stlib(path, target, dflags = [], install = '${PREFIX}/lib'):
        bld.stlib(source = bld.path.ant_glob(search_paths(os.path.join(src, path))),
                  target = target,
                  includes = includes,
                  install_path = install,
                  dflags = dflags)

    def program(path, target, deps, dflags = [], install = '${PREFIX}/bin'):
        bld.program(source = bld.path.ant_glob(search_paths(os.path.join(src, path))),
                    target = target,
                    use = deps,
                    includes = includes,
                    install_path = install,
                    dflags = dflags)

    stlib('core', 'mci.core')
    stlib('assembler', 'mci.assembler')
    stlib('verifier', 'mci.verifier')
    stlib('vm', 'mci.vm')

    deps = ['mci.vm',
            'mci.verifier',
            'mci.assembler',
            'mci.core',
            'ffi-d',
            'FFI']

    if not Utils.unversioned_sys_platform().lower().endswith('bsd'):
        deps += ['DL']

    program('cli', 'mci', deps)

    program('tester', 'mci.tester', deps, ['-unittest'], None)

    if bld.env.VIM:
        bld.install_files(os.path.join(bld.env.VIM, 'syntax'), os.path.join('vim', 'syntax', 'ial.vim'))
        bld.install_files(os.path.join(bld.env.VIM, 'ftdetect'), os.path.join('vim', 'ftdetect', 'ial.vim'))

def _run_shell(dir, ctx, args):
    cwd = os.getcwd()
    os.chdir(dir)

    code = subprocess.Popen(args, shell = True).wait()

    if code != 0:
        ctx.fatal(str(args) + ' exited with: ' + str(code))

    os.chdir(cwd)

def _run_tests(ctx):
    if 'darwin' in Utils.unversioned_sys_platform():
        cmd = './mci.tester'
    else:
        cmd = 'gdb --command=' + os.path.join('..', 'mci.gdb') + ' mci.tester'

    _run_shell(OUT, ctx, cmd)
    _run_shell('tests', ctx, 'rdmd tester.d "assembler" "asm <file> -o <name>.mci -d <name>.ast"')
    _run_shell('tests', ctx, 'rdmd tester.d "verifier" "asm <file> -o <name>.mci -d <name>.ast -v"')

def test(ctx):
    Options.commands = ['build', '_run_tests'] + Options.commands

def docs(ctx):
    def build_docs(targets):
        for x in targets:
            _run_shell('docs', ctx, 'make ' + x)

    build_docs(['html',
                'dirhtml',
                'singlehtml',
                'pickle',
                'json',
                'htmlhelp',
                'qthelp',
                'devhelp',
                'epub',
                'latex',
                'text',
                'man',
                'changes',
                'linkcheck'])

def dist(dst):
    with open('.gitignore', 'r') as f:
        dst.excl = ' '.join(l.strip() for l in f if l.strip())
