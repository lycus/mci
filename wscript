#!/usr/bin/env python

import glob, os, shutil, subprocess
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

    def add_option(option, flags = 'DFLAGS'):
        if option not in conf.env[flags]:
            conf.env.append_value(flags, option)

    if conf.env.COMPILER_D == 'dmd':
        add_option('-w')
        add_option('-ignore')
        add_option('-property')
        add_option('-g')

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
        add_option('-ggdb')

        if conf.options.mode == 'debug':
            add_option('-fdebug')
        elif conf.options.mode == 'release':
            add_option('-frelease')
            add_option('-O3')
        else:
            conf.fatal('--mode must be either debug or release.')
    elif conf.env.COMPILER_D == 'ldc2':
        add_option('-w')
        add_option('-wi')
        add_option('-ignore')
        add_option('-property')
        add_option('-check-printf-calls')
        add_option('-g')

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

    if Utils.unversioned_sys_platform().lower() == 'freebsd':
        conf.env.LIB_GC = ['gc-threaded']
    else:
        conf.env.LIB_GC = ['gc']

    if not Utils.unversioned_sys_platform().lower().endswith('bsd'):
        conf.env.LIB_DL = ['dl']

def build(bld):
    bld.recurse('libffi-d')
    bld.recurse('libgc-d')

    def search_paths(path):
        return [os.path.join(path, '*.d'),
                os.path.join(path, '**', '*.d')]

    includes = ['src',
                'libffi-d',
                'libgc-d']

    def glob(path):
        return bld.path.ant_glob(search_paths(path))

    def stlib(sources, target, dflags = [], install = '${PREFIX}/lib'):
        bld.stlib(source = sources,
                  target = target,
                  includes = includes,
                  install_path = install,
                  dflags = dflags)

    def program(sources, target, deps, dflags = [], install = '${PREFIX}/bin'):
        bld.program(source = sources,
                    target = target,
                    use = deps,
                    includes = includes,
                    install_path = install,
                    dflags = dflags)

    def src_path(dir):
        return os.path.join('src', 'mci', dir)

    stlib(glob(src_path('core')), 'mci.core')
    stlib(glob(src_path('assembler')), 'mci.assembler')
    stlib(glob(src_path('verifier')), 'mci.verifier')
    stlib(glob(src_path('optimizer')), 'mci.optimizer')
    stlib(glob(src_path('linker')), 'mci.linker')
    stlib(glob(src_path('debugger')), 'mci.debugger')
    stlib(glob(src_path('vm')), 'mci.vm')
    stlib(glob(src_path('interpreter')), 'mci.interpreter')
    stlib(glob(src_path('compiler')), 'mci.compiler')
    stlib(glob(src_path('jit')), 'mci.jit')
    stlib(glob(src_path('aot')), 'mci.aot')

    deps = ['mci.aot',
            'mci.jit',
            'mci.compiler',
            'mci.interpreter',
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

    program(glob(src_path('cli')), 'mci', deps)

    if bld.env.COMPILER_D == 'dmd':
        unittest = '-unittest'
    elif bld.env.COMPILER_D == 'gdc':
        unittest = '-funittest'
    elif bld.env.COMPILER_D == 'ldc2':
        unittest = '-unittest'
    else:
        bld.fatal('Unsupported D compiler.')

    program(glob(src_path('tester')), 'mci.tester', deps, unittest, None)
    program(os.path.join('tests', 'tester.d'), 'tester', deps, install = None)
    program(os.path.join('bootdoc', 'generate.d'), 'generate', [], install = None)

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

    if ctx.env.VALGRIND == 'true':
        cmd = 'valgrind'
        cmd += ' --suppressions=' + os.path.join(os.pardir, 'mci.valgrind')
        cmd += ' --leak-check=full'
        cmd += ' --track-fds=yes'
        cmd += ' --num-callers=50'
        cmd += ' --show-reachable=yes'
        cmd += ' --undef-value-errors=no'
        cmd += ' --error-exitcode=1'
        cmd += ' --gen-suppressions=all'
        cmd += ' ' + os.path.join(os.curdir, 'mci.tester')

        _run_shell(OUT, ctx, cmd)
    else:
        _run_shell(OUT, ctx, './mci.tester')

class UnitTestContext(Build.BuildContext):
    cmd = 'unittest'
    fun = 'unittest'

def test(ctx):
    '''runs the infrastructure tests'''

    stats = [0, 0]

    def run_test(parent, sub):
        passes = 0
        failures = 0

        _run_shell('tests', ctx, '{0} {1}'.format(os.path.join(os.pardir, OUT, 'tester'),
                                                  os.path.join(parent, sub)))

        for file in glob.glob(os.path.join('tests', parent, sub, '*.out')):
            with open(file, 'r') as f:
                passes += int(f.readline())
                failures += int(f.readline())

        stats[0] = stats[0] + passes
        stats[1] = stats[1] + failures

    run_test('assembler', 'pass')
    run_test('assembler', 'fail')
    run_test('disassembler', 'pass')
    run_test('verifier', 'pass')
    run_test('verifier', 'fail')

    ctx.to_log('<<<<<<<<<<---------- Passes: {0} Failures: {1} ---------->>>>>>>>>>\n'.format(stats[0], stats[1]))

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

    if ctx.env.COMPILER_D == 'dmd':
        cmd = ' --dmd=dmd'
    elif ctx.env.COMPILER_D == 'gdc':
        cmd = ' --dmd=gdmd'
    elif ctx.env.COMPILER_D == 'ldc2':
        cmd = ' --dmd=ldmd2'
    else:
        ctx.fatal('Unsupported D compiler.')

    cmd += ' --parallel'
    cmd += ' --verbose'
    cmd += ' --extra=index.d'
    cmd += ' --bootdoc=' + os.path.join(os.pardir, 'bootdoc')
    cmd += ' --output=_ddoc'
    cmd += ' ' + os.path.join(os.pardir, 'src')
    cmd += ' -I' + os.path.join(os.pardir, 'libffi-d')
    cmd += ' -I' + os.path.join(os.pardir, 'libgc-d')

    if ctx.env.COMPILER_D == 'dmd':
        cmd += ' -version=MCI_Ddoc'
    elif ctx.env.COMPILER_D == 'gdc':
        cmd += ' -fversion=MCI_Ddoc'
    elif ctx.env.COMPILER_D == 'ldc2':
        cmd += ' -d-version=MCI_Ddoc'
    else:
        ctx.fatal('Unsupported D compiler.')

    _run_shell('docs', ctx, '{0} {1}'.format(os.path.join(os.pardir, OUT, 'generate'), cmd))

    bddir = os.path.join(dir, 'bootDoc')

    shutil.rmtree(bddir, True)
    shutil.copytree('bootdoc', bddir)

    git = os.path.join(bddir, '.git')

    try:
        shutil.rmtree(git)
    except:
        os.remove(git)

class DdocContext(Build.BuildContext):
    cmd = 'ddoc'
    fun = 'ddoc'

def dist(dst):
    '''makes a tarball for redistributing the sources'''

    with open('.gitignore', 'r') as f:
        dst.excl = ' '.join(l.strip() for l in f if l.strip())
        dst.excl = ' .git/* .gitignore .arcconfig'
