#!/usr/bin/env python

import os, shutil, subprocess
from waflib import Build, Utils

APPNAME = 'MCI'
VERSION = '1.0'

TOP = os.curdir
OUT = 'build'

def options(opt):
    opt.recurse('libffi-d')
    opt.recurse('libgc-d')

    opt.add_option('--vim', action = 'store', default = None, help = 'include Vim syntax files (prefix)')
    opt.add_option('--gtksourceview', action = 'store', default = None, help = 'include GtkSourceView syntax files (prefix)')
    opt.add_option('--valgrind', action = 'store', default = 'false', help = 'use Valgrind for unit tests')

def configure(conf):
    conf.recurse('libffi-d')
    conf.recurse('libgc-d')

    conf.env.VIM = conf.options.vim
    conf.env.GTKSOURCEVIEW = conf.options.gtksourceview

    if conf.options.valgrind != 'true' and conf.options.valgrind != 'false':
        conf.fatal('--valgrind must be either true or false.')

    conf.env.VALGRIND = conf.options.valgrind

    def add_option(option):
        conf.env.append_value('DFLAGS', option)

    if conf.env.COMPILER_D == 'dmd':
        add_option('-w')
        add_option('-ignore')
        add_option('-property')
        add_option('-gc')

        if conf.options.mode == 'debug':
            add_option('-debug')
        elif conf.options.mode == 'release':
            add_option('-release')
            add_option('-O')
            add_option('-inline')
        else:
            conf.fatal('--mode must be either debug or release.')
    elif conf.env.COMPILER_D == 'gdc':
        add_option('-Wall')
        add_option('-Werror')
        add_option('-fignore-unknown-pragmas')
        add_option('-fproperty')
        add_option('-g')
        add_option('-fdebug-c')

        if conf.options.mode == 'debug':
            add_option('-fdebug')
        elif conf.options.mode == 'release':
            add_option('-frelease')
            add_option('-O3')
        else:
            conf.fatal('--mode must be either debug or release.')

        conf.env.append_value('LINKFLAGS', '-lpthread')
    elif conf.env.COMPILER_D == 'ldc2':
        add_option('-w')
        add_option('-wi')
        add_option('-ignore')
        add_option('-property')
        add_option('-check-printf-calls')
        add_option('-gc')

        if conf.options.mode == 'debug':
            add_option('-d-debug')
        elif conf.options.mode == 'release':
            add_option('-release')
            add_option('-O3')
            add_option('--enable-inlining')
        else:
            conf.fatal('--mode must be either debug or release.')
    else:
        conf.fatal('Unsupported D compiler.')

    if conf.options.lp64 == 'true':
        add_option('-m64')
        conf.env.append_value('LINKFLAGS', '-m64')
    elif conf.options.lp64 == 'false':
        add_option('-m32')
        conf.env.append_value('LINKFLAGS', '-m32')
    else:
        conf.fatal('--lp64 must be either true or false.')

    conf.env.LIB_FFI = ['ffi']
    conf.env.LIB_GC = ['gc']

    if not Utils.unversioned_sys_platform().lower().endswith('bsd'):
        conf.env.LIB_DL = ['dl']

def build(bld):
    bld.recurse('libffi-d')
    bld.recurse('libgc-d')

    def search_paths(path):
        return [os.path.join(path, '*.d'), os.path.join(path, '**', '*.d')]

    includes = ['src', 'libffi-d', 'libgc-d']
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
    stlib('optimizer', 'mci.optimizer')
    stlib('linker', 'mci.linker')
    stlib('debugger', 'mci.debugger')
    stlib('vm', 'mci.vm')
    stlib('compiler', 'mci.compiler')
    stlib('jit', 'mci.jit')

    deps = ['mci.jit',
            'mci.compiler',
            'mci.vm',
            'mci.debugger',
            'mci.linker',
            'mci.optimizer',
            'mci.verifier',
            'mci.assembler',
            'mci.core',
            'ffi-d',
            'gc-d',
            'FFI',
            'GC']

    if not Utils.unversioned_sys_platform().lower().endswith('bsd'):
        deps += ['DL']

    program('cli', 'mci', deps)

    if bld.env.COMPILER_D == 'dmd':
        unittest = '-unittest'
    elif bld.env.COMPILER_D == 'gdc':
        unittest = '-funittest'
    else:
        bld.fatal('Unsupported D compiler.')

    program('tester', 'mci.tester', deps, unittest, None)

    if bld.env.VIM:
        bld.install_files(os.path.join(bld.env.VIM, 'syntax'), os.path.join('syntax', 'vim', 'syntax', 'ial.vim'))
        bld.install_files(os.path.join(bld.env.VIM, 'ftdetect'), os.path.join('syntax', 'vim', 'ftdetect', 'ial.vim'))

    if bld.env.GTKSOURCEVIEW:
        bld.install_files(bld.env.GTKSOURCEVIEW, os.path.join('syntax', 'gtksourceview', 'ial.lang'))

def _run_shell(dir, ctx, args):
    cwd = os.getcwd()
    os.chdir(dir)

    code = subprocess.Popen(args, shell = True).wait()

    if code != 0:
        ctx.fatal(str(args) + ' exited with: ' + str(code))

    os.chdir(cwd)

def unittest(ctx):
    '''runs the unit test suite'''

    if 'darwin' in Utils.unversioned_sys_platform():
        _run_shell(OUT, ctx, './mci.tester')
    else:
        _run_shell(OUT, ctx, 'gdb --command=' + os.path.join(os.pardir, 'mci.gdb') + ' mci.tester')

    if ctx.env.VALGRIND == 'true':
        cmd = 'valgrind'
        cmd += ' --suppressions=' + os.path.join(os.pardir, 'mci.valgrind')
        cmd += ' --leak-check=full'
        cmd += ' --track-fds=yes'
        cmd += ' --num-callers=50'
        cmd += ' --show-reachable=yes'
        cmd += ' --undef-value-errors=no'
        cmd += ' --error-exitcode=1'
        cmd += ' ' + os.path.join(os.curdir, 'mci.tester')

        _run_shell(OUT, ctx, cmd)

class UnitTestContext(Build.BuildContext):
    cmd = 'unittest'
    fun = 'unittest'

def test(ctx):
    '''runs the infrastructure tests'''

    def run_test(parent, sub):
        _run_shell('tests', ctx, 'rdmd tester.d {0}'.format(os.path.join(parent, sub)))

    run_test('assembler', 'pass')
    run_test('assembler', 'fail')
    run_test('disassembler', 'pass')
    run_test('verifier', 'pass')
    run_test('verifier', 'fail')

class TestContext(Build.BuildContext):
    cmd = 'test'
    fun = 'test'

def docs(ctx):
    '''builds the documentation'''

    def build_docs(targets):
        for x in targets:
            _run_shell('docs', ctx, 'make ' + x)

    build_docs(['html',
                'dirhtml',
                'singlehtml',
                'latexpdf',
                'text',
                'man',
                'changes',
                'linkcheck'])

def ddoc(ctx):
    '''builds the D source documentation'''

    dir = os.path.join('docs', '_ddoc')

    try:
        os.makedirs(dir)
    except os.error:
        pass

    doc = os.path.join(os.pardir, 'bootdoc')

    cmd = 'rdmd ' + os.path.join(doc, 'generate.d')
    cmd += ' --parallel'
    cmd += ' --verbose'
    cmd += ' --extra=index.d'
    cmd += ' --bootdoc=' + doc
    cmd += ' --output=_ddoc'
    cmd += ' ' + os.path.join(os.pardir, 'src')
    cmd += ' -I' + os.path.join(os.pardir, 'libffi-d')
    cmd += ' -I' + os.path.join(os.pardir, 'libgc-d')

    _run_shell('docs', ctx, cmd)

    bddir = os.path.join(dir, 'bootDoc')

    shutil.rmtree(bddir, True)
    shutil.copytree('bootdoc', bddir)
    shutil.rmtree(os.path.join(bddir, '.git'), True)

def dist(dst):
    '''makes a tarball for redistributing the sources'''

    with open('.gitignore', 'r') as f:
        dst.excl = ' '.join(l.strip() for l in f if l.strip())
