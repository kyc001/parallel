	.arch armv8-a
	.file	"analyze.cc"
	.text
	.align	2
	.global	_Z18ip_distance_serialPKfS0_i
	.type	_Z18ip_distance_serialPKfS0_i, %function
_Z18ip_distance_serialPKfS0_i:
.LFB5574:
	.cfi_startproc
	cmp	w2, 0
	ble	.L4
	sbfiz	x3, x2, 2, 32
	mov	x2, 0
	movi	v30.2s, #0
.L3:
	ldr	s31, [x0, x2]
	ldr	s29, [x1, x2]
	fmul	s31, s31, s29
	fadd	s30, s30, s31
	add	x2, x2, 4
	cmp	x2, x3
	bne	.L3
.L2:
	fmov	s0, 1.0e+0
	fsub	s0, s0, s30
	ret
.L4:
	movi	v30.2s, #0
	b	.L2
	.cfi_endproc
.LFE5574:
	.size	_Z18ip_distance_serialPKfS0_i, .-_Z18ip_distance_serialPKfS0_i
	.align	2
	.global	_Z16ip_distance_simdPKfS0_i
	.type	_Z16ip_distance_simdPKfS0_i, %function
_Z16ip_distance_simdPKfS0_i:
.LFB5576:
	.cfi_startproc
	cmp	w2, 15
	ble	.L11
	mov	x3, x0
	mov	x4, x1
	sub	w5, w2, #16
	lsr	w6, w2, 4
	sub	w6, w6, #1
	add	x7, x0, 64
	add	x6, x7, x6, lsl 6
	movi	v26.4s, 0
	mov	v28.16b, v26.16b
	mov	v27.16b, v26.16b
	mov	v29.16b, v26.16b
.L8:
	ldp	q30, q31, [x3]
	ldp	q24, q25, [x4]
	fmul	v30.4s, v30.4s, v24.4s
	fadd	v29.4s, v29.4s, v30.4s
	fmul	v31.4s, v31.4s, v25.4s
	fadd	v27.4s, v27.4s, v31.4s
	ldp	q30, q31, [x3, 32]
	ldp	q24, q25, [x4, 32]
	fmul	v30.4s, v30.4s, v24.4s
	fadd	v28.4s, v28.4s, v30.4s
	fmul	v31.4s, v31.4s, v25.4s
	fadd	v26.4s, v26.4s, v31.4s
	add	x3, x3, 64
	add	x4, x4, 64
	cmp	x3, x6
	bne	.L8
	and	w3, w5, -16
	add	w3, w3, 16
.L7:
	add	w4, w3, 3
	cmp	w2, w4
	ble	.L9
	sxtw	x3, w3
.L10:
	lsl	x4, x3, 2
	ldr	q31, [x0, x4]
	ldr	q30, [x1, x4]
	fmul	v31.4s, v31.4s, v30.4s
	fadd	v29.4s, v29.4s, v31.4s
	add	x3, x3, 4
	add	w4, w3, 3
	cmp	w2, w4
	bgt	.L10
.L9:
	fadd	v28.4s, v28.4s, v26.4s
	fadd	v29.4s, v29.4s, v27.4s
	fadd	v28.4s, v28.4s, v29.4s
	dup	d0, v28.d[1]
	fadd	v0.2s, v0.2s, v28.2s
	faddp	v0.2s, v0.2s, v0.2s
	fmov	s31, 1.0e+0
	fsub	s0, s31, s0
	ret
.L11:
	mov	w3, 0
	movi	v26.4s, 0
	mov	v28.16b, v26.16b
	mov	v27.16b, v26.16b
	mov	v29.16b, v26.16b
	b	.L7
	.cfi_endproc
.LFE5576:
	.size	_Z16ip_distance_simdPKfS0_i, .-_Z16ip_distance_simdPKfS0_i
	.align	2
	.global	_Z19sq_l2_distance_simdPKhS0_i
	.type	_Z19sq_l2_distance_simdPKhS0_i, %function
_Z19sq_l2_distance_simdPKhS0_i:
.LFB5577:
	.cfi_startproc
	cmp	w2, 0
	ble	.L17
	mov	x3, 0
	movi	v30.4s, 0
.L16:
	ldr	q31, [x0, x3]
	ldr	q29, [x1, x3]
	uabd	v31.16b, v31.16b, v29.16b
	umull	v29.8h, v31.8b, v31.8b
	umull2	v31.8h, v31.16b, v31.16b
	uadalp	v30.4s, v29.8h
	uadalp	v30.4s, v31.8h
	add	x3, x3, 16
	cmp	w2, w3
	bgt	.L16
.L15:
	addv	s31, v30.4s
	fmov	w0, s31
	ret
.L17:
	movi	v30.4s, 0
	b	.L15
	.cfi_endproc
.LFE5577:
	.size	_Z19sq_l2_distance_simdPKhS0_i, .-_Z19sq_l2_distance_simdPKhS0_i
	.align	2
	.global	_Z12adc_distancePKfPKhi
	.type	_Z12adc_distancePKfPKhi, %function
_Z12adc_distancePKfPKhi:
.LFB5578:
	.cfi_startproc
	cmp	w2, 0
	ble	.L22
	sxtw	x4, w2
	mov	x2, 0
	movi	v31.2s, #0
.L21:
	ldrb	w3, [x1, x2]
	add	w3, w3, w2, lsl 8
	ldr	s30, [x0, w3, sxtw 2]
	fadd	s31, s31, s30
	add	x2, x2, 1
	cmp	x2, x4
	bne	.L21
.L20:
	fmov	s0, 1.0e+0
	fsub	s0, s0, s31
	ret
.L22:
	movi	v31.2s, #0
	b	.L20
	.cfi_endproc
.LFE5578:
	.size	_Z12adc_distancePKfPKhi, .-_Z12adc_distancePKfPKhi
	.align	2
	.global	_Z12dot_sub_simdPKfS0_i
	.type	_Z12dot_sub_simdPKfS0_i, %function
_Z12dot_sub_simdPKfS0_i:
.LFB5579:
	.cfi_startproc
	cmp	w2, 0
	ble	.L27
	sub	w3, w2, #1
	lsr	w3, w3, 2
	add	w3, w3, 1
	ubfiz	x3, x3, 4, 31
	mov	x2, 0
	movi	v30.4s, 0
.L26:
	ldr	q31, [x0, x2]
	ldr	q29, [x1, x2]
	fmul	v31.4s, v31.4s, v29.4s
	fadd	v30.4s, v30.4s, v31.4s
	add	x2, x2, 16
	cmp	x2, x3
	bne	.L26
.L25:
	dup	d0, v30.d[1]
	fadd	v0.2s, v0.2s, v30.2s
	faddp	v0.2s, v0.2s, v0.2s
	ret
.L27:
	movi	v30.4s, 0
	b	.L25
	.cfi_endproc
.LFE5579:
	.size	_Z12dot_sub_simdPKfS0_i, .-_Z12dot_sub_simdPKfS0_i
	.align	2
	.global	main
	.type	main, %function
main:
.LFB5580:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	stp	x21, x22, [sp, 32]
	mov	x13, 9168
	sub	sp, sp, x13
	.cfi_def_cfa_offset 9216
	.cfi_offset 19, -32
	.cfi_offset 20, -24
	.cfi_offset 21, -16
	.cfi_offset 22, -8
	str	xzr, [sp, 1024]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 9160]
	mov	x1, 0
	add	x21, sp, 384
	mov	w2, 96
	mov	x1, x21
	mov	x0, sp
	bl	_Z18ip_distance_serialPKfS0_i
	adrp	x19, .LANCHOR0
	add	x22, x19, :lo12:.LANCHOR0
	str	s0, [x19, #:lo12:.LANCHOR0]
	mov	w2, 96
	mov	x1, x21
	mov	x0, sp
	bl	_Z16ip_distance_simdPKfS0_i
	str	s0, [x19, #:lo12:.LANCHOR0]
	mov	w2, 96
	add	x1, sp, 8192
	add	x1, x1, 872
	add	x0, sp, 8192
	add	x0, x0, 776
	bl	_Z19sq_l2_distance_simdPKhS0_i
	str	w0, [x22, 4]
	mov	w2, 8
	add	x1, sp, 8192
	add	x1, x1, 768
	add	x0, sp, 768
	bl	_Z12adc_distancePKfPKhi
	str	s0, [x19, #:lo12:.LANCHOR0]
	mov	w2, 12
	mov	x1, x21
	mov	x0, sp
	bl	_Z12dot_sub_simdPKfS0_i
	str	s0, [x19, #:lo12:.LANCHOR0]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, :got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 9160]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L32
	mov	w0, 0
	mov	x13, 9168
	add	sp, sp, x13
	.cfi_remember_state
	.cfi_def_cfa_offset 48
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
.L32:
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
