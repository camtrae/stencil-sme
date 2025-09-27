	.build_version macos, 15, 0	sdk_version 15, 5
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_matmul_cpu                     ; -- Begin function matmul_cpu
	.p2align	2
_matmul_cpu:                            ; @matmul_cpu
	.cfi_startproc
; %bb.0:
	cbz	x3, LBB0_22
; %bb.1:
	stp	x24, x23, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w22, -32
	.cfi_offset w23, -40
	.cfi_offset w24, -48
	mov	x8, #0                          ; =0x0
	cmp	x4, #3
	ccmp	x5, #1, #0, hi
	cset	w9, eq
	and	x10, x4, #0xfffffffffffffff0
	and	x11, x4, #0xc
	and	x12, x4, #0xfffffffffffffffc
	add	x13, x0, #32
	lsl	x14, x4, #2
	add	x15, x1, #32
	neg	x16, x12
	lsl	x17, x5, #2
	b	LBB0_3
LBB0_2:                                 ;   in Loop: Header=BB0_3 Depth=1
	add	x8, x8, #1
	add	x13, x13, x14
	add	x0, x0, x14
	cmp	x8, x3
	b.eq	LBB0_21
LBB0_3:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_7 Depth 2
                                        ;       Child Loop BB0_13 Depth 3
                                        ;       Child Loop BB0_17 Depth 3
                                        ;       Child Loop BB0_20 Depth 3
	cbz	x5, LBB0_2
; %bb.4:                                ;   in Loop: Header=BB0_3 Depth=1
	mov	x6, #0                          ; =0x0
	mul	x7, x8, x5
	add	x7, x2, x7, lsl #2
	mov	x19, x1
	mov	x20, x15
	b	LBB0_7
LBB0_5:                                 ;   in Loop: Header=BB0_7 Depth=2
	movi	d0, #0000000000000000
LBB0_6:                                 ;   in Loop: Header=BB0_7 Depth=2
	str	s0, [x7, x6, lsl #2]
	add	x6, x6, #1
	add	x20, x20, #4
	add	x19, x19, #4
	cmp	x6, x5
	b.eq	LBB0_2
LBB0_7:                                 ;   Parent Loop BB0_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB0_13 Depth 3
                                        ;       Child Loop BB0_17 Depth 3
                                        ;       Child Loop BB0_20 Depth 3
	cbz	x4, LBB0_5
; %bb.8:                                ;   in Loop: Header=BB0_7 Depth=2
	tbz	w9, #0, LBB0_11
; %bb.9:                                ;   in Loop: Header=BB0_7 Depth=2
	cmp	x4, #16
	b.hs	LBB0_12
; %bb.10:                               ;   in Loop: Header=BB0_7 Depth=2
	mov	x22, #0                         ; =0x0
	movi	d0, #0000000000000000
	b	LBB0_16
LBB0_11:                                ;   in Loop: Header=BB0_7 Depth=2
	mov	x21, #0                         ; =0x0
	movi	d0, #0000000000000000
	b	LBB0_19
LBB0_12:                                ;   in Loop: Header=BB0_7 Depth=2
	movi	d0, #0000000000000000
	mov	x21, x20
	mov	x22, x13
	mov	x23, x10
LBB0_13:                                ;   Parent Loop BB0_3 Depth=1
                                        ;     Parent Loop BB0_7 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldp	q1, q2, [x22, #-32]
	ldp	q3, q4, [x22], #64
	ldp	q5, q6, [x21, #-32]
	ldp	q7, q16, [x21], #64
	fmul.4s	v1, v1, v5
	mov	s5, v1[3]
	mov	s17, v1[2]
	mov	s18, v1[1]
	fmul.4s	v2, v2, v6
	mov	s6, v2[3]
	mov	s19, v2[2]
	mov	s20, v2[1]
	fmul.4s	v3, v3, v7
	mov	s7, v3[3]
	mov	s21, v3[2]
	mov	s22, v3[1]
	fmul.4s	v4, v4, v16
	mov	s16, v4[3]
	mov	s23, v4[2]
	mov	s24, v4[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s18
	fadd	s0, s0, s17
	fadd	s0, s0, s5
	fadd	s0, s0, s2
	fadd	s0, s0, s20
	fadd	s0, s0, s19
	fadd	s0, s0, s6
	fadd	s0, s0, s3
	fadd	s0, s0, s22
	fadd	s0, s0, s21
	fadd	s0, s0, s7
	fadd	s0, s0, s4
	fadd	s0, s0, s24
	fadd	s0, s0, s23
	fadd	s0, s0, s16
	subs	x23, x23, #16
	b.ne	LBB0_13
; %bb.14:                               ;   in Loop: Header=BB0_7 Depth=2
	cmp	x4, x10
	b.eq	LBB0_6
; %bb.15:                               ;   in Loop: Header=BB0_7 Depth=2
	mov	x21, x10
	mov	x22, x10
	cbz	x11, LBB0_19
LBB0_16:                                ;   in Loop: Header=BB0_7 Depth=2
	add	x21, x16, x22
	lsl	x23, x22, #2
	add	x22, x19, x23
	add	x23, x0, x23
LBB0_17:                                ;   Parent Loop BB0_3 Depth=1
                                        ;     Parent Loop BB0_7 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	q1, [x23], #16
	ldr	q2, [x22], #16
	fmul.4s	v1, v1, v2
	mov	s2, v1[3]
	mov	s3, v1[2]
	mov	s4, v1[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s4
	fadd	s0, s0, s3
	fadd	s0, s0, s2
	adds	x21, x21, #4
	b.ne	LBB0_17
; %bb.18:                               ;   in Loop: Header=BB0_7 Depth=2
	mov	x21, x12
	cmp	x4, x12
	b.eq	LBB0_6
LBB0_19:                                ;   in Loop: Header=BB0_7 Depth=2
	mul	x22, x17, x21
LBB0_20:                                ;   Parent Loop BB0_3 Depth=1
                                        ;     Parent Loop BB0_7 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	s1, [x0, x21, lsl #2]
	ldr	s2, [x19, x22]
	fmadd	s0, s1, s2, s0
	add	x21, x21, #1
	add	x22, x22, x17
	cmp	x4, x21
	b.ne	LBB0_20
	b	LBB0_6
LBB0_21:
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #48             ; 16-byte Folded Reload
LBB0_22:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_preprocess_left_matrix_cpu     ; -- Begin function preprocess_left_matrix_cpu
	.p2align	2
_preprocess_left_matrix_cpu:            ; @preprocess_left_matrix_cpu
	.cfi_startproc
; %bb.0:
	cbz	x2, LBB1_15
; %bb.1:
	stp	x22, x21, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w22, -32
	mov	x8, #0                          ; =0x0
	mul	x9, x4, x3
	lsl	x9, x9, #2
	mul	x10, x4, x4
	lsl	x10, x10, #2
	lsl	x11, x4, #2
	lsl	x12, x3, #2
	b	LBB1_3
LBB1_2:                                 ;   in Loop: Header=BB1_3 Depth=1
	add	x1, x1, x9
	add	x0, x0, x9
	add	x8, x8, x4
	cmp	x8, x2
	b.hs	LBB1_14
LBB1_3:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_6 Depth 2
                                        ;       Child Loop BB1_9 Depth 3
                                        ;         Child Loop BB1_10 Depth 4
	cbz	x3, LBB1_2
; %bb.4:                                ;   in Loop: Header=BB1_3 Depth=1
	mov	x13, #0                         ; =0x0
	mov	x14, x0
	mov	x15, x1
	b	LBB1_6
LBB1_5:                                 ;   in Loop: Header=BB1_6 Depth=2
	add	x15, x15, x10
	add	x14, x14, x11
	add	x13, x13, x4
	cmp	x13, x3
	b.hs	LBB1_2
LBB1_6:                                 ;   Parent Loop BB1_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB1_9 Depth 3
                                        ;         Child Loop BB1_10 Depth 4
	cbz	x4, LBB1_5
; %bb.7:                                ;   in Loop: Header=BB1_6 Depth=2
	mov	x16, #0                         ; =0x0
	mov	x17, x14
	mov	x5, x15
	b	LBB1_9
LBB1_8:                                 ;   in Loop: Header=BB1_9 Depth=3
	add	x16, x16, #1
	add	x5, x5, #4
	add	x17, x17, x12
	cmp	x16, x4
	b.eq	LBB1_5
LBB1_9:                                 ;   Parent Loop BB1_3 Depth=1
                                        ;     Parent Loop BB1_6 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB1_10 Depth 4
	add	x6, x16, x8
	mov	x7, x17
	mov	w19, #1                         ; =0x1
	mov	x20, x5
LBB1_10:                                ;   Parent Loop BB1_3 Depth=1
                                        ;     Parent Loop BB1_6 Depth=2
                                        ;       Parent Loop BB1_9 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	movi	d0, #0000000000000000
	cmp	x6, x2
	b.hs	LBB1_12
; %bb.11:                               ;   in Loop: Header=BB1_10 Depth=4
	ldr	s0, [x7]
LBB1_12:                                ;   in Loop: Header=BB1_10 Depth=4
	str	s0, [x20]
	cmp	x19, x4
	b.hs	LBB1_8
; %bb.13:                               ;   in Loop: Header=BB1_10 Depth=4
	add	x21, x13, x19
	add	x20, x20, x11
	add	x19, x19, #1
	add	x7, x7, #4
	cmp	x21, x3
	b.lo	LBB1_10
	b	LBB1_8
LBB1_14:
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp], #32             ; 16-byte Folded Reload
LBB1_15:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_preprocess_left_matrix_sme_kernel ; -- Begin function preprocess_left_matrix_sme_kernel
	.p2align	2
_preprocess_left_matrix_sme_kernel:     ; @preprocess_left_matrix_sme_kernel
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #144
	stp	x28, x27, [sp, #48]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #64]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #80]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #96]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #112]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #128]            ; 16-byte Folded Spill
	.cfi_def_cfa_offset 144
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	stp	x0, x1, [sp, #32]               ; 16-byte Folded Spill
	str	x2, [sp, #16]                   ; 8-byte Folded Spill
	cbz	x2, LBB2_10
; %bb.1:
	str	xzr, [sp, #24]                  ; 8-byte Folded Spill
	mov	x9, #0                          ; =0x0
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	add	x8, x8, x4
	sub	x8, x8, #1
	udiv	x8, x8, x4
	mov	w10, #12                        ; =0xc
	mul	x12, x4, x3
	lsl	x11, x4, #1
	lsl	x13, x12, #2
	stp	x13, x12, [sp]                  ; 16-byte Folded Spill
	lsl	x2, x4, #3
	lsl	x14, x3, #4
	mul	x15, x4, x4
	mul	x16, x12, x8
	ldp	x12, x8, [sp, #32]              ; 16-byte Folded Reload
	add	x0, x12, x3, lsl #3
	add	x5, x12, x3, lsl #2
	add	x1, x8, x15, lsl #2
	lsl	x7, x15, #3
	lsl	x19, x4, #4
	madd	x10, x3, x10, x12
	lsl	x21, x15, #1
	lsl	x22, x4, #2
	b	LBB2_3
LBB2_2:                                 ;   in Loop: Header=BB2_3 Depth=1
	ldp	x13, x12, [sp]                  ; 16-byte Folded Reload
	add	x10, x10, x13
	add	x0, x0, x13
	add	x5, x5, x13
	ldr	x8, [sp, #32]                   ; 8-byte Folded Reload
	add	x8, x8, x13
	str	x8, [sp, #32]                   ; 8-byte Folded Spill
	add	x1, x1, x13
	ldr	x8, [sp, #24]                   ; 8-byte Folded Reload
	add	x8, x8, x12
	str	x8, [sp, #24]                   ; 8-byte Folded Spill
	ldr	x8, [sp, #40]                   ; 8-byte Folded Reload
	add	x8, x8, x13
	str	x8, [sp, #40]                   ; 8-byte Folded Spill
	add	x9, x9, x4
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	cmp	x9, x8
	b.hs	LBB2_10
LBB2_3:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB2_5 Depth 2
                                        ;       Child Loop BB2_6 Depth 3
                                        ;       Child Loop BB2_8 Depth 3
	cbz	x3, LBB2_2
; %bb.4:                                ;   in Loop: Header=BB2_3 Depth=1
	mov	x23, #0                         ; =0x0
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	whilelo	p0.s, x9, x8
	ldp	x27, x24, [sp, #32]             ; 16-byte Folded Reload
	ldr	x8, [sp, #24]                   ; 8-byte Folded Reload
	mov	x6, x1
	mov	x28, x5
	mov	x30, x0
	mov	x20, x10
LBB2_5:                                 ;   Parent Loop BB2_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB2_6 Depth 3
                                        ;       Child Loop BB2_8 Depth 3
	mov	x12, #0                         ; =0x0
	mov	x13, #0                         ; =0x0
	whilelo	pn8.s, x23, x3, vlx2
	mov	p1.b, p8.b
LBB2_6:                                 ;   Parent Loop BB2_3 Depth=1
                                        ;     Parent Loop BB2_5 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	psel	pn8, p1, p0.s[w13, 0]
	psel	p3, p1, p0.s[w13, 1]
	psel	p4, p1, p0.s[w13, 2]
	psel	p5, p1, p0.s[w13, 3]
	add	x25, x27, x12
	ld1w	{ z16.s, z24.s }, pn8/z, [x25]
	add	x25, x28, x12
	mov	p8.b, p3.b
	ld1w	{ z17.s, z25.s }, pn8/z, [x25]
	add	x25, x30, x12
	mov	p8.b, p4.b
	ld1w	{ z18.s, z26.s }, pn8/z, [x25]
	add	x25, x20, x12
	mov	p8.b, p5.b
	ld1w	{ z19.s, z27.s }, pn8/z, [x25]
	mov	z0.d, z16.d
	mov	z1.d, z17.d
	mov	z2.d, z18.d
	mov	z3.d, z19.d
	mov	za0h.s[w13, 0:3], { z0.s - z3.s }
	mov	za1h.s[w13, 0:3], { z24.s - z27.s }
	add	x13, x13, #4
	add	x12, x12, x14
	cmp	x13, x4
	b.lo	LBB2_6
; %bb.7:                                ;   in Loop: Header=BB2_5 Depth=2
	mov	x12, #0                         ; =0x0
	mov	x13, x24
	mov	x25, x8
	mov	x26, x6
LBB2_8:                                 ;   Parent Loop BB2_3 Depth=1
                                        ;     Parent Loop BB2_5 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	whilelo	pn8.s, x25, x16, vlx4
	add	x17, x15, x25
	whilelo	pn9.s, x17, x16, vlx4
	mov	{ z0.s - z3.s }, za0v.s[w12, 0:3]
	mov	{ z4.s - z7.s }, za1v.s[w12, 0:3]
	add	x12, x12, #4
	st1w	{ z0.s - z3.s }, pn8, [x13]
	st1w	{ z4.s - z7.s }, pn9, [x26]
	add	x26, x26, x19
	add	x25, x25, x22
	add	x13, x13, x19
	cmp	x12, x4
	b.lo	LBB2_8
; %bb.9:                                ;   in Loop: Header=BB2_5 Depth=2
	add	x20, x20, x2
	add	x30, x30, x2
	add	x28, x28, x2
	add	x27, x27, x2
	add	x6, x6, x7
	add	x8, x8, x21
	add	x24, x24, x7
	add	x23, x23, x11
	cmp	x23, x3
	b.lo	LBB2_5
	b	LBB2_2
LBB2_10:
	ldp	x29, x30, [sp, #128]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #112]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #96]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #80]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #64]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #144
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_matmul_sme_kernel              ; -- Begin function matmul_sme_kernel
	.p2align	2
_matmul_sme_kernel:                     ; @matmul_sme_kernel
	.cfi_startproc
; %bb.0:
	cbz	x3, LBB3_13
; %bb.1:
	stp	x24, x23, [sp, #-48]!           ; 16-byte Folded Spill
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w22, -32
	.cfi_offset w23, -40
	.cfi_offset w24, -48
	mov	x8, #0                          ; =0x0
	mov	x9, #0                          ; =0x0
	lsl	x10, x6, #2
	lsl	x11, x5, #2
	mul	x12, x6, x4
	lsl	x21, x12, #2
	mul	x12, x6, x5
	lsl	x24, x12, #2
	lsl	x14, x5, #4
	add	x15, x2, x11
	add	x16, x2, x5, lsl #3
	mov	w12, #12                        ; =0xc
	madd	x17, x5, x12, x2
	b	LBB3_3
LBB3_2:                                 ;   in Loop: Header=BB3_3 Depth=1
	add	x0, x0, x21
	add	x8, x8, x24
	add	x9, x9, x6
	cmp	x9, x3
	b.hs	LBB3_12
LBB3_3:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB3_6 Depth 2
                                        ;       Child Loop BB3_7 Depth 3
                                        ;       Child Loop BB3_10 Depth 3
	cbz	x5, LBB3_2
; %bb.4:                                ;   in Loop: Header=BB3_3 Depth=1
	mov	x7, #0                          ; =0x0
	whilelo	p0.s, x9, x3
	mov	x19, x8
	mov	x20, x1
	b	LBB3_6
LBB3_5:                                 ;   in Loop: Header=BB3_6 Depth=2
	add	x20, x20, x10
	add	x19, x19, x10
	add	x7, x7, x6
	cmp	x7, x5
	b.hs	LBB3_2
LBB3_6:                                 ;   Parent Loop BB3_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB3_7 Depth 3
                                        ;       Child Loop BB3_10 Depth 3
	whilelo	p1.s, x7, x5
	zero	{za}
	mov	x12, x0
	mov	x22, x20
	mov	x23, x4
	cbz	x4, LBB3_8
LBB3_7:                                 ;   Parent Loop BB3_3 Depth=1
                                        ;     Parent Loop BB3_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld1w	{ z0.s }, p0/z, [x12]
	ld1w	{ z1.s }, p1/z, [x22]
	fmopa	za0.s, p0/m, p1/m, z0.s, z1.s
	add	x22, x22, x11
	add	x12, x12, x10
	subs	x23, x23, #1
	b.ne	LBB3_7
LBB3_8:                                 ;   in Loop: Header=BB3_6 Depth=2
	cbz	x6, LBB3_5
; %bb.9:                                ;   in Loop: Header=BB3_6 Depth=2
	mov	x12, #0                         ; =0x0
	mov	x22, x19
LBB3_10:                                ;   Parent Loop BB3_3 Depth=1
                                        ;     Parent Loop BB3_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	add	x23, x9, x12
	cmp	x23, x3
	b.hs	LBB3_5
; %bb.11:                               ;   in Loop: Header=BB3_10 Depth=3
	add	w13, w9, w12
	psel	p2, p1, p0.s[w13, 0]
	psel	p3, p1, p0.s[w13, 1]
	psel	p4, p1, p0.s[w13, 2]
	psel	p5, p1, p0.s[w13, 3]
	add	x13, x2, x22
	st1w	{za0h.s[w12, 0]}, p2, [x13]
	add	x13, x15, x22
	st1w	{za0h.s[w12, 1]}, p3, [x13]
	add	x13, x16, x22
	st1w	{za0h.s[w12, 2]}, p4, [x13]
	add	x13, x17, x22
	st1w	{za0h.s[w12, 3]}, p5, [x13]
	add	x22, x22, x14
	add	x12, x12, #4
	cmp	x12, x6
	b.lo	LBB3_10
	b	LBB3_5
LBB3_12:
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #48             ; 16-byte Folded Reload
LBB3_13:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_matmul_sme_kernel_4tiles       ; -- Begin function matmul_sme_kernel_4tiles
	.p2align	2
_matmul_sme_kernel_4tiles:              ; @matmul_sme_kernel_4tiles
	.cfi_startproc
; %bb.0:
	stp	x28, x27, [sp, #-96]!           ; 16-byte Folded Spill
	stp	x26, x25, [sp, #16]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #32]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #48]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	sub	sp, sp, #192
	addvl	sp, sp, #-1
	.cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0xa0, 0x02, 0x22, 0x11, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 ; sp + 288 + 8 * VG
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	stp	x4, x0, [sp, #72]               ; 16-byte Folded Spill
	str	x1, [sp, #16]                   ; 8-byte Folded Spill
	cbz	x3, LBB4_24
; %bb.1:
	mov	x9, #0                          ; =0x0
	lsl	x8, x6, #1
	str	x8, [sp, #64]                   ; 8-byte Folded Spill
	add	x8, x8, x6
	lsl	x30, x6, #2
	str	x8, [sp, #56]                   ; 8-byte Folded Spill
	lsl	x25, x8, #2
	lsl	x8, x6, #4
	stp	xzr, x8, [sp, #40]              ; 16-byte Folded Spill
	lsl	x27, x5, #2
	lsl	x16, x6, #3
	ldr	x8, [sp, #72]                   ; 8-byte Folded Reload
	mul	x8, x6, x8
	lsl	x10, x8, #2
	mul	x8, x6, x5
	lsl	x8, x8, #2
	stp	x8, x10, [sp, #24]              ; 16-byte Folded Spill
	lsl	x19, x5, #4
	add	x8, x30, x27
	add	x8, x2, x8
	str	x8, [sp, #144]                  ; 8-byte Folded Spill
	add	x8, x16, x27
	add	x8, x2, x8
	str	x8, [sp, #136]                  ; 8-byte Folded Spill
	add	x22, x2, x27
	add	x8, x22, x25
	str	x8, [sp, #128]                  ; 8-byte Folded Spill
	lsl	x8, x5, #3
	add	x10, x8, x30
	add	x10, x2, x10
	str	x10, [sp, #120]                 ; 8-byte Folded Spill
	add	x10, x16, x8
	add	x10, x2, x10
	add	x26, x2, x8
	add	x8, x26, x25
	stp	x8, x10, [sp, #104]             ; 16-byte Folded Spill
	add	x8, x5, x5, lsl #1
	lsl	x8, x8, #2
	add	x28, x2, x8
	add	x10, x2, x30
	mov	x1, x10
	add	x10, x10, x8
	str	x10, [sp, #96]                  ; 8-byte Folded Spill
	add	x10, x2, x16
	mov	x7, x10
	add	x10, x10, x8
	str	x10, [sp, #88]                  ; 8-byte Folded Spill
	add	x8, x25, x8
	add	x8, x2, x8
	add	x10, x2, x25
	b	LBB4_3
LBB4_2:                                 ;   in Loop: Header=BB4_3 Depth=1
	ldr	x11, [sp, #80]                  ; 8-byte Folded Reload
	ldp	x12, x13, [sp, #24]             ; 16-byte Folded Reload
	add	x11, x11, x13
	str	x11, [sp, #80]                  ; 8-byte Folded Spill
	ldr	x11, [sp, #40]                  ; 8-byte Folded Reload
	add	x11, x11, x12
	str	x11, [sp, #40]                  ; 8-byte Folded Spill
	add	x9, x9, x6
	cmp	x9, x3
	b.hs	LBB4_24
LBB4_3:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB4_6 Depth 2
                                        ;       Child Loop BB4_10 Depth 3
                                        ;       Child Loop BB4_17 Depth 3
	cbz	x5, LBB4_2
; %bb.4:                                ;   in Loop: Header=BB4_3 Depth=1
	mov	x11, #0                         ; =0x0
	whilelo	p0.s, x9, x3
	ldr	x24, [sp, #40]                  ; 8-byte Folded Reload
	ldr	x0, [sp, #16]                   ; 8-byte Folded Reload
	b	LBB4_6
LBB4_5:                                 ;   in Loop: Header=BB4_6 Depth=2
	ldr	x12, [sp, #48]                  ; 8-byte Folded Reload
	add	x0, x0, x12
	add	x24, x24, x12
	add	x11, x11, x30
	cmp	x11, x5
	b.hs	LBB4_2
LBB4_6:                                 ;   Parent Loop BB4_3 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB4_10 Depth 3
                                        ;       Child Loop BB4_17 Depth 3
	whilelo	p1.s, x11, x5
	add	x4, x11, x6
	whilelo	p2.s, x4, x5
	ldp	x12, x13, [sp, #56]             ; 16-byte Folded Reload
	add	x20, x11, x13
	whilelo	p3.s, x20, x5
	add	x21, x11, x12
	whilelo	p4.s, x21, x5
	zero	{za}
	ldp	x15, x12, [sp, #72]             ; 16-byte Folded Reload
	mov	x13, x0
	mov	x14, x15
	cbnz	x15, LBB4_10
LBB4_7:                                 ;   in Loop: Header=BB4_6 Depth=2
	add	x12, sp, #192
	str	p2, [x12, #7, mul vl]           ; 2-byte Folded Spill
	cbz	x6, LBB4_5
; %bb.8:                                ;   in Loop: Header=BB4_6 Depth=2
	mov	x14, #0                         ; =0x0
	mov	x23, x24
	b	LBB4_17
LBB4_9:                                 ;   in Loop: Header=BB4_10 Depth=3
	add	x13, x13, x27
	add	x12, x12, x30
	subs	x14, x14, #1
	b.eq	LBB4_7
LBB4_10:                                ;   Parent Loop BB4_3 Depth=1
                                        ;     Parent Loop BB4_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld1w	{ z0.s }, p0/z, [x12]
	ld1w	{ z1.s }, p1/z, [x13]
	fmopa	za0.s, p0/m, p1/m, z0.s, z1.s
	cmp	x4, x5
	b.lo	LBB4_13
; %bb.11:                               ;   in Loop: Header=BB4_10 Depth=3
	cmp	x20, x5
	b.lo	LBB4_14
LBB4_12:                                ;   in Loop: Header=BB4_10 Depth=3
	cmp	x21, x5
	b.hs	LBB4_9
	b	LBB4_15
LBB4_13:                                ;   in Loop: Header=BB4_10 Depth=3
	add	x15, x13, x30
	ld1w	{ z1.s }, p2/z, [x15]
	fmopa	za1.s, p0/m, p2/m, z0.s, z1.s
	cmp	x20, x5
	b.hs	LBB4_12
LBB4_14:                                ;   in Loop: Header=BB4_10 Depth=3
	add	x15, x13, x16
	ld1w	{ z1.s }, p3/z, [x15]
	fmopa	za2.s, p0/m, p3/m, z0.s, z1.s
	cmp	x21, x5
	b.hs	LBB4_9
LBB4_15:                                ;   in Loop: Header=BB4_10 Depth=3
	add	x15, x13, x25
	ld1w	{ z1.s }, p4/z, [x15]
	fmopa	za3.s, p0/m, p4/m, z0.s, z1.s
	b	LBB4_9
LBB4_16:                                ;   in Loop: Header=BB4_17 Depth=3
	add	x14, x14, #4
	add	x23, x23, x19
	cmp	x14, x6
	b.hs	LBB4_5
LBB4_17:                                ;   Parent Loop BB4_3 Depth=1
                                        ;     Parent Loop BB4_6 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	add	x13, x9, x14
	cmp	x13, x3
	b.hs	LBB4_5
; %bb.18:                               ;   in Loop: Header=BB4_17 Depth=3
	psel	p7, p1, p0.s[w13, 0]
	add	x12, x13, #1
	str	x12, [sp, #184]                 ; 8-byte Folded Spill
	psel	p2, p1, p0.s[w12, 0]
	add	x12, x13, #2
	str	x12, [sp, #160]                 ; 8-byte Folded Spill
	psel	p6, p1, p0.s[w12, 0]
	add	x12, x13, #3
	str	x12, [sp, #176]                 ; 8-byte Folded Spill
	psel	p5, p1, p0.s[w12, 0]
	add	x12, x2, x23
	st1w	{za0h.s[w14, 0]}, p7, [x12]
	add	x15, x14, #1
	add	x12, x22, x23
	str	x15, [sp, #168]                 ; 8-byte Folded Spill
	st1w	{za0h.s[w15, 0]}, p2, [x12]
	add	x12, x26, x23
	add	x15, x14, #2
	st1w	{za0h.s[w15, 0]}, p6, [x12]
	add	x17, x28, x23
	add	x12, x14, #3
	str	x12, [sp, #152]                 ; 8-byte Folded Spill
	st1w	{za0h.s[w12, 0]}, p5, [x17]
	cmp	x4, x5
	b.lo	LBB4_21
; %bb.19:                               ;   in Loop: Header=BB4_17 Depth=3
	cmp	x20, x5
	b.lo	LBB4_22
LBB4_20:                                ;   in Loop: Header=BB4_17 Depth=3
	cmp	x21, x5
	b.hs	LBB4_16
	b	LBB4_23
LBB4_21:                                ;   in Loop: Header=BB4_17 Depth=3
	add	x12, sp, #192
	ldr	p7, [x12, #7, mul vl]           ; 2-byte Folded Reload
	psel	p2, p7, p0.s[w13, 0]
	mov	x12, x15
	ldr	x15, [sp, #184]                 ; 8-byte Folded Reload
	psel	p5, p7, p0.s[w15, 0]
	mov	x15, x12
	ldr	x12, [sp, #160]                 ; 8-byte Folded Reload
	psel	p6, p7, p0.s[w12, 0]
	ldr	x12, [sp, #176]                 ; 8-byte Folded Reload
	psel	p7, p7, p0.s[w12, 0]
	add	x17, x1, x23
	st1w	{za1h.s[w14, 0]}, p2, [x17]
	ldr	x17, [sp, #144]                 ; 8-byte Folded Reload
	add	x17, x17, x23
	ldr	x12, [sp, #168]                 ; 8-byte Folded Reload
	st1w	{za1h.s[w12, 0]}, p5, [x17]
	ldr	x17, [sp, #120]                 ; 8-byte Folded Reload
	add	x17, x17, x23
	st1w	{za1h.s[w15, 0]}, p6, [x17]
	ldr	x17, [sp, #96]                  ; 8-byte Folded Reload
	add	x17, x17, x23
	ldr	x12, [sp, #152]                 ; 8-byte Folded Reload
	st1w	{za1h.s[w12, 0]}, p7, [x17]
	cmp	x20, x5
	b.hs	LBB4_20
LBB4_22:                                ;   in Loop: Header=BB4_17 Depth=3
	psel	p2, p3, p0.s[w13, 0]
	mov	x12, x15
	ldr	x15, [sp, #184]                 ; 8-byte Folded Reload
	psel	p5, p3, p0.s[w15, 0]
	mov	x15, x12
	ldr	x12, [sp, #160]                 ; 8-byte Folded Reload
	psel	p6, p3, p0.s[w12, 0]
	ldr	x12, [sp, #176]                 ; 8-byte Folded Reload
	psel	p7, p3, p0.s[w12, 0]
	add	x17, x7, x23
	st1w	{za2h.s[w14, 0]}, p2, [x17]
	ldr	x17, [sp, #136]                 ; 8-byte Folded Reload
	add	x17, x17, x23
	ldr	x12, [sp, #168]                 ; 8-byte Folded Reload
	st1w	{za2h.s[w12, 0]}, p5, [x17]
	ldr	x17, [sp, #112]                 ; 8-byte Folded Reload
	add	x17, x17, x23
	st1w	{za2h.s[w15, 0]}, p6, [x17]
	ldr	x17, [sp, #88]                  ; 8-byte Folded Reload
	add	x17, x17, x23
	ldr	x12, [sp, #152]                 ; 8-byte Folded Reload
	st1w	{za2h.s[w12, 0]}, p7, [x17]
	cmp	x21, x5
	b.hs	LBB4_16
LBB4_23:                                ;   in Loop: Header=BB4_17 Depth=3
	psel	p2, p4, p0.s[w13, 0]
	ldr	x13, [sp, #184]                 ; 8-byte Folded Reload
	psel	p5, p4, p0.s[w13, 0]
	ldr	x12, [sp, #160]                 ; 8-byte Folded Reload
	psel	p6, p4, p0.s[w12, 0]
	ldr	x12, [sp, #176]                 ; 8-byte Folded Reload
	psel	p7, p4, p0.s[w12, 0]
	add	x13, x10, x23
	st1w	{za3h.s[w14, 0]}, p2, [x13]
	ldr	x13, [sp, #128]                 ; 8-byte Folded Reload
	add	x13, x13, x23
	ldr	x12, [sp, #168]                 ; 8-byte Folded Reload
	st1w	{za3h.s[w12, 0]}, p5, [x13]
	ldr	x13, [sp, #104]                 ; 8-byte Folded Reload
	add	x13, x13, x23
	st1w	{za3h.s[w15, 0]}, p6, [x13]
	add	x13, x8, x23
	ldr	x12, [sp, #152]                 ; 8-byte Folded Reload
	st1w	{za3h.s[w12, 0]}, p7, [x13]
	b	LBB4_16
LBB4_24:
	addvl	sp, sp, #1
	add	sp, sp, #192
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #48]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #32]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #16]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp], #96             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_matmul_sme_cpu_preprocess      ; -- Begin function matmul_sme_cpu_preprocess
	.p2align	2
_matmul_sme_cpu_preprocess:             ; @matmul_sme_cpu_preprocess
	.cfi_startproc
; %bb.0:
	stp	d15, d14, [sp, #-160]!          ; 16-byte Folded Spill
	.cfi_def_cfa_offset 160
	stp	d13, d12, [sp, #16]             ; 16-byte Folded Spill
	stp	d11, d10, [sp, #32]             ; 16-byte Folded Spill
	stp	d9, d8, [sp, #48]               ; 16-byte Folded Spill
	stp	x28, x27, [sp, #64]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #80]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #96]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #112]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #128]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #144]            ; 16-byte Folded Spill
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_offset b8, -104
	.cfi_offset b9, -112
	.cfi_offset b10, -120
	.cfi_offset b11, -128
	.cfi_offset b12, -136
	.cfi_offset b13, -144
	.cfi_offset b14, -152
	.cfi_offset b15, -160
	sub	sp, sp, #16
	mov	x20, x5
	mov	x21, x4
	mov	x22, x3
	mov	x23, x2
	mov	x24, x1
	mov	x25, x0
	smstart	sm
	mov	x8, sp
	rdsvl	x9, #1
	msub	x8, x9, x9, x8
	mov	sp, x8
	stur	x8, [x29, #-160]
	sturh	wzr, [x29, #-150]
	stur	wzr, [x29, #-148]
	mrs	x8, TPIDR2_EL0
	cbz	x8, LBB5_2
; %bb.1:
	bl	___arm_tpidr2_save
	msr	TPIDR2_EL0, xzr
LBB5_2:
	smstart	za
	zero	{za}
	rdsvl	x8, #1
	lsr	x26, x8, #2
	add	x9, x22, x26
	sub	x9, x9, #1
	udiv	x9, x9, x26
	mul	x9, x9, x26
	mul	x9, x21, x9
	lsl	x1, x9, #2
	sturh	w8, [x29, #-152]
	sub	x27, x29, #160
	msr	TPIDR2_EL0, x27
	smstop	sm
	mov	w0, #64                         ; =0x40
	bl	_aligned_alloc
	mov	x1, x0
	smstart	sm
	smstart	za
	mrs	x8, TPIDR2_EL0
	sub	x0, x29, #160
	cbnz	x8, LBB5_4
; %bb.3:
	bl	___arm_tpidr2_restore
LBB5_4:
	msr	TPIDR2_EL0, xzr
	cbz	x22, LBB5_27
; %bb.5:
	mov	x10, #0                         ; =0x0
	mul	x8, x26, x21
	lsl	x8, x8, #2
	lsl	x9, x26, #2
	lsl	x11, x21, #2
	mul	x12, x26, x26
	lsl	x12, x12, #2
	mov	x13, x1
	b	LBB5_7
LBB5_6:                                 ;   in Loop: Header=BB5_7 Depth=1
	add	x25, x25, x8
	add	x13, x13, x8
	add	x10, x10, x26
	cmp	x10, x22
	b.hs	LBB5_17
LBB5_7:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_10 Depth 2
                                        ;       Child Loop BB5_12 Depth 3
                                        ;         Child Loop BB5_13 Depth 4
	cbz	x21, LBB5_6
; %bb.8:                                ;   in Loop: Header=BB5_7 Depth=1
	mov	x14, #0                         ; =0x0
	mov	x15, x13
	mov	x16, x25
	b	LBB5_10
LBB5_9:                                 ;   in Loop: Header=BB5_10 Depth=2
	add	x16, x16, x9
	add	x15, x15, x12
	add	x14, x14, x26
	cmp	x14, x21
	b.hs	LBB5_6
LBB5_10:                                ;   Parent Loop BB5_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB5_12 Depth 3
                                        ;         Child Loop BB5_13 Depth 4
	mov	x17, #0                         ; =0x0
	mov	x0, x15
	mov	x2, x16
	b	LBB5_12
LBB5_11:                                ;   in Loop: Header=BB5_12 Depth=3
	add	x17, x17, #1
	add	x2, x2, x11
	add	x0, x0, #4
	cmp	x17, x26
	b.eq	LBB5_9
LBB5_12:                                ;   Parent Loop BB5_7 Depth=1
                                        ;     Parent Loop BB5_10 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB5_13 Depth 4
	add	x3, x17, x10
	mov	x4, x0
	mov	w5, #1                          ; =0x1
	mov	x6, x2
LBB5_13:                                ;   Parent Loop BB5_7 Depth=1
                                        ;     Parent Loop BB5_10 Depth=2
                                        ;       Parent Loop BB5_12 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	fmov	s0, wzr
	cmp	x3, x22
	b.hs	LBB5_15
; %bb.14:                               ;   in Loop: Header=BB5_13 Depth=4
	ldr	s0, [x6]
LBB5_15:                                ;   in Loop: Header=BB5_13 Depth=4
	str	s0, [x4]
	cmp	x5, x26
	b.hs	LBB5_11
; %bb.16:                               ;   in Loop: Header=BB5_13 Depth=4
	add	x7, x14, x5
	add	x6, x6, #4
	add	x5, x5, #1
	add	x4, x4, x9
	cmp	x7, x21
	b.lo	LBB5_13
	b	LBB5_11
LBB5_17:
	mov	x10, #0                         ; =0x0
	lsl	x11, x20, #2
	mov	w12, #12                        ; =0xc
	madd	x30, x20, x12, x23
	mul	x13, x26, x20
	lsl	x25, x13, #2
	lsl	x14, x20, #4
	add	x15, x23, x20, lsl #3
	add	x16, x23, x11
	mov	x17, x1
	b	LBB5_19
LBB5_18:                                ;   in Loop: Header=BB5_19 Depth=1
	add	x17, x17, x8
	add	x30, x30, x25
	add	x15, x15, x25
	add	x16, x16, x25
	add	x23, x23, x25
	add	x10, x10, x26
	cmp	x10, x22
	b.hs	LBB5_27
LBB5_19:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_22 Depth 2
                                        ;       Child Loop BB5_23 Depth 3
                                        ;       Child Loop BB5_25 Depth 3
	cbz	x20, LBB5_18
; %bb.20:                               ;   in Loop: Header=BB5_19 Depth=1
	mov	x0, #0                          ; =0x0
	mov	x2, x23
	whilelo	p0.s, x10, x22
	mov	x3, x16
	mov	x4, x15
	mov	x5, x30
	mov	x6, x24
	b	LBB5_22
LBB5_21:                                ;   in Loop: Header=BB5_22 Depth=2
	add	x6, x6, x9
	add	x5, x5, x9
	add	x4, x4, x9
	add	x3, x3, x9
	add	x2, x2, x9
	add	x0, x0, x26
	cmp	x0, x20
	b.hs	LBB5_18
LBB5_22:                                ;   Parent Loop BB5_19 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB5_23 Depth 3
                                        ;       Child Loop BB5_25 Depth 3
	whilelo	p1.s, x0, x20
	zero	{za}
	mov	x13, x17
	mov	x7, x6
	mov	x28, x21
	cbz	x21, LBB5_24
LBB5_23:                                ;   Parent Loop BB5_19 Depth=1
                                        ;     Parent Loop BB5_22 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld1w	{ z0.s }, p0/z, [x13]
	ld1w	{ z1.s }, p1/z, [x7]
	fmopa	za0.s, p0/m, p1/m, z0.s, z1.s
	add	x7, x7, x11
	add	x13, x13, x9
	subs	x28, x28, #1
	b.ne	LBB5_23
LBB5_24:                                ;   in Loop: Header=BB5_22 Depth=2
	mov	x7, #0                          ; =0x0
	mov	x13, #0                         ; =0x0
LBB5_25:                                ;   Parent Loop BB5_19 Depth=1
                                        ;     Parent Loop BB5_22 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	add	x28, x10, x13
	cmp	x28, x22
	b.hs	LBB5_21
; %bb.26:                               ;   in Loop: Header=BB5_25 Depth=3
	add	w12, w10, w13
	psel	p2, p1, p0.s[w12, 0]
	psel	p3, p1, p0.s[w12, 1]
	psel	p4, p1, p0.s[w12, 2]
	psel	p5, p1, p0.s[w12, 3]
	add	x12, x2, x7
	st1w	{za0h.s[w13, 0]}, p2, [x12]
	add	x12, x3, x7
	st1w	{za0h.s[w13, 1]}, p3, [x12]
	add	x12, x4, x7
	st1w	{za0h.s[w13, 2]}, p4, [x12]
	add	x12, x5, x7
	st1w	{za0h.s[w13, 3]}, p5, [x12]
	add	x7, x7, x14
	add	x13, x13, #4
	cmp	x13, x26
	b.lo	LBB5_25
	b	LBB5_21
LBB5_27:
	rdsvl	x8, #1
	sturh	w8, [x29, #-152]
	msr	TPIDR2_EL0, x27
	smstop	sm
	mov	x0, x1
	bl	_free
	smstart	sm
	smstart	za
	mrs	x8, TPIDR2_EL0
	sub	x0, x29, #160
	cbnz	x8, LBB5_29
; %bb.28:
	bl	___arm_tpidr2_restore
LBB5_29:
	msr	TPIDR2_EL0, xzr
	smstop	za
	smstop	sm
	sub	sp, x29, #144
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #128]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #112]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #96]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #80]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #64]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #48]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #32]             ; 16-byte Folded Reload
	ldp	d13, d12, [sp, #16]             ; 16-byte Folded Reload
	ldp	d15, d14, [sp], #160            ; 16-byte Folded Reload
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	.cfi_restore b8
	.cfi_restore b9
	.cfi_restore b10
	.cfi_restore b11
	.cfi_restore b12
	.cfi_restore b13
	.cfi_restore b14
	.cfi_restore b15
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_matmul_sme_sme_preprocess      ; -- Begin function matmul_sme_sme_preprocess
	.p2align	2
_matmul_sme_sme_preprocess:             ; @matmul_sme_sme_preprocess
	.cfi_startproc
; %bb.0:
	stp	d15, d14, [sp, #-160]!          ; 16-byte Folded Spill
	.cfi_def_cfa_offset 160
	stp	d13, d12, [sp, #16]             ; 16-byte Folded Spill
	stp	d11, d10, [sp, #32]             ; 16-byte Folded Spill
	stp	d9, d8, [sp, #48]               ; 16-byte Folded Spill
	stp	x28, x27, [sp, #64]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #80]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #96]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #112]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #128]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #144]            ; 16-byte Folded Spill
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_offset b8, -104
	.cfi_offset b9, -112
	.cfi_offset b10, -120
	.cfi_offset b11, -128
	.cfi_offset b12, -136
	.cfi_offset b13, -144
	.cfi_offset b14, -152
	.cfi_offset b15, -160
	sub	sp, sp, #128
	mov	x20, x5
	mov	x21, x4
	mov	x22, x3
	mov	x24, x2
	mov	x25, x1
	stur	x0, [x29, #-184]                ; 8-byte Folded Spill
	smstart	sm
	mov	x8, sp
	rdsvl	x9, #1
	msub	x8, x9, x9, x8
	mov	sp, x8
	stur	x8, [x29, #-176]
	sturh	wzr, [x29, #-166]
	stur	wzr, [x29, #-164]
	mrs	x8, TPIDR2_EL0
	cbz	x8, LBB6_2
; %bb.1:
	bl	___arm_tpidr2_save
	msr	TPIDR2_EL0, xzr
LBB6_2:
	smstart	za
	zero	{za}
	rdsvl	x8, #1
	lsr	x26, x8, #2
	add	x9, x22, x26
	sub	x9, x9, #1
	udiv	x9, x9, x26
	mul	x23, x9, x26
	mul	x9, x21, x23
	lsl	x1, x9, #2
	sturh	w8, [x29, #-168]
	sub	x27, x29, #176
	msr	TPIDR2_EL0, x27
	smstop	sm
	mov	w0, #64                         ; =0x40
	bl	_aligned_alloc
	mov	x28, x0
	smstart	sm
	smstart	za
	mrs	x8, TPIDR2_EL0
	sub	x0, x29, #176
	cbnz	x8, LBB6_4
; %bb.3:
	bl	___arm_tpidr2_restore
LBB6_4:
	msr	TPIDR2_EL0, xzr
	cbz	x22, LBB6_24
; %bb.5:
	stp	x25, x24, [x29, #-256]          ; 16-byte Folded Spill
	stp	xzr, xzr, [x29, #-200]          ; 16-byte Folded Spill
	mov	w8, #12                         ; =0xc
	lsl	x13, x26, #1
	mul	x9, x26, x21
	stur	x9, [x29, #-240]                ; 8-byte Folded Spill
	lsl	x30, x9, #2
	lsl	x15, x26, #3
	lsl	x16, x21, #4
	mul	x17, x26, x26
	mul	x0, x23, x21
	ldur	x9, [x29, #-184]                ; 8-byte Folded Reload
	add	x11, x9, x21, lsl #3
	add	x10, x9, x21, lsl #2
	stp	x10, x11, [x29, #-216]          ; 16-byte Folded Spill
	madd	x8, x21, x8, x9
	stur	x8, [x29, #-224]                ; 8-byte Folded Spill
	lsl	x4, x17, #3
	lsl	x5, x26, #4
	lsl	x6, x17, #1
	lsl	x10, x26, #2
	mov	x8, x28
	sub	x9, x29, #8
	stur	x28, [x9, #-256]                ; 8-byte Folded Spill
	add	x23, x28, x17, lsl #2
	stur	x30, [x29, #-232]               ; 8-byte Folded Spill
	b	LBB6_7
LBB6_6:                                 ;   in Loop: Header=BB6_7 Depth=1
	ldp	x30, x9, [x29, #-232]           ; 16-byte Folded Reload
	add	x9, x9, x30
	stur	x9, [x29, #-224]                ; 8-byte Folded Spill
	ldur	x9, [x29, #-208]                ; 8-byte Folded Reload
	add	x9, x9, x30
	stur	x9, [x29, #-208]                ; 8-byte Folded Spill
	ldur	x9, [x29, #-216]                ; 8-byte Folded Reload
	add	x9, x9, x30
	stur	x9, [x29, #-216]                ; 8-byte Folded Spill
	ldur	x9, [x29, #-184]                ; 8-byte Folded Reload
	add	x9, x9, x30
	stur	x9, [x29, #-184]                ; 8-byte Folded Spill
	add	x23, x23, x30
	ldur	x9, [x29, #-192]                ; 8-byte Folded Reload
	ldur	x11, [x29, #-240]               ; 8-byte Folded Reload
	add	x9, x9, x11
	stur	x9, [x29, #-192]                ; 8-byte Folded Spill
	add	x8, x8, x30
	ldur	x9, [x29, #-200]                ; 8-byte Folded Reload
	add	x9, x9, x26
	stur	x9, [x29, #-200]                ; 8-byte Folded Spill
	cmp	x9, x22
	b.hs	LBB6_14
LBB6_7:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_9 Depth 2
                                        ;       Child Loop BB6_10 Depth 3
                                        ;       Child Loop BB6_12 Depth 3
	cbz	x21, LBB6_6
; %bb.8:                                ;   in Loop: Header=BB6_7 Depth=1
	mov	x30, #0                         ; =0x0
	ldp	x11, x9, [x29, #-200]           ; 16-byte Folded Reload
	whilelo	p0.s, x11, x22
	mov	x7, x8
	mov	x24, x23
	ldur	x25, [x29, #-184]               ; 8-byte Folded Reload
	ldp	x2, x1, [x29, #-216]            ; 16-byte Folded Reload
	ldur	x3, [x29, #-224]                ; 8-byte Folded Reload
LBB6_9:                                 ;   Parent Loop BB6_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB6_10 Depth 3
                                        ;       Child Loop BB6_12 Depth 3
	mov	x27, #0                         ; =0x0
	mov	x14, #0                         ; =0x0
	whilelo	pn8.s, x30, x21, vlx2
	mov	p1.b, p8.b
LBB6_10:                                ;   Parent Loop BB6_7 Depth=1
                                        ;     Parent Loop BB6_9 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	psel	pn8, p1, p0.s[w14, 0]
	psel	p3, p1, p0.s[w14, 1]
	psel	p4, p1, p0.s[w14, 2]
	psel	p5, p1, p0.s[w14, 3]
	add	x11, x25, x27
	ld1w	{ z16.s, z24.s }, pn8/z, [x11]
	add	x11, x2, x27
	mov	p8.b, p3.b
	ld1w	{ z17.s, z25.s }, pn8/z, [x11]
	add	x11, x1, x27
	mov	p8.b, p4.b
	ld1w	{ z18.s, z26.s }, pn8/z, [x11]
	add	x11, x3, x27
	mov	p8.b, p5.b
	ld1w	{ z19.s, z27.s }, pn8/z, [x11]
	mov	z0.d, z16.d
	mov	z1.d, z17.d
	mov	z2.d, z18.d
	mov	z3.d, z19.d
	mov	za0h.s[w14, 0:3], { z0.s - z3.s }
	mov	za1h.s[w14, 0:3], { z24.s - z27.s }
	add	x14, x14, #4
	add	x27, x27, x16
	cmp	x14, x26
	b.lo	LBB6_10
; %bb.11:                               ;   in Loop: Header=BB6_9 Depth=2
	mov	x14, #0                         ; =0x0
	mov	x27, x7
	mov	x11, x9
	mov	x28, x24
LBB6_12:                                ;   Parent Loop BB6_7 Depth=1
                                        ;     Parent Loop BB6_9 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	whilelo	pn8.s, x11, x0, vlx4
	add	x12, x17, x11
	whilelo	pn9.s, x12, x0, vlx4
	mov	{ z0.s - z3.s }, za0v.s[w14, 0:3]
	mov	{ z4.s - z7.s }, za1v.s[w14, 0:3]
	add	x14, x14, #4
	st1w	{ z0.s - z3.s }, pn8, [x27]
	st1w	{ z4.s - z7.s }, pn9, [x28]
	add	x28, x28, x5
	add	x11, x11, x10
	add	x27, x27, x5
	cmp	x14, x26
	b.lo	LBB6_12
; %bb.13:                               ;   in Loop: Header=BB6_9 Depth=2
	add	x3, x3, x15
	add	x1, x1, x15
	add	x2, x2, x15
	add	x25, x25, x15
	add	x24, x24, x4
	add	x9, x9, x6
	add	x7, x7, x4
	add	x30, x30, x13
	cmp	x30, x21
	b.lo	LBB6_9
	b	LBB6_6
LBB6_14:
	mov	x11, #0                         ; =0x0
	lsl	x12, x20, #2
	mov	w8, #12                         ; =0xc
	ldp	x25, x24, [x29, #-256]          ; 16-byte Folded Reload
	madd	x23, x20, x8, x24
	mul	x8, x26, x20
	lsl	x6, x8, #2
	lsl	x15, x20, #4
	add	x16, x24, x20, lsl #3
	add	x17, x24, x12
	sub	x8, x29, #8
	ldur	x28, [x8, #-256]                ; 8-byte Folded Reload
	mov	x0, x28
	sub	x27, x29, #176
	b	LBB6_16
LBB6_15:                                ;   in Loop: Header=BB6_16 Depth=1
	add	x0, x0, x30
	add	x23, x23, x6
	add	x16, x16, x6
	add	x17, x17, x6
	add	x24, x24, x6
	add	x11, x11, x26
	cmp	x11, x22
	b.hs	LBB6_24
LBB6_16:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_19 Depth 2
                                        ;       Child Loop BB6_20 Depth 3
                                        ;       Child Loop BB6_22 Depth 3
	cbz	x20, LBB6_15
; %bb.17:                               ;   in Loop: Header=BB6_16 Depth=1
	mov	x8, #0                          ; =0x0
	mov	x9, x24
	whilelo	p0.s, x11, x22
	mov	x1, x17
	mov	x2, x16
	mov	x3, x23
	mov	x4, x25
	b	LBB6_19
LBB6_18:                                ;   in Loop: Header=BB6_19 Depth=2
	add	x4, x4, x10
	add	x3, x3, x10
	add	x2, x2, x10
	add	x1, x1, x10
	add	x9, x9, x10
	add	x8, x8, x26
	cmp	x8, x20
	b.hs	LBB6_15
LBB6_19:                                ;   Parent Loop BB6_16 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB6_20 Depth 3
                                        ;       Child Loop BB6_22 Depth 3
	whilelo	p1.s, x8, x20
	zero	{za}
	mov	x14, x0
	mov	x5, x4
	mov	x7, x21
	cbz	x21, LBB6_21
LBB6_20:                                ;   Parent Loop BB6_16 Depth=1
                                        ;     Parent Loop BB6_19 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ld1w	{ z0.s }, p0/z, [x14]
	ld1w	{ z1.s }, p1/z, [x5]
	fmopa	za0.s, p0/m, p1/m, z0.s, z1.s
	add	x5, x5, x12
	add	x14, x14, x10
	subs	x7, x7, #1
	b.ne	LBB6_20
LBB6_21:                                ;   in Loop: Header=BB6_19 Depth=2
	mov	x5, #0                          ; =0x0
	mov	x14, #0                         ; =0x0
LBB6_22:                                ;   Parent Loop BB6_16 Depth=1
                                        ;     Parent Loop BB6_19 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	add	x7, x11, x14
	cmp	x7, x22
	b.hs	LBB6_18
; %bb.23:                               ;   in Loop: Header=BB6_22 Depth=3
	add	w13, w11, w14
	psel	p2, p1, p0.s[w13, 0]
	psel	p3, p1, p0.s[w13, 1]
	psel	p4, p1, p0.s[w13, 2]
	psel	p5, p1, p0.s[w13, 3]
	add	x13, x9, x5
	st1w	{za0h.s[w14, 0]}, p2, [x13]
	add	x13, x1, x5
	st1w	{za0h.s[w14, 1]}, p3, [x13]
	add	x13, x2, x5
	st1w	{za0h.s[w14, 2]}, p4, [x13]
	add	x13, x3, x5
	st1w	{za0h.s[w14, 3]}, p5, [x13]
	add	x5, x5, x15
	add	x14, x14, #4
	cmp	x14, x26
	b.lo	LBB6_22
	b	LBB6_18
LBB6_24:
	rdsvl	x8, #1
	sturh	w8, [x29, #-168]
	msr	TPIDR2_EL0, x27
	smstop	sm
	mov	x0, x28
	bl	_free
	smstart	sm
	smstart	za
	mrs	x8, TPIDR2_EL0
	sub	x0, x29, #176
	cbnz	x8, LBB6_26
; %bb.25:
	bl	___arm_tpidr2_restore
LBB6_26:
	msr	TPIDR2_EL0, xzr
	smstop	za
	smstop	sm
	sub	sp, x29, #144
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #128]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #112]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #96]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #80]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #64]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #48]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #32]             ; 16-byte Folded Reload
	ldp	d13, d12, [sp, #16]             ; 16-byte Folded Reload
	ldp	d15, d14, [sp], #160            ; 16-byte Folded Reload
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	.cfi_restore b8
	.cfi_restore b9
	.cfi_restore b10
	.cfi_restore b11
	.cfi_restore b12
	.cfi_restore b13
	.cfi_restore b14
	.cfi_restore b15
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_matmul_sme_4tiles              ; -- Begin function matmul_sme_4tiles
	.p2align	2
_matmul_sme_4tiles:                     ; @matmul_sme_4tiles
	.cfi_startproc
; %bb.0:
	stp	d15, d14, [sp, #-160]!          ; 16-byte Folded Spill
	.cfi_def_cfa_offset 160
	stp	d13, d12, [sp, #16]             ; 16-byte Folded Spill
	stp	d11, d10, [sp, #32]             ; 16-byte Folded Spill
	stp	d9, d8, [sp, #48]               ; 16-byte Folded Spill
	stp	x28, x27, [sp, #64]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #80]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #96]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #112]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #128]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #144]            ; 16-byte Folded Spill
	add	x29, sp, #144
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_offset b8, -104
	.cfi_offset b9, -112
	.cfi_offset b10, -120
	.cfi_offset b11, -128
	.cfi_offset b12, -136
	.cfi_offset b13, -144
	.cfi_offset b14, -152
	.cfi_offset b15, -160
	sub	sp, sp, #128
	stp	x2, x5, [x29, #-256]            ; 16-byte Folded Spill
	mov	x21, x4
	stur	x3, [x29, #-216]                ; 8-byte Folded Spill
	sub	x8, x29, #8
	stur	x1, [x8, #-256]                 ; 8-byte Folded Spill
	stur	x0, [x29, #-184]                ; 8-byte Folded Spill
	smstart	sm
	mov	x8, sp
	rdsvl	x9, #1
	msub	x8, x9, x9, x8
	mov	sp, x8
	stur	x8, [x29, #-176]
	sturh	wzr, [x29, #-166]
	stur	wzr, [x29, #-164]
	mrs	x8, TPIDR2_EL0
	cbz	x8, LBB7_2
; %bb.1:
	bl	___arm_tpidr2_save
	msr	TPIDR2_EL0, xzr
LBB7_2:
	smstart	za
	zero	{za}
	rdsvl	x8, #1
	lsr	x26, x8, #2
	ldur	x20, [x29, #-216]               ; 8-byte Folded Reload
	add	x9, x20, x26
	sub	x9, x9, #1
	udiv	x9, x9, x26
	mul	x22, x9, x26
	mul	x9, x21, x22
	lsl	x1, x9, #2
	sturh	w8, [x29, #-168]
	sub	x8, x29, #176
	msr	TPIDR2_EL0, x8
	smstop	sm
	mov	w0, #64                         ; =0x40
	bl	_aligned_alloc
	stur	x0, [x29, #-240]                ; 8-byte Folded Spill
	smstart	sm
	smstart	za
	mrs	x8, TPIDR2_EL0
	sub	x0, x29, #176
	cbnz	x8, LBB7_4
; %bb.3:
	bl	___arm_tpidr2_restore
LBB7_4:
	msr	TPIDR2_EL0, xzr
	cbz	x20, LBB7_14
; %bb.5:
	mov	x9, #0                          ; =0x0
	mov	w8, #12                         ; =0xc
	lsl	x10, x26, #1
	mul	x11, x26, x21
	stur	x11, [x29, #-224]               ; 8-byte Folded Spill
	lsl	x11, x11, #2
	stur	x11, [x29, #-232]               ; 8-byte Folded Spill
	lsl	x13, x26, #3
	lsl	x14, x21, #4
	mul	x15, x26, x26
	mul	x16, x22, x21
	ldur	x11, [x29, #-184]               ; 8-byte Folded Reload
	add	x12, x11, x21, lsl #3
	stp	x12, xzr, [x29, #-200]          ; 16-byte Folded Spill
	add	x12, x11, x21, lsl #2
	stur	x12, [x29, #-208]               ; 8-byte Folded Spill
	madd	x22, x21, x8, x11
	lsl	x2, x15, #3
	lsl	x3, x26, #4
	lsl	x4, x15, #1
	lsl	x5, x26, #2
	ldur	x8, [x29, #-240]                ; 8-byte Folded Reload
	mov	x27, x8
	add	x11, x8, x15, lsl #2
	b	LBB7_7
LBB7_6:                                 ;   in Loop: Header=BB7_7 Depth=1
	ldp	x17, x12, [x29, #-232]          ; 16-byte Folded Reload
	add	x22, x22, x17
	ldur	x8, [x29, #-200]                ; 8-byte Folded Reload
	add	x8, x8, x17
	stur	x8, [x29, #-200]                ; 8-byte Folded Spill
	ldur	x8, [x29, #-208]                ; 8-byte Folded Reload
	add	x8, x8, x17
	stur	x8, [x29, #-208]                ; 8-byte Folded Spill
	ldur	x8, [x29, #-184]                ; 8-byte Folded Reload
	add	x8, x8, x17
	stur	x8, [x29, #-184]                ; 8-byte Folded Spill
	add	x11, x11, x17
	ldur	x8, [x29, #-192]                ; 8-byte Folded Reload
	add	x8, x8, x12
	stur	x8, [x29, #-192]                ; 8-byte Folded Spill
	add	x27, x27, x17
	add	x9, x9, x26
	ldur	x8, [x29, #-216]                ; 8-byte Folded Reload
	cmp	x9, x8
	b.hs	LBB7_14
LBB7_7:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB7_9 Depth 2
                                        ;       Child Loop BB7_10 Depth 3
                                        ;       Child Loop BB7_12 Depth 3
	cbz	x21, LBB7_6
; %bb.8:                                ;   in Loop: Header=BB7_7 Depth=1
	mov	x30, #0                         ; =0x0
	ldp	x8, x0, [x29, #-216]            ; 16-byte Folded Reload
	whilelo	p0.s, x9, x8
	mov	x6, x27
	ldp	x20, x25, [x29, #-192]          ; 16-byte Folded Reload
	mov	x23, x11
	ldur	x17, [x29, #-200]               ; 8-byte Folded Reload
	mov	x1, x22
LBB7_9:                                 ;   Parent Loop BB7_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB7_10 Depth 3
                                        ;       Child Loop BB7_12 Depth 3
	mov	x24, #0                         ; =0x0
	mov	x12, #0                         ; =0x0
	whilelo	pn8.s, x30, x21, vlx2
	mov	p1.b, p8.b
LBB7_10:                                ;   Parent Loop BB7_7 Depth=1
                                        ;     Parent Loop BB7_9 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	psel	pn8, p1, p0.s[w12, 0]
	psel	p3, p1, p0.s[w12, 1]
	psel	p4, p1, p0.s[w12, 2]
	psel	p5, p1, p0.s[w12, 3]
	add	x8, x25, x24
	ld1w	{ z16.s, z24.s }, pn8/z, [x8]
	add	x8, x0, x24
	mov	p8.b, p3.b
	ld1w	{ z17.s, z25.s }, pn8/z, [x8]
	add	x8, x17, x24
	mov	p8.b, p4.b
	ld1w	{ z18.s, z26.s }, pn8/z, [x8]
	add	x8, x1, x24
	mov	p8.b, p5.b
	ld1w	{ z19.s, z27.s }, pn8/z, [x8]
	mov	z0.d, z16.d
	mov	z1.d, z17.d
	mov	z2.d, z18.d
	mov	z3.d, z19.d
	mov	za0h.s[w12, 0:3], { z0.s - z3.s }
	mov	za1h.s[w12, 0:3], { z24.s - z27.s }
	add	x12, x12, #4
	add	x24, x24, x14
	cmp	x12, x26
	b.lo	LBB7_10
; %bb.11:                               ;   in Loop: Header=BB7_9 Depth=2
	mov	x12, #0                         ; =0x0
	mov	x24, x6
	mov	x8, x20
	mov	x7, x23
LBB7_12:                                ;   Parent Loop BB7_7 Depth=1
                                        ;     Parent Loop BB7_9 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	whilelo	pn8.s, x8, x16, vlx4
	add	x28, x15, x8
	whilelo	pn9.s, x28, x16, vlx4
	mov	{ z0.s - z3.s }, za0v.s[w12, 0:3]
	mov	{ z4.s - z7.s }, za1v.s[w12, 0:3]
	add	x12, x12, #4
	st1w	{ z0.s - z3.s }, pn8, [x24]
	st1w	{ z4.s - z7.s }, pn9, [x7]
	add	x7, x7, x3
	add	x8, x8, x5
	add	x24, x24, x3
	cmp	x12, x26
	b.lo	LBB7_12
; %bb.13:                               ;   in Loop: Header=BB7_9 Depth=2
	add	x1, x1, x13
	add	x17, x17, x13
	add	x0, x0, x13
	add	x25, x25, x13
	add	x23, x23, x2
	add	x20, x20, x4
	add	x6, x6, x2
	add	x30, x30, x10
	cmp	x30, x21
	b.lo	LBB7_9
	b	LBB7_6
LBB7_14:
	ldp	x5, x20, [x29, #-248]           ; 16-byte Folded Reload
	mov	x0, x20
	sub	x8, x29, #8
	ldur	x1, [x8, #-256]                 ; 8-byte Folded Reload
	ldur	x2, [x29, #-256]                ; 8-byte Folded Reload
	ldur	x3, [x29, #-216]                ; 8-byte Folded Reload
	mov	x4, x21
	mov	x6, x26
	bl	_matmul_sme_kernel_4tiles
	rdsvl	x8, #1
	sturh	w8, [x29, #-168]
	sub	x8, x29, #176
	msr	TPIDR2_EL0, x8
	smstop	sm
	mov	x0, x20
	bl	_free
	smstart	sm
	smstart	za
	mrs	x8, TPIDR2_EL0
	sub	x0, x29, #176
	cbnz	x8, LBB7_16
; %bb.15:
	bl	___arm_tpidr2_restore
LBB7_16:
	msr	TPIDR2_EL0, xzr
	smstop	za
	smstop	sm
	sub	sp, x29, #144
	.cfi_def_cfa wsp, 160
	ldp	x29, x30, [sp, #144]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #128]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #112]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #96]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #80]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #64]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #48]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #32]             ; 16-byte Folded Reload
	ldp	d13, d12, [sp, #16]             ; 16-byte Folded Reload
	ldp	d15, d14, [sp], #160            ; 16-byte Folded Reload
	.cfi_def_cfa_offset 0
	.cfi_restore w30
	.cfi_restore w29
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w24
	.cfi_restore w25
	.cfi_restore w26
	.cfi_restore w27
	.cfi_restore w28
	.cfi_restore b8
	.cfi_restore b9
	.cfi_restore b10
	.cfi_restore b11
	.cfi_restore b12
	.cfi_restore b13
	.cfi_restore b14
	.cfi_restore b15
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_init_matrix                    ; -- Begin function init_matrix
	.p2align	2
_init_matrix:                           ; @init_matrix
	.cfi_startproc
; %bb.0:
	stp	d9, d8, [sp, #-64]!             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset b8, -56
	.cfi_offset b9, -64
	mov	x19, x1
	mov	x20, x0
	mov	x0, x2
	bl	_srand
	cbz	x19, LBB8_3
; %bb.1:
	mov	w21, #19923                     ; =0x4dd3
	movk	w21, #4194, lsl #16
	mov	w22, #1000                      ; =0x3e8
	mov	w8, #1120403456                 ; =0x42c80000
	fmov	s8, w8
	fmov	s9, #-5.00000000
LBB8_2:                                 ; =>This Inner Loop Header: Depth=1
	bl	_rand
	smull	x8, w0, w21
	asr	x8, x8, #38
	add	w8, w8, w8, lsr #31
	msub	w8, w8, w22, w0
	scvtf	s0, w8
	fdiv	s0, s0, s8
	fadd	s0, s0, s9
	str	s0, [x20], #4
	subs	x19, x19, #1
	b.ne	LBB8_2
LBB8_3:
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp], #64               ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_compare_matrices               ; -- Begin function compare_matrices
	.p2align	2
_compare_matrices:                      ; @compare_matrices
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #144
	stp	d11, d10, [sp, #32]             ; 16-byte Folded Spill
	stp	d9, d8, [sp, #48]               ; 16-byte Folded Spill
	stp	x26, x25, [sp, #64]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #80]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #96]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #112]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #128]            ; 16-byte Folded Spill
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset b8, -88
	.cfi_offset b9, -96
	.cfi_offset b10, -104
	.cfi_offset b11, -112
	mul	x23, x3, x2
	cbz	x23, LBB9_8
; %bb.1:
	fmov	d8, d0
	mov	x19, x1
	mov	x20, x0
	mov	w22, #0                         ; =0x0
	mov	x24, #0                         ; =0x0
	movi	d9, #0000000000000000
Lloh0:
	adrp	x21, l_.str@PAGE
Lloh1:
	add	x21, x21, l_.str@PAGEOFF
	movi	d10, #0000000000000000
	b	LBB9_4
LBB9_2:                                 ;   in Loop: Header=BB9_4 Depth=1
	mov	x22, x25
LBB9_3:                                 ;   in Loop: Header=BB9_4 Depth=1
	fadd	s9, s9, s11
	add	x24, x24, #1
	cmp	x23, x24
	b.eq	LBB9_7
LBB9_4:                                 ; =>This Inner Loop Header: Depth=1
	ldr	s0, [x20, x24, lsl #2]
	ldr	s1, [x19, x24, lsl #2]
	fabd	s11, s0, s1
	fcmp	s11, s10
	fcsel	s10, s11, s10, gt
	fcmp	s11, s8
	b.le	LBB9_3
; %bb.5:                                ;   in Loop: Header=BB9_4 Depth=1
	add	w25, w22, #1
	cmp	w22, #3
	b.gt	LBB9_2
; %bb.6:                                ;   in Loop: Header=BB9_4 Depth=1
	fcvt	d0, s0
	fcvt	d1, s1
	fcvt	d2, s11
	stp	d1, d2, [sp, #16]
	str	d0, [sp, #8]
	str	x24, [sp]
	mov	x0, x21
	bl	_printf
	b	LBB9_2
LBB9_7:
	fcvt	d8, s10
	b	LBB9_9
LBB9_8:
	mov	w22, #0                         ; =0x0
	movi	d9, #0000000000000000
	movi	d8, #0000000000000000
LBB9_9:
	ucvtf	s0, x23
	fdiv	s9, s9, s0
	stp	x22, x23, [sp]
Lloh2:
	adrp	x0, l_.str.1@PAGE
Lloh3:
	add	x0, x0, l_.str.1@PAGEOFF
	bl	_printf
	str	d8, [sp]
Lloh4:
	adrp	x0, l_.str.2@PAGE
Lloh5:
	add	x0, x0, l_.str.2@PAGEOFF
	bl	_printf
	fcvt	d0, s9
	str	d0, [sp]
Lloh6:
	adrp	x0, l_.str.3@PAGE
Lloh7:
	add	x0, x0, l_.str.3@PAGEOFF
	bl	_printf
	cmp	w22, #0
	cset	w0, eq
	ldp	x29, x30, [sp, #128]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #112]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #96]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #80]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #64]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #48]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #144
	ret
	.loh AdrpAdd	Lloh0, Lloh1
	.loh AdrpAdd	Lloh6, Lloh7
	.loh AdrpAdd	Lloh4, Lloh5
	.loh AdrpAdd	Lloh2, Lloh3
	.cfi_endproc
                                        ; -- End function
	.globl	_get_time_us                    ; -- Begin function get_time_us
	.p2align	2
_get_time_us:                           ; @get_time_us
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x1, sp
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	mov	w8, #16960                      ; =0x4240
	movk	w8, #15, lsl #16
	ldp	x9, x10, [sp]
	mov	x11, #63439                     ; =0xf7cf
	movk	x11, #58195, lsl #16
	movk	x11, #39845, lsl #32
	movk	x11, #8388, lsl #48
	smulh	x10, x10, x11
	asr	x11, x10, #7
	add	x10, x11, x10, lsr #63
	madd	x0, x9, x8, x10
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_print_matrix_sample            ; -- Begin function print_matrix_sample
	.p2align	2
_print_matrix_sample:                   ; @print_matrix_sample
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, x2
	mov	x21, x1
	mov	x20, x0
	str	x3, [sp]
Lloh8:
	adrp	x0, l_.str.4@PAGE
Lloh9:
	add	x0, x0, l_.str.4@PAGEOFF
	bl	_printf
	cbz	x21, LBB11_25
; %bb.1:
Lloh10:
	adrp	x0, l_.str.5@PAGE
Lloh11:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB11_6
; %bb.2:
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh12:
	adrp	x0, l_.str.6@PAGE
Lloh13:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB11_6
; %bb.3:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh14:
	adrp	x0, l_.str.6@PAGE
Lloh15:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB11_6
; %bb.4:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh16:
	adrp	x0, l_.str.6@PAGE
Lloh17:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB11_6
; %bb.5:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh18:
	adrp	x0, l_.str.6@PAGE
Lloh19:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB11_6:
Lloh20:
	adrp	x0, l_str.75@PAGE
Lloh21:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	cmp	x21, #1
	b.eq	LBB11_25
; %bb.7:
Lloh22:
	adrp	x0, l_.str.5@PAGE
Lloh23:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB11_12
; %bb.8:
	add	x22, x20, x19, lsl #2
	ldr	s0, [x22]
	fcvt	d0, s0
	str	d0, [sp]
Lloh24:
	adrp	x0, l_.str.6@PAGE
Lloh25:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB11_12
; %bb.9:
	ldr	s0, [x22, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh26:
	adrp	x0, l_.str.6@PAGE
Lloh27:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB11_12
; %bb.10:
	ldr	s0, [x22, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh28:
	adrp	x0, l_.str.6@PAGE
Lloh29:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB11_12
; %bb.11:
	ldr	s0, [x22, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh30:
	adrp	x0, l_.str.6@PAGE
Lloh31:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB11_12:
Lloh32:
	adrp	x0, l_str.75@PAGE
Lloh33:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	cmp	x21, #2
	b.eq	LBB11_25
; %bb.13:
Lloh34:
	adrp	x0, l_.str.5@PAGE
Lloh35:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB11_18
; %bb.14:
	add	x22, x20, x19, lsl #3
	ldr	s0, [x22]
	fcvt	d0, s0
	str	d0, [sp]
Lloh36:
	adrp	x0, l_.str.6@PAGE
Lloh37:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB11_18
; %bb.15:
	ldr	s0, [x22, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh38:
	adrp	x0, l_.str.6@PAGE
Lloh39:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB11_18
; %bb.16:
	ldr	s0, [x22, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh40:
	adrp	x0, l_.str.6@PAGE
Lloh41:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB11_18
; %bb.17:
	ldr	s0, [x22, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh42:
	adrp	x0, l_.str.6@PAGE
Lloh43:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB11_18:
Lloh44:
	adrp	x0, l_str.75@PAGE
Lloh45:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	cmp	x21, #3
	b.eq	LBB11_25
; %bb.19:
Lloh46:
	adrp	x0, l_.str.5@PAGE
Lloh47:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB11_24
; %bb.20:
	mov	w8, #12                         ; =0xc
	madd	x20, x19, x8, x20
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh48:
	adrp	x0, l_.str.6@PAGE
Lloh49:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB11_24
; %bb.21:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh50:
	adrp	x0, l_.str.6@PAGE
Lloh51:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB11_24
; %bb.22:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh52:
	adrp	x0, l_.str.6@PAGE
Lloh53:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB11_24
; %bb.23:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh54:
	adrp	x0, l_.str.6@PAGE
Lloh55:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB11_24:
Lloh56:
	adrp	x0, l_str.75@PAGE
Lloh57:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
LBB11_25:
Lloh58:
	adrp	x0, l_str@PAGE
Lloh59:
	add	x0, x0, l_str@PAGEOFF
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #64
	b	_puts
	.loh AdrpAdd	Lloh8, Lloh9
	.loh AdrpAdd	Lloh10, Lloh11
	.loh AdrpAdd	Lloh12, Lloh13
	.loh AdrpAdd	Lloh14, Lloh15
	.loh AdrpAdd	Lloh16, Lloh17
	.loh AdrpAdd	Lloh18, Lloh19
	.loh AdrpAdd	Lloh20, Lloh21
	.loh AdrpAdd	Lloh22, Lloh23
	.loh AdrpAdd	Lloh24, Lloh25
	.loh AdrpAdd	Lloh26, Lloh27
	.loh AdrpAdd	Lloh28, Lloh29
	.loh AdrpAdd	Lloh30, Lloh31
	.loh AdrpAdd	Lloh32, Lloh33
	.loh AdrpAdd	Lloh34, Lloh35
	.loh AdrpAdd	Lloh36, Lloh37
	.loh AdrpAdd	Lloh38, Lloh39
	.loh AdrpAdd	Lloh40, Lloh41
	.loh AdrpAdd	Lloh42, Lloh43
	.loh AdrpAdd	Lloh44, Lloh45
	.loh AdrpAdd	Lloh46, Lloh47
	.loh AdrpAdd	Lloh48, Lloh49
	.loh AdrpAdd	Lloh50, Lloh51
	.loh AdrpAdd	Lloh52, Lloh53
	.loh AdrpAdd	Lloh54, Lloh55
	.loh AdrpAdd	Lloh56, Lloh57
	.loh AdrpAdd	Lloh58, Lloh59
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #368
	stp	d15, d14, [sp, #208]            ; 16-byte Folded Spill
	stp	d13, d12, [sp, #224]            ; 16-byte Folded Spill
	stp	d11, d10, [sp, #240]            ; 16-byte Folded Spill
	stp	d9, d8, [sp, #256]              ; 16-byte Folded Spill
	stp	x28, x27, [sp, #272]            ; 16-byte Folded Spill
	stp	x26, x25, [sp, #288]            ; 16-byte Folded Spill
	stp	x24, x23, [sp, #304]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #320]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #336]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #352]            ; 16-byte Folded Spill
	add	x29, sp, #352
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_offset b8, -104
	.cfi_offset b9, -112
	.cfi_offset b10, -120
	.cfi_offset b11, -128
	.cfi_offset b12, -136
	.cfi_offset b13, -144
	.cfi_offset b14, -152
	.cfi_offset b15, -160
	mov	x20, x1
	mov	x21, x0
Lloh60:
	adrp	x19, l_str.101@PAGE
Lloh61:
	add	x19, x19, l_str.101@PAGEOFF
	mov	x0, x19
	bl	_puts
Lloh62:
	adrp	x0, l_str.77@PAGE
Lloh63:
	add	x0, x0, l_str.77@PAGEOFF
	bl	_puts
	mov	x0, x19
	bl	_puts
	bl	___arm_sme_state
	tbnz	x0, #63, LBB12_2
; %bb.1:
Lloh64:
	adrp	x0, l_str.79@PAGE
Lloh65:
	add	x0, x0, l_str.79@PAGEOFF
	b	LBB12_91
LBB12_2:
	rdsvl	x8, #1
	lsr	x28, x8, #2
Lloh66:
	adrp	x0, l_str.80@PAGE
Lloh67:
	add	x0, x0, l_str.80@PAGEOFF
	bl	_puts
	str	x28, [sp]
Lloh68:
	adrp	x0, l_.str.13@PAGE
Lloh69:
	add	x0, x0, l_.str.13@PAGEOFF
	bl	_printf
	stp	x28, x28, [sp]
Lloh70:
	adrp	x0, l_.str.14@PAGE
Lloh71:
	add	x0, x0, l_.str.14@PAGEOFF
	bl	_printf
	cmp	w21, #4
	b.lt	LBB12_5
; %bb.3:
	ldr	x0, [x20, #8]
	mov	x1, #0                          ; =0x0
	mov	w2, #0                          ; =0x0
	bl	_strtoul
	mov	x22, x0
	ldr	x0, [x20, #16]
	mov	x1, #0                          ; =0x0
	mov	w2, #0                          ; =0x0
	bl	_strtoul
	mov	x27, x0
	ldr	x0, [x20, #24]
	mov	x1, #0                          ; =0x0
	mov	w2, #0                          ; =0x0
	bl	_strtoul
	mov	x19, x0
	cmp	w21, #4
	b.ne	LBB12_6
; %bb.4:
	mov	w20, #10                        ; =0xa
	b	LBB12_7
LBB12_5:
	mov	w20, #10                        ; =0xa
	mov	w19, #64                        ; =0x40
	mov	w27, #240                       ; =0xf0
	mov	w22, #256                       ; =0x100
	b	LBB12_7
LBB12_6:
	ldr	x0, [x20, #32]
	bl	_atoi
	mov	x20, x0
LBB12_7:
	stp	x22, x19, [sp, #32]
	stp	x27, x19, [sp, #16]
	stp	x22, x27, [sp]
Lloh72:
	adrp	x0, l_.str.15@PAGE
Lloh73:
	add	x0, x0, l_.str.15@PAGEOFF
	bl	_printf
	str	x20, [sp, #136]                 ; 8-byte Folded Spill
	str	x20, [sp]
Lloh74:
	adrp	x0, l_.str.16@PAGE
Lloh75:
	add	x0, x0, l_.str.16@PAGEOFF
	bl	_printf
	add	x8, x28, x19
	sub	x8, x8, #1
	udiv	x9, x8, x28
	mov	w8, #4                          ; =0x4
	cmp	x9, #4
	mov	x23, x22
	str	x9, [sp, #64]                   ; 8-byte Folded Spill
	csel	x8, x9, x8, lo
	str	x8, [sp, #80]                   ; 8-byte Folded Spill
	str	x8, [sp]
Lloh76:
	adrp	x0, l_.str.17@PAGE
Lloh77:
	add	x0, x0, l_.str.17@PAGEOFF
	bl	_printf
Lloh78:
	adrp	x0, l_str.81@PAGE
Lloh79:
	add	x0, x0, l_str.81@PAGEOFF
	bl	_puts
	mul	x21, x27, x22
	lsl	x1, x21, #2
	mov	w0, #64                         ; =0x40
	bl	_aligned_alloc
	mov	x26, x0
	mul	x20, x19, x27
	lsl	x1, x20, #2
	mov	w0, #64                         ; =0x40
	bl	_aligned_alloc
	mov	x22, x0
	str	x23, [sp, #176]                 ; 8-byte Folded Spill
	mul	x8, x23, x19
	lsl	x25, x8, #2
	mov	w0, #64                         ; =0x40
	mov	x1, x25
	bl	_aligned_alloc
	mov	x23, x0
	mov	w0, #64                         ; =0x40
	mov	x1, x25
	bl	_aligned_alloc
	str	x0, [sp, #96]                   ; 8-byte Folded Spill
	mov	w0, #64                         ; =0x40
	mov	x1, x25
	bl	_aligned_alloc
	mov	x8, x0
	mov	w0, #64                         ; =0x40
	mov	x1, x25
	mov	x24, x8
	bl	_aligned_alloc
	cbz	x26, LBB12_90
; %bb.8:
	cbz	x22, LBB12_90
; %bb.9:
	cbz	x23, LBB12_90
; %bb.10:
	ldr	x8, [sp, #96]                   ; 8-byte Folded Reload
	cbz	x8, LBB12_90
; %bb.11:
	cbz	x24, LBB12_90
; %bb.12:
	cbz	x0, LBB12_90
; %bb.13:
	mov	x25, x26
	str	x0, [sp, #88]                   ; 8-byte Folded Spill
	str	x24, [sp, #72]                  ; 8-byte Folded Spill
	str	x23, [sp, #128]                 ; 8-byte Folded Spill
	str	x22, [sp, #144]                 ; 8-byte Folded Spill
Lloh80:
	adrp	x0, l_str.83@PAGE
Lloh81:
	add	x0, x0, l_str.83@PAGEOFF
	bl	_puts
	mov	w0, #42                         ; =0x2a
	bl	_srand
	cbz	x21, LBB12_16
; %bb.14:
	mov	w22, #19923                     ; =0x4dd3
	movk	w22, #4194, lsl #16
	mov	w23, #1000                      ; =0x3e8
	mov	w8, #1120403456                 ; =0x42c80000
	fmov	s8, w8
	fmov	s9, #-5.00000000
	mov	x24, x25
LBB12_15:                               ; =>This Inner Loop Header: Depth=1
	bl	_rand
	smull	x8, w0, w22
	asr	x8, x8, #38
	add	w8, w8, w8, lsr #31
	msub	w8, w8, w23, w0
	scvtf	s0, w8
	fdiv	s0, s0, s8
	fadd	s0, s0, s9
	str	s0, [x24], #4
	subs	x21, x21, #1
	b.ne	LBB12_15
LBB12_16:
	mov	w0, #123                        ; =0x7b
	bl	_srand
	cbz	x20, LBB12_19
; %bb.17:
	mov	w21, #19923                     ; =0x4dd3
	movk	w21, #4194, lsl #16
	mov	w22, #1000                      ; =0x3e8
	mov	w8, #1120403456                 ; =0x42c80000
	fmov	s8, w8
	fmov	s9, #-5.00000000
	ldr	x23, [sp, #144]                 ; 8-byte Folded Reload
LBB12_18:                               ; =>This Inner Loop Header: Depth=1
	bl	_rand
	smull	x8, w0, w21
	asr	x8, x8, #38
	add	w8, w8, w8, lsr #31
	msub	w8, w8, w22, w0
	scvtf	s0, w8
	fdiv	s0, s0, s8
	fadd	s0, s0, s9
	str	s0, [x23], #4
	subs	x20, x20, #1
	b.ne	LBB12_18
LBB12_19:
Lloh82:
	adrp	x8, l_.str.21@PAGE
Lloh83:
	add	x8, x8, l_.str.21@PAGEOFF
	str	x8, [sp]
Lloh84:
	adrp	x0, l_.str.4@PAGE
Lloh85:
	add	x0, x0, l_.str.4@PAGEOFF
	bl	_printf
	ldr	x8, [sp, #176]                  ; 8-byte Folded Reload
	ldr	x21, [sp, #136]                 ; 8-byte Folded Reload
	mov	x22, x25
	cbz	x8, LBB12_44
; %bb.20:
Lloh86:
	adrp	x0, l_.str.5@PAGE
Lloh87:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x27, LBB12_25
; %bb.21:
	ldr	s0, [x22]
	fcvt	d0, s0
	str	d0, [sp]
Lloh88:
	adrp	x0, l_.str.6@PAGE
Lloh89:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #1
	b.eq	LBB12_25
; %bb.22:
	ldr	s0, [x22, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh90:
	adrp	x0, l_.str.6@PAGE
Lloh91:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #2
	b.eq	LBB12_25
; %bb.23:
	ldr	s0, [x22, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh92:
	adrp	x0, l_.str.6@PAGE
Lloh93:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #3
	b.eq	LBB12_25
; %bb.24:
	ldr	s0, [x22, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh94:
	adrp	x0, l_.str.6@PAGE
Lloh95:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_25:
Lloh96:
	adrp	x0, l_str.75@PAGE
Lloh97:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	ldr	x8, [sp, #176]                  ; 8-byte Folded Reload
	cmp	x8, #1
	b.eq	LBB12_44
; %bb.26:
Lloh98:
	adrp	x0, l_.str.5@PAGE
Lloh99:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x27, LBB12_31
; %bb.27:
	add	x20, x22, x27, lsl #2
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh100:
	adrp	x0, l_.str.6@PAGE
Lloh101:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #1
	b.eq	LBB12_31
; %bb.28:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh102:
	adrp	x0, l_.str.6@PAGE
Lloh103:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #2
	b.eq	LBB12_31
; %bb.29:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh104:
	adrp	x0, l_.str.6@PAGE
Lloh105:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #3
	b.eq	LBB12_31
; %bb.30:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh106:
	adrp	x0, l_.str.6@PAGE
Lloh107:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_31:
Lloh108:
	adrp	x0, l_str.75@PAGE
Lloh109:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	ldr	x8, [sp, #176]                  ; 8-byte Folded Reload
	cmp	x8, #2
	b.eq	LBB12_44
; %bb.32:
Lloh110:
	adrp	x0, l_.str.5@PAGE
Lloh111:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x27, LBB12_37
; %bb.33:
	add	x20, x22, x27, lsl #3
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh112:
	adrp	x0, l_.str.6@PAGE
Lloh113:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #1
	b.eq	LBB12_37
; %bb.34:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh114:
	adrp	x0, l_.str.6@PAGE
Lloh115:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #2
	b.eq	LBB12_37
; %bb.35:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh116:
	adrp	x0, l_.str.6@PAGE
Lloh117:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #3
	b.eq	LBB12_37
; %bb.36:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh118:
	adrp	x0, l_.str.6@PAGE
Lloh119:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_37:
Lloh120:
	adrp	x0, l_str.75@PAGE
Lloh121:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	ldr	x8, [sp, #176]                  ; 8-byte Folded Reload
	cmp	x8, #3
	b.eq	LBB12_44
; %bb.38:
Lloh122:
	adrp	x0, l_.str.5@PAGE
Lloh123:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x27, LBB12_43
; %bb.39:
	mov	w8, #12                         ; =0xc
	madd	x20, x27, x8, x22
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh124:
	adrp	x0, l_.str.6@PAGE
Lloh125:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #1
	b.eq	LBB12_43
; %bb.40:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh126:
	adrp	x0, l_.str.6@PAGE
Lloh127:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #2
	b.eq	LBB12_43
; %bb.41:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh128:
	adrp	x0, l_.str.6@PAGE
Lloh129:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x27, #3
	b.eq	LBB12_43
; %bb.42:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh130:
	adrp	x0, l_.str.6@PAGE
Lloh131:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_43:
Lloh132:
	adrp	x0, l_str.75@PAGE
Lloh133:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
LBB12_44:
Lloh134:
	adrp	x0, l_str@PAGE
Lloh135:
	add	x0, x0, l_str@PAGEOFF
	bl	_puts
Lloh136:
	adrp	x8, l_.str.22@PAGE
Lloh137:
	add	x8, x8, l_.str.22@PAGEOFF
	str	x8, [sp]
Lloh138:
	adrp	x0, l_.str.4@PAGE
Lloh139:
	add	x0, x0, l_.str.4@PAGEOFF
	bl	_printf
	cbz	x27, LBB12_69
; %bb.45:
Lloh140:
	adrp	x0, l_.str.5@PAGE
Lloh141:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB12_50
; %bb.46:
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	ldr	s0, [x8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh142:
	adrp	x0, l_.str.6@PAGE
Lloh143:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB12_50
; %bb.47:
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	ldr	s0, [x8, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh144:
	adrp	x0, l_.str.6@PAGE
Lloh145:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB12_50
; %bb.48:
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	ldr	s0, [x8, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh146:
	adrp	x0, l_.str.6@PAGE
Lloh147:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB12_50
; %bb.49:
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	ldr	s0, [x8, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh148:
	adrp	x0, l_.str.6@PAGE
Lloh149:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_50:
Lloh150:
	adrp	x0, l_str.75@PAGE
Lloh151:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	cmp	x27, #1
	b.eq	LBB12_69
; %bb.51:
Lloh152:
	adrp	x0, l_.str.5@PAGE
Lloh153:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB12_56
; %bb.52:
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	add	x20, x8, x19, lsl #2
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh154:
	adrp	x0, l_.str.6@PAGE
Lloh155:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB12_56
; %bb.53:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh156:
	adrp	x0, l_.str.6@PAGE
Lloh157:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB12_56
; %bb.54:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh158:
	adrp	x0, l_.str.6@PAGE
Lloh159:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB12_56
; %bb.55:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh160:
	adrp	x0, l_.str.6@PAGE
Lloh161:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_56:
Lloh162:
	adrp	x0, l_str.75@PAGE
Lloh163:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	cmp	x27, #2
	b.eq	LBB12_69
; %bb.57:
Lloh164:
	adrp	x0, l_.str.5@PAGE
Lloh165:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB12_62
; %bb.58:
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	add	x20, x8, x19, lsl #3
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh166:
	adrp	x0, l_.str.6@PAGE
Lloh167:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB12_62
; %bb.59:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh168:
	adrp	x0, l_.str.6@PAGE
Lloh169:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB12_62
; %bb.60:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh170:
	adrp	x0, l_.str.6@PAGE
Lloh171:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB12_62
; %bb.61:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh172:
	adrp	x0, l_.str.6@PAGE
Lloh173:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_62:
Lloh174:
	adrp	x0, l_str.75@PAGE
Lloh175:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
	cmp	x27, #3
	b.eq	LBB12_69
; %bb.63:
Lloh176:
	adrp	x0, l_.str.5@PAGE
Lloh177:
	add	x0, x0, l_.str.5@PAGEOFF
	bl	_printf
	cbz	x19, LBB12_68
; %bb.64:
	mov	w8, #12                         ; =0xc
	ldr	x9, [sp, #144]                  ; 8-byte Folded Reload
	madd	x20, x19, x8, x9
	ldr	s0, [x20]
	fcvt	d0, s0
	str	d0, [sp]
Lloh178:
	adrp	x0, l_.str.6@PAGE
Lloh179:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #1
	b.eq	LBB12_68
; %bb.65:
	ldr	s0, [x20, #4]
	fcvt	d0, s0
	str	d0, [sp]
Lloh180:
	adrp	x0, l_.str.6@PAGE
Lloh181:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #2
	b.eq	LBB12_68
; %bb.66:
	ldr	s0, [x20, #8]
	fcvt	d0, s0
	str	d0, [sp]
Lloh182:
	adrp	x0, l_.str.6@PAGE
Lloh183:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
	cmp	x19, #3
	b.eq	LBB12_68
; %bb.67:
	ldr	s0, [x20, #12]
	fcvt	d0, s0
	str	d0, [sp]
Lloh184:
	adrp	x0, l_.str.6@PAGE
Lloh185:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_printf
LBB12_68:
Lloh186:
	adrp	x0, l_str.75@PAGE
Lloh187:
	add	x0, x0, l_str.75@PAGEOFF
	bl	_puts
LBB12_69:
Lloh188:
	adrp	x0, l_str@PAGE
Lloh189:
	add	x0, x0, l_str@PAGEOFF
	bl	_puts
Lloh190:
	adrp	x0, l_str.103@PAGE
Lloh191:
	add	x0, x0, l_str.103@PAGEOFF
	bl	_puts
Lloh192:
	adrp	x0, l_str.85@PAGE
Lloh193:
	add	x0, x0, l_str.85@PAGEOFF
	bl	_puts
	lsl	x20, x27, #2
	lsl	x25, x19, #2
	ldr	x6, [sp, #144]                  ; 8-byte Folded Reload
	ldr	x7, [sp, #128]                  ; 8-byte Folded Reload
	ldr	x8, [sp, #176]                  ; 8-byte Folded Reload
	cbz	x8, LBB12_93
; %bb.70:
	mov	x8, #0                          ; =0x0
	cmp	x27, #3
	ccmp	x19, #1, #0, hi
	cset	w9, eq
	and	x10, x27, #0xfffffffffffffff0
	and	x11, x27, #0xc
	and	x12, x27, #0xfffffffffffffffc
	add	x13, x22, #32
	add	x14, x6, #32
	neg	x15, x12
	mov	x16, x22
	b	LBB12_72
LBB12_71:                               ;   in Loop: Header=BB12_72 Depth=1
	add	x8, x8, #1
	add	x13, x13, x20
	add	x16, x16, x20
	ldr	x17, [sp, #176]                 ; 8-byte Folded Reload
	cmp	x8, x17
	b.eq	LBB12_93
LBB12_72:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB12_76 Depth 2
                                        ;       Child Loop BB12_82 Depth 3
                                        ;       Child Loop BB12_86 Depth 3
                                        ;       Child Loop BB12_89 Depth 3
	cbz	x19, LBB12_71
; %bb.73:                               ;   in Loop: Header=BB12_72 Depth=1
	mov	x17, #0                         ; =0x0
	mul	x0, x8, x19
	add	x0, x7, x0, lsl #2
	mov	x1, x6
	mov	x2, x14
	b	LBB12_76
LBB12_74:                               ;   in Loop: Header=BB12_76 Depth=2
	movi	d0, #0000000000000000
LBB12_75:                               ;   in Loop: Header=BB12_76 Depth=2
	str	s0, [x0, x17, lsl #2]
	add	x17, x17, #1
	add	x2, x2, #4
	add	x1, x1, #4
	cmp	x17, x19
	b.eq	LBB12_71
LBB12_76:                               ;   Parent Loop BB12_72 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB12_82 Depth 3
                                        ;       Child Loop BB12_86 Depth 3
                                        ;       Child Loop BB12_89 Depth 3
	cbz	x27, LBB12_74
; %bb.77:                               ;   in Loop: Header=BB12_76 Depth=2
	tbz	w9, #0, LBB12_80
; %bb.78:                               ;   in Loop: Header=BB12_76 Depth=2
	cmp	x27, #16
	b.hs	LBB12_81
; %bb.79:                               ;   in Loop: Header=BB12_76 Depth=2
	mov	x4, #0                          ; =0x0
	movi	d0, #0000000000000000
	b	LBB12_85
LBB12_80:                               ;   in Loop: Header=BB12_76 Depth=2
	mov	x3, #0                          ; =0x0
	movi	d0, #0000000000000000
	b	LBB12_88
LBB12_81:                               ;   in Loop: Header=BB12_76 Depth=2
	movi	d0, #0000000000000000
	mov	x3, x2
	mov	x4, x13
	mov	x5, x10
LBB12_82:                               ;   Parent Loop BB12_72 Depth=1
                                        ;     Parent Loop BB12_76 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldp	q1, q2, [x4, #-32]
	ldp	q3, q4, [x4], #64
	ldp	q5, q6, [x3, #-32]
	ldp	q7, q16, [x3], #64
	fmul.4s	v1, v1, v5
	mov	s5, v1[3]
	mov	s17, v1[2]
	mov	s18, v1[1]
	fmul.4s	v2, v2, v6
	mov	s6, v2[3]
	mov	s19, v2[2]
	mov	s20, v2[1]
	fmul.4s	v3, v3, v7
	mov	s7, v3[3]
	mov	s21, v3[2]
	mov	s22, v3[1]
	fmul.4s	v4, v4, v16
	mov	s16, v4[3]
	mov	s23, v4[2]
	mov	s24, v4[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s18
	fadd	s0, s0, s17
	fadd	s0, s0, s5
	fadd	s0, s0, s2
	fadd	s0, s0, s20
	fadd	s0, s0, s19
	fadd	s0, s0, s6
	fadd	s0, s0, s3
	fadd	s0, s0, s22
	fadd	s0, s0, s21
	fadd	s0, s0, s7
	fadd	s0, s0, s4
	fadd	s0, s0, s24
	fadd	s0, s0, s23
	fadd	s0, s0, s16
	subs	x5, x5, #16
	b.ne	LBB12_82
; %bb.83:                               ;   in Loop: Header=BB12_76 Depth=2
	cmp	x27, x10
	b.eq	LBB12_75
; %bb.84:                               ;   in Loop: Header=BB12_76 Depth=2
	mov	x3, x10
	mov	x4, x10
	cbz	x11, LBB12_88
LBB12_85:                               ;   in Loop: Header=BB12_76 Depth=2
	add	x3, x15, x4
	lsl	x5, x4, #2
	add	x4, x1, x5
	add	x5, x16, x5
LBB12_86:                               ;   Parent Loop BB12_72 Depth=1
                                        ;     Parent Loop BB12_76 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	q1, [x5], #16
	ldr	q2, [x4], #16
	fmul.4s	v1, v1, v2
	mov	s2, v1[3]
	mov	s3, v1[2]
	mov	s4, v1[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s4
	fadd	s0, s0, s3
	fadd	s0, s0, s2
	adds	x3, x3, #4
	b.ne	LBB12_86
; %bb.87:                               ;   in Loop: Header=BB12_76 Depth=2
	mov	x3, x12
	cmp	x27, x12
	b.eq	LBB12_75
LBB12_88:                               ;   in Loop: Header=BB12_76 Depth=2
	mul	x4, x25, x3
LBB12_89:                               ;   Parent Loop BB12_72 Depth=1
                                        ;     Parent Loop BB12_76 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldr	s1, [x16, x3, lsl #2]
	ldr	s2, [x1, x4]
	fmadd	s0, s1, s2, s0
	add	x3, x3, #1
	add	x4, x4, x25
	cmp	x27, x3
	b.ne	LBB12_89
	b	LBB12_75
LBB12_90:
Lloh194:
	adrp	x0, l_str.82@PAGE
Lloh195:
	add	x0, x0, l_str.82@PAGEOFF
LBB12_91:
	bl	_puts
	mov	w0, #1                          ; =0x1
LBB12_92:
	ldp	x29, x30, [sp, #352]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #336]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #320]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #304]            ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #288]            ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #272]            ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #256]              ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #240]            ; 16-byte Folded Reload
	ldp	d13, d12, [sp, #224]            ; 16-byte Folded Reload
	ldp	d15, d14, [sp, #208]            ; 16-byte Folded Reload
	add	sp, sp, #368
	ret
LBB12_93:
	movi	d8, #0000000000000000
	movi	d0, #0000000000000000
	cmp	w21, #1
	str	x22, [sp, #112]                 ; 8-byte Folded Spill
	ldr	x26, [sp, #176]                 ; 8-byte Folded Reload
	str	x28, [sp, #56]                  ; 8-byte Folded Spill
	b.lt	LBB12_118
; %bb.94:
	mov	x9, #0                          ; =0x0
	mov	w10, #0                         ; =0x0
	cmp	x27, #3
	ccmp	x19, #1, #0, hi
	mov	x8, x22
	cset	w28, eq
	and	x22, x27, #0xfffffffffffffff0
	and	x21, x27, #0xc
	and	x24, x27, #0xfffffffffffffffc
	add	x8, x8, #32
	str	x8, [sp, #104]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	add	x8, x8, #32
	str	x8, [sp, #120]                  ; 8-byte Folded Spill
	neg	x23, x24
	b	LBB12_96
LBB12_95:                               ;   in Loop: Header=BB12_96 Depth=1
	ldp	x9, x8, [x29, #-168]
	str	x9, [sp, #152]                  ; 8-byte Folded Spill
	smulh	x8, x8, x2
	asr	x9, x8, #7
	add	x26, x9, x8, lsr #63
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldp	x8, x9, [x29, #-168]
	mov	x10, #63439                     ; =0xf7cf
	movk	x10, #58195, lsl #16
	movk	x10, #39845, lsl #32
	movk	x10, #8388, lsl #48
	smulh	x9, x9, x10
	asr	x10, x9, #7
	add	x9, x10, x9, lsr #63
	ldr	x10, [sp, #152]                 ; 8-byte Folded Reload
	sub	x8, x8, x10
	ldr	x10, [sp, #168]                 ; 8-byte Folded Reload
	add	x10, x26, x10
	ldr	x26, [sp, #176]                 ; 8-byte Folded Reload
	add	x9, x10, x9
	mov	w10, #16960                     ; =0x4240
	movk	w10, #15, lsl #16
	madd	x9, x8, x10, x9
	ldr	w10, [sp, #164]                 ; 4-byte Folded Reload
	add	w10, w10, #1
	ldr	x8, [sp, #136]                  ; 8-byte Folded Reload
	cmp	w10, w8
	b.eq	LBB12_117
LBB12_96:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB12_99 Depth 2
                                        ;       Child Loop BB12_103 Depth 3
                                        ;         Child Loop BB12_109 Depth 4
                                        ;         Child Loop BB12_113 Depth 4
                                        ;         Child Loop BB12_116 Depth 4
	str	w10, [sp, #164]                 ; 4-byte Folded Spill
	str	x9, [sp, #168]                  ; 8-byte Folded Spill
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldr	x0, [sp, #144]                  ; 8-byte Folded Reload
	ldp	x3, x1, [sp, #120]              ; 16-byte Folded Reload
	mov	x2, #2097                       ; =0x831
	movk	x2, #7340, lsl #16
	movk	x2, #25690, lsl #32
	movk	x2, #57147, lsl #48
	cbz	x26, LBB12_95
; %bb.97:                               ;   in Loop: Header=BB12_96 Depth=1
	mov	x8, #0                          ; =0x0
	ldp	x10, x9, [sp, #104]             ; 16-byte Folded Reload
	b	LBB12_99
LBB12_98:                               ;   in Loop: Header=BB12_99 Depth=2
	add	x8, x8, #1
	add	x10, x10, x20
	add	x9, x9, x20
	cmp	x8, x26
	b.eq	LBB12_95
LBB12_99:                               ;   Parent Loop BB12_96 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB12_103 Depth 3
                                        ;         Child Loop BB12_109 Depth 4
                                        ;         Child Loop BB12_113 Depth 4
                                        ;         Child Loop BB12_116 Depth 4
	cbz	x19, LBB12_98
; %bb.100:                              ;   in Loop: Header=BB12_99 Depth=2
	mov	x11, #0                         ; =0x0
	mul	x12, x8, x19
	add	x12, x1, x12, lsl #2
	mov	x13, x0
	mov	x14, x3
	b	LBB12_103
LBB12_101:                              ;   in Loop: Header=BB12_103 Depth=3
	movi	d0, #0000000000000000
LBB12_102:                              ;   in Loop: Header=BB12_103 Depth=3
	str	s0, [x12, x11, lsl #2]
	add	x11, x11, #1
	add	x14, x14, #4
	add	x13, x13, #4
	cmp	x11, x19
	b.eq	LBB12_98
LBB12_103:                              ;   Parent Loop BB12_96 Depth=1
                                        ;     Parent Loop BB12_99 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB12_109 Depth 4
                                        ;         Child Loop BB12_113 Depth 4
                                        ;         Child Loop BB12_116 Depth 4
	cbz	x27, LBB12_101
; %bb.104:                              ;   in Loop: Header=BB12_103 Depth=3
	tbz	w28, #0, LBB12_107
; %bb.105:                              ;   in Loop: Header=BB12_103 Depth=3
	cmp	x27, #16
	b.hs	LBB12_108
; %bb.106:                              ;   in Loop: Header=BB12_103 Depth=3
	mov	x16, #0                         ; =0x0
	movi	d0, #0000000000000000
	b	LBB12_112
LBB12_107:                              ;   in Loop: Header=BB12_103 Depth=3
	mov	x15, #0                         ; =0x0
	movi	d0, #0000000000000000
	b	LBB12_115
LBB12_108:                              ;   in Loop: Header=BB12_103 Depth=3
	movi	d0, #0000000000000000
	mov	x15, x14
	mov	x16, x10
	mov	x17, x22
LBB12_109:                              ;   Parent Loop BB12_96 Depth=1
                                        ;     Parent Loop BB12_99 Depth=2
                                        ;       Parent Loop BB12_103 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ldp	q1, q2, [x16, #-32]
	ldp	q3, q4, [x16], #64
	ldp	q5, q6, [x15, #-32]
	ldp	q7, q16, [x15], #64
	fmul.4s	v1, v1, v5
	mov	s5, v1[3]
	mov	s17, v1[2]
	mov	s18, v1[1]
	fmul.4s	v2, v2, v6
	mov	s6, v2[3]
	mov	s19, v2[2]
	mov	s20, v2[1]
	fmul.4s	v3, v3, v7
	mov	s7, v3[3]
	mov	s21, v3[2]
	mov	s22, v3[1]
	fmul.4s	v4, v4, v16
	mov	s16, v4[3]
	mov	s23, v4[2]
	mov	s24, v4[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s18
	fadd	s0, s0, s17
	fadd	s0, s0, s5
	fadd	s0, s0, s2
	fadd	s0, s0, s20
	fadd	s0, s0, s19
	fadd	s0, s0, s6
	fadd	s0, s0, s3
	fadd	s0, s0, s22
	fadd	s0, s0, s21
	fadd	s0, s0, s7
	fadd	s0, s0, s4
	fadd	s0, s0, s24
	fadd	s0, s0, s23
	fadd	s0, s0, s16
	subs	x17, x17, #16
	b.ne	LBB12_109
; %bb.110:                              ;   in Loop: Header=BB12_103 Depth=3
	cmp	x27, x22
	b.eq	LBB12_102
; %bb.111:                              ;   in Loop: Header=BB12_103 Depth=3
	mov	x15, x22
	mov	x16, x22
	cbz	x21, LBB12_115
LBB12_112:                              ;   in Loop: Header=BB12_103 Depth=3
	add	x15, x23, x16
	lsl	x17, x16, #2
	add	x16, x13, x17
	add	x17, x9, x17
LBB12_113:                              ;   Parent Loop BB12_96 Depth=1
                                        ;     Parent Loop BB12_99 Depth=2
                                        ;       Parent Loop BB12_103 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ldr	q1, [x17], #16
	ldr	q2, [x16], #16
	fmul.4s	v1, v1, v2
	mov	s2, v1[3]
	mov	s3, v1[2]
	mov	s4, v1[1]
	fadd	s0, s0, s1
	fadd	s0, s0, s4
	fadd	s0, s0, s3
	fadd	s0, s0, s2
	adds	x15, x15, #4
	b.ne	LBB12_113
; %bb.114:                              ;   in Loop: Header=BB12_103 Depth=3
	mov	x15, x24
	cmp	x27, x24
	b.eq	LBB12_102
LBB12_115:                              ;   in Loop: Header=BB12_103 Depth=3
	mul	x16, x25, x15
LBB12_116:                              ;   Parent Loop BB12_96 Depth=1
                                        ;     Parent Loop BB12_99 Depth=2
                                        ;       Parent Loop BB12_103 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ldr	s1, [x9, x15, lsl #2]
	ldr	s2, [x13, x16]
	fmadd	s0, s1, s2, s0
	add	x15, x15, #1
	add	x16, x16, x25
	cmp	x27, x15
	b.ne	LBB12_116
	b	LBB12_102
LBB12_117:
	ucvtf	s0, x9
	ldr	x22, [sp, #112]                 ; 8-byte Folded Reload
	ldr	x21, [sp, #136]                 ; 8-byte Folded Reload
LBB12_118:
	scvtf	s14, w21
	fdiv	s0, s0, s14
	str	s0, [sp, #164]                  ; 4-byte Folded Spill
	fcvt	d9, s0
	str	d9, [sp]
Lloh196:
	adrp	x0, l_.str.25@PAGE
Lloh197:
	add	x0, x0, l_.str.25@PAGEOFF
	bl	_printf
Lloh198:
	adrp	x0, l_str.103@PAGE
Lloh199:
	add	x0, x0, l_str.103@PAGEOFF
	bl	_puts
Lloh200:
	adrp	x0, l_str.87@PAGE
Lloh201:
	add	x0, x0, l_str.87@PAGEOFF
	bl	_puts
	mov	x0, x22
	ldr	x1, [sp, #144]                  ; 8-byte Folded Reload
	ldr	x23, [sp, #96]                  ; 8-byte Folded Reload
	mov	x2, x23
	mov	x3, x26
	mov	x4, x27
	mov	x5, x19
	bl	_matmul_sme_cpu_preprocess
	cmp	w21, #1
	b.lt	LBB12_122
; %bb.119:
	mov	x20, #0                         ; =0x0
                                        ; kill: def $w21 killed $w21 killed $x21
	mov	x25, x22
	ldr	x24, [sp, #144]                 ; 8-byte Folded Reload
	mov	x28, x23
LBB12_120:                              ; =>This Inner Loop Header: Depth=1
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldp	x22, x8, [x29, #-168]
	mov	x9, #2097                       ; =0x831
	movk	x9, #7340, lsl #16
	movk	x9, #25690, lsl #32
	movk	x9, #57147, lsl #48
	smulh	x8, x8, x9
	asr	x9, x8, #7
	add	x23, x9, x8, lsr #63
	mov	x0, x25
	mov	x1, x24
	mov	x2, x28
	mov	x3, x26
	mov	x4, x27
	mov	x5, x19
	bl	_matmul_sme_cpu_preprocess
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldp	x8, x9, [x29, #-168]
	mov	x10, #63439                     ; =0xf7cf
	movk	x10, #58195, lsl #16
	movk	x10, #39845, lsl #32
	movk	x10, #8388, lsl #48
	smulh	x9, x9, x10
	asr	x10, x9, #7
	add	x9, x10, x9, lsr #63
	sub	x8, x8, x22
	add	x10, x23, x20
	add	x9, x10, x9
	mov	w10, #16960                     ; =0x4240
	movk	w10, #15, lsl #16
	madd	x20, x8, x10, x9
	subs	w21, w21, #1
	b.ne	LBB12_120
; %bb.121:
	ucvtf	s8, x20
	ldr	x21, [sp, #136]                 ; 8-byte Folded Reload
	mov	x22, x25
	mov	x23, x28
LBB12_122:
	fdiv	s0, s8, s14
	str	s0, [sp, #176]                  ; 4-byte Folded Spill
	fcvt	d13, s0
	str	d13, [sp]
Lloh202:
	adrp	x0, l_.str.25@PAGE
Lloh203:
	add	x0, x0, l_.str.25@PAGEOFF
	bl	_printf
Lloh204:
	adrp	x0, l_str.103@PAGE
Lloh205:
	add	x0, x0, l_str.103@PAGEOFF
	bl	_puts
Lloh206:
	adrp	x0, l_str.89@PAGE
Lloh207:
	add	x0, x0, l_str.89@PAGEOFF
	bl	_puts
	mov	x0, x22
	ldr	x1, [sp, #144]                  ; 8-byte Folded Reload
	ldr	x24, [sp, #72]                  ; 8-byte Folded Reload
	mov	x2, x24
	mov	x3, x26
	mov	x4, x27
	mov	x5, x19
	bl	_matmul_sme_sme_preprocess
	movi	d8, #0000000000000000
	movi	d0, #0000000000000000
	cmp	w21, #1
	b.lt	LBB12_126
; %bb.123:
	mov	x20, #0                         ; =0x0
                                        ; kill: def $w21 killed $w21 killed $x21
	mov	x28, x26
	mov	x26, x24
	mov	x25, x22
	ldr	x24, [sp, #144]                 ; 8-byte Folded Reload
LBB12_124:                              ; =>This Inner Loop Header: Depth=1
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldp	x22, x8, [x29, #-168]
	mov	x9, #2097                       ; =0x831
	movk	x9, #7340, lsl #16
	movk	x9, #25690, lsl #32
	movk	x9, #57147, lsl #48
	smulh	x8, x8, x9
	asr	x9, x8, #7
	add	x23, x9, x8, lsr #63
	mov	x0, x25
	mov	x1, x24
	mov	x2, x26
	mov	x3, x28
	mov	x4, x27
	mov	x5, x19
	bl	_matmul_sme_sme_preprocess
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldp	x8, x9, [x29, #-168]
	mov	x10, #63439                     ; =0xf7cf
	movk	x10, #58195, lsl #16
	movk	x10, #39845, lsl #32
	movk	x10, #8388, lsl #48
	smulh	x9, x9, x10
	asr	x10, x9, #7
	add	x9, x10, x9, lsr #63
	sub	x8, x8, x22
	add	x10, x23, x20
	add	x9, x10, x9
	mov	w10, #16960                     ; =0x4240
	movk	w10, #15, lsl #16
	madd	x20, x8, x10, x9
	subs	w21, w21, #1
	b.ne	LBB12_124
; %bb.125:
	ucvtf	s0, x20
	mov	x24, x26
	mov	x26, x28
	ldr	x21, [sp, #136]                 ; 8-byte Folded Reload
	mov	x22, x25
	ldr	x23, [sp, #96]                  ; 8-byte Folded Reload
LBB12_126:
	fdiv	s0, s0, s14
	str	s0, [sp, #168]                  ; 4-byte Folded Spill
	fcvt	d15, s0
	str	d15, [sp]
Lloh208:
	adrp	x0, l_.str.25@PAGE
Lloh209:
	add	x0, x0, l_.str.25@PAGEOFF
	bl	_printf
Lloh210:
	adrp	x0, l_str.103@PAGE
Lloh211:
	add	x0, x0, l_str.103@PAGEOFF
	bl	_puts
Lloh212:
	adrp	x0, l_str.91@PAGE
Lloh213:
	add	x0, x0, l_str.91@PAGEOFF
	bl	_puts
	mov	x0, x22
	ldr	x1, [sp, #144]                  ; 8-byte Folded Reload
	ldr	x2, [sp, #88]                   ; 8-byte Folded Reload
	mov	x3, x26
	mov	x4, x27
	mov	x5, x19
	bl	_matmul_sme_4tiles
	cmp	w21, #1
	b.lt	LBB12_130
; %bb.127:
	mov	x20, #0                         ; =0x0
	ldr	x23, [sp, #144]                 ; 8-byte Folded Reload
	mov	x28, x26
	ldr	x26, [sp, #88]                  ; 8-byte Folded Reload
	mov	x25, x22
LBB12_128:                              ; =>This Inner Loop Header: Depth=1
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	mov	x24, x21
	ldp	x21, x8, [x29, #-168]
	mov	x9, #2097                       ; =0x831
	movk	x9, #7340, lsl #16
	movk	x9, #25690, lsl #32
	movk	x9, #57147, lsl #48
	smulh	x8, x8, x9
	asr	x9, x8, #7
	add	x22, x9, x8, lsr #63
	mov	x0, x25
	mov	x1, x23
	mov	x2, x26
	mov	x3, x28
	mov	x4, x27
	mov	x5, x19
	bl	_matmul_sme_4tiles
	sub	x1, x29, #168
	mov	w0, #6                          ; =0x6
	bl	_clock_gettime
	ldp	x8, x9, [x29, #-168]
	mov	x10, #63439                     ; =0xf7cf
	movk	x10, #58195, lsl #16
	movk	x10, #39845, lsl #32
	movk	x10, #8388, lsl #48
	smulh	x9, x9, x10
	asr	x10, x9, #7
	add	x9, x10, x9, lsr #63
	sub	x8, x8, x21
	mov	x21, x24
	add	x10, x22, x20
	add	x9, x10, x9
	mov	w10, #16960                     ; =0x4240
	movk	w10, #15, lsl #16
	madd	x20, x8, x10, x9
	subs	w21, w21, #1
	b.ne	LBB12_128
; %bb.129:
	ucvtf	s8, x20
	mov	x26, x28
	ldr	x24, [sp, #72]                  ; 8-byte Folded Reload
	ldr	x23, [sp, #96]                  ; 8-byte Folded Reload
LBB12_130:
	fdiv	s12, s8, s14
	fcvt	d11, s12
	str	d11, [sp]
Lloh214:
	adrp	x0, l_.str.25@PAGE
Lloh215:
	add	x0, x0, l_.str.25@PAGEOFF
	bl	_printf
Lloh216:
	adrp	x0, l_str.103@PAGE
Lloh217:
	add	x0, x0, l_str.103@PAGEOFF
	bl	_puts
Lloh218:
	adrp	x0, l_str.93@PAGE
Lloh219:
	add	x0, x0, l_str.93@PAGEOFF
	bl	_puts
Lloh220:
	adrp	x0, l_str.94@PAGE
Lloh221:
	add	x0, x0, l_str.94@PAGEOFF
	bl	_puts
	mov	w8, #4719                       ; =0x126f
	movk	w8, #14979, lsl #16
	fmov	s8, w8
	ldr	x20, [sp, #128]                 ; 8-byte Folded Reload
	mov	x0, x20
	mov	x1, x23
	mov	x2, x26
	mov	x3, x19
	fmov	d0, d8
	bl	_compare_matrices
	mov	x28, x0
Lloh222:
	adrp	x0, l_str.95@PAGE
Lloh223:
	add	x0, x0, l_str.95@PAGEOFF
	bl	_puts
	mov	x0, x20
	mov	x1, x24
	mov	x2, x26
	mov	x3, x19
	fmov	d0, d8
	bl	_compare_matrices
	mov	x25, x0
Lloh224:
	adrp	x0, l_str.96@PAGE
Lloh225:
	add	x0, x0, l_str.96@PAGEOFF
	bl	_puts
	mov	x0, x20
	ldr	x1, [sp, #88]                   ; 8-byte Folded Reload
	mov	x2, x26
	mov	x3, x19
	fmov	d0, d8
	bl	_compare_matrices
	cmp	w28, #0
	ccmp	w25, #0, #4, ne
	ccmp	w0, #0, #4, ne
	cset	w20, eq
Lloh226:
	adrp	x8, l_str.98@PAGE
Lloh227:
	add	x8, x8, l_str.98@PAGEOFF
Lloh228:
	adrp	x9, l_str.97@PAGE
Lloh229:
	add	x9, x9, l_str.97@PAGEOFF
	csel	x0, x9, x8, eq
	bl	_puts
Lloh230:
	adrp	x0, l_str.112@PAGE
Lloh231:
	add	x0, x0, l_str.112@PAGEOFF
	bl	_puts
Lloh232:
	adrp	x0, l_str.100@PAGE
Lloh233:
	add	x0, x0, l_str.100@PAGEOFF
	bl	_puts
Lloh234:
	adrp	x0, l_str.101@PAGE
Lloh235:
	add	x0, x0, l_str.101@PAGEOFF
	bl	_puts
Lloh236:
	adrp	x8, l_.str.42@PAGE
Lloh237:
	add	x8, x8, l_.str.42@PAGEOFF
Lloh238:
	adrp	x9, l_.str.41@PAGE
Lloh239:
	add	x9, x9, l_.str.41@PAGEOFF
Lloh240:
	adrp	x10, l_.str.40@PAGE
Lloh241:
	add	x10, x10, l_.str.40@PAGEOFF
	stp	x9, x8, [sp, #24]
Lloh242:
	adrp	x8, l_.str.39@PAGE
Lloh243:
	add	x8, x8, l_.str.39@PAGEOFF
Lloh244:
	adrp	x11, l_.str.38@PAGE
Lloh245:
	add	x11, x11, l_.str.38@PAGEOFF
	stp	x8, x10, [sp, #8]
	str	x11, [sp]
Lloh246:
	adrp	x0, l_.str.37@PAGE
Lloh247:
	add	x0, x0, l_.str.37@PAGEOFF
	bl	_printf
Lloh248:
	adrp	x0, l_str.102@PAGE
Lloh249:
	add	x0, x0, l_str.102@PAGEOFF
	bl	_puts
	ucvtf	d0, x26
	fadd	d0, d0, d0
	ucvtf	d1, x19
	ucvtf	d2, x27
	fmul	d0, d0, d1
	fmul	d0, d0, d2
	fdiv	d1, d0, d9
	mov	x8, #70368744177664             ; =0x400000000000
	movk	x8, #16527, lsl #48
	fmov	d2, x8
	fdiv	d1, d1, d2
	fdiv	d3, d0, d13
	fdiv	d10, d3, d2
	fdiv	d3, d0, d15
	fmov	d4, d9
	fdiv	d9, d3, d2
	fdiv	d0, d0, d11
	fdiv	d14, d0, d2
Lloh250:
	adrp	x8, l_.str.47@PAGE
Lloh251:
	add	x8, x8, l_.str.47@PAGEOFF
	str	x8, [sp, #32]
	str	d1, [sp, #24]
Lloh252:
	adrp	x8, l_.str.46@PAGE
Lloh253:
	add	x8, x8, l_.str.46@PAGEOFF
	str	x8, [sp, #16]
	str	d4, [sp, #8]
Lloh254:
	adrp	x8, l_.str.45@PAGE
Lloh255:
	add	x8, x8, l_.str.45@PAGEOFF
	str	x8, [sp]
Lloh256:
	adrp	x0, l_.str.44@PAGE
Lloh257:
	add	x0, x0, l_.str.44@PAGEOFF
	bl	_printf
	ldr	s8, [sp, #164]                  ; 4-byte Folded Reload
	ldr	s0, [sp, #176]                  ; 4-byte Folded Reload
	fdiv	s0, s8, s0
	fcvt	d0, s0
Lloh258:
	adrp	x21, l_.str.50@PAGE
Lloh259:
	add	x21, x21, l_.str.50@PAGEOFF
	str	x21, [sp, #32]
	stp	d0, d10, [sp, #16]
	str	d13, [sp, #8]
Lloh260:
	adrp	x8, l_.str.49@PAGE
Lloh261:
	add	x8, x8, l_.str.49@PAGEOFF
	str	x8, [sp]
Lloh262:
	adrp	x25, l_.str.48@PAGE
Lloh263:
	add	x25, x25, l_.str.48@PAGEOFF
	mov	x0, x25
	bl	_printf
	ldr	s10, [sp, #168]                 ; 4-byte Folded Reload
	fdiv	s0, s8, s10
	fcvt	d0, s0
	str	x21, [sp, #32]
	stp	d0, d9, [sp, #16]
	str	d15, [sp, #8]
Lloh264:
	adrp	x8, l_.str.51@PAGE
Lloh265:
	add	x8, x8, l_.str.51@PAGEOFF
	str	x8, [sp]
	mov	x0, x25
	bl	_printf
	fdiv	s13, s8, s12
	fcvt	d9, s13
	ldr	x25, [sp, #80]                  ; 8-byte Folded Reload
	cmp	x25, #3
	b.eq	LBB12_133
; %bb.131:
	cmp	x25, #4
	b.ne	LBB12_134
; %bb.132:
Lloh266:
	adrp	x8, l_.str.53@PAGE
Lloh267:
	add	x8, x8, l_.str.53@PAGEOFF
	b	LBB12_135
LBB12_133:
Lloh268:
	adrp	x8, l_.str.54@PAGE
Lloh269:
	add	x8, x8, l_.str.54@PAGEOFF
	b	LBB12_135
LBB12_134:
Lloh270:
	adrp	x8, l_.str.55@PAGE
Lloh271:
	add	x8, x8, l_.str.55@PAGEOFF
	ldr	x9, [sp, #64]                   ; 8-byte Folded Reload
	cmp	x9, #2
	csel	x8, x8, x21, eq
LBB12_135:
	ldr	x21, [sp, #112]                 ; 8-byte Folded Reload
	ldr	x22, [sp, #96]                  ; 8-byte Folded Reload
	ldr	x23, [sp, #56]                  ; 8-byte Folded Reload
	str	x8, [sp, #32]
	stp	d9, d14, [sp, #16]
	str	d11, [sp, #8]
Lloh272:
	adrp	x8, l_.str.52@PAGE
Lloh273:
	add	x8, x8, l_.str.52@PAGEOFF
	str	x8, [sp]
Lloh274:
	adrp	x0, l_.str.48@PAGE
Lloh275:
	add	x0, x0, l_.str.48@PAGEOFF
	bl	_printf
Lloh276:
	adrp	x0, l_str.103@PAGE
Lloh277:
	add	x0, x0, l_str.103@PAGEOFF
	bl	_puts
Lloh278:
	adrp	x0, l_str.104@PAGE
Lloh279:
	add	x0, x0, l_str.104@PAGEOFF
	bl	_puts
Lloh280:
	adrp	x0, l_str.105@PAGE
Lloh281:
	add	x0, x0, l_str.105@PAGEOFF
	bl	_puts
	ldr	s0, [sp, #176]                  ; 4-byte Folded Reload
	fcmp	s0, #0.0
	b.le	LBB12_138
; %bb.136:
	fcmp	s10, #0.0
	b.le	LBB12_138
; %bb.137:
	ldr	s0, [sp, #176]                  ; 4-byte Folded Reload
	ldr	s1, [sp, #168]                  ; 4-byte Folded Reload
	fdiv	s10, s0, s1
Lloh282:
	adrp	x0, l_str.106@PAGE
Lloh283:
	add	x0, x0, l_str.106@PAGEOFF
	bl	_puts
	fcvt	d0, s10
	fmov	d1, #-1.00000000
	fadd	d1, d0, d1
	fmov	d2, #1.00000000
	fsub	d0, d2, d0
	fmov	s2, #1.00000000
	fcmp	s10, s2
	ldr	s10, [sp, #168]                 ; 4-byte Folded Reload
	fcsel	d0, d1, d0, gt
Lloh284:
	adrp	x8, l_.str.60@PAGE
Lloh285:
	add	x8, x8, l_.str.60@PAGEOFF
Lloh286:
	adrp	x9, l_.str.59@PAGE
Lloh287:
	add	x9, x9, l_.str.59@PAGEOFF
	csel	x0, x9, x8, gt
	mov	x8, #4636737291354636288        ; =0x4059000000000000
	fmov	d1, x8
	fmul	d0, d0, d1
	str	d0, [sp]
	bl	_printf
LBB12_138:
	fcmp	s10, #0.0
	b.le	LBB12_141
; %bb.139:
	fcmp	s12, #0.0
	b.le	LBB12_141
; %bb.140:
	fdiv	s10, s10, s12
Lloh288:
	adrp	x0, l_str.107@PAGE
Lloh289:
	add	x0, x0, l_str.107@PAGEOFF
	bl	_puts
	fcvt	d0, s10
	str	d0, [sp]
Lloh290:
	adrp	x0, l_.str.62@PAGE
Lloh291:
	add	x0, x0, l_.str.62@PAGEOFF
	bl	_printf
	ucvtf	s11, x25
	ucvtf	d0, x25
	str	d0, [sp]
Lloh292:
	adrp	x0, l_.str.63@PAGE
Lloh293:
	add	x0, x0, l_.str.63@PAGEOFF
	bl	_printf
	fdiv	s0, s10, s11
	mov	w8, #1120403456                 ; =0x42c80000
	fmov	s1, w8
	fmul	s0, s0, s1
	fcvt	d0, s0
	str	d0, [sp]
Lloh294:
	adrp	x0, l_.str.64@PAGE
Lloh295:
	add	x0, x0, l_.str.64@PAGEOFF
	bl	_printf
LBB12_141:
Lloh296:
	adrp	x0, l_str.108@PAGE
Lloh297:
	add	x0, x0, l_str.108@PAGEOFF
	bl	_puts
	fmov	s0, #1.00000000
	fcmp	s13, s0
	b.le	LBB12_143
; %bb.142:
	fmov	d0, #-1.00000000
	fadd	d0, d9, d0
	mov	x8, #4636737291354636288        ; =0x4059000000000000
	fmov	d1, x8
	fmul	d0, d0, d1
	stp	d9, d0, [sp]
Lloh298:
	adrp	x0, l_.str.66@PAGE
Lloh299:
	add	x0, x0, l_.str.66@PAGEOFF
	bl	_printf
	str	d14, [sp]
Lloh300:
	adrp	x0, l_.str.67@PAGE
Lloh301:
	add	x0, x0, l_.str.67@PAGEOFF
	b	LBB12_144
LBB12_143:
	fmov	d0, #1.00000000
	fsub	d0, d0, d9
	mov	x8, #4636737291354636288        ; =0x4059000000000000
	fmov	d1, x8
	fmul	d0, d0, d1
	str	d0, [sp]
Lloh302:
	adrp	x0, l_.str.68@PAGE
Lloh303:
	add	x0, x0, l_.str.68@PAGEOFF
LBB12_144:
	bl	_printf
Lloh304:
	adrp	x0, l_str.109@PAGE
Lloh305:
	add	x0, x0, l_str.109@PAGEOFF
	bl	_puts
	cmp	x19, x23
	b.ls	LBB12_147
; %bb.145:
	lsl	x8, x23, #2
	cmp	x19, x8
	b.hs	LBB12_148
; %bb.146:
	stp	x19, x8, [sp]
Lloh306:
	adrp	x0, l_.str.72@PAGE
Lloh307:
	add	x0, x0, l_.str.72@PAGEOFF
	bl	_printf
	mov	w8, #4                          ; =0x4
	stp	x25, x8, [sp]
Lloh308:
	adrp	x0, l_.str.73@PAGE
Lloh309:
	add	x0, x0, l_.str.73@PAGEOFF
	bl	_printf
	b	LBB12_150
LBB12_147:
	stp	x19, x23, [sp]
Lloh310:
	adrp	x0, l_.str.70@PAGE
Lloh311:
	add	x0, x0, l_.str.70@PAGEOFF
	bl	_printf
Lloh312:
	adrp	x0, l_str.111@PAGE
Lloh313:
	add	x0, x0, l_str.111@PAGEOFF
	b	LBB12_149
LBB12_148:
Lloh314:
	adrp	x0, l_str.110@PAGE
Lloh315:
	add	x0, x0, l_str.110@PAGEOFF
LBB12_149:
	bl	_puts
LBB12_150:
Lloh316:
	adrp	x0, l_str.112@PAGE
Lloh317:
	add	x0, x0, l_str.112@PAGEOFF
	bl	_puts
	mov	x0, x21
	bl	_free
	ldr	x0, [sp, #144]                  ; 8-byte Folded Reload
	bl	_free
	ldr	x0, [sp, #128]                  ; 8-byte Folded Reload
	bl	_free
	mov	x0, x22
	bl	_free
	mov	x0, x24
	bl	_free
	ldr	x0, [sp, #88]                   ; 8-byte Folded Reload
	bl	_free
	mov	x0, x20
	b	LBB12_92
	.loh AdrpAdd	Lloh62, Lloh63
	.loh AdrpAdd	Lloh60, Lloh61
	.loh AdrpAdd	Lloh64, Lloh65
	.loh AdrpAdd	Lloh70, Lloh71
	.loh AdrpAdd	Lloh68, Lloh69
	.loh AdrpAdd	Lloh66, Lloh67
	.loh AdrpAdd	Lloh78, Lloh79
	.loh AdrpAdd	Lloh76, Lloh77
	.loh AdrpAdd	Lloh74, Lloh75
	.loh AdrpAdd	Lloh72, Lloh73
	.loh AdrpAdd	Lloh80, Lloh81
	.loh AdrpAdd	Lloh84, Lloh85
	.loh AdrpAdd	Lloh82, Lloh83
	.loh AdrpAdd	Lloh86, Lloh87
	.loh AdrpAdd	Lloh88, Lloh89
	.loh AdrpAdd	Lloh90, Lloh91
	.loh AdrpAdd	Lloh92, Lloh93
	.loh AdrpAdd	Lloh94, Lloh95
	.loh AdrpAdd	Lloh96, Lloh97
	.loh AdrpAdd	Lloh98, Lloh99
	.loh AdrpAdd	Lloh100, Lloh101
	.loh AdrpAdd	Lloh102, Lloh103
	.loh AdrpAdd	Lloh104, Lloh105
	.loh AdrpAdd	Lloh106, Lloh107
	.loh AdrpAdd	Lloh108, Lloh109
	.loh AdrpAdd	Lloh110, Lloh111
	.loh AdrpAdd	Lloh112, Lloh113
	.loh AdrpAdd	Lloh114, Lloh115
	.loh AdrpAdd	Lloh116, Lloh117
	.loh AdrpAdd	Lloh118, Lloh119
	.loh AdrpAdd	Lloh120, Lloh121
	.loh AdrpAdd	Lloh122, Lloh123
	.loh AdrpAdd	Lloh124, Lloh125
	.loh AdrpAdd	Lloh126, Lloh127
	.loh AdrpAdd	Lloh128, Lloh129
	.loh AdrpAdd	Lloh130, Lloh131
	.loh AdrpAdd	Lloh132, Lloh133
	.loh AdrpAdd	Lloh138, Lloh139
	.loh AdrpAdd	Lloh136, Lloh137
	.loh AdrpAdd	Lloh134, Lloh135
	.loh AdrpAdd	Lloh140, Lloh141
	.loh AdrpAdd	Lloh142, Lloh143
	.loh AdrpAdd	Lloh144, Lloh145
	.loh AdrpAdd	Lloh146, Lloh147
	.loh AdrpAdd	Lloh148, Lloh149
	.loh AdrpAdd	Lloh150, Lloh151
	.loh AdrpAdd	Lloh152, Lloh153
	.loh AdrpAdd	Lloh154, Lloh155
	.loh AdrpAdd	Lloh156, Lloh157
	.loh AdrpAdd	Lloh158, Lloh159
	.loh AdrpAdd	Lloh160, Lloh161
	.loh AdrpAdd	Lloh162, Lloh163
	.loh AdrpAdd	Lloh164, Lloh165
	.loh AdrpAdd	Lloh166, Lloh167
	.loh AdrpAdd	Lloh168, Lloh169
	.loh AdrpAdd	Lloh170, Lloh171
	.loh AdrpAdd	Lloh172, Lloh173
	.loh AdrpAdd	Lloh174, Lloh175
	.loh AdrpAdd	Lloh176, Lloh177
	.loh AdrpAdd	Lloh178, Lloh179
	.loh AdrpAdd	Lloh180, Lloh181
	.loh AdrpAdd	Lloh182, Lloh183
	.loh AdrpAdd	Lloh184, Lloh185
	.loh AdrpAdd	Lloh186, Lloh187
	.loh AdrpAdd	Lloh192, Lloh193
	.loh AdrpAdd	Lloh190, Lloh191
	.loh AdrpAdd	Lloh188, Lloh189
	.loh AdrpAdd	Lloh194, Lloh195
	.loh AdrpAdd	Lloh200, Lloh201
	.loh AdrpAdd	Lloh198, Lloh199
	.loh AdrpAdd	Lloh196, Lloh197
	.loh AdrpAdd	Lloh206, Lloh207
	.loh AdrpAdd	Lloh204, Lloh205
	.loh AdrpAdd	Lloh202, Lloh203
	.loh AdrpAdd	Lloh212, Lloh213
	.loh AdrpAdd	Lloh210, Lloh211
	.loh AdrpAdd	Lloh208, Lloh209
	.loh AdrpAdd	Lloh264, Lloh265
	.loh AdrpAdd	Lloh262, Lloh263
	.loh AdrpAdd	Lloh260, Lloh261
	.loh AdrpAdd	Lloh258, Lloh259
	.loh AdrpAdd	Lloh256, Lloh257
	.loh AdrpAdd	Lloh254, Lloh255
	.loh AdrpAdd	Lloh252, Lloh253
	.loh AdrpAdd	Lloh250, Lloh251
	.loh AdrpAdd	Lloh248, Lloh249
	.loh AdrpAdd	Lloh246, Lloh247
	.loh AdrpAdd	Lloh244, Lloh245
	.loh AdrpAdd	Lloh242, Lloh243
	.loh AdrpAdd	Lloh240, Lloh241
	.loh AdrpAdd	Lloh238, Lloh239
	.loh AdrpAdd	Lloh236, Lloh237
	.loh AdrpAdd	Lloh234, Lloh235
	.loh AdrpAdd	Lloh232, Lloh233
	.loh AdrpAdd	Lloh230, Lloh231
	.loh AdrpAdd	Lloh228, Lloh229
	.loh AdrpAdd	Lloh226, Lloh227
	.loh AdrpAdd	Lloh224, Lloh225
	.loh AdrpAdd	Lloh222, Lloh223
	.loh AdrpAdd	Lloh220, Lloh221
	.loh AdrpAdd	Lloh218, Lloh219
	.loh AdrpAdd	Lloh216, Lloh217
	.loh AdrpAdd	Lloh214, Lloh215
	.loh AdrpAdd	Lloh266, Lloh267
	.loh AdrpAdd	Lloh268, Lloh269
	.loh AdrpAdd	Lloh270, Lloh271
	.loh AdrpAdd	Lloh280, Lloh281
	.loh AdrpAdd	Lloh278, Lloh279
	.loh AdrpAdd	Lloh276, Lloh277
	.loh AdrpAdd	Lloh274, Lloh275
	.loh AdrpAdd	Lloh272, Lloh273
	.loh AdrpAdd	Lloh286, Lloh287
	.loh AdrpAdd	Lloh284, Lloh285
	.loh AdrpAdd	Lloh282, Lloh283
	.loh AdrpAdd	Lloh294, Lloh295
	.loh AdrpAdd	Lloh292, Lloh293
	.loh AdrpAdd	Lloh290, Lloh291
	.loh AdrpAdd	Lloh288, Lloh289
	.loh AdrpAdd	Lloh296, Lloh297
	.loh AdrpAdd	Lloh300, Lloh301
	.loh AdrpAdd	Lloh298, Lloh299
	.loh AdrpAdd	Lloh302, Lloh303
	.loh AdrpAdd	Lloh304, Lloh305
	.loh AdrpAdd	Lloh308, Lloh309
	.loh AdrpAdd	Lloh306, Lloh307
	.loh AdrpAdd	Lloh312, Lloh313
	.loh AdrpAdd	Lloh310, Lloh311
	.loh AdrpAdd	Lloh314, Lloh315
	.loh AdrpAdd	Lloh316, Lloh317
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"  \350\257\257\345\267\256\344\275\215\347\275\256[%lu]: \345\217\202\350\200\203\345\200\274=%.6f, \347\273\223\346\236\234=%.6f, \345\267\256\345\200\274=%.6f\n"

l_.str.1:                               ; @.str.1
	.asciz	"  \351\224\231\350\257\257\346\225\260\351\207\217: %d / %lu\n"

l_.str.2:                               ; @.str.2
	.asciz	"  \346\234\200\345\244\247\350\257\257\345\267\256: %.9f\n"

l_.str.3:                               ; @.str.3
	.asciz	"  \345\271\263\345\235\207\350\257\257\345\267\256: %.9f\n"

l_.str.4:                               ; @.str.4
	.asciz	"%s (\345\211\2154x4):\n"

l_.str.5:                               ; @.str.5
	.asciz	"  "

l_.str.6:                               ; @.str.6
	.asciz	"%8.2f "

l_.str.13:                              ; @.str.13
	.asciz	"\342\234\223 \345\220\221\351\207\217\351\225\277\345\272\246(SVL): %lu \344\270\25232\344\275\215\345\255\227\n"

l_.str.14:                              ; @.str.14
	.asciz	"\342\234\223 ZA\345\257\204\345\255\230\345\231\250: 4\344\270\252 %lu\303\227%lu tiles\n\n"

l_.str.15:                              ; @.str.15
	.asciz	"\347\237\251\351\230\265\347\273\264\345\272\246: A[%lu\303\227%lu] \303\227 B[%lu\303\227%lu] = C[%lu\303\227%lu]\n"

l_.str.16:                              ; @.str.16
	.asciz	"\346\265\213\350\257\225\350\277\255\344\273\243\346\254\241\346\225\260: %d\n"

l_.str.17:                              ; @.str.17
	.asciz	"\347\220\206\350\256\272\346\234\200\345\244\247tile\345\210\251\347\224\250\346\225\260: %lu / 4\n"

l_.str.21:                              ; @.str.21
	.asciz	"\347\237\251\351\230\265 A"

l_.str.22:                              ; @.str.22
	.asciz	"\347\237\251\351\230\265 B"

l_.str.25:                              ; @.str.25
	.asciz	"   \345\271\263\345\235\207\346\227\266\351\227\264: %.3f \316\274s\n"

l_.str.37:                              ; @.str.37
	.asciz	"%-25s %12s %12s %12s %15s\n"

l_.str.38:                              ; @.str.38
	.asciz	"\347\211\210\346\234\254"

l_.str.39:                              ; @.str.39
	.asciz	"\346\227\266\351\227\264(\316\274s)"

l_.str.40:                              ; @.str.40
	.asciz	"\345\212\240\351\200\237\346\257\224"

l_.str.41:                              ; @.str.41
	.asciz	"GFLOPS"

l_.str.42:                              ; @.str.42
	.asciz	"Tile\345\210\251\347\224\250\347\216\207"

l_.str.44:                              ; @.str.44
	.asciz	"%-25s %12.3f %12s %12.2f %15s\n"

l_.str.45:                              ; @.str.45
	.asciz	"CPU"

l_.str.46:                              ; @.str.46
	.asciz	"1.00x"

l_.str.47:                              ; @.str.47
	.asciz	"N/A"

l_.str.48:                              ; @.str.48
	.asciz	"%-25s %12.3f %12.2fx %12.2f %15s\n"

l_.str.49:                              ; @.str.49
	.asciz	"SME(CPU\350\275\254\347\275\256+\345\215\225tile)"

l_.str.50:                              ; @.str.50
	.asciz	"1/4 (25%)"

l_.str.51:                              ; @.str.51
	.asciz	"SME(SME\350\275\254\347\275\256+\345\215\225tile)"

l_.str.52:                              ; @.str.52
	.asciz	"SME(SME\350\275\254\347\275\256+4-tiles)"

l_.str.53:                              ; @.str.53
	.asciz	"4/4 (100%)"

l_.str.54:                              ; @.str.54
	.asciz	"3/4 (75%)"

l_.str.55:                              ; @.str.55
	.asciz	"2/4 (50%)"

l_.str.59:                              ; @.str.59
	.asciz	"   \342\234\223 SME\350\275\254\347\275\256\346\257\224CPU\350\275\254\347\275\256\345\277\253 %.1f%%\n"

l_.str.60:                              ; @.str.60
	.asciz	"   \342\234\227 SME\350\275\254\347\275\256\346\257\224CPU\350\275\254\347\275\256\346\205\242 %.1f%%\n"

l_.str.62:                              ; @.str.62
	.asciz	"   \347\233\270\346\257\224\345\215\225tile\347\211\210\346\234\254\345\212\240\351\200\237: %.2fx\n"

l_.str.63:                              ; @.str.63
	.asciz	"   \347\220\206\350\256\272\346\234\200\345\244\247\345\212\240\351\200\237: %.1fx\n"

l_.str.64:                              ; @.str.64
	.asciz	"   \346\225\210\347\216\207: %.1f%%\n"

l_.str.66:                              ; @.str.66
	.asciz	"   \342\234\223 \346\200\273\344\275\223\345\212\240\351\200\237 %.2fx (\345\277\253%.1f%%)\n"

l_.str.67:                              ; @.str.67
	.asciz	"   \350\276\276\345\210\260 %.2f GFLOPS \346\200\247\350\203\275\n"

l_.str.68:                              ; @.str.68
	.asciz	"   \342\234\227 \346\262\241\346\234\211\345\212\240\351\200\237\346\225\210\346\236\234 (\346\205\242%.1f%%)\n"

l_.str.70:                              ; @.str.70
	.asciz	"   \342\232\240 N\347\273\264\345\272\246(%lu) <= SVL(%lu)\357\274\214\345\217\252\350\203\275\344\275\277\347\224\2501\344\270\252tile\n"

l_.str.72:                              ; @.str.72
	.asciz	"   \342\232\240 N\347\273\264\345\272\246(%lu) < 4*SVL(%lu)\357\274\214\345\217\252\350\203\275\351\203\250\345\210\206\345\210\251\347\224\250tiles\n"

l_.str.73:                              ; @.str.73
	.asciz	"   \345\275\223\345\211\215\344\275\277\347\224\250 %lu/%d tiles\n"

l_str:                                  ; @str
	.asciz	"  ..."

l_str.75:                               ; @str.75
	.asciz	"..."

l_str.77:                               ; @str.77
	.asciz	"SME \347\237\251\351\230\265\344\271\230\346\263\225\346\200\247\350\203\275\345\257\271\346\257\224\346\265\213\350\257\225\357\274\210\345\220\2534-tiles\344\274\230\345\214\226\357\274\211"

l_str.79:                               ; @str.79
	.asciz	"\351\224\231\350\257\257: \347\263\273\347\273\237\344\270\215\346\224\257\346\214\201SME"

l_str.80:                               ; @str.80
	.asciz	"\342\234\223 \346\243\200\346\265\213\345\210\260SME\346\224\257\346\214\201"

l_str.81:                               ; @str.81
	.asciz	"==========================================\n"

l_str.82:                               ; @str.82
	.asciz	"\345\206\205\345\255\230\345\210\206\351\205\215\345\244\261\350\264\245"

l_str.83:                               ; @str.83
	.asciz	"\345\210\235\345\247\213\345\214\226\346\265\213\350\257\225\347\237\251\351\230\265..."

l_str.85:                               ; @str.85
	.asciz	"1. \350\277\220\350\241\214\344\274\240\347\273\237CPU\347\211\210\346\234\254..."

l_str.87:                               ; @str.87
	.asciz	"2. \350\277\220\350\241\214SME\347\211\210\346\234\254\357\274\210CPU\350\275\254\347\275\256 + \345\215\225tile\357\274\211..."

l_str.89:                               ; @str.89
	.asciz	"3. \350\277\220\350\241\214SME\347\211\210\346\234\254\357\274\210SME\350\275\254\347\275\256 + \345\215\225tile\357\274\211..."

l_str.91:                               ; @str.91
	.asciz	"4. \350\277\220\350\241\214SME\347\211\210\346\234\254\357\274\210SME\350\275\254\347\275\256 + 4-tiles\345\271\266\350\241\214\357\274\211..."

l_str.93:                               ; @str.93
	.asciz	"\351\252\214\350\257\201\350\256\241\347\256\227\345\207\206\347\241\256\345\272\246..."

l_str.94:                               ; @str.94
	.asciz	"\n\345\257\271\346\257\224CPU\347\273\223\346\236\234\344\270\216SME(CPU\350\275\254\347\275\256+\345\215\225tile):"

l_str.95:                               ; @str.95
	.asciz	"\n\345\257\271\346\257\224CPU\347\273\223\346\236\234\344\270\216SME(SME\350\275\254\347\275\256+\345\215\225tile):"

l_str.96:                               ; @str.96
	.asciz	"\n\345\257\271\346\257\224CPU\347\273\223\346\236\234\344\270\216SME(SME\350\275\254\347\275\256+4-tiles):"

l_str.97:                               ; @str.97
	.asciz	"\n\342\234\227 \345\207\206\347\241\256\345\272\246\351\252\214\350\257\201\345\244\261\350\264\245\357\274\201"

l_str.98:                               ; @str.98
	.asciz	"\n\342\234\223 \346\211\200\346\234\211\347\211\210\346\234\254\345\207\206\347\241\256\345\272\246\351\252\214\350\257\201\351\200\232\350\277\207\357\274\201"

l_str.100:                              ; @str.100
	.asciz	"\346\200\247\350\203\275\346\200\273\347\273\223"

l_str.101:                              ; @str.101
	.asciz	"===================================================="

l_str.102:                              ; @str.102
	.asciz	"----------------------------------------------------"

l_str.103:                              ; @str.103
	.asciz	"\n----------------------------------------------------"

l_str.104:                              ; @str.104
	.asciz	"\n\344\274\230\345\214\226\346\225\210\346\236\234\345\210\206\346\236\220:"

l_str.105:                              ; @str.105
	.asciz	"=========================================="

l_str.106:                              ; @str.106
	.asciz	"1. \350\275\254\347\275\256\344\274\230\345\214\226\357\274\210\345\215\225tile\357\274\211:"

l_str.107:                              ; @str.107
	.asciz	"\n2. 4-tiles\345\271\266\350\241\214\344\274\230\345\214\226:"

l_str.108:                              ; @str.108
	.asciz	"\n3. \346\234\200\344\275\263SME\347\211\210\346\234\254\347\233\270\346\257\224CPU:"

l_str.109:                              ; @str.109
	.asciz	"\n4. \346\200\247\350\203\275\345\210\206\346\236\220:"

l_str.110:                              ; @str.110
	.asciz	"   \342\234\223 N\347\273\264\345\272\246\345\205\205\350\266\263\357\274\214\345\217\257\345\256\214\345\205\250\345\210\251\347\224\2504\344\270\252tiles"

l_str.111:                              ; @str.111
	.asciz	"   \345\273\272\350\256\256\357\274\232\345\242\236\345\244\247N\347\273\264\345\272\246\344\273\245\345\205\205\345\210\206\345\210\251\347\224\2504\344\270\252tiles"

l_str.112:                              ; @str.112
	.asciz	"\n===================================================="

.subsections_via_symbols
