" Vim syntax file
" Language:      IAL (Intermediate Assembly Language)
" Maintainer:    The Lycus Foundation <http://lycus.org>
" File Names:    *.ial

if exists("b:current_syntax")
    finish
endif

setlocal iskeyword+=.

syn keyword ialType                     void int8 uint8 int16 uint16 int32 uint32 int64 uint64 int uint float32 float64
syn keyword ialDeclaration              type field function register block thread entry exit
syn keyword ialModifier                 instance static ssa pure nooptimize noinline align unwind
syn keyword ialConvention               cdecl stdcall
syn keyword ialInstruction              nop comment
syn keyword ialInstruction              load.i8 load.ui8 load.i16 load.ui16 load.i32 load.ui32 load.i64 load.ui64 load.f32 load.f64
syn keyword ialInstruction              load.i8a load.ui8a load.i16a load.ui16a load.i32a load.ui32a load.i64a load.ui64a load.f32a load.f64a
syn keyword ialInstruction              load.func load.null load.size load.align load.offset
syn keyword ialInstruction              copy
syn keyword ialInstruction              ari.add ari.sub ari.mul ari.div ari.rem ari.neg
syn keyword ialInstruction              bit.and bit.or bit.xor bit.neg
syn keyword ialInstruction              not shl shr rol ror
syn keyword ialInstruction              mem.alloc mem.new mem.free mem.salloc mem.snew mem.pin mem.unpin
syn keyword ialInstruction              mem.get mem.set mem.addr
syn keyword ialInstruction              array.get array.set array.addr array.len
syn keyword ialInstruction              array.ari.add array.ari.sub array.ari.mul array.ari.div array.ari.rem array.ari.neg
syn keyword ialInstruction              array.bit.or array.bit.xor array.bit.neg
syn keyword ialInstruction              array.not array.shl array.shr array.rol array.ror
syn keyword ialInstruction              array.conv
syn keyword ialInstruction              array.cmp.eq array.cmp.neq array.cmp.gt array.cmp.lt array.cmp.gteq array.cmp.lteq
syn keyword ialInstruction              field.get field.set field.addr
syn keyword ialInstruction              field.user.get field.user.set field.user.addr
syn keyword ialInstruction              field.static.get field.static.set field.static.addr
syn keyword ialInstruction              cmp.eq cmp.neq cmp.gt cmp.lt cmp.gteq cmp.lteq
syn keyword ialInstruction              arg.push arg.pop call call.tail call.indirect invoke invoke.tail invoke.indirect
syn keyword ialInstruction              jump jump.cond leave return dead phi raw ffi
syn keyword ialInstruction              eh.throw eh.rethrow eh.catch
syn keyword ialInstruction              conv
syn keyword ialInstruction              fence
syn keyword ialInstruction              tramp

syn keyword ialTodo                     contained TODO FIXME HACK UNDONE XXX NOTE
syn match   ialComment                  "//.*$" contains=ialTodo

syn match   ialSpecialChar1             contained +\\["\\']+
syn match   ialSpecialChar2             contained +\\['\\"]+
syn region  ialString1                  start=+"+ end=+"+ contains=ialSpecialChar1
syn region  ialString2                  start=+'+ end=+'+ contains=ialSpecialChar2
syn match   ialNumber                   "\<\(0[xX]\x\+\|\d\+\)\=\>"
syn match   ialNumber                   "\<\(\d\+\.\)\=\d\+\([eE][-+]\=\d\+\)\=\>"

hi def link ialType                     Type
hi def link ialDeclaration              Conditional
hi def link ialModifier                 PreProc
hi def link ialConvention               PreProc
hi def link ialInstruction              Type

hi def link ialTodo                     Todo
hi def link ialComment                  Constant

hi def link ialString1                  String
hi def link ialString2                  String
hi def link ialSpecialChar1             SpecialChar
hi def link ialSpecialChar2             SpecialChar
hi def link ialNumber                   Number

let b:current_syntax = "ial"
