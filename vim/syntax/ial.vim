" Vim syntax file
" Language:      IAL (Intermediate Assembly Language)
" Maintainer:    The Lycus Foundation <http://lycus.org>
" File Names:    *.ial

if exists("b:current_syntax")
    finish
endif

setlocal iskeyword+=.

syn keyword ialType                     void int8 uint8 int16 uint16 int32 uint32 int64 uint64 int uint float32 float64
syn keyword ialDeclaration              type field function register block
syn keyword ialModifier                 instance static pure nooptimize noinline nocallinline align unwind
syn keyword ialConvention               cdecl stdcall
syn keyword ialInstruction              nop comment dead load.i8 load.ui8 load.i16 load.ui16 load.i32 load.ui32
syn keyword ialInstruction              load.i64 load.ui64 load.f32 load.f64 load.i8a load.ui8a load.i16a
syn keyword ialInstruction              load.ui16a load.i32a load.ui32a load.i64a load.ui64a load.f32a load.f64a
syn keyword ialInstruction              load.func load.null load.size load.align load.offset ari.add ari.sub ari.mul
syn keyword ialInstruction              ari.div ari.rem ari.neg bit.and bit.or bit.xor bit.neg not shl shr conv mem.alloc
syn keyword ialInstruction              mem.new mem.free mem.salloc mem.pin mem.unpin mem.get mem.set mem.addr
syn keyword ialInstruction              array.get array.set array.addr array.len field.get field.set field.addr
syn keyword ialInstruction              field.gget field.gset field.gaddr cmp.eq cmp.neq cmp.gt cmp.lt cmp.gteq cmp.lteq
syn keyword ialInstruction              arg.push arg.pop invoke invoke.tail invoke.indirect call call.tail call.indirect
syn keyword ialInstruction              raw ffi jump jump.cond leave return phi ex.throw ex.try ex.handle ex.end

syn keyword ialTodo                     contained TODO FIXME HACK UNDONE XXX NOTE
syn match   ialComment                  "//.*$" contains=ialTodo

syn match   ialSpecialChar1             contained +\\["\\']+
syn match   ialSpecialChar2             contained +\\['\\"]+
syn region  ialString1                  start=+"+ end=+"+ contains=ialSpecialChar1
syn region  ialString2                  start=+'+ end=+'+ contains=ialSpecialChar2
syn match   ialNumber                   "\<\(0[x]\x\+\|\d\+\)\=\>"
syn match   ialNumber                   "\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\="
syn match   ialNumber                   "\<\d\+[eE][-+]\=\d\+\>"
syn match   ialNumber                   "\<\d\+\([eE][-+]\=\d\+\)\>"

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
hi def link ialCharacter                Character
hi def link ialSpecialChar              SpecialChar
hi def link ialNumber                   Number

let b:current_syntax = "ial"
