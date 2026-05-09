	.arch armv8-a
	.file	"main.cc"
	.text
#APP
	.globl _ZSt21ios_base_library_initv
#NO_APP
	.section	.text._ZNKSt5ctypeIcE8do_widenEc,"axG",@progbits,_ZNKSt5ctypeIcE8do_widenEc,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNKSt5ctypeIcE8do_widenEc
	.type	_ZNKSt5ctypeIcE8do_widenEc, %function
_ZNKSt5ctypeIcE8do_widenEc:
.LFB1768:
	.cfi_startproc
	mov	w0, w1
	ret
	.cfi_endproc
.LFE1768:
	.size	_ZNKSt5ctypeIcE8do_widenEc, .-_ZNKSt5ctypeIcE8do_widenEc
	.section	.text._ZN7hnswlib17BaseFilterFunctorclEm,"axG",@progbits,_ZN7hnswlib17BaseFilterFunctorclEm,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib17BaseFilterFunctorclEm
	.type	_ZN7hnswlib17BaseFilterFunctorclEm, %function
_ZN7hnswlib17BaseFilterFunctorclEm:
.LFB3463:
	.cfi_startproc
	mov	w0, 1
	ret
	.cfi_endproc
.LFE3463:
	.size	_ZN7hnswlib17BaseFilterFunctorclEm, .-_ZN7hnswlib17BaseFilterFunctorclEm
	.text
	.align	2
	.p2align 5,,15
	.type	_ZN7hnswlibL20InnerProductDistanceEPKvS1_S1_, %function
_ZN7hnswlibL20InnerProductDistanceEPKvS1_S1_:
.LFB3505:
	.cfi_startproc
	ldr	x4, [x2]
	cbz	x4, .L7
	movi	v31.2s, #0
	mov	w3, 0
	mov	x2, 0
	.p2align 5,,15
.L6:
	ldr	s30, [x0, x2, lsl 2]
	ldr	s1, [x1, x2, lsl 2]
	add	w2, w3, 1
	mov	x3, x2
	fmadd	s31, s30, s1, s31
	cmp	x4, x2
	bhi	.L6
	fmov	s29, 1.0e+0
	fsub	s0, s29, s31
	ret
	.p2align 2,,3
.L7:
	fmov	s0, 1.0e+0
	ret
	.cfi_endproc
.LFE3505:
	.size	_ZN7hnswlibL20InnerProductDistanceEPKvS1_S1_, .-_ZN7hnswlibL20InnerProductDistanceEPKvS1_S1_
	.section	.text._ZN7hnswlib17InnerProductSpace13get_data_sizeEv,"axG",@progbits,_ZN7hnswlib17InnerProductSpace13get_data_sizeEv,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib17InnerProductSpace13get_data_sizeEv
	.type	_ZN7hnswlib17InnerProductSpace13get_data_sizeEv, %function
_ZN7hnswlib17InnerProductSpace13get_data_sizeEv:
.LFB3509:
	.cfi_startproc
	ldr	x0, [x0, 16]
	ret
	.cfi_endproc
.LFE3509:
	.size	_ZN7hnswlib17InnerProductSpace13get_data_sizeEv, .-_ZN7hnswlib17InnerProductSpace13get_data_sizeEv
	.section	.text._ZN7hnswlib17InnerProductSpace13get_dist_funcEv,"axG",@progbits,_ZN7hnswlib17InnerProductSpace13get_dist_funcEv,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib17InnerProductSpace13get_dist_funcEv
	.type	_ZN7hnswlib17InnerProductSpace13get_dist_funcEv, %function
_ZN7hnswlib17InnerProductSpace13get_dist_funcEv:
.LFB3510:
	.cfi_startproc
	ldr	x0, [x0, 8]
	ret
	.cfi_endproc
.LFE3510:
	.size	_ZN7hnswlib17InnerProductSpace13get_dist_funcEv, .-_ZN7hnswlib17InnerProductSpace13get_dist_funcEv
	.section	.text._ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv,"axG",@progbits,_ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv
	.type	_ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv, %function
_ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv:
.LFB3511:
	.cfi_startproc
	add	x0, x0, 24
	ret
	.cfi_endproc
.LFE3511:
	.size	_ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv, .-_ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv
	.section	.text._ZN7hnswlib17InnerProductSpaceD2Ev,"axG",@progbits,_ZN7hnswlib17InnerProductSpaceD5Ev,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib17InnerProductSpaceD2Ev
	.type	_ZN7hnswlib17InnerProductSpaceD2Ev, %function
_ZN7hnswlib17InnerProductSpaceD2Ev:
.LFB3513:
	.cfi_startproc
	ret
	.cfi_endproc
.LFE3513:
	.size	_ZN7hnswlib17InnerProductSpaceD2Ev, .-_ZN7hnswlib17InnerProductSpaceD2Ev
	.weak	_ZN7hnswlib17InnerProductSpaceD1Ev
	.set	_ZN7hnswlib17InnerProductSpaceD1Ev,_ZN7hnswlib17InnerProductSpaceD2Ev
	.section	.text._ZN7hnswlib17InnerProductSpaceD0Ev,"axG",@progbits,_ZN7hnswlib17InnerProductSpaceD5Ev,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib17InnerProductSpaceD0Ev
	.type	_ZN7hnswlib17InnerProductSpaceD0Ev, %function
_ZN7hnswlib17InnerProductSpaceD0Ev:
.LFB3515:
	.cfi_startproc
	b	_ZdlPv
	.cfi_endproc
.LFE3515:
	.size	_ZN7hnswlib17InnerProductSpaceD0Ev, .-_ZN7hnswlib17InnerProductSpaceD0Ev
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"void hnswlib::HierarchicalNSW<dist_t>::unmarkDeletedInternal(hnswlib::tableint) [with dist_t = float; hnswlib::tableint = unsigned int]"
	.align	3
.LC1:
	.string	"hnswlib/hnswlib/hnswalg.h"
	.align	3
.LC2:
	.string	"internalId < cur_element_count"
	.section	.text.unlikely,"ax",@progbits
	.align	2
	.type	_ZN7hnswlib15HierarchicalNSWIfE21unmarkDeletedInternalEj.part.0, %function
_ZN7hnswlib15HierarchicalNSWIfE21unmarkDeletedInternalEj.part.0:
.LFB12804:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	adrp	x3, .LC0
	adrp	x1, .LC1
	mov	x29, sp
	adrp	x0, .LC2
	add	x3, x3, :lo12:.LC0
	add	x1, x1, :lo12:.LC1
	add	x0, x0, :lo12:.LC2
	mov	w2, 915
	bl	__assert_fail
	.cfi_endproc
.LFE12804:
	.size	_ZN7hnswlib15HierarchicalNSWIfE21unmarkDeletedInternalEj.part.0, .-_ZN7hnswlib15HierarchicalNSWIfE21unmarkDeletedInternalEj.part.0
	.text
	.align	2
	.p2align 5,,15
	.type	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfmESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0, %function
_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfmESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0:
.LFB12814:
	.cfi_startproc
	cmp	x1, x2
	ble	.L30
	sub	x4, x1, #1
	add	x4, x4, x4, lsr 63
	asr	x4, x4, 1
.L21:
	lsl	x5, x4, 4
	add	x6, x0, x4, lsl 4
	ldr	s31, [x0, x5]
	fcmpe	s31, s0
	bmi	.L26
	bgt	.L30
	ldr	x5, [x6, 8]
	cmp	x5, x3
	bcs	.L30
.L24:
	lsl	x7, x1, 4
	add	x1, x0, x1, lsl 4
	str	s31, [x0, x7]
	str	x5, [x1, 8]
	sub	x1, x4, #1
	add	x5, x1, x1, lsr 63
	mov	x1, x4
	cmp	x2, x4
	bge	.L18
	asr	x4, x5, 1
	b	.L21
	.p2align 2,,3
.L30:
	add	x6, x0, x1, lsl 4
.L18:
	str	s0, [x6]
	str	x3, [x6, 8]
	ret
	.p2align 2,,3
.L26:
	ldr	x5, [x6, 8]
	b	.L24
	.cfi_endproc
.LFE12814:
	.size	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfmESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0, .-_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfmESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	.align	2
	.p2align 5,,15
	.type	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE5eraseERKj.isra.0, %function
_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE5eraseERKj.isra.0:
.LFB12815:
	.cfi_startproc
	mov	x4, x0
	ldr	x0, [x0, 24]
	cbz	x0, .L32
	ldr	w9, [x1]
	ldp	x3, x1, [x4]
	uxtw	x0, w9
	udiv	x2, x0, x1
	msub	x2, x2, x1, x0
	ubfiz	x8, x2, 3, 32
	ldr	x3, [x3, x8]
	cbz	x3, .L62
	ldr	x5, [x3]
	ldr	w6, [x5, 8]
	cmp	w9, w6
	beq	.L37
.L63:
	ldr	x0, [x5]
	cbz	x0, .L59
	ldr	w6, [x0, 8]
	mov	x3, x5
	uxtw	x7, w6
	udiv	x5, x7, x1
	msub	x5, x5, x1, x7
	cmp	x5, x2
	bne	.L59
	mov	x5, x0
	cmp	w9, w6
	bne	.L63
.L37:
	ldr	x0, [x3]
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	ldr	x6, [x4]
	ldr	x5, [x0]
	add	x9, x6, x8
	ldr	x7, [x6, x8]
	cmp	x3, x7
	bne	.L39
.L66:
	cbz	x5, .L61
	ldr	w8, [x5, 8]
	udiv	x7, x8, x1
	msub	x1, x7, x1, x8
	cmp	x2, x1
	beq	.L42
	str	x3, [x6, w1, uxtw 3]
.L61:
	str	xzr, [x9]
	ldr	x5, [x0]
	b	.L42
	.p2align 2,,3
.L32:
	.cfi_def_cfa_offset 0
	.cfi_restore 29
	.cfi_restore 30
	ldr	x2, [x4, 16]
	cbz	x2, .L59
	ldr	w5, [x1]
	add	x3, x4, 16
	b	.L36
	.p2align 2,,3
.L65:
	ldr	x1, [x2]
	mov	x3, x2
	cbz	x1, .L64
	mov	x2, x1
.L36:
	ldr	w0, [x2, 8]
	cmp	w5, w0
	bne	.L65
	ldr	x0, [x3]
	ldr	x1, [x4, 8]
	ldr	w5, [x0, 8]
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	udiv	x2, x5, x1
	ldr	x6, [x4]
	msub	x2, x2, x1, x5
	ldr	x5, [x0]
	ubfiz	x8, x2, 3, 32
	add	x9, x6, x8
	ldr	x7, [x6, x8]
	cmp	x3, x7
	beq	.L66
.L39:
	cbz	x5, .L42
	ldr	w8, [x5, 8]
	udiv	x7, x8, x1
	msub	x1, x7, x1, x8
	cmp	x2, x1
	beq	.L42
	str	x3, [x6, w1, uxtw 3]
	ldr	x5, [x0]
.L42:
	str	x5, [x3]
	str	x4, [sp, 24]
	bl	_ZdlPv
	ldr	x4, [sp, 24]
	ldr	x0, [x4, 24]
	sub	x0, x0, #1
	str	x0, [x4, 24]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L64:
	ret
.L62:
	ret
.L59:
	ret
	.cfi_endproc
.LFE12815:
	.size	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE5eraseERKj.isra.0, .-_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE5eraseERKj.isra.0
	.align	2
	.p2align 5,,15
	.type	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0, %function
_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0:
.LFB12819:
	.cfi_startproc
	sbfx	x4, x3, 0, 32
	lsr	x3, x3, 32
	fmov	d30, x4
	cmp	x1, x2
	ble	.L81
	sub	x4, x1, #1
	add	x4, x4, x4, lsr 63
	asr	x4, x4, 1
.L72:
	lsl	x5, x4, 3
	add	x6, x0, x4, lsl 3
	ldr	s31, [x0, x5]
	fcmpe	s30, s31
	bgt	.L77
	bmi	.L81
	ldr	w5, [x6, 4]
	cmp	w3, w5
	bls	.L81
.L75:
	lsl	x7, x1, 3
	add	x1, x0, x1, lsl 3
	str	s31, [x0, x7]
	str	w5, [x1, 4]
	sub	x1, x4, #1
	add	x5, x1, x1, lsr 63
	mov	x1, x4
	cmp	x2, x4
	bge	.L69
	asr	x4, x5, 1
	b	.L72
	.p2align 2,,3
.L81:
	add	x6, x0, x1, lsl 3
.L69:
	str	s30, [x6]
	str	w3, [x6, 4]
	ret
	.p2align 2,,3
.L77:
	ldr	w5, [x6, 4]
	b	.L75
	.cfi_endproc
.LFE12819:
	.size	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0, .-_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	.align	2
	.p2align 5,,15
	.type	_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0, %function
_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0:
.LFB12820:
	.cfi_startproc
	sub	x9, x2, #1
	mov	x11, x1
	add	x9, x9, x9, lsr 63
	asr	x9, x9, 1
	cmp	x1, x9
	bge	.L83
	mov	x4, x1
	b	.L87
	.p2align 2,,3
.L91:
	mov	w5, w7
.L86:
	lsl	x6, x4, 3
	add	x4, x0, x4, lsl 3
	str	s30, [x0, x6]
	str	w5, [x4, 4]
	cmp	x1, x9
	bge	.L83
.L92:
	mov	x4, x1
.L87:
	add	x5, x4, 1
	lsl	x6, x5, 1
	lsl	x8, x5, 4
	sub	x1, x6, #1
	add	x5, x0, x5, lsl 4
	lsl	x7, x1, 3
	ldr	s31, [x0, x8]
	add	x10, x0, x1, lsl 3
	ldr	s30, [x0, x7]
	fcmpe	s30, s31
	bgt	.L93
	ldr	w5, [x5, 4]
	bmi	.L90
	ldr	w7, [x10, 4]
	cmp	w5, w7
	bcc	.L91
.L90:
	fmov	s30, s31
	mov	x1, x6
	lsl	x6, x4, 3
	add	x4, x0, x4, lsl 3
	str	s30, [x0, x6]
	str	w5, [x4, 4]
	cmp	x1, x9
	blt	.L92
.L83:
	tbnz	x2, 0, .L88
	sub	x2, x2, #2
	cmp	x1, x2, asr 1
	beq	.L95
.L88:
	mov	x2, x11
	b	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	.p2align 2,,3
.L93:
	ldr	w5, [x10, 4]
	b	.L86
	.p2align 2,,3
.L95:
	lsl	x2, x1, 1
	lsl	x5, x1, 3
	add	x4, x0, x1, lsl 3
	add	x1, x2, 1
	lsl	x6, x1, 3
	add	x2, x0, x1, lsl 3
	ldr	s31, [x0, x6]
	ldr	w2, [x2, 4]
	str	s31, [x0, x5]
	str	w2, [x4, 4]
	mov	x2, x11
	b	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	.cfi_endproc
.LFE12820:
	.size	_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0, .-_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0
	.align	2
	.p2align 5,,15
	.type	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_M_constructIPKcEEvT_S8_St20forward_iterator_tag.isra.0, %function
_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_M_constructIPKcEEvT_S8_St20forward_iterator_tag.isra.0:
.LFB12821:
	.cfi_startproc
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	mov	x5, x1
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	mov	x4, x0
	stp	x29, x30, [sp, 48]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 48
	ldr	x3, [x1]
	str	x3, [sp, 40]
	mov	x3, 0
	sub	x3, x2, x5
	str	x3, [sp, 32]
	cmp	x3, 15
	bhi	.L106
	ldr	x0, [x0]
	cmp	x3, 1
	bne	.L99
	ldrb	w1, [x5]
	strb	w1, [x0]
	ldr	x0, [x4]
	ldr	x3, [sp, 32]
.L100:
	str	x3, [x4, 8]
	strb	wzr, [x0, x3]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 40]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L107
	ldp	x29, x30, [sp, 48]
	add	sp, sp, 64
	.cfi_remember_state
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L99:
	.cfi_restore_state
	cbz	x3, .L100
	b	.L98
	.p2align 2,,3
.L106:
	add	x1, sp, 32
	mov	x2, 0
	stp	x3, x0, [sp, 8]
	str	x5, [sp, 24]
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm
	ldp	x3, x4, [sp, 8]
	ldp	x5, x1, [sp, 24]
	str	x0, [x4]
	str	x1, [x4, 16]
.L98:
	mov	x2, x3
	mov	x1, x5
	str	x4, [sp, 8]
	bl	memcpy
	ldr	x4, [sp, 8]
	ldr	x3, [sp, 32]
	ldr	x0, [x4]
	b	.L100
.L107:
	bl	__stack_chk_fail
	.cfi_endproc
.LFE12821:
	.size	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_M_constructIPKcEEvT_S8_St20forward_iterator_tag.isra.0, .-_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_M_constructIPKcEEvT_S8_St20forward_iterator_tag.isra.0
	.align	2
	.p2align 5,,15
	.type	_ZNSt8__detail9_Map_baseImSt4pairIKmjESaIS3_ENS_10_Select1stESt8equal_toImESt4hashImENS_18_Mod_range_hashingENS_20_Default_ranged_hashENS_20_Prime_rehash_policyENS_17_Hashtable_traitsILb0ELb0ELb1EEELb1EEixERS2_.isra.0, %function
_ZNSt8__detail9_Map_baseImSt4pairIKmjESaIS3_ENS_10_Select1stESt8equal_toImESt4hashImENS_18_Mod_range_hashingENS_20_Default_ranged_hashENS_20_Prime_rehash_policyENS_17_Hashtable_traitsILb0ELb0ELb1EEELb1EEixERS2_.isra.0:
.LFB12822:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12822
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	mov	x20, x1
	mov	x19, x0
	stp	x21, x22, [sp, 32]
	ldp	x2, x1, [x0]
	udiv	x0, x20, x1
	msub	x0, x0, x1, x20
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	lsl	x22, x0, 3
	ldr	x5, [x2, x22]
	cbz	x5, .L109
	ldr	x4, [x5]
	ldr	x2, [x4, 8]
	cmp	x20, x2
	beq	.L110
.L151:
	ldr	x3, [x4]
	cbz	x3, .L109
	ldr	x2, [x3, 8]
	mov	x5, x4
	udiv	x4, x2, x1
	msub	x4, x4, x1, x2
	cmp	x0, x4
	bne	.L109
	mov	x4, x3
	cmp	x20, x2
	bne	.L151
.L110:
	ldr	x2, [x5]
	add	x0, x2, 16
	cbz	x2, .L109
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 80
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L109:
	.cfi_restore_state
	mov	x0, 24
	str	x23, [sp, 48]
	.cfi_offset 23, -32
	str	x1, [sp, 64]
.LEHB0:
	bl	_Znwm
.LEHE0:
	stp	xzr, x20, [x0]
	mov	x21, x0
	mov	x3, 1
	ldr	x2, [x19, 24]
	str	wzr, [x21, 16]
	ldr	x1, [sp, 64]
	ldr	x0, [x19, 40]
	mov	x23, x0
	add	x0, x19, 32
.LEHB1:
	bl	_ZNKSt8__detail20_Prime_rehash_policy14_M_need_rehashEmmm
	mov	x5, x1
	tbnz	x0, 0, .L113
	ldr	x7, [x19]
	add	x0, x7, x22
	ldr	x1, [x7, x22]
	cbz	x1, .L126
.L156:
	ldr	x0, [x1]
	str	x0, [x21]
	ldr	x0, [x7, x22]
	str	x21, [x0]
.L127:
	ldr	x0, [x19, 24]
	ldr	x23, [sp, 48]
	.cfi_remember_state
	.cfi_restore 23
	add	x0, x0, 1
	str	x0, [x19, 24]
	add	x0, x21, 16
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L113:
	.cfi_restore_state
	cmp	x1, 1
	beq	.L152
	mov	x0, 1152921504606846975
	cmp	x1, x0
	bhi	.L153
	lsl	x22, x1, 3
	str	x1, [sp, 72]
	mov	x0, x22
	bl	_Znwm
	mov	x2, x22
	mov	w1, 0
	str	x0, [sp, 64]
	bl	memset
	ldp	x7, x5, [sp, 64]
	add	x9, x19, 48
.L116:
	add	x0, x19, 16
	mov	x8, 0
	ldr	x3, [x19, 16]
	str	xzr, [x19, 16]
.L150:
	cbz	x3, .L154
.L119:
	ldr	x1, [x3, 8]
	mov	x2, x3
	ldr	x3, [x3]
	udiv	x4, x1, x5
	msub	x4, x4, x5, x1
	lsl	x1, x4, 3
	ldr	x6, [x7, x1]
	cbz	x6, .L155
	ldr	x4, [x6]
	str	x4, [x2]
	ldr	x1, [x7, x1]
	str	x2, [x1]
	cbnz	x3, .L119
.L154:
	ldr	x0, [x19]
	cmp	x0, x9
	beq	.L120
	stp	x7, x5, [sp, 64]
	bl	_ZdlPv
	ldp	x7, x5, [sp, 64]
.L120:
	stp	x7, x5, [x19]
	udiv	x22, x20, x5
	msub	x22, x22, x5, x20
	lsl	x22, x22, 3
	add	x0, x7, x22
	ldr	x1, [x7, x22]
	cbnz	x1, .L156
.L126:
	ldr	x1, [x19, 16]
	str	x1, [x21]
	str	x21, [x19, 16]
	cbz	x1, .L128
	ldr	x3, [x1, 8]
	ldr	x2, [x19, 8]
	udiv	x1, x3, x2
	msub	x1, x1, x2, x3
	str	x21, [x7, x1, lsl 3]
.L128:
	add	x1, x19, 16
	str	x1, [x0]
	b	.L127
	.p2align 2,,3
.L155:
	ldr	x6, [x19, 16]
	str	x6, [x2]
	str	x2, [x19, 16]
	str	x0, [x7, x1]
	ldr	x1, [x2]
	cbz	x1, .L123
	str	x2, [x7, x8, lsl 3]
.L123:
	mov	x8, x4
	b	.L150
.L153:
	mov	x0, 2305843009213693951
	cmp	x1, x0
	bls	.L118
	bl	_ZSt28__throw_bad_array_new_lengthv
.L152:
	mov	x9, x19
	str	xzr, [x9, 48]!
	mov	x7, x9
	b	.L116
.L118:
	bl	_ZSt17__throw_bad_allocv
.LEHE1:
.L132:
	str	x23, [x19, 40]
	mov	x20, x0
	mov	x0, x21
	bl	_ZdlPv
	mov	x0, x20
.LEHB2:
	bl	_Unwind_Resume
.LEHE2:
	.cfi_endproc
.LFE12822:
	.section	.gcc_except_table,"a",@progbits
.LLSDA12822:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12822-.LLSDACSB12822
.LLSDACSB12822:
	.uleb128 .LEHB0-.LFB12822
	.uleb128 .LEHE0-.LEHB0
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB1-.LFB12822
	.uleb128 .LEHE1-.LEHB1
	.uleb128 .L132-.LFB12822
	.uleb128 0
	.uleb128 .LEHB2-.LFB12822
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
.LLSDACSE12822:
	.text
	.size	_ZNSt8__detail9_Map_baseImSt4pairIKmjESaIS3_ENS_10_Select1stESt8equal_toImESt4hashImENS_18_Mod_range_hashingENS_20_Default_ranged_hashENS_20_Prime_rehash_policyENS_17_Hashtable_traitsILb0ELb0ELb1EEELb1EEixERS2_.isra.0, .-_ZNSt8__detail9_Map_baseImSt4pairIKmjESaIS3_ENS_10_Select1stESt8equal_toImESt4hashImENS_18_Mod_range_hashingENS_20_Default_ranged_hashENS_20_Prime_rehash_policyENS_17_Hashtable_traitsILb0ELb0ELb1EEELb1EEixERS2_.isra.0
	.align	2
	.p2align 5,,15
	.type	_ZNSt8_Rb_treeIjjSt9_IdentityIjESt4lessIjESaIjEE8_M_eraseEPSt13_Rb_tree_nodeIjE.isra.0, %function
_ZNSt8_Rb_treeIjjSt9_IdentityIjESt4lessIjESaIjEE8_M_eraseEPSt13_Rb_tree_nodeIjE.isra.0:
.LFB12827:
	.cfi_startproc
	cbz	x0, .L218
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	stp	x23, x24, [sp, 48]
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	mov	x23, x0
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
.L175:
	ldr	x24, [x23, 24]
	cbz	x24, .L159
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -56
	.cfi_offset 21, -64
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -24
	.cfi_offset 25, -32
.L174:
	ldr	x25, [x24, 24]
	cbz	x25, .L160
.L173:
	ldr	x26, [x25, 24]
	cbz	x26, .L161
.L172:
	ldr	x19, [x26, 24]
	cbz	x19, .L162
.L171:
	ldr	x21, [x19, 24]
	cbz	x21, .L163
	str	x27, [sp, 80]
	.cfi_offset 27, -16
.L170:
	ldr	x27, [x21, 24]
	cbz	x27, .L164
.L169:
	ldr	x20, [x27, 24]
	cbz	x20, .L165
.L168:
	ldr	x22, [x20, 24]
	cbz	x22, .L166
.L167:
	ldr	x0, [x22, 24]
	bl	_ZNSt8_Rb_treeIjjSt9_IdentityIjESt4lessIjESaIjEE8_M_eraseEPSt13_Rb_tree_nodeIjE.isra.0
	mov	x0, x22
	ldr	x22, [x22, 16]
	bl	_ZdlPv
	cbnz	x22, .L167
.L166:
	ldr	x22, [x20, 16]
	mov	x0, x20
	bl	_ZdlPv
	cbz	x22, .L165
	mov	x20, x22
	b	.L168
.L219:
	ldr	x27, [sp, 80]
	.cfi_restore 27
.L163:
	mov	x0, x19
	ldr	x20, [x19, 16]
	bl	_ZdlPv
	cbz	x20, .L162
	mov	x19, x20
	b	.L171
	.p2align 2,,3
.L164:
	.cfi_offset 27, -16
	ldr	x20, [x21, 16]
	mov	x0, x21
	bl	_ZdlPv
	cbz	x20, .L219
	mov	x21, x20
	b	.L170
.L162:
	.cfi_restore 27
	ldr	x19, [x26, 16]
	mov	x0, x26
	bl	_ZdlPv
	cbz	x19, .L161
	mov	x26, x19
	b	.L172
	.p2align 2,,3
.L165:
	.cfi_offset 27, -16
	ldr	x20, [x27, 16]
	mov	x0, x27
	bl	_ZdlPv
	cbz	x20, .L164
	mov	x27, x20
	b	.L169
.L161:
	.cfi_restore 27
	ldr	x19, [x25, 16]
	mov	x0, x25
	bl	_ZdlPv
	cbz	x19, .L160
	mov	x25, x19
	b	.L173
.L160:
	ldr	x19, [x24, 16]
	mov	x0, x24
	bl	_ZdlPv
	cbz	x19, .L220
	mov	x24, x19
	b	.L174
.L220:
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
.L159:
	mov	x0, x23
	ldr	x19, [x23, 16]
	bl	_ZdlPv
	cbz	x19, .L221
	mov	x23, x19
	b	.L175
.L221:
	ldp	x19, x20, [sp, 16]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L218:
	ret
	.cfi_endproc
.LFE12827:
	.size	_ZNSt8_Rb_treeIjjSt9_IdentityIjESt4lessIjESaIjEE8_M_eraseEPSt13_Rb_tree_nodeIjE.isra.0, .-_ZNSt8_Rb_treeIjjSt9_IdentityIjESt4lessIjESaIjEE8_M_eraseEPSt13_Rb_tree_nodeIjE.isra.0
	.section	.text._ZN7hnswlib15HierarchicalNSWIfED2Ev,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfED5Ev,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfED2Ev
	.type	_ZN7hnswlib15HierarchicalNSWIfED2Ev, %function
_ZN7hnswlib15HierarchicalNSWIfED2Ev:
.LFB12539:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -32
	.cfi_offset 20, -24
	mov	x19, x0
	adrp	x0, _ZTVN7hnswlib15HierarchicalNSWIfEE+16
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -16
	.cfi_offset 22, -8
	add	x0, x0, :lo12:_ZTVN7hnswlib15HierarchicalNSWIfEE+16
	mov	w20, 0
	str	x0, [x19]
	add	x21, x19, 16
	ldr	x0, [x19, 256]
	bl	free
	str	xzr, [x19, 256]
	uxtw	x0, w20
	ldar	x1, [x21]
	cmp	x0, x1
	bcs	.L294
	.p2align 5,,15
.L225:
	ldr	x1, [x19, 272]
	ldr	w1, [x1, x0, lsl 2]
	cmp	w1, 0
	bgt	.L295
	add	w20, w20, 1
.L299:
	uxtw	x0, w20
	ldar	x1, [x21]
	cmp	x0, x1
	bcc	.L225
.L294:
	ldr	x0, [x19, 264]
	bl	free
	str	xzr, [x19, 264]
	stlr	xzr, [x21]
	ldr	x20, [x19, 112]
	str	xzr, [x19, 112]
	add	x21, x20, 16
	cbnz	x20, .L230
	b	.L227
	.p2align 2,,3
.L298:
	add	x2, x2, 8
	str	x2, [x20, 16]
	cbnz	x22, .L296
.L230:
	ldp	x0, x22, [x21, 16]
	ldr	x4, [x20, 72]
	ldr	x2, [x21]
	cmp	x4, 0
	sub	x1, x4, x22
	cset	x3, ne
	asr	x1, x1, 3
	sub	x1, x1, x3
	ldp	x3, x5, [x20, 48]
	sub	x3, x3, x5
	asr	x3, x3, 3
	add	x1, x3, x1, lsl 6
	sub	x3, x0, x2
	add	x1, x1, x3, asr 3
	cbz	x1, .L297
	sub	x0, x0, #8
	ldr	x22, [x2]
	cmp	x2, x0
	bne	.L298
	ldr	x0, [x20, 24]
	bl	_ZdlPv
	ldr	x0, [x20, 40]
	add	x1, x0, 8
	ldr	x2, [x0, 8]
	str	x1, [x21, 24]
	add	x0, x2, 512
	stp	x2, x0, [x21, 8]
	str	x2, [x20, 16]
	cbz	x22, .L230
	.p2align 5,,15
.L296:
	ldr	x0, [x22, 8]
	cbz	x0, .L231
	bl	_ZdaPv
.L231:
	mov	x0, x22
	bl	_ZdlPv
	b	.L230
	.p2align 2,,3
.L295:
	ldr	x1, [x19, 264]
	add	w20, w20, 1
	ldr	x0, [x1, x0, lsl 3]
	bl	free
	b	.L299
	.p2align 2,,3
.L297:
	ldr	x0, [x20]
	cbz	x0, .L233
	add	x21, x4, 8
	cmp	x22, x21
	bcs	.L234
	.p2align 5,,15
.L235:
	ldr	x0, [x22], 8
	bl	_ZdlPv
	cmp	x21, x22
	bhi	.L235
	ldr	x0, [x20]
.L234:
	bl	_ZdlPv
.L233:
	mov	x0, x20
	bl	_ZdlPv
.L227:
	ldr	x20, [x19, 528]
	cbz	x20, .L239
	.p2align 5,,15
.L236:
	mov	x0, x20
	ldr	x20, [x20]
	bl	_ZdlPv
	cbnz	x20, .L236
.L239:
	ldr	x0, [x19, 512]
	add	x1, x19, 560
	cmp	x0, x1
	beq	.L237
	bl	_ZdlPv
.L237:
	ldr	x20, [x19, 384]
	cbz	x20, .L243
	.p2align 5,,15
.L240:
	mov	x0, x20
	ldr	x20, [x20]
	bl	_ZdlPv
	cbnz	x20, .L240
.L243:
	ldr	x0, [x19, 368]
	add	x1, x19, 416
	cmp	x0, x1
	beq	.L241
	bl	_ZdlPv
.L241:
	ldr	x0, [x19, 272]
	cbz	x0, .L244
	bl	_ZdlPv
.L244:
	ldr	x0, [x19, 192]
	cbz	x0, .L245
	bl	_ZdlPv
.L245:
	ldr	x0, [x19, 120]
	cbz	x0, .L246
	bl	_ZdlPv
.L246:
	ldr	x19, [x19, 112]
	add	x20, x19, 16
	cbnz	x19, .L251
	b	.L300
	.p2align 2,,3
.L303:
	add	x1, x1, 8
	str	x1, [x19, 16]
	cbnz	x21, .L301
.L251:
	ldp	x3, x21, [x20, 16]
	ldr	x4, [x19, 72]
	ldr	x1, [x20]
	cmp	x4, 0
	sub	x0, x4, x21
	cset	x2, ne
	asr	x0, x0, 3
	sub	x0, x0, x2
	ldp	x2, x5, [x19, 48]
	sub	x2, x2, x5
	asr	x2, x2, 3
	add	x0, x2, x0, lsl 6
	sub	x2, x3, x1
	add	x0, x0, x2, asr 3
	cbz	x0, .L302
	sub	x3, x3, #8
	ldr	x21, [x1]
	cmp	x1, x3
	bne	.L303
	ldr	x0, [x19, 24]
	bl	_ZdlPv
	ldr	x0, [x19, 40]
	add	x1, x0, 8
	str	x1, [x20, 24]
	ldr	x1, [x0, 8]
	add	x0, x1, 512
	stp	x1, x0, [x20, 8]
	str	x1, [x19, 16]
	cbz	x21, .L251
	.p2align 5,,15
.L301:
	ldr	x0, [x21, 8]
	cbz	x0, .L252
	bl	_ZdaPv
.L252:
	mov	x0, x21
	bl	_ZdlPv
	b	.L251
	.p2align 2,,3
.L302:
	ldr	x0, [x19]
	cbz	x0, .L254
	add	x20, x4, 8
	cmp	x21, x20
	bcs	.L255
	.p2align 5,,15
.L256:
	ldr	x0, [x21], 8
	bl	_ZdlPv
	cmp	x20, x21
	bhi	.L256
	ldr	x0, [x19]
.L255:
	bl	_ZdlPv
.L254:
	ldp	x21, x22, [sp, 32]
	mov	x0, x19
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 48
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	b	_ZdlPv
	.p2align 2,,3
.L300:
	.cfi_restore_state
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE12539:
	.size	_ZN7hnswlib15HierarchicalNSWIfED2Ev, .-_ZN7hnswlib15HierarchicalNSWIfED2Ev
	.weak	_ZN7hnswlib15HierarchicalNSWIfED1Ev
	.set	_ZN7hnswlib15HierarchicalNSWIfED1Ev,_ZN7hnswlib15HierarchicalNSWIfED2Ev
	.section	.text._ZN7hnswlib15HierarchicalNSWIfED0Ev,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfED5Ev,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfED0Ev
	.type	_ZN7hnswlib15HierarchicalNSWIfED0Ev, %function
_ZN7hnswlib15HierarchicalNSWIfED0Ev:
.LFB12541:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	str	x0, [sp, 24]
	bl	_ZN7hnswlib15HierarchicalNSWIfED1Ev
	ldr	x0, [sp, 24]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	b	_ZdlPv
	.cfi_endproc
.LFE12541:
	.size	_ZN7hnswlib15HierarchicalNSWIfED0Ev, .-_ZN7hnswlib15HierarchicalNSWIfED0Ev
	.section	.rodata.str1.8
	.align	3
.LC3:
	.string	"basic_string::append"
	.text
	.align	2
	.p2align 5,,15
	.type	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EERKS8_PKS5_.isra.0, %function
_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EERKS8_PKS5_.isra.0:
.LFB12829:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12829
	stp	x29, x30, [sp, -64]!
	.cfi_def_cfa_offset 64
	.cfi_offset 29, -64
	.cfi_offset 30, -56
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -48
	.cfi_offset 20, -40
	mov	x19, x8
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -32
	.cfi_offset 22, -24
	mov	x21, x1
	mov	x22, x2
	str	x23, [sp, 48]
	.cfi_offset 23, -16
	mov	x23, x0
	mov	x0, x2
	bl	strlen
	mov	x20, x0
	add	x0, x19, 16
	stp	x0, xzr, [x19]
	add	x1, x20, x21
	mov	x0, x19
	strb	wzr, [x19, 16]
.LEHB3:
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE7reserveEm
	ldr	x1, [x19, 8]
	mov	x0, 9223372036854775806
	sub	x0, x0, x1
	cmp	x21, x0
	bhi	.L314
	mov	x2, x21
	mov	x1, x23
	mov	x0, x19
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_appendEPKcm
	ldr	x1, [x19, 8]
	mov	x0, 9223372036854775806
	sub	x0, x0, x1
	cmp	x20, x0
	bhi	.L315
	mov	x2, x20
	mov	x1, x22
	mov	x0, x19
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_appendEPKcm
.LEHE3:
	ldr	x23, [sp, 48]
	mov	x0, x19
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 64
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L311:
	.cfi_restore_state
	mov	x20, x0
	mov	x0, x19
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	x0, x20
.LEHB4:
	bl	_Unwind_Resume
.LEHE4:
.L315:
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
.LEHB5:
	bl	_ZSt20__throw_length_errorPKc
.L314:
	adrp	x0, .LC3
	add	x0, x0, :lo12:.LC3
	bl	_ZSt20__throw_length_errorPKc
.LEHE5:
	.cfi_endproc
.LFE12829:
	.section	.gcc_except_table
.LLSDA12829:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12829-.LLSDACSB12829
.LLSDACSB12829:
	.uleb128 .LEHB3-.LFB12829
	.uleb128 .LEHE3-.LEHB3
	.uleb128 .L311-.LFB12829
	.uleb128 0
	.uleb128 .LEHB4-.LFB12829
	.uleb128 .LEHE4-.LEHB4
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB5-.LFB12829
	.uleb128 .LEHE5-.LEHB5
	.uleb128 .L311-.LFB12829
	.uleb128 0
.LLSDACSE12829:
	.text
	.size	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EERKS8_PKS5_.isra.0, .-_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EERKS8_PKS5_.isra.0
	.section	.rodata.str1.8
	.align	3
.LC4:
	.string	"cannot create std::vector larger than max_size()"
	.align	3
.LC5:
	.string	"vector::_M_realloc_append"
	.text
	.align	2
	.p2align 5,,15
	.global	_Z9pq_searchPfS_mmmRK7PQIndexm
	.type	_Z9pq_searchPfS_mmmRK7PQIndexm, %function
_Z9pq_searchPfS_mmmRK7PQIndexm:
.LFB10138:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10138
	stp	x29, x30, [sp, -192]!
	.cfi_def_cfa_offset 192
	.cfi_offset 29, -192
	.cfi_offset 30, -184
	mov	x29, sp
	stp	x27, x28, [sp, 80]
	.cfi_offset 27, -112
	.cfi_offset 28, -104
	mov	x27, x1
	mov	x1, 2305843009213693951
	stp	x2, x0, [sp, 136]
	stp	x4, x6, [sp, 152]
	ldr	w0, [x5]
	stp	x19, x20, [sp, 16]
	.cfi_offset 20, -168
	.cfi_offset 19, -176
	lsl	w0, w0, 8
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -152
	.cfi_offset 21, -160
	sxtw	x0, w0
	cmp	x0, x1
	bhi	.L423
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -120
	.cfi_offset 25, -128
	mov	x20, x8
	mov	x26, x3
	mov	x25, x5
	cbz	x0, .L318
	lsl	x21, x0, 2
	mov	x0, x21
.LEHB6:
	bl	_Znwm
.LEHE6:
	str	wzr, [x0]
	mov	x19, x0
	mov	x28, x0
	sub	x2, x21, #4
	add	x0, x0, 4
	mov	w1, 0
	bl	memset
	ldr	w10, [x25]
	mov	w9, 0
	ldr	w5, [x25, 8]
	.p2align 5,,15
.L323:
	cmp	w5, 0
	ble	.L319
	ldr	w6, [x25, 4]
	mul	w7, w5, w9
	ldr	x8, [x25, 32]
	sub	w2, w6, #1
	mov	x4, 0
	mul	w7, w7, w6
	lsr	w2, w2, 2
	mul	w3, w6, w9
	add	w2, w2, 1
	sxtw	x7, w7
	ubfiz	x2, x2, 4, 31
	add	x3, x27, w3, sxtw 2
	.p2align 5,,15
.L322:
	cmp	w6, 0
	ble	.L378
	mul	w1, w6, w4
	mov	x0, 0
	movi	v30.4s, 0
	add	x1, x7, w1, sxtw
	add	x1, x8, x1, lsl 2
	.p2align 5,,15
.L321:
	ldr	q29, [x3, x0]
	ldr	q0, [x1, x0]
	add	x0, x0, 16
	fmul	v0.4s, v29.4s, v0.4s
	fadd	v30.4s, v30.4s, v0.4s
	cmp	x2, x0
	bne	.L321
	dup	d28, v30.d[1]
	fadd	v31.2s, v28.2s, v30.2s
.L320:
	faddp	v31.2s, v31.2s, v31.2s
	str	s31, [x28, x4, lsl 2]
	add	x4, x4, 1
	cmp	w5, w4
	bgt	.L322
.L319:
	add	w9, w9, 1
	mov	w7, w10
	add	x28, x28, 1024
	cmp	w9, w10
	blt	.L323
	ldr	x0, [sp, 136]
	cbz	x0, .L327
.L325:
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -136
	.cfi_offset 23, -144
	sxtw	x21, w7
	mov	x28, 0
	mov	x22, 0
	mov	x23, 0
	stp	d13, d14, [sp, 96]
	.cfi_offset 78, -88
	.cfi_offset 77, -96
	ldr	x24, [x25, 56]
	mov	x25, 0
	str	d15, [sp, 112]
	.cfi_offset 79, -80
	fmov	s15, 1.0e+0
	.p2align 5,,15
.L345:
	cmp	w7, 0
	ble	.L380
	movi	v14.2s, #0
	mov	x0, 0
	.p2align 5,,15
.L329:
	ldrb	w1, [x24, x0]
	add	w1, w1, w0, lsl 8
	add	x0, x0, 1
	ldr	s1, [x19, x1, lsl 2]
	fadd	s14, s14, s1
	cmp	x0, x21
	bne	.L329
	fsub	s14, s15, s14
.L328:
	ldr	x2, [sp, 160]
	sub	x1, x22, x25
	asr	x0, x1, 3
	cmp	x2, x0
	bhi	.L424
	ldr	s27, [x25]
	fcmpe	s27, s14
	bgt	.L388
.L337:
	ldr	x0, [sp, 136]
	add	x23, x23, 1
	add	x24, x24, x21
	cmp	x0, x23
	bne	.L345
	stp	xzr, xzr, [x20]
	str	xzr, [x20, 16]
	cmp	x25, x22
	beq	.L425
	sub	w21, w26, #16
	lsr	w24, w21, 4
	and	w21, w21, -16
	add	w24, w24, 1
	.p2align 5,,15
.L371:
	sub	x0, x22, x25
	ldr	w5, [x25, 4]
	cmp	x0, 8
	sub	x22, x22, #8
	bgt	.L426
	uxtw	x3, w5
	ldr	x0, [sp, 144]
	mul	x3, x3, x26
	add	x3, x0, x3, lsl 2
	cmp	w26, 15
	ble	.L383
.L428:
	movi	v26.4s, 0
	mov	w2, 64
	mov	x0, x3
	mov	x1, x27
	umaddl	x2, w24, w2, x3
	mov	v3.16b, v26.16b
	mov	v25.16b, v26.16b
	mov	v4.16b, v26.16b
	.p2align 5,,15
.L353:
	ldp	q20, q18, [x0]
	ldp	q19, q17, [x1]
	ldp	q16, q6, [x0, 32]
	add	x0, x0, 64
	ldp	q7, q5, [x1, 32]
	add	x1, x1, 64
	fmul	v19.4s, v20.4s, v19.4s
	fmul	v17.4s, v18.4s, v17.4s
	fmul	v7.4s, v16.4s, v7.4s
	fmul	v5.4s, v6.4s, v5.4s
	fadd	v4.4s, v4.4s, v19.4s
	fadd	v25.4s, v25.4s, v17.4s
	fadd	v3.4s, v3.4s, v7.4s
	fadd	v26.4s, v26.4s, v5.4s
	cmp	x0, x2
	bne	.L353
	add	w0, w21, 16
	add	w1, w21, 19
.L352:
	cmp	w1, w26
	bge	.L354
	sxtw	x0, w0
.L355:
	lsl	x1, x0, 2
	add	x0, x0, 4
	ldr	q23, [x3, x1]
	ldr	q22, [x27, x1]
	add	w1, w0, 3
	fmul	v22.4s, v23.4s, v22.4s
	fadd	v4.4s, v4.4s, v22.4s
	cmp	w1, w26
	blt	.L355
.L354:
	fadd	v4.4s, v4.4s, v25.4s
	fadd	v3.4s, v3.4s, v26.4s
	ldp	x6, x7, [x20]
	fmov	s13, 1.0e+0
	ldr	x2, [sp, 152]
	fadd	v3.4s, v4.4s, v3.4s
	sub	x1, x7, x6
	dup	d2, v3.d[1]
	asr	x0, x1, 3
	fadd	v2.2s, v2.2s, v3.2s
	faddp	v2.2s, v2.2s, v2.2s
	fsub	s13, s13, s2
	cmp	x2, x0
	bhi	.L427
	ldr	s24, [x6]
	fcmpe	s24, s13
	bgt	.L389
.L363:
	cmp	x25, x22
	bne	.L371
.L349:
	mov	x0, x25
	bl	_ZdlPv
.L350:
	ldr	d15, [sp, 112]
	.cfi_restore 79
	ldp	x23, x24, [sp, 48]
	.cfi_restore 24
	.cfi_restore 23
	ldp	d13, d14, [sp, 96]
	.cfi_restore 78
	.cfi_restore 77
	cbz	x19, .L316
.L347:
	mov	x0, x19
	bl	_ZdlPv
.L316:
	ldp	x21, x22, [sp, 32]
	.cfi_remember_state
	.cfi_restore 22
	.cfi_restore 21
	mov	x0, x20
	ldp	x19, x20, [sp, 16]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 192
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_restore 28
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L378:
	.cfi_restore_state
	movi	v31.2s, 0
	b	.L320
.L424:
	.cfi_offset 23, -144
	.cfi_offset 24, -136
	.cfi_offset 77, -96
	.cfi_offset 78, -88
	.cfi_offset 79, -80
	cmp	x28, x22
	beq	.L331
	add	x22, x22, 8
	str	w23, [x22, -4]
	str	s14, [x22, -8]
.L332:
	ldr	x3, [x22, -8]
	sub	x1, x22, x25
	mov	x0, x25
	mov	x2, 0
	asr	x1, x1, 3
	str	w7, [sp, 168]
	sub	x1, x1, #1
	bl	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	ldr	w7, [sp, 168]
	b	.L337
.L427:
	ldr	x2, [x20, 16]
	cmp	x7, x2
	beq	.L357
	str	s13, [x7]
	add	x7, x7, 8
	str	w5, [x7, -4]
	str	x7, [x20, 8]
.L358:
	ldr	x3, [x7, -8]
	sub	x1, x7, x6
	mov	x0, x6
	mov	x2, 0
	asr	x1, x1, 3
	sub	x1, x1, #1
	bl	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	b	.L363
.L426:
	ldr	x3, [x22]
	sub	x2, x22, x25
	ldr	s31, [x25]
	mov	x0, x25
	str	w5, [x22, 4]
	asr	x2, x2, 3
	mov	x1, 0
	str	w5, [sp, 136]
	str	s31, [x22]
	bl	_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0
	ldr	w5, [sp, 136]
	ldr	x0, [sp, 144]
	uxtw	x3, w5
	mul	x3, x3, x26
	add	x3, x0, x3, lsl 2
	cmp	w26, 15
	bgt	.L428
.L383:
	movi	v26.4s, 0
	mov	w1, 3
	mov	w0, 0
	mov	v3.16b, v26.16b
	mov	v25.16b, v26.16b
	mov	v4.16b, v26.16b
	b	.L352
.L389:
	ldr	x2, [x20, 16]
	cmp	x7, x2
	beq	.L365
	add	x28, x7, 8
	str	w5, [x7, 4]
	str	s13, [x7]
.L366:
	ldr	x3, [x28, -8]
	sub	x8, x28, x6
	mov	x0, x6
	mov	x2, 0
	asr	x1, x8, 3
	str	x6, [sp, 136]
	sub	x1, x1, #1
	str	x7, [sp, 160]
	bl	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	ldr	x6, [sp, 136]
	cmp	x8, 8
	ldr	x7, [sp, 160]
	bgt	.L429
	str	x7, [x20, 8]
	b	.L363
.L429:
	ldr	x3, [x28, -8]
	sub	x2, x7, x6
	ldr	s31, [x6]
	ldr	w1, [x6, 4]
	asr	x2, x2, 3
	str	w1, [x28, -4]
	mov	x1, 0
	str	s31, [x28, -8]
	str	x7, [sp, 136]
	bl	_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0
	ldr	x7, [sp, 136]
	str	x7, [x20, 8]
	b	.L363
.L388:
	cmp	x28, x22
	beq	.L339
	add	x9, x22, 8
	str	w23, [x22, 4]
	str	s14, [x22]
.L340:
	ldr	x3, [x9, -8]
	sub	x10, x9, x25
	mov	x0, x25
	mov	x2, 0
	asr	x1, x10, 3
	str	w7, [sp, 168]
	sub	x1, x1, #1
	bl	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	ldr	w7, [sp, 168]
	cmp	x10, 8
	ble	.L337
	ldr	x3, [x9, -8]
	str	w7, [sp, 168]
	ldr	s31, [x25]
	ldr	w1, [x25, 4]
	str	w1, [x9, -4]
	sub	x1, x22, x25
	str	s31, [x9, -8]
	asr	x2, x1, 3
	mov	x1, 0
	bl	_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0
	ldr	w7, [sp, 168]
	b	.L337
.L380:
	fmov	s14, 1.0e+0
	b	.L328
.L318:
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 77
	.cfi_restore 78
	.cfi_restore 79
	ldr	x0, [sp, 136]
	mov	w7, 0
	mov	x19, 0
	cbnz	x0, .L325
	stp	xzr, xzr, [x8]
	str	xzr, [x8, 16]
	b	.L316
.L357:
	.cfi_offset 23, -144
	.cfi_offset 24, -136
	.cfi_offset 77, -96
	.cfi_offset 78, -88
	.cfi_offset 79, -80
	mov	x2, 1152921504606846975
	cmp	x0, x2
	beq	.L430
	cmp	x0, 0
	str	w5, [sp, 136]
	csinc	x28, x0, xzr, ne
	stp	x7, x6, [sp, 160]
	add	x28, x28, x0
	cmp	x28, x2
	str	x1, [sp, 176]
	csel	x28, x28, x2, ls
	lsl	x28, x28, 3
	mov	x0, x28
.LEHB7:
	bl	_Znwm
.LEHE7:
	ldr	x1, [sp, 176]
	mov	x8, x0
	ldp	x7, x6, [sp, 160]
	add	x0, x0, x1
	ldr	w5, [sp, 136]
	str	s13, [x8, x1]
	str	w5, [x0, 4]
	cmp	x7, x6
	beq	.L384
	mov	x1, x8
	mov	x2, x6
.L361:
	ldr	x3, [x2], 8
	str	x3, [x1], 8
	cmp	x0, x1
	bne	.L361
.L360:
	add	x7, x0, 8
	cbz	x6, .L362
	mov	x0, x6
	str	x7, [sp, 136]
	str	x8, [sp, 160]
	bl	_ZdlPv
	ldr	x7, [sp, 136]
	ldr	x8, [sp, 160]
.L362:
	add	x28, x8, x28
	mov	x6, x8
	stp	x8, x7, [x20]
	str	x28, [x20, 16]
	b	.L358
.L331:
	mov	x3, 1152921504606846975
	cmp	x0, x3
	beq	.L431
	cmp	x0, 0
	str	w7, [sp, 168]
	csinc	x28, x0, xzr, ne
	str	w23, [sp, 176]
	add	x28, x28, x0
	str	x1, [sp, 184]
	cmp	x28, x3
	csel	x28, x28, x3, ls
	lsl	x28, x28, 3
	mov	x0, x28
.LEHB8:
	bl	_Znwm
.LEHE8:
	ldr	x1, [sp, 184]
	mov	x3, x0
	ldr	w2, [sp, 176]
	cmp	x25, x22
	add	x9, x0, x1
	ldr	w7, [sp, 168]
	str	s14, [x0, x1]
	str	w2, [x9, 4]
	beq	.L334
	mov	x1, x25
.L335:
	ldr	x2, [x1], 8
	str	x2, [x0], 8
	cmp	x0, x9
	bne	.L335
.L334:
	add	x22, x0, 8
	cbz	x25, .L336
	mov	x0, x25
	str	w7, [sp, 168]
	str	x3, [sp, 176]
	bl	_ZdlPv
	ldr	x3, [sp, 176]
	ldr	w7, [sp, 168]
.L336:
	add	x28, x3, x28
	mov	x25, x3
	b	.L332
.L425:
	cbz	x25, .L350
	b	.L349
	.p2align 2,,3
.L365:
	mov	x2, 1152921504606846975
	cmp	x0, x2
	beq	.L432
	cmp	x0, 0
	str	w5, [sp, 136]
	csinc	x28, x0, xzr, ne
	stp	x7, x6, [sp, 160]
	add	x28, x28, x0
	cmp	x28, x2
	str	x1, [sp, 176]
	csel	x28, x28, x2, ls
	lsl	x23, x28, 3
	mov	x0, x23
.LEHB9:
	bl	_Znwm
.LEHE9:
	ldr	x1, [sp, 176]
	mov	x2, x0
	ldp	x7, x6, [sp, 160]
	add	x8, x0, x1
	ldr	w5, [sp, 136]
	str	s13, [x0, x1]
	str	w5, [x8, 4]
	cmp	x7, x6
	beq	.L385
	mov	x1, x6
.L369:
	ldr	x3, [x1], 8
	str	x3, [x0], 8
	cmp	x8, x0
	bne	.L369
	mov	x7, x8
.L368:
	mov	x0, x6
	add	x28, x7, 8
	str	x7, [sp, 136]
	str	x2, [sp, 160]
	bl	_ZdlPv
	ldr	x2, [sp, 160]
	str	x2, [x20]
	ldr	x7, [sp, 136]
	add	x0, x2, x23
	mov	x6, x2
	str	x0, [x20, 16]
	b	.L366
.L339:
	mov	x2, 1152921504606846975
	cmp	x0, x2
	beq	.L433
	cmp	x0, 0
	str	w7, [sp, 168]
	csinc	x28, x0, xzr, ne
	str	w23, [sp, 176]
	add	x28, x28, x0
	str	x1, [sp, 184]
	cmp	x28, x2
	csel	x28, x28, x2, ls
	lsl	x28, x28, 3
	mov	x0, x28
.LEHB10:
	bl	_Znwm
.LEHE10:
	ldr	x1, [sp, 184]
	mov	x2, x0
	ldr	w3, [sp, 176]
	cmp	x25, x22
	add	x0, x0, x1
	ldr	w7, [sp, 168]
	str	s14, [x2, x1]
	str	w3, [x0, 4]
	beq	.L382
	mov	x3, x2
	mov	x0, x25
.L343:
	ldr	x9, [x0], 8
	str	x9, [x3], 8
	cmp	x0, x22
	bne	.L343
	add	x22, x2, x1
.L342:
	add	x9, x22, 8
	mov	x0, x25
	str	x9, [sp, 168]
	str	w7, [sp, 176]
	str	x2, [sp, 184]
	bl	_ZdlPv
	ldr	x2, [sp, 184]
	ldr	x9, [sp, 168]
	add	x28, x2, x28
	ldr	w7, [sp, 176]
	mov	x25, x2
	b	.L340
.L327:
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 77
	.cfi_restore 78
	.cfi_restore 79
	stp	xzr, xzr, [x20]
	str	xzr, [x20, 16]
	b	.L347
.L384:
	.cfi_offset 23, -144
	.cfi_offset 24, -136
	.cfi_offset 77, -96
	.cfi_offset 78, -88
	.cfi_offset 79, -80
	mov	x0, x8
	b	.L360
.L385:
	mov	x7, x0
	b	.L368
.L382:
	mov	x22, x2
	b	.L342
.L387:
	mov	x21, x0
	cbnz	x25, .L374
	cbz	x19, .L377
.L434:
	mov	x0, x19
	bl	_ZdlPv
.L377:
	mov	x0, x21
.LEHB11:
	bl	_Unwind_Resume
.LEHE11:
.L386:
	mov	x21, x0
	ldr	x0, [x20]
	cbz	x0, .L374
	bl	_ZdlPv
.L374:
	mov	x0, x25
	bl	_ZdlPv
	cbnz	x19, .L434
	b	.L377
.L431:
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB12:
	bl	_ZSt20__throw_length_errorPKc
.LEHE12:
.L432:
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB13:
	bl	_ZSt20__throw_length_errorPKc
.LEHE13:
.L433:
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB14:
	bl	_ZSt20__throw_length_errorPKc
.LEHE14:
.L423:
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 77
	.cfi_restore 78
	.cfi_restore 79
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	stp	x23, x24, [sp, 48]
	.cfi_offset 24, -136
	.cfi_offset 23, -144
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -120
	.cfi_offset 25, -128
	stp	d13, d14, [sp, 96]
	.cfi_offset 78, -88
	.cfi_offset 77, -96
	str	d15, [sp, 112]
	.cfi_offset 79, -80
.LEHB15:
	bl	_ZSt20__throw_length_errorPKc
.LEHE15:
.L430:
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB16:
	bl	_ZSt20__throw_length_errorPKc
.LEHE16:
	.cfi_endproc
.LFE10138:
	.section	.gcc_except_table
.LLSDA10138:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE10138-.LLSDACSB10138
.LLSDACSB10138:
	.uleb128 .LEHB6-.LFB10138
	.uleb128 .LEHE6-.LEHB6
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB7-.LFB10138
	.uleb128 .LEHE7-.LEHB7
	.uleb128 .L386-.LFB10138
	.uleb128 0
	.uleb128 .LEHB8-.LFB10138
	.uleb128 .LEHE8-.LEHB8
	.uleb128 .L387-.LFB10138
	.uleb128 0
	.uleb128 .LEHB9-.LFB10138
	.uleb128 .LEHE9-.LEHB9
	.uleb128 .L386-.LFB10138
	.uleb128 0
	.uleb128 .LEHB10-.LFB10138
	.uleb128 .LEHE10-.LEHB10
	.uleb128 .L387-.LFB10138
	.uleb128 0
	.uleb128 .LEHB11-.LFB10138
	.uleb128 .LEHE11-.LEHB11
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB12-.LFB10138
	.uleb128 .LEHE12-.LEHB12
	.uleb128 .L387-.LFB10138
	.uleb128 0
	.uleb128 .LEHB13-.LFB10138
	.uleb128 .LEHE13-.LEHB13
	.uleb128 .L386-.LFB10138
	.uleb128 0
	.uleb128 .LEHB14-.LFB10138
	.uleb128 .LEHE14-.LEHB14
	.uleb128 .L387-.LFB10138
	.uleb128 0
	.uleb128 .LEHB15-.LFB10138
	.uleb128 .LEHE15-.LEHB15
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB16-.LFB10138
	.uleb128 .LEHE16-.LEHB16
	.uleb128 .L386-.LFB10138
	.uleb128 0
.LLSDACSE10138:
	.text
	.size	_Z9pq_searchPfS_mmmRK7PQIndexm, .-_Z9pq_searchPfS_mmmRK7PQIndexm
	.section	.text._ZN7PQIndexD2Ev,"axG",@progbits,_ZN7PQIndexD5Ev,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7PQIndexD2Ev
	.type	_ZN7PQIndexD2Ev, %function
_ZN7PQIndexD2Ev:
.LFB10184:
	.cfi_startproc
	mov	x1, x0
	ldr	x0, [x0, 56]
	cbz	x0, .L442
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	str	x1, [sp, 24]
	bl	_ZdlPv
	ldr	x1, [sp, 24]
	ldr	x0, [x1, 32]
	cbz	x0, .L435
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	b	_ZdlPv
	.p2align 2,,3
.L435:
	.cfi_restore_state
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L442:
	ldr	x0, [x1, 32]
	cbz	x0, .L444
	b	_ZdlPv
	.p2align 2,,3
.L444:
	ret
	.cfi_endproc
.LFE10184:
	.size	_ZN7PQIndexD2Ev, .-_ZN7PQIndexD2Ev
	.weak	_ZN7PQIndexD1Ev
	.set	_ZN7PQIndexD1Ev,_ZN7PQIndexD2Ev
	.section	.text._ZNSt11unique_lockISt5mutexE6unlockEv,"axG",@progbits,_ZNSt11unique_lockISt5mutexE6unlockEv,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt11unique_lockISt5mutexE6unlockEv
	.type	_ZNSt11unique_lockISt5mutexE6unlockEv, %function
_ZNSt11unique_lockISt5mutexE6unlockEv:
.LFB10895:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x1, x0
	mov	x29, sp
	ldrb	w0, [x0, 8]
	tbz	x0, 0, .L454
	ldr	x0, [x1]
	cbz	x0, .L447
	str	x1, [sp, 24]
	bl	pthread_mutex_unlock
	ldr	x1, [sp, 24]
	strb	wzr, [x1, 8]
.L447:
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
.L454:
	.cfi_restore_state
	mov	w0, 1
	bl	_ZSt20__throw_system_errori
	.cfi_endproc
.LFE10895:
	.size	_ZNSt11unique_lockISt5mutexE6unlockEv, .-_ZNSt11unique_lockISt5mutexE6unlockEv
	.section	.text._ZN7hnswlib15VisitedListPool18getFreeVisitedListEv,"axG",@progbits,_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv
	.type	_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv, %function
_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv:
.LFB4212:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA4212
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x29, x30, [sp, 48]
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	add	x29, sp, 48
	stp	x19, x20, [sp, 64]
	.cfi_offset 19, -32
	.cfi_offset 20, -24
	mov	x19, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x21, [sp, 80]
	.cfi_offset 21, -16
	add	x21, x19, 80
	ldr	x1, [x0]
	str	x1, [sp, 40]
	mov	x1, 0
	mov	x0, x21
	str	x21, [sp, 24]
	bl	pthread_mutex_lock
	cbnz	w0, .L472
	add	x4, x19, 16
	mov	w0, 1
	strb	w0, [sp, 32]
	ldr	x1, [x19, 72]
	ldp	x3, x0, [x4, 16]
	cmp	x1, 0
	ldr	x2, [x19, 16]
	sub	x0, x1, x0
	cset	x1, ne
	asr	x0, x0, 3
	sub	x0, x0, x1
	ldp	x1, x5, [x19, 48]
	sub	x1, x1, x5
	asr	x1, x1, 3
	add	x0, x1, x0, lsl 6
	sub	x1, x3, x2
	add	x0, x0, x1, asr 3
	cbz	x0, .L458
	sub	x3, x3, #8
	ldr	x20, [x2]
	cmp	x2, x3
	beq	.L459
	add	x2, x2, 8
	str	x2, [x19, 16]
	mov	x0, x21
	bl	pthread_mutex_unlock
	ldrh	w0, [x20]
	add	w0, w0, 1
	and	w0, w0, 65535
	strh	w0, [x20]
	cbnz	w0, .L455
.L473:
	ldr	x0, [x20, 8]
	mov	w1, 0
	ldr	w2, [x20, 16]
	lsl	x2, x2, 1
	bl	memset
	ldrh	w0, [x20]
	add	w0, w0, 1
	strh	w0, [x20]
	b	.L455
	.p2align 2,,3
.L458:
	mov	x0, 24
.LEHB17:
	bl	_Znwm
.LEHE17:
	mov	x20, x0
	mov	w1, -1
	strh	w1, [x0]
	ldr	w0, [x19, 128]
	str	w0, [x20, 16]
	ubfiz	x0, x0, 1, 32
.LEHB18:
	bl	_Znam
.LEHE18:
	str	x0, [x20, 8]
.L461:
	mov	x0, x21
	bl	pthread_mutex_unlock
	ldrh	w0, [x20]
	add	w0, w0, 1
	and	w0, w0, 65535
	strh	w0, [x20]
	cbz	w0, .L473
.L455:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 40]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L471
	ldr	x21, [sp, 80]
	mov	x0, x20
	ldp	x29, x30, [sp, 48]
	ldp	x19, x20, [sp, 64]
	add	sp, sp, 96
	.cfi_remember_state
	.cfi_restore 21
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L459:
	.cfi_restore_state
	ldr	x0, [x19, 24]
	str	x4, [sp, 8]
	bl	_ZdlPv
	ldr	x0, [x19, 40]
	ldr	x4, [sp, 8]
	add	x1, x0, 8
	ldr	x0, [x0, 8]
	str	x1, [x4, 24]
	add	x1, x0, 512
	stp	x0, x1, [x4, 8]
	str	x0, [x19, 16]
	b	.L461
.L468:
	mov	x19, x0
	mov	x0, x20
	bl	_ZdlPv
.L464:
	add	x0, sp, 24
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 40]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	beq	.L465
.L471:
	bl	__stack_chk_fail
.L467:
	mov	x19, x0
	b	.L464
.L472:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 40]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	bne	.L471
.LEHB19:
	bl	_ZSt20__throw_system_errori
.L465:
	mov	x0, x19
	bl	_Unwind_Resume
.LEHE19:
	.cfi_endproc
.LFE4212:
	.section	.gcc_except_table
.LLSDA4212:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE4212-.LLSDACSB4212
.LLSDACSB4212:
	.uleb128 .LEHB17-.LFB4212
	.uleb128 .LEHE17-.LEHB17
	.uleb128 .L467-.LFB4212
	.uleb128 0
	.uleb128 .LEHB18-.LFB4212
	.uleb128 .LEHE18-.LEHB18
	.uleb128 .L468-.LFB4212
	.uleb128 0
	.uleb128 .LEHB19-.LFB4212
	.uleb128 .LEHE19-.LEHB19
	.uleb128 0
	.uleb128 0
.LLSDACSE4212:
	.section	.text._ZN7hnswlib15VisitedListPool18getFreeVisitedListEv,"axG",@progbits,_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv,comdat
	.size	_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv, .-_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv
	.section	.rodata._ZNSt6vectorIfSaIfEE17_M_default_appendEm.str1.8,"aMS",@progbits,1
	.align	3
.LC6:
	.string	"vector::_M_default_append"
	.section	.text._ZNSt6vectorIfSaIfEE17_M_default_appendEm,"axG",@progbits,_ZNSt6vectorIfSaIfEE17_M_default_appendEm,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt6vectorIfSaIfEE17_M_default_appendEm
	.type	_ZNSt6vectorIfSaIfEE17_M_default_appendEm, %function
_ZNSt6vectorIfSaIfEE17_M_default_appendEm:
.LFB10942:
	.cfi_startproc
	cbz	x1, .L498
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x4, x0
	mov	x3, x1
	mov	x29, sp
	ldp	x2, x0, [x0, 8]
	sub	x0, x0, x2
	cmp	x1, x0, asr 2
	bhi	.L476
	mov	x0, x2
	subs	x3, x1, #1
	str	wzr, [x0], 4
	beq	.L477
	add	x3, x0, x3, lsl 2
	mov	w1, 0
	sub	x2, x3, x2
	stp	x3, x4, [sp, 32]
	sub	x2, x2, #4
	bl	memset
	ldp	x0, x4, [sp, 32]
.L477:
	str	x0, [x4, 8]
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L498:
	ret
	.p2align 2,,3
.L476:
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	ldr	x8, [x4]
	mov	x1, 2305843009213693951
	str	x19, [sp, 16]
	.cfi_offset 19, -64
	sub	x5, x2, x8
	asr	x7, x5, 2
	sub	x0, x1, x7
	cmp	x0, x3
	bcc	.L501
	cmp	x3, x7
	stp	x7, x3, [sp, 32]
	csel	x0, x3, x7, cs
	add	x0, x0, x7
	stp	x8, x5, [sp, 48]
	cmp	x0, x1
	csel	x0, x0, x1, ls
	str	x4, [sp, 64]
	lsl	x0, x0, 2
	mov	x19, x0
	bl	_Znwm
	ldp	x8, x5, [sp, 48]
	mov	x6, x0
	ldp	x7, x3, [sp, 32]
	ldr	x4, [sp, 64]
	str	wzr, [x6, x5]
	add	x0, x0, x5
	subs	x2, x3, #1
	beq	.L479
	lsl	x2, x2, 2
	add	x0, x0, 4
	mov	w1, 0
	stp	x8, x5, [sp, 40]
	str	x6, [sp, 56]
	str	x3, [sp, 72]
	bl	memset
	ldp	x7, x8, [sp, 32]
	ldp	x5, x6, [sp, 48]
	ldp	x4, x3, [sp, 64]
.L479:
	cbnz	x5, .L502
.L480:
	cbz	x8, .L481
	mov	x0, x8
	stp	x7, x6, [sp, 32]
	stp	x4, x3, [sp, 48]
	bl	_ZdlPv
	ldp	x7, x6, [sp, 32]
	ldp	x4, x3, [sp, 48]
.L481:
	add	x3, x3, x7
	add	x3, x6, x3, lsl 2
	stp	x6, x3, [x4]
	add	x6, x6, x19
	ldr	x19, [sp, 16]
	.cfi_remember_state
	.cfi_restore 19
	str	x6, [x4, 16]
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L502:
	.cfi_restore_state
	mov	x1, x8
	mov	x0, x6
	mov	x2, x5
	stp	x8, x7, [sp, 32]
	stp	x4, x3, [sp, 48]
	bl	memcpy
	mov	x6, x0
	ldp	x8, x7, [sp, 32]
	ldp	x4, x3, [sp, 48]
	b	.L480
.L501:
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE10942:
	.size	_ZNSt6vectorIfSaIfEE17_M_default_appendEm, .-_ZNSt6vectorIfSaIfEE17_M_default_appendEm
	.section	.text._ZNSt6vectorIhSaIhEE17_M_default_appendEm,"axG",@progbits,_ZNSt6vectorIhSaIhEE17_M_default_appendEm,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt6vectorIhSaIhEE17_M_default_appendEm
	.type	_ZNSt6vectorIhSaIhEE17_M_default_appendEm, %function
_ZNSt6vectorIhSaIhEE17_M_default_appendEm:
.LFB10954:
	.cfi_startproc
	cbz	x1, .L527
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x4, x0
	mov	x3, x1
	mov	x29, sp
	ldp	x1, x0, [x0, 8]
	sub	x0, x0, x1
	cmp	x3, x0
	bhi	.L505
	mov	x0, x1
	strb	wzr, [x0], 1
	cmp	x3, 1
	bne	.L530
.L506:
	str	x0, [x4, 8]
	ldp	x29, x30, [sp], 80
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L527:
	ret
	.p2align 2,,3
.L505:
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	ldr	x8, [x4]
	mov	x0, 9223372036854775807
	sub	x5, x1, x8
	sub	x1, x0, x5
	cmp	x1, x3
	bcc	.L531
	cmp	x3, x5
	stp	x3, x8, [sp, 48]
	csel	x7, x3, x5, cs
	add	x7, x7, x5
	str	x4, [sp, 64]
	cmp	x7, x0
	csel	x7, x7, x0, ls
	stp	x7, x5, [sp, 32]
	mov	x0, x7
	bl	_Znwm
	mov	x6, x0
	ldp	x7, x5, [sp, 32]
	ldp	x3, x8, [sp, 48]
	ldr	x4, [sp, 64]
	strb	wzr, [x6, x5]
	add	x0, x0, x5
	cmp	x3, 1
	beq	.L508
	sub	x2, x3, #1
	add	x0, x0, 1
	mov	w1, 0
	stp	x3, x8, [sp, 32]
	stp	x5, x7, [sp, 48]
	stp	x6, x4, [sp, 64]
	bl	memset
	ldp	x3, x8, [sp, 32]
	ldp	x5, x7, [sp, 48]
	ldp	x6, x4, [sp, 64]
.L508:
	cbnz	x5, .L532
.L509:
	cbz	x8, .L510
	mov	x0, x8
	stp	x5, x7, [sp, 32]
	stp	x6, x4, [sp, 48]
	str	x3, [sp, 64]
	bl	_ZdlPv
	ldp	x5, x7, [sp, 32]
	ldp	x6, x4, [sp, 48]
	ldr	x3, [sp, 64]
.L510:
	add	x3, x3, x5
	add	x3, x6, x3
	stp	x6, x3, [x4]
	add	x6, x6, x7
	str	x6, [x4, 16]
	ldp	x29, x30, [sp], 80
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L530:
	.cfi_restore_state
	sub	x2, x3, #1
	str	x19, [sp, 16]
	.cfi_offset 19, -64
	add	x19, x1, x3
	mov	w1, 0
	str	x4, [sp, 32]
	bl	memset
	ldr	x4, [sp, 32]
	mov	x0, x19
	ldr	x19, [sp, 16]
	.cfi_restore 19
	b	.L506
	.p2align 2,,3
.L532:
	mov	x2, x5
	mov	x1, x8
	mov	x0, x6
	stp	x8, x5, [sp, 32]
	stp	x7, x4, [sp, 48]
	str	x3, [sp, 64]
	bl	memcpy
	ldr	x3, [sp, 64]
	mov	x6, x0
	ldp	x8, x5, [sp, 32]
	ldp	x7, x4, [sp, 48]
	b	.L509
.L531:
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	str	x19, [sp, 16]
	.cfi_offset 19, -64
	bl	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE10954:
	.size	_ZNSt6vectorIhSaIhEE17_M_default_appendEm, .-_ZNSt6vectorIhSaIhEE17_M_default_appendEm
	.section	.rodata._ZN7PQIndex5buildEPKfmmiii.str1.8,"aMS",@progbits,1
	.align	3
.LC7:
	.string	"[PQ] Building index: M="
	.align	3
.LC8:
	.string	", dsub="
	.align	3
.LC9:
	.string	", ksub="
	.align	3
.LC10:
	.string	", niter="
	.align	3
.LC11:
	.string	"\n"
	.align	3
.LC12:
	.string	"[PQ] Index built.\n"
	.align	3
.LC13:
	.string	"[PQ] Training sub-segment "
	.align	3
.LC14:
	.string	"/"
	.align	3
.LC15:
	.string	"...\n"
	.section	.text._ZN7PQIndex5buildEPKfmmiii,"axG",@progbits,_ZN7PQIndex5buildEPKfmmiii,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7PQIndex5buildEPKfmmiii
	.type	_ZN7PQIndex5buildEPKfmmiii, %function
_ZN7PQIndex5buildEPKfmmiii:
.LFB10135:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10135
	stp	x29, x30, [sp, -176]!
	.cfi_def_cfa_offset 176
	.cfi_offset 29, -176
	.cfi_offset 30, -168
	mov	x8, x2
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x23, x24, [sp, 48]
	.cfi_offset 19, -160
	.cfi_offset 20, -152
	.cfi_offset 23, -128
	.cfi_offset 24, -120
	add	x24, x0, 32
	stp	x27, x28, [sp, 80]
	.cfi_offset 27, -96
	.cfi_offset 28, -88
	mov	x27, x0
	str	w6, [sp, 124]
	str	x1, [sp, 152]
	stp	x2, x3, [x0, 16]
	sxtw	x2, w4
	str	w5, [x0, 8]
	udiv	x1, x3, x2
	stp	w4, w1, [x0]
	mul	w0, w4, w5
	ldr	x3, [x24, 8]
	ldr	x4, [x27, 32]
	mul	w0, w0, w1
	sub	x1, x3, x4
	sxtw	x0, w0
	asr	x1, x1, 2
	cmp	x0, x1
	bhi	.L662
	bcs	.L535
	add	x0, x4, x0, lsl 2
	cmp	x3, x0
	beq	.L535
	str	x0, [x24, 8]
.L535:
	add	x0, x27, 56
	str	x0, [sp, 128]
	mul	x2, x2, x8
	ldp	x0, x3, [x27, 56]
	sub	x1, x3, x0
	cmp	x2, x1
	bhi	.L663
.L538:
	bcc	.L664
.L539:
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	mov	x2, 23
	adrp	x1, .LC7
	add	x1, x1, :lo12:.LC7
.LEHB20:
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	w1, [x27]
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	bl	_ZNSolsEi
	mov	x19, x0
	mov	x2, 7
	adrp	x1, .LC8
	add	x1, x1, :lo12:.LC8
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	w1, [x27, 4]
	mov	x0, x19
	bl	_ZNSolsEi
	mov	x19, x0
	mov	x2, 7
	adrp	x1, .LC9
	add	x1, x1, :lo12:.LC9
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	w1, [x27, 8]
	mov	x0, x19
	bl	_ZNSolsEi
	mov	x19, x0
	mov	x2, 8
	adrp	x1, .LC10
	add	x1, x1, :lo12:.LC10
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	w1, [sp, 124]
	mov	x0, x19
	bl	_ZNSolsEi
	mov	x2, 1
	adrp	x1, .LC11
	add	x1, x1, :lo12:.LC11
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	w0, [x27]
	cmp	w0, 0
	ble	.L593
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	mov	x20, 0
	stp	x21, x22, [sp, 32]
	.cfi_offset 22, -136
	.cfi_offset 21, -144
	stp	x25, x26, [sp, 64]
	.cfi_offset 26, -104
	.cfi_offset 25, -112
	str	d15, [sp, 96]
	.cfi_offset 79, -80
	str	x0, [sp, 144]
	mov	w0, 2139095039
	fmov	s15, w0
.L540:
	ldr	x19, [sp, 144]
	mov	x2, 26
	adrp	x0, .LC13
	add	x1, x0, :lo12:.LC13
	mov	x0, x19
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	add	w1, w20, 1
	mov	x0, x19
	bl	_ZNSolsEi
	mov	x19, x0
	mov	x2, 1
	adrp	x1, .LC14
	add	x1, x1, :lo12:.LC14
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	w1, [x27]
	mov	x0, x19
	mov	w23, w20
	mov	w28, w20
	bl	_ZNSolsEi
	mov	x2, 4
	adrp	x1, .LC15
	add	x1, x1, :lo12:.LC15
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	w25, [x27, 4]
	mov	x0, 2305843009213693951
	ldr	x26, [x27, 16]
	sxtw	x22, w25
	mul	x1, x22, x26
	cmp	x1, x0
	bhi	.L665
	mov	x19, 0
	cbz	x1, .L542
	lsl	x21, x1, 2
	str	x1, [sp, 136]
	mov	x0, x21
	bl	_Znwm
.LEHE20:
	ldr	x1, [sp, 136]
	str	wzr, [x0]
	mov	x19, x0
	cmp	x1, 1
	beq	.L542
	sub	x2, x21, #4
	add	x0, x0, 4
	mov	w1, 0
	bl	memset
.L542:
	cbz	x26, .L548
	ldr	x1, [sp, 152]
	mul	w0, w25, w28
	ldr	x5, [x27, 24]
	lsl	x2, x22, 2
	mov	x4, x19
	add	x22, x1, w0, sxtw 2
	mov	x21, 0
.L547:
	mov	x1, x22
	mov	x0, x4
	str	x2, [sp, 136]
	add	x21, x21, 1
	str	x5, [sp, 160]
	bl	memcpy
	ldr	x5, [sp, 160]
	ldr	x2, [sp, 136]
	add	x22, x22, x5, lsl 2
	add	x4, x0, x2
	cmp	x26, x21
	bne	.L547
.L548:
	ldr	w5, [x27, 8]
	mov	w22, 0
	ldr	x0, [x24]
	mul	w5, w28, w5
	mul	w5, w5, w25
	add	x21, x0, w5, sxtw 2
	add	w0, w23, 42
	bl	srand
	ldr	w23, [x27, 8]
	cmp	w23, 0
	ble	.L546
.L545:
	bl	rand
	sxtw	x0, w0
	ldr	x4, [x27, 16]
	ldr	w1, [x27, 4]
	sbfiz	x2, x1, 2, 32
	mul	w3, w1, w22
	add	w22, w22, 1
	udiv	x1, x0, x4
	msub	x1, x1, x4, x0
	add	x0, x21, w3, sxtw 2
	madd	x1, x1, x2, x19
	bl	memcpy
	ldr	w23, [x27, 8]
	cmp	w23, w22
	bgt	.L545
.L546:
	ldr	x26, [x27, 16]
	mov	x0, 2305843009213693951
	cmp	x26, x0
	bhi	.L666
	cbz	x26, .L551
	lsl	x25, x26, 2
	mov	x0, x25
.LEHB21:
	bl	_Znwm
.LEHE21:
	str	wzr, [x0]
	mov	x22, x0
	cmp	x26, 1
	beq	.L552
	sub	x2, x25, #4
	add	x0, x0, 4
	mov	w1, 0
	bl	memset
	ldr	w0, [sp, 124]
	cmp	w0, 0
	ble	.L557
	ldr	w23, [x27, 8]
.L555:
	str	wzr, [sp, 136]
.L558:
	cbz	x26, .L667
.L610:
	ldr	w28, [x27, 4]
	mov	x10, 0
	ldr	x26, [x27, 16]
	sub	w3, w28, #1
	sxtw	x11, w28
	lsr	w3, w3, 2
	add	w3, w3, 1
	ubfiz	x3, x3, 4, 31
	.p2align 5,,15
.L564:
	cmp	w23, 0
	ble	.L604
	mul	x2, x11, x10
	fmov	s28, s15
	mov	w8, 0
	mov	w9, 0
	add	x2, x19, x2, lsl 2
	.p2align 5,,15
.L563:
	cmp	w28, 0
	ble	.L605
	mul	w1, w28, w8
	mov	x0, 0
	movi	v30.4s, 0
	add	x1, x21, x1, lsl 2
	.p2align 5,,15
.L561:
	ldr	q31, [x2, x0]
	ldr	q29, [x1, x0]
	add	x0, x0, 16
	fsub	v31.4s, v31.4s, v29.4s
	fmul	v31.4s, v31.4s, v31.4s
	fadd	v30.4s, v30.4s, v31.4s
	cmp	x0, x3
	bne	.L561
	dup	d31, v30.d[1]
	fadd	v31.2s, v31.2s, v30.2s
.L560:
	faddp	v31.2s, v31.2s, v31.2s
	fcmpe	s28, s31
	bgt	.L606
.L562:
	add	w8, w8, 1
	cmp	w23, w8
	bgt	.L563
	str	w9, [x22, x10, lsl 2]
	add	x10, x10, 1
	cmp	x26, x10
	bhi	.L564
.L587:
	mul	w0, w23, w28
	mov	x1, 2305843009213693951
	sxtw	x0, w0
	cmp	x0, x1
	bhi	.L668
	cbz	x0, .L669
	lsl	x2, x0, 2
	str	x2, [sp, 160]
	mov	x0, x2
.LEHB22:
	bl	_Znwm
.LEHE22:
	ldr	x2, [sp, 160]
	mov	w1, 0
	mov	x25, x0
	bl	memset
	sxtw	x0, w23
	mov	x1, 2305843009213693951
	cmp	x0, x1
	bhi	.L567
.L568:
	ubfiz	x2, x0, 2, 32
	str	x2, [sp, 168]
	mov	x0, x2
.LEHB23:
	bl	_Znwm
.LEHE23:
	ldr	x2, [sp, 168]
	mov	w1, 0
	str	x0, [sp, 160]
	bl	memset
	ldr	x8, [sp, 160]
	sxtw	x10, w28
	cbz	x26, .L571
.L569:
	sxtw	x10, w28
	sbfiz	x3, x28, 2, 32
	mov	x2, x19
	mov	x9, 0
	.p2align 5,,15
.L573:
	ldr	w0, [x22, x9, lsl 2]
	sbfiz	x11, x0, 2, 32
	ldr	w1, [x8, x11]
	add	w1, w1, 1
	str	w1, [x8, x11]
	cmp	w28, 0
	ble	.L576
	mul	w0, w28, w0
	add	x1, x25, w0, sxtw 2
	mov	x0, 0
	.p2align 5,,15
.L575:
	ldr	s31, [x1, x0]
	ldr	s30, [x2, x0]
	fadd	s31, s31, s30
	str	s31, [x1, x0]
	add	x0, x0, 4
	cmp	x0, x3
	bne	.L575
.L576:
	add	x9, x9, 1
	add	x2, x2, x3
	cmp	x9, x26
	bcc	.L573
	cmp	w23, 0
	ble	.L577
.L571:
	lsl	x3, x10, 2
	mov	w9, 0
	mov	x1, 0
	fmov	s29, 1.0e+0
	b	.L579
.L583:
	add	x1, x1, 1
	add	w9, w9, w28
	cmp	w23, w1
	ble	.L577
.L579:
	ldr	w0, [x8, x1, lsl 2]
	cmp	w0, 0
	ble	.L583
	cmp	w28, 0
	ble	.L582
.L581:
	scvtf	s30, w0
	ubfiz	x2, x9, 2, 32
	add	x6, x25, x2
	add	x2, x21, x2
	mov	x0, 0
	fdiv	s30, s29, s30
	.p2align 5,,15
.L584:
	ldr	s31, [x6, x0]
	fmul	s31, s31, s30
	str	s31, [x2, x0]
	add	x0, x0, 4
	cmp	x0, x3
	bne	.L584
	add	x1, x1, 1
	cmp	w23, w1
	ble	.L577
	ldr	w0, [x8, x1, lsl 2]
	add	w9, w9, w28
	cmp	w0, 0
	bgt	.L581
	add	x1, x1, 1
	add	w9, w9, w28
	cmp	w23, w1
	bgt	.L579
.L577:
	cbz	x8, .L585
	mov	x0, x8
	bl	_ZdlPv
.L585:
	cbz	x25, .L570
	mov	x0, x25
	bl	_ZdlPv
.L570:
	ldr	w0, [sp, 136]
	ldr	w1, [sp, 124]
	add	w0, w0, 1
	str	w0, [sp, 136]
	ldr	x26, [x27, 16]
	cmp	w1, w0
	ble	.L586
.L670:
	ldr	w23, [x27, 8]
	cbnz	x26, .L610
.L667:
	ldr	w28, [x27, 4]
	b	.L587
.L582:
	add	x0, x1, 1
	cmp	w23, w0
	ble	.L577
	add	x1, x1, 2
	cmp	w23, w1
	ble	.L577
	ldr	w0, [x8, x1, lsl 2]
	add	w9, w9, w28, lsl 1
	cmp	w0, 0
	ble	.L583
	b	.L582
	.p2align 2,,3
.L606:
	fmov	s28, s31
	mov	w9, w8
	b	.L562
	.p2align 2,,3
.L605:
	movi	v31.2s, 0
	b	.L560
.L604:
	mov	w9, 0
	str	w9, [x22, x10, lsl 2]
	add	x10, x10, 1
	cmp	x26, x10
	bhi	.L564
	b	.L587
.L669:
	sxtw	x0, w23
	mov	x25, 0
	cmp	x0, x1
	bhi	.L567
	cbnz	x0, .L568
	mov	x8, 0
	cbnz	x26, .L569
	ldr	w0, [sp, 136]
	ldr	w1, [sp, 124]
	add	w0, w0, 1
	str	w0, [sp, 136]
	ldr	x26, [x27, 16]
	cmp	w1, w0
	bgt	.L670
.L586:
	cbz	x26, .L588
.L557:
	mov	x0, 0
.L589:
	ldr	x2, [sp, 128]
	ldrsw	x1, [x27]
	ldr	x2, [x2]
	madd	x1, x1, x0, x2
	ldr	w2, [x22, x0, lsl 2]
	add	x0, x0, 1
	strb	w2, [x1, x20]
	ldr	x1, [x27, 16]
	cmp	x1, x0
	bhi	.L589
.L590:
	mov	x0, x22
	bl	_ZdlPv
.L556:
	cbz	x19, .L592
	mov	x0, x19
	bl	_ZdlPv
.L592:
	ldr	w0, [x27]
	add	x20, x20, 1
	cmp	w0, w20
	bgt	.L540
	ldp	x21, x22, [sp, 32]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 64]
	.cfi_restore 26
	.cfi_restore 25
	ldr	d15, [sp, 96]
	.cfi_restore 79
.L593:
	ldp	x19, x20, [sp, 16]
	mov	x2, 18
	ldp	x23, x24, [sp, 48]
	adrp	x1, .LC12
	ldp	x27, x28, [sp, 80]
	add	x1, x1, :lo12:.LC12
	ldp	x29, x30, [sp], 176
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
.LEHB24:
	b	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
.L551:
	.cfi_def_cfa_offset 176
	.cfi_offset 19, -160
	.cfi_offset 20, -152
	.cfi_offset 21, -144
	.cfi_offset 22, -136
	.cfi_offset 23, -128
	.cfi_offset 24, -120
	.cfi_offset 25, -112
	.cfi_offset 26, -104
	.cfi_offset 27, -96
	.cfi_offset 28, -88
	.cfi_offset 29, -176
	.cfi_offset 30, -168
	.cfi_offset 79, -80
	ldr	w0, [sp, 124]
	mov	x22, 0
	cmp	w0, 0
	ble	.L556
	str	wzr, [sp, 136]
	b	.L558
.L588:
	cbz	x22, .L556
	b	.L590
	.p2align 2,,3
.L552:
	ldr	w0, [sp, 124]
	cmp	w0, 0
	ble	.L557
	ldr	w23, [x27, 8]
	b	.L555
.L662:
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 79
	sub	x1, x0, x1
	mov	x0, x24
	bl	_ZNSt6vectorIfSaIfEE17_M_default_appendEm
	add	x0, x27, 56
	str	x0, [sp, 128]
	ldr	x8, [x27, 16]
	ldp	x0, x3, [x27, 56]
	ldrsw	x2, [x27]
	mul	x2, x2, x8
	sub	x1, x3, x0
	cmp	x2, x1
	bls	.L538
.L663:
	ldr	x0, [sp, 128]
	sub	x1, x2, x1
	bl	_ZNSt6vectorIhSaIhEE17_M_default_appendEm
	b	.L539
.L664:
	add	x0, x0, x2
	cmp	x3, x0
	beq	.L539
	ldr	x1, [sp, 128]
	str	x0, [x1, 8]
	b	.L539
.L665:
	.cfi_offset 21, -144
	.cfi_offset 22, -136
	.cfi_offset 25, -112
	.cfi_offset 26, -104
	.cfi_offset 79, -80
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
	bl	_ZSt20__throw_length_errorPKc
.L613:
	mov	x20, x0
	cbz	x25, .L596
	mov	x0, x25
	bl	_ZdlPv
.L596:
	cbz	x22, .L598
.L671:
	mov	x0, x22
	bl	_ZdlPv
.L598:
	cbz	x19, .L599
.L672:
	mov	x0, x19
	bl	_ZdlPv
.L599:
	mov	x0, x20
	bl	_Unwind_Resume
.LEHE24:
.L567:
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
.LEHB25:
	bl	_ZSt20__throw_length_errorPKc
.LEHE25:
.L612:
	mov	x20, x0
	cbnz	x22, .L671
	b	.L598
.L668:
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
.LEHB26:
	bl	_ZSt20__throw_length_errorPKc
.LEHE26:
.L611:
	mov	x20, x0
	cbnz	x19, .L672
	b	.L599
.L666:
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
.LEHB27:
	bl	_ZSt20__throw_length_errorPKc
.LEHE27:
	.cfi_endproc
.LFE10135:
	.section	.gcc_except_table
.LLSDA10135:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE10135-.LLSDACSB10135
.LLSDACSB10135:
	.uleb128 .LEHB20-.LFB10135
	.uleb128 .LEHE20-.LEHB20
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB21-.LFB10135
	.uleb128 .LEHE21-.LEHB21
	.uleb128 .L611-.LFB10135
	.uleb128 0
	.uleb128 .LEHB22-.LFB10135
	.uleb128 .LEHE22-.LEHB22
	.uleb128 .L612-.LFB10135
	.uleb128 0
	.uleb128 .LEHB23-.LFB10135
	.uleb128 .LEHE23-.LEHB23
	.uleb128 .L613-.LFB10135
	.uleb128 0
	.uleb128 .LEHB24-.LFB10135
	.uleb128 .LEHE24-.LEHB24
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB25-.LFB10135
	.uleb128 .LEHE25-.LEHB25
	.uleb128 .L613-.LFB10135
	.uleb128 0
	.uleb128 .LEHB26-.LFB10135
	.uleb128 .LEHE26-.LEHB26
	.uleb128 .L612-.LFB10135
	.uleb128 0
	.uleb128 .LEHB27-.LFB10135
	.uleb128 .LEHE27-.LEHB27
	.uleb128 .L611-.LFB10135
	.uleb128 0
.LLSDACSE10135:
	.section	.text._ZN7PQIndex5buildEPKfmmiii,"axG",@progbits,_ZN7PQIndex5buildEPKfmmiii,comdat
	.size	_ZN7PQIndex5buildEPKfmmiii, .-_ZN7PQIndex5buildEPKfmmiii
	.section	.text._ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED2Ev,"axG",@progbits,_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED5Ev,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED2Ev
	.type	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED2Ev, %function
_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED2Ev:
.LFB11075:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -16
	.cfi_offset 20, -8
	mov	x20, x0
	ldr	x19, [x0, 16]
	cbz	x19, .L674
	.p2align 5,,15
.L675:
	mov	x0, x19
	ldr	x19, [x19]
	bl	_ZdlPv
	cbnz	x19, .L675
.L674:
	mov	x1, x20
	ldr	x0, [x1], 48
	cmp	x0, x1
	beq	.L673
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	b	_ZdlPv
	.p2align 2,,3
.L673:
	.cfi_restore_state
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE11075:
	.size	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED2Ev, .-_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED2Ev
	.weak	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED1Ev
	.set	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED1Ev,_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED2Ev
	.section	.text._ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv,"axG",@progbits,_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	.type	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv, %function
_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv:
.LFB11450:
	.cfi_startproc
	ldp	x1, x2, [x0]
	sub	x3, x2, x1
	sub	x9, x2, #8
	cmp	x3, 8
	bgt	.L707
	str	x9, [x0, 8]
	ret
	.p2align 2,,3
.L707:
	ldr	s30, [x1]
	sub	x12, x9, x1
	ldr	w3, [x1, 4]
	ldr	s31, [x2, -8]
	asr	x8, x12, 3
	ldr	w10, [x2, -4]
	str	s30, [x2, -8]
	str	w3, [x2, -4]
	cmp	x12, 16
	ble	.L684
	sub	x8, x8, #1
	mov	x3, 0
	asr	x8, x8, 1
	b	.L687
	.p2align 2,,3
.L697:
	mov	x3, x4
.L687:
	add	x2, x3, 1
	lsl	x4, x2, 1
	lsl	x7, x2, 4
	sub	x5, x4, #1
	add	x2, x1, x2, lsl 4
	lsl	x6, x5, 3
	ldr	s30, [x1, x7]
	ldr	s0, [x1, x6]
	fcmpe	s0, s30
	bgt	.L700
.L685:
	lsl	x5, x3, 3
	add	x3, x1, x3, lsl 3
	str	s30, [x1, x5]
	ldr	w5, [x2, 4]
	str	w5, [x3, 4]
	cmp	x8, x4
	bgt	.L697
	tbz	x12, 3, .L691
.L706:
	sub	x3, x4, #1
	add	x3, x3, x3, lsr 63
	asr	x3, x3, 1
	cbz	x4, .L690
	.p2align 5,,15
.L696:
	lsl	x2, x3, 3
	add	x5, x1, x3, lsl 3
	lsl	x6, x4, 3
	ldr	s29, [x1, x2]
	add	x2, x1, x4, lsl 3
	fcmpe	s29, s31
	bmi	.L701
.L690:
	str	w10, [x2, 4]
	str	s31, [x2]
.L709:
	str	x9, [x0, 8]
	ret
	.p2align 2,,3
.L701:
	ldr	w4, [x5, 4]
	str	s29, [x1, x6]
	str	w4, [x2, 4]
	sub	x2, x3, #1
	mov	x4, x3
	add	x2, x2, x2, lsr 63
	cbz	x3, .L708
	asr	x3, x2, 1
	b	.L696
	.p2align 2,,3
.L700:
	fmov	s30, s0
	add	x2, x1, x5, lsl 3
	mov	x4, x5
	b	.L685
	.p2align 2,,3
.L691:
	asr	x12, x12, 4
	sub	x12, x12, #1
	cmp	x4, x12
	bne	.L706
.L693:
	lsl	x5, x4, 1
	add	x5, x5, 1
	lsl	x6, x5, 3
	add	x3, x1, x5, lsl 3
	ldr	s30, [x1, x6]
	ldr	w3, [x3, 4]
	str	w3, [x2, 4]
	mov	x3, x4
	mov	x4, x5
	str	s30, [x2]
	b	.L696
	.p2align 2,,3
.L708:
	mov	x2, x5
	str	s31, [x2]
	str	w10, [x2, 4]
	b	.L709
	.p2align 2,,3
.L684:
	mov	x2, x1
	tbnz	x12, 3, .L690
	cmp	x12, 16
	bne	.L690
	mov	x4, 0
	b	.L693
	.cfi_endproc
.LFE11450:
	.size	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv, .-_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji
	.type	_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji, %function
_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji:
.LFB11469:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA11469
	sub	sp, sp, #112
	.cfi_def_cfa_offset 112
	stp	x29, x30, [sp, 48]
	.cfi_offset 29, -64
	.cfi_offset 30, -56
	add	x29, sp, 48
	stp	x21, x22, [sp, 80]
	.cfi_offset 21, -32
	.cfi_offset 22, -24
	mov	x22, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	stp	x19, x20, [sp, 64]
	.cfi_offset 19, -48
	.cfi_offset 20, -40
	mov	w20, w2
	stp	x23, x24, [sp, 96]
	.cfi_offset 23, -16
	.cfi_offset 24, -8
	ldr	x2, [x0]
	str	x2, [sp, 40]
	mov	x2, 0
	ldr	x0, [x22, 192]
	mov	w2, 48
	umaddl	x21, w1, w2, x0
	str	x21, [sp, 24]
	cbz	x21, .L727
	mov	x19, x8
	uxtw	x23, w1
	mov	x0, x21
	bl	pthread_mutex_lock
	cbnz	w0, .L728
	mov	w0, 1
	strb	w0, [sp, 32]
	cbnz	w20, .L715
	ldr	x0, [x22, 24]
	ldr	x1, [x22, 240]
	ldr	x20, [x22, 256]
	madd	x0, x23, x0, x1
	add	x20, x20, x0
	ldrh	w2, [x20]
	stp	xzr, xzr, [x19]
	str	xzr, [x19, 16]
	cbz	x2, .L729
.L717:
	ubfiz	x23, x2, 2, 32
	str	x2, [sp, 8]
	mov	x0, x23
.LEHB28:
	bl	_Znwm
.LEHE28:
	ldr	x2, [sp, 8]
	mov	x22, x0
	add	x24, x0, x23
	str	x22, [x19]
	str	wzr, [x0], 4
	str	x24, [x19, 16]
	cmp	x2, 1
	beq	.L722
	sub	x2, x23, #4
	mov	w1, 0
	bl	memset
	mov	x2, x23
	mov	x0, x24
.L718:
	add	x1, x20, 4
	str	x0, [x19, 8]
	mov	x0, x22
	bl	memcpy
	mov	x0, x21
	bl	pthread_mutex_unlock
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 40]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L724
	ldp	x29, x30, [sp, 48]
	mov	x0, x19
	ldp	x19, x20, [sp, 64]
	ldp	x21, x22, [sp, 80]
	ldp	x23, x24, [sp, 96]
	add	sp, sp, 112
	.cfi_remember_state
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L715:
	.cfi_restore_state
	ldr	x0, [x22, 264]
	sub	w20, w20, #1
	ldr	x1, [x22, 32]
	sxtw	x20, w20
	ldr	x0, [x0, x23, lsl 3]
	madd	x20, x20, x1, x0
	ldrh	w2, [x20]
	stp	xzr, xzr, [x19]
	str	xzr, [x19, 16]
	cbnz	x2, .L717
.L729:
	mov	x22, 0
	mov	x0, 0
	str	xzr, [x19]
	str	xzr, [x19, 16]
	b	.L718
	.p2align 2,,3
.L722:
	mov	x2, 4
	b	.L718
.L728:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 40]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L714
.L724:
	bl	__stack_chk_fail
.L723:
	mov	x19, x0
	add	x0, sp, 24
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 40]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L724
	mov	x0, x19
.LEHB29:
	bl	_Unwind_Resume
.L727:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 40]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L724
	mov	w0, 1
	bl	_ZSt20__throw_system_errori
.L714:
	bl	_ZSt20__throw_system_errori
.LEHE29:
	.cfi_endproc
.LFE11469:
	.section	.gcc_except_table
.LLSDA11469:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE11469-.LLSDACSB11469
.LLSDACSB11469:
	.uleb128 .LEHB28-.LFB11469
	.uleb128 .LEHE28-.LEHB28
	.uleb128 .L723-.LFB11469
	.uleb128 0
	.uleb128 .LEHB29-.LFB11469
	.uleb128 .LEHE29-.LEHB29
	.uleb128 0
	.uleb128 0
.LLSDACSE11469:
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji,comdat
	.size	_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji, .-_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE
	.type	_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE, %function
_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE:
.LFB10726:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10726
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	stp	x27, x28, [sp, 80]
	.cfi_offset 27, -16
	.cfi_offset 28, -8
	mov	x28, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	mov	x19, x1
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	sub	sp, sp, #560
	.cfi_def_cfa_offset 656
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	.cfi_offset 25, -32
	.cfi_offset 26, -24
	add	x20, sp, 32
	ldr	x1, [x0]
	str	x1, [sp, 552]
	mov	x1, 0
	add	x0, sp, 288
	adrp	x25, :got:_ZTVSt9basic_iosIcSt11char_traitsIcEE
	ldr	x25, [x25, :got_lo12:_ZTVSt9basic_iosIcSt11char_traitsIcEE]
	bl	_ZNSt8ios_baseC2Ev
	strh	wzr, [sp, 512]
	movi	v31.4s, 0
	add	x0, x25, 16
	str	x0, [sp, 288]
	add	x0, sp, 520
	str	xzr, [sp, 504]
	str	q31, [x0]
	add	x0, sp, 536
	str	q31, [x0]
	adrp	x0, :got:_ZTTSt14basic_ofstreamIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTTSt14basic_ofstreamIcSt11char_traitsIcEE]
	ldp	x26, x0, [x0, 8]
	mov	x1, x0
	str	x1, [sp, 8]
	ldr	x0, [x26, -24]
	str	x26, [sp, 32]
	str	x1, [x20, x0]
	add	x0, x20, x0
	mov	x1, 0
.LEHB30:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE4initEPSt15basic_streambufIcS1_E
.LEHE30:
	adrp	x23, :got:_ZTVSt14basic_ofstreamIcSt11char_traitsIcEE
	ldr	x23, [x23, :got_lo12:_ZTVSt14basic_ofstreamIcSt11char_traitsIcEE]
	add	x0, x23, 24
	str	x0, [sp, 32]
	add	x0, x23, 64
	str	x0, [sp, 288]
	add	x0, sp, 40
.LEHB31:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEEC1Ev
.LEHE31:
	add	x1, sp, 40
	add	x0, sp, 288
.LEHB32:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE4initEPSt15basic_streambufIcS1_E
	ldr	x1, [x19]
	add	x0, sp, 40
	mov	w2, 20
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE4openEPKcSt13_Ios_Openmode
	mov	x2, x0
	ldr	x0, [sp, 32]
	ldr	x1, [x0, -24]
	add	x0, x20, x1
	cbz	x2, .L763
	mov	w1, 0
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
.LEHE32:
.L732:
	add	x1, x28, 240
	mov	x0, x20
	mov	x2, 8
.LEHB33:
	bl	_ZNSo5writeEPKcl
	mov	x2, 8
	mov	x0, x20
	add	x1, x28, x2
	bl	_ZNSo5writeEPKcl
	add	x21, x28, 16
	mov	x0, x20
	mov	x1, x21
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 24
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 248
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 232
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 104
	mov	x0, x20
	mov	x2, 4
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 216
	mov	x0, x20
	mov	x2, 4
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 56
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 64
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 48
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 88
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	add	x1, x28, 72
	mov	x0, x20
	mov	x2, 8
	bl	_ZNSo5writeEPKcl
	ldr	x1, [x28, 256]
	ldar	x2, [x21]
	ldr	x0, [x28, 24]
	mul	x2, x2, x0
	mov	x0, x20
	bl	_ZNSo5writeEPKcl
	mov	x19, 0
	ldar	x0, [x21]
	cmp	x19, x0
	bcs	.L764
	.p2align 5,,15
.L741:
	ldr	x0, [x28, 272]
	ldr	w1, [x0, x19, lsl 2]
	mov	w0, 0
	cmp	w1, 0
	ble	.L739
	ldr	x0, [x28, 32]
	mul	w0, w1, w0
.L739:
	add	x1, sp, 28
	mov	x2, 4
	str	w0, [sp, 28]
	mov	x0, x20
	bl	_ZNSo5writeEPKcl
	ldr	w2, [sp, 28]
	cbnz	w2, .L765
	add	x19, x19, 1
.L767:
	ldar	x0, [x21]
	cmp	x19, x0
	bcc	.L741
.L764:
	add	x0, sp, 40
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv
.LEHE33:
	cbz	x0, .L766
.L742:
	add	x0, x23, 24
	str	x0, [sp, 32]
	adrp	x0, :got:_ZTVSt13basic_filebufIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt13basic_filebufIcSt11char_traitsIcEE]
	add	x23, x23, 64
	str	x23, [sp, 288]
	add	x0, x0, 16
	str	x0, [sp, 40]
	add	x0, sp, 40
.LEHB34:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv
.LEHE34:
.L744:
	add	x0, sp, 152
	bl	_ZNSt12__basic_fileIcED1Ev
	adrp	x0, :got:_ZTVSt15basic_streambufIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt15basic_streambufIcSt11char_traitsIcEE]
	add	x25, x25, 16
	add	x0, x0, 16
	str	x0, [sp, 40]
	add	x0, sp, 96
	bl	_ZNSt6localeD1Ev
	ldr	x0, [x26, -24]
	str	x26, [sp, 32]
	ldr	x1, [sp, 8]
	str	x1, [x20, x0]
	add	x0, sp, 288
	str	x25, [sp, 288]
	bl	_ZNSt8ios_baseD2Ev
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 552]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L760
	add	sp, sp, 560
	.cfi_remember_state
	.cfi_def_cfa_offset 96
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L765:
	.cfi_restore_state
	ldr	x0, [x28, 264]
	uxtw	x2, w2
	ldr	x1, [x0, x19, lsl 3]
	mov	x0, x20
.LEHB35:
	bl	_ZNSo5writeEPKcl
.LEHE35:
	add	x19, x19, 1
	b	.L767
	.p2align 2,,3
.L763:
	ldr	w1, [x0, 32]
	orr	w1, w1, 4
.LEHB36:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
.LEHE36:
	b	.L732
	.p2align 2,,3
.L766:
	ldr	x0, [sp, 32]
	ldr	x0, [x0, -24]
	add	x0, x20, x0
	ldr	w1, [x0, 32]
	orr	w1, w1, 4
.LEHB37:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
.LEHE37:
	b	.L742
.L750:
	mov	x19, x0
	mov	x0, x20
	bl	_ZNSt14basic_ofstreamIcSt11char_traitsIcEED1Ev
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 552]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	beq	.L746
.L760:
	bl	__stack_chk_fail
.L752:
	mov	x19, x0
	b	.L735
.L751:
	mov	x19, x0
.L736:
	add	x0, sp, 288
	add	x25, x25, 16
	str	x25, [sp, 288]
	bl	_ZNSt8ios_baseD2Ev
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 552]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L760
.L746:
	mov	x0, x19
.LEHB38:
	bl	_Unwind_Resume
.LEHE38:
.L753:
	mov	x19, x0
	add	x0, sp, 40
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEED1Ev
.L735:
	ldr	x0, [x26, -24]
	str	x26, [sp, 32]
	ldr	x1, [sp, 8]
	str	x1, [x20, x0]
	b	.L736
.L754:
	bl	__cxa_begin_catch
	bl	__cxa_end_catch
	b	.L744
	.cfi_endproc
.LFE10726:
	.section	.gcc_except_table
	.align	2
.LLSDA10726:
	.byte	0xff
	.byte	0x9b
	.uleb128 .LLSDATT10726-.LLSDATTD10726
.LLSDATTD10726:
	.byte	0x1
	.uleb128 .LLSDACSE10726-.LLSDACSB10726
.LLSDACSB10726:
	.uleb128 .LEHB30-.LFB10726
	.uleb128 .LEHE30-.LEHB30
	.uleb128 .L751-.LFB10726
	.uleb128 0
	.uleb128 .LEHB31-.LFB10726
	.uleb128 .LEHE31-.LEHB31
	.uleb128 .L752-.LFB10726
	.uleb128 0
	.uleb128 .LEHB32-.LFB10726
	.uleb128 .LEHE32-.LEHB32
	.uleb128 .L753-.LFB10726
	.uleb128 0
	.uleb128 .LEHB33-.LFB10726
	.uleb128 .LEHE33-.LEHB33
	.uleb128 .L750-.LFB10726
	.uleb128 0
	.uleb128 .LEHB34-.LFB10726
	.uleb128 .LEHE34-.LEHB34
	.uleb128 .L754-.LFB10726
	.uleb128 0x1
	.uleb128 .LEHB35-.LFB10726
	.uleb128 .LEHE35-.LEHB35
	.uleb128 .L750-.LFB10726
	.uleb128 0
	.uleb128 .LEHB36-.LFB10726
	.uleb128 .LEHE36-.LEHB36
	.uleb128 .L753-.LFB10726
	.uleb128 0
	.uleb128 .LEHB37-.LFB10726
	.uleb128 .LEHE37-.LEHB37
	.uleb128 .L750-.LFB10726
	.uleb128 0
	.uleb128 .LEHB38-.LFB10726
	.uleb128 .LEHE38-.LEHB38
	.uleb128 0
	.uleb128 0
.LLSDACSE10726:
	.byte	0x1
	.byte	0
	.align	2
	.4byte	0

.LLSDATT10726:
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE,comdat
	.size	_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE, .-_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE
	.section	.rodata._Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_.str1.8,"aMS",@progbits,1
	.align	3
.LC16:
	.string	"load data "
	.align	3
.LC17:
	.string	"dimension: "
	.align	3
.LC18:
	.string	"  number:"
	.align	3
.LC19:
	.string	"  size_per_element:"
	.section	.text._Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,"axG",@progbits,_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,comdat
	.align	2
	.p2align 5,,15
	.weak	_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_
	.type	_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_, %function
_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_:
.LFB10728:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10728
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	mov	x21, x1
	mov	x22, x2
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	sub	sp, sp, #592
	.cfi_def_cfa_offset 688
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	.cfi_offset 25, -32
	.cfi_offset 26, -24
	.cfi_offset 27, -16
	.cfi_offset 28, -8
	add	x20, sp, 48
	str	x0, [sp, 8]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 584]
	mov	x1, 0
	add	x0, sp, 312
	bl	_ZNSt8ios_baseC2Ev
	strh	wzr, [sp, 536]
	adrp	x0, :got:_ZTVSt9basic_iosIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt9basic_iosIcSt11char_traitsIcEE]
	str	x0, [sp, 24]
	movi	v31.4s, 0
	str	xzr, [sp, 528]
	add	x0, x0, 16
	str	x0, [sp, 312]
	adrp	x0, :got:_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE]
	stp	q31, q31, [sp, 544]
	ldp	x25, x0, [x0, 8]
	mov	x1, x0
	str	x1, [sp, 16]
	ldr	x0, [x25, -24]
	str	x25, [sp, 48]
	str	x1, [x20, x0]
	mov	x1, 0
	str	xzr, [sp, 56]
	ldr	x0, [x25, -24]
	add	x0, x20, x0
.LEHB39:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE4initEPSt15basic_streambufIcS1_E
.LEHE39:
	adrp	x24, :got:_ZTVSt14basic_ifstreamIcSt11char_traitsIcEE
	ldr	x24, [x24, :got_lo12:_ZTVSt14basic_ifstreamIcSt11char_traitsIcEE]
	add	x0, x24, 24
	str	x0, [sp, 48]
	add	x0, x24, 64
	str	x0, [sp, 312]
	add	x0, sp, 64
.LEHB40:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEEC1Ev
.LEHE40:
	add	x1, sp, 64
	add	x0, sp, 312
.LEHB41:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE4initEPSt15basic_streambufIcS1_E
.LEHE41:
	ldr	x0, [sp, 8]
	mov	w2, 12
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	add	x0, sp, 64
.LEHB42:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE4openEPKcSt13_Ios_Openmode
	mov	x2, x0
	ldr	x0, [sp, 48]
	ldr	x1, [x0, -24]
	add	x0, x20, x1
	cbz	x2, .L797
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	w1, 0
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
.L775:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	x1, x21
	mov	x0, x20
	mov	x2, 4
	bl	_ZNSi4readEPcl
	mov	x1, x22
	mov	x0, x20
	mov	x2, 4
	bl	_ZNSi4readEPcl
	ldr	x1, [x21]
	mov	x3, 2305843009213693950
	ldr	x2, [x22]
	mul	x0, x1, x2
	cmp	x0, x3
	bhi	.L776
	lsl	x0, x0, 2
	stp	x1, x2, [sp, 32]
	bl	_Znam
	ldp	x1, x2, [sp, 32]
	mov	x23, x0
	mov	x28, 0
	cbnz	x1, .L777
	b	.L778
	.p2align 2,,3
.L798:
	ldr	x2, [x22]
.L777:
	lsl	x2, x2, 2
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	x0, x20
	madd	x1, x2, x28, x23
	bl	_ZNSi4readEPcl
	ldr	x0, [x21]
	add	x28, x28, 1
	cmp	x0, x28
	bhi	.L798
.L778:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	add	x0, sp, 64
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv
	cbz	x0, .L799
.L780:
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	adrp	x1, .LC16
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	add	x1, x1, :lo12:.LC16
	mov	x2, 10
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	x0, [sp, 8]
	ldp	x1, x2, [x0]
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	adrp	x28, .LC11
	mov	x2, 1
	add	x1, x28, :lo12:.LC11
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	adrp	x1, .LC17
	mov	x2, 11
	add	x1, x1, :lo12:.LC17
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	x1, [x22]
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	bl	_ZNSo9_M_insertImEERSoT_
	adrp	x1, .LC18
	mov	x22, x0
	add	x1, x1, :lo12:.LC18
	mov	x2, 9
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	x1, [x21]
	mov	x0, x22
	bl	_ZNSo9_M_insertImEERSoT_
	adrp	x1, .LC19
	mov	x21, x0
	add	x1, x1, :lo12:.LC19
	mov	x2, 19
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	mov	x0, x21
	mov	x1, 4
	bl	_ZNSo9_M_insertImEERSoT_
	add	x1, x28, :lo12:.LC11
	mov	x2, 1
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
.LEHE42:
	add	x0, x24, 24
	str	x0, [sp, 48]
	adrp	x0, :got:_ZTVSt13basic_filebufIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt13basic_filebufIcSt11char_traitsIcEE]
	add	x24, x24, 64
	str	x24, [sp, 312]
	add	x0, x0, 16
	str	x0, [sp, 64]
	add	x0, sp, 64
.LEHB43:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv
.LEHE43:
.L782:
	add	x0, sp, 176
	bl	_ZNSt12__basic_fileIcED1Ev
	adrp	x0, :got:_ZTVSt15basic_streambufIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt15basic_streambufIcSt11char_traitsIcEE]
	add	x0, x0, 16
	str	x0, [sp, 64]
	add	x0, sp, 120
	bl	_ZNSt6localeD1Ev
	ldr	x0, [x25, -24]
	str	x25, [sp, 48]
	ldr	x1, [sp, 16]
	str	x1, [x20, x0]
	ldr	x0, [sp, 24]
	str	xzr, [sp, 56]
	add	x0, x0, 16
	str	x0, [sp, 312]
	add	x0, sp, 312
	bl	_ZNSt8ios_baseD2Ev
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 584]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L794
	add	sp, sp, 592
	.cfi_remember_state
	.cfi_def_cfa_offset 96
	mov	x0, x23
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L797:
	.cfi_restore_state
	ldr	w1, [x0, 32]
	orr	w1, w1, 4
.LEHB44:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
	b	.L775
	.p2align 2,,3
.L799:
	ldr	x0, [sp, 48]
	ldr	x0, [x0, -24]
	add	x0, x20, x0
	ldr	w1, [x0, 32]
	orr	w1, w1, 4
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
.LEHE44:
	b	.L780
.L776:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 584]
	ldr	x1, [x19]
	subs	x0, x0, x1
	mov	x1, 0
	beq	.L779
.L794:
	bl	__stack_chk_fail
.L791:
	bl	__cxa_begin_catch
	bl	__cxa_end_catch
	b	.L782
.L787:
	mov	x21, x0
	mov	x0, x20
	bl	_ZNSt14basic_ifstreamIcSt11char_traitsIcEED1Ev
	ldr	x0, [sp, 584]
	ldr	x1, [x19]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L794
	mov	x0, x21
.LEHB45:
	bl	_Unwind_Resume
.L790:
	mov	x19, x0
	add	x0, sp, 64
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEED1Ev
.L771:
	ldr	x0, [x25, -24]
	str	x25, [sp, 48]
	ldr	x1, [sp, 16]
	str	x1, [x20, x0]
	str	xzr, [sp, 56]
.L772:
	ldr	x0, [sp, 24]
	add	x0, x0, 16
	str	x0, [sp, 312]
	add	x0, sp, 312
	bl	_ZNSt8ios_baseD2Ev
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 584]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L794
	mov	x0, x19
	bl	_Unwind_Resume
.LEHE45:
.L788:
	mov	x19, x0
	b	.L772
.L789:
	mov	x19, x0
	b	.L771
.L779:
.LEHB46:
	bl	__cxa_throw_bad_array_new_length
.LEHE46:
	.cfi_endproc
.LFE10728:
	.section	.gcc_except_table
	.align	2
.LLSDA10728:
	.byte	0xff
	.byte	0x9b
	.uleb128 .LLSDATT10728-.LLSDATTD10728
.LLSDATTD10728:
	.byte	0x1
	.uleb128 .LLSDACSE10728-.LLSDACSB10728
.LLSDACSB10728:
	.uleb128 .LEHB39-.LFB10728
	.uleb128 .LEHE39-.LEHB39
	.uleb128 .L788-.LFB10728
	.uleb128 0
	.uleb128 .LEHB40-.LFB10728
	.uleb128 .LEHE40-.LEHB40
	.uleb128 .L789-.LFB10728
	.uleb128 0
	.uleb128 .LEHB41-.LFB10728
	.uleb128 .LEHE41-.LEHB41
	.uleb128 .L790-.LFB10728
	.uleb128 0
	.uleb128 .LEHB42-.LFB10728
	.uleb128 .LEHE42-.LEHB42
	.uleb128 .L787-.LFB10728
	.uleb128 0
	.uleb128 .LEHB43-.LFB10728
	.uleb128 .LEHE43-.LEHB43
	.uleb128 .L791-.LFB10728
	.uleb128 0x1
	.uleb128 .LEHB44-.LFB10728
	.uleb128 .LEHE44-.LEHB44
	.uleb128 .L787-.LFB10728
	.uleb128 0
	.uleb128 .LEHB45-.LFB10728
	.uleb128 .LEHE45-.LEHB45
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB46-.LFB10728
	.uleb128 .LEHE46-.LEHB46
	.uleb128 .L787-.LFB10728
	.uleb128 0
.LLSDACSE10728:
	.byte	0x1
	.byte	0
	.align	2
	.4byte	0

.LLSDATT10728:
	.section	.text._Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,"axG",@progbits,_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,comdat
	.size	_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_, .-_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_
	.section	.text._Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,"axG",@progbits,_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,comdat
	.align	2
	.p2align 5,,15
	.weak	_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_
	.type	_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_, %function
_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_:
.LFB10729:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10729
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	mov	x21, x1
	mov	x22, x2
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	sub	sp, sp, #592
	.cfi_def_cfa_offset 688
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	.cfi_offset 25, -32
	.cfi_offset 26, -24
	.cfi_offset 27, -16
	.cfi_offset 28, -8
	add	x20, sp, 48
	str	x0, [sp, 8]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 584]
	mov	x1, 0
	add	x0, sp, 312
	bl	_ZNSt8ios_baseC2Ev
	strh	wzr, [sp, 536]
	adrp	x0, :got:_ZTVSt9basic_iosIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt9basic_iosIcSt11char_traitsIcEE]
	str	x0, [sp, 24]
	movi	v31.4s, 0
	str	xzr, [sp, 528]
	add	x0, x0, 16
	str	x0, [sp, 312]
	adrp	x0, :got:_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTTSt14basic_ifstreamIcSt11char_traitsIcEE]
	stp	q31, q31, [sp, 544]
	ldp	x25, x0, [x0, 8]
	mov	x1, x0
	str	x1, [sp, 16]
	ldr	x0, [x25, -24]
	str	x25, [sp, 48]
	str	x1, [x20, x0]
	mov	x1, 0
	str	xzr, [sp, 56]
	ldr	x0, [x25, -24]
	add	x0, x20, x0
.LEHB47:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE4initEPSt15basic_streambufIcS1_E
.LEHE47:
	adrp	x24, :got:_ZTVSt14basic_ifstreamIcSt11char_traitsIcEE
	ldr	x24, [x24, :got_lo12:_ZTVSt14basic_ifstreamIcSt11char_traitsIcEE]
	add	x0, x24, 24
	str	x0, [sp, 48]
	add	x0, x24, 64
	str	x0, [sp, 312]
	add	x0, sp, 64
.LEHB48:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEEC1Ev
.LEHE48:
	add	x1, sp, 64
	add	x0, sp, 312
.LEHB49:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE4initEPSt15basic_streambufIcS1_E
.LEHE49:
	ldr	x0, [sp, 8]
	mov	w2, 12
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	add	x0, sp, 64
.LEHB50:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE4openEPKcSt13_Ios_Openmode
	mov	x2, x0
	ldr	x0, [sp, 48]
	ldr	x1, [x0, -24]
	add	x0, x20, x1
	cbz	x2, .L829
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	w1, 0
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
.L807:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	x1, x21
	mov	x0, x20
	mov	x2, 4
	bl	_ZNSi4readEPcl
	mov	x1, x22
	mov	x0, x20
	mov	x2, 4
	bl	_ZNSi4readEPcl
	ldr	x1, [x21]
	mov	x3, 2305843009213693950
	ldr	x2, [x22]
	mul	x0, x1, x2
	cmp	x0, x3
	bhi	.L808
	lsl	x0, x0, 2
	stp	x1, x2, [sp, 32]
	bl	_Znam
	ldp	x1, x2, [sp, 32]
	mov	x23, x0
	mov	x28, 0
	cbnz	x1, .L809
	b	.L810
	.p2align 2,,3
.L830:
	ldr	x2, [x22]
.L809:
	lsl	x2, x2, 2
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	x0, x20
	madd	x1, x2, x28, x23
	bl	_ZNSi4readEPcl
	ldr	x0, [x21]
	add	x28, x28, 1
	cmp	x0, x28
	bhi	.L830
.L810:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	add	x0, sp, 64
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv
	cbz	x0, .L831
.L812:
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	adrp	x1, .LC16
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	add	x1, x1, :lo12:.LC16
	mov	x2, 10
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	x0, [sp, 8]
	ldp	x1, x2, [x0]
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	adrp	x28, .LC11
	mov	x2, 1
	add	x1, x28, :lo12:.LC11
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	adrp	x1, .LC17
	mov	x2, 11
	add	x1, x1, :lo12:.LC17
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	x1, [x22]
	adrp	x0, :got:_ZSt4cerr
	ldr	x0, [x0, :got_lo12:_ZSt4cerr]
	bl	_ZNSo9_M_insertImEERSoT_
	adrp	x1, .LC18
	mov	x22, x0
	add	x1, x1, :lo12:.LC18
	mov	x2, 9
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	x1, [x21]
	mov	x0, x22
	bl	_ZNSo9_M_insertImEERSoT_
	adrp	x1, .LC19
	mov	x21, x0
	add	x1, x1, :lo12:.LC19
	mov	x2, 19
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	mov	x0, x21
	mov	x1, 4
	bl	_ZNSo9_M_insertImEERSoT_
	add	x1, x28, :lo12:.LC11
	mov	x2, 1
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
.LEHE50:
	add	x0, x24, 24
	str	x0, [sp, 48]
	adrp	x0, :got:_ZTVSt13basic_filebufIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt13basic_filebufIcSt11char_traitsIcEE]
	add	x24, x24, 64
	str	x24, [sp, 312]
	add	x0, x0, 16
	str	x0, [sp, 64]
	add	x0, sp, 64
.LEHB51:
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEE5closeEv
.LEHE51:
.L814:
	add	x0, sp, 176
	bl	_ZNSt12__basic_fileIcED1Ev
	adrp	x0, :got:_ZTVSt15basic_streambufIcSt11char_traitsIcEE
	ldr	x0, [x0, :got_lo12:_ZTVSt15basic_streambufIcSt11char_traitsIcEE]
	add	x0, x0, 16
	str	x0, [sp, 64]
	add	x0, sp, 120
	bl	_ZNSt6localeD1Ev
	ldr	x0, [x25, -24]
	str	x25, [sp, 48]
	ldr	x1, [sp, 16]
	str	x1, [x20, x0]
	ldr	x0, [sp, 24]
	str	xzr, [sp, 56]
	add	x0, x0, 16
	str	x0, [sp, 312]
	add	x0, sp, 312
	bl	_ZNSt8ios_baseD2Ev
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 584]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L826
	add	sp, sp, 592
	.cfi_remember_state
	.cfi_def_cfa_offset 96
	mov	x0, x23
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L829:
	.cfi_restore_state
	ldr	w1, [x0, 32]
	orr	w1, w1, 4
.LEHB52:
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
	b	.L807
	.p2align 2,,3
.L831:
	ldr	x0, [sp, 48]
	ldr	x0, [x0, -24]
	add	x0, x20, x0
	ldr	w1, [x0, 32]
	orr	w1, w1, 4
	bl	_ZNSt9basic_iosIcSt11char_traitsIcEE5clearESt12_Ios_Iostate
.LEHE52:
	b	.L812
.L808:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 584]
	ldr	x1, [x19]
	subs	x0, x0, x1
	mov	x1, 0
	beq	.L811
.L826:
	bl	__stack_chk_fail
.L823:
	bl	__cxa_begin_catch
	bl	__cxa_end_catch
	b	.L814
.L819:
	mov	x21, x0
	mov	x0, x20
	bl	_ZNSt14basic_ifstreamIcSt11char_traitsIcEED1Ev
	ldr	x0, [sp, 584]
	ldr	x1, [x19]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L826
	mov	x0, x21
.LEHB53:
	bl	_Unwind_Resume
.L822:
	mov	x19, x0
	add	x0, sp, 64
	bl	_ZNSt13basic_filebufIcSt11char_traitsIcEED1Ev
.L803:
	ldr	x0, [x25, -24]
	str	x25, [sp, 48]
	ldr	x1, [sp, 16]
	str	x1, [x20, x0]
	str	xzr, [sp, 56]
.L804:
	ldr	x0, [sp, 24]
	add	x0, x0, 16
	str	x0, [sp, 312]
	add	x0, sp, 312
	bl	_ZNSt8ios_baseD2Ev
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 584]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L826
	mov	x0, x19
	bl	_Unwind_Resume
.LEHE53:
.L820:
	mov	x19, x0
	b	.L804
.L821:
	mov	x19, x0
	b	.L803
.L811:
.LEHB54:
	bl	__cxa_throw_bad_array_new_length
.LEHE54:
	.cfi_endproc
.LFE10729:
	.section	.gcc_except_table
	.align	2
.LLSDA10729:
	.byte	0xff
	.byte	0x9b
	.uleb128 .LLSDATT10729-.LLSDATTD10729
.LLSDATTD10729:
	.byte	0x1
	.uleb128 .LLSDACSE10729-.LLSDACSB10729
.LLSDACSB10729:
	.uleb128 .LEHB47-.LFB10729
	.uleb128 .LEHE47-.LEHB47
	.uleb128 .L820-.LFB10729
	.uleb128 0
	.uleb128 .LEHB48-.LFB10729
	.uleb128 .LEHE48-.LEHB48
	.uleb128 .L821-.LFB10729
	.uleb128 0
	.uleb128 .LEHB49-.LFB10729
	.uleb128 .LEHE49-.LEHB49
	.uleb128 .L822-.LFB10729
	.uleb128 0
	.uleb128 .LEHB50-.LFB10729
	.uleb128 .LEHE50-.LEHB50
	.uleb128 .L819-.LFB10729
	.uleb128 0
	.uleb128 .LEHB51-.LFB10729
	.uleb128 .LEHE51-.LEHB51
	.uleb128 .L823-.LFB10729
	.uleb128 0x1
	.uleb128 .LEHB52-.LFB10729
	.uleb128 .LEHE52-.LEHB52
	.uleb128 .L819-.LFB10729
	.uleb128 0
	.uleb128 .LEHB53-.LFB10729
	.uleb128 .LEHE53-.LEHB53
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB54-.LFB10729
	.uleb128 .LEHE54-.LEHB54
	.uleb128 .L819-.LFB10729
	.uleb128 0
.LLSDACSE10729:
	.byte	0x1
	.byte	0
	.align	2
	.4byte	0

.LLSDATT10729:
	.section	.text._Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,"axG",@progbits,_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_,comdat
	.size	_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_, .-_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_
	.section	.rodata.str1.8
	.align	3
.LC20:
	.string	"./files/"
	.align	3
.LC21:
	.string	"DEEP100K.query.fbin"
	.align	3
.LC22:
	.string	"DEEP100K.gt.query.100k.top100.bin"
	.align	3
.LC23:
	.string	"DEEP100K.base.100k.fbin"
	.align	3
.LC24:
	.string	"p="
	.align	3
.LC25:
	.string	", recall="
	.align	3
.LC26:
	.string	", latency="
	.section	.text.startup,"ax",@progbits
	.align	2
	.p2align 5,,15
	.global	main
	.type	main, %function
main:
.LFB10159:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10159
	stp	x29, x30, [sp, -112]!
	.cfi_def_cfa_offset 112
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	adrp	x2, .LC20+8
	add	x2, x2, :lo12:.LC20+8
	mov	x29, sp
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	stp	d14, d15, [sp, 96]
	sub	sp, sp, #448
	.cfi_def_cfa_offset 560
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	add	x3, sp, 376
	ldr	x1, [x0]
	str	x1, [sp, 440]
	mov	x1, 0
	add	x0, sp, 392
	adrp	x1, .LC20
	add	x1, x1, :lo12:.LC20
	str	x3, [sp, 120]
	add	x19, sp, 408
	stp	xzr, xzr, [sp, 144]
	stp	xzr, xzr, [sp, 160]
	str	x0, [sp, 376]
	mov	x0, x3
.LEHB55:
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_M_constructIPKcEEvT_S8_St20forward_iterator_tag.isra.0
.LEHE55:
	ldp	x0, x1, [sp, 376]
	adrp	x2, .LC21
	mov	x8, x19
	add	x2, x2, :lo12:.LC21
.LEHB56:
	bl	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EERKS8_PKS5_.isra.0
.LEHE56:
	add	x2, sp, 168
	add	x1, sp, 144
	mov	x0, x19
.LEHB57:
	bl	_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_
.LEHE57:
	str	x0, [sp, 72]
	mov	x0, x19
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	ldp	x0, x1, [sp, 376]
	adrp	x2, .LC22
	mov	x8, x19
	add	x2, x2, :lo12:.LC22
.LEHB58:
	bl	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EERKS8_PKS5_.isra.0
.LEHE58:
	add	x2, sp, 160
	add	x1, sp, 144
	mov	x0, x19
.LEHB59:
	bl	_Z8LoadDataIiEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_
.LEHE59:
	mov	x23, x0
	mov	x0, x19
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	ldp	x0, x1, [sp, 376]
	adrp	x2, .LC23
	mov	x8, x19
	add	x2, x2, :lo12:.LC23
.LEHB60:
	bl	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EERKS8_PKS5_.isra.0
.LEHE60:
	add	x2, sp, 168
	add	x1, sp, 152
	mov	x0, x19
.LEHB61:
	bl	_Z8LoadDataIfEPT_NSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEERmS8_
.LEHE61:
	mov	x20, x0
	mov	x0, x19
	str	x20, [sp, 80]
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	ldr	x2, [sp, 152]
	mov	x0, 2000
	ldr	x3, [sp, 168]
	mov	x1, x20
	movi	v31.4s, 0
	mov	w6, 20
	mov	w5, 256
	mov	w4, 8
	str	x0, [sp, 144]
	add	x0, sp, 288
	str	x0, [sp, 48]
	stp	q31, q31, [sp, 320]
	str	q31, [sp, 352]
.LEHB62:
	bl	_ZN7PQIndex5buildEPKfmmiii
	mov	x0, 72
	bl	_Znwm
.LEHE62:
	mov	x22, x0
	adrp	x0, .LANCHOR0
	add	x0, x0, :lo12:.LANCHOR0
	mov	w2, -261
	adrp	x1, :got:_ZSt4cout
	ldr	x1, [x1, :got_lo12:_ZSt4cout]
	add	x27, sp, 248
	ldp	q29, q28, [x0]
	ldp	q31, q30, [x0, 32]
	ldr	x0, [x0, 64]
	stp	q29, q28, [x22]
	stp	q31, q30, [x22, 32]
	str	x0, [x22, 64]
	ldr	x0, [x1]
	str	x1, [sp, 128]
	str	xzr, [sp, 88]
	ldr	x0, [x0, -24]
	add	x0, x0, x1
	ldr	w1, [x0, 24]
	and	w1, w1, w2
	orr	w1, w1, 4
	str	w1, [x0, 24]
	mov	x1, 5
	str	x1, [x0, 8]
.L860:
	ldr	x1, [sp, 88]
	ldp	x21, x0, [sp, 144]
	ldr	x1, [x22, x1, lsl 3]
	cmp	x1, x0
	csel	x0, x1, x0, ls
	str	x0, [sp, 112]
	mov	x0, 576460752303423487
	cmp	x21, x0
	bhi	.L923
	cbz	x21, .L876
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	lsl	x0, x21, 4
.LEHB63:
	bl	_Znwm
.LEHE63:
	stp	xzr, xzr, [x0]
	mov	x25, x0
	add	x1, x0, x21, lsl 4
	add	x0, x0, 16
	cmp	x21, 1
	beq	.L839
.L838:
	ldp	x2, x3, [x25]
	stp	x2, x3, [x0], 16
	cmp	x1, x0
	bne	.L838
.L839:
	mov	x24, x25
	stp	x22, x25, [sp, 96]
	add	x0, sp, 176
	str	x25, [sp, 136]
	mov	x19, x27
	ldr	x25, [sp, 112]
	mov	x21, 0
	str	x0, [sp, 56]
	add	x0, sp, 208
	str	x0, [sp, 64]
	.p2align 5,,15
.L837:
	ldr	x0, [sp, 56]
	mov	x1, 0
	bl	gettimeofday
	ldr	x3, [sp, 168]
	mov	x6, x25
	ldp	x8, x0, [sp, 64]
	mov	x4, 10
	mul	x1, x3, x21
	ldr	x5, [sp, 48]
	ldr	x2, [sp, 152]
	add	x1, x0, x1, lsl 2
	ldr	x0, [sp, 80]
.LEHB64:
	bl	_Z9pq_searchPfS_mmmRK7PQIndexm
.LEHE64:
	ldp	x4, x22, [sp, 208]
	add	x0, sp, 192
	mov	x1, 0
	str	x4, [sp]
	mov	x20, 0
	mov	x26, 0
	bl	gettimeofday
	str	x24, [sp, 40]
	ldp	x27, x13, [sp, 176]
	stp	x13, x22, [sp, 24]
	ldp	x12, x28, [sp, 192]
	stp	x12, x28, [sp, 8]
	str	wzr, [sp, 248]
	stp	xzr, x19, [sp, 256]
	stp	x19, xzr, [sp, 272]
	.p2align 5,,15
.L847:
	ldr	x0, [sp, 160]
	madd	x0, x21, x0, x20
	ldr	w24, [x23, x0, lsl 2]
	cbz	x26, .L840
	mov	x22, x26
	b	.L842
	.p2align 2,,3
.L878:
	mov	x22, x0
.L842:
	ldp	x0, x2, [x22, 16]
	ldr	w1, [x22, 32]
	cmp	w24, w1
	csel	x0, x0, x2, cc
	cbnz	x0, .L878
	bcc	.L924
.L843:
	cmp	w24, w1
	bls	.L845
.L844:
	mov	w28, 1
	cmp	x22, x19
	bne	.L925
.L846:
	mov	x0, 40
.LEHB65:
	bl	_Znwm
.LEHE65:
	mov	x1, x0
	mov	x3, x19
	mov	w0, w28
	mov	x2, x22
	str	w24, [x1, 32]
	bl	_ZSt29_Rb_tree_insert_and_rebalancebPSt18_Rb_tree_node_baseS0_RS_
	ldr	x0, [sp, 280]
	ldr	x26, [sp, 256]
	add	x0, x0, 1
	str	x0, [sp, 280]
.L845:
	add	x20, x20, 1
	cmp	x20, 10
	bne	.L847
	ldp	x4, x12, [sp]
	mov	x18, 0
	ldp	x22, x24, [sp, 32]
	ldp	x28, x13, [sp, 16]
	mov	x0, x4
	sub	x2, x22, x4
	cbz	x2, .L926
	.p2align 5,,15
.L853:
	ldr	w7, [x0, 4]
	cbz	x26, .L849
	mov	x1, x26
	mov	x8, x19
	.p2align 5,,15
.L851:
	ldr	w3, [x1, 32]
	ldp	x4, x5, [x1, 16]
	cmp	w7, w3
	bls	.L881
	mov	x1, x5
	cbnz	x1, .L851
.L929:
	cmp	x8, x19
	beq	.L849
	ldr	w1, [x8, 32]
	cmp	w7, w1
	cinc	x18, x18, cs
.L849:
	sub	x22, x22, #8
	sub	x14, x22, x0
	cmp	x2, 8
	bgt	.L927
	mov	x2, x14
.L928:
	cbnz	x2, .L853
.L926:
	ucvtf	s31, x18
	fmov	s30, 1.0e+1
	mov	x1, 16960
	mov	x4, x0
	movk	x1, 0xf, lsl 16
	stp	xzr, xzr, [x24]
	mov	x20, x4
	fdiv	s30, s31, s30
	mul	x0, x12, x1
	sub	x0, x0, x13
	msub	x13, x27, x1, x28
	add	x0, x0, x13
	str	x0, [x24, 8]
	str	s30, [x24]
	cbz	x26, .L857
.L854:
	ldr	x0, [x26, 24]
	bl	_ZNSt8_Rb_treeIjjSt9_IdentityIjESt4lessIjESaIjEE8_M_eraseEPSt13_Rb_tree_nodeIjE.isra.0
	mov	x0, x26
	ldr	x26, [x26, 16]
	bl	_ZdlPv
	cbnz	x26, .L854
	mov	x4, x20
.L857:
	cbz	x4, .L856
	mov	x0, x4
	bl	_ZdlPv
.L856:
	ldr	x0, [sp, 144]
	add	x21, x21, 1
	add	x24, x24, 16
	cmp	x0, x21
	bhi	.L837
	ldr	x2, [sp, 136]
	mov	x27, x19
	ldp	x22, x25, [sp, 96]
	cbz	x0, .L882
	movi	d15, #0
	add	x0, x25, x0, lsl 4
	fmov	d14, d15
	.p2align 5,,15
.L858:
	ldr	s31, [x2]
	add	x2, x2, 16
	fcvt	d31, s31
	fadd	d14, d14, d31
	ldr	d31, [x2, -8]
	scvtf	d31, d31
	fadd	d15, d15, d31
	cmp	x0, x2
	bne	.L858
.L835:
	ldr	x19, [sp, 128]
	adrp	x1, .LC24
	mov	x2, 2
	add	x1, x1, :lo12:.LC24
	mov	x0, x19
.LEHB66:
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	x1, [sp, 112]
	mov	x0, x19
	bl	_ZNSo9_M_insertImEERSoT_
	adrp	x1, .LC25
	mov	x19, x0
	add	x1, x1, :lo12:.LC25
	mov	x2, 9
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	d0, [sp, 144]
	mov	x0, x19
	ucvtf	d0, d0
	fdiv	d0, d14, d0
	bl	_ZNSo9_M_insertIdEERSoT_
	adrp	x1, .LC26
	mov	x19, x0
	add	x1, x1, :lo12:.LC26
	mov	x2, 10
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	ldr	d0, [sp, 144]
	mov	x1, 2
	ldr	x0, [x19]
	ucvtf	d0, d0
	ldr	x0, [x0, -24]
	fdiv	d0, d15, d0
	add	x0, x19, x0
	str	x1, [x0, 8]
	mov	x0, x19
	bl	_ZNSo9_M_insertIdEERSoT_
	ldr	x1, [x0]
	mov	x2, 5
	ldr	x1, [x1, -24]
	add	x1, x0, x1
	str	x2, [x1, 8]
	adrp	x1, .LC11
	mov	x2, 1
	add	x1, x1, :lo12:.LC11
	bl	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
.LEHE66:
	cbz	x25, .L859
	mov	x0, x25
	bl	_ZdlPv
.L859:
	ldr	x0, [sp, 88]
	add	x0, x0, 1
	str	x0, [sp, 88]
	cmp	x0, 9
	bne	.L860
	mov	x0, x22
	bl	_ZdlPv
	ldr	x0, [sp, 48]
	bl	_ZN7PQIndexD1Ev
	ldr	x0, [sp, 120]
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 440]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L917
	add	sp, sp, 448
	.cfi_remember_state
	.cfi_def_cfa_offset 112
	mov	w0, 0
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	d14, d15, [sp, 96]
	ldp	x29, x30, [sp], 112
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 78
	.cfi_restore 79
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L927:
	.cfi_restore_state
	ldr	x3, [x22]
	asr	x2, x14, 3
	ldr	s31, [x0]
	mov	x1, 0
	str	w7, [x22, 4]
	str	s31, [x22]
	bl	_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0
	mov	x2, x14
	b	.L928
	.p2align 2,,3
.L881:
	mov	x8, x1
	mov	x1, x4
	cbnz	x1, .L851
	b	.L929
	.p2align 2,,3
.L924:
	ldr	x0, [sp, 264]
	cmp	x22, x0
	beq	.L844
.L874:
	mov	x0, x22
	bl	_ZSt18_Rb_tree_decrementPSt18_Rb_tree_node_base
	ldr	w1, [x0, 32]
	b	.L843
	.p2align 2,,3
.L925:
	ldr	w0, [x22, 32]
	cmp	w24, w0
	cset	w28, cc
	b	.L846
	.p2align 2,,3
.L840:
	ldr	x22, [sp, 264]
	cmp	x22, x19
	beq	.L883
	mov	x22, x19
	b	.L874
.L883:
	mov	w28, 1
	b	.L846
.L876:
	movi	d15, #0
	mov	x25, 0
	fmov	d14, d15
	b	.L835
.L882:
	movi	d15, #0
	fmov	d14, d15
	b	.L835
.L889:
	mov	x20, x0
.L870:
	mov	x0, x22
	bl	_ZdlPv
.L871:
	ldr	x0, [sp, 48]
	bl	_ZN7PQIndexD1Ev
.L862:
	ldr	x0, [sp, 120]
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	ldr	x0, [sp, 440]
	ldr	x1, [x19]
	subs	x0, x0, x1
	mov	x1, 0
	beq	.L872
.L917:
	bl	__stack_chk_fail
.L884:
.L921:
	mov	x20, x0
	mov	x0, x19
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	b	.L862
.L885:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	x20, x0
	b	.L862
.L892:
	mov	x20, x0
	cbz	x25, .L869
.L873:
	mov	x0, x25
	bl	_ZdlPv
.L869:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	b	.L870
.L923:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 440]
	ldr	x1, [x19]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L917
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
.LEHB67:
	bl	_ZSt20__throw_length_errorPKc
.LEHE67:
.L886:
	b	.L921
.L888:
	adrp	x19, :got:__stack_chk_guard
	ldr	x19, [x19, :got_lo12:__stack_chk_guard]
	mov	x20, x0
	b	.L871
.L887:
	b	.L921
.L872:
	mov	x0, x20
.LEHB68:
	bl	_Unwind_Resume
.LEHE68:
.L890:
	ldr	x20, [sp]
	mov	x21, x0
	ldp	x22, x25, [sp, 96]
	mov	x0, x26
	bl	_ZNSt8_Rb_treeIjjSt9_IdentityIjESt4lessIjESaIjEE8_M_eraseEPSt13_Rb_tree_nodeIjE.isra.0
	cbz	x20, .L866
	mov	x0, x20
	bl	_ZdlPv
.L866:
	mov	x20, x21
	b	.L873
.L891:
	ldp	x22, x25, [sp, 96]
	mov	x20, x0
	b	.L873
	.cfi_endproc
.LFE10159:
	.section	.gcc_except_table
.LLSDA10159:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE10159-.LLSDACSB10159
.LLSDACSB10159:
	.uleb128 .LEHB55-.LFB10159
	.uleb128 .LEHE55-.LEHB55
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB56-.LFB10159
	.uleb128 .LEHE56-.LEHB56
	.uleb128 .L885-.LFB10159
	.uleb128 0
	.uleb128 .LEHB57-.LFB10159
	.uleb128 .LEHE57-.LEHB57
	.uleb128 .L884-.LFB10159
	.uleb128 0
	.uleb128 .LEHB58-.LFB10159
	.uleb128 .LEHE58-.LEHB58
	.uleb128 .L885-.LFB10159
	.uleb128 0
	.uleb128 .LEHB59-.LFB10159
	.uleb128 .LEHE59-.LEHB59
	.uleb128 .L886-.LFB10159
	.uleb128 0
	.uleb128 .LEHB60-.LFB10159
	.uleb128 .LEHE60-.LEHB60
	.uleb128 .L885-.LFB10159
	.uleb128 0
	.uleb128 .LEHB61-.LFB10159
	.uleb128 .LEHE61-.LEHB61
	.uleb128 .L887-.LFB10159
	.uleb128 0
	.uleb128 .LEHB62-.LFB10159
	.uleb128 .LEHE62-.LEHB62
	.uleb128 .L888-.LFB10159
	.uleb128 0
	.uleb128 .LEHB63-.LFB10159
	.uleb128 .LEHE63-.LEHB63
	.uleb128 .L889-.LFB10159
	.uleb128 0
	.uleb128 .LEHB64-.LFB10159
	.uleb128 .LEHE64-.LEHB64
	.uleb128 .L891-.LFB10159
	.uleb128 0
	.uleb128 .LEHB65-.LFB10159
	.uleb128 .LEHE65-.LEHB65
	.uleb128 .L890-.LFB10159
	.uleb128 0
	.uleb128 .LEHB66-.LFB10159
	.uleb128 .LEHE66-.LEHB66
	.uleb128 .L892-.LFB10159
	.uleb128 0
	.uleb128 .LEHB67-.LFB10159
	.uleb128 .LEHE67-.LEHB67
	.uleb128 .L889-.LFB10159
	.uleb128 0
	.uleb128 .LEHB68-.LFB10159
	.uleb128 .LEHE68-.LEHB68
	.uleb128 0
	.uleb128 0
.LLSDACSE10159:
	.section	.text.startup
	.size	main, .-main
	.section	.text._ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb,"axG",@progbits,_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb
	.type	_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb, %function
_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb:
.LFB11640:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	and	w2, w2, 255
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	mov	x19, x0
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	ldr	x24, [x0, 40]
	ldr	x3, [x0, 72]
	ldr	x0, [x0, 8]
	sub	x23, x3, x24
	asr	x20, x23, 3
	add	x20, x20, 1
	add	x20, x20, x1
	cmp	x0, x20, lsl 1
	bls	.L931
	sub	x0, x0, x20
	lsl	x4, x1, 3
	ldr	x22, [x19]
	lsr	x0, x0, 1
	tst	x2, 1
	add	x2, x3, 8
	lsl	x21, x0, 3
	add	x0, x4, x0, lsl 3
	csel	x21, x0, x21, ne
	sub	x2, x2, x24
	add	x20, x22, x21
	cmp	x24, x20
	bls	.L933
	cmp	x2, 8
	ble	.L934
	mov	x1, x24
	mov	x0, x20
	bl	memmove
	ldr	x0, [x22, x21]
	b	.L935
	.p2align 2,,3
.L931:
	cmp	x0, x1
	stp	x1, x3, [sp, 72]
	csel	x21, x0, x1, cs
	add	x0, x0, 2
	str	w2, [sp, 92]
	add	x21, x21, x0
	sub	x20, x21, x20
	lsl	x0, x21, 3
	bl	_Znwm
	ldp	x1, x3, [sp, 72]
	lsr	x20, x20, 1
	ldr	w2, [sp, 92]
	mov	x22, x0
	lsl	x4, x20, 3
	tst	x2, 1
	lsl	x0, x1, 3
	add	x2, x3, 8
	add	x20, x0, x20, lsl 3
	sub	x2, x2, x24
	csel	x4, x20, x4, ne
	add	x20, x22, x4
	cmp	x2, 8
	ble	.L940
	mov	x1, x24
	mov	x0, x20
	bl	memmove
.L941:
	ldr	x0, [x19]
	bl	_ZdlPv
	stp	x22, x21, [x19]
.L947:
	ldr	x0, [x20]
.L935:
	add	x2, x0, 512
	stp	x0, x2, [x19, 24]
	add	x0, x20, x23
	str	x0, [x19, 72]
	ldr	x0, [x20, x23]
	str	x20, [x19, 40]
	add	x1, x0, 512
	stp	x0, x1, [x19, 56]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 96
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L933:
	.cfi_restore_state
	lsl	x1, x2, 61
	add	x0, x23, 8
	sub	x1, x1, x2
	add	x0, x0, x1
	add	x0, x20, x0
	cmp	x2, 8
	ble	.L937
	mov	x1, x24
	bl	memmove
	ldr	x0, [x20]
	b	.L935
	.p2align 2,,3
.L940:
	bne	.L941
	ldr	x0, [x24]
	str	x0, [x20]
	b	.L941
	.p2align 2,,3
.L937:
	bne	.L947
	ldr	x1, [x24]
	str	x1, [x0]
	ldr	x0, [x20]
	b	.L935
	.p2align 2,,3
.L934:
	bne	.L947
	ldr	x0, [x24]
	str	x0, [x20]
	b	.L935
	.cfi_endproc
.LFE11640:
	.size	_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb, .-_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb
	.section	.rodata._ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi.str1.8,"aMS",@progbits,1
	.align	3
.LC27:
	.string	"cannot create std::deque larger than max_size()"
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi
	.type	_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi, %function
_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi:
.LFB11444:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA11444
	sub	sp, sp, #304
	.cfi_def_cfa_offset 304
	stp	x29, x30, [sp, 192]
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	add	x29, sp, 192
	stp	x27, x28, [sp, 272]
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	mov	x28, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x2, [sp, 32]
	str	w3, [sp, 100]
	stp	x19, x20, [sp, 208]
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	mov	x20, x8
	mov	x19, x2
	stp	x21, x22, [sp, 224]
	stp	x23, x24, [sp, 240]
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	uxtw	x24, w1
	mov	x23, x24
	stp	x25, x26, [sp, 256]
	stp	d13, d15, [sp, 288]
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	.cfi_offset 77, -16
	.cfi_offset 79, -8
	ldr	x1, [x0]
	str	x1, [sp, 184]
	mov	x1, 0
	ldr	x0, [x28, 112]
.LEHB69:
	bl	_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv
.LEHE69:
	ldrh	w22, [x0]
	ldr	x21, [x0, 8]
	str	x0, [sp, 120]
	ldr	x0, [x28, 24]
	stp	xzr, xzr, [x20]
	ldr	x1, [x28, 256]
	mul	x0, x24, x0
	ldr	x3, [x28, 240]
	add	x2, x1, x0
	str	xzr, [x20, 16]
	add	x2, x2, x3
	ldrb	w2, [x2, 2]
	tbnz	x2, 0, .L949
	ldr	x2, [x28, 232]
	add	x0, x0, x2
	adrp	x2, :got:__stack_chk_guard
	ldr	x2, [x2, :got_lo12:__stack_chk_guard]
	str	x2, [sp, 24]
	add	x1, x1, x0
	mov	x0, x19
	ldp	x3, x2, [x28, 304]
.LEHB70:
	blr	x3
	ldp	x25, x27, [x20]
	fmov	s13, s0
	ldr	x0, [x20, 16]
	cmp	x27, x0
	beq	.L950
	fmov	s30, s0
	mov	w5, w24
	str	s0, [x27]
	add	x27, x27, 8
	str	w24, [x27, -4]
	str	x27, [x20, 8]
.L951:
	sub	x27, x27, x25
	asr	x1, x27, 3
	sub	x0, x1, #1
	cmp	x0, 0
	ble	.L957
	sub	x1, x1, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L960:
	lsl	x2, x1, 3
	add	x3, x25, x1, lsl 3
	ldr	s31, [x25, x2]
	lsl	x2, x0, 3
	add	x0, x25, x0, lsl 3
	fcmpe	s31, s30
	bmi	.L1031
	mov	x3, x0
.L958:
	fneg	s15, s13
	str	w5, [x3, 4]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	s30, [x3]
	str	x0, [sp, 24]
	mov	x0, 8
	bl	_Znwm
.LEHE70:
	mov	x19, x0
	add	x27, x0, 8
	str	w23, [x0, 4]
	str	s15, [x0]
.L961:
	strh	w22, [x21, x24, lsl 1]
	cmp	x19, x27
	beq	.L965
	add	x0, sp, 144
	str	x0, [sp, 104]
	ldr	w0, [sp, 100]
	mov	x23, x27
	sub	w0, w0, #1
	sxtw	x0, w0
	str	x0, [sp, 112]
	.p2align 5,,15
.L1003:
	ldr	s31, [x19]
	fneg	s31, s31
	fcmpe	s31, s13
	bgt	.L1032
	b	.L966
	.p2align 2,,3
.L1031:
	str	s31, [x25, x2]
	ldr	w2, [x3, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L958
	asr	x1, x2, 1
	b	.L960
	.p2align 2,,3
.L1032:
	ldp	x1, x0, [x20]
	sub	x0, x0, x1
	ldr	x1, [x28, 72]
	cmp	x1, x0, asr 3
	beq	.L965
.L966:
	ldr	x0, [sp, 104]
	str	x23, [sp, 160]
	ldr	w24, [x19, 4]
	stp	x19, x27, [sp, 144]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x0, [x28, 192]
	mov	w1, 48
	ldr	x27, [sp, 152]
	uxtw	x25, w24
	umaddl	x0, w24, w1, x0
	str	x0, [sp, 40]
	str	x0, [sp, 128]
	cbz	x0, .L1061
	ldr	x0, [sp, 40]
	bl	pthread_mutex_lock
	cbnz	w0, .L1062
	mov	w0, 1
	strb	w0, [sp, 136]
	ldr	w0, [sp, 100]
	cbnz	w0, .L972
	ldr	x1, [x28, 24]
	ldr	x0, [x28, 240]
	ldr	x24, [x28, 256]
	madd	x25, x25, x1, x0
	add	x0, x24, x25
	str	x0, [sp, 8]
.L973:
	ldr	x0, [sp, 8]
	ldrh	w0, [x0]
	str	x0, [sp, 16]
	cbz	x0, .L974
	mov	x26, 0
	b	.L1002
	.p2align 2,,3
.L1063:
	fcmpe	s0, s13
	bmi	.L976
.L977:
	ldr	x0, [sp, 16]
	cmp	x0, x26
	beq	.L974
.L1002:
	ldr	x0, [sp, 8]
	add	x26, x26, 1
	ldr	w25, [x0, x26, lsl 2]
	uxtw	x24, w25
	ubfiz	x0, x25, 1, 32
	ldrh	w1, [x21, x0]
	cmp	w1, w22
	beq	.L977
	ldr	x1, [x28, 232]
	strh	w22, [x21, x0]
	ldr	x0, [x28, 24]
	adrp	x2, :got:__stack_chk_guard
	ldr	x2, [x2, :got_lo12:__stack_chk_guard]
	str	x2, [sp, 24]
	madd	x0, x24, x0, x1
	ldr	x1, [x28, 256]
	ldp	x3, x2, [x28, 304]
	add	x1, x1, x0
	ldr	x0, [sp, 32]
.LEHB71:
	blr	x3
	ldp	x3, x9, [x20]
	ldr	x0, [x28, 72]
	sub	x11, x9, x3
	asr	x10, x11, 3
	cmp	x0, x10
	bls	.L1063
.L976:
	fneg	s15, s0
	cmp	x27, x23
	beq	.L978
	add	x27, x27, 8
	str	s15, [x27, -8]
	str	w25, [x27, -4]
	sub	x2, x27, x19
	mov	w13, w25
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	ble	.L985
.L1070:
	sub	x1, x1, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L988:
	lsl	x2, x1, 3
	add	x12, x19, x1, lsl 3
	ldr	s31, [x19, x2]
	lsl	x2, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s15, s31
	bgt	.L1033
.L986:
	ldr	x2, [x28, 24]
	str	s15, [x0]
	ldr	x1, [x28, 256]
	str	w13, [x0, 4]
	ldr	x0, [x28, 240]
	madd	x5, x24, x2, x1
	add	x5, x5, x0
	ldrb	w0, [x5, 2]
	tbz	x0, 0, .L1064
.L989:
	ldr	x0, [x28, 72]
	cmp	x0, x10
	bcc	.L1065
.L1001:
	cmp	x3, x9
	beq	.L977
	ldr	x0, [sp, 16]
	ldr	s13, [x3]
	cmp	x0, x26
	bne	.L1002
.L974:
	ldr	x0, [sp, 40]
	bl	pthread_mutex_unlock
	cmp	x27, x19
	bne	.L1003
.L965:
	ldr	x21, [x28, 112]
	add	x23, x21, 80
	str	x23, [sp, 128]
	mov	x0, x23
	bl	pthread_mutex_lock
	cbnz	w0, .L1066
	mov	w2, 1
	strb	w2, [sp, 136]
	ldp	x0, x1, [x21, 16]
	cmp	x0, x1
	beq	.L1006
	ldr	x1, [sp, 120]
	str	x1, [x0, -8]!
	str	x0, [x21, 16]
.L1007:
	mov	x0, x23
	bl	pthread_mutex_unlock
	cbz	x19, .L948
	mov	x0, x19
	bl	_ZdlPv
.L948:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 184]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1060
	ldp	x29, x30, [sp, 192]
	mov	x0, x20
	ldp	x19, x20, [sp, 208]
	ldp	x21, x22, [sp, 224]
	ldp	x23, x24, [sp, 240]
	ldp	x25, x26, [sp, 256]
	ldp	x27, x28, [sp, 272]
	ldp	d13, d15, [sp, 288]
	add	sp, sp, 304
	.cfi_remember_state
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 77
	.cfi_restore 79
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L1033:
	.cfi_restore_state
	str	s31, [x19, x2]
	ldr	w2, [x12, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L1067
	asr	x1, x2, 1
	b	.L988
	.p2align 2,,3
.L1067:
	mov	x0, x12
	b	.L986
	.p2align 2,,3
.L1065:
	mov	x0, x20
	str	x3, [sp, 24]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x9, [x20, 8]
	ldr	x3, [sp, 24]
	b	.L1001
	.p2align 2,,3
.L1064:
	ldr	x0, [x20, 16]
	cmp	x9, x0
	beq	.L990
	add	x9, x9, 8
	str	s0, [x9, -8]
	str	w25, [x9, -4]
	sub	x1, x9, x3
	str	x9, [x20, 8]
	asr	x10, x1, 3
	sub	x0, x10, #1
	cmp	x0, 0
	ble	.L997
.L1072:
	sub	x1, x10, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L1000:
	lsl	x2, x1, 3
	add	x5, x3, x1, lsl 3
	ldr	s31, [x3, x2]
	lsl	x2, x0, 3
	add	x0, x3, x0, lsl 3
	fcmpe	s31, s0
	bmi	.L998
	str	s0, [x3, x2]
	str	w25, [x0, 4]
	b	.L989
	.p2align 2,,3
.L998:
	str	s31, [x3, x2]
	ldr	w2, [x5, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L1068
	asr	x1, x2, 1
	b	.L1000
	.p2align 2,,3
.L978:
	sub	x1, x27, x19
	mov	x2, 1152921504606846975
	asr	x0, x1, 3
	cmp	x0, x2
	beq	.L1069
	cmp	x0, 0
	str	s0, [sp, 48]
	csinc	x23, x0, xzr, ne
	stp	x9, x3, [sp, 56]
	add	x23, x23, x0
	cmp	x23, x2
	stp	x10, x11, [sp, 72]
	csel	x23, x23, x2, ls
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	lsl	x23, x23, 3
	str	x0, [sp, 24]
	mov	x0, x23
	str	x1, [sp, 88]
	bl	_Znwm
	ldr	x1, [sp, 88]
	mov	x14, x0
	ldp	x9, x3, [sp, 56]
	add	x12, x0, x1
	ldp	x10, x11, [sp, 72]
	str	s15, [x0, x1]
	str	w25, [x12, 4]
	cmp	x19, x27
	ldr	s0, [sp, 48]
	mov	x1, x0
	beq	.L982
	mov	x2, x19
	.p2align 5,,15
.L983:
	ldr	x8, [x2], 8
	str	x8, [x1], 8
	cmp	x12, x1
	bne	.L983
	mov	x1, x12
.L982:
	add	x27, x1, 8
	cbz	x19, .L984
	mov	x0, x19
	str	s0, [sp, 24]
	stp	x9, x3, [sp, 48]
	stp	x10, x14, [sp, 64]
	stp	x1, x11, [sp, 80]
	bl	_ZdlPv
	ldr	s0, [sp, 24]
	ldp	x9, x3, [sp, 48]
	ldp	x10, x14, [sp, 64]
	ldp	x1, x11, [sp, 80]
.L984:
	mov	x19, x14
	sub	x2, x27, x19
	ldr	s15, [x1]
	ldr	w13, [x1, 4]
	add	x23, x14, x23
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	bgt	.L1070
.L985:
	sub	x2, x2, #8
	add	x0, x19, x2
	b	.L986
	.p2align 2,,3
.L1068:
	str	s0, [x5]
	str	w25, [x5, 4]
	b	.L989
	.p2align 2,,3
.L972:
	ldr	x0, [x28, 264]
	ldr	x24, [x28, 32]
	ldr	x0, [x0, x25, lsl 3]
	ldr	x1, [sp, 112]
	madd	x0, x1, x24, x0
	str	x0, [sp, 8]
	b	.L973
.L990:
	mov	x1, 1152921504606846975
	cmp	x10, x1
	beq	.L1071
	cmp	x10, 0
	str	s0, [sp, 56]
	csinc	x0, x10, xzr, ne
	stp	x9, x3, [sp, 64]
	add	x0, x0, x10
	cmp	x0, x1
	str	x11, [sp, 80]
	csel	x0, x0, x1, ls
	lsl	x10, x0, 3
	str	x10, [sp, 48]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x0, x10
	bl	_Znwm
.LEHE71:
	ldr	x11, [sp, 80]
	mov	x13, x0
	ldr	s0, [sp, 56]
	ldp	x9, x3, [sp, 64]
	add	x12, x0, x11
	str	s0, [x0, x11]
	ldr	x10, [sp, 48]
	str	w25, [x12, 4]
	cmp	x9, x3
	beq	.L1025
	mov	x1, x0
	mov	x2, x3
	.p2align 5,,15
.L995:
	ldr	x5, [x2], 8
	str	x5, [x1], 8
	cmp	x1, x12
	bne	.L995
	mov	x24, x1
.L994:
	add	x9, x24, 8
	cbz	x3, .L996
	mov	x0, x3
	str	x9, [sp, 24]
	stp	x10, x13, [sp, 48]
	bl	_ZdlPv
	ldp	x10, x13, [sp, 48]
	ldr	x9, [sp, 24]
.L996:
	mov	x3, x13
	sub	x1, x9, x3
	add	x10, x13, x10
	stp	x13, x9, [x20]
	str	x10, [x20, 16]
	asr	x10, x1, 3
	sub	x0, x10, #1
	ldr	s0, [x24]
	ldr	w25, [x24, 4]
	cmp	x0, 0
	bgt	.L1072
.L997:
	sub	x1, x1, #8
	add	x0, x3, x1
	str	s0, [x3, x1]
	str	w25, [x0, 4]
	b	.L989
.L1025:
	mov	x24, x0
	b	.L994
.L1006:
	add	x24, x21, 16
	ldr	x4, [x21, 72]
	ldp	x3, x22, [x24, 16]
	cmp	x4, 0
	sub	x1, x4, x22
	cset	x4, ne
	sub	x0, x3, x0
	asr	x1, x1, 3
	sub	x1, x1, x4
	ldp	x4, x5, [x21, 48]
	sub	x4, x4, x5
	asr	x4, x4, 3
	add	x1, x4, x1, lsl 6
	add	x0, x1, x0, asr 3
	mov	x1, 1152921504606846975
	cmp	x0, x1
	beq	.L1073
	ldr	x0, [x21]
	cmp	x22, x0
	beq	.L1074
.L1010:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x0, 512
.LEHB72:
	bl	_Znwm
.LEHE72:
	str	x0, [x22, -8]!
	add	x1, x0, 512
	stp	x0, x1, [x24, 8]
	add	x1, x0, 504
	str	x22, [x24, 24]
	str	x1, [x21, 16]
	ldr	x1, [sp, 120]
	str	x1, [x0, 504]
	b	.L1007
.L950:
	sub	x26, x27, x25
	mov	x1, 1152921504606846975
	asr	x0, x26, 3
	cmp	x0, x1
	beq	.L1075
	cmp	x0, 0
	csinc	x19, x0, xzr, ne
	add	x19, x19, x0
	cmp	x19, x1
	csel	x19, x19, x1, ls
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	lsl	x19, x19, 3
	str	x0, [sp, 24]
	mov	x0, x19
.LEHB73:
	bl	_Znwm
	add	x3, x0, x26
	str	s13, [x0, x26]
	mov	x1, x0
	str	w24, [x3, 4]
	cmp	x27, x25
	beq	.L1019
	mov	x2, x25
.L955:
	ldr	x5, [x2], 8
	str	x5, [x0], 8
	cmp	x0, x3
	bne	.L955
	mov	x26, x0
.L954:
	add	x27, x26, 8
	cbz	x25, .L956
	mov	x0, x25
	str	x1, [sp, 8]
	bl	_ZdlPv
	ldr	x1, [sp, 8]
.L956:
	stp	x1, x27, [x20]
	add	x19, x1, x19
	ldr	s30, [x26]
	mov	x25, x1
	ldr	w5, [x26, 4]
	str	x19, [x20, 16]
	b	.L951
.L949:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x0, 8
	bl	_Znwm
.LEHE73:
	mvni	v31.2s, 0x80, lsl 16
	mov	x19, x0
	add	x27, x0, 8
	mov	w0, 2139095039
	fmov	s13, w0
	str	w24, [x19, 4]
	str	s31, [x19]
	b	.L961
.L1074:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	mov	x1, 1
	str	x0, [sp, 24]
	mov	x0, x21
.LEHB74:
	bl	_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb
.LEHE74:
	ldr	x22, [x21, 40]
	b	.L1010
.L957:
	sub	x27, x27, #8
	add	x3, x25, x27
	b	.L958
.L1019:
	mov	x26, x0
	b	.L954
.L1061:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x2, x0
	ldr	x0, [sp, 184]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	beq	.L969
.L1060:
	bl	__stack_chk_fail
.L1028:
	mov	x21, x0
	add	x0, sp, 128
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	cbz	x19, .L964
.L1076:
	mov	x0, x19
	bl	_ZdlPv
.L964:
	ldr	x0, [x20]
	cbz	x0, .L1016
	bl	_ZdlPv
.L1016:
	ldr	x2, [sp, 24]
	ldr	x0, [sp, 184]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1060
	mov	x0, x21
.LEHB75:
	bl	_Unwind_Resume
.LEHE75:
.L1073:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x2, x0
	ldr	x0, [sp, 184]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1060
	adrp	x0, .LC27
	add	x0, x0, :lo12:.LC27
.LEHB76:
	bl	_ZSt20__throw_length_errorPKc
.LEHE76:
.L1075:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x2, x0
	ldr	x0, [sp, 184]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1060
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB77:
	bl	_ZSt20__throw_length_errorPKc
.LEHE77:
.L969:
	mov	w0, 1
.LEHB78:
	bl	_ZSt20__throw_system_errori
.LEHE78:
.L1030:
	mov	x21, x0
	add	x0, sp, 128
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	cbnz	x19, .L1076
	b	.L964
.L1062:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	str	x1, [sp, 24]
	mov	x3, x1
	ldr	x1, [sp, 184]
	ldr	x2, [x3]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1060
.LEHB79:
	bl	_ZSt20__throw_system_errori
.LEHE79:
.L1027:
	mov	x21, x0
	cbnz	x19, .L1076
	b	.L964
.L1029:
	mov	x21, x0
	b	.L964
.L1071:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x2, x0
	ldr	x0, [sp, 184]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1060
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB80:
	bl	_ZSt20__throw_length_errorPKc
.L1069:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 24]
	mov	x2, x0
	ldr	x0, [sp, 184]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1060
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	_ZSt20__throw_length_errorPKc
.LEHE80:
.L1066:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	str	x1, [sp, 24]
	mov	x3, x1
	ldr	x1, [sp, 184]
	ldr	x2, [x3]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1060
.LEHB81:
	bl	_ZSt20__throw_system_errori
.LEHE81:
	.cfi_endproc
.LFE11444:
	.section	.gcc_except_table
.LLSDA11444:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE11444-.LLSDACSB11444
.LLSDACSB11444:
	.uleb128 .LEHB69-.LFB11444
	.uleb128 .LEHE69-.LEHB69
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB70-.LFB11444
	.uleb128 .LEHE70-.LEHB70
	.uleb128 .L1029-.LFB11444
	.uleb128 0
	.uleb128 .LEHB71-.LFB11444
	.uleb128 .LEHE71-.LEHB71
	.uleb128 .L1030-.LFB11444
	.uleb128 0
	.uleb128 .LEHB72-.LFB11444
	.uleb128 .LEHE72-.LEHB72
	.uleb128 .L1028-.LFB11444
	.uleb128 0
	.uleb128 .LEHB73-.LFB11444
	.uleb128 .LEHE73-.LEHB73
	.uleb128 .L1029-.LFB11444
	.uleb128 0
	.uleb128 .LEHB74-.LFB11444
	.uleb128 .LEHE74-.LEHB74
	.uleb128 .L1028-.LFB11444
	.uleb128 0
	.uleb128 .LEHB75-.LFB11444
	.uleb128 .LEHE75-.LEHB75
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB76-.LFB11444
	.uleb128 .LEHE76-.LEHB76
	.uleb128 .L1028-.LFB11444
	.uleb128 0
	.uleb128 .LEHB77-.LFB11444
	.uleb128 .LEHE77-.LEHB77
	.uleb128 .L1029-.LFB11444
	.uleb128 0
	.uleb128 .LEHB78-.LFB11444
	.uleb128 .LEHE78-.LEHB78
	.uleb128 .L1027-.LFB11444
	.uleb128 0
	.uleb128 .LEHB79-.LFB11444
	.uleb128 .LEHE79-.LEHB79
	.uleb128 .L1027-.LFB11444
	.uleb128 0
	.uleb128 .LEHB80-.LFB11444
	.uleb128 .LEHE80-.LEHB80
	.uleb128 .L1030-.LFB11444
	.uleb128 0
	.uleb128 .LEHB81-.LFB11444
	.uleb128 .LEHE81-.LEHB81
	.uleb128 .L1027-.LFB11444
	.uleb128 0
.LLSDACSE11444:
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi,comdat
	.size	_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi, .-_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi
	.section	.text._ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_,"axG",@progbits,_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_
	.type	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_, %function
_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_:
.LFB12058:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x4, 1152921504606846975
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	.cfi_offset 23, -32
	.cfi_offset 24, -24
	ldp	x21, x23, [x0]
	sub	x22, x23, x21
	asr	x3, x22, 3
	cmp	x3, x4
	beq	.L1088
	cmp	x3, 0
	mov	x19, x0
	csinc	x0, x3, xzr, ne
	mov	x24, x2
	add	x0, x0, x3
	str	x1, [sp, 72]
	cmp	x0, x4
	csel	x0, x0, x4, ls
	lsl	x20, x0, 3
	mov	x0, x20
	bl	_Znwm
	ldr	x1, [sp, 72]
	mov	x5, x0
	add	x4, x0, x22
	ldr	w0, [x24]
	ldr	s31, [x1]
	mov	x1, x5
	str	s31, [x5, x22]
	str	w0, [x4, 4]
	cmp	x21, x23
	beq	.L1079
	mov	x2, x21
	.p2align 5,,15
.L1080:
	ldr	x3, [x2], 8
	str	x3, [x1], 8
	cmp	x1, x4
	bne	.L1080
.L1079:
	add	x22, x1, 8
	cbz	x21, .L1081
	mov	x0, x21
	str	x5, [sp, 72]
	bl	_ZdlPv
	ldr	x5, [sp, 72]
.L1081:
	stp	x5, x22, [x19]
	add	x5, x5, x20
	str	x5, [x19, 16]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 80
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L1088:
	.cfi_restore_state
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE12058:
	.size	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_, .-_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_
	.section	.text._ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_,"axG",@progbits,_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_
	.type	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_, %function
_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_:
.LFB12069:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x2, 1152921504606846975
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	mov	x21, x0
	stp	x23, x24, [sp, 48]
	.cfi_offset 23, -32
	.cfi_offset 24, -24
	ldp	x22, x23, [x0]
	sub	x19, x23, x22
	asr	x0, x19, 3
	cmp	x0, x2
	beq	.L1100
	cmp	x0, 0
	mov	x24, x1
	csinc	x20, x0, xzr, ne
	add	x20, x20, x0
	cmp	x20, x2
	csel	x20, x20, x2, ls
	lsl	x20, x20, 3
	mov	x0, x20
	bl	_Znwm
	mov	x5, x0
	ldr	x0, [x24]
	str	x0, [x5, x19]
	cmp	x22, x23
	beq	.L1094
	add	x4, x5, x19
	mov	x1, x5
	mov	x2, x22
	.p2align 5,,15
.L1092:
	ldr	x3, [x2], 8
	str	x3, [x1], 8
	cmp	x1, x4
	bne	.L1092
.L1091:
	add	x19, x1, 8
	cbz	x22, .L1093
	mov	x0, x22
	str	x5, [sp, 72]
	bl	_ZdlPv
	ldr	x5, [sp, 72]
.L1093:
	stp	x5, x19, [x21]
	add	x5, x5, x20
	str	x5, [x21, 16]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 80
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L1094:
	.cfi_restore_state
	mov	x1, x5
	b	.L1091
.L1100:
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE12069:
	.size	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_, .-_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm
	.type	_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm, %function
_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm:
.LFB11489:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA11489
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x29, x30, [sp, 64]
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	add	x29, sp, 64
	stp	x27, x28, [sp, 144]
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	mov	x28, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x2, [sp]
	stp	x21, x22, [sp, 96]
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	mov	x22, x1
	stp	x23, x24, [sp, 112]
	ldr	x1, [x0]
	str	x1, [sp, 56]
	mov	x1, 0
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	ldp	x24, x0, [x22]
	sub	x0, x0, x24
	cmp	x2, x0, asr 3
	bhi	.L1101
	stp	x19, x20, [sp, 80]
	.cfi_offset 20, -88
	.cfi_offset 19, -96
	mov	x23, 0
	mov	x19, 0
	stp	x25, x26, [sp, 128]
	.cfi_offset 26, -40
	.cfi_offset 25, -48
	mov	x21, 0
	mov	x20, 1152921504606846975
	stp	d14, d15, [sp, 160]
	.cfi_offset 79, -8
	.cfi_offset 78, -16
	cbz	x0, .L1178
	.p2align 5,,15
.L1110:
	ldr	s14, [x24]
	fneg	s14, s14
	cmp	x23, x19
	beq	.L1103
	ldr	w0, [x24, 4]
	add	x19, x19, 8
	str	w0, [x19, -4]
	str	s14, [x19, -8]
.L1104:
	sub	x1, x19, x21
	mov	x2, 0
	ldr	x3, [x19, -8]
	asr	x1, x1, 3
	sub	x1, x1, #1
	mov	x0, x21
	bl	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	mov	x0, x22
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x0, [x22, 8]
	sub	x0, x0, x24
	cbnz	x0, .L1110
.L1178:
	str	xzr, [sp, 8]
	sub	x0, x19, x21
	mov	x20, 0
	mov	x23, 0
	cbz	x0, .L1112
	.p2align 5,,15
.L1121:
	ldr	x2, [sp]
	sub	x1, x20, x23
	cmp	x2, x1, asr 3
	bls	.L1112
	ldr	s14, [x21]
	sub	x19, x19, #8
	ldr	w26, [x21, 4]
	cmp	x0, 8
	bgt	.L1179
.L1113:
	fneg	s15, s14
	uxtw	x24, w26
	mov	x27, x23
	cmp	x23, x20
	beq	.L1119
	.p2align 5,,15
.L1118:
	ldr	x6, [x28, 24]
	ldr	x2, [x28, 232]
	ldr	w0, [x27, 4]
	ldr	x5, [x28, 256]
	madd	x1, x6, x24, x2
	adrp	x25, :got:__stack_chk_guard
	ldr	x25, [x25, :got_lo12:__stack_chk_guard]
	madd	x0, x0, x6, x2
	ldp	x6, x2, [x28, 304]
	add	x1, x5, x1
	add	x0, x5, x0
.LEHB82:
	blr	x6
.LEHE82:
	fcmpe	s15, s0
	bgt	.L1117
	add	x27, x27, 8
	cmp	x27, x20
	bne	.L1118
.L1119:
	ldr	x0, [sp, 8]
	cmp	x0, x20
	beq	.L1180
	add	x20, x20, 8
	str	w26, [x20, -4]
	str	s14, [x20, -8]
.L1117:
	sub	x0, x19, x21
.L1186:
	cbnz	x0, .L1121
.L1112:
	cmp	x23, x20
	beq	.L1137
	ldp	x19, x24, [x22]
	mov	x26, x23
	mov	x28, 1152921504606846975
	.p2align 5,,15
.L1136:
	ldr	s15, [x26]
	ldr	x0, [x22, 16]
	ldr	w27, [x26, 4]
	fneg	s15, s15
	cmp	x24, x0
	beq	.L1125
	add	x24, x24, 8
	str	s15, [x24, -8]
	str	w27, [x24, -4]
	sub	x1, x24, x19
	str	x24, [x22, 8]
	asr	x2, x1, 3
	sub	x0, x2, #1
	cmp	x0, 0
	ble	.L1132
.L1184:
	sub	x2, x2, #2
	asr	x2, x2, 1
	.p2align 5,,15
.L1135:
	lsl	x1, x2, 3
	add	x3, x19, x2, lsl 3
	ldr	s31, [x19, x1]
	lsl	x1, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s31, s15
	bmi	.L1154
	add	x26, x26, 8
	str	s15, [x0]
	str	w27, [x0, 4]
	cmp	x20, x26
	bne	.L1136
.L1137:
	cbz	x23, .L1124
	mov	x0, x23
	bl	_ZdlPv
.L1124:
	cbz	x21, .L1175
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 56]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1177
	ldp	x19, x20, [sp, 80]
	.cfi_remember_state
	.cfi_restore 20
	.cfi_restore 19
	mov	x0, x21
	ldp	x25, x26, [sp, 128]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x29, x30, [sp, 64]
	ldp	x21, x22, [sp, 96]
	ldp	x23, x24, [sp, 112]
	ldp	x27, x28, [sp, 144]
	ldp	d14, d15, [sp, 160]
	.cfi_restore 79
	.cfi_restore 78
	add	sp, sp, 176
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
.LEHB83:
	b	_ZdlPv
.LEHE83:
	.p2align 2,,3
.L1103:
	.cfi_restore_state
	sub	x26, x23, x21
	asr	x1, x26, 3
	cmp	x1, x20
	beq	.L1181
	cmp	x1, 0
	csinc	x0, x1, xzr, ne
	add	x0, x0, x1
	cmp	x0, x20
	csel	x0, x0, x20, ls
	adrp	x25, :got:__stack_chk_guard
	ldr	x25, [x25, :got_lo12:__stack_chk_guard]
	lsl	x23, x0, 3
	mov	x0, x23
.LEHB84:
	bl	_Znwm
.LEHE84:
	mov	x25, x0
	add	x0, x0, x26
	ldr	w1, [x24, 4]
	str	s14, [x25, x26]
	str	w1, [x0, 4]
	cmp	x21, x19
	beq	.L1148
	sub	x19, x19, x21
	mov	x1, x25
	add	x19, x25, x19
	mov	x2, x21
	.p2align 5,,15
.L1108:
	ldr	x3, [x2], 8
	str	x3, [x1], 8
	cmp	x19, x1
	bne	.L1108
	add	x19, x19, 8
	cbz	x21, .L1109
.L1187:
	mov	x0, x21
	bl	_ZdlPv
.L1109:
	add	x23, x25, x23
	mov	x21, x25
	b	.L1104
	.p2align 2,,3
.L1179:
	ldr	x3, [x19]
	sub	x2, x19, x21
	str	w26, [x19, 4]
	mov	x0, x21
	asr	x2, x2, 3
	mov	x1, 0
	str	s14, [x19]
	bl	_ZSt13__adjust_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfjESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops15_Iter_comp_iterISt4lessIS3_EEEEvT_T0_SF_T1_T2_.isra.0
	b	.L1113
	.p2align 2,,3
.L1154:
	str	s31, [x19, x1]
	ldr	w1, [x3, 4]
	str	w1, [x0, 4]
	sub	x0, x2, #1
	add	x1, x0, x0, lsr 63
	mov	x0, x2
	cbz	x2, .L1182
	asr	x2, x1, 1
	b	.L1135
	.p2align 2,,3
.L1182:
	mov	x0, x3
	add	x26, x26, 8
	str	s15, [x0]
	str	w27, [x0, 4]
	cmp	x20, x26
	bne	.L1136
	b	.L1137
	.p2align 2,,3
.L1125:
	sub	x5, x24, x19
	asr	x1, x5, 3
	cmp	x1, x28
	beq	.L1183
	cmp	x1, 0
	csinc	x0, x1, xzr, ne
	add	x0, x0, x1
	cmp	x0, x28
	csel	x0, x0, x28, ls
	adrp	x25, :got:__stack_chk_guard
	ldr	x25, [x25, :got_lo12:__stack_chk_guard]
	lsl	x4, x0, 3
	mov	x0, x4
	stp	x4, x5, [sp]
.LEHB85:
	bl	_Znwm
.LEHE85:
	ldp	x4, x5, [sp]
	mov	x25, x0
	cmp	x19, x24
	add	x0, x0, x5
	str	s15, [x25, x5]
	str	w27, [x0, 4]
	beq	.L1149
	mov	x2, x25
	mov	x1, x19
	.p2align 5,,15
.L1130:
	ldr	x3, [x1], 8
	str	x3, [x2], 8
	cmp	x24, x1
	bne	.L1130
	add	x27, x25, x5
.L1129:
	add	x24, x27, 8
	cbz	x19, .L1131
	mov	x0, x19
	str	x4, [sp]
	bl	_ZdlPv
	ldr	x4, [sp]
.L1131:
	mov	x19, x25
	sub	x1, x24, x19
	stp	x25, x24, [x22]
	add	x4, x25, x4
	asr	x2, x1, 3
	str	x4, [x22, 16]
	sub	x0, x2, #1
	ldr	s15, [x27]
	ldr	w27, [x27, 4]
	cmp	x0, 0
	bgt	.L1184
.L1132:
	sub	x1, x1, #8
	add	x26, x26, 8
	add	x0, x19, x1
	str	s15, [x0]
	str	w27, [x0, 4]
	cmp	x20, x26
	bne	.L1136
	b	.L1137
.L1175:
	ldp	x19, x20, [sp, 80]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x25, x26, [sp, 128]
	.cfi_restore 26
	.cfi_restore 25
	ldp	d14, d15, [sp, 160]
	.cfi_restore 79
	.cfi_restore 78
.L1101:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 56]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1185
	ldp	x29, x30, [sp, 64]
	ldp	x21, x22, [sp, 96]
	ldp	x23, x24, [sp, 112]
	ldp	x27, x28, [sp, 144]
	add	sp, sp, 176
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L1180:
	.cfi_def_cfa_offset 176
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	ldr	x0, [sp, 8]
	add	x1, sp, 24
	str	s14, [sp, 24]
	str	w26, [sp, 28]
	stp	x23, x0, [sp, 32]
	str	x0, [sp, 48]
	add	x0, sp, 32
.LEHB86:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_
.LEHE86:
	ldr	x0, [sp, 48]
	str	x0, [sp, 8]
	ldp	x23, x20, [sp, 32]
	sub	x0, x19, x21
	b	.L1186
.L1149:
	mov	x27, x25
	b	.L1129
.L1148:
	mov	x19, x25
	add	x19, x19, 8
	cbnz	x21, .L1187
	b	.L1109
.L1185:
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 78
	.cfi_restore 79
	stp	x19, x20, [sp, 80]
	.cfi_offset 20, -88
	.cfi_offset 19, -96
	stp	x25, x26, [sp, 128]
	.cfi_offset 26, -40
	.cfi_offset 25, -48
	stp	d14, d15, [sp, 160]
	.cfi_offset 79, -8
	.cfi_offset 78, -16
.L1177:
	bl	__stack_chk_fail
.L1151:
	ldr	x23, [sp, 32]
	mov	x19, x0
	adrp	x25, :got:__stack_chk_guard
	ldr	x25, [x25, :got_lo12:__stack_chk_guard]
	cbz	x23, .L1143
.L1189:
	mov	x0, x23
	bl	_ZdlPv
.L1143:
	cbz	x21, .L1144
.L1188:
	mov	x0, x21
	bl	_ZdlPv
.L1144:
	ldr	x0, [sp, 56]
	ldr	x1, [x25]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1177
	mov	x0, x19
.LEHB87:
	bl	_Unwind_Resume
.LEHE87:
.L1183:
	adrp	x25, :got:__stack_chk_guard
	ldr	x25, [x25, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 56]
	ldr	x1, [x25]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1177
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB88:
	bl	_ZSt20__throw_length_errorPKc
.LEHE88:
.L1153:
	mov	x19, x0
	cbnz	x21, .L1188
	b	.L1144
.L1152:
	mov	x19, x0
	cbnz	x23, .L1189
	b	.L1143
.L1181:
	adrp	x25, :got:__stack_chk_guard
	ldr	x25, [x25, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 56]
	ldr	x1, [x25]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1177
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB89:
	bl	_ZSt20__throw_length_errorPKc
.LEHE89:
	.cfi_endproc
.LFE11489:
	.section	.gcc_except_table
.LLSDA11489:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE11489-.LLSDACSB11489
.LLSDACSB11489:
	.uleb128 .LEHB82-.LFB11489
	.uleb128 .LEHE82-.LEHB82
	.uleb128 .L1152-.LFB11489
	.uleb128 0
	.uleb128 .LEHB83-.LFB11489
	.uleb128 .LEHE83-.LEHB83
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB84-.LFB11489
	.uleb128 .LEHE84-.LEHB84
	.uleb128 .L1153-.LFB11489
	.uleb128 0
	.uleb128 .LEHB85-.LFB11489
	.uleb128 .LEHE85-.LEHB85
	.uleb128 .L1152-.LFB11489
	.uleb128 0
	.uleb128 .LEHB86-.LFB11489
	.uleb128 .LEHE86-.LEHB86
	.uleb128 .L1151-.LFB11489
	.uleb128 0
	.uleb128 .LEHB87-.LFB11489
	.uleb128 .LEHE87-.LEHB87
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB88-.LFB11489
	.uleb128 .LEHE88-.LEHB88
	.uleb128 .L1152-.LFB11489
	.uleb128 0
	.uleb128 .LEHB89-.LFB11489
	.uleb128 .LEHE89-.LEHB89
	.uleb128 .L1153-.LFB11489
	.uleb128 0
.LLSDACSE11489:
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm,comdat
	.size	_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm, .-_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm
	.section	.rodata.str1.8
	.align	3
.LC28:
	.string	"Should be not be more than M_ candidates returned by the heuristic"
	.align	3
.LC29:
	.string	"vector::reserve"
	.align	3
.LC30:
	.string	"The newly inserted element should have blank link list"
	.align	3
.LC31:
	.string	"Possible memory corruption"
	.align	3
.LC32:
	.string	"Trying to make a link on a non-existent level"
	.align	3
.LC33:
	.string	"Bad value of sz_link_list_other"
	.align	3
.LC34:
	.string	"Trying to connect an element to itself"
	.text
	.align	2
	.p2align 5,,15
	.type	_ZN7hnswlib15HierarchicalNSWIfE25mutuallyConnectNewElementEPKvjRSt14priority_queueISt4pairIfjESt6vectorIS6_SaIS6_EENS1_14CompareByFirstEEib.isra.0, %function
_ZN7hnswlib15HierarchicalNSWIfE25mutuallyConnectNewElementEPKvjRSt14priority_queueISt4pairIfjESt6vectorIS6_SaIS6_EENS1_14CompareByFirstEEib.isra.0:
.LFB12864:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12864
	sub	sp, sp, #288
	.cfi_def_cfa_offset 288
	cmp	w3, 0
	stp	x29, x30, [sp, 176]
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	add	x29, sp, 176
	stp	x21, x22, [sp, 208]
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	mov	w22, w1
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	str	w3, [sp, 4]
	stp	x19, x20, [sp, 192]
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	and	w19, w4, 255
	stp	x23, x24, [sp, 224]
	stp	x25, x26, [sp, 240]
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	mov	x26, x2
	stp	x27, x28, [sp, 256]
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	mov	x27, x0
	stp	d14, d15, [sp, 272]
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	ldr	x2, [x1]
	str	x2, [sp, 168]
	mov	x2, 0
	ldr	x4, [x0, 64]
	ldp	x2, x1, [x0, 48]
	csel	x1, x4, x1, eq
	str	x1, [sp, 48]
	mov	x1, x26
.LEHB90:
	bl	_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm
.LEHE90:
	ldp	x28, x21, [x26]
	ldr	x0, [x27, 48]
	sub	x21, x21, x28
	cmp	x0, x21, asr 3
	bcc	.L1338
	mov	x1, 2305843009213693951
	cmp	x0, x1
	bhi	.L1339
	cbz	x0, .L1274
	lsl	x24, x0, 2
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x0, x24
.LEHB91:
	bl	_Znwm
.LEHE91:
	add	x24, x0, x24
	mov	x20, x0
	mov	x23, 2305843009213693951
	str	x20, [sp, 16]
.L1197:
	cbz	x21, .L1340
	.p2align 5,,15
.L1204:
	cmp	x20, x24
	beq	.L1198
	ldr	w0, [x28, 4]
	str	w0, [x20], 4
.L1199:
	mov	x0, x26
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x21, [x26, 8]
	sub	x21, x21, x28
	cbnz	x21, .L1204
.L1340:
	ldr	w0, [x20, -4]
	mov	w21, 48
	str	w0, [sp, 108]
	uxtw	x0, w22
	str	x0, [sp, 72]
	ldr	x0, [x27, 192]
	strb	wzr, [sp, 136]
	umaddl	x21, w22, w21, x0
	and	w0, w19, 1
	str	w0, [sp, 104]
	str	x21, [sp, 128]
	tbnz	x19, 0, .L1341
.L1205:
	ldr	w0, [sp, 4]
	cbnz	w0, .L1210
	ldr	x0, [x27, 24]
	uxtw	x2, w22
	ldr	x1, [x27, 240]
	madd	x0, x2, x0, x1
	ldr	x1, [x27, 256]
	add	x1, x1, x0
.L1211:
	ldr	w0, [x1]
	cmp	w0, 0
	ccmp	w19, 0, 0, ne
	beq	.L1342
	ldr	x0, [sp, 16]
	sub	x20, x20, x0
	asr	x0, x20, 2
	strh	w0, [x1], 4
	str	x0, [sp, 40]
	mov	x0, 0
	cbz	x20, .L1343
	.p2align 5,,15
.L1214:
	ldr	w2, [x1, x0, lsl 2]
	cmp	w2, 0
	ccmp	w19, 0, 0, ne
	beq	.L1344
	ldr	x2, [sp, 16]
	ldr	x3, [x27, 272]
	ldr	w2, [x2, x0, lsl 2]
	ldr	w4, [sp, 4]
	ldr	w3, [x3, w2, uxtw 2]
	cmp	w4, w3
	bgt	.L1345
	str	w2, [x1, x0, lsl 2]
	add	x0, x0, 1
	ldr	x2, [sp, 40]
	cmp	x0, x2
	bcc	.L1214
	cmp	x21, 0
	ldrb	w0, [sp, 136]
	cset	w1, ne
	tst	w1, w0
	bne	.L1215
	cbz	x2, .L1222
.L1221:
	ldr	w0, [sp, 4]
	mov	x23, 0
	sub	w0, w0, #1
	sxtw	x0, w0
	str	x0, [sp, 64]
	b	.L1254
	.p2align 2,,3
.L1352:
	ldr	x0, [x27, 24]
	ldr	x1, [x27, 240]
	ldr	x6, [x27, 256]
	madd	x0, x21, x0, x1
	add	x28, x6, x0
.L1229:
	ldr	x0, [sp, 48]
	ldrh	w25, [x28]
	mov	x2, x25
	cmp	x25, x0
	bhi	.L1346
	cmp	w19, w22
	beq	.L1347
	ldr	x0, [x27, 272]
	ldr	w1, [sp, 4]
	ldr	w0, [x0, x21, lsl 2]
	cmp	w1, w0
	bgt	.L1348
	ldr	w0, [sp, 104]
	cbnz	w0, .L1349
.L1236:
	ldr	x1, [sp, 48]
	add	x0, x28, 4
	str	x0, [sp, 24]
	cmp	x25, x1
	bcs	.L1239
	str	w22, [x0, x25, lsl 2]
	add	w2, w2, 1
	strh	w2, [x28]
.L1237:
	mov	x0, x20
	bl	pthread_mutex_unlock
	ldr	x0, [sp, 40]
	add	x23, x23, 1
	cmp	x23, x0
	beq	.L1222
.L1254:
	ldr	x0, [sp, 16]
	ldr	x20, [x27, 192]
	ldr	w19, [x0, x23, lsl 2]
	mov	w0, 48
	uxtw	x21, w19
	umaddl	x20, w19, w0, x20
	str	x20, [sp, 112]
	cbz	x20, .L1350
	mov	x0, x20
	bl	pthread_mutex_lock
	cbnz	w0, .L1351
	mov	w0, 1
	strb	w0, [sp, 120]
	ldr	w0, [sp, 4]
	cbz	w0, .L1352
	ldr	x0, [x27, 264]
	ldr	x6, [x27, 32]
	ldr	x0, [x0, x21, lsl 3]
	ldr	x1, [sp, 64]
	madd	x28, x1, x6, x0
	b	.L1229
	.p2align 2,,3
.L1198:
	ldr	x0, [sp, 16]
	sub	x20, x20, x0
	asr	x0, x20, 2
	cmp	x0, x23
	beq	.L1353
	cmp	x0, 0
	csinc	x24, x0, xzr, ne
	add	x24, x24, x0
	cmp	x24, x23
	csel	x24, x24, x23, ls
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	lsl	x24, x24, 2
	str	x0, [sp, 8]
	mov	x0, x24
.LEHB92:
	bl	_Znwm
.LEHE92:
	ldr	w1, [x28, 4]
	mov	x21, x0
	str	w1, [x0, x20]
	cbz	x20, .L1202
	ldr	x1, [sp, 16]
	mov	x2, x20
	bl	memcpy
.L1202:
	ldr	x0, [sp, 16]
	add	x20, x20, 4
	add	x20, x21, x20
	cbz	x0, .L1203
	bl	_ZdlPv
.L1203:
	add	x24, x21, x24
	str	x21, [sp, 16]
	b	.L1199
	.p2align 2,,3
.L1349:
	cbz	x25, .L1236
	mov	x0, 1
	b	.L1238
	.p2align 2,,3
.L1354:
	cmp	x25, x0
	beq	.L1236
	add	x0, x0, 1
.L1238:
	ldr	w1, [x28, x0, lsl 2]
	cmp	w1, w22
	bne	.L1354
	mov	x0, x20
	bl	pthread_mutex_unlock
	ldr	x0, [sp, 40]
	add	x23, x23, 1
	cmp	x23, x0
	bne	.L1254
.L1222:
	ldr	x0, [sp, 16]
	bl	_ZdlPv
.L1190:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 168]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1336
	ldr	w0, [sp, 108]
	ldp	x29, x30, [sp, 176]
	ldp	x19, x20, [sp, 192]
	ldp	x21, x22, [sp, 208]
	ldp	x23, x24, [sp, 224]
	ldp	x25, x26, [sp, 240]
	ldp	x27, x28, [sp, 256]
	ldp	d14, d15, [sp, 272]
	add	sp, sp, 288
	.cfi_remember_state
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 78
	.cfi_restore 79
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L1239:
	.cfi_restore_state
	ldr	x2, [x27, 24]
	ldr	x4, [sp, 72]
	ldr	x0, [x27, 232]
	ldr	x3, [x27, 256]
	madd	x1, x21, x2, x0
	madd	x0, x4, x2, x0
	adrp	x2, :got:__stack_chk_guard
	ldr	x2, [x2, :got_lo12:__stack_chk_guard]
	str	x2, [sp, 8]
	add	x1, x3, x1
	add	x0, x3, x0
	ldp	x4, x2, [x27, 304]
.LEHB93:
	blr	x4
	fmov	s15, s0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x0, 8
	bl	_Znwm
.LEHE93:
	add	x26, x0, 8
	str	w22, [x0, 4]
	str	x26, [sp, 32]
	mov	x19, x0
	str	s15, [x0]
	cbz	x25, .L1240
	mov	x24, 1
	.p2align 5,,15
.L1250:
	ldr	x9, [x27, 24]
	ldr	x2, [x27, 232]
	ldr	w0, [x28, x24, lsl 2]
	ldr	x3, [x27, 256]
	madd	x1, x21, x9, x2
	madd	x0, x0, x9, x2
	add	x1, x3, x1
	adrp	x2, :got:__stack_chk_guard
	ldr	x2, [x2, :got_lo12:__stack_chk_guard]
	str	x2, [sp, 8]
	add	x0, x3, x0
	ldp	x9, x2, [x27, 304]
.LEHB94:
	blr	x9
.LEHE94:
	ldr	x0, [sp, 32]
	fmov	s14, s0
	cmp	x26, x0
	beq	.L1241
	ldr	w10, [x28, x24, lsl 2]
	add	x26, x26, 8
	str	s0, [x26, -8]
	str	w10, [x26, -4]
	sub	x3, x26, x19
	asr	x1, x3, 3
	sub	x3, x3, #8
	sub	x2, x1, #1
	sub	x1, x1, #2
	add	x3, x19, x3
	add	x1, x1, x1, lsr 63
	asr	x1, x1, 1
.L1242:
	cmp	x2, 0
	ble	.L1246
	.p2align 5,,15
.L1249:
	lsl	x0, x1, 3
	add	x9, x19, x1, lsl 3
	add	x3, x19, x2, lsl 3
	ldr	s31, [x19, x0]
	lsl	x0, x2, 3
	fcmpe	s14, s31
	bgt	.L1294
.L1246:
	str	s14, [x3]
	str	w10, [x3, 4]
	cmp	x25, x24
	beq	.L1240
.L1280:
	add	x24, x24, 1
	b	.L1250
	.p2align 2,,3
.L1294:
	str	s31, [x19, x0]
	mov	x2, x1
	ldr	w0, [x9, 4]
	str	w0, [x3, 4]
	sub	x0, x1, #1
	add	x0, x0, x0, lsr 63
	cbz	x1, .L1355
	asr	x1, x0, 1
	b	.L1249
	.p2align 2,,3
.L1355:
	mov	x3, x9
	str	s14, [x3]
	str	w10, [x3, 4]
	cmp	x25, x24
	bne	.L1280
.L1240:
	ldr	x2, [sp, 48]
	add	x1, sp, 128
	ldr	x0, [sp, 32]
	stp	x19, x26, [sp, 128]
	str	x0, [sp, 144]
	mov	x0, x27
.LEHB95:
	bl	_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm
.LEHE95:
	ldp	x24, x0, [sp, 128]
	mov	x19, 0
	ldr	x21, [sp, 144]
	sub	x2, x0, x24
	cbz	x2, .L1356
	.p2align 5,,15
.L1252:
	ldr	x1, [sp, 24]
	str	x21, [sp, 144]
	ldr	w2, [x24, 4]
	str	w2, [x1, x19, lsl 2]
	add	x19, x19, 1
	stp	x24, x0, [sp, 128]
	add	x0, sp, 128
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x0, [sp, 136]
	sub	x2, x0, x24
	cbnz	x2, .L1252
.L1356:
	strh	w19, [x28]
	cbz	x24, .L1237
	mov	x0, x24
	bl	_ZdlPv
	b	.L1237
	.p2align 2,,3
.L1241:
	sub	x2, x26, x19
	mov	x0, 1152921504606846975
	asr	x1, x2, 3
	cmp	x1, x0
	beq	.L1357
	cmp	x1, 0
	str	x2, [sp, 56]
	csinc	x0, x1, xzr, ne
	add	x0, x0, x1
	mov	x1, 1152921504606846975
	cmp	x0, x1
	csel	x0, x0, x1, ls
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	lsl	x0, x0, 3
	str	x1, [sp, 8]
	str	x0, [sp, 32]
.LEHB96:
	bl	_Znwm
.LEHE96:
	ldr	x2, [sp, 56]
	mov	x9, x0
	ldr	w1, [x28, x24, lsl 2]
	add	x0, x0, x2
	str	s14, [x9, x2]
	mov	x2, x9
	str	w1, [x0, 4]
	mov	x1, x19
	cmp	x26, x19
	beq	.L1358
	.p2align 5,,15
.L1245:
	ldr	x3, [x1], 8
	str	x3, [x2], 8
	cmp	x26, x1
	bne	.L1245
	sub	x4, x26, #8
	sub	x11, x9, x19
	add	x11, x11, x4
	add	x26, x11, 16
	sub	x3, x26, x9
	asr	x1, x3, 3
	sub	x3, x3, #8
	sub	x2, x1, #1
	sub	x1, x1, #2
	add	x3, x9, x3
	add	x1, x1, x1, lsr 63
	asr	x1, x1, 1
	cbz	x19, .L1247
	mov	x0, x19
	str	x2, [sp, 8]
	str	x1, [sp, 56]
	stp	x3, x9, [sp, 80]
	str	x11, [sp, 96]
	bl	_ZdlPv
	ldp	x3, x9, [sp, 80]
	ldr	x2, [sp, 8]
	ldr	x1, [sp, 56]
	ldr	x11, [sp, 96]
.L1247:
	mov	x19, x9
	ldr	x0, [sp, 32]
	ldr	s14, [x11, 8]
	add	x0, x9, x0
	ldr	w10, [x11, 12]
	str	x0, [sp, 32]
	b	.L1242
.L1274:
	mov	x20, 0
	mov	x24, 0
	mov	x23, 2305843009213693951
	str	x20, [sp, 16]
	b	.L1197
.L1210:
	ldr	x0, [x27, 264]
	ldr	w1, [sp, 4]
	ldr	x2, [x27, 32]
	sub	w1, w1, #1
	ldr	x0, [x0, w22, uxtw 3]
	sxtw	x1, w1
	madd	x1, x1, x2, x0
	b	.L1211
.L1341:
	cbz	x21, .L1359
	mov	x0, x21
	bl	pthread_mutex_lock
	cbnz	w0, .L1360
	mov	w0, 1
	strb	w0, [sp, 136]
	b	.L1205
.L1358:
	mov	x0, x19
	add	x26, x9, 8
	str	x9, [sp, 8]
	bl	_ZdlPv
	ldr	x9, [sp, 8]
	ldr	x0, [sp, 32]
	mov	x19, x9
	ldr	s14, [x9]
	mov	x3, x9
	add	x0, x9, x0
	ldr	w10, [x9, 4]
	str	x0, [sp, 32]
	b	.L1246
.L1343:
	cmp	x21, 0
	ldrb	w0, [sp, 136]
	cset	w1, ne
	tst	w1, w0
	beq	.L1216
.L1215:
	mov	x0, x21
	bl	pthread_mutex_unlock
.L1216:
	ldr	x0, [sp, 40]
	cbnz	x0, .L1221
	ldr	x0, [sp, 16]
	cbz	x0, .L1190
	b	.L1222
.L1348:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC32
	mov	x20, x0
	add	x1, x1, :lo12:.LC32
.LEHB97:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE97:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	beq	.L1235
.L1336:
	bl	__stack_chk_fail
.L1291:
	mov	x19, x0
.L1271:
	ldr	x2, [sp, 8]
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	mov	x0, x19
.LEHB98:
	bl	_Unwind_Resume
.LEHE98:
.L1339:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x0, .LC29
	add	x0, x0, :lo12:.LC29
.LEHB99:
	bl	_ZSt20__throw_length_errorPKc
.LEHE99:
.L1338:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC28
	mov	x19, x0
	add	x1, x1, :lo12:.LC28
.LEHB100:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE100:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 168]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1336
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x19
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB101:
	bl	__cxa_throw
.L1289:
	mov	x20, x0
	mov	x0, x19
	bl	__cxa_free_exception
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 168]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1336
	mov	x0, x20
	bl	_Unwind_Resume
.LEHE101:
.L1292:
	mov	x19, x0
.L1262:
	ldr	x0, [sp, 16]
	cbz	x0, .L1271
	bl	_ZdlPv
	b	.L1271
.L1353:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB102:
	bl	_ZSt20__throw_length_errorPKc
.L1359:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	mov	w0, 1
	bl	_ZSt20__throw_system_errori
.LEHE102:
.L1290:
	ldr	x19, [sp, 128]
	mov	x20, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	cbz	x19, .L1269
.L1361:
	mov	x0, x19
	bl	_ZdlPv
.L1269:
	mov	x19, x20
.L1264:
	add	x0, sp, 112
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	b	.L1262
.L1293:
	mov	x20, x0
	cbnz	x19, .L1361
	b	.L1269
.L1281:
	mov	x19, x0
	b	.L1264
.L1346:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC33
	mov	x20, x0
	add	x1, x1, :lo12:.LC33
.LEHB103:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE103:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x20
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB104:
	bl	__cxa_throw
.LEHE104:
.L1350:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	mov	w0, 1
.LEHB105:
	bl	_ZSt20__throw_system_errori
.LEHE105:
.L1342:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC30
	mov	x20, x0
	add	x1, x1, :lo12:.LC30
.LEHB106:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE106:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x20
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB107:
	bl	__cxa_throw
.LEHE107:
.L1288:
.L1333:
	mov	x19, x0
	mov	x0, x20
	bl	__cxa_free_exception
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
.L1258:
	ldrb	w0, [sp, 136]
	tbz	x0, 0, .L1262
	add	x0, sp, 128
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	b	.L1262
.L1285:
	mov	x19, x0
	b	.L1258
.L1345:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC32
	mov	x20, x0
	add	x1, x1, :lo12:.LC32
.LEHB108:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE108:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x20
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB109:
	bl	__cxa_throw
.LEHE109:
.L1357:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB110:
	bl	_ZSt20__throw_length_errorPKc
.LEHE110:
.L1347:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC34
	mov	x20, x0
	add	x1, x1, :lo12:.LC34
.LEHB111:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE111:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x20
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB112:
	bl	__cxa_throw
.LEHE112:
.L1344:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC31
	mov	x20, x0
	add	x1, x1, :lo12:.LC31
.LEHB113:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE113:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1336
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x20
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB114:
	bl	__cxa_throw
.LEHE114:
.L1287:
	b	.L1333
.L1284:
.L1334:
	mov	x19, x0
	mov	x0, x20
	bl	__cxa_free_exception
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	b	.L1264
.L1286:
	b	.L1333
.L1235:
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x20
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB115:
	bl	__cxa_throw
.LEHE115:
.L1282:
	b	.L1334
.L1360:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	str	x1, [sp, 8]
	mov	x3, x1
	ldr	x1, [sp, 168]
	ldr	x2, [x3]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1336
.LEHB116:
	bl	_ZSt20__throw_system_errori
.L1351:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	str	x1, [sp, 8]
	mov	x3, x1
	ldr	x1, [sp, 168]
	ldr	x2, [x3]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1336
	bl	_ZSt20__throw_system_errori
.LEHE116:
.L1283:
	b	.L1334
	.cfi_endproc
.LFE12864:
	.section	.gcc_except_table
.LLSDA12864:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12864-.LLSDACSB12864
.LLSDACSB12864:
	.uleb128 .LEHB90-.LFB12864
	.uleb128 .LEHE90-.LEHB90
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB91-.LFB12864
	.uleb128 .LEHE91-.LEHB91
	.uleb128 .L1291-.LFB12864
	.uleb128 0
	.uleb128 .LEHB92-.LFB12864
	.uleb128 .LEHE92-.LEHB92
	.uleb128 .L1292-.LFB12864
	.uleb128 0
	.uleb128 .LEHB93-.LFB12864
	.uleb128 .LEHE93-.LEHB93
	.uleb128 .L1281-.LFB12864
	.uleb128 0
	.uleb128 .LEHB94-.LFB12864
	.uleb128 .LEHE94-.LEHB94
	.uleb128 .L1293-.LFB12864
	.uleb128 0
	.uleb128 .LEHB95-.LFB12864
	.uleb128 .LEHE95-.LEHB95
	.uleb128 .L1290-.LFB12864
	.uleb128 0
	.uleb128 .LEHB96-.LFB12864
	.uleb128 .LEHE96-.LEHB96
	.uleb128 .L1293-.LFB12864
	.uleb128 0
	.uleb128 .LEHB97-.LFB12864
	.uleb128 .LEHE97-.LEHB97
	.uleb128 .L1282-.LFB12864
	.uleb128 0
	.uleb128 .LEHB98-.LFB12864
	.uleb128 .LEHE98-.LEHB98
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB99-.LFB12864
	.uleb128 .LEHE99-.LEHB99
	.uleb128 .L1291-.LFB12864
	.uleb128 0
	.uleb128 .LEHB100-.LFB12864
	.uleb128 .LEHE100-.LEHB100
	.uleb128 .L1289-.LFB12864
	.uleb128 0
	.uleb128 .LEHB101-.LFB12864
	.uleb128 .LEHE101-.LEHB101
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB102-.LFB12864
	.uleb128 .LEHE102-.LEHB102
	.uleb128 .L1292-.LFB12864
	.uleb128 0
	.uleb128 .LEHB103-.LFB12864
	.uleb128 .LEHE103-.LEHB103
	.uleb128 .L1284-.LFB12864
	.uleb128 0
	.uleb128 .LEHB104-.LFB12864
	.uleb128 .LEHE104-.LEHB104
	.uleb128 .L1281-.LFB12864
	.uleb128 0
	.uleb128 .LEHB105-.LFB12864
	.uleb128 .LEHE105-.LEHB105
	.uleb128 .L1292-.LFB12864
	.uleb128 0
	.uleb128 .LEHB106-.LFB12864
	.uleb128 .LEHE106-.LEHB106
	.uleb128 .L1288-.LFB12864
	.uleb128 0
	.uleb128 .LEHB107-.LFB12864
	.uleb128 .LEHE107-.LEHB107
	.uleb128 .L1285-.LFB12864
	.uleb128 0
	.uleb128 .LEHB108-.LFB12864
	.uleb128 .LEHE108-.LEHB108
	.uleb128 .L1286-.LFB12864
	.uleb128 0
	.uleb128 .LEHB109-.LFB12864
	.uleb128 .LEHE109-.LEHB109
	.uleb128 .L1285-.LFB12864
	.uleb128 0
	.uleb128 .LEHB110-.LFB12864
	.uleb128 .LEHE110-.LEHB110
	.uleb128 .L1293-.LFB12864
	.uleb128 0
	.uleb128 .LEHB111-.LFB12864
	.uleb128 .LEHE111-.LEHB111
	.uleb128 .L1283-.LFB12864
	.uleb128 0
	.uleb128 .LEHB112-.LFB12864
	.uleb128 .LEHE112-.LEHB112
	.uleb128 .L1281-.LFB12864
	.uleb128 0
	.uleb128 .LEHB113-.LFB12864
	.uleb128 .LEHE113-.LEHB113
	.uleb128 .L1287-.LFB12864
	.uleb128 0
	.uleb128 .LEHB114-.LFB12864
	.uleb128 .LEHE114-.LEHB114
	.uleb128 .L1285-.LFB12864
	.uleb128 0
	.uleb128 .LEHB115-.LFB12864
	.uleb128 .LEHE115-.LEHB115
	.uleb128 .L1281-.LFB12864
	.uleb128 0
	.uleb128 .LEHB116-.LFB12864
	.uleb128 .LEHE116-.LEHB116
	.uleb128 .L1292-.LFB12864
	.uleb128 0
.LLSDACSE12864:
	.text
	.size	_ZN7hnswlib15HierarchicalNSWIfE25mutuallyConnectNewElementEPKvjRSt14priority_queueISt4pairIfjESt6vectorIS6_SaIS6_EENS1_14CompareByFirstEEib.isra.0, .-_ZN7hnswlib15HierarchicalNSWIfE25mutuallyConnectNewElementEPKvjRSt14priority_queueISt4pairIfjESt6vectorIS6_SaIS6_EENS1_14CompareByFirstEEib.isra.0
	.section	.rodata._ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii.str1.8,"aMS",@progbits,1
	.align	3
.LC35:
	.string	"Level of item to be updated cannot be bigger than max level"
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii
	.type	_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii, %function
_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii:
.LFB11496:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA11496
	sub	sp, sp, #224
	.cfi_def_cfa_offset 224
	stp	x29, x30, [sp, 112]
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	add	x29, sp, 112
	stp	x25, x26, [sp, 176]
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	mov	x26, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	w5, [sp, 8]
	stp	w4, w2, [sp, 24]
	stp	x19, x20, [sp, 128]
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	mov	x20, x1
	stp	x21, x22, [sp, 144]
	stp	x23, x24, [sp, 160]
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	mov	w24, w3
	stp	x27, x28, [sp, 192]
	str	d15, [sp, 208]
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	.cfi_offset 79, -16
	ldr	x1, [x0]
	str	x1, [sp, 104]
	mov	x1, 0
	cmp	w4, w5
	bge	.L1418
	ldr	x1, [x26, 232]
	uxtw	x0, w2
	mov	w22, w2
	mov	w25, w5
	ldr	x2, [x26, 24]
	madd	x0, x0, x2, x1
	ldp	x3, x2, [x26, 304]
	ldr	x1, [x26, 256]
	add	x1, x1, x0
	mov	x0, x20
.LEHB117:
	blr	x3
.LEHE117:
	fmov	s15, s0
	.p2align 5,,15
.L1364:
	sub	w0, w25, #1
	sxtw	x0, w0
	str	x0, [sp]
	.p2align 5,,15
.L1376:
	ldr	x21, [x26, 192]
	mov	w0, 48
	uxtw	x19, w22
	umaddl	x21, w22, w0, x21
	str	x21, [sp, 64]
	cbz	x21, .L1462
	mov	x0, x21
	bl	pthread_mutex_lock
	cbnz	w0, .L1463
	mov	w0, 1
	strb	w0, [sp, 72]
	cbnz	w25, .L1369
	ldr	x1, [x26, 24]
	ldr	x0, [x26, 240]
	madd	x1, x19, x1, x0
	ldr	x0, [x26, 256]
	add	x0, x0, x1
	ldrh	w19, [x0]
	cbz	w19, .L1371
.L1467:
	sub	w19, w19, #1
	add	x27, x0, 4
	add	x0, x0, 8
	mov	w23, 0
	add	x19, x0, w19, uxtw 2
	.p2align 5,,15
.L1373:
	ldr	w28, [x27]
	ldr	x2, [x26, 24]
	uxtw	x0, w28
	ldr	x1, [x26, 232]
	madd	x0, x0, x2, x1
	ldp	x3, x2, [x26, 304]
	ldr	x1, [x26, 256]
	add	x1, x1, x0
	mov	x0, x20
.LEHB118:
	blr	x3
.LEHE118:
	fcmpe	s0, s15
	bmi	.L1419
.L1372:
	add	x27, x27, 4
	cmp	x27, x19
	bne	.L1373
	mov	x0, x21
	bl	pthread_mutex_unlock
	cbnz	w23, .L1376
	ldr	w0, [sp, 24]
	sub	w25, w25, #1
	cmp	w0, w25
	bne	.L1364
.L1363:
	ldr	w1, [sp, 8]
	ldr	w0, [sp, 24]
	cmp	w0, w1
	bgt	.L1377
	add	x1, sp, 64
	str	x1, [sp]
	ldr	w1, [sp, 28]
	add	x23, sp, 32
	str	x1, [sp, 8]
	tbnz	w0, #31, .L1362
	.p2align 5,,15
.L1378:
	ldr	w3, [sp, 24]
	mov	x0, x26
	mov	x8, x23
	mov	x2, x20
	mov	w1, w22
	mov	x25, 0
	mov	x28, 0
	mov	x19, 0
.LEHB119:
	bl	_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi
.LEHE119:
	ldp	x21, x27, [sp, 32]
	sub	x0, x27, x21
	cbz	x0, .L1464
	.p2align 5,,15
.L1388:
	ldr	w0, [x21, 4]
	cmp	w0, w24
	beq	.L1381
	cmp	x28, x25
	beq	.L1382
	ldr	x0, [x21]
	str	x0, [x28], 8
	sub	x2, x28, x19
	ldr	s30, [x28, -8]
	ldr	w7, [x28, -4]
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	ble	.L1384
.L1469:
	sub	x1, x1, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L1387:
	lsl	x2, x1, 3
	add	x3, x19, x1, lsl 3
	ldr	s29, [x19, x2]
	lsl	x2, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s29, s30
	bmi	.L1428
.L1385:
	str	w7, [x0, 4]
	str	s30, [x0]
.L1381:
	mov	x0, x23
	stp	x21, x27, [sp, 32]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x27, [sp, 40]
	sub	x0, x27, x21
	cbnz	x0, .L1388
.L1464:
	subs	x3, x28, x19
	beq	.L1389
	ldr	x2, [sp, 8]
	ldr	x0, [x26, 24]
	ldr	x1, [x26, 256]
	ldr	x4, [x26, 240]
	mul	x0, x2, x0
	add	x2, x1, x0
	add	x2, x2, x4
	ldrb	w2, [x2, 2]
	tbz	x2, 0, .L1390
	ldr	x2, [x26, 232]
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	add	x0, x0, x2
	ldp	x4, x2, [x26, 304]
	add	x1, x1, x0
	mov	x0, x20
	str	x3, [sp, 16]
.LEHB120:
	blr	x4
.LEHE120:
	ldr	x3, [sp, 16]
	fmov	s15, s0
	cmp	x28, x25
	beq	.L1391
	ldr	w0, [sp, 28]
	add	x28, x28, 8
	str	s0, [x28, -8]
	str	w0, [x28, -4]
	sub	x1, x28, x19
	mov	w7, w0
	asr	x4, x1, 3
	sub	x0, x4, #1
	cmp	x0, 0
	ble	.L1398
.L1471:
	sub	x1, x4, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L1401:
	lsl	x2, x1, 3
	add	x3, x19, x1, lsl 3
	ldr	s31, [x19, x2]
	lsl	x2, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s31, s15
	bmi	.L1429
.L1399:
	str	w7, [x0, 4]
	str	s15, [x0]
.L1416:
	ldr	x0, [x26, 72]
	cmp	x0, x4
	bcc	.L1465
.L1390:
	ldr	x2, [sp]
	mov	w1, w24
	ldr	w3, [sp, 24]
	mov	x0, x26
	mov	w4, 1
	stp	x19, x28, [sp, 64]
	str	x25, [sp, 80]
.LEHB121:
	bl	_ZN7hnswlib15HierarchicalNSWIfE25mutuallyConnectNewElementEPKvjRSt14priority_queueISt4pairIfjESt6vectorIS6_SaIS6_EENS1_14CompareByFirstEEib.isra.0
.LEHE121:
	ldr	x19, [sp, 64]
	mov	w22, w0
.L1389:
	cbz	x19, .L1405
	mov	x0, x19
	bl	_ZdlPv
.L1405:
	cbz	x21, .L1406
	mov	x0, x21
	bl	_ZdlPv
.L1406:
	ldr	w0, [sp, 24]
	sub	w0, w0, #1
	str	w0, [sp, 24]
	cmn	w0, #1
	bne	.L1378
.L1362:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 104]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1461
	ldr	d15, [sp, 208]
	ldp	x29, x30, [sp, 112]
	ldp	x19, x20, [sp, 128]
	ldp	x21, x22, [sp, 144]
	ldp	x23, x24, [sp, 160]
	ldp	x25, x26, [sp, 176]
	ldp	x27, x28, [sp, 192]
	add	sp, sp, 224
	.cfi_remember_state
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 79
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L1428:
	.cfi_restore_state
	str	s29, [x19, x2]
	ldr	w2, [x3, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L1466
	asr	x1, x2, 1
	b	.L1387
	.p2align 2,,3
.L1419:
	fmov	s15, s0
	mov	w22, w28
	mov	w23, 1
	b	.L1372
	.p2align 2,,3
.L1466:
	mov	x0, x3
	b	.L1385
	.p2align 2,,3
.L1369:
	ldr	x1, [x26, 264]
	ldr	x2, [sp]
	ldr	x1, [x1, x19, lsl 3]
	ldr	x0, [x26, 32]
	madd	x0, x2, x0, x1
	ldrh	w19, [x0]
	cbnz	w19, .L1467
.L1371:
	mov	x0, x21
	bl	pthread_mutex_unlock
	ldr	w0, [sp, 24]
	sub	w25, w25, #1
	cmp	w0, w25
	bne	.L1364
	b	.L1363
	.p2align 2,,3
.L1429:
	str	s31, [x19, x2]
	ldr	w2, [x3, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L1468
	asr	x1, x2, 1
	b	.L1401
	.p2align 2,,3
.L1382:
	ldr	x0, [sp]
	mov	x1, x21
	stp	x19, x28, [sp, 64]
	str	x28, [sp, 80]
.LEHB122:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRKS1_EEEvDpOT_
.LEHE122:
	ldp	x19, x28, [sp, 64]
	ldr	x25, [sp, 80]
	sub	x2, x28, x19
	ldr	s30, [x28, -8]
	ldr	w7, [x28, -4]
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	bgt	.L1469
.L1384:
	sub	x2, x2, #8
	add	x0, x19, x2
	b	.L1385
.L1468:
	mov	x0, x3
	b	.L1399
.L1465:
	ldr	x0, [sp]
	stp	x19, x28, [sp, 64]
	str	x25, [sp, 80]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x28, [sp, 72]
	b	.L1390
.L1418:
	ldr	w22, [sp, 28]
	b	.L1363
.L1391:
	asr	x1, x3, 3
	mov	x0, 9223372036854775800
	cmp	x3, x0
	beq	.L1470
	cmp	x1, 0
	str	x3, [sp, 16]
	csinc	x0, x1, xzr, ne
	add	x0, x0, x1
	mov	x1, 1152921504606846975
	cmp	x0, x1
	csel	x0, x0, x1, ls
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	lsl	x25, x0, 3
	mov	x0, x25
.LEHB123:
	bl	_Znwm
.LEHE123:
	ldr	x3, [sp, 16]
	mov	x8, x0
	ldr	w0, [sp, 28]
	add	x4, x8, x3
	str	s15, [x8, x3]
	str	w0, [x4, 4]
	cmp	x28, x19
	beq	.L1421
	mov	x0, x8
	mov	x1, x19
.L1396:
	ldr	x2, [x1], 8
	str	x2, [x0], 8
	cmp	x0, x4
	bne	.L1396
	mov	x22, x0
.L1395:
	add	x28, x22, 8
	cbz	x19, .L1397
	mov	x0, x19
	str	x8, [sp, 16]
	bl	_ZdlPv
	ldr	x8, [sp, 16]
.L1397:
	mov	x19, x8
	sub	x1, x28, x19
	ldr	s15, [x22]
	ldr	w7, [x22, 4]
	add	x25, x8, x25
	asr	x4, x1, 3
	sub	x0, x4, #1
	cmp	x0, 0
	bgt	.L1471
.L1398:
	sub	x1, x1, #8
	add	x0, x19, x1
	str	s15, [x19, x1]
	str	w7, [x0, 4]
	b	.L1416
.L1421:
	mov	x22, x8
	b	.L1395
.L1377:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC35
	mov	x19, x0
	add	x1, x1, :lo12:.LC35
.LEHB124:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE124:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 104]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	beq	.L1379
.L1461:
	bl	__stack_chk_fail
.L1423:
	mov	x19, x0
	add	x0, sp, 64
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 104]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1461
	mov	x0, x19
.LEHB125:
	bl	_Unwind_Resume
.L1379:
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x19
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
	bl	__cxa_throw
.L1427:
	mov	x20, x0
	cbz	x19, .L1413
.L1472:
	mov	x0, x19
	bl	_ZdlPv
.L1413:
	cbz	x21, .L1414
	mov	x0, x21
	bl	_ZdlPv
.L1414:
	ldr	x0, [sp, 104]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1461
.L1415:
	mov	x0, x20
	bl	_Unwind_Resume
.LEHE125:
.L1426:
.L1459:
	ldr	x19, [sp, 64]
	mov	x20, x0
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	cbnz	x19, .L1472
	b	.L1413
.L1425:
	b	.L1459
.L1470:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 104]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1461
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB126:
	bl	_ZSt20__throw_length_errorPKc
.LEHE126:
.L1463:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 104]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	bne	.L1461
.LEHB127:
	bl	_ZSt20__throw_system_errori
.L1424:
	mov	x20, x0
	mov	x0, x19
	bl	__cxa_free_exception
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 104]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	beq	.L1415
	b	.L1461
.L1462:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 104]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1461
	mov	w0, 1
	bl	_ZSt20__throw_system_errori
.LEHE127:
	.cfi_endproc
.LFE11496:
	.section	.gcc_except_table
.LLSDA11496:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE11496-.LLSDACSB11496
.LLSDACSB11496:
	.uleb128 .LEHB117-.LFB11496
	.uleb128 .LEHE117-.LEHB117
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB118-.LFB11496
	.uleb128 .LEHE118-.LEHB118
	.uleb128 .L1423-.LFB11496
	.uleb128 0
	.uleb128 .LEHB119-.LFB11496
	.uleb128 .LEHE119-.LEHB119
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB120-.LFB11496
	.uleb128 .LEHE120-.LEHB120
	.uleb128 .L1427-.LFB11496
	.uleb128 0
	.uleb128 .LEHB121-.LFB11496
	.uleb128 .LEHE121-.LEHB121
	.uleb128 .L1426-.LFB11496
	.uleb128 0
	.uleb128 .LEHB122-.LFB11496
	.uleb128 .LEHE122-.LEHB122
	.uleb128 .L1425-.LFB11496
	.uleb128 0
	.uleb128 .LEHB123-.LFB11496
	.uleb128 .LEHE123-.LEHB123
	.uleb128 .L1427-.LFB11496
	.uleb128 0
	.uleb128 .LEHB124-.LFB11496
	.uleb128 .LEHE124-.LEHB124
	.uleb128 .L1424-.LFB11496
	.uleb128 0
	.uleb128 .LEHB125-.LFB11496
	.uleb128 .LEHE125-.LEHB125
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB126-.LFB11496
	.uleb128 .LEHE126-.LEHB126
	.uleb128 .L1427-.LFB11496
	.uleb128 0
	.uleb128 .LEHB127-.LFB11496
	.uleb128 .LEHE127-.LEHB127
	.uleb128 0
	.uleb128 0
.LLSDACSE11496:
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii,comdat
	.size	_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii, .-_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii
	.section	.text._ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm,"axG",@progbits,_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm
	.type	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm, %function
_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm:
.LFB12260:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12260
	stp	x29, x30, [sp, -64]!
	.cfi_def_cfa_offset 64
	.cfi_offset 29, -64
	.cfi_offset 30, -56
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -48
	.cfi_offset 20, -40
	mov	x19, x0
	add	x0, x0, 32
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -32
	.cfi_offset 22, -24
	mov	x22, x2
	stp	x23, x24, [sp, 48]
	.cfi_offset 23, -16
	.cfi_offset 24, -8
	mov	x23, x1
	mov	x24, x3
	ldr	x1, [x19, 8]
	mov	x3, x4
	ldr	x2, [x19, 24]
	ldr	x20, [x19, 40]
.LEHB128:
	bl	_ZNKSt8__detail20_Prime_rehash_policy14_M_need_rehashEmmm
	mov	x21, x1
	tbnz	x0, 0, .L1474
	ldr	x20, [x19]
	ldr	x0, [x20, x23, lsl 3]
	add	x1, x20, x23, lsl 3
	cbz	x0, .L1487
.L1510:
	ldr	x0, [x0]
	str	x0, [x24]
	ldr	x0, [x20, x23, lsl 3]
	str	x24, [x0]
.L1488:
	ldr	x0, [x19, 24]
	add	x0, x0, 1
	str	x0, [x19, 24]
	mov	x0, x24
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 64
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L1474:
	.cfi_restore_state
	cmp	x1, 1
	beq	.L1506
	mov	x0, 1152921504606846975
	cmp	x1, x0
	bhi	.L1507
	lsl	x0, x1, 3
	bl	_Znwm
	mov	x20, x0
	lsl	x2, x21, 3
	mov	w1, 0
	bl	memset
	add	x8, x19, 48
.L1477:
	add	x3, x19, 16
	mov	x7, 0
	ldr	x4, [x19, 16]
	str	xzr, [x19, 16]
.L1505:
	cbz	x4, .L1508
.L1480:
	ldr	w1, [x4, 8]
	mov	x2, x4
	ldr	x4, [x4]
	udiv	x5, x1, x21
	msub	x5, x5, x21, x1
	ubfiz	x1, x5, 3, 32
	ldr	x6, [x20, x1]
	cbz	x6, .L1509
	ldr	x0, [x6]
	str	x0, [x2]
	ldr	x0, [x20, x1]
	str	x2, [x0]
	cbnz	x4, .L1480
.L1508:
	ldr	x0, [x19]
	cmp	x0, x8
	beq	.L1481
	bl	_ZdlPv
.L1481:
	udiv	x23, x22, x21
	stp	x20, x21, [x19]
	msub	x23, x23, x21, x22
	add	x1, x20, x23, lsl 3
	ldr	x0, [x20, x23, lsl 3]
	cbnz	x0, .L1510
.L1487:
	ldr	x0, [x19, 16]
	str	x0, [x24]
	str	x24, [x19, 16]
	ldr	x0, [x24]
	cbz	x0, .L1489
	ldr	x2, [x19, 8]
	ldr	w3, [x0, 8]
	udiv	x0, x3, x2
	msub	w0, w0, w2, w3
	str	x24, [x20, x0, lsl 3]
.L1489:
	add	x0, x19, 16
	str	x0, [x1]
	b	.L1488
	.p2align 2,,3
.L1509:
	ldr	x0, [x19, 16]
	str	x0, [x2]
	str	x2, [x19, 16]
	str	x3, [x20, x1]
	ldr	x0, [x2]
	cbz	x0, .L1484
	str	x2, [x20, w7, uxtw 3]
.L1484:
	mov	x7, x5
	b	.L1505
	.p2align 2,,3
.L1506:
	mov	x8, x19
	str	xzr, [x8, 48]!
	mov	x20, x8
	b	.L1477
	.p2align 2,,3
.L1507:
	mov	x0, 2305843009213693951
	cmp	x1, x0
	bls	.L1479
	bl	_ZSt28__throw_bad_array_new_lengthv
.L1479:
	bl	_ZSt17__throw_bad_allocv
.LEHE128:
.L1492:
	str	x20, [x19, 40]
.LEHB129:
	bl	_Unwind_Resume
.LEHE129:
	.cfi_endproc
.LFE12260:
	.section	.gcc_except_table
.LLSDA12260:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12260-.LLSDACSB12260
.LLSDACSB12260:
	.uleb128 .LEHB128-.LFB12260
	.uleb128 .LEHE128-.LEHB128
	.uleb128 .L1492-.LFB12260
	.uleb128 0
	.uleb128 .LEHB129-.LFB12260
	.uleb128 .LEHE129-.LEHB129
	.uleb128 0
	.uleb128 0
.LLSDACSE12260:
	.section	.text._ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm,"axG",@progbits,_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm,comdat
	.size	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm, .-_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm
	.section	.text._ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf,comdat
	.align	2
	.p2align 5,,15
	.type	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0, %function
_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0:
.LFB12868:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12868
	ldr	w4, [x1]
	ldr	x1, [x0, 24]
	cbz	x1, .L1512
	ldp	x3, x7, [x0]
	uxtw	x2, w4
	udiv	x1, x2, x7
	msub	x1, x1, x7, x2
	ldr	x3, [x3, w1, uxtw 3]
	cbz	x3, .L1513
	ldr	x3, [x3]
	ldr	w6, [x3, 8]
.L1518:
	cmp	w4, w6
	beq	.L1534
	ldr	x3, [x3]
	cbz	x3, .L1513
	ldr	w6, [x3, 8]
	uxtw	x8, w6
	udiv	x5, x8, x7
	msub	x5, x5, x7, x8
	cmp	x1, x5
	beq	.L1518
	b	.L1513
	.p2align 2,,3
.L1512:
	ldr	x1, [x0, 16]
	cbnz	x1, .L1517
	.p2align 5,,15
.L1515:
	ldr	x3, [x0, 8]
	uxtw	x2, w4
	udiv	x1, x2, x3
	msub	x1, x1, x3, x2
.L1513:
	stp	x29, x30, [sp, -64]!
	.cfi_def_cfa_offset 64
	.cfi_offset 29, -64
	.cfi_offset 30, -56
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -48
	.cfi_offset 20, -40
	mov	x19, x0
	mov	x0, 16
	str	w4, [sp, 44]
	stp	x1, x2, [sp, 48]
.LEHB130:
	bl	_Znwm
.LEHE130:
	mov	x1, x0
	ldr	w4, [sp, 44]
	mov	x20, x0
	mov	x3, x0
	mov	x0, x19
	str	xzr, [x1]
	str	w4, [x1, 8]
	mov	x4, 1
	ldp	x1, x2, [sp, 48]
.LEHB131:
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE21_M_insert_unique_nodeEmmPNS1_10_Hash_nodeIjLb0EEEm
.LEHE131:
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 64
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L1536:
	ldr	x1, [x1]
	cbz	x1, .L1515
.L1517:
	ldr	w2, [x1, 8]
	cmp	w2, w4
	bne	.L1536
.L1534:
	ret
.L1520:
	.cfi_def_cfa_offset 64
	.cfi_offset 19, -48
	.cfi_offset 20, -40
	.cfi_offset 29, -64
	.cfi_offset 30, -56
	mov	x19, x0
	mov	x0, x20
	bl	_ZdlPv
	mov	x0, x19
.LEHB132:
	bl	_Unwind_Resume
.LEHE132:
	.cfi_endproc
.LFE12868:
	.section	.gcc_except_table
.LLSDA12868:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12868-.LLSDACSB12868
.LLSDACSB12868:
	.uleb128 .LEHB130-.LFB12868
	.uleb128 .LEHE130-.LEHB130
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB131-.LFB12868
	.uleb128 .LEHE131-.LEHB131
	.uleb128 .L1520-.LFB12868
	.uleb128 0
	.uleb128 .LEHB132-.LFB12868
	.uleb128 .LEHE132-.LEHB132
	.uleb128 0
	.uleb128 0
.LLSDACSE12868:
	.section	.text._ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf,comdat
	.size	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0, .-_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf
	.type	_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf, %function
_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf:
.LFB11103:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA11103
	sub	sp, sp, #416
	.cfi_def_cfa_offset 416
	stp	x29, x30, [sp, 288]
	.cfi_offset 29, -128
	.cfi_offset 30, -120
	add	x29, sp, 288
	stp	x25, x26, [sp, 352]
	.cfi_offset 25, -64
	.cfi_offset 26, -56
	mov	x26, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x1, [sp, 80]
	str	w2, [sp, 92]
	stp	x19, x20, [sp, 304]
	.cfi_offset 19, -112
	.cfi_offset 20, -104
	uxtw	x19, w2
	stp	d14, d15, [sp, 400]
	ldr	x3, [x0]
	str	x3, [sp, 280]
	mov	x3, 0
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	fmov	s14, s0
	ldr	x0, [x26, 24]
	str	w19, [sp, 60]
	ldr	x2, [x26, 232]
	ldr	x3, [x26, 256]
	madd	x0, x19, x0, x2
	ldr	x2, [x26, 296]
	add	x0, x3, x0
	bl	memcpy
	ldr	w0, [x26, 104]
	str	w0, [sp, 76]
	ldr	w0, [x26, 216]
	str	w0, [sp, 88]
	cmp	w19, w0
	beq	.L1698
.L1538:
	ldr	x0, [x26, 272]
	ldr	w0, [x0, w19, uxtw 2]
	str	w0, [sp, 72]
	tbnz	w0, #31, .L1552
	add	x0, sp, 216
	str	x0, [sp, 32]
	add	x0, sp, 272
	stp	d12, d13, [sp, 384]
	.cfi_offset 77, -24
	.cfi_offset 76, -32
	movi	v13.2s, 0x30, lsl 24
	str	x0, [sp, 40]
	add	x0, sp, 104
	mov	x25, 0
	str	x0, [sp, 64]
	mov	w0, 1065353215
	fmov	s12, w0
	stp	x21, x22, [sp, 320]
	.cfi_offset 22, -88
	.cfi_offset 21, -96
	stp	x23, x24, [sp, 336]
	.cfi_offset 24, -72
	.cfi_offset 23, -80
	stp	x27, x28, [sp, 368]
	.cfi_offset 28, -40
	.cfi_offset 27, -48
	.p2align 5,,15
.L1540:
	ldr	w1, [sp, 60]
	ldr	x0, [sp, 32]
	str	x0, [sp, 168]
	ldr	x8, [sp, 64]
	mov	x0, 1
	str	x0, [sp, 176]
	fmov	s31, 1.0e+0
	ldr	x0, [sp, 40]
	str	x0, [sp, 224]
	mov	x0, 1
	mov	w2, w25
	str	w25, [sp, 8]
	stp	xzr, xzr, [sp, 184]
	str	s31, [sp, 200]
	stp	xzr, xzr, [sp, 208]
	str	x0, [sp, 232]
	mov	x0, x26
	stp	xzr, xzr, [sp, 240]
	str	s31, [sp, 256]
	stp	xzr, xzr, [sp, 264]
.LEHB133:
	bl	_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji
.LEHE133:
	ldp	x0, x21, [sp, 104]
	str	x0, [sp, 48]
	cmp	x21, x0
	bne	.L1541
	cbz	x21, .L1542
	mov	x0, x21
	bl	_ZdlPv
.L1542:
	ldr	x19, [sp, 240]
	cbz	x19, .L1546
	.p2align 5,,15
.L1543:
	mov	x0, x19
	ldr	x19, [x19]
	bl	_ZdlPv
	cbnz	x19, .L1543
.L1546:
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 224]
	cmp	x0, x1
	beq	.L1544
	bl	_ZdlPv
.L1544:
	ldr	x19, [sp, 184]
	cbz	x19, .L1614
	.p2align 5,,15
.L1547:
	mov	x0, x19
	ldr	x19, [x19]
	bl	_ZdlPv
	cbnz	x19, .L1547
.L1614:
	ldr	x1, [sp, 32]
	ldr	x0, [sp, 168]
	cmp	x0, x1
	beq	.L1551
	bl	_ZdlPv
.L1551:
	ldr	w0, [sp, 72]
	add	x25, x25, 1
	cmp	w0, w25
	bge	.L1540
	ldp	x21, x22, [sp, 320]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x23, x24, [sp, 336]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 368]
	.cfi_restore 28
	.cfi_restore 27
	ldp	d12, d13, [sp, 384]
	.cfi_restore 77
	.cfi_restore 76
.L1552:
	mov	x0, x26
	ldr	x1, [sp, 80]
	ldr	w3, [sp, 60]
	ldp	w4, w5, [sp, 72]
	ldr	w2, [sp, 88]
.LEHB134:
	bl	_ZN7hnswlib15HierarchicalNSWIfE26repairConnectionsForUpdateEPKvjjii
.LEHE134:
.L1537:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 280]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1699
	ldp	x29, x30, [sp, 288]
	ldp	x19, x20, [sp, 304]
	ldp	x25, x26, [sp, 352]
	ldp	d14, d15, [sp, 400]
	add	sp, sp, 416
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 78
	.cfi_restore 79
	.cfi_def_cfa_offset 0
	ret
.L1541:
	.cfi_def_cfa_offset 416
	.cfi_offset 19, -112
	.cfi_offset 20, -104
	.cfi_offset 21, -96
	.cfi_offset 22, -88
	.cfi_offset 23, -80
	.cfi_offset 24, -72
	.cfi_offset 25, -64
	.cfi_offset 26, -56
	.cfi_offset 27, -48
	.cfi_offset 28, -40
	.cfi_offset 29, -128
	.cfi_offset 30, -120
	.cfi_offset 76, -32
	.cfi_offset 77, -24
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	add	x1, sp, 224
	add	x0, sp, 168
	stp	x0, x1, [sp, 16]
	add	x1, sp, 92
.LEHB135:
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0
	ldr	x0, [sp, 48]
	mov	x19, x0
	cmp	x21, x0
	beq	.L1564
	movi	v15.2s, #0
	add	x22, sp, 224
	mov	x24, 16807
	mov	x28, 2147483647
	.p2align 5,,15
.L1563:
	ldr	x0, [sp, 16]
	mov	x1, x19
	str	x22, [sp, 24]
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0
	ldr	x0, [x26, 432]
	fmov	s30, 1.0e+0
	mul	x0, x0, x24
	udiv	x2, x0, x28
	lsl	x1, x2, 31
	sub	x1, x1, x2
	sub	x0, x0, x1
	str	x0, [x26, 432]
	sub	x0, x0, #1
	ucvtf	s31, x0
	fadd	s31, s31, s15
	fmul	s31, s31, s13
	fcmpe	s31, s30
	bge	.L1626
	fadd	s31, s31, s15
.L1556:
	fcmpe	s14, s31
	bmi	.L1557
	mov	x1, x19
	mov	x0, x22
	str	x22, [sp, 24]
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0
	ldr	w1, [x19]
	add	x8, sp, 128
	ldr	w2, [sp, 8]
	mov	x0, x26
	bl	_ZN7hnswlib15HierarchicalNSWIfE22getConnectionsWithLockEji
.LEHE135:
	ldp	x23, x20, [sp, 128]
	mov	x27, x23
	cmp	x20, x23
	beq	.L1562
	.p2align 5,,15
.L1561:
	ldr	x0, [sp, 16]
	mov	x1, x27
.LEHB136:
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE15_M_emplace_uniqIJRKjEEESt4pairINS1_14_Node_iteratorIjLb1ELb0EEEbEDpOT_.isra.0
.LEHE136:
	add	x27, x27, 4
	cmp	x20, x27
	bne	.L1561
.L1562:
	cbz	x23, .L1557
	mov	x0, x23
	bl	_ZdlPv
	.p2align 5,,15
.L1557:
	add	x19, x19, 4
	cmp	x21, x19
	bne	.L1563
.L1564:
	ldr	x20, [sp, 240]
	add	x22, sp, 128
	cbz	x20, .L1555
	.p2align 5,,15
.L1554:
	ldr	x4, [sp, 192]
	cbz	x4, .L1567
	ldr	w2, [x20, 8]
	ldr	x7, [sp, 176]
	uxtw	x0, w2
	udiv	x9, x0, x7
	msub	x9, x9, x7, x0
	ldr	x0, [sp, 168]
	ldr	x1, [x0, w9, uxtw 3]
	cbz	x1, .L1568
	ldr	x3, [x1]
	ldr	w5, [x3, 8]
	cmp	w2, w5
	beq	.L1571
.L1700:
	ldr	x0, [x3]
	cbz	x0, .L1568
	ldr	w5, [x0, 8]
	mov	x1, x3
	uxtw	x8, w5
	udiv	x3, x8, x7
	msub	x3, x3, x7, x8
	cmp	x9, x3
	bne	.L1568
	mov	x3, x0
	cmp	w2, w5
	bne	.L1700
	.p2align 5,,15
.L1571:
	ldr	x0, [x1]
	cmp	x0, 0
	cset	x0, ne
	sub	x4, x4, x0
.L1568:
	ldr	x27, [sp, 184]
	cbz	x27, .L1629
.L1623:
	ldr	x21, [x26, 72]
	mov	x23, 0
	mov	x28, 0
	mov	x19, 0
	cmp	x21, x4
	csel	x21, x21, x4, ls
	b	.L1594
	.p2align 2,,3
.L1576:
	ldr	s31, [x19]
	fcmpe	s31, s0
	bgt	.L1640
.L1575:
	ldr	x27, [x27]
	cbz	x27, .L1570
.L1701:
	ldr	w2, [x20, 8]
.L1594:
	ldr	w1, [x27, 8]
	cmp	w1, w2
	beq	.L1575
	ldr	x7, [x26, 24]
	uxtw	x2, w2
	ldr	x0, [x26, 232]
	uxtw	x1, w1
	ldr	x5, [x26, 256]
	add	x24, x27, 8
	madd	x1, x1, x7, x0
	madd	x0, x2, x7, x0
	adrp	x2, :got:__stack_chk_guard
	ldr	x2, [x2, :got_lo12:__stack_chk_guard]
	str	x2, [sp, 8]
	add	x1, x5, x1
	add	x0, x5, x0
	ldp	x7, x2, [x26, 304]
.LEHB137:
	blr	x7
.LEHE137:
	sub	x0, x28, x19
	str	s0, [sp, 100]
	cmp	x21, x0, asr 3
	bls	.L1576
	cmp	x28, x23
	beq	.L1577
	ldr	w7, [x27, 8]
	add	x28, x28, 8
	str	s0, [x28, -8]
	str	w7, [x28, -4]
	sub	x2, x28, x19
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	ble	.L1590
.L1708:
	sub	x1, x1, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L1582:
	lsl	x2, x1, 3
	add	x5, x19, x1, lsl 3
	ldr	s31, [x19, x2]
	lsl	x2, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s0, s31
	bgt	.L1639
	str	w7, [x0, 4]
	str	s0, [x0]
.L1705:
	ldr	x27, [x27]
	cbnz	x27, .L1701
.L1570:
	ldp	x2, x0, [x26, 56]
	cmp	x25, 0
	mov	x1, x22
	stp	x19, x28, [sp, 128]
	str	x23, [sp, 144]
	csel	x2, x2, x0, ne
	mov	x0, x26
.LEHB138:
	bl	_ZN7hnswlib15HierarchicalNSWIfE24getNeighborsByHeuristic2ERSt14priority_queueISt4pairIfjESt6vectorIS4_SaIS4_EENS1_14CompareByFirstEEm
.LEHE138:
	ldr	w0, [x20, 8]
	mov	w1, 48
	ldr	x28, [x26, 192]
	ldr	x24, [sp, 144]
	umull	x0, w0, w1
	ldp	x19, x2, [sp, 128]
	adds	x28, x28, x0
	beq	.L1702
	mov	x0, x28
	str	x2, [sp, 8]
	bl	pthread_mutex_lock
	ldr	x2, [sp, 8]
	cbnz	w0, .L1703
	ldr	w0, [x20, 8]
	cbnz	x25, .L1602
	ldr	x3, [x26, 24]
	uxtw	x0, w0
	ldr	x1, [x26, 240]
	mov	x27, 0
	ldr	x21, [x26, 256]
	madd	x0, x0, x3, x1
	add	x21, x21, x0
	sub	x0, x2, x19
	asr	x23, x0, 3
	strh	w23, [x21]
	cbz	x0, .L1704
	.p2align 5,,15
.L1607:
	add	x27, x27, 1
	ldr	w0, [x19, 4]
	str	x24, [sp, 144]
	str	w0, [x21, x27, lsl 2]
	mov	x0, x22
	stp	x19, x2, [sp, 128]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x2, [sp, 136]
	cmp	x23, x27
	bhi	.L1607
	mov	x0, x28
	bl	pthread_mutex_unlock
.L1605:
	mov	x0, x19
	bl	_ZdlPv
.L1606:
	ldr	x20, [x20]
	cbnz	x20, .L1554
.L1555:
	ldr	x0, [sp, 48]
	cbz	x0, .L1566
	ldr	x0, [sp, 48]
	bl	_ZdlPv
.L1566:
	ldr	x19, [sp, 240]
	cbz	x19, .L1611
	.p2align 5,,15
.L1608:
	mov	x0, x19
	ldr	x19, [x19]
	bl	_ZdlPv
	cbnz	x19, .L1608
.L1611:
	ldr	x1, [sp, 40]
	ldr	x0, [sp, 224]
	cmp	x0, x1
	beq	.L1609
	bl	_ZdlPv
.L1609:
	ldr	x19, [sp, 184]
	cbz	x19, .L1614
	.p2align 5,,15
.L1612:
	mov	x0, x19
	ldr	x19, [x19]
	bl	_ZdlPv
	cbnz	x19, .L1612
	b	.L1614
	.p2align 2,,3
.L1639:
	str	s31, [x19, x2]
	ldr	w2, [x5, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L1696
	asr	x1, x2, 1
	b	.L1582
	.p2align 2,,3
.L1696:
	mov	x0, x5
	str	s0, [x0]
	str	w7, [x0, 4]
	b	.L1705
	.p2align 2,,3
.L1640:
	mov	x0, x22
	str	s0, [sp, 8]
	stp	x19, x28, [sp, 128]
	str	x23, [sp, 144]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x4, [sp, 136]
	cmp	x23, x4
	beq	.L1585
	ldr	s0, [sp, 8]
	add	x28, x4, 8
	ldr	w7, [x27, 8]
	str	w7, [x4, 4]
	str	s0, [x4]
.L1586:
	sub	x2, x28, x19
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	ble	.L1590
	sub	x1, x1, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L1593:
	lsl	x2, x1, 3
	add	x5, x19, x1, lsl 3
	ldr	s31, [x19, x2]
	lsl	x2, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s0, s31
	bgt	.L1641
	str	s0, [x0]
	str	w7, [x0, 4]
	b	.L1705
	.p2align 2,,3
.L1641:
	str	s31, [x19, x2]
	ldr	w2, [x5, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L1696
	asr	x1, x2, 1
	b	.L1593
	.p2align 2,,3
.L1602:
	ldr	x3, [x26, 264]
	sub	x21, x25, #1
	ldr	x1, [x26, 32]
	mov	x27, 0
	ldr	x0, [x3, w0, uxtw 3]
	madd	x21, x21, x1, x0
	sub	x0, x2, x19
	asr	x23, x0, 3
	strh	w23, [x21]
	cbnz	x0, .L1607
.L1704:
	mov	x0, x28
	bl	pthread_mutex_unlock
	cbz	x19, .L1606
	b	.L1605
	.p2align 2,,3
.L1567:
	ldr	x19, [sp, 184]
	cbz	x19, .L1627
	ldr	w2, [x20, 8]
	add	x1, sp, 184
	b	.L1572
	.p2align 2,,3
.L1707:
	ldr	x0, [x19]
	mov	x1, x19
	cbz	x0, .L1706
	mov	x19, x0
.L1572:
	ldr	w0, [x19, 8]
	cmp	w2, w0
	bne	.L1707
	b	.L1571
	.p2align 2,,3
.L1577:
	mov	x2, x24
	add	x1, sp, 100
	mov	x0, x22
	stp	x19, x28, [sp, 128]
	str	x28, [sp, 144]
.LEHB139:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_
.LEHE139:
	ldp	x19, x28, [sp, 128]
	ldr	x23, [sp, 144]
	sub	x2, x28, x19
	ldr	s0, [x28, -8]
	ldr	w7, [x28, -4]
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	bgt	.L1708
.L1590:
	sub	x2, x2, #8
	add	x0, x19, x2
	str	s0, [x0]
	str	w7, [x0, 4]
	b	.L1705
	.p2align 2,,3
.L1585:
	mov	x2, x24
	add	x1, sp, 100
	mov	x0, x22
	str	x19, [sp, 128]
	str	x23, [sp, 144]
.LEHB140:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRKjEEEvDpOT_
.LEHE140:
	ldp	x19, x28, [sp, 128]
	ldr	x23, [sp, 144]
	ldr	s0, [x28, -8]
	ldr	w7, [x28, -4]
	b	.L1586
	.p2align 2,,3
.L1706:
	ldr	x27, [sp, 184]
	b	.L1623
.L1626:
	fmov	s31, s12
	b	.L1556
.L1629:
	mov	x23, 0
	mov	x28, 0
	mov	x19, 0
	b	.L1570
.L1627:
	mov	x23, 0
	mov	x28, 0
	b	.L1570
.L1698:
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 76
	.cfi_restore 77
	add	x0, x26, 16
	ldar	x0, [x0]
	cmp	x0, 1
	beq	.L1537
	ldr	w0, [sp, 92]
	str	w0, [sp, 60]
	mov	x19, x0
	b	.L1538
.L1699:
	stp	x21, x22, [sp, 320]
	.cfi_offset 22, -88
	.cfi_offset 21, -96
	stp	x23, x24, [sp, 336]
	.cfi_offset 24, -72
	.cfi_offset 23, -80
	stp	x27, x28, [sp, 368]
	.cfi_offset 28, -40
	.cfi_offset 27, -48
	stp	d12, d13, [sp, 384]
	.cfi_offset 77, -24
	.cfi_offset 76, -32
.L1695:
	bl	__stack_chk_fail
.L1638:
	mov	x20, x0
	cbz	x19, .L1619
.L1709:
	mov	x0, x19
	bl	_ZdlPv
.L1619:
	add	x0, sp, 224
	str	x0, [sp, 24]
.L1617:
	ldr	x0, [sp, 48]
	cbz	x0, .L1621
	bl	_ZdlPv
.L1621:
	ldr	x0, [sp, 24]
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED1Ev
	ldr	x0, [sp, 16]
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED1Ev
	ldr	x2, [sp, 8]
	ldr	x0, [sp, 280]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1695
	mov	x0, x20
.LEHB141:
	bl	_Unwind_Resume
.LEHE141:
.L1634:
	mov	x20, x0
	cbz	x23, .L1693
	mov	x0, x23
	bl	_ZdlPv
.L1693:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	b	.L1617
.L1637:
.L1692:
	ldr	x19, [sp, 128]
	mov	x20, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	cbnz	x19, .L1709
	b	.L1619
.L1636:
	b	.L1692
.L1632:
	mov	x20, x0
	add	x0, sp, 168
	str	x0, [sp, 16]
	add	x0, sp, 224
	str	x0, [sp, 24]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	b	.L1621
.L1702:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x0, [sp, 8]
	mov	x2, x0
	ldr	x0, [sp, 280]
	ldr	x1, [x2]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1695
	mov	w0, 1
.LEHB142:
	bl	_ZSt20__throw_system_errori
.L1703:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	str	x1, [sp, 8]
	mov	x3, x1
	ldr	x1, [sp, 280]
	ldr	x2, [x3]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1695
	bl	_ZSt20__throw_system_errori
.LEHE142:
.L1635:
	b	.L1692
.L1633:
	mov	x20, x0
	b	.L1693
	.cfi_endproc
.LFE11103:
	.section	.gcc_except_table
.LLSDA11103:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE11103-.LLSDACSB11103
.LLSDACSB11103:
	.uleb128 .LEHB133-.LFB11103
	.uleb128 .LEHE133-.LEHB133
	.uleb128 .L1632-.LFB11103
	.uleb128 0
	.uleb128 .LEHB134-.LFB11103
	.uleb128 .LEHE134-.LEHB134
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB135-.LFB11103
	.uleb128 .LEHE135-.LEHB135
	.uleb128 .L1633-.LFB11103
	.uleb128 0
	.uleb128 .LEHB136-.LFB11103
	.uleb128 .LEHE136-.LEHB136
	.uleb128 .L1634-.LFB11103
	.uleb128 0
	.uleb128 .LEHB137-.LFB11103
	.uleb128 .LEHE137-.LEHB137
	.uleb128 .L1638-.LFB11103
	.uleb128 0
	.uleb128 .LEHB138-.LFB11103
	.uleb128 .LEHE138-.LEHB138
	.uleb128 .L1637-.LFB11103
	.uleb128 0
	.uleb128 .LEHB139-.LFB11103
	.uleb128 .LEHE139-.LEHB139
	.uleb128 .L1635-.LFB11103
	.uleb128 0
	.uleb128 .LEHB140-.LFB11103
	.uleb128 .LEHE140-.LEHB140
	.uleb128 .L1636-.LFB11103
	.uleb128 0
	.uleb128 .LEHB141-.LFB11103
	.uleb128 .LEHE141-.LEHB141
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB142-.LFB11103
	.uleb128 .LEHE142-.LEHB142
	.uleb128 .L1638-.LFB11103
	.uleb128 0
.LLSDACSE11103:
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf,comdat
	.size	_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf, .-_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf
	.section	.rodata.str1.8
	.align	3
.LC36:
	.string	"Can't use addPoint to update deleted elements if replacement of deleted elements is enabled."
	.align	3
.LC37:
	.string	"The requested to undelete element is not deleted"
	.align	3
.LC38:
	.string	"The number of elements exceeds the specified limit"
	.align	3
.LC39:
	.string	"Not enough memory: addPoint failed to allocate linklist"
	.align	3
.LC40:
	.string	"cand error"
	.align	3
.LC41:
	.string	"Level error"
	.text
	.align	2
	.p2align 5,,15
	.type	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0, %function
_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0:
.LFB12869:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12869
	sub	sp, sp, #240
	.cfi_def_cfa_offset 240
	stp	x29, x30, [sp, 128]
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	add	x29, sp, 128
	stp	x27, x28, [sp, 208]
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	mov	x27, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	w3, [sp, 8]
	stp	x19, x20, [sp, 144]
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	add	x19, x27, 320
	stp	x21, x22, [sp, 160]
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	mov	x21, x1
	mov	x22, x2
	stp	x25, x26, [sp, 192]
	ldr	x1, [x0]
	str	x1, [sp, 120]
	mov	x1, 0
	mov	x0, x19
	str	x19, [sp, 80]
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	bl	pthread_mutex_lock
	cbnz	w0, .L1897
	stp	x23, x24, [sp, 176]
	.cfi_offset 24, -56
	.cfi_offset 23, -64
	add	x23, x27, 368
	mov	w0, 1
	strb	w0, [sp, 88]
	ldr	x0, [x23, 24]
	cbnz	x0, .L1713
	ldr	x0, [x27, 384]
	cbz	x0, .L1714
	add	x2, x27, 384
	b	.L1716
	.p2align 2,,3
.L1898:
	ldr	x1, [x0]
	mov	x2, x0
	cbz	x1, .L1714
	mov	x0, x1
.L1716:
	ldr	x1, [x0, 8]
	cmp	x1, x22
	bne	.L1898
.L1715:
	ldr	x0, [x2]
	cbz	x0, .L1714
	ldr	w22, [x0, 16]
	ldrb	w0, [x27, 456]
	uxtw	x20, w22
	tbz	x0, 0, .L1718
	ldr	x0, [x27, 24]
	ldr	x2, [x27, 256]
	ldr	x1, [x27, 240]
	madd	x0, x20, x0, x2
	add	x0, x0, x1
	ldrb	w0, [x0, 2]
	tbnz	x0, 0, .L1899
.L1718:
	mov	x0, x19
	bl	pthread_mutex_unlock
	ldr	x0, [x27, 24]
	strb	wzr, [sp, 88]
	ldr	x2, [x27, 256]
	ldr	x1, [x27, 240]
	madd	x0, x20, x0, x2
	add	x0, x0, x1
	ldrb	w0, [x0, 2]
	tbz	x0, 0, .L1720
	str	w22, [sp, 64]
	add	x0, x27, 16
	ldar	x0, [x0]
	cmp	x0, x20
	bls	.L1900
	ldr	x2, [x27, 24]
	ldr	x0, [x27, 240]
	ldr	w1, [sp, 64]
	madd	x1, x1, x2, x0
	ldr	x0, [x27, 256]
	add	x0, x0, x1
	ldrb	w1, [x0, 2]
	tbz	x1, 0, .L1722
	and	w1, w1, -2
	strb	w1, [x0, 2]
	add	x1, x27, 40
	mov	x0, -1
	bl	__aarch64_ldadd8_acq_rel
	ldrb	w0, [x27, 456]
	tbnz	x0, 0, .L1901
.L1723:
	fmov	s0, 1.0e+0
	ldrb	w19, [sp, 88]
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	mov	w2, w22
	mov	x1, x21
	mov	x0, x27
.LEHB143:
	bl	_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf
.LEHE143:
	tbz	x19, 0, .L1710
	ldr	x0, [sp, 80]
	cbz	x0, .L1710
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 120]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	bne	.L1894
	ldp	x23, x24, [sp, 176]
	.cfi_remember_state
	.cfi_restore 24
	.cfi_restore 23
	ldp	x29, x30, [sp, 128]
	ldp	x19, x20, [sp, 144]
	ldp	x21, x22, [sp, 160]
	ldp	x25, x26, [sp, 192]
	ldp	x27, x28, [sp, 208]
	add	sp, sp, 240
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
.LEHB144:
	b	pthread_mutex_unlock
.LEHE144:
	.p2align 2,,3
.L1713:
	.cfi_restore_state
	ldr	x4, [x23, 8]
	ldr	x0, [x27, 368]
	udiv	x6, x22, x4
	msub	x6, x6, x4, x22
	ldr	x2, [x0, x6, lsl 3]
	cbz	x2, .L1714
	ldr	x3, [x2]
	ldr	x0, [x3, 8]
	cmp	x0, x22
	beq	.L1715
	ldr	x1, [x3]
	cbz	x1, .L1714
.L1902:
	ldr	x0, [x1, 8]
	mov	x2, x3
	udiv	x3, x0, x4
	msub	x3, x3, x4, x0
	cmp	x6, x3
	bne	.L1714
	mov	x3, x1
	cmp	x0, x22
	beq	.L1715
	ldr	x1, [x3]
	cbnz	x1, .L1902
	.p2align 5,,15
.L1714:
	add	x1, x27, 16
	ldar	x2, [x1]
	ldr	x0, [x27, 8]
	cmp	x2, x0
	bcs	.L1903
	ldar	x19, [x1]
	mov	x0, 1
	str	w19, [sp, 16]
	bl	__aarch64_ldadd8_acq_rel
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	mov	x1, x22
	mov	x0, x23
.LEHB145:
	bl	_ZNSt8__detail9_Map_baseImSt4pairIKmjESaIS3_ENS_10_Select1stESt8equal_toImESt4hashImENS_18_Mod_range_hashingENS_20_Default_ranged_hashENS_20_Prime_rehash_policyENS_17_Hashtable_traitsILb0ELb0ELb1EEELb1EEixERS2_.isra.0
.LEHE145:
	str	w19, [x0]
	ldrb	w0, [sp, 88]
	tbnz	x0, 0, .L1904
.L1735:
	ldr	x0, [x27, 192]
	mov	w1, 48
	and	x20, x19, 4294967295
	umaddl	x0, w19, w1, x0
	str	x0, [sp, 32]
	str	x0, [sp, 48]
	cbz	x0, .L1905
	ldr	x0, [sp, 32]
	bl	pthread_mutex_lock
	cbnz	w0, .L1906
	mov	w0, 1
	strb	w0, [sp, 56]
	ldr	x0, [x27, 424]
	mov	x3, 16807
	mov	x2, 2147483647
	movi	d29, #0
	str	d15, [sp, 224]
	.cfi_offset 79, -16
	mul	x0, x0, x3
	ldr	d15, [x27, 88]
	udiv	x4, x0, x2
	lsl	x1, x4, 31
	sub	x1, x1, x4
	sub	x0, x0, x1
	sub	x1, x0, #1
	umull	x0, w0, w3
	ucvtf	d31, x1
	udiv	x1, x0, x2
	fadd	d30, d31, d29
	lsl	x2, x1, 31
	sub	x1, x2, x1
	sub	x0, x0, x1
	str	x0, [x27, 424]
	sub	x0, x0, #1
	ucvtf	d31, x0
	mov	x0, 281474968322048
	movk	x0, 0x41df, lsl 48
	fmov	d28, x0
	mov	x0, 281474959933440
	movk	x0, 0x43cf, lsl 48
	fmadd	d31, d31, d28, d30
	fmov	d30, x0
	fdiv	d31, d31, d30
	fmov	d30, 1.0e+0
	fcmpe	d31, d30
	bge	.L1805
	fadd	d0, d31, d29
.L1740:
	bl	log
	ldr	w2, [sp, 8]
	ubfiz	x0, x19, 2, 32
	ldr	x1, [x27, 272]
	cmp	w2, 0
	bgt	.L1888
	fnmul	d0, d0, d15
	fcvtzs	w2, d0
	str	w2, [sp, 8]
.L1888:
	str	w2, [x1, x0]
	add	x0, x27, 144
	str	x0, [sp, 40]
	str	x0, [sp, 64]
	ldr	x0, [sp, 40]
	bl	pthread_mutex_lock
	cbnz	w0, .L1907
	mov	w0, 1
	ldr	w1, [sp, 8]
	strb	w0, [sp, 72]
	ldr	w0, [x27, 104]
	str	w0, [sp, 12]
	cmp	w0, w1
	blt	.L1745
	ldr	x0, [sp, 40]
	bl	pthread_mutex_unlock
	strb	wzr, [sp, 72]
.L1745:
	ldr	w0, [x27, 216]
	mov	w1, 0
	ldr	x2, [x27, 24]
	str	w0, [sp, 20]
	ldr	x0, [x27, 240]
	ldr	x3, [x27, 256]
	madd	x0, x20, x2, x0
	add	x0, x3, x0
	bl	memset
	ldp	x1, x2, [x27, 248]
	ldr	x0, [x27, 24]
	madd	x0, x20, x0, x2
	str	x22, [x0, x1]
	ldr	x1, [x27, 24]
	ldr	x0, [x27, 232]
	ldr	x2, [x27, 296]
	madd	x20, x20, x1, x0
	mov	x1, x21
	ldr	x0, [x27, 256]
	add	x0, x0, x20
	bl	memcpy
	ldr	w0, [sp, 8]
	cbnz	w0, .L1908
.L1746:
	ldr	w22, [sp, 20]
	cmn	w22, #1
	beq	.L1749
	ldp	w0, w19, [sp, 8]
	uxtw	x2, w22
	str	x2, [sp, 24]
	cmp	w19, w0
	ble	.L1806
	ldr	x0, [x27, 24]
	ldr	x1, [x27, 232]
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	madd	x0, x2, x0, x1
	ldp	x3, x2, [x27, 304]
	ldr	x1, [x27, 256]
	add	x1, x1, x0
	mov	x0, x21
.LEHB146:
	blr	x3
.LEHE146:
	fmov	s15, s0
	sxtw	x0, w19
	str	x0, [sp]
	.p2align 5,,15
.L1763:
	ldr	x23, [x27, 192]
	mov	w0, 48
	umaddl	x23, w22, w0, x23
	str	x23, [sp, 80]
	cbz	x23, .L1909
	mov	x0, x23
	bl	pthread_mutex_lock
	cbnz	w0, .L1910
	mov	w0, 1
	strb	w0, [sp, 88]
	ldr	x0, [sp]
	ldr	x1, [x27, 264]
	sub	x25, x0, #1
	ldr	x0, [x27, 32]
	ldr	x2, [x1, w22, uxtw 3]
	mul	x0, x25, x0
	add	x1, x2, x0
	ldrh	w19, [x2, x0]
	cbz	w19, .L1756
	sub	w19, w19, #1
	add	x28, x1, 4
	add	x1, x1, 8
	mov	w24, 0
	add	x19, x1, w19, uxtw 2
	.p2align 5,,15
.L1760:
	ldr	x0, [x27, 8]
	ldr	w26, [x28]
	uxtw	x1, w26
	cmp	x1, x0
	bhi	.L1911
	ldr	x2, [x27, 24]
	ldr	x0, [x27, 232]
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	madd	x1, x1, x2, x0
	ldp	x6, x2, [x27, 304]
	ldr	x0, [x27, 256]
	add	x1, x0, x1
	mov	x0, x21
.LEHB147:
	blr	x6
.LEHE147:
	fcmpe	s0, s15
	bmi	.L1807
.L1759:
	add	x28, x28, 4
	cmp	x28, x19
	bne	.L1760
	mov	x0, x23
	bl	pthread_mutex_unlock
	cbnz	w24, .L1763
	.p2align 5,,15
.L1762:
	ldr	w0, [sp]
	sub	w26, w0, #1
	ldr	w0, [sp, 8]
	cmp	w26, w0
	ble	.L1750
	str	x25, [sp]
	b	.L1763
	.p2align 2,,3
.L1720:
	.cfi_restore 79
	fmov	s0, 1.0e+0
	mov	w2, w22
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	mov	x1, x21
	mov	x0, x27
.LEHB148:
	bl	_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf
.LEHE148:
.L1710:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 120]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1894
	ldp	x23, x24, [sp, 176]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x29, x30, [sp, 128]
	ldp	x19, x20, [sp, 144]
	ldp	x21, x22, [sp, 160]
	ldp	x25, x26, [sp, 192]
	ldp	x27, x28, [sp, 208]
	add	sp, sp, 240
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L1807:
	.cfi_def_cfa_offset 240
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	.cfi_offset 79, -16
	fmov	s15, s0
	mov	w22, w26
	mov	w24, 1
	b	.L1759
	.p2align 2,,3
.L1756:
	mov	x0, x23
	bl	pthread_mutex_unlock
	b	.L1762
.L1901:
	.cfi_restore 79
	add	x0, x27, 464
	bl	pthread_mutex_lock
	cbnz	w0, .L1912
	add	x1, sp, 64
	add	x0, x27, 512
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE5eraseERKj.isra.0
	add	x0, x27, 464
	bl	pthread_mutex_unlock
	b	.L1723
.L1806:
	.cfi_offset 79, -16
	ldr	w22, [sp, 20]
.L1750:
	ldp	w1, w0, [sp, 8]
	cmp	w0, w1
	csel	w25, w0, w1, le
	tbnz	w25, #31, .L1765
	ldr	x0, [x27, 24]
	add	x19, sp, 80
	ldr	x3, [sp, 24]
	mov	x24, 1152921504606846975
	ldr	x2, [x27, 256]
	ldr	x1, [x27, 240]
	madd	x0, x3, x0, x2
	add	x0, x0, x1
	ldrb	w23, [x0, 2]
	and	w23, w23, 1
	.p2align 5,,15
.L1781:
	ldr	w0, [sp, 12]
	cmp	w0, w25
	blt	.L1913
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	mov	x8, x19
	mov	w3, w25
	mov	x2, x21
	mov	w1, w22
	mov	x0, x27
.LEHB149:
	bl	_ZN7hnswlib15HierarchicalNSWIfE15searchBaseLayerEjPKvi
.LEHE149:
	ldr	x28, [sp, 96]
	ldp	x22, x26, [sp, 80]
	cbz	w23, .L1768
	ldr	x2, [sp, 24]
	ldr	x0, [x27, 24]
	ldr	x1, [x27, 232]
	madd	x0, x2, x0, x1
	ldp	x3, x2, [x27, 304]
	ldr	x1, [x27, 256]
	add	x1, x1, x0
	mov	x0, x21
.LEHB150:
	blr	x3
.LEHE150:
	fmov	s15, s0
	cmp	x28, x26
	beq	.L1769
	ldr	w0, [sp, 20]
	add	x26, x26, 8
	str	w0, [x26, -4]
	mov	w6, w0
	str	s0, [x26, -8]
.L1770:
	sub	x1, x26, x22
	asr	x4, x1, 3
	sub	x0, x4, #1
	cmp	x0, 0
	ble	.L1776
	sub	x1, x4, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L1779:
	lsl	x2, x1, 3
	add	x3, x22, x1, lsl 3
	ldr	s31, [x22, x2]
	lsl	x2, x0, 3
	add	x0, x22, x0, lsl 3
	fcmpe	s15, s31
	bgt	.L1823
.L1777:
	str	w6, [x0, 4]
	str	s15, [x0]
.L1802:
	ldr	x0, [x27, 72]
	cmp	x4, x0
	bhi	.L1914
.L1768:
	ldr	w1, [sp, 16]
	mov	w3, w25
	mov	x2, x19
	mov	x0, x27
	mov	w4, 0
	stp	x22, x26, [sp, 80]
	str	x28, [sp, 96]
.LEHB151:
	bl	_ZN7hnswlib15HierarchicalNSWIfE25mutuallyConnectNewElementEPKvjRSt14priority_queueISt4pairIfjESt6vectorIS6_SaIS6_EENS1_14CompareByFirstEEib.isra.0
.LEHE151:
	mov	w22, w0
	ldr	x0, [sp, 80]
	cbz	x0, .L1780
	bl	_ZdlPv
.L1780:
	sub	w25, w25, #1
	cmn	w25, #1
	bne	.L1781
.L1765:
	ldp	w0, w1, [sp, 8]
	cmp	w1, w0
	bge	.L1783
	ldr	w1, [sp, 16]
	str	w0, [x27, 104]
	str	w1, [x27, 216]
.L1783:
	ldrb	w0, [sp, 72]
	tbnz	x0, 0, .L1915
.L1784:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 120]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L1892
	ldp	x23, x24, [sp, 176]
	.cfi_remember_state
	.cfi_restore 24
	.cfi_restore 23
	ldp	x29, x30, [sp, 128]
	ldp	x19, x20, [sp, 144]
	ldp	x21, x22, [sp, 160]
	ldp	x25, x26, [sp, 192]
	ldp	x27, x28, [sp, 208]
	ldr	x0, [sp, 32]
	ldr	d15, [sp, 224]
	.cfi_restore 79
	add	sp, sp, 240
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
.LEHB152:
	b	pthread_mutex_unlock
.LEHE152:
	.p2align 2,,3
.L1823:
	.cfi_restore_state
	str	s31, [x22, x2]
	ldr	w2, [x3, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L1916
	asr	x1, x2, 1
	b	.L1779
.L1916:
	mov	x0, x3
	b	.L1777
.L1914:
	mov	x0, x19
	stp	x22, x26, [sp, 80]
	str	x28, [sp, 96]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x26, [sp, 88]
	b	.L1768
.L1769:
	sub	x2, x28, x22
	asr	x1, x2, 3
	cmp	x1, x24
	beq	.L1917
	cmp	x1, 0
	str	x2, [sp]
	csinc	x0, x1, xzr, ne
	add	x0, x0, x1
	cmp	x0, x24
	csel	x0, x0, x24, ls
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	lsl	x28, x0, 3
	mov	x0, x28
.LEHB153:
	bl	_Znwm
.LEHE153:
	ldr	x2, [sp]
	mov	x20, x0
	ldr	w1, [sp, 20]
	add	x0, x0, x2
	str	s15, [x20, x2]
	str	w1, [x0, 4]
	mov	x1, x20
	cmp	x22, x26
	beq	.L1773
	mov	x0, x22
	.p2align 5,,15
.L1774:
	ldr	x2, [x0], 8
	str	x2, [x1], 8
	cmp	x26, x0
	bne	.L1774
	sub	x1, x26, x22
	add	x1, x20, x1
.L1773:
	add	x26, x1, 8
	cbz	x22, .L1775
	mov	x0, x22
	str	x1, [sp]
	bl	_ZdlPv
	ldr	x1, [sp]
.L1775:
	add	x28, x20, x28
	ldr	s15, [x1]
	mov	x22, x20
	ldr	w6, [x1, 4]
	b	.L1770
.L1915:
	ldr	x0, [sp, 40]
	bl	pthread_mutex_unlock
	b	.L1784
.L1749:
	ldr	w0, [sp, 8]
	str	w0, [x27, 104]
	str	wzr, [x27, 216]
	b	.L1765
.L1908:
	ldr	x0, [x27, 32]
	ubfiz	x19, x19, 3, 32
	ldrsw	x20, [sp, 8]
	ldr	x22, [x27, 264]
	mul	x20, x20, x0
	add	x0, x20, 1
	bl	malloc
	str	x0, [x22, x19]
	cbz	x0, .L1918
	add	x3, x20, 1
	mov	w1, 0
	mov	x2, x3
	bl	__memset_chk
	b	.L1746
.L1904:
	.cfi_restore 79
	ldr	x0, [sp, 80]
	cbz	x0, .L1735
	bl	pthread_mutex_unlock
	b	.L1735
.L1776:
	.cfi_offset 79, -16
	sub	x1, x1, #8
	add	x0, x22, x1
	str	s15, [x22, x1]
	str	w6, [x0, 4]
	b	.L1802
.L1805:
	mov	x0, 4607182418800017407
	fmov	d0, x0
	b	.L1740
.L1899:
	.cfi_restore 79
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC36
	mov	x21, x0
	add	x1, x1, :lo12:.LC36
.LEHB154:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE154:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	beq	.L1719
.L1894:
	str	d15, [sp, 224]
	.cfi_offset 79, -16
.L1892:
	bl	__stack_chk_fail
.L1913:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC41
	mov	x21, x0
	add	x1, x1, :lo12:.LC41
.LEHB155:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE155:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1892
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB156:
	bl	__cxa_throw
.LEHE156:
.L1912:
	.cfi_restore 79
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x1, [sp, 120]
	ldr	x2, [x20]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1894
.LEHB157:
	bl	_ZSt20__throw_system_errori
.LEHE157:
.L1918:
	.cfi_offset 79, -16
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC39
	mov	x21, x0
	add	x1, x1, :lo12:.LC39
.LEHB158:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE158:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1892
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB159:
	bl	__cxa_throw
.LEHE159:
.L1917:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1892
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB160:
	bl	_ZSt20__throw_length_errorPKc
.LEHE160:
.L1812:
.L1890:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	mov	x19, x0
	mov	x0, x21
	bl	__cxa_free_exception
.L1792:
	ldrb	w0, [sp, 72]
	tbz	x0, 0, .L1800
	add	x0, sp, 64
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
.L1800:
	add	x0, sp, 48
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1892
.L1801:
	mov	x0, x19
.LEHB161:
	bl	_Unwind_Resume
.LEHE161:
.L1815:
	b	.L1890
.L1820:
	ldr	x22, [sp, 80]
	mov	x19, x0
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	cbz	x22, .L1792
.L1919:
	mov	x0, x22
	bl	_ZdlPv
	b	.L1792
.L1816:
	.cfi_restore 79
	mov	x19, x0
.L1729:
	ldrb	w0, [sp, 88]
	tbz	x0, 0, .L1789
.L1787:
	add	x0, sp, 80
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
.L1789:
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	str	d15, [sp, 224]
	.cfi_offset 79, -16
	beq	.L1801
	b	.L1892
.L1822:
	mov	x19, x0
	cbnz	x22, .L1919
	b	.L1792
.L1906:
	.cfi_restore 79
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 120]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	str	d15, [sp, 224]
	.cfi_offset 79, -16
	bne	.L1892
.LEHB162:
	bl	_ZSt20__throw_system_errori
.LEHE162:
.L1811:
	mov	x19, x0
	b	.L1792
.L1907:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x1, [sp, 120]
	ldr	x2, [x20]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1892
.LEHB163:
	bl	_ZSt20__throw_system_errori
.LEHE163:
.L1813:
	mov	x19, x0
.L1794:
	add	x0, sp, 80
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	b	.L1792
.L1910:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x1, [sp, 120]
	ldr	x2, [x20]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L1892
.LEHB164:
	bl	_ZSt20__throw_system_errori
.LEHE164:
.L1911:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC40
	mov	x21, x0
	add	x1, x1, :lo12:.LC40
.LEHB165:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE165:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1892
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB166:
	bl	__cxa_throw
.LEHE166:
.L1909:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1892
	mov	w0, 1
.LEHB167:
	bl	_ZSt20__throw_system_errori
.LEHE167:
.L1810:
	mov	x19, x0
	b	.L1800
.L1814:
	mov	x19, x0
	mov	x0, x21
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	bl	__cxa_free_exception
	b	.L1794
.L1905:
	.cfi_restore 79
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 120]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	str	d15, [sp, 224]
	.cfi_remember_state
	.cfi_offset 79, -16
	mov	w0, 1
	bne	.L1892
.LEHB168:
	bl	_ZSt20__throw_system_errori
.LEHE168:
.L1903:
	.cfi_restore_state
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC38
	mov	x21, x0
	add	x1, x1, :lo12:.LC38
.LEHB169:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE169:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1894
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB170:
	bl	__cxa_throw
.LEHE170:
.L1897:
	.cfi_restore 23
	.cfi_restore 24
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 120]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	stp	x23, x24, [sp, 176]
	.cfi_offset 24, -56
	.cfi_offset 23, -64
	str	d15, [sp, 224]
	.cfi_offset 79, -16
	bne	.L1892
.LEHB171:
	bl	_ZSt20__throw_system_errori
.LEHE171:
.L1817:
	.cfi_restore 79
.L1889:
	mov	x19, x0
	mov	x0, x21
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	bl	__cxa_free_exception
	b	.L1729
.L1719:
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB172:
	bl	__cxa_throw
.LEHE172:
.L1818:
	mov	x19, x0
	mov	x0, x21
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	bl	__cxa_free_exception
	b	.L1787
.L1821:
	mov	x19, x0
	b	.L1787
.L1900:
	str	d15, [sp, 224]
	.cfi_offset 79, -16
	bl	_ZN7hnswlib15HierarchicalNSWIfE21unmarkDeletedInternalEj.part.0
.L1722:
	.cfi_restore 79
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC37
	mov	x21, x0
	add	x1, x1, :lo12:.LC37
.LEHB173:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE173:
	adrp	x20, :got:__stack_chk_guard
	ldr	x20, [x20, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 120]
	ldr	x1, [x20]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L1894
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB174:
	bl	__cxa_throw
.LEHE174:
.L1819:
	b	.L1889
	.cfi_endproc
.LFE12869:
	.section	.gcc_except_table
.LLSDA12869:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12869-.LLSDACSB12869
.LLSDACSB12869:
	.uleb128 .LEHB143-.LFB12869
	.uleb128 .LEHE143-.LEHB143
	.uleb128 .L1816-.LFB12869
	.uleb128 0
	.uleb128 .LEHB144-.LFB12869
	.uleb128 .LEHE144-.LEHB144
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB145-.LFB12869
	.uleb128 .LEHE145-.LEHB145
	.uleb128 .L1816-.LFB12869
	.uleb128 0
	.uleb128 .LEHB146-.LFB12869
	.uleb128 .LEHE146-.LEHB146
	.uleb128 .L1811-.LFB12869
	.uleb128 0
	.uleb128 .LEHB147-.LFB12869
	.uleb128 .LEHE147-.LEHB147
	.uleb128 .L1813-.LFB12869
	.uleb128 0
	.uleb128 .LEHB148-.LFB12869
	.uleb128 .LEHE148-.LEHB148
	.uleb128 .L1816-.LFB12869
	.uleb128 0
	.uleb128 .LEHB149-.LFB12869
	.uleb128 .LEHE149-.LEHB149
	.uleb128 .L1811-.LFB12869
	.uleb128 0
	.uleb128 .LEHB150-.LFB12869
	.uleb128 .LEHE150-.LEHB150
	.uleb128 .L1822-.LFB12869
	.uleb128 0
	.uleb128 .LEHB151-.LFB12869
	.uleb128 .LEHE151-.LEHB151
	.uleb128 .L1820-.LFB12869
	.uleb128 0
	.uleb128 .LEHB152-.LFB12869
	.uleb128 .LEHE152-.LEHB152
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB153-.LFB12869
	.uleb128 .LEHE153-.LEHB153
	.uleb128 .L1822-.LFB12869
	.uleb128 0
	.uleb128 .LEHB154-.LFB12869
	.uleb128 .LEHE154-.LEHB154
	.uleb128 .L1818-.LFB12869
	.uleb128 0
	.uleb128 .LEHB155-.LFB12869
	.uleb128 .LEHE155-.LEHB155
	.uleb128 .L1812-.LFB12869
	.uleb128 0
	.uleb128 .LEHB156-.LFB12869
	.uleb128 .LEHE156-.LEHB156
	.uleb128 .L1811-.LFB12869
	.uleb128 0
	.uleb128 .LEHB157-.LFB12869
	.uleb128 .LEHE157-.LEHB157
	.uleb128 .L1816-.LFB12869
	.uleb128 0
	.uleb128 .LEHB158-.LFB12869
	.uleb128 .LEHE158-.LEHB158
	.uleb128 .L1815-.LFB12869
	.uleb128 0
	.uleb128 .LEHB159-.LFB12869
	.uleb128 .LEHE159-.LEHB159
	.uleb128 .L1811-.LFB12869
	.uleb128 0
	.uleb128 .LEHB160-.LFB12869
	.uleb128 .LEHE160-.LEHB160
	.uleb128 .L1822-.LFB12869
	.uleb128 0
	.uleb128 .LEHB161-.LFB12869
	.uleb128 .LEHE161-.LEHB161
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB162-.LFB12869
	.uleb128 .LEHE162-.LEHB162
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB163-.LFB12869
	.uleb128 .LEHE163-.LEHB163
	.uleb128 .L1810-.LFB12869
	.uleb128 0
	.uleb128 .LEHB164-.LFB12869
	.uleb128 .LEHE164-.LEHB164
	.uleb128 .L1811-.LFB12869
	.uleb128 0
	.uleb128 .LEHB165-.LFB12869
	.uleb128 .LEHE165-.LEHB165
	.uleb128 .L1814-.LFB12869
	.uleb128 0
	.uleb128 .LEHB166-.LFB12869
	.uleb128 .LEHE166-.LEHB166
	.uleb128 .L1813-.LFB12869
	.uleb128 0
	.uleb128 .LEHB167-.LFB12869
	.uleb128 .LEHE167-.LEHB167
	.uleb128 .L1811-.LFB12869
	.uleb128 0
	.uleb128 .LEHB168-.LFB12869
	.uleb128 .LEHE168-.LEHB168
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB169-.LFB12869
	.uleb128 .LEHE169-.LEHB169
	.uleb128 .L1817-.LFB12869
	.uleb128 0
	.uleb128 .LEHB170-.LFB12869
	.uleb128 .LEHE170-.LEHB170
	.uleb128 .L1816-.LFB12869
	.uleb128 0
	.uleb128 .LEHB171-.LFB12869
	.uleb128 .LEHE171-.LEHB171
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB172-.LFB12869
	.uleb128 .LEHE172-.LEHB172
	.uleb128 .L1821-.LFB12869
	.uleb128 0
	.uleb128 .LEHB173-.LFB12869
	.uleb128 .LEHE173-.LEHB173
	.uleb128 .L1819-.LFB12869
	.uleb128 0
	.uleb128 .LEHB174-.LFB12869
	.uleb128 .LEHE174-.LEHB174
	.uleb128 .L1816-.LFB12869
	.uleb128 0
.LLSDACSE12869:
	.text
	.size	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0, .-_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0
	.section	.rodata._ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb.str1.8,"aMS",@progbits,1
	.align	3
.LC42:
	.string	"Replacement of deleted elements is disabled in constructor"
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb
	.type	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb, %function
_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb:
.LFB10725:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10725
	sub	sp, sp, #176
	.cfi_def_cfa_offset 176
	stp	x29, x30, [sp, 80]
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	add	x29, sp, 80
	stp	x19, x20, [sp, 96]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	mov	x19, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	stp	x21, x22, [sp, 112]
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	mov	x22, x1
	stp	x23, x24, [sp, 128]
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	and	w23, w3, 255
	str	x27, [sp, 160]
	ldr	x1, [x0]
	str	x1, [sp, 72]
	mov	x1, 0
	ldrb	w0, [x19, 456]
	bic	x0, x23, x0
	.cfi_offset 27, -16
	tbnz	x0, 0, .L2012
	ldr	x20, [x19, 120]
	and	x0, x2, 65535
	mov	w1, 48
	mov	x21, x2
	umaddl	x20, w0, w1, x20
	str	x20, [sp, 24]
	cbz	x20, .L2013
	mov	x0, x20
	bl	pthread_mutex_lock
	cbnz	w0, .L2014
	stp	x25, x26, [sp, 144]
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	mov	w25, 1
	strb	w25, [sp, 32]
	tbz	x23, 0, .L2015
	add	x23, x19, 464
	str	x23, [sp, 40]
	mov	x0, x23
	bl	pthread_mutex_lock
	cbnz	w0, .L2016
	ldr	x0, [x19, 536]
	add	x26, x19, 512
	cbnz	x0, .L1931
	mov	x0, x23
	bl	pthread_mutex_unlock
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	mov	x2, x21
	mov	x1, x22
	mov	x0, x19
	mov	w3, -1
	strb	wzr, [sp, 48]
.LEHB175:
	bl	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0
.LEHE175:
.L1932:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 72]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2011
.L1957:
	ldp	x25, x26, [sp, 144]
	.cfi_remember_state
	.cfi_restore 26
	.cfi_restore 25
	mov	x0, x20
	ldp	x29, x30, [sp, 80]
	ldp	x19, x20, [sp, 96]
	ldp	x21, x22, [sp, 112]
	ldp	x23, x24, [sp, 128]
	ldr	x27, [sp, 160]
	add	sp, sp, 176
	.cfi_restore 27
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
.LEHB176:
	b	pthread_mutex_unlock
.LEHE176:
	.p2align 2,,3
.L1931:
	.cfi_restore_state
	ldr	x0, [x26, 16]
	add	x1, sp, 16
	add	x24, x19, 320
	ldr	w20, [x0, 8]
	mov	x0, x26
	str	w20, [sp, 16]
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE5eraseERKj.isra.0
	mov	x0, x23
	bl	pthread_mutex_unlock
	strb	wzr, [sp, 48]
	uxtw	x3, w20
	ldr	x0, [x19, 24]
	mov	x27, x3
	ldp	x2, x1, [x19, 248]
	str	x24, [sp, 56]
	madd	x0, x3, x0, x2
	ldr	x3, [x1, x0]
	str	x21, [x1, x0]
	mov	x0, x24
	str	x3, [sp, 8]
	bl	pthread_mutex_lock
	ldr	x3, [sp, 8]
	cbnz	w0, .L2017
	strb	w25, [sp, 64]
	add	x25, x19, 368
	ldr	x0, [x25, 24]
	cbz	x0, .L2018
	ldr	x6, [x25, 8]
	ldr	x0, [x19, 368]
	udiv	x1, x3, x6
	msub	x1, x1, x6, x3
	lsl	x7, x1, 3
	ldr	x2, [x0, x7]
	cbz	x2, .L1936
	ldr	x5, [x2]
	ldr	x0, [x5, 8]
	cmp	x3, x0
	beq	.L1939
.L2019:
	ldr	x4, [x5]
	cbz	x4, .L1936
	ldr	x0, [x4, 8]
	mov	x2, x5
	udiv	x5, x0, x6
	msub	x5, x5, x6, x0
	cmp	x1, x5
	bne	.L1936
	mov	x5, x4
	cmp	x3, x0
	bne	.L2019
.L1939:
	ldr	x0, [x2]
	b	.L1966
	.p2align 2,,3
.L2015:
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	mov	x2, x21
	mov	x1, x22
	mov	x0, x19
	mov	w3, -1
.LEHB177:
	bl	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0
.LEHE177:
	ldr	x2, [sp, 72]
	ldr	x1, [x23]
	subs	x2, x2, x1
	mov	x1, 0
	beq	.L1957
.L2011:
	bl	__stack_chk_fail
	.p2align 2,,3
.L2018:
	ldr	x0, [x19, 384]
	cbz	x0, .L1936
	add	x2, x19, 384
	b	.L1938
	.p2align 2,,3
.L2020:
	ldr	x1, [x0]
	mov	x2, x0
	cbz	x1, .L1936
	mov	x0, x1
.L1938:
	ldr	x1, [x0, 8]
	cmp	x3, x1
	bne	.L2020
	ldr	x0, [x2]
	ldr	x3, [x25, 8]
	ldr	x4, [x0, 8]
	udiv	x1, x4, x3
	msub	x1, x1, x3, x4
	lsl	x7, x1, 3
.L1966:
	ldr	x4, [x19, 368]
	ldr	x3, [x0]
	add	x6, x4, x7
	ldr	x5, [x4, x7]
	cmp	x5, x2
	beq	.L2021
	cbz	x3, .L1944
	ldr	x7, [x3, 8]
	ldr	x6, [x25, 8]
	udiv	x5, x7, x6
	msub	x5, x5, x6, x7
	cmp	x1, x5
	beq	.L1944
	str	x2, [x4, x5, lsl 3]
	ldr	x3, [x0]
.L1944:
	str	x3, [x2]
	bl	_ZdlPv
	ldr	x0, [x25, 24]
	sub	x0, x0, #1
	str	x0, [x25, 24]
.L1936:
	mov	x1, x21
	mov	x0, x25
.LEHB178:
	bl	_ZNSt8__detail9_Map_baseImSt4pairIKmjESaIS3_ENS_10_Select1stESt8equal_toImESt4hashImENS_18_Mod_range_hashingENS_20_Default_ranged_hashENS_20_Prime_rehash_policyENS_17_Hashtable_traitsILb0ELb0ELb1EEELb1EEixERS2_.isra.0
.LEHE178:
	str	w20, [x0]
	mov	x0, x24
	bl	pthread_mutex_unlock
	str	w20, [sp, 20]
	strb	wzr, [sp, 64]
	add	x0, x19, 16
	ldar	x0, [x0]
	cmp	x27, x0
	bcs	.L2022
	ldr	x2, [x19, 24]
	ldr	x0, [x19, 240]
	ldr	w1, [sp, 20]
	madd	x1, x1, x2, x0
	ldr	x0, [x19, 256]
	add	x0, x0, x1
	ldrb	w1, [x0, 2]
	tbz	x1, 0, .L1946
	and	w1, w1, -2
	strb	w1, [x0, 2]
	add	x1, x19, 40
	mov	x0, -1
	bl	__aarch64_ldadd8_acq_rel
	ldrb	w0, [x19, 456]
	tbnz	x0, 0, .L2023
.L1947:
	fmov	s0, 1.0e+0
	mov	w2, w20
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	mov	x1, x22
	mov	x0, x19
.LEHB179:
	bl	_ZN7hnswlib15HierarchicalNSWIfE11updatePointEPKvjf
	ldrb	w0, [sp, 64]
	tbnz	x0, 0, .L2024
.L1954:
	ldrb	w0, [sp, 48]
	ldr	x20, [sp, 24]
	tbz	x0, 0, .L1955
	ldr	x0, [sp, 40]
	cbz	x0, .L1955
	bl	pthread_mutex_unlock
.L1955:
	cbnz	x20, .L1932
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 72]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2011
	ldr	x27, [sp, 160]
	ldp	x25, x26, [sp, 144]
	.cfi_remember_state
	.cfi_restore 26
	.cfi_restore 25
	ldp	x29, x30, [sp, 80]
	ldp	x19, x20, [sp, 96]
	ldp	x21, x22, [sp, 112]
	ldp	x23, x24, [sp, 128]
	add	sp, sp, 176
	.cfi_restore 27
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L2024:
	.cfi_restore_state
	ldr	x0, [sp, 56]
	cbz	x0, .L1954
	bl	pthread_mutex_unlock
	b	.L1954
	.p2align 2,,3
.L2023:
	mov	x0, x23
	bl	pthread_mutex_lock
	cbnz	w0, .L2025
	add	x1, sp, 20
	mov	x0, x26
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEE5eraseERKj.isra.0
	mov	x0, x23
	bl	pthread_mutex_unlock
	b	.L1947
	.p2align 2,,3
.L2021:
	cbz	x3, .L2010
	ldr	x8, [x3, 8]
	ldr	x7, [x25, 8]
	udiv	x5, x8, x7
	msub	x5, x5, x7, x8
	cmp	x1, x5
	beq	.L1944
	str	x2, [x4, x5, lsl 3]
.L2010:
	str	xzr, [x6]
	ldr	x3, [x0]
	b	.L1944
.L2025:
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	ldr	x1, [sp, 72]
	ldr	x2, [x23]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L2011
	bl	_ZSt20__throw_system_errori
.LEHE179:
.L1972:
	mov	x19, x0
.L1953:
	ldrb	w0, [sp, 64]
	tbz	x0, 0, .L1962
.L1961:
	add	x0, sp, 56
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
.L1962:
	ldrb	w0, [sp, 48]
	tbz	x0, 0, .L1964
	add	x0, sp, 40
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
.L1964:
	add	x0, sp, 24
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	ldr	x0, [sp, 72]
	ldr	x1, [x23]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L2011
	mov	x0, x19
.LEHB180:
	bl	_Unwind_Resume
.LEHE180:
.L1946:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC37
	mov	x20, x0
	add	x1, x1, :lo12:.LC37
.LEHB181:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE181:
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 72]
	ldr	x1, [x23]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L2011
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x20
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB182:
	bl	__cxa_throw
.LEHE182:
.L2022:
	bl	_ZN7hnswlib15HierarchicalNSWIfE21unmarkDeletedInternalEj.part.0
.L1973:
	mov	x19, x0
	mov	x0, x20
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	bl	__cxa_free_exception
	b	.L1953
.L1974:
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	mov	x19, x0
	b	.L1961
.L1970:
	mov	x19, x0
	b	.L1964
.L2016:
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	ldr	x1, [sp, 72]
	ldr	x2, [x23]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L2011
.LEHB183:
	bl	_ZSt20__throw_system_errori
.LEHE183:
.L2014:
	.cfi_restore 25
	.cfi_restore 26
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 72]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	stp	x25, x26, [sp, 144]
	.cfi_remember_state
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	bne	.L2011
.LEHB184:
	bl	_ZSt20__throw_system_errori
.L2013:
	.cfi_restore_state
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 72]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	stp	x25, x26, [sp, 144]
	.cfi_remember_state
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	bne	.L2011
	mov	w0, 1
	bl	_ZSt20__throw_system_errori
.LEHE184:
.L2012:
	.cfi_restore_state
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC42
	mov	x19, x0
	add	x1, x1, :lo12:.LC42
.LEHB185:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE185:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 72]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	stp	x25, x26, [sp, 144]
	.cfi_remember_state
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	bne	.L2011
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x19
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB186:
	bl	__cxa_throw
.L1969:
	.cfi_restore_state
	mov	x20, x0
	mov	x0, x19
	bl	__cxa_free_exception
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 72]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	stp	x25, x26, [sp, 144]
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	bne	.L2011
	mov	x0, x20
	bl	_Unwind_Resume
.LEHE186:
.L1971:
	mov	x19, x0
	b	.L1962
.L2017:
	adrp	x23, :got:__stack_chk_guard
	ldr	x23, [x23, :got_lo12:__stack_chk_guard]
	ldr	x1, [sp, 72]
	ldr	x2, [x23]
	subs	x1, x1, x2
	mov	x2, 0
	bne	.L2011
.LEHB187:
	bl	_ZSt20__throw_system_errori
.LEHE187:
	.cfi_endproc
.LFE10725:
	.section	.gcc_except_table
.LLSDA10725:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE10725-.LLSDACSB10725
.LLSDACSB10725:
	.uleb128 .LEHB175-.LFB10725
	.uleb128 .LEHE175-.LEHB175
	.uleb128 .L1971-.LFB10725
	.uleb128 0
	.uleb128 .LEHB176-.LFB10725
	.uleb128 .LEHE176-.LEHB176
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB177-.LFB10725
	.uleb128 .LEHE177-.LEHB177
	.uleb128 .L1970-.LFB10725
	.uleb128 0
	.uleb128 .LEHB178-.LFB10725
	.uleb128 .LEHE178-.LEHB178
	.uleb128 .L1974-.LFB10725
	.uleb128 0
	.uleb128 .LEHB179-.LFB10725
	.uleb128 .LEHE179-.LEHB179
	.uleb128 .L1972-.LFB10725
	.uleb128 0
	.uleb128 .LEHB180-.LFB10725
	.uleb128 .LEHE180-.LEHB180
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB181-.LFB10725
	.uleb128 .LEHE181-.LEHB181
	.uleb128 .L1973-.LFB10725
	.uleb128 0
	.uleb128 .LEHB182-.LFB10725
	.uleb128 .LEHE182-.LEHB182
	.uleb128 .L1972-.LFB10725
	.uleb128 0
	.uleb128 .LEHB183-.LFB10725
	.uleb128 .LEHE183-.LEHB183
	.uleb128 .L1970-.LFB10725
	.uleb128 0
	.uleb128 .LEHB184-.LFB10725
	.uleb128 .LEHE184-.LEHB184
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB185-.LFB10725
	.uleb128 .LEHE185-.LEHB185
	.uleb128 .L1969-.LFB10725
	.uleb128 0
	.uleb128 .LEHB186-.LFB10725
	.uleb128 .LEHE186-.LEHB186
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB187-.LFB10725
	.uleb128 .LEHE187-.LEHB187
	.uleb128 .L1971-.LFB10725
	.uleb128 0
.LLSDACSE10725:
	.section	.text._ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb,"axG",@progbits,_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb,comdat
	.size	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb, .-_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb
	.text
	.align	2
	.p2align 5,,15
	.type	_Z11build_indexPfmm._omp_fn.0, %function
_Z11build_indexPfmm._omp_fn.0:
.LFB12786:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12786
	sub	sp, sp, #128
	.cfi_def_cfa_offset 128
	stp	x29, x30, [sp, 32]
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	add	x29, sp, 32
	stp	x19, x20, [sp, 48]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	mov	x20, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	stp	x23, x24, [sp, 80]
	ldr	x1, [x0]
	str	x1, [sp, 24]
	mov	x1, 0
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	bl	omp_get_num_threads
	mov	w19, w0
	bl	omp_get_thread_num
	ldr	x1, [x20, 8]
	sub	w1, w1, #1
	sdiv	w23, w1, w19
	msub	w1, w23, w19, w1
	cmp	w0, w1
	cinc	w23, w23, lt
	csel	w1, w1, wzr, ge
	madd	w0, w23, w0, w1
	add	w23, w23, w0
	cmp	w0, w23
	bge	.L2026
	stp	x21, x22, [sp, 64]
	.cfi_offset 22, -56
	.cfi_offset 21, -64
	add	w21, w0, 1
	sxtw	x0, w0
	stp	x25, x26, [sp, 96]
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	sxtw	x22, w21
	adrp	x25, _ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb
	stp	x27, x28, [sp, 112]
	.cfi_offset 28, -8
	.cfi_offset 27, -16
	add	w23, w23, 1
	add	x25, x25, :lo12:_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb
	ldp	x24, x28, [x20, 16]
	mov	w27, 48
	ldr	x1, [x20]
	mov	w26, 1
	add	x20, x0, 1
	lsl	x24, x24, 2
	madd	x22, x22, x24, x1
	b	.L2037
	.p2align 2,,3
.L2048:
	ldr	x0, [x28, 120]
	and	w19, w21, 65535
	umaddl	x19, w19, w27, x0
	str	x19, [sp, 8]
	cbz	x19, .L2045
	mov	x0, x19
	bl	pthread_mutex_lock
	cbnz	w0, .L2046
	mov	x2, x20
	mov	x1, x22
	mov	x0, x28
	mov	w3, -1
	strb	w26, [sp, 16]
.LEHB188:
	bl	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0
.LEHE188:
	mov	x0, x19
	add	w21, w21, 1
	bl	pthread_mutex_unlock
	add	x22, x22, x24
	add	x20, x20, 1
	cmp	w21, w23
	beq	.L2047
.L2037:
	ldr	x0, [x28]
	ldr	x4, [x0]
	cmp	x4, x25
	beq	.L2048
	mov	x2, x20
	mov	x1, x22
	mov	x0, x28
	mov	w3, 0
	add	w21, w21, 1
	blr	x4
	add	x22, x22, x24
	add	x20, x20, 1
	cmp	w21, w23
	bne	.L2037
.L2047:
	ldp	x21, x22, [sp, 64]
	.cfi_restore 22
	.cfi_restore 21
	ldp	x25, x26, [sp, 96]
	.cfi_restore 26
	.cfi_restore 25
	ldp	x27, x28, [sp, 112]
	.cfi_restore 28
	.cfi_restore 27
.L2026:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 24]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2049
	ldp	x29, x30, [sp, 32]
	ldp	x19, x20, [sp, 48]
	ldp	x23, x24, [sp, 80]
	add	sp, sp, 128
	.cfi_remember_state
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
.L2049:
	.cfi_restore_state
	stp	x21, x22, [sp, 64]
	.cfi_offset 22, -56
	.cfi_offset 21, -64
	stp	x25, x26, [sp, 96]
	.cfi_offset 26, -24
	.cfi_offset 25, -32
	stp	x27, x28, [sp, 112]
	.cfi_offset 28, -8
	.cfi_offset 27, -16
.L2044:
	bl	__stack_chk_fail
.L2040:
	mov	x19, x0
	add	x0, sp, 8
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 24]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2044
	mov	x0, x19
.LEHB189:
	bl	_Unwind_Resume
.L2046:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 24]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	bne	.L2044
	bl	_ZSt20__throw_system_errori
.L2045:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 24]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2044
	mov	w0, 1
	bl	_ZSt20__throw_system_errori
.LEHE189:
	.cfi_endproc
.LFE12786:
	.section	.gcc_except_table
.LLSDA12786:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12786-.LLSDACSB12786
.LLSDACSB12786:
	.uleb128 .LEHB188-.LFB12786
	.uleb128 .LEHE188-.LEHB188
	.uleb128 .L2040-.LFB12786
	.uleb128 0
	.uleb128 .LEHB189-.LFB12786
	.uleb128 .LEHE189-.LEHB189
	.uleb128 0
	.uleb128 0
.LLSDACSE12786:
	.text
	.size	_Z11build_indexPfmm._omp_fn.0, .-_Z11build_indexPfmm._omp_fn.0
	.section	.rodata.str1.8
	.align	3
.LC43:
	.string	"Not enough memory"
	.align	3
.LC44:
	.string	"Not enough memory: HierarchicalNSW failed to allocate linklists"
	.text
	.align	2
	.p2align 5,,15
	.global	_Z11build_indexPfmm
	.type	_Z11build_indexPfmm, %function
_Z11build_indexPfmm:
.LFB10158:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA10158
	stp	x29, x30, [sp, -96]!
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	stp	x25, x26, [sp, 64]
	stp	x27, x28, [sp, 80]
	sub	sp, sp, #1152
	.cfi_def_cfa_offset 1248
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	.cfi_offset 25, -32
	.cfi_offset 26, -24
	.cfi_offset 27, -16
	.cfi_offset 28, -8
	str	xzr, [sp, 1024]
	mov	x27, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	mov	x21, x1
	mov	x26, x2
	ldr	x1, [x0]
	str	x1, [sp, 1144]
	mov	x1, 0
	adrp	x0, _ZTVN7hnswlib17InnerProductSpaceE+16
	add	x0, x0, :lo12:_ZTVN7hnswlib17InnerProductSpaceE+16
	str	x0, [sp, 56]
	adrp	x0, _ZN7hnswlibL20InnerProductDistanceEPKvS1_S1_
	add	x0, x0, :lo12:_ZN7hnswlibL20InnerProductDistanceEPKvS1_S1_
	str	x0, [sp, 64]
	lsl	x0, x2, 2
	stp	x0, x2, [sp, 72]
	mov	x0, 568
.LEHB190:
	bl	_Znwm
.LEHE190:
	movi	v31.4s, 0
	mov	x19, x0
	adrp	x0, _ZTVN7hnswlib15HierarchicalNSWIfEE+16
	add	x0, x0, :lo12:_ZTVN7hnswlib15HierarchicalNSWIfEE+16
	str	x0, [x19]
	add	x0, x19, 8
	stp	xzr, xzr, [x19, 88]
	stp	q31, q31, [x19, 112]
	stp	q31, q31, [x0]
	stp	q31, q31, [x0, 32]
	mov	x0, 3145728
	str	wzr, [x19, 104]
	str	q31, [x19, 72]
.LEHB191:
	bl	_Znwm
.LEHE191:
	add	x20, x0, 3145728
	str	x0, [x19, 120]
	str	x20, [x19, 136]
	mov	x2, 3145728
	mov	w1, 0
	bl	memset
	str	x20, [x19, 128]
	mov	x0, -6148914691236517206
	stp	xzr, xzr, [x19, 144]
	movk	x0, 0x2aa, lsl 48
	stp	xzr, xzr, [x19, 160]
	stp	xzr, xzr, [x19, 176]
	cmp	x21, x0
	bhi	.L2167
	movi	v31.4s, 0
	mov	x20, x19
	str	q31, [x20, 192]!
	str	xzr, [x20, 16]
	cbz	x21, .L2168
	add	x23, x21, x21, lsl 1
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	lsl	x0, x23, 4
.LEHB192:
	bl	_Znwm
.LEHE192:
	str	x0, [x19, 192]
	add	x22, x0, x23, lsl 4
	str	x22, [x20, 16]
	lsl	x2, x23, 4
	mov	w1, 0
	bl	memset
	str	x22, [x20, 8]
	movi	v31.4s, 0
	add	x20, x19, 272
	str	wzr, [x19, 216]
	lsl	x22, x21, 2
	mov	x0, x22
	stp	q31, q31, [x19, 224]
	stp	q31, q31, [x19, 256]
	str	xzr, [x20, 16]
.LEHB193:
	bl	_Znwm
.LEHE193:
	mov	x3, x0
	str	x3, [x19, 272]
	add	x0, x0, x22
	str	x0, [x20, 16]
	str	wzr, [x3], 4
	cmp	x21, 1
	beq	.L2054
	sub	x22, x22, #4
	mov	x0, x3
	mov	x2, x22
	mov	w1, 0
	bl	memset
	add	x3, x0, x22
.L2054:
	add	x28, x19, 368
	str	x3, [x20, 8]
	add	x0, x19, 416
	str	xzr, [x19, 296]
	str	xzr, [x19, 312]
	mov	x1, 1
	stp	xzr, xzr, [x19, 320]
	fmov	s31, 1.0e+0
	add	x23, x19, 512
	stp	xzr, xzr, [x19, 336]
	stp	xzr, xzr, [x19, 352]
	str	x0, [x19, 368]
	str	x1, [x28, 8]
	str	xzr, [x19, 384]
	str	xzr, [x28, 24]
	str	xzr, [x19, 408]
	str	s31, [x19, 400]
	str	xzr, [x28, 48]
	stp	x1, x1, [x19, 424]
	stp	xzr, xzr, [x23, -72]
	str	x0, [sp]
	add	x0, x19, 560
	strb	wzr, [x19, 456]
	stp	xzr, xzr, [x19, 464]
	stp	xzr, xzr, [x19, 480]
	stp	xzr, xzr, [x19, 496]
	str	x0, [x19, 512]
	str	x1, [x23, 8]
	str	xzr, [x19, 528]
	str	xzr, [x23, 24]
	str	s31, [x23, 32]
	stp	xzr, xzr, [x23, 40]
	str	x21, [x19, 8]
	add	x0, x19, 40
	stlr	xzr, [x0]
	ldp	x0, x1, [sp, 64]
	stp	x1, x0, [x19, 296]
	adrp	x2, .LC49
	add	x0, sp, 80
	str	x0, [x19, 312]
	adrp	x0, .LC46
	ldr	q31, [x0, #:lo12:.LC46]
	adrp	x0, .LC47
	ldr	q30, [x0, #:lo12:.LC47]
	mov	x0, 10
	str	x0, [x19, 80]
	adrp	x0, .LC48
	stp	q31, q30, [x19, 48]
	ldr	q30, [x0, #:lo12:.LC48]
	add	x0, x1, 140
	add	x1, x1, 132
	str	q30, [x23, -88]
	stp	xzr, x1, [x19, 240]
	ldr	x1, [x19, 8]
	str	x0, [x19, 24]
	ldr	q30, [x2, #:lo12:.LC49]
	mul	x0, x0, x1
	str	q30, [x19, 224]
	bl	malloc
	str	x0, [x19, 256]
	adrp	x1, .LC46
	cbz	x0, .L2169
	add	x0, x19, 16
	stlr	xzr, [x0]
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	mov	x0, 136
.LEHB194:
	bl	_Znwm
.LEHE194:
	mov	x20, x0
	str	w21, [sp, 12]
	movi	v31.4s, 0
	mov	x0, 8
	stp	xzr, x0, [x20]
	mov	x0, 64
	stp	q31, q31, [x20, 16]
	stp	q31, q31, [x20, 48]
.LEHB195:
	bl	_Znwm
.LEHE195:
	mov	x22, x0
	str	x22, [x20]
	add	x25, x0, 24
	mov	x0, 512
.LEHB196:
	bl	_Znwm
.LEHE196:
	mov	x24, x0
	add	x1, x0, 512
	str	x24, [x22, 24]
	str	x0, [x20, 48]
	mov	x0, 24
	stp	x24, x1, [x20, 56]
	str	x25, [x20, 72]
	stp	xzr, xzr, [x20, 80]
	stp	xzr, xzr, [x20, 96]
	stp	xzr, xzr, [x20, 112]
	str	w21, [x20, 128]
.LEHB197:
	bl	_Znwm
.LEHE197:
	mov	x25, x0
	mov	w0, -1
	strh	w0, [x25]
	ubfiz	x0, x21, 1, 32
	str	w21, [x25, 16]
.LEHB198:
	bl	_Znam
.LEHE198:
	str	x0, [x25, 8]
	mov	x0, 512
.LEHB199:
	bl	_Znwm
.LEHE199:
	str	x0, [x22, 16]!
	add	x2, x0, 512
	stp	x0, x2, [x20, 24]
	add	x1, x0, 504
	str	x22, [x20, 40]
	ldr	x22, [x19, 112]
	str	x1, [x20, 16]
	str	x20, [x19, 112]
	str	x25, [x0, 504]
	add	x20, x22, 16
	cbnz	x22, .L2070
	b	.L2063
	.p2align 2,,3
.L2172:
	add	x1, x1, 8
	str	x1, [x22, 16]
	cbnz	x24, .L2170
.L2070:
	ldp	x3, x24, [x20, 16]
	ldr	x4, [x22, 72]
	ldr	x1, [x20]
	cmp	x4, 0
	sub	x0, x4, x24
	cset	x2, ne
	asr	x0, x0, 3
	sub	x0, x0, x2
	ldp	x2, x5, [x22, 48]
	sub	x2, x2, x5
	asr	x2, x2, 3
	add	x0, x2, x0, lsl 6
	sub	x2, x3, x1
	add	x0, x0, x2, asr 3
	cbz	x0, .L2171
	sub	x3, x3, #8
	ldr	x24, [x1]
	cmp	x1, x3
	bne	.L2172
	ldr	x0, [x22, 24]
	bl	_ZdlPv
	ldr	x0, [x22, 40]
	add	x1, x0, 8
	str	x1, [x20, 24]
	ldr	x1, [x0, 8]
	add	x0, x1, 512
	stp	x1, x0, [x20, 8]
	str	x1, [x22, 16]
	cbz	x24, .L2070
	.p2align 5,,15
.L2170:
	ldr	x0, [x24, 8]
	cbz	x0, .L2071
	bl	_ZdaPv
.L2071:
	mov	x0, x24
	bl	_ZdlPv
	b	.L2070
	.p2align 2,,3
.L2171:
	ldr	x0, [x22]
	cbz	x0, .L2073
	add	x20, x4, 8
	cmp	x24, x20
	bcs	.L2074
	.p2align 5,,15
.L2075:
	ldr	x0, [x24], 8
	bl	_ZdlPv
	cmp	x20, x24
	bhi	.L2075
	ldr	x0, [x22]
.L2074:
	bl	_ZdlPv
.L2073:
	mov	x0, x22
	bl	_ZdlPv
.L2063:
	ldr	x0, [x19, 8]
	mov	w20, -1
	str	w20, [x19, 104]
	str	w20, [x19, 216]
	lsl	x0, x0, 3
	bl	malloc
	str	x0, [x19, 264]
	cbz	x0, .L2173
	ldp	x1, x0, [x19, 48]
	add	x0, x0, 1
	ucvtf	d0, x1
	lsl	x0, x0, 2
	str	x0, [x19, 32]
	bl	log
	fmov	d31, 1.0e+0
	ldr	x22, [x19, 120]
	fdiv	d0, d31, d0
	fdiv	d31, d31, d0
	stp	d0, d31, [x19, 88]
	str	x22, [sp, 16]
	cbz	x22, .L2174
	mov	x0, x22
	bl	pthread_mutex_lock
	cbnz	w0, .L2175
	mov	w0, 1
	mov	w3, w20
	mov	x1, x27
	mov	x2, 0
	strb	w0, [sp, 24]
	mov	x0, x19
.LEHB200:
	bl	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmi.isra.0
.LEHE200:
	mov	x0, x22
	bl	pthread_mutex_unlock
	add	x1, sp, 16
	mov	w3, 0
	mov	w2, 0
	adrp	x0, _Z11build_indexPfmm._omp_fn.0
	add	x0, x0, :lo12:_Z11build_indexPfmm._omp_fn.0
	stp	x27, x21, [sp, 16]
	add	x20, sp, 88
	stp	x26, x19, [sp, 32]
	bl	GOMP_parallel
	adrp	x0, .LC45
	add	x0, x0, :lo12:.LC45
	mov	w1, 0
	add	x21, sp, 104
	ldp	x2, x3, [x0]
	stp	x2, x3, [sp, 120]
	ldrb	w0, [x0, 16]
	strb	w0, [sp, 136]
	add	x0, sp, 137
	mov	x2, 1007
	bl	memset
	str	x21, [sp, 88]
	ldr	x0, [x19]
	add	x2, sp, 136
	add	x1, sp, 120
	ldr	x23, [x0, 24]
	mov	x0, x20
.LEHB201:
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_M_constructIPKcEEvT_S8_St20forward_iterator_tag.isra.0
.LEHE201:
	adrp	x0, _ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE
	add	x0, x0, :lo12:_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE
	cmp	x23, x0
	bne	.L2176
	mov	x1, x20
	mov	x0, x19
.LEHB202:
	bl	_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE
.L2110:
	ldr	x0, [sp, 88]
	cmp	x0, x21
	beq	.L2050
	bl	_ZdlPv
.L2050:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 1144]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2166
	add	sp, sp, 1152
	.cfi_remember_state
	.cfi_def_cfa_offset 96
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x25, x26, [sp, 64]
	ldp	x27, x28, [sp, 80]
	ldp	x29, x30, [sp], 96
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L2168:
	.cfi_restore_state
	str	xzr, [x20, 16]
	add	x20, x19, 272
	str	wzr, [x19, 216]
	mov	x3, 0
	stp	q31, q31, [x19, 224]
	str	q31, [x19, 256]
	str	xzr, [x19, 272]
	str	xzr, [x20, 16]
	b	.L2054
	.p2align 2,,3
.L2176:
	mov	x1, x20
	mov	x0, x19
	blr	x23
.LEHE202:
	b	.L2110
.L2169:
	ldr	x0, [x1, #:lo12:.LC46]
	bl	__cxa_allocate_exception
	mov	x21, x0
	adrp	x1, .LC43
	add	x1, x1, :lo12:.LC43
.LEHB203:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE203:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 1144]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	beq	.L2056
.L2166:
	bl	__stack_chk_fail
.L2115:
	mov	x19, x0
	mov	x0, x20
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 1144]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2166
.L2113:
	mov	x0, x19
.LEHB204:
	bl	_Unwind_Resume
.LEHE204:
.L2167:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 1144]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L2166
	adrp	x0, .LC4
	add	x0, x0, :lo12:.LC4
.LEHB205:
	bl	_ZSt20__throw_length_errorPKc
.LEHE205:
.L2127:
	mov	x19, x0
	add	x0, sp, 16
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 1144]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	beq	.L2113
	b	.L2166
.L2118:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	mov	x20, x0
.L2087:
	ldr	x0, [x19, 192]
	cbz	x0, .L2089
	bl	_ZdlPv
.L2089:
	ldr	x0, [x19, 120]
	cbz	x0, .L2091
	bl	_ZdlPv
.L2091:
	ldr	x21, [x19, 112]
	add	x23, x21, 16
	cbnz	x21, .L2096
.L2093:
	mov	x0, x19
	bl	_ZdlPv
	ldr	x0, [sp, 1144]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L2166
	mov	x0, x20
.LEHB206:
	bl	_Unwind_Resume
.LEHE206:
.L2117:
	mov	x20, x0
	b	.L2089
.L2098:
	sub	x4, x4, #8
	ldr	x24, [x0]
	cmp	x0, x4
	beq	.L2094
	add	x0, x0, 8
.L2095:
	str	x0, [x21, 16]
	cbnz	x24, .L2177
.L2096:
	ldp	x4, x24, [x23, 16]
	ldr	x2, [x21, 72]
	ldr	x0, [x23]
	cmp	x2, 0
	sub	x1, x2, x24
	cset	x3, ne
	asr	x1, x1, 3
	sub	x1, x1, x3
	ldp	x3, x5, [x21, 48]
	sub	x3, x3, x5
	asr	x3, x3, 3
	add	x1, x3, x1, lsl 6
	sub	x3, x4, x0
	add	x1, x1, x3, asr 3
	cbnz	x1, .L2098
	ldr	x0, [x21]
	add	x23, x2, 8
	cbnz	x0, .L2100
.L2099:
	mov	x0, x21
	bl	_ZdlPv
	b	.L2093
.L2116:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	mov	x20, x0
	b	.L2091
.L2056:
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB207:
	bl	__cxa_throw
.LEHE207:
.L2122:
.L2164:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	mov	x20, x0
	mov	x0, x21
	bl	__cxa_free_exception
.L2081:
	mov	x0, x23
	bl	_ZNSt10_HashtableIjjSaIjENSt8__detail9_IdentityESt8equal_toIjESt4hashIjENS1_18_Mod_range_hashingENS1_20_Default_ranged_hashENS1_20_Prime_rehash_policyENS1_17_Hashtable_traitsILb0ELb1ELb1EEEED1Ev
	ldr	x0, [x28, 16]
	cbz	x0, .L2178
.L2084:
	ldr	x21, [x0]
	bl	_ZdlPv
	mov	x0, x21
	cbz	x0, .L2178
	b	.L2084
.L2101:
	ldr	x0, [x24], 8
	bl	_ZdlPv
.L2100:
	cmp	x23, x24
	bhi	.L2101
	ldr	x0, [x21]
	bl	_ZdlPv
	b	.L2099
.L2094:
	ldr	x0, [x21, 24]
	bl	_ZdlPv
	ldr	x0, [x21, 40]
	add	x1, x0, 8
	ldr	x0, [x0, 8]
	str	x1, [x23, 24]
	add	x1, x0, 512
	stp	x0, x1, [x23, 8]
	b	.L2095
.L2177:
	ldr	x0, [x24, 8]
	cbz	x0, .L2097
	bl	_ZdaPv
.L2097:
	mov	x0, x24
	bl	_ZdlPv
	b	.L2096
.L2178:
	ldr	x1, [sp]
	ldr	x0, [x19, 368]
	cmp	x1, x0
	beq	.L2085
	bl	_ZdlPv
.L2085:
	ldr	x0, [x19, 272]
	cbz	x0, .L2087
	bl	_ZdlPv
	b	.L2087
.L2175:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 1144]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	bne	.L2166
.LEHB208:
	bl	_ZSt20__throw_system_errori
.L2174:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 1144]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2166
	mov	w0, 1
	bl	_ZSt20__throw_system_errori
.LEHE208:
.L2173:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC44
	mov	x21, x0
	add	x1, x1, :lo12:.LC44
.LEHB209:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE209:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	ldr	x0, [sp, 1144]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L2166
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x21
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB210:
	bl	__cxa_throw
.LEHE210:
.L2128:
	mov	x21, x0
	mov	x0, x25
	bl	_ZdlPv
.L2067:
	mov	x0, x24
	bl	_ZdlPv
	mov	x0, x22
	bl	_ZdlPv
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
.L2065:
	mov	x0, x20
	mov	x20, x21
	bl	_ZdlPv
	b	.L2081
.L2120:
	b	.L2164
.L2123:
	mov	x21, x0
	b	.L2067
.L2125:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	bl	__cxa_begin_catch
	ldr	x0, [sp, 1144]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L2166
.LEHB211:
	bl	__cxa_rethrow
.LEHE211:
.L2121:
	adrp	x22, :got:__stack_chk_guard
	ldr	x22, [x22, :got_lo12:__stack_chk_guard]
	mov	x21, x0
	b	.L2065
.L2119:
	mov	x20, x0
	b	.L2081
.L2126:
	mov	x21, x0
	bl	__cxa_end_catch
	mov	x0, x21
	bl	__cxa_begin_catch
	ldr	x0, [x20]
	bl	_ZdlPv
	stp	xzr, xzr, [x20]
	ldr	x0, [sp, 1144]
	ldr	x1, [x22]
	subs	x0, x0, x1
	mov	x1, 0
	bne	.L2166
.LEHB212:
	bl	__cxa_rethrow
.LEHE212:
.L2124:
	mov	x21, x0
	bl	__cxa_end_catch
	b	.L2065
	.cfi_endproc
.LFE10158:
	.section	.gcc_except_table
	.align	2
.LLSDA10158:
	.byte	0xff
	.byte	0x9b
	.uleb128 .LLSDATT10158-.LLSDATTD10158
.LLSDATTD10158:
	.byte	0x1
	.uleb128 .LLSDACSE10158-.LLSDACSB10158
.LLSDACSB10158:
	.uleb128 .LEHB190-.LFB10158
	.uleb128 .LEHE190-.LEHB190
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB191-.LFB10158
	.uleb128 .LEHE191-.LEHB191
	.uleb128 .L2116-.LFB10158
	.uleb128 0
	.uleb128 .LEHB192-.LFB10158
	.uleb128 .LEHE192-.LEHB192
	.uleb128 .L2117-.LFB10158
	.uleb128 0
	.uleb128 .LEHB193-.LFB10158
	.uleb128 .LEHE193-.LEHB193
	.uleb128 .L2118-.LFB10158
	.uleb128 0
	.uleb128 .LEHB194-.LFB10158
	.uleb128 .LEHE194-.LEHB194
	.uleb128 .L2119-.LFB10158
	.uleb128 0
	.uleb128 .LEHB195-.LFB10158
	.uleb128 .LEHE195-.LEHB195
	.uleb128 .L2121-.LFB10158
	.uleb128 0
	.uleb128 .LEHB196-.LFB10158
	.uleb128 .LEHE196-.LEHB196
	.uleb128 .L2125-.LFB10158
	.uleb128 0x1
	.uleb128 .LEHB197-.LFB10158
	.uleb128 .LEHE197-.LEHB197
	.uleb128 .L2123-.LFB10158
	.uleb128 0
	.uleb128 .LEHB198-.LFB10158
	.uleb128 .LEHE198-.LEHB198
	.uleb128 .L2128-.LFB10158
	.uleb128 0
	.uleb128 .LEHB199-.LFB10158
	.uleb128 .LEHE199-.LEHB199
	.uleb128 .L2123-.LFB10158
	.uleb128 0
	.uleb128 .LEHB200-.LFB10158
	.uleb128 .LEHE200-.LEHB200
	.uleb128 .L2127-.LFB10158
	.uleb128 0
	.uleb128 .LEHB201-.LFB10158
	.uleb128 .LEHE201-.LEHB201
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB202-.LFB10158
	.uleb128 .LEHE202-.LEHB202
	.uleb128 .L2115-.LFB10158
	.uleb128 0
	.uleb128 .LEHB203-.LFB10158
	.uleb128 .LEHE203-.LEHB203
	.uleb128 .L2122-.LFB10158
	.uleb128 0
	.uleb128 .LEHB204-.LFB10158
	.uleb128 .LEHE204-.LEHB204
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB205-.LFB10158
	.uleb128 .LEHE205-.LEHB205
	.uleb128 .L2117-.LFB10158
	.uleb128 0
	.uleb128 .LEHB206-.LFB10158
	.uleb128 .LEHE206-.LEHB206
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB207-.LFB10158
	.uleb128 .LEHE207-.LEHB207
	.uleb128 .L2119-.LFB10158
	.uleb128 0
	.uleb128 .LEHB208-.LFB10158
	.uleb128 .LEHE208-.LEHB208
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB209-.LFB10158
	.uleb128 .LEHE209-.LEHB209
	.uleb128 .L2120-.LFB10158
	.uleb128 0
	.uleb128 .LEHB210-.LFB10158
	.uleb128 .LEHE210-.LEHB210
	.uleb128 .L2119-.LFB10158
	.uleb128 0
	.uleb128 .LEHB211-.LFB10158
	.uleb128 .LEHE211-.LEHB211
	.uleb128 .L2126-.LFB10158
	.uleb128 0x1
	.uleb128 .LEHB212-.LFB10158
	.uleb128 .LEHE212-.LEHB212
	.uleb128 .L2124-.LFB10158
	.uleb128 0
.LLSDACSE10158:
	.byte	0x1
	.byte	0
	.align	2
	.4byte	0

.LLSDATT10158:
	.text
	.size	_Z11build_indexPfmm, .-_Z11build_indexPfmm
	.section	.rodata.str1.8
	.align	3
.LC45:
	.string	"files/hnsw.index"
	.text
	.section	.text._ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm,"axG",@progbits,_ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm
	.type	_ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm, %function
_ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm:
.LFB12608:
	.cfi_startproc
	cbz	x1, .L2198
	mov	x3, x0
	ldp	x4, x0, [x0, 8]
	sub	x0, x0, x4
	cmp	x1, x0, asr 4
	bhi	.L2181
	add	x0, x4, x1, lsl 4
	mov	x2, x4
	.p2align 5,,15
.L2182:
	add	x2, x2, 16
	str	wzr, [x2, -16]
	str	xzr, [x2, -8]
	cmp	x2, x0
	bne	.L2182
	add	x1, x4, x1, lsl 4
	str	x1, [x3, 8]
	ret
	.p2align 2,,3
.L2198:
	ret
	.p2align 2,,3
.L2181:
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x2, 576460752303423487
	mov	x29, sp
	ldr	x10, [x3]
	str	x19, [sp, 16]
	.cfi_offset 19, -64
	sub	x5, x4, x10
	asr	x9, x5, 4
	sub	x0, x2, x9
	cmp	x0, x1
	bcc	.L2200
	cmp	x1, x9
	stp	x9, x1, [sp, 32]
	csel	x0, x1, x9, cs
	add	x0, x0, x9
	stp	x10, x4, [sp, 48]
	cmp	x0, x2
	csel	x0, x0, x2, ls
	stp	x3, x5, [sp, 64]
	lsl	x0, x0, 4
	mov	x19, x0
	bl	_Znwm
	ldp	x3, x5, [sp, 64]
	mov	x8, x0
	ldp	x9, x1, [sp, 32]
	ldp	x10, x4, [sp, 48]
	add	x2, x0, x5
	add	x0, x2, x1, lsl 4
	.p2align 5,,15
.L2184:
	add	x2, x2, 16
	str	wzr, [x2, -16]
	str	xzr, [x2, -8]
	cmp	x2, x0
	bne	.L2184
	cmp	x10, x4
	beq	.L2185
	add	x5, x8, x5
	mov	x2, x8
	mov	x4, x10
	.p2align 5,,15
.L2186:
	ldp	x6, x7, [x4], 16
	stp	x6, x7, [x2], 16
	cmp	x2, x5
	bne	.L2186
.L2185:
	cbz	x10, .L2187
	mov	x0, x10
	stp	x9, x8, [sp, 32]
	stp	x3, x1, [sp, 48]
	bl	_ZdlPv
	ldp	x9, x8, [sp, 32]
	ldp	x3, x1, [sp, 48]
.L2187:
	add	x1, x1, x9
	add	x1, x8, x1, lsl 4
	stp	x8, x1, [x3]
	add	x8, x8, x19
	ldr	x19, [sp, 16]
	str	x8, [x3, 16]
	ldp	x29, x30, [sp], 80
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	ret
.L2200:
	.cfi_restore_state
	adrp	x0, .LC6
	add	x0, x0, :lo12:.LC6
	bl	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE12608:
	.size	_ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm, .-_ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm
	.section	.text._ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_,"axG",@progbits,_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_
	.type	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_, %function
_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_:
.LFB12681:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x4, 1152921504606846975
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	.cfi_offset 23, -32
	.cfi_offset 24, -24
	ldp	x21, x23, [x0]
	sub	x22, x23, x21
	asr	x3, x22, 3
	cmp	x3, x4
	beq	.L2212
	cmp	x3, 0
	mov	x19, x0
	csinc	x0, x3, xzr, ne
	mov	x24, x2
	add	x0, x0, x3
	str	x1, [sp, 72]
	cmp	x0, x4
	csel	x0, x0, x4, ls
	lsl	x20, x0, 3
	mov	x0, x20
	bl	_Znwm
	ldr	x1, [sp, 72]
	mov	x5, x0
	add	x4, x0, x22
	ldr	w0, [x24]
	ldr	s31, [x1]
	mov	x1, x5
	str	s31, [x5, x22]
	str	w0, [x4, 4]
	cmp	x21, x23
	beq	.L2203
	mov	x2, x21
	.p2align 5,,15
.L2204:
	ldr	x3, [x2], 8
	str	x3, [x1], 8
	cmp	x1, x4
	bne	.L2204
.L2203:
	add	x22, x1, 8
	cbz	x21, .L2205
	mov	x0, x21
	str	x5, [sp, 72]
	bl	_ZdlPv
	ldr	x5, [sp, 72]
.L2205:
	stp	x5, x22, [x19]
	add	x5, x5, x20
	str	x5, [x19, 16]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 80
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L2212:
	.cfi_restore_state
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE12681:
	.size	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_, .-_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_
	.section	.text._ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_,"axG",@progbits,_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_
	.type	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_, %function
_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_:
.LFB12689:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x4, 1152921504606846975
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	stp	x23, x24, [sp, 48]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	.cfi_offset 23, -32
	.cfi_offset 24, -24
	ldp	x21, x23, [x0]
	sub	x22, x23, x21
	asr	x3, x22, 3
	cmp	x3, x4
	beq	.L2224
	cmp	x3, 0
	mov	x19, x0
	csinc	x0, x3, xzr, ne
	mov	x24, x2
	add	x0, x0, x3
	str	x1, [sp, 72]
	cmp	x0, x4
	csel	x0, x0, x4, ls
	lsl	x20, x0, 3
	mov	x0, x20
	bl	_Znwm
	ldr	x1, [sp, 72]
	mov	x5, x0
	add	x4, x0, x22
	ldr	w0, [x24]
	ldr	s31, [x1]
	mov	x1, x5
	str	s31, [x5, x22]
	str	w0, [x4, 4]
	cmp	x21, x23
	beq	.L2215
	mov	x2, x21
	.p2align 5,,15
.L2216:
	ldr	x3, [x2], 8
	str	x3, [x1], 8
	cmp	x1, x4
	bne	.L2216
.L2215:
	add	x22, x1, 8
	cbz	x21, .L2217
	mov	x0, x21
	str	x5, [sp, 72]
	bl	_ZdlPv
	ldr	x5, [sp, 72]
.L2217:
	stp	x5, x22, [x19]
	add	x5, x5, x20
	str	x5, [x19, 16]
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x23, x24, [sp, 48]
	ldp	x29, x30, [sp], 80
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L2224:
	.cfi_restore_state
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
	bl	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE12689:
	.size	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_, .-_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_
	.section	.text._ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE,"axG",@progbits,_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE
	.type	_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE, %function
_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE:
.LFB12508:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12508
	sub	sp, sp, #384
	.cfi_def_cfa_offset 384
	stp	x29, x30, [sp, 272]
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	add	x29, sp, 272
	stp	x25, x26, [sp, 336]
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	mov	x26, x0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	str	x3, [sp, 64]
	stp	x8, x2, [sp, 104]
	stp	x21, x22, [sp, 304]
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	mov	x22, x1
	ldr	x1, [x0]
	str	x1, [sp, 264]
	mov	x1, 0
	stp	xzr, xzr, [x8]
	str	xzr, [x8, 16]
	add	x0, x26, 16
	ldar	x0, [x0]
	cbz	x0, .L2225
	stp	x19, x20, [sp, 288]
	.cfi_offset 20, -88
	.cfi_offset 19, -96
	stp	x23, x24, [sp, 320]
	.cfi_offset 24, -56
	.cfi_offset 23, -64
	stp	x27, x28, [sp, 352]
	.cfi_offset 28, -24
	.cfi_offset 27, -32
	stp	d14, d15, [sp, 368]
	.cfi_offset 79, -8
	.cfi_offset 78, -16
	ldr	w23, [x26, 216]
	ldr	x0, [x26, 24]
	uxtw	x3, w23
	str	x3, [sp, 16]
	ldr	x1, [x26, 232]
	ldp	x5, x2, [x26, 304]
	madd	x0, x3, x0, x1
	ldr	x1, [x26, 256]
	add	x1, x1, x0
	mov	x0, x22
.LEHB213:
	blr	x5
	ldr	w0, [x26, 104]
	fmov	s15, s0
	cmp	w0, 0
	ble	.L2228
	ldr	x3, [sp, 16]
	sxtw	x1, w0
	sub	x21, x1, #1
	sub	w0, w0, #1
	sub	x1, x1, #2
	add	x25, x26, 448
	add	x24, x26, 440
	sub	x0, x1, x0
	str	x0, [sp, 8]
	.p2align 5,,15
.L2235:
	ldr	x0, [x26, 32]
	ldr	x1, [x26, 264]
	mul	x0, x21, x0
	ldr	x1, [x1, x3, lsl 3]
	add	x20, x1, x0
	ldrh	w19, [x1, x0]
	mov	x1, x25
	mov	x0, 1
	bl	__aarch64_ldadd8_acq_rel
	mov	x1, x24
	uxtw	x0, w19
	bl	__aarch64_ldadd8_acq_rel
	cbz	w19, .L2230
	sub	w19, w19, #1
	add	x27, x20, 4
	add	x20, x20, 8
	add	x19, x20, w19, uxtw 2
	mov	w20, 0
	.p2align 5,,15
.L2234:
	ldr	x0, [x26, 8]
	ldr	w28, [x27]
	uxtw	x1, w28
	cmp	x1, x0
	bhi	.L2460
	ldr	x2, [x26, 24]
	ldr	x0, [x26, 232]
	madd	x1, x1, x2, x0
	ldp	x5, x2, [x26, 304]
	ldr	x0, [x26, 256]
	add	x1, x0, x1
	mov	x0, x22
	blr	x5
.LEHE213:
	fcmpe	s0, s15
	bmi	.L2368
.L2233:
	add	x27, x27, 4
	cmp	x19, x27
	bne	.L2234
	uxtw	x3, w23
	cbnz	w20, .L2235
	.p2align 5,,15
.L2230:
	ldr	x0, [sp, 8]
	sub	x21, x21, #1
	cmp	x21, x0
	beq	.L2228
	uxtw	x3, w23
	b	.L2235
.L2228:
	str	xzr, [sp, 176]
	add	x0, x26, 40
	ldar	x1, [x0]
	ldr	x21, [x26, 80]
	ldr	x0, [sp, 112]
	ldr	x2, [sp, 64]
	cmp	x21, x0
	csel	x21, x21, x0, cs
	ldr	x0, [x26, 112]
	orr	x1, x2, x1
	cbz	x1, .L2461
.LEHB214:
	bl	_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv
.LEHE214:
	ldr	x1, [x0, 8]
	str	x0, [sp, 120]
	ldrh	w0, [x0]
	uxtw	x24, w23
	str	x1, [sp, 40]
	mov	w27, w0
	ldr	x0, [x26, 24]
	ldr	x1, [x26, 256]
	ldr	x2, [x26, 240]
	mul	x0, x24, x0
	add	x5, x1, x0
	add	x2, x5, x2
	ldrb	w2, [x2, 2]
	tbnz	x2, 0, .L2283
	ldr	x2, [sp, 64]
	cbz	x2, .L2284
	ldr	x2, [x2]
	ldr	x3, [x2]
	adrp	x2, _ZN7hnswlib17BaseFilterFunctorclEm
	add	x2, x2, :lo12:_ZN7hnswlib17BaseFilterFunctorclEm
	cmp	x3, x2
	bne	.L2462
.L2284:
	ldr	x2, [x26, 232]
	add	x0, x0, x2
	ldp	x3, x2, [x26, 304]
	add	x1, x1, x0
	mov	x0, x22
.LEHB215:
	blr	x3
.LEHE215:
	fmov	s14, s0
	mov	x0, 8
.LEHB216:
	bl	_Znwm
.LEHE216:
	mov	x20, x0
	fneg	s15, s14
	add	x28, x0, 8
	mov	x0, 8
	str	w23, [x20, 4]
	str	s14, [x20]
.LEHB217:
	bl	_Znwm
.LEHE217:
	mov	x19, x0
	add	x25, x0, 8
	str	s15, [x0]
	str	w23, [x0, 4]
	b	.L2291
.L2469:
	cbz	x20, .L2452
	mov	x0, x20
	bl	_ZdlPv
	ldp	x19, x20, [sp, 288]
	.cfi_restore 20
	.cfi_restore 19
	ldp	x23, x24, [sp, 320]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 352]
	.cfi_restore 28
	.cfi_restore 27
	ldp	d14, d15, [sp, 368]
	.cfi_restore 79
	.cfi_restore 78
.L2225:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 264]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2463
	ldr	x0, [sp, 104]
	ldp	x29, x30, [sp, 272]
	ldp	x21, x22, [sp, 304]
	ldp	x25, x26, [sp, 336]
	add	sp, sp, 384
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L2368:
	.cfi_def_cfa_offset 384
	.cfi_offset 19, -96
	.cfi_offset 20, -88
	.cfi_offset 21, -80
	.cfi_offset 22, -72
	.cfi_offset 23, -64
	.cfi_offset 24, -56
	.cfi_offset 25, -48
	.cfi_offset 26, -40
	.cfi_offset 27, -32
	.cfi_offset 28, -24
	.cfi_offset 29, -112
	.cfi_offset 30, -104
	.cfi_offset 78, -16
	.cfi_offset 79, -8
	fmov	s15, s0
	mov	w23, w28
	mov	w20, 1
	b	.L2233
.L2283:
	mov	x0, 8
.LEHB218:
	bl	_Znwm
.LEHE218:
	mov	x19, x0
	mvni	v31.2s, 0x80, lsl 16
	add	x25, x0, 8
	mov	x28, 0
	mov	w0, 2139095039
	mov	x20, 0
	fmov	s14, w0
	str	w23, [x19, 4]
	str	s31, [x19]
.L2291:
	ldr	x0, [sp, 40]
	strh	w27, [x0, x24, lsl 1]
	cmp	x19, x25
	beq	.L2372
	mov	x23, x28
	add	x24, sp, 192
	adrp	x0, _ZN7hnswlib17BaseFilterFunctorclEm
	add	x0, x0, :lo12:_ZN7hnswlib17BaseFilterFunctorclEm
	stp	x25, x22, [sp, 48]
	str	x0, [sp, 80]
	.p2align 5,,15
.L2328:
	ldr	s31, [x19]
	fneg	s31, s31
	fcmpe	s14, s31
	bmi	.L2402
.L2295:
	ldr	x0, [sp, 48]
	str	x0, [sp, 240]
	ldr	w22, [x19, 4]
	add	x0, sp, 224
	str	x0, [sp, 72]
	stp	x19, x25, [sp, 224]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	uxtw	x0, w22
	ldr	x2, [x26, 24]
	ldr	x1, [x26, 240]
	ldr	x25, [sp, 232]
	madd	x0, x0, x2, x1
	ldr	x1, [x26, 256]
	add	x11, x1, x0
	ldrh	w10, [x1, x0]
	cbz	x10, .L2297
	mov	x22, x26
	mov	x26, x28
	mov	x28, 1
	stp	x11, x10, [sp, 24]
	b	.L2327
	.p2align 2,,3
.L2465:
	fcmpe	s0, s14
	bmi	.L2302
.L2298:
	ldr	x0, [sp, 32]
	cmp	x28, x0
	beq	.L2464
.L2376:
	add	x28, x28, 1
.L2327:
	ldr	x0, [sp, 24]
	ldr	x2, [sp, 40]
	ldr	w5, [x0, x28, lsl 2]
	str	w5, [sp, 136]
	sbfiz	x0, x5, 1, 32
	ldrh	w1, [x2, x0]
	cmp	w1, w27
	beq	.L2298
	ldr	x1, [x22, 232]
	strh	w27, [x2, x0]
	ldr	x0, [x22, 24]
	uxtw	x9, w5
	str	x9, [sp, 8]
	str	w5, [sp, 16]
	str	w5, [sp, 88]
	madd	x0, x9, x0, x1
	ldr	x1, [x22, 256]
	ldp	x3, x2, [x22, 304]
	add	x1, x1, x0
	ldr	x0, [sp, 56]
.LEHB219:
	blr	x3
.LEHE219:
	sub	x7, x26, x20
	str	s0, [sp, 140]
	ldr	x9, [sp, 8]
	asr	x7, x7, 3
	ldr	w5, [sp, 16]
	cmp	x7, x21
	bcs	.L2465
.L2302:
	fneg	s30, s0
	ldr	x0, [sp, 48]
	str	s30, [sp, 144]
	cmp	x25, x0
	beq	.L2305
	add	x25, x25, 8
	str	s30, [x25, -8]
	str	w5, [x25, -4]
	sub	x2, x25, x19
	mov	w10, w5
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	ble	.L2307
.L2472:
	sub	x1, x1, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L2310:
	lsl	x2, x1, 3
	add	x3, x19, x1, lsl 3
	ldr	s31, [x19, x2]
	lsl	x2, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s31, s30
	bmi	.L2403
.L2308:
	ldr	x2, [x22, 24]
	ldr	x1, [x22, 256]
	str	s30, [x0]
	str	w10, [x0, 4]
	ldr	x0, [x22, 240]
	madd	x9, x9, x2, x1
	add	x0, x9, x0
	ldrb	w0, [x0, 2]
	tbnz	x0, 0, .L2362
	ldr	x0, [sp, 64]
	cbz	x0, .L2315
	ldr	x0, [sp, 64]
	ldr	x0, [x0]
	ldr	x2, [x0]
	ldr	x0, [sp, 80]
	cmp	x2, x0
	bne	.L2466
.L2315:
	cmp	x26, x23
	beq	.L2467
.L2313:
	add	x26, x26, 8
	str	w5, [x26, -4]
	str	s0, [x26, -8]
.L2318:
	sub	x1, x26, x20
	asr	x7, x1, 3
	sub	x0, x7, #1
	cmp	x0, 0
	ble	.L2321
	sub	x1, x7, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L2324:
	lsl	x2, x1, 3
	add	x3, x20, x1, lsl 3
	ldr	s31, [x20, x2]
	lsl	x2, x0, 3
	add	x0, x20, x0, lsl 3
	fcmpe	s0, s31
	bgt	.L2404
.L2322:
	ldr	w1, [sp, 88]
	str	w1, [x0, 4]
	str	s0, [x0]
.L2362:
	cmp	x7, x21
	bls	.L2325
	.p2align 5,,15
.L2326:
	mov	x0, x24
	stp	x20, x26, [sp, 192]
	str	x23, [sp, 208]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x26, [sp, 200]
	sub	x0, x26, x20
	cmp	x21, x0, asr 3
	bcc	.L2326
.L2325:
	cmp	x26, x20
	beq	.L2298
	ldr	x0, [sp, 32]
	ldr	s14, [x20]
	cmp	x28, x0
	bne	.L2376
.L2464:
	mov	x28, x26
	mov	x26, x22
.L2297:
	cmp	x19, x25
	bne	.L2328
.L2294:
	ldr	x19, [x26, 112]
	add	x21, x19, 80
	str	x21, [sp, 144]
	mov	x0, x21
	bl	pthread_mutex_lock
	cbnz	w0, .L2468
	mov	w2, 1
	strb	w2, [sp, 152]
	ldp	x1, x0, [x19, 16]
	cmp	x1, x0
	beq	.L2331
	ldr	x0, [sp, 120]
	str	x0, [x1, -8]!
	str	x1, [x19, 16]
.L2332:
	mov	x0, x21
	bl	pthread_mutex_unlock
	cbz	x25, .L2337
	mov	x0, x25
	bl	_ZdlPv
.L2337:
	str	x23, [sp, 176]
.L2276:
	sub	x0, x28, x20
	ldr	x21, [sp, 112]
	asr	x1, x0, 3
	b	.L2345
	.p2align 2,,3
.L2346:
	add	x0, sp, 160
	stp	x20, x28, [sp, 160]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x28, [sp, 168]
	sub	x0, x28, x20
	asr	x1, x0, 3
.L2345:
	cmp	x1, x21
	bhi	.L2346
	mov	x22, 576460752303423487
	.p2align 5,,15
.L2347:
	cbz	x0, .L2469
	ldp	x1, x2, [x26, 248]
	ldr	x3, [x26, 24]
	ldr	w0, [x20, 4]
	ldr	s15, [x20]
	madd	x0, x0, x3, x2
	ldr	x3, [x0, x1]
	ldr	x1, [sp, 104]
	ldp	x24, x19, [x1]
	ldr	x0, [x1, 16]
	cmp	x19, x0
	beq	.L2348
	str	s15, [x19]
	add	x19, x19, 16
	str	x3, [x19, -8]
	str	x19, [x1, 8]
.L2349:
	sub	x19, x19, x24
	fmov	s0, s15
	mov	x2, 0
	mov	x0, x24
	asr	x1, x19, 4
	sub	x1, x1, #1
	bl	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfmESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	add	x0, sp, 160
	stp	x20, x28, [sp, 160]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x28, [sp, 168]
	sub	x0, x28, x20
	b	.L2347
	.p2align 2,,3
.L2403:
	str	s31, [x19, x2]
	ldr	w2, [x3, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L2470
	asr	x1, x2, 1
	b	.L2310
	.p2align 2,,3
.L2404:
	str	s31, [x20, x2]
	ldr	w2, [x3, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L2471
	asr	x1, x2, 1
	b	.L2324
	.p2align 2,,3
.L2470:
	mov	x0, x3
	b	.L2308
	.p2align 2,,3
.L2305:
	ldr	x0, [sp, 72]
	add	x2, sp, 136
	add	x1, sp, 144
	str	s0, [sp, 8]
	str	x7, [sp, 16]
	str	w5, [sp, 92]
	str	x9, [sp, 96]
	stp	x19, x25, [sp, 224]
	str	x25, [sp, 240]
.LEHB220:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_
.LEHE220:
	ldp	x19, x25, [sp, 224]
	ldr	x0, [sp, 240]
	str	x0, [sp, 48]
	ldr	s0, [sp, 8]
	ldr	x7, [sp, 16]
	sub	x2, x25, x19
	ldr	s30, [x25, -8]
	asr	x1, x2, 3
	ldr	w5, [sp, 92]
	sub	x0, x1, #1
	ldr	w10, [x25, -4]
	ldr	x9, [sp, 96]
	cmp	x0, 0
	bgt	.L2472
.L2307:
	sub	x2, x2, #8
	add	x0, x19, x2
	b	.L2308
.L2321:
	sub	x1, x1, #8
	add	x0, x20, x1
	str	s0, [x20, x1]
	ldr	w1, [sp, 88]
	str	w1, [x0, 4]
	b	.L2362
	.p2align 2,,3
.L2471:
	mov	x0, x3
	b	.L2322
	.p2align 2,,3
.L2402:
	sub	x0, x28, x20
	cmp	x21, x0, asr 3
	bne	.L2295
	mov	x25, x19
	b	.L2294
	.p2align 2,,3
.L2466:
	ldr	x0, [x22, 248]
	str	x7, [sp, 16]
	str	w5, [sp, 92]
	str	s0, [sp, 8]
	ldr	x1, [x9, x0]
	ldr	x0, [sp, 64]
.LEHB221:
	blr	x2
.LEHE221:
	ldr	s0, [sp, 8]
	ldr	x7, [sp, 16]
	ldr	w5, [sp, 92]
	tbz	x0, 0, .L2362
	cmp	x26, x23
	bne	.L2313
.L2467:
	add	x2, sp, 136
	add	x1, sp, 140
	mov	x0, x24
	stp	x20, x26, [sp, 192]
	str	x26, [sp, 208]
.LEHB222:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_
.LEHE222:
	ldp	x20, x26, [sp, 192]
	ldr	x23, [sp, 208]
	ldr	w0, [x26, -4]
	ldr	s0, [x26, -8]
	str	w0, [sp, 88]
	b	.L2318
.L2348:
	sub	x23, x19, x24
	asr	x1, x23, 4
	cmp	x1, x22
	beq	.L2473
	cmp	x1, 0
	str	x3, [sp, 8]
	csinc	x0, x1, xzr, ne
	add	x0, x0, x1
	cmp	x0, x22
	csel	x0, x0, x22, ls
	lsl	x25, x0, 4
	mov	x0, x25
.LEHB223:
	bl	_Znwm
.LEHE223:
	add	x6, x0, x23
	str	s15, [x0, x23]
	ldr	x3, [sp, 8]
	mov	x27, x0
	str	x3, [x6, 8]
	cmp	x24, x19
	beq	.L2377
	mov	x1, x24
	.p2align 5,,15
.L2353:
	ldp	x2, x3, [x1], 16
	stp	x2, x3, [x0], 16
	cmp	x0, x6
	bne	.L2353
	mov	x23, x0
.L2352:
	add	x19, x23, 16
	cbz	x24, .L2354
	mov	x0, x24
	bl	_ZdlPv
.L2354:
	ldr	x1, [sp, 104]
	add	x0, x27, x25
	mov	x24, x27
	stp	x27, x19, [x1]
	ldr	s15, [x23]
	ldr	x3, [x23, 8]
	str	x0, [x1, 16]
	b	.L2349
.L2452:
	ldp	x19, x20, [sp, 288]
	.cfi_remember_state
	.cfi_restore 20
	.cfi_restore 19
	ldp	x23, x24, [sp, 320]
	.cfi_restore 24
	.cfi_restore 23
	ldp	x27, x28, [sp, 352]
	.cfi_restore 28
	.cfi_restore 27
	ldp	d14, d15, [sp, 368]
	.cfi_restore 79
	.cfi_restore 78
	b	.L2225
.L2461:
	.cfi_restore_state
.LEHB224:
	bl	_ZN7hnswlib15VisitedListPool18getFreeVisitedListEv
.LEHE224:
	ldr	x1, [x0, 8]
	uxtw	x3, w23
	str	x3, [sp, 8]
	str	x1, [sp, 24]
	str	x0, [sp, 56]
	ldr	x1, [x26, 232]
	ldrh	w27, [x0]
	ldr	x0, [x26, 24]
	ldp	x5, x2, [x26, 304]
	madd	x0, x3, x0, x1
	ldr	x1, [x26, 256]
	add	x1, x1, x0
	mov	x0, x22
.LEHB225:
	blr	x5
.LEHE225:
	fmov	s15, s0
	mov	x0, 8
.LEHB226:
	bl	_Znwm
.LEHE226:
	mov	x20, x0
	fneg	s14, s15
	add	x28, x0, 8
	mov	x0, 8
	str	w23, [x20, 4]
	str	s15, [x20]
.LEHB227:
	bl	_Znwm
.LEHE227:
	ldr	x3, [sp, 8]
	mov	x19, x0
	add	x6, x0, 8
	mov	x24, x28
	ldr	x0, [sp, 24]
	str	s14, [x19]
	str	w23, [x19, 4]
	add	x25, sp, 192
	str	x6, [sp, 48]
	strh	w27, [x0, x3, lsl 1]
	add	x0, sp, 224
	str	x0, [sp, 64]
	add	x0, sp, 136
	str	x0, [sp, 72]
.L2264:
	fneg	s14, s14
	fcmpe	s14, s15
	bgt	.L2240
	ldr	x0, [sp, 48]
	str	x0, [sp, 240]
	ldr	x0, [sp, 64]
	stp	x19, x6, [sp, 224]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x2, [x26, 24]
	uxtw	x0, w23
	ldr	x1, [x26, 240]
	ldr	x6, [sp, 232]
	madd	x0, x0, x2, x1
	ldr	x1, [x26, 256]
	add	x2, x1, x0
	ldrh	w0, [x1, x0]
	stp	x2, x0, [sp, 32]
	cbz	x0, .L2241
	mov	x23, 1
	b	.L2263
	.p2align 2,,3
.L2371:
	add	x23, x23, 1
.L2263:
	ldp	x2, x0, [sp, 24]
	ldr	w7, [x0, x23, lsl 2]
	str	w7, [sp, 136]
	sbfiz	x0, x7, 1, 32
	ldrh	w1, [x2, x0]
	cmp	w1, w27
	beq	.L2242
	ldr	x1, [x26, 232]
	strh	w27, [x2, x0]
	ldr	x2, [x26, 24]
	uxtw	x0, w7
	str	w7, [sp, 8]
	str	x6, [sp, 16]
	str	w7, [sp, 88]
	madd	x0, x0, x2, x1
	ldr	x1, [x26, 256]
	ldp	x8, x2, [x26, 304]
	add	x1, x1, x0
	mov	x0, x22
.LEHB228:
	blr	x8
.LEHE228:
	sub	x0, x28, x20
	str	s0, [sp, 140]
	ldr	x6, [sp, 16]
	cmp	x21, x0, asr 3
	ldr	w7, [sp, 8]
	bhi	.L2243
	fcmpe	s0, s15
	bmi	.L2243
.L2242:
	ldr	x0, [sp, 40]
	cmp	x0, x23
	bne	.L2371
.L2241:
	cmp	x6, x19
	beq	.L2240
	ldr	s14, [x19]
	ldr	w23, [x19, 4]
	b	.L2264
.L2243:
	fneg	s30, s0
	ldr	x0, [sp, 48]
	str	s30, [sp, 144]
	cmp	x0, x6
	beq	.L2246
	mov	w9, w7
	add	x6, x6, 8
	str	w7, [x6, -4]
	str	s30, [x6, -8]
.L2247:
	sub	x2, x6, x19
	asr	x1, x2, 3
	sub	x0, x1, #1
	cmp	x0, 0
	ble	.L2248
	sub	x1, x1, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L2251:
	lsl	x2, x1, 3
	add	x8, x19, x1, lsl 3
	ldr	s31, [x19, x2]
	lsl	x2, x0, 3
	add	x0, x19, x0, lsl 3
	fcmpe	s30, s31
	bgt	.L2400
.L2249:
	str	s30, [x0]
	str	w9, [x0, 4]
	cmp	x24, x28
	beq	.L2252
.L2476:
	add	x28, x28, 8
	str	w7, [x28, -4]
	str	s0, [x28, -8]
.L2253:
	sub	x1, x28, x20
	asr	x8, x1, 3
	sub	x0, x8, #1
	cmp	x0, 0
	ble	.L2257
	sub	x1, x8, #2
	asr	x1, x1, 1
	.p2align 5,,15
.L2260:
	lsl	x2, x1, 3
	add	x7, x20, x1, lsl 3
	ldr	s31, [x20, x2]
	lsl	x2, x0, 3
	add	x0, x20, x0, lsl 3
	fcmpe	s0, s31
	bgt	.L2401
.L2258:
	ldr	w1, [sp, 88]
	str	w1, [x0, 4]
	str	s0, [x0]
.L2364:
	cmp	x8, x21
	bls	.L2261
	str	x19, [sp, 8]
	mov	x19, x20
	mov	x20, x6
	.p2align 5,,15
.L2262:
	mov	x0, x25
	stp	x19, x28, [sp, 192]
	str	x24, [sp, 208]
	bl	_ZNSt14priority_queueISt4pairIfjESt6vectorIS1_SaIS1_EEN7hnswlib15HierarchicalNSWIfE14CompareByFirstEE3popEv
	ldr	x28, [sp, 200]
	sub	x0, x28, x19
	cmp	x21, x0, asr 3
	bcc	.L2262
	mov	x6, x20
	mov	x20, x19
	ldr	x19, [sp, 8]
.L2261:
	cmp	x20, x28
	beq	.L2242
	ldr	s15, [x20]
	b	.L2242
	.p2align 2,,3
.L2400:
	str	s31, [x19, x2]
	ldr	w2, [x8, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L2474
	asr	x1, x2, 1
	b	.L2251
	.p2align 2,,3
.L2401:
	str	s31, [x20, x2]
	ldr	w2, [x7, 4]
	str	w2, [x0, 4]
	sub	x0, x1, #1
	add	x2, x0, x0, lsr 63
	mov	x0, x1
	cbz	x1, .L2475
	asr	x1, x2, 1
	b	.L2260
.L2474:
	mov	x0, x8
	str	s30, [x0]
	str	w9, [x0, 4]
	cmp	x24, x28
	bne	.L2476
.L2252:
	ldr	x2, [sp, 72]
	add	x1, sp, 140
	mov	x0, x25
	str	x6, [sp, 8]
	stp	x20, x24, [sp, 192]
	str	x24, [sp, 208]
.LEHB229:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJRfRiEEEvDpOT_
.LEHE229:
	ldp	x20, x28, [sp, 192]
	ldr	x6, [sp, 8]
	ldr	x24, [sp, 208]
	ldr	w0, [x28, -4]
	ldr	s0, [x28, -8]
	str	w0, [sp, 88]
	b	.L2253
.L2475:
	mov	x0, x7
	b	.L2258
.L2246:
	ldr	x0, [sp, 48]
	stp	x19, x0, [sp, 224]
	add	x1, sp, 144
	ldr	x2, [sp, 72]
	str	x0, [sp, 240]
	ldr	x0, [sp, 64]
	str	w7, [sp, 8]
	str	s0, [sp, 16]
.LEHB230:
	bl	_ZNSt6vectorISt4pairIfjESaIS1_EE17_M_realloc_appendIJfRiEEEvDpOT_
.LEHE230:
	ldp	x19, x6, [sp, 224]
	ldr	x0, [sp, 240]
	str	x0, [sp, 48]
	ldr	s0, [sp, 16]
	ldr	w7, [sp, 8]
	ldr	s30, [x6, -8]
	ldr	w9, [x6, -4]
	b	.L2247
.L2331:
	add	x24, x19, 16
	ldr	x6, [x19, 72]
	ldp	x3, x22, [x24, 16]
	cmp	x6, 0
	sub	x0, x6, x22
	cset	x6, ne
	sub	x1, x3, x1
	asr	x0, x0, 3
	sub	x0, x0, x6
	ldp	x6, x7, [x19, 48]
	sub	x6, x6, x7
	asr	x6, x6, 3
	add	x0, x6, x0, lsl 6
	add	x0, x0, x1, asr 3
	mov	x1, 1152921504606846975
	cmp	x0, x1
	beq	.L2477
	ldr	x0, [x19]
	cmp	x22, x0
	beq	.L2478
.L2335:
	mov	x0, 512
.LEHB231:
	bl	_Znwm
.LEHE231:
	str	x0, [x22, -8]!
	add	x1, x0, 512
	stp	x0, x1, [x24, 8]
	add	x1, x0, 504
	str	x22, [x24, 24]
	str	x1, [x19, 16]
	ldr	x1, [sp, 120]
	str	x1, [x0, 504]
	b	.L2332
.L2377:
	mov	x23, x0
	b	.L2352
.L2248:
	sub	x2, x2, #8
	add	x0, x19, x2
	b	.L2249
.L2257:
	sub	x1, x1, #8
	add	x0, x20, x1
	str	s0, [x20, x1]
	ldr	w1, [sp, 88]
	str	w1, [x0, 4]
	b	.L2364
.L2240:
	ldr	x21, [x26, 112]
	add	x22, x21, 80
	str	x22, [sp, 144]
	mov	x0, x22
	bl	pthread_mutex_lock
	cbnz	w0, .L2479
	mov	w2, 1
	strb	w2, [sp, 152]
	ldp	x1, x0, [x21, 16]
	cmp	x1, x0
	beq	.L2267
	ldr	x0, [sp, 56]
	str	x0, [x1, -8]!
	str	x1, [x21, 16]
.L2268:
	mov	x0, x22
	bl	pthread_mutex_unlock
	cbz	x19, .L2273
	mov	x0, x19
	bl	_ZdlPv
.L2273:
	str	x24, [sp, 176]
	b	.L2276
.L2462:
	ldr	x0, [x26, 248]
	ldr	x1, [x5, x0]
	ldr	x0, [sp, 64]
.LEHB232:
	blr	x3
.LEHE232:
	tbz	x0, 0, .L2283
	ldr	x0, [x26, 24]
	ldr	x1, [x26, 256]
	mul	x0, x24, x0
	b	.L2284
.L2478:
	mov	x0, x19
	mov	x1, 1
.LEHB233:
	bl	_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb
.LEHE233:
	ldr	x22, [x19, 40]
	b	.L2335
.L2372:
	mov	x23, x28
	b	.L2294
.L2267:
	add	x25, x21, 16
	ldr	x6, [x21, 72]
	ldp	x3, x23, [x25, 16]
	cmp	x6, 0
	sub	x0, x6, x23
	cset	x6, ne
	sub	x1, x3, x1
	asr	x0, x0, 3
	sub	x0, x0, x6
	ldp	x6, x7, [x21, 48]
	sub	x6, x6, x7
	asr	x6, x6, 3
	add	x0, x6, x0, lsl 6
	add	x0, x0, x1, asr 3
	mov	x1, 1152921504606846975
	cmp	x0, x1
	beq	.L2480
	ldr	x0, [x21]
	cmp	x23, x0
	beq	.L2481
.L2271:
	mov	x0, 512
.LEHB234:
	bl	_Znwm
	str	x0, [x23, -8]!
	add	x1, x0, 512
	stp	x0, x1, [x25, 8]
	add	x1, x0, 504
	str	x23, [x25, 24]
	str	x1, [x21, 16]
	ldr	x1, [sp, 56]
	str	x1, [x0, 504]
	b	.L2268
.L2463:
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 27
	.cfi_restore 28
	.cfi_restore 78
	.cfi_restore 79
	stp	x19, x20, [sp, 288]
	.cfi_offset 20, -88
	.cfi_offset 19, -96
	stp	x23, x24, [sp, 320]
	.cfi_offset 24, -56
	.cfi_offset 23, -64
	stp	x27, x28, [sp, 352]
	.cfi_offset 28, -24
	.cfi_offset 27, -32
	stp	d14, d15, [sp, 368]
	.cfi_offset 79, -8
	.cfi_offset 78, -16
.L2457:
	bl	__stack_chk_fail
.L2481:
	mov	x0, x21
	mov	x1, 1
	bl	_ZNSt5dequeIPN7hnswlib11VisitedListESaIS2_EE17_M_reallocate_mapEmb
.LEHE234:
	ldr	x23, [x21, 40]
	b	.L2271
.L2385:
	ldr	x20, [sp, 192]
	mov	x21, x0
	cbz	x19, .L2341
.L2482:
	mov	x0, x19
	bl	_ZdlPv
.L2341:
	cbz	x20, .L2358
.L2455:
	mov	x0, x20
	bl	_ZdlPv
.L2358:
	ldr	x0, [sp, 104]
	ldr	x0, [x0]
	cbz	x0, .L2360
	bl	_ZdlPv
.L2360:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 264]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2457
	mov	x0, x21
.LEHB235:
	bl	_Unwind_Resume
.LEHE235:
.L2384:
	ldr	x19, [sp, 224]
	mov	x21, x0
	cbnz	x19, .L2482
	b	.L2341
.L2389:
	mov	x21, x0
.L2483:
	cbnz	x20, .L2455
	b	.L2358
.L2394:
	mov	x21, x0
	b	.L2358
.L2479:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 264]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	bne	.L2457
.LEHB236:
	bl	_ZSt20__throw_system_errori
.LEHE236:
.L2395:
	mov	x21, x0
	b	.L2358
.L2477:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 264]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2457
	adrp	x0, .LC27
	add	x0, x0, :lo12:.LC27
.LEHB237:
	bl	_ZSt20__throw_length_errorPKc
.LEHE237:
.L2397:
	mov	x21, x0
	b	.L2358
.L2383:
	mov	x21, x0
	add	x0, sp, 144
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	cbz	x25, .L2341
.L2484:
	mov	x0, x25
	bl	_ZdlPv
	cbnz	x20, .L2455
	b	.L2358
.L2390:
	mov	x21, x0
	b	.L2483
.L2381:
	mov	x21, x0
	cbnz	x19, .L2482
	b	.L2341
.L2480:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 264]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2457
	adrp	x0, .LC27
	add	x0, x0, :lo12:.LC27
.LEHB238:
	bl	_ZSt20__throw_length_errorPKc
.LEHE238:
.L2468:
	adrp	x1, :got:__stack_chk_guard
	ldr	x1, [x1, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 264]
	ldr	x2, [x1]
	subs	x3, x3, x2
	mov	x2, 0
	bne	.L2457
.LEHB239:
	bl	_ZSt20__throw_system_errori
.LEHE239:
.L2382:
	mov	x21, x0
	add	x0, sp, 144
	bl	_ZNSt11unique_lockISt5mutexE6unlockEv
	cbnz	x19, .L2482
	b	.L2341
.L2392:
.L2453:
	mov	x21, x0
	mov	x25, x19
	cbnz	x25, .L2484
	b	.L2341
.L2473:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 264]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2457
	adrp	x0, .LC5
	add	x0, x0, :lo12:.LC5
.LEHB240:
	bl	_ZSt20__throw_length_errorPKc
.LEHE240:
.L2460:
	mov	x0, 16
	bl	__cxa_allocate_exception
	adrp	x1, .LC40
	mov	x19, x0
	add	x1, x1, :lo12:.LC40
.LEHB241:
	bl	_ZNSt13runtime_errorC1EPKc
.LEHE241:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 264]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2457
	adrp	x2, :got:_ZNSt13runtime_errorD1Ev
	ldr	x2, [x2, :got_lo12:_ZNSt13runtime_errorD1Ev]
	mov	x0, x19
	adrp	x1, :got:_ZTISt13runtime_error
	ldr	x1, [x1, :got_lo12:_ZTISt13runtime_error]
.LEHB242:
	bl	__cxa_throw
.LEHE242:
.L2380:
	mov	x21, x0
	b	.L2455
.L2391:
	mov	x21, x0
	cbnz	x25, .L2484
	b	.L2341
.L2379:
	mov	x21, x0
	mov	x0, x19
	bl	__cxa_free_exception
	b	.L2358
.L2399:
	mov	x21, x0
	b	.L2358
.L2396:
	mov	x21, x0
	b	.L2358
.L2393:
	b	.L2453
.L2387:
	ldr	x20, [sp, 192]
	mov	x21, x0
	mov	x25, x19
	cbnz	x25, .L2484
	b	.L2341
.L2378:
	mov	x21, x0
	b	.L2358
.L2388:
	mov	x21, x0
	b	.L2358
.L2398:
	mov	x21, x0
	b	.L2358
.L2386:
	ldr	x25, [sp, 224]
	mov	x21, x0
	cbnz	x25, .L2484
	b	.L2341
	.cfi_endproc
.LFE12508:
	.section	.gcc_except_table
.LLSDA12508:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12508-.LLSDACSB12508
.LLSDACSB12508:
	.uleb128 .LEHB213-.LFB12508
	.uleb128 .LEHE213-.LEHB213
	.uleb128 .L2378-.LFB12508
	.uleb128 0
	.uleb128 .LEHB214-.LFB12508
	.uleb128 .LEHE214-.LEHB214
	.uleb128 .L2388-.LFB12508
	.uleb128 0
	.uleb128 .LEHB215-.LFB12508
	.uleb128 .LEHE215-.LEHB215
	.uleb128 .L2396-.LFB12508
	.uleb128 0
	.uleb128 .LEHB216-.LFB12508
	.uleb128 .LEHE216-.LEHB216
	.uleb128 .L2399-.LFB12508
	.uleb128 0
	.uleb128 .LEHB217-.LFB12508
	.uleb128 .LEHE217-.LEHB217
	.uleb128 .L2390-.LFB12508
	.uleb128 0
	.uleb128 .LEHB218-.LFB12508
	.uleb128 .LEHE218-.LEHB218
	.uleb128 .L2398-.LFB12508
	.uleb128 0
	.uleb128 .LEHB219-.LFB12508
	.uleb128 .LEHE219-.LEHB219
	.uleb128 .L2392-.LFB12508
	.uleb128 0
	.uleb128 .LEHB220-.LFB12508
	.uleb128 .LEHE220-.LEHB220
	.uleb128 .L2386-.LFB12508
	.uleb128 0
	.uleb128 .LEHB221-.LFB12508
	.uleb128 .LEHE221-.LEHB221
	.uleb128 .L2393-.LFB12508
	.uleb128 0
	.uleb128 .LEHB222-.LFB12508
	.uleb128 .LEHE222-.LEHB222
	.uleb128 .L2387-.LFB12508
	.uleb128 0
	.uleb128 .LEHB223-.LFB12508
	.uleb128 .LEHE223-.LEHB223
	.uleb128 .L2380-.LFB12508
	.uleb128 0
	.uleb128 .LEHB224-.LFB12508
	.uleb128 .LEHE224-.LEHB224
	.uleb128 .L2388-.LFB12508
	.uleb128 0
	.uleb128 .LEHB225-.LFB12508
	.uleb128 .LEHE225-.LEHB225
	.uleb128 .L2395-.LFB12508
	.uleb128 0
	.uleb128 .LEHB226-.LFB12508
	.uleb128 .LEHE226-.LEHB226
	.uleb128 .L2394-.LFB12508
	.uleb128 0
	.uleb128 .LEHB227-.LFB12508
	.uleb128 .LEHE227-.LEHB227
	.uleb128 .L2389-.LFB12508
	.uleb128 0
	.uleb128 .LEHB228-.LFB12508
	.uleb128 .LEHE228-.LEHB228
	.uleb128 .L2381-.LFB12508
	.uleb128 0
	.uleb128 .LEHB229-.LFB12508
	.uleb128 .LEHE229-.LEHB229
	.uleb128 .L2385-.LFB12508
	.uleb128 0
	.uleb128 .LEHB230-.LFB12508
	.uleb128 .LEHE230-.LEHB230
	.uleb128 .L2384-.LFB12508
	.uleb128 0
	.uleb128 .LEHB231-.LFB12508
	.uleb128 .LEHE231-.LEHB231
	.uleb128 .L2383-.LFB12508
	.uleb128 0
	.uleb128 .LEHB232-.LFB12508
	.uleb128 .LEHE232-.LEHB232
	.uleb128 .L2397-.LFB12508
	.uleb128 0
	.uleb128 .LEHB233-.LFB12508
	.uleb128 .LEHE233-.LEHB233
	.uleb128 .L2383-.LFB12508
	.uleb128 0
	.uleb128 .LEHB234-.LFB12508
	.uleb128 .LEHE234-.LEHB234
	.uleb128 .L2382-.LFB12508
	.uleb128 0
	.uleb128 .LEHB235-.LFB12508
	.uleb128 .LEHE235-.LEHB235
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB236-.LFB12508
	.uleb128 .LEHE236-.LEHB236
	.uleb128 .L2381-.LFB12508
	.uleb128 0
	.uleb128 .LEHB237-.LFB12508
	.uleb128 .LEHE237-.LEHB237
	.uleb128 .L2383-.LFB12508
	.uleb128 0
	.uleb128 .LEHB238-.LFB12508
	.uleb128 .LEHE238-.LEHB238
	.uleb128 .L2382-.LFB12508
	.uleb128 0
	.uleb128 .LEHB239-.LFB12508
	.uleb128 .LEHE239-.LEHB239
	.uleb128 .L2391-.LFB12508
	.uleb128 0
	.uleb128 .LEHB240-.LFB12508
	.uleb128 .LEHE240-.LEHB240
	.uleb128 .L2380-.LFB12508
	.uleb128 0
	.uleb128 .LEHB241-.LFB12508
	.uleb128 .LEHE241-.LEHB241
	.uleb128 .L2379-.LFB12508
	.uleb128 0
	.uleb128 .LEHB242-.LFB12508
	.uleb128 .LEHE242-.LEHB242
	.uleb128 .L2378-.LFB12508
	.uleb128 0
.LLSDACSE12508:
	.section	.text._ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE,"axG",@progbits,_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE,comdat
	.size	_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE, .-_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE
	.section	.text._ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE,"axG",@progbits,_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE,comdat
	.align	2
	.p2align 5,,15
	.weak	_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE
	.type	_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE, %function
_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE:
.LFB12522:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA12522
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	adrp	x4, :got:__stack_chk_guard
	ldr	x4, [x4, :got_lo12:__stack_chk_guard]
	stp	x29, x30, [sp, 64]
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	add	x29, sp, 64
	stp	x19, x20, [sp, 80]
	.cfi_offset 19, -16
	.cfi_offset 20, -8
	mov	x19, x8
	ldr	x5, [x4]
	str	x5, [sp, 56]
	mov	x5, 0
	stp	xzr, xzr, [x8]
	ldr	x4, [x0]
	ldr	x5, [x4, 8]
	adrp	x4, _ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE
	add	x4, x4, :lo12:_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE
	str	xzr, [x8, 16]
	add	x8, sp, 24
	cmp	x5, x4
	bne	.L2486
.LEHB243:
	bl	_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE
.LEHE243:
.L2487:
	ldp	x3, x4, [x19]
	ldp	x0, x8, [sp, 24]
	sub	x1, x4, x3
	sub	x2, x8, x0
	cmp	x2, x1
	bhi	.L2526
	bcc	.L2527
.L2489:
	cmp	x8, x0
	beq	.L2528
.L2492:
	ldr	x9, [x19]
	sub	x2, x2, #16
	add	x9, x9, x2
	b	.L2502
	.p2align 2,,3
.L2495:
	sub	x9, x9, #16
	cmp	x0, x8
	beq	.L2493
.L2502:
	ldr	s31, [x0]
	sub	x1, x8, x0
	ldr	x2, [x0, 8]
	str	x2, [x9, 8]
	str	s31, [x9]
	cmp	x1, 16
	sub	x8, x8, #16
	ble	.L2495
	sub	x1, x8, x0
	ldr	s30, [x8]
	ldr	x3, [x8, 8]
	str	s31, [x8]
	str	x2, [x8, 8]
	asr	x12, x1, 4
	cmp	x1, 32
	ble	.L2509
	sub	x11, x12, #1
	mov	x4, 0
	asr	x11, x11, 1
	b	.L2500
	.p2align 2,,3
.L2511:
	mov	x2, x6
.L2499:
	lsl	x5, x4, 4
	add	x4, x0, x4, lsl 4
	str	s29, [x0, x5]
	str	x2, [x4, 8]
	cmp	x11, x1
	ble	.L2496
.L2512:
	mov	x4, x1
.L2500:
	add	x2, x4, 1
	lsl	x5, x2, 1
	lsl	x2, x2, 5
	sub	x1, x5, #1
	add	x10, x0, x2
	lsl	x6, x1, 4
	ldr	s31, [x0, x2]
	add	x7, x0, x1, lsl 4
	ldr	s29, [x0, x6]
	fcmpe	s29, s31
	bgt	.L2515
	ldr	x2, [x10, 8]
	bmi	.L2510
	ldr	x6, [x7, 8]
	cmp	x6, x2
	bhi	.L2511
.L2510:
	fmov	s29, s31
	mov	x1, x5
	lsl	x5, x4, 4
	add	x4, x0, x4, lsl 4
	str	s29, [x0, x5]
	str	x2, [x4, 8]
	cmp	x11, x1
	bgt	.L2512
.L2496:
	tbnz	x12, 0, .L2501
	sub	x12, x12, #2
	cmp	x1, x12, asr 1
	bne	.L2501
	lsl	x5, x1, 4
	add	x2, x0, x1, lsl 4
	lsl	x1, x1, 1
	add	x1, x1, 1
	lsl	x6, x1, 4
	add	x4, x0, x1, lsl 4
	ldr	s31, [x0, x6]
	ldr	x4, [x4, 8]
	str	s31, [x0, x5]
	str	x4, [x2, 8]
	.p2align 5,,15
.L2501:
	fmov	s0, s30
	mov	x2, 0
	sub	x9, x9, #16
	bl	_ZSt11__push_heapIN9__gnu_cxx17__normal_iteratorIPSt4pairIfmESt6vectorIS3_SaIS3_EEEElS3_NS0_5__ops14_Iter_comp_valISt4lessIS3_EEEEvT_T0_SF_T1_RT2_.isra.0
	cmp	x0, x8
	bne	.L2502
.L2493:
	bl	_ZdlPv
.L2485:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 56]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L2525
	ldp	x29, x30, [sp, 64]
	mov	x0, x19
	ldp	x19, x20, [sp, 80]
	add	sp, sp, 96
	.cfi_remember_state
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L2515:
	.cfi_restore_state
	ldr	x2, [x7, 8]
	b	.L2499
	.p2align 2,,3
.L2527:
	add	x3, x3, x2
	cmp	x4, x3
	beq	.L2489
	str	x3, [x19, 8]
	cmp	x8, x0
	bne	.L2492
.L2528:
	cbz	x0, .L2485
	b	.L2493
	.p2align 2,,3
.L2526:
	asr	x0, x2, 4
	str	x2, [sp, 8]
	sub	x1, x0, x1, asr 4
	mov	x0, x19
.LEHB244:
	bl	_ZNSt6vectorISt4pairIfmESaIS1_EE17_M_default_appendEm
.LEHE244:
	ldr	x2, [sp, 8]
	ldp	x0, x8, [sp, 24]
	b	.L2489
	.p2align 2,,3
.L2509:
	mov	x1, 0
	b	.L2496
.L2486:
.LEHB245:
	blr	x5
.LEHE245:
	b	.L2487
.L2513:
	mov	x1, x0
.L2505:
	ldr	x0, [x19]
	cbnz	x0, .L2529
.L2506:
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 56]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L2507
.L2525:
	bl	__stack_chk_fail
.L2514:
	mov	x20, x0
	ldr	x0, [sp, 24]
	cbz	x0, .L2504
	bl	_ZdlPv
.L2504:
	mov	x1, x20
	b	.L2505
.L2529:
	str	x1, [sp, 8]
	bl	_ZdlPv
	ldr	x1, [sp, 8]
	b	.L2506
.L2507:
	mov	x0, x1
.LEHB246:
	bl	_Unwind_Resume
.LEHE246:
	.cfi_endproc
.LFE12522:
	.section	.gcc_except_table
.LLSDA12522:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE12522-.LLSDACSB12522
.LLSDACSB12522:
	.uleb128 .LEHB243-.LFB12522
	.uleb128 .LEHE243-.LEHB243
	.uleb128 .L2513-.LFB12522
	.uleb128 0
	.uleb128 .LEHB244-.LFB12522
	.uleb128 .LEHE244-.LEHB244
	.uleb128 .L2514-.LFB12522
	.uleb128 0
	.uleb128 .LEHB245-.LFB12522
	.uleb128 .LEHE245-.LEHB245
	.uleb128 .L2513-.LFB12522
	.uleb128 0
	.uleb128 .LEHB246-.LFB12522
	.uleb128 .LEHE246-.LEHB246
	.uleb128 0
	.uleb128 0
.LLSDACSE12522:
	.section	.text._ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE,"axG",@progbits,_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE,comdat
	.size	_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE, .-_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE
	.weak	_ZTSN7hnswlib14SpaceInterfaceIfEE
	.section	.rodata._ZTSN7hnswlib14SpaceInterfaceIfEE,"aG",@progbits,_ZTSN7hnswlib14SpaceInterfaceIfEE,comdat
	.align	3
	.type	_ZTSN7hnswlib14SpaceInterfaceIfEE, %object
	.size	_ZTSN7hnswlib14SpaceInterfaceIfEE, 30
_ZTSN7hnswlib14SpaceInterfaceIfEE:
	.string	"N7hnswlib14SpaceInterfaceIfEE"
	.weak	_ZTIN7hnswlib14SpaceInterfaceIfEE
	.section	.data.rel.ro._ZTIN7hnswlib14SpaceInterfaceIfEE,"awG",@progbits,_ZTIN7hnswlib14SpaceInterfaceIfEE,comdat
	.align	3
	.type	_ZTIN7hnswlib14SpaceInterfaceIfEE, %object
	.size	_ZTIN7hnswlib14SpaceInterfaceIfEE, 16
_ZTIN7hnswlib14SpaceInterfaceIfEE:
	.xword	_ZTVN10__cxxabiv117__class_type_infoE+16
	.xword	_ZTSN7hnswlib14SpaceInterfaceIfEE
	.weak	_ZTSN7hnswlib17InnerProductSpaceE
	.section	.rodata._ZTSN7hnswlib17InnerProductSpaceE,"aG",@progbits,_ZTSN7hnswlib17InnerProductSpaceE,comdat
	.align	3
	.type	_ZTSN7hnswlib17InnerProductSpaceE, %object
	.size	_ZTSN7hnswlib17InnerProductSpaceE, 30
_ZTSN7hnswlib17InnerProductSpaceE:
	.string	"N7hnswlib17InnerProductSpaceE"
	.weak	_ZTIN7hnswlib17InnerProductSpaceE
	.section	.data.rel.ro._ZTIN7hnswlib17InnerProductSpaceE,"awG",@progbits,_ZTIN7hnswlib17InnerProductSpaceE,comdat
	.align	3
	.type	_ZTIN7hnswlib17InnerProductSpaceE, %object
	.size	_ZTIN7hnswlib17InnerProductSpaceE, 24
_ZTIN7hnswlib17InnerProductSpaceE:
	.xword	_ZTVN10__cxxabiv120__si_class_type_infoE+16
	.xword	_ZTSN7hnswlib17InnerProductSpaceE
	.xword	_ZTIN7hnswlib14SpaceInterfaceIfEE
	.weak	_ZTSN7hnswlib18AlgorithmInterfaceIfEE
	.section	.rodata._ZTSN7hnswlib18AlgorithmInterfaceIfEE,"aG",@progbits,_ZTSN7hnswlib18AlgorithmInterfaceIfEE,comdat
	.align	3
	.type	_ZTSN7hnswlib18AlgorithmInterfaceIfEE, %object
	.size	_ZTSN7hnswlib18AlgorithmInterfaceIfEE, 34
_ZTSN7hnswlib18AlgorithmInterfaceIfEE:
	.string	"N7hnswlib18AlgorithmInterfaceIfEE"
	.weak	_ZTIN7hnswlib18AlgorithmInterfaceIfEE
	.section	.data.rel.ro._ZTIN7hnswlib18AlgorithmInterfaceIfEE,"awG",@progbits,_ZTIN7hnswlib18AlgorithmInterfaceIfEE,comdat
	.align	3
	.type	_ZTIN7hnswlib18AlgorithmInterfaceIfEE, %object
	.size	_ZTIN7hnswlib18AlgorithmInterfaceIfEE, 16
_ZTIN7hnswlib18AlgorithmInterfaceIfEE:
	.xword	_ZTVN10__cxxabiv117__class_type_infoE+16
	.xword	_ZTSN7hnswlib18AlgorithmInterfaceIfEE
	.weak	_ZTSN7hnswlib15HierarchicalNSWIfEE
	.section	.rodata._ZTSN7hnswlib15HierarchicalNSWIfEE,"aG",@progbits,_ZTSN7hnswlib15HierarchicalNSWIfEE,comdat
	.align	3
	.type	_ZTSN7hnswlib15HierarchicalNSWIfEE, %object
	.size	_ZTSN7hnswlib15HierarchicalNSWIfEE, 31
_ZTSN7hnswlib15HierarchicalNSWIfEE:
	.string	"N7hnswlib15HierarchicalNSWIfEE"
	.weak	_ZTIN7hnswlib15HierarchicalNSWIfEE
	.section	.data.rel.ro._ZTIN7hnswlib15HierarchicalNSWIfEE,"awG",@progbits,_ZTIN7hnswlib15HierarchicalNSWIfEE,comdat
	.align	3
	.type	_ZTIN7hnswlib15HierarchicalNSWIfEE, %object
	.size	_ZTIN7hnswlib15HierarchicalNSWIfEE, 24
_ZTIN7hnswlib15HierarchicalNSWIfEE:
	.xword	_ZTVN10__cxxabiv120__si_class_type_infoE+16
	.xword	_ZTSN7hnswlib15HierarchicalNSWIfEE
	.xword	_ZTIN7hnswlib18AlgorithmInterfaceIfEE
	.weak	_ZTVN7hnswlib17InnerProductSpaceE
	.section	.data.rel.ro.local._ZTVN7hnswlib17InnerProductSpaceE,"awG",@progbits,_ZTVN7hnswlib17InnerProductSpaceE,comdat
	.align	3
	.type	_ZTVN7hnswlib17InnerProductSpaceE, %object
	.size	_ZTVN7hnswlib17InnerProductSpaceE, 56
_ZTVN7hnswlib17InnerProductSpaceE:
	.xword	0
	.xword	_ZTIN7hnswlib17InnerProductSpaceE
	.xword	_ZN7hnswlib17InnerProductSpace13get_data_sizeEv
	.xword	_ZN7hnswlib17InnerProductSpace13get_dist_funcEv
	.xword	_ZN7hnswlib17InnerProductSpace19get_dist_func_paramEv
	.xword	_ZN7hnswlib17InnerProductSpaceD1Ev
	.xword	_ZN7hnswlib17InnerProductSpaceD0Ev
	.weak	_ZTVN7hnswlib15HierarchicalNSWIfEE
	.section	.data.rel.ro.local._ZTVN7hnswlib15HierarchicalNSWIfEE,"awG",@progbits,_ZTVN7hnswlib15HierarchicalNSWIfEE,comdat
	.align	3
	.type	_ZTVN7hnswlib15HierarchicalNSWIfEE, %object
	.size	_ZTVN7hnswlib15HierarchicalNSWIfEE, 64
_ZTVN7hnswlib15HierarchicalNSWIfEE:
	.xword	0
	.xword	_ZTIN7hnswlib15HierarchicalNSWIfEE
	.xword	_ZN7hnswlib15HierarchicalNSWIfE8addPointEPKvmb
	.xword	_ZNK7hnswlib15HierarchicalNSWIfE9searchKnnEPKvmPNS_17BaseFilterFunctorE
	.xword	_ZNK7hnswlib18AlgorithmInterfaceIfE20searchKnnCloserFirstEPKvmPNS_17BaseFilterFunctorE
	.xword	_ZN7hnswlib15HierarchicalNSWIfE9saveIndexERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE
	.xword	_ZN7hnswlib15HierarchicalNSWIfED1Ev
	.xword	_ZN7hnswlib15HierarchicalNSWIfED0Ev
	.section	.rodata.cst16,"aM",@progbits,16
	.align	4
.LC46:
	.xword	16
	.xword	16
	.align	4
.LC47:
	.xword	32
	.xword	150
	.align	4
.LC48:
	.xword	100
	.xword	101
	.align	4
.LC49:
	.xword	132
	.xword	132
	.section	.rodata
	.align	3
	.set	.LANCHOR0,. + 0
	.type	C.315.0, %object
	.size	C.315.0, 72
C.315.0:
	.xword	100
	.xword	200
	.xword	500
	.xword	1000
	.xword	2000
	.xword	5000
	.xword	10000
	.xword	50000
	.xword	100000
	.hidden	DW.ref.__gxx_personality_v0
	.weak	DW.ref.__gxx_personality_v0
	.section	.data.rel.local.DW.ref.__gxx_personality_v0,"awG",@progbits,DW.ref.__gxx_personality_v0,comdat
	.align	3
	.type	DW.ref.__gxx_personality_v0, %object
	.size	DW.ref.__gxx_personality_v0, 8
DW.ref.__gxx_personality_v0:
	.xword	__gxx_personality_v0
	.global	__aarch64_ldadd8_acq_rel
	.global	__gxx_personality_v0
	.ident	"GCC: (Ubuntu 15.2.0-4ubuntu4) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
