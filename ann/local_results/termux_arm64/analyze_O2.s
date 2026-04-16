	.arch armv8-a
	.file	"analyze.cc"
	.text
	.align	2
	.p2align 5,,15
	.global	_Z18ip_distance_serialPKfS0_i
	.type	_Z18ip_distance_serialPKfS0_i, %function
_Z18ip_distance_serialPKfS0_i:
.LFB5574:
	.cfi_startproc
	cmp	w2, 0
	ble	.L4
	movi	v31.2s, #0
	ubfiz	x2, x2, 2, 32
	mov	x3, 0
	.p2align 5,,15
.L3:
	ldr	s30, [x0, x3]
	ldr	s1, [x1, x3]
	add	x3, x3, 4
	fmadd	s31, s30, s1, s31
	cmp	x2, x3
	bne	.L3
	fmov	s29, 1.0e+0
	fsub	s0, s29, s31
	ret
	.p2align 2,,3
.L4:
	fmov	s0, 1.0e+0
	ret
	.cfi_endproc
.LFE5574:
	.size	_Z18ip_distance_serialPKfS0_i, .-_Z18ip_distance_serialPKfS0_i
	.align	2
	.p2align 5,,15
	.global	_Z16ip_distance_simdPKfS0_i
	.type	_Z16ip_distance_simdPKfS0_i, %function
_Z16ip_distance_simdPKfS0_i:
.LFB5576:
	.cfi_startproc
	cmp	w2, 15
	ble	.L12
	movi	v31.4s, 0
	lsr	w5, w2, 4
	sub	w5, w5, #1
	add	x7, x0, 64
	mov	w8, 64
	mov	x3, x0
	mov	x4, x1
	sub	w6, w2, #16
	mov	v0.16b, v31.16b
	umaddl	x5, w5, w8, x7
	mov	v29.16b, v31.16b
	mov	v28.16b, v31.16b
	.p2align 5,,15
.L9:
	ldp	q16, q6, [x3]
	ldp	q7, q5, [x4]
	ldp	q4, q2, [x3, 32]
	add	x3, x3, 64
	ldp	q3, q1, [x4, 32]
	add	x4, x4, 64
	fmul	v7.4s, v16.4s, v7.4s
	fmul	v5.4s, v6.4s, v5.4s
	fmul	v3.4s, v4.4s, v3.4s
	fmul	v1.4s, v2.4s, v1.4s
	fadd	v28.4s, v28.4s, v7.4s
	fadd	v29.4s, v29.4s, v5.4s
	fadd	v0.4s, v0.4s, v3.4s
	fadd	v31.4s, v31.4s, v1.4s
	cmp	x3, x5
	bne	.L9
	and	w4, w6, -16
	add	w3, w4, 16
	add	w4, w4, 19
.L8:
	cmp	w2, w4
	ble	.L10
	sxtw	x3, w3
.L11:
	lsl	x4, x3, 2
	add	x3, x3, 4
	ldr	q27, [x0, x4]
	ldr	q26, [x1, x4]
	add	w4, w3, 3
	fmul	v26.4s, v27.4s, v26.4s
	fadd	v28.4s, v28.4s, v26.4s
	cmp	w4, w2
	blt	.L11
.L10:
	fadd	v0.4s, v0.4s, v31.4s
	fadd	v28.4s, v28.4s, v29.4s
	fadd	v28.4s, v0.4s, v28.4s
	fmov	s0, 1.0e+0
	dup	d30, v28.d[1]
	fadd	v30.2s, v30.2s, v28.2s
	faddp	v30.2s, v30.2s, v30.2s
	fsub	s0, s0, s30
	ret
	.p2align 2,,3
.L12:
	movi	v31.4s, 0
	mov	w4, 3
	mov	w3, 0
	mov	v0.16b, v31.16b
	mov	v29.16b, v31.16b
	mov	v28.16b, v31.16b
	b	.L8
	.cfi_endproc
.LFE5576:
	.size	_Z16ip_distance_simdPKfS0_i, .-_Z16ip_distance_simdPKfS0_i
	.align	2
	.p2align 5,,15
	.global	_Z19sq_l2_distance_simdPKhS0_i
	.type	_Z19sq_l2_distance_simdPKhS0_i, %function
_Z19sq_l2_distance_simdPKhS0_i:
.LFB5577:
	.cfi_startproc
	cmp	w2, 0
	ble	.L18
	movi	v30.4s, 0
	mov	x3, 0
	.p2align 5,,15
.L17:
	ldr	q0, [x0, x3]
	ldr	q28, [x1, x3]
	add	x3, x3, 16
	uabd	v28.16b, v0.16b, v28.16b
	umull	v29.8h, v28.8b, v28.8b
	umull2	v28.8h, v28.16b, v28.16b
	uadalp	v30.4s, v29.8h
	uadalp	v30.4s, v28.8h
	cmp	w2, w3
	bgt	.L17
	addv	s31, v30.4s
	fmov	w0, s31
	ret
	.p2align 2,,3
.L18:
	movi	v31.2d, #0
	fmov	w0, s31
	ret
	.cfi_endproc
.LFE5577:
	.size	_Z19sq_l2_distance_simdPKhS0_i, .-_Z19sq_l2_distance_simdPKhS0_i
	.align	2
	.p2align 5,,15
	.global	_Z12adc_distancePKfPKhi
	.type	_Z12adc_distancePKfPKhi, %function
_Z12adc_distancePKfPKhi:
.LFB5578:
	.cfi_startproc
	cmp	w2, 0
	ble	.L23
	movi	v31.2s, #0
	sxtw	x2, w2
	mov	x3, 0
	.p2align 5,,15
.L22:
	ldrb	w4, [x1, x3]
	add	w4, w4, w3, lsl 8
	add	x3, x3, 1
	ldr	s1, [x0, x4, lsl 2]
	fadd	s31, s31, s1
	cmp	x2, x3
	bne	.L22
	fmov	s30, 1.0e+0
	fsub	s0, s30, s31
	ret
	.p2align 2,,3
.L23:
	fmov	s0, 1.0e+0
	ret
	.cfi_endproc
.LFE5578:
	.size	_Z12adc_distancePKfPKhi, .-_Z12adc_distancePKfPKhi
	.align	2
	.p2align 5,,15
	.global	_Z12dot_sub_simdPKfS0_i
	.type	_Z12dot_sub_simdPKfS0_i, %function
_Z12dot_sub_simdPKfS0_i:
.LFB5579:
	.cfi_startproc
	cmp	w2, 0
	ble	.L28
	movi	v30.4s, 0
	sub	w3, w2, #1
	mov	x2, 0
	lsr	w3, w3, 2
	add	w3, w3, 1
	ubfiz	x3, x3, 4, 31
	.p2align 5,,15
.L27:
	ldr	q31, [x0, x2]
	ldr	q29, [x1, x2]
	add	x2, x2, 16
	fmul	v31.4s, v31.4s, v29.4s
	fadd	v30.4s, v30.4s, v31.4s
	cmp	x3, x2
	bne	.L27
	dup	d0, v30.d[1]
	fadd	v0.2s, v0.2s, v30.2s
	faddp	v0.2s, v0.2s, v0.2s
	ret
	.p2align 2,,3
.L28:
	movi	v0.2s, 0
	faddp	v0.2s, v0.2s, v0.2s
	ret
	.cfi_endproc
.LFE5579:
	.size	_Z12dot_sub_simdPKfS0_i, .-_Z12dot_sub_simdPKfS0_i
	.section	.text.startup,"ax",@progbits
	.align	2
	.p2align 5,,15
	.global	main
	.type	main, %function
main:
.LFB5580:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x13, 9168
	mov	x29, sp
	sub	sp, sp, x13
	.cfi_def_cfa_offset 9184
	str	xzr, [sp, 1024]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	movi	v30.2s, #0
	mov	x10, sp
	mov	x3, sp
	ldr	x1, [x0]
	str	x1, [sp, 9160]
	mov	x1, 0
	mov	x0, sp
	add	x1, sp, 384
	mov	x9, x1
	add	x4, x1, 384
	mov	x2, x1
	.p2align 5,,15
.L31:
	ldr	q29, [x2], 16
	ldr	q31, [x3], 16
	fmul	v31.4s, v31.4s, v29.4s
	dup	s29, v31.s[1]
	fadd	s30, s30, s31
	fadd	s30, s30, s29
	dup	s29, v31.s[2]
	dup	s31, v31.s[3]
	fadd	s30, s30, s29
	fadd	s30, s30, s31
	cmp	x2, x4
	bne	.L31
	fmov	s31, 1.0e+0
	adrp	x11, .LANCHOR0
	mov	w2, 96
	add	x12, x11, :lo12:.LANCHOR0
	fsub	s31, s31, s30
	str	s31, [x11, #:lo12:.LANCHOR0]
	bl	_Z16ip_distance_simdPKfS0_i
	mov	x3, 8968
	mov	x0, 9064
	mov	x4, 8960
	add	x1, sp, x0
	str	s0, [x11, #:lo12:.LANCHOR0]
	add	x0, sp, x3
	bl	_Z19sq_l2_distance_simdPKhS0_i
	add	x1, sp, x4
	mov	w2, 8
	str	w0, [x12, 4]
	add	x0, sp, 768
	bl	_Z12adc_distancePKfPKhi
	movi	v30.4s, 0
	mov	w0, 0
	str	s0, [x11, #:lo12:.LANCHOR0]
	.p2align 5,,15
.L32:
	ldr	q31, [x10], 16
	add	w0, w0, 4
	ldr	q29, [x9], 16
	fmul	v31.4s, v31.4s, v29.4s
	fadd	v30.4s, v30.4s, v31.4s
	cmp	w0, 12
	bne	.L32
	dup	d31, v30.d[1]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	fadd	v31.2s, v31.2s, v30.2s
	faddp	v31.2s, v31.2s, v31.2s
	str	s31, [x11, #:lo12:.LANCHOR0]
	ldr	x2, [sp, 9160]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L37
	mov	x13, 9168
	add	sp, sp, x13
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	mov	w0, 0
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
.L37:
	.cfi_restore_state
	bl	__stack_chk_fail
	.cfi_endproc
.LFE5580:
	.size	main, .-main
	.global	usink
	.global	sink
	.bss
	.align	2
	.set	.LANCHOR0,. + 0
	.type	sink, %object
	.size	sink, 4
sink:
	.zero	4
	.type	usink, %object
	.size	usink, 4
usink:
	.zero	4
	.ident	"GCC: (Ubuntu 15.2.0-4ubuntu4) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
