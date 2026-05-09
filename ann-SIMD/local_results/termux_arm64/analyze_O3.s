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
	ble	.L6
	sub	w3, w2, #1
	cmp	w3, 2
	bls	.L7
	lsr	w4, w2, 2
	movi	v31.2s, #0
	mov	x3, 0
	lsl	x4, x4, 4
	.p2align 5,,15
.L4:
	ldr	q17, [x0, x3]
	ldr	q6, [x1, x3]
	add	x3, x3, 16
	fmul	v6.4s, v17.4s, v6.4s
	fadd	s31, s31, s6
	dup	s16, v6.s[1]
	dup	s7, v6.s[2]
	dup	s6, v6.s[3]
	fadd	s31, s31, s16
	fadd	s31, s31, s7
	fadd	s31, s31, s6
	cmp	x3, x4
	bne	.L4
	and	w3, w2, -4
	cmp	w2, w3
	beq	.L5
.L3:
	ubfiz	x4, x3, 2, 32
	add	w5, w3, 1
	ldr	s5, [x0, x4]
	ldr	s4, [x1, x4]
	fmadd	s31, s5, s4, s31
	cmp	w2, w5
	ble	.L5
	add	x5, x4, 4
	add	w3, w3, 2
	ldr	s3, [x0, x5]
	ldr	s2, [x1, x5]
	fmadd	s31, s3, s2, s31
	cmp	w2, w3
	ble	.L5
	add	x4, x4, 8
	ldr	s30, [x1, x4]
	ldr	s1, [x0, x4]
	fmadd	s31, s30, s1, s31
.L5:
	fmov	s29, 1.0e+0
	fsub	s0, s29, s31
	ret
	.p2align 2,,3
.L6:
	fmov	s0, 1.0e+0
	ret
.L7:
	movi	v31.2s, #0
	mov	w3, 0
	b	.L3
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
	ble	.L15
	movi	v31.4s, 0
	lsr	w5, w2, 4
	add	x7, x0, 64
	sub	w5, w5, #1
	mov	w8, 64
	mov	x3, x0
	mov	x4, x1
	sub	w6, w2, #16
	mov	v0.16b, v31.16b
	umaddl	x5, w5, w8, x7
	mov	v29.16b, v31.16b
	mov	v28.16b, v31.16b
	.p2align 5,,15
.L12:
	ldp	q20, q18, [x3]
	ldp	q19, q17, [x4]
	ldp	q16, q6, [x3, 32]
	add	x3, x3, 64
	ldp	q7, q5, [x4, 32]
	add	x4, x4, 64
	fmul	v19.4s, v20.4s, v19.4s
	fmul	v17.4s, v18.4s, v17.4s
	fmul	v7.4s, v16.4s, v7.4s
	fmul	v5.4s, v6.4s, v5.4s
	fadd	v28.4s, v28.4s, v19.4s
	fadd	v29.4s, v29.4s, v17.4s
	fadd	v0.4s, v0.4s, v7.4s
	fadd	v31.4s, v31.4s, v5.4s
	cmp	x3, x5
	bne	.L12
	and	w3, w6, -16
	add	w4, w3, 16
	add	w3, w3, 19
.L11:
	cmp	w2, w3
	ble	.L13
	ubfiz	x3, x4, 2, 32
	add	w5, w4, 7
	ldr	q4, [x0, x3]
	ldr	q3, [x1, x3]
	fmul	v3.4s, v4.4s, v3.4s
	fadd	v28.4s, v28.4s, v3.4s
	cmp	w2, w5
	ble	.L13
	add	x5, x3, 16
	add	w4, w4, 11
	ldr	q2, [x0, x5]
	ldr	q1, [x1, x5]
	fmul	v1.4s, v2.4s, v1.4s
	fadd	v28.4s, v28.4s, v1.4s
	cmp	w4, w2
	bge	.L13
	add	x3, x3, 32
	ldr	q27, [x0, x3]
	ldr	q26, [x1, x3]
	fmul	v26.4s, v27.4s, v26.4s
	fadd	v28.4s, v28.4s, v26.4s
.L13:
	fadd	v0.4s, v0.4s, v31.4s
	fadd	v28.4s, v28.4s, v29.4s
	fmov	s31, 1.0e+0
	fadd	v28.4s, v0.4s, v28.4s
	dup	d30, v28.d[1]
	fadd	v30.2s, v30.2s, v28.2s
	faddp	v30.2s, v30.2s, v30.2s
	fsub	s0, s31, s30
	ret
	.p2align 2,,3
.L15:
	movi	v31.4s, 0
	mov	w3, 3
	mov	w4, 0
	mov	v0.16b, v31.16b
	mov	v29.16b, v31.16b
	mov	v28.16b, v31.16b
	b	.L11
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
	ble	.L20
	movi	v30.4s, 0
	mov	x3, 0
	.p2align 5,,15
.L19:
	ldr	q0, [x0, x3]
	ldr	q28, [x1, x3]
	add	x3, x3, 16
	uabd	v28.16b, v0.16b, v28.16b
	umull	v29.8h, v28.8b, v28.8b
	umull2	v28.8h, v28.16b, v28.16b
	uadalp	v30.4s, v29.8h
	uadalp	v30.4s, v28.8h
	cmp	w2, w3
	bgt	.L19
	addv	s31, v30.4s
	fmov	w0, s31
	ret
	.p2align 2,,3
.L20:
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
	ble	.L25
	movi	v31.2s, #0
	sxtw	x2, w2
	mov	x3, 0
	.p2align 5,,15
.L24:
	ldrb	w4, [x1, x3]
	add	w4, w4, w3, lsl 8
	add	x3, x3, 1
	ldr	s1, [x0, x4, lsl 2]
	fadd	s31, s31, s1
	cmp	x2, x3
	bne	.L24
	fmov	s30, 1.0e+0
	fsub	s0, s30, s31
	ret
	.p2align 2,,3
.L25:
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
	ble	.L30
	sub	w2, w2, #1
	mov	x3, 0
	movi	v30.4s, 0
	lsr	w2, w2, 2
	add	w2, w2, 1
	ubfiz	x2, x2, 4, 31
	.p2align 5,,15
.L29:
	ldr	q31, [x0, x3]
	ldr	q29, [x1, x3]
	add	x3, x3, 16
	fmul	v31.4s, v31.4s, v29.4s
	fadd	v30.4s, v30.4s, v31.4s
	cmp	x2, x3
	bne	.L29
	dup	d0, v30.d[1]
	fadd	v0.2s, v0.2s, v30.2s
	faddp	v0.2s, v0.2s, v0.2s
	ret
	.p2align 2,,3
.L30:
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
	add	x1, sp, 384
	adrp	x2, :got:__stack_chk_guard
	ldr	x2, [x2, :got_lo12:__stack_chk_guard]
	movi	v30.2s, #0
	mov	x0, sp
	add	x4, x1, 384
	ldr	x3, [x2]
	str	x3, [sp, 9160]
	mov	x3, 0
	mov	x2, x1
	mov	x3, sp
	.p2align 5,,15
.L33:
	ldr	q29, [x3], 16
	ldr	q31, [x2], 16
	fmul	v31.4s, v31.4s, v29.4s
	dup	s28, v31.s[1]
	fadd	s30, s30, s31
	dup	s29, v31.s[2]
	dup	s31, v31.s[3]
	fadd	s30, s28, s30
	fadd	s30, s29, s30
	fadd	s30, s30, s31
	cmp	x2, x4
	bne	.L33
	fmov	s25, 1.0e+0
	adrp	x9, .LANCHOR0
	mov	w2, 96
	mov	x11, 9128
	fsub	s30, s25, s30
	mov	x12, 9048
	mov	x13, 9144
	add	x10, x9, :lo12:.LANCHOR0
	str	s30, [x9, #:lo12:.LANCHOR0]
	bl	_Z16ip_distance_simdPKfS0_i
	mov	x0, 8968
	add	x0, sp, x0
	mov	x1, 9064
	mov	x2, 8984
	movi	v26.2s, #0
	ldr	s30, [sp, 776]
	ldr	q29, [x0]
	add	x0, sp, x1
	mov	x3, 9080
	ldr	s23, [sp, 1800]
	fadd	s30, s30, s26
	mov	x4, 9000
	ldr	q31, [x0]
	add	x0, sp, x2
	ldr	s17, [sp, 2824]
	mov	x5, 9096
	fadd	s30, s30, s23
	ldr	s18, [sp, 3848]
	uabd	v29.16b, v29.16b, v31.16b
	mov	x6, 9016
	ldr	q28, [x0]
	add	x0, sp, x3
	ldr	s19, [sp, 4872]
	mov	x7, 9112
	umull	v31.8h, v29.8b, v29.8b
	ldr	s20, [sp, 5896]
	ldr	q24, [x0]
	add	x0, sp, x4
	umull2	v26.8h, v29.16b, v29.16b
	mov	x8, 9032
	uaddlp	v29.4s, v31.8h
	ldr	s21, [sp, 6920]
	uabd	v28.16b, v28.16b, v24.16b
	str	s0, [x9, #:lo12:.LANCHOR0]
	ldr	q27, [x0]
	add	x0, sp, x5
	uadalp	v29.4s, v26.8h
	umull	v23.8h, v28.8b, v28.8b
	fadd	s31, s30, s17
	ldr	q22, [x0]
	add	x0, sp, x6
	umull2	v24.8h, v28.16b, v28.16b
	uadalp	v29.4s, v23.8h
	uabd	v27.16b, v27.16b, v22.16b
	ldr	s22, [sp, 7944]
	fadd	s31, s31, s18
	ldr	q28, [x0]
	add	x0, sp, x7
	umull	v23.8h, v27.8b, v27.8b
	uadalp	v29.4s, v24.8h
	ldr	q30, [x0]
	fadd	s31, s31, s19
	umull2	v26.8h, v27.16b, v27.16b
	add	x0, sp, x8
	uadalp	v29.4s, v23.8h
	uabd	v30.16b, v28.16b, v30.16b
	fadd	s31, s31, s20
	ldr	q27, [x0]
	add	x0, sp, x11
	umull	v24.8h, v30.8b, v30.8b
	uadalp	v29.4s, v26.8h
	ldr	q28, [x0]
	fadd	s31, s31, s21
	ldr	q2, [sp, 384]
	add	x0, sp, x12
	umull2	v26.8h, v30.16b, v30.16b
	uabd	v27.16b, v27.16b, v28.16b
	ldp	q3, q1, [sp]
	fadd	s31, s31, s22
	uadalp	v29.4s, v24.8h
	movi	v4.4s, 0
	fmul	v2.4s, v3.4s, v2.4s
	fsub	s25, s25, s31
	uadalp	v29.4s, v26.8h
	ldp	q30, q31, [sp, 400]
	umull	v26.8h, v27.8b, v27.8b
	ldr	q28, [x0]
	add	x0, sp, x13
	ldr	q0, [sp, 32]
	ldr	q24, [x0]
	umull2	v27.8h, v27.16b, v27.16b
	fadd	v2.4s, v4.4s, v2.4s
	uadalp	v29.4s, v26.8h
	fmul	v30.4s, v1.4s, v30.4s
	uabd	v28.16b, v28.16b, v24.16b
	fmul	v31.4s, v0.4s, v31.4s
	uadalp	v29.4s, v27.8h
	fadd	v30.4s, v2.4s, v30.4s
	umull	v27.8h, v28.8b, v28.8b
	umull2	v28.8h, v28.16b, v28.16b
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	fadd	v31.4s, v30.4s, v31.4s
	mov	v30.16b, v29.16b
	dup	d29, v31.d[1]
	uadalp	v30.4s, v27.8h
	fadd	v29.2s, v29.2s, v31.2s
	uadalp	v30.4s, v28.8h
	faddp	v29.2s, v29.2s, v29.2s
	addv	s30, v30.4s
	str	s30, [x10, 4]
	str	s25, [x9, #:lo12:.LANCHOR0]
	str	s29, [x9, #:lo12:.LANCHOR0]
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
