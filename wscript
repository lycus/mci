#!/usr/bin/env python

import os, subprocess

VERSION = '1.0'
APPNAME = 'MCI'

TOP = '.'
OUT = 'build'

def options(opt):
    opt.recurse('libffi-d')

    opt.load('compiler_d')

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

def _run_shell(ctx, args):
    code = subprocess.Popen(args, shell = True).wait()

    if code != 0:
        ctx.fatal(str(args) + ' exited with: ' + str(code))

def _run_tests(ctx, variant):
    os.chdir('tests')

    os.chdir('assembler')
    _run_shell(ctx, 'rdmd tester.d ' + variant)

def test_debug(ctx):
    _run_tests(ctx, 'debug')

def test_release(ctx):
    _run_tests(ctx, 'release')

def docs(ctx):
    os.chdir('docs')

    def build_docs(targets):
        for x in targets:
            _run_shell(ctx, 'make ' + x)

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

from waflib.Build import BuildContext, CleanContext, InstallContext, UninstallContext

for x in ('debug', 'release'):
    for y in (BuildContext, CleanContext, InstallContext, UninstallContext):
        class tmp(y):
            cmd = y.__name__.replace('Context', '').lower() + '_' + x
            variant = x
