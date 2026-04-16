	.arch armv8-a
	.file	"analyze.cc"
	.text
	.section	.rodata
	.align	3
	.type	_ZStL6ignore, %object
	.size	_ZStL6ignore, 1
_ZStL6ignore:
	.zero	1
	.align	3
	.type	_ZStL19piecewise_construct, %object
	.size	_ZStL19piecewise_construct, 1
_ZStL19piecewise_construct:
	.zero	1
	.align	3
	.type	_ZStL13allocator_arg, %object
	.size	_ZStL13allocator_arg, 1
_ZStL13allocator_arg:
	.zero	1
	.text
	.align	2
	.global	_Z18ip_distance_serialPKfS0_i
	.type	_Z18ip_distance_serialPKfS0_i, %function
_Z18ip_distance_serialPKfS0_i:
.LFB5534:
	.cfi_startproc
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	str	w2, [sp, 12]
	str	wzr, [sp, 40]
	str	wzr, [sp, 44]
	b	.L2
.L3:
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	ldr	s30, [x0]
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 16]
	add	x0, x1, x0
	ldr	s31, [x0]
	fmul	s31, s30, s31
	ldr	s30, [sp, 40]
	fadd	s31, s30, s31
	str	s31, [sp, 40]
	ldr	w0, [sp, 44]
	add	w0, w0, 1
	str	w0, [sp, 44]
.L2:
	ldr	w1, [sp, 44]
	ldr	w0, [sp, 12]
	cmp	w1, w0
	blt	.L3
	fmov	s30, 1.0e+0
	ldr	s31, [sp, 40]
	fsub	s31, s30, s31
	fmov	s0, s31
	add	sp, sp, 48
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE5534:
	.size	_Z18ip_distance_serialPKfS0_i, .-_Z18ip_distance_serialPKfS0_i
	.section	.text._Z18horizontal_sum_f3213__Float32x4_t,"axG",@progbits,_Z18horizontal_sum_f3213__Float32x4_t,comdat
	.align	2
	.weak	_Z18horizontal_sum_f3213__Float32x4_t
	.type	_Z18horizontal_sum_f3213__Float32x4_t, %function
_Z18horizontal_sum_f3213__Float32x4_t:
.LFB5535:
	.cfi_startproc
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x29, x30, [sp, 80]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 80
	str	q0, [sp]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 72]
	mov	x1, 0
	ldr	d30, [sp]
	ldr	d31, [sp, 8]
	str	d30, [sp, 56]
	str	d31, [sp, 64]
	ldr	d30, [sp, 56]
	ldr	d31, [sp, 64]
	fadd	v31.2s, v30.2s, v31.2s
	str	d31, [sp, 24]
	ldr	d31, [sp, 24]
	str	d31, [sp, 40]
	ldr	d31, [sp, 24]
	str	d31, [sp, 48]
	ldr	d31, [sp, 40]
	ldr	d30, [sp, 48]
	faddp	v31.2s, v31.2s, v30.2s
	nop
	str	d31, [sp, 32]
	ldr	d31, [sp, 32]
	str	d31, [sp, 16]
	ldr	s31, [sp, 16]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 72]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	beq	.L10
	bl	__stack_chk_fail
.L10:
	fmov	s0, s31
	ldp	x29, x30, [sp, 80]
	add	sp, sp, 96
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE5535:
	.size	_Z18horizontal_sum_f3213__Float32x4_t, .-_Z18horizontal_sum_f3213__Float32x4_t
	.text
	.align	2
	.global	_Z16ip_distance_simdPKfS0_i
	.type	_Z16ip_distance_simdPKfS0_i, %function
_Z16ip_distance_simdPKfS0_i:
.LFB5536:
	.cfi_startproc
	sub	sp, sp, #576
	.cfi_def_cfa_offset 576
	stp	x29, x30, [sp]
	.cfi_offset 29, -576
	.cfi_offset 30, -568
	mov	x29, sp
	str	x0, [sp, 40]
	str	x1, [sp, 32]
	str	w2, [sp, 28]
	str	wzr, [sp, 76]
	ldr	s31, [sp, 76]
	dup	v31.4s, v31.s[0]
	str	q31, [sp, 160]
	str	wzr, [sp, 72]
	ldr	s31, [sp, 72]
	dup	v31.4s, v31.s[0]
	str	q31, [sp, 176]
	str	wzr, [sp, 68]
	ldr	s31, [sp, 68]
	dup	v31.4s, v31.s[0]
	str	q31, [sp, 192]
	str	wzr, [sp, 64]
	ldr	s31, [sp, 64]
	dup	v31.4s, v31.s[0]
	str	q31, [sp, 208]
	str	wzr, [sp, 60]
	b	.L16
.L29:
	ldrsw	x0, [sp, 60]
	lsl	x0, x0, 2
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	str	x0, [sp, 136]
	ldr	x0, [sp, 136]
	ldr	q30, [x0]
	nop
	ldrsw	x0, [sp, 60]
	lsl	x0, x0, 2
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	str	x0, [sp, 128]
	ldr	x0, [sp, 128]
	ldr	q31, [x0]
	nop
	ldr	q29, [sp, 160]
	str	q29, [sp, 384]
	str	q30, [sp, 400]
	str	q31, [sp, 416]
	ldr	q30, [sp, 384]
	ldr	q29, [sp, 400]
	ldr	q31, [sp, 416]
	fmul	v31.4s, v29.4s, v31.4s
	fadd	v31.4s, v30.4s, v31.4s
	nop
	str	q31, [sp, 160]
	ldrsw	x0, [sp, 60]
	add	x0, x0, 4
	lsl	x0, x0, 2
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	str	x0, [sp, 120]
	ldr	x0, [sp, 120]
	ldr	q30, [x0]
	nop
	ldrsw	x0, [sp, 60]
	add	x0, x0, 4
	lsl	x0, x0, 2
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	str	x0, [sp, 112]
	ldr	x0, [sp, 112]
	ldr	q31, [x0]
	nop
	ldr	q29, [sp, 176]
	str	q29, [sp, 336]
	str	q30, [sp, 352]
	str	q31, [sp, 368]
	ldr	q30, [sp, 336]
	ldr	q29, [sp, 352]
	ldr	q31, [sp, 368]
	fmul	v31.4s, v29.4s, v31.4s
	fadd	v31.4s, v30.4s, v31.4s
	nop
	str	q31, [sp, 176]
	ldrsw	x0, [sp, 60]
	add	x0, x0, 8
	lsl	x0, x0, 2
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	str	x0, [sp, 104]
	ldr	x0, [sp, 104]
	ldr	q30, [x0]
	nop
	ldrsw	x0, [sp, 60]
	add	x0, x0, 8
	lsl	x0, x0, 2
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	str	x0, [sp, 96]
	ldr	x0, [sp, 96]
	ldr	q31, [x0]
	nop
	ldr	q29, [sp, 192]
	str	q29, [sp, 288]
	str	q30, [sp, 304]
	str	q31, [sp, 320]
	ldr	q30, [sp, 288]
	ldr	q29, [sp, 304]
	ldr	q31, [sp, 320]
	fmul	v31.4s, v29.4s, v31.4s
	fadd	v31.4s, v30.4s, v31.4s
	nop
	str	q31, [sp, 192]
	ldrsw	x0, [sp, 60]
	add	x0, x0, 12
	lsl	x0, x0, 2
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	str	x0, [sp, 88]
	ldr	x0, [sp, 88]
	ldr	q30, [x0]
	nop
	ldrsw	x0, [sp, 60]
	add	x0, x0, 12
	lsl	x0, x0, 2
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	str	x0, [sp, 80]
	ldr	x0, [sp, 80]
	ldr	q31, [x0]
	nop
	ldr	q29, [sp, 208]
	str	q29, [sp, 240]
	str	q30, [sp, 256]
	str	q31, [sp, 272]
	ldr	q30, [sp, 240]
	ldr	q29, [sp, 256]
	ldr	q31, [sp, 272]
	fmul	v31.4s, v29.4s, v31.4s
	fadd	v31.4s, v30.4s, v31.4s
	nop
	str	q31, [sp, 208]
	ldr	w0, [sp, 60]
	add	w0, w0, 16
	str	w0, [sp, 60]
.L16:
	ldr	w0, [sp, 60]
	add	w0, w0, 15
	ldr	w1, [sp, 28]
	cmp	w1, w0
	bgt	.L29
	b	.L30
.L34:
	ldrsw	x0, [sp, 60]
	lsl	x0, x0, 2
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	str	x0, [sp, 152]
	ldr	x0, [sp, 152]
	ldr	q30, [x0]
	nop
	ldrsw	x0, [sp, 60]
	lsl	x0, x0, 2
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	str	x0, [sp, 144]
	ldr	x0, [sp, 144]
	ldr	q31, [x0]
	nop
	ldr	q29, [sp, 160]
	str	q29, [sp, 432]
	str	q30, [sp, 448]
	str	q31, [sp, 464]
	ldr	q30, [sp, 432]
	ldr	q29, [sp, 448]
	ldr	q31, [sp, 464]
	fmul	v31.4s, v29.4s, v31.4s
	fadd	v31.4s, v30.4s, v31.4s
	nop
	str	q31, [sp, 160]
	ldr	w0, [sp, 60]
	add	w0, w0, 4
	str	w0, [sp, 60]
.L30:
	ldr	w0, [sp, 60]
	add	w0, w0, 3
	ldr	w1, [sp, 28]
	cmp	w1, w0
	bgt	.L34
	ldr	q31, [sp, 160]
	str	q31, [sp, 544]
	ldr	q31, [sp, 176]
	str	q31, [sp, 560]
	ldr	q30, [sp, 544]
	ldr	q31, [sp, 560]
	fadd	v29.4s, v30.4s, v31.4s
	ldr	q31, [sp, 192]
	str	q31, [sp, 512]
	ldr	q31, [sp, 208]
	str	q31, [sp, 528]
	ldr	q30, [sp, 512]
	ldr	q31, [sp, 528]
	fadd	v31.4s, v30.4s, v31.4s
	str	q29, [sp, 480]
	str	q31, [sp, 496]
	ldr	q30, [sp, 480]
	ldr	q31, [sp, 496]
	fadd	v31.4s, v30.4s, v31.4s
	str	q31, [sp, 224]
	ldr	q0, [sp, 224]
	bl	_Z18horizontal_sum_f3213__Float32x4_t
	fmov	s30, s0
	fmov	s31, 1.0e+0
	fsub	s31, s31, s30
	fmov	s0, s31
	ldp	x29, x30, [sp]
	add	sp, sp, 576
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE5536:
	.size	_Z16ip_distance_simdPKfS0_i, .-_Z16ip_distance_simdPKfS0_i
	.align	2
	.global	_Z19sq_l2_distance_simdPKhS0_i
	.type	_Z19sq_l2_distance_simdPKhS0_i, %function
_Z19sq_l2_distance_simdPKhS0_i:
.LFB5537:
	.cfi_startproc
	sub	sp, sp, #304
	.cfi_def_cfa_offset 304
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	str	w2, [sp, 12]
	str	wzr, [sp, 44]
	ldr	s31, [sp, 44]
	dup	v31.4s, v31.s[0]
	str	q31, [sp, 96]
	str	wzr, [sp, 40]
	b	.L41
.L49:
	ldrsw	x0, [sp, 40]
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	str	x0, [sp, 88]
	ldr	x0, [sp, 88]
	ldr	q31, [x0]
	nop
	str	q31, [sp, 112]
	ldrsw	x0, [sp, 40]
	ldr	x1, [sp, 16]
	add	x0, x1, x0
	str	x0, [sp, 80]
	ldr	x0, [sp, 80]
	ldr	q31, [x0]
	nop
	str	q31, [sp, 128]
	ldr	q31, [sp, 112]
	str	q31, [sp, 256]
	ldr	q31, [sp, 128]
	str	q31, [sp, 272]
	ldr	q30, [sp, 256]
	ldr	q31, [sp, 272]
	uabd	v31.16b, v30.16b, v31.16b
	nop
	str	q31, [sp, 144]
	ldr	d30, [sp, 144]
	ldr	d31, [sp, 144]
	str	d30, [sp, 64]
	str	d31, [sp, 72]
	ldr	d30, [sp, 64]
	ldr	d31, [sp, 72]
	umull	v31.8h, v30.8b, v31.8b
	nop
	str	q31, [sp, 160]
	ldr	d30, [sp, 152]
	ldr	d31, [sp, 152]
	str	d30, [sp, 48]
	str	d31, [sp, 56]
	ldr	d30, [sp, 48]
	ldr	d31, [sp, 56]
	umull	v31.8h, v30.8b, v31.8b
	nop
	str	q31, [sp, 176]
	ldr	q31, [sp, 96]
	str	q31, [sp, 224]
	ldr	q31, [sp, 160]
	str	q31, [sp, 240]
	ldr	q31, [sp, 224]
	ldr	q30, [sp, 240]
	uadalp	v31.4s, v30.8h
	nop
	str	q31, [sp, 96]
	ldr	q31, [sp, 96]
	str	q31, [sp, 192]
	ldr	q31, [sp, 176]
	str	q31, [sp, 208]
	ldr	q31, [sp, 192]
	ldr	q30, [sp, 208]
	uadalp	v31.4s, v30.8h
	nop
	str	q31, [sp, 96]
	ldr	w0, [sp, 40]
	add	w0, w0, 16
	str	w0, [sp, 40]
.L41:
	ldr	w1, [sp, 40]
	ldr	w0, [sp, 12]
	cmp	w1, w0
	blt	.L49
	ldr	q31, [sp, 96]
	str	q31, [sp, 288]
	ldr	q31, [sp, 288]
	addv	s31, v31.4s
	nop
	fmov	w0, s31
	add	sp, sp, 304
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE5537:
	.size	_Z19sq_l2_distance_simdPKhS0_i, .-_Z19sq_l2_distance_simdPKhS0_i
	.align	2
	.global	_Z12adc_distancePKfPKhi
	.type	_Z12adc_distancePKfPKhi, %function
_Z12adc_distancePKfPKhi:
.LFB5538:
	.cfi_startproc
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	str	w2, [sp, 12]
	str	wzr, [sp, 40]
	str	wzr, [sp, 44]
	b	.L53
.L54:
	ldr	w0, [sp, 44]
	lsl	w0, w0, 8
	ldrsw	x1, [sp, 44]
	ldr	x2, [sp, 16]
	add	x1, x2, x1
	ldrb	w1, [x1]
	add	w0, w0, w1
	sxtw	x0, w0
	lsl	x0, x0, 2
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	ldr	s31, [x0]
	ldr	s30, [sp, 40]
	fadd	s31, s30, s31
	str	s31, [sp, 40]
	ldr	w0, [sp, 44]
	add	w0, w0, 1
	str	w0, [sp, 44]
.L53:
	ldr	w1, [sp, 44]
	ldr	w0, [sp, 12]
	cmp	w1, w0
	blt	.L54
	fmov	s30, 1.0e+0
	ldr	s31, [sp, 40]
	fsub	s31, s30, s31
	fmov	s0, s31
	add	sp, sp, 48
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE5538:
	.size	_Z12adc_distancePKfPKhi, .-_Z12adc_distancePKfPKhi
	.align	2
	.global	_Z12dot_sub_simdPKfS0_i
	.type	_Z12dot_sub_simdPKfS0_i, %function
_Z12dot_sub_simdPKfS0_i:
.LFB5539:
	.cfi_startproc
	stp	x29, x30, [sp, -144]!
	.cfi_def_cfa_offset 144
	.cfi_offset 29, -144
	.cfi_offset 30, -136
	mov	x29, sp
	str	x0, [sp, 40]
	str	x1, [sp, 32]
	str	w2, [sp, 28]
	str	wzr, [sp, 60]
	ldr	s31, [sp, 60]
	dup	v31.4s, v31.s[0]
	str	q31, [sp, 80]
	str	wzr, [sp, 56]
	b	.L58
.L62:
	ldrsw	x0, [sp, 56]
	lsl	x0, x0, 2
	ldr	x1, [sp, 40]
	add	x0, x1, x0
	str	x0, [sp, 72]
	ldr	x0, [sp, 72]
	ldr	q30, [x0]
	nop
	ldrsw	x0, [sp, 56]
	lsl	x0, x0, 2
	ldr	x1, [sp, 32]
	add	x0, x1, x0
	str	x0, [sp, 64]
	ldr	x0, [sp, 64]
	ldr	q31, [x0]
	nop
	ldr	q29, [sp, 80]
	str	q29, [sp, 96]
	str	q30, [sp, 112]
	str	q31, [sp, 128]
	ldr	q30, [sp, 96]
	ldr	q29, [sp, 112]
	ldr	q31, [sp, 128]
	fmul	v31.4s, v29.4s, v31.4s
	fadd	v31.4s, v30.4s, v31.4s
	nop
	str	q31, [sp, 80]
	ldr	w0, [sp, 56]
	add	w0, w0, 4
	str	w0, [sp, 56]
.L58:
	ldr	w1, [sp, 56]
	ldr	w0, [sp, 28]
	cmp	w1, w0
	blt	.L62
	ldr	q0, [sp, 80]
	bl	_Z18horizontal_sum_f3213__Float32x4_t
	fmov	s31, s0
	fmov	s0, s31
	ldp	x29, x30, [sp], 144
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE5539:
	.size	_Z12dot_sub_simdPKfS0_i, .-_Z12dot_sub_simdPKfS0_i
	.global	sink
	.bss
	.align	2
	.type	sink, %object
	.size	sink, 4
sink:
	.zero	4
	.global	usink
	.align	2
	.type	usink, %object
	.size	usink, 4
usink:
	.zero	4
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB5540:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	mov	x13, 9168
	sub	sp, sp, x13
	.cfi_def_cfa_offset 9184
	str	xzr, [sp, 1024]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 9160]
	mov	x1, 0
	add	x1, sp, 384
	mov	x0, sp
	mov	w2, 96
	bl	_Z18ip_distance_serialPKfS0_i
	fmov	s31, s0
	adrp	x0, sink
	add	x0, x0, :lo12:sink
	str	s31, [x0]
	add	x1, sp, 384
	mov	x0, sp
	mov	w2, 96
	bl	_Z16ip_distance_simdPKfS0_i
	fmov	s31, s0
	adrp	x0, sink
	add	x0, x0, :lo12:sink
	str	s31, [x0]
	add	x1, sp, 8192
	add	x1, x1, 872
	add	x0, sp, 8192
	add	x0, x0, 776
	mov	w2, 96
	bl	_Z19sq_l2_distance_simdPKhS0_i
	mov	w1, w0
	adrp	x0, usink
	add	x0, x0, :lo12:usink
	str	w1, [x0]
	add	x1, sp, 8192
	add	x1, x1, 768
	add	x0, sp, 768
	mov	w2, 8
	bl	_Z12adc_distancePKfPKhi
	fmov	s31, s0
	adrp	x0, sink
	add	x0, x0, :lo12:sink
	str	s31, [x0]
	add	x1, sp, 384
	mov	x0, sp
	mov	w2, 12
	bl	_Z12dot_sub_simdPKfS0_i
	fmov	s31, s0
	adrp	x0, sink
	add	x0, x0, :lo12:sink
	str	s31, [x0]
	mov	w0, 0
	mov	w1, w0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 9160]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L66
	bl	__stack_chk_fail
.L66:
	mov	w0, w1
	mov	x13, 9168
	add	sp, sp, x13
	.cfi_def_cfa_offset 16
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE5540:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 15.2.0-4ubuntu4) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
