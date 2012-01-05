#!/usr/bin/env python

import os, subprocess
from waflib.Build import BuildContext, CleanContext, InstallContext, UninstallContext

VERSION = '1.0'
APPNAME = 'MCI'

TOP = '.'
OUT = 'build'

def options(opt):
    opt.recurse('libffi-d')

    opt.add_option('--vim', action='store', default=None, help='Include Vim syntax files (prefix)')

def configure(conf):
    conf.recurse('libffi-d')

    def add_option(option):
        conf.env.append_value('DFLAGS', [option])

    def common_options():
        add_option('-w')
        add_option('-wi')
        add_option('-ignore')
        add_option('-property')
        add_option('-gc')

        if conf.options.lp64 == 'true':
            add_option('-m64')
        else:
            add_option('-m32')

        conf.env.LIB_FFI = ['ffi']
        conf.env.LIB_DL = ['dl']

        conf.check_dlibrary()

        conf.env.VIM = conf.options.vim

    conf.setenv('debug')
    conf.load('dmd')
    common_options()
    add_option('-debug')

    conf.setenv('release')
    conf.load('dmd')
    common_options()
    add_option('-release')
    add_option('-O')
    add_option('-inline')

def build(bld):
    bld.recurse('libffi-d')

    def search_paths(path):
        return [os.path.join(path, '*.d'), os.path.join(path, '**', '*.d')]

    includes = ['.', 'libffi-d']

    def stlib(path, target, dflags = [], install = '${PREFIX}/lib'):
        bld.stlib(source = bld.path.ant_glob(search_paths(path)),
                  target = target,
                  includes = includes,
                  install_path = install,
                  dflags = dflags)

    def program(path, target, deps, dflags = [], install = '${PREFIX}/bin'):
        bld.program(source = bld.path.ant_glob(search_paths(path)),
                    target = target,
                    use = deps,
                    includes = includes,
                    install_path = install,
                    dflags = dflags)

    stlib('mci/core', 'mci.core')
    stlib('mci/assembler', 'mci.assembler')
    stlib('mci/verifier', 'mci.verifier')
    stlib('mci/vm', 'mci.vm')

    deps = ['mci.vm',
            'mci.verifier',
            'mci.assembler',
            'mci.core',
            'FFI',
            'DL']

    program('mci/cli', 'mci.cli', deps)

    program('mci/tester', 'mci.tester', deps, ['-unittest'], None)

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

def _run_tests(ctx, variant):
    _run_shell(os.path.join(OUT, variant), ctx, os.path.join('gdb --command=' + \
               os.path.join('..', '..', 'mci.gdb') + ' mci.tester'))
    _run_shell(os.path.join('tests', 'assembler'), ctx, 'rdmd tester.d ' + variant)

def test_debug(ctx):
    _run_tests(ctx, 'debug')

def test_release(ctx):
    _run_tests(ctx, 'release')

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

for x in ('debug', 'release'):
    for y in (BuildContext, CleanContext, InstallContext, UninstallContext):
        class tmp(y):
            cmd = y.__name__.replace('Context', '').lower() + '_' + x
            variant = x
