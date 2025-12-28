	.file	"bf16_mul.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	__mulsi3
	.align	2
	.globl	bf16_mul
	.type	bf16_mul, @function
bf16_mul:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	addi	s0,sp,64
	sh	a0,-52(s0)
	sh	a1,-56(s0)
	lhu	a5,-52(s0)
	srli	a5,a5,15
	sh	a5,-38(s0)
	lhu	a5,-56(s0)
	srli	a5,a5,15
	sh	a5,-40(s0)
	lhu	a5,-52(s0)
	srli	a5,a5,7
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a5,a5,255
	sh	a5,-18(s0)
	lhu	a5,-56(s0)
	srli	a5,a5,7
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a5,a5,255
	sh	a5,-20(s0)
	lhu	a5,-52(s0)
	andi	a5,a5,127
	sh	a5,-22(s0)
	lhu	a5,-56(s0)
	andi	a5,a5,127
	sh	a5,-24(s0)
	lhu	a5,-38(s0)
	mv	a4,a5
	lhu	a5,-40(s0)
	xor	a5,a4,a5
	sh	a5,-42(s0)
	lh	a4,-18(s0)
	li	a5,255
	bne	a4,a5,.L2
	lhu	a5,-22(s0)
	beq	a5,zero,.L3
	lhu	a5,-52(s0)
	j	.L27
.L3:
	lh	a5,-20(s0)
	bne	a5,zero,.L5
	lhu	a5,-24(s0)
	bne	a5,zero,.L5
	li	a5,-32768
	xori	a5,a5,-64
	j	.L27
.L5:
	lh	a5,-42(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	li	a5,32768
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	.L27
.L2:
	lh	a4,-20(s0)
	li	a5,255
	bne	a4,a5,.L7
	lhu	a5,-24(s0)
	beq	a5,zero,.L8
	lhu	a5,-56(s0)
	j	.L27
.L8:
	lh	a5,-18(s0)
	bne	a5,zero,.L10
	lhu	a5,-22(s0)
	bne	a5,zero,.L10
	li	a5,-32768
	xori	a5,a5,-64
	j	.L27
.L10:
	lh	a5,-42(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	li	a5,32768
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	.L27
.L7:
	lh	a5,-18(s0)
	bne	a5,zero,.L11
	lhu	a5,-22(s0)
	beq	a5,zero,.L12
.L11:
	lh	a5,-20(s0)
	bne	a5,zero,.L13
	lhu	a5,-24(s0)
	bne	a5,zero,.L13
.L12:
	lhu	a5,-42(s0)
	slli	a5,a5,15
	slli	a5,a5,16
	srli	a5,a5,16
	j	.L27
.L13:
	sh	zero,-26(s0)
	lh	a5,-18(s0)
	bne	a5,zero,.L14
	j	.L15
.L16:
	lhu	a5,-22(s0)
	slli	a5,a5,1
	sh	a5,-22(s0)
	lh	a5,-26(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,-26(s0)
.L15:
	lhu	a5,-22(s0)
	andi	a5,a5,128
	beq	a5,zero,.L16
	li	a5,1
	sh	a5,-18(s0)
	j	.L17
.L14:
	lhu	a5,-22(s0)
	ori	a5,a5,128
	sh	a5,-22(s0)
.L17:
	lh	a5,-20(s0)
	bne	a5,zero,.L18
	j	.L19
.L20:
	lhu	a5,-24(s0)
	slli	a5,a5,1
	sh	a5,-24(s0)
	lh	a5,-26(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,-26(s0)
.L19:
	lhu	a5,-24(s0)
	andi	a5,a5,128
	beq	a5,zero,.L20
	li	a5,1
	sh	a5,-20(s0)
	j	.L21
.L18:
	lhu	a5,-24(s0)
	ori	a5,a5,128
	sh	a5,-24(s0)
.L21:
	lhu	a5,-22(s0)
	lhu	a4,-24(s0)
	mv	a1,a4
	mv	a0,a5
	call	__mulsi3
	mv	a5,a0
	sw	a5,-32(s0)
	lh	a4,-18(s0)
	lh	a5,-20(s0)
	add	a5,a4,a5
	addi	a4,a5,-127
	lh	a5,-26(s0)
	add	a5,a4,a5
	sw	a5,-36(s0)
	lw	a4,-32(s0)
	li	a5,32768
	and	a5,a4,a5
	beq	a5,zero,.L22
	lw	a5,-32(s0)
	srli	a5,a5,8
	andi	a5,a5,127
	sw	a5,-32(s0)
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
	j	.L23
.L22:
	lw	a5,-32(s0)
	srli	a5,a5,7
	andi	a5,a5,127
	sw	a5,-32(s0)
.L23:
	lw	a4,-36(s0)
	li	a5,254
	ble	a4,a5,.L24
	lh	a5,-42(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	li	a5,32768
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	.L27
.L24:
	lw	a5,-36(s0)
	bgt	a5,zero,.L25
	lw	a4,-36(s0)
	li	a5,-6
	bge	a4,a5,.L26
	lhu	a5,-42(s0)
	slli	a5,a5,15
	slli	a5,a5,16
	srli	a5,a5,16
	j	.L27
.L26:
	li	a4,1
	lw	a5,-36(s0)
	sub	a5,a4,a5
	lw	a4,-32(s0)
	srl	a5,a4,a5
	sw	a5,-32(s0)
	sw	zero,-36(s0)
.L25:
	lh	a5,-42(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	lw	a5,-36(s0)
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,7
	slli	a3,a5,16
	srai	a3,a3,16
	li	a5,32768
	addi	a5,a5,-128
	and	a5,a3,a5
	slli	a5,a5,16
	srai	a5,a5,16
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a4,a5,16
	srli	a4,a4,16
	lw	a5,-32(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	andi	a5,a5,127
	slli	a5,a5,16
	srli	a5,a5,16
	or	a5,a4,a5
	slli	a5,a5,16
	srli	a5,a5,16
.L27:
	mv	a0,a5
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra
	.size	bf16_mul, .-bf16_mul
	.ident	"GCC: (13.2.0-11ubuntu1+12) 13.2.0"
