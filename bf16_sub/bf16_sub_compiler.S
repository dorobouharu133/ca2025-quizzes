bf16_add:
	addi	sp,sp,-64
	sw	s0,60(sp)
	addi	s0,sp,64
	sh	a0,-52(s0)
	sh	a1,-56(s0)
	lhu	a5,-52(s0)
	srli	a5,a5,15
	sh	a5,-30(s0)
	lhu	a5,-56(s0)
	srli	a5,a5,15
	sh	a5,-32(s0)
	lhu	a5,-52(s0)
	srli	a5,a5,7
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a5,a5,255
	sh	a5,-34(s0)
	lhu	a5,-56(s0)
	srli	a5,a5,7
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a5,a5,255
	sh	a5,-36(s0)
	lhu	a5,-52(s0)
	andi	a5,a5,127
	sh	a5,-18(s0)
	lhu	a5,-56(s0)
	andi	a5,a5,127
	sh	a5,-20(s0)
	lh	a4,-34(s0)
	addi	a5,x0,255
	bne	a4,a5,L2
	lhu	a5,-18(s0)
	beq	a5,zero,L3
	lhu	a5,-52(s0)
	j	L25
L3:
	lh	a4,-36(s0)
	addi	a5,x0,255
	bne	a4,a5,L5
	lhu	a5,-20(s0)
	bne	a5,zero,L6
	lhu	a4,-30(s0)
	lhu	a5,-32(s0)
	beq	a4,a5,L6
	addi a5, a5, -1
    slli a5, a5, 15
	xori	a5,a5,-64
	j	L25
L6:
	lhu	a5,-56(s0)
	j	L25
L5:
	lhu	a5,-52(s0)
	j	L25
L2:
	lh	a4,-36(s0)
	addi	a5,x0,255
	bne	a4,a5,L8
	lhu	a5,-56(s0)
	j	L25
L8:
	lh	a5,-34(s0)
	bne	a5,zero,L9
	lhu	a5,-18(s0)
	bne	a5,zero,L9
	lhu	a5,-56(s0)
	j	L25
L9:
	lh	a5,-36(s0)
	bne	a5,zero,L10
	lhu	a5,-20(s0)
	bne	a5,zero,L10
	lhu	a5,-52(s0)
	j	L25
L10:
	lh	a5,-34(s0)
	beq	a5,zero,L11
	lhu	a5,-18(s0)
	ori	a5,a5,128
	sh	a5,-18(s0)
L11:
	lh	a5,-36(s0)
	beq	a5,zero,L12
	lhu	a5,-20(s0)
	ori	a5,a5,128
	sh	a5,-20(s0)
L12:
	lhu	a4,-34(s0)
	lhu	a5,-36(s0)
	sub	a5,a4,a5
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,-38(s0)
	lh	a5,-38(s0)
	ble	a5,zero,L13
	lhu	a5,-34(s0)
	sh	a5,-24(s0)
	lh	a4,-38(s0)
	addi	a5,x0,8
	ble	a4,a5,L14
	lhu	a5,-52(s0)
	j	L25
L14:
	lhu	a4,-20(s0)
	lh	a5,-38(s0)
	sra	a5,a4,a5
	sh	a5,-20(s0)
	j	L15
L13:
	lh	a5,-38(s0)
	bge	a5,zero,L16
	lhu	a5,-36(s0)
	sh	a5,-24(s0)
	lh	a4,-38(s0)
	addi	a5,x0,-8
	bge	a4,a5,L17
	lhu	a5,-56(s0)
	j	L25
L17:
	lhu	a4,-18(s0)
	lh	a5,-38(s0)
	neg	a5,a5
	sra	a5,a4,a5
	sh	a5,-18(s0)
	j	L15
L16:
	lhu	a5,-34(s0)
	sh	a5,-24(s0)
L15:
	lhu	a4,-30(s0)
	lhu	a5,-32(s0)
	bne	a4,a5,L18
	lhu	a5,-30(s0)
	sh	a5,-22(s0)
	lhu	a4,-18(s0)
	lhu	a5,-20(s0)
	add	a5,a4,a5
	sw	a5,-28(s0)
	lw	a5,-28(s0)
	andi	a5,a5,256
	beq	a5,zero,L19
	lw	a5,-28(s0)
	srli	a5,a5,1
	sw	a5,-28(s0)
	lhu	a5,-24(s0)
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,-24(s0)
	lh	a4,-24(s0)
	addi	a5,x0, 254
	ble	a4,a5,L19
	lh	a5,-22(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	addi a5, a5, 1
    slli a5, a5, 15
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	L25
L18:
	lhu	a4,-18(s0)
	lhu	a5,-20(s0)
	bltu	a4,a5,L20
	lhu	a5,-30(s0)
	sh	a5,-22(s0)
	lhu	a4,-18(s0)
	lhu	a5,-20(s0)
	sub	a5,a4,a5
	sw	a5,-28(s0)
	j	L21
L20:
	lhu	a5,-32(s0)
	sh	a5,-22(s0)
	lhu	a4,-20(s0)
	lhu	a5,-18(s0)
	sub	a5,a4,a5
	sw	a5,-28(s0)
L21:
	lw	a5,-28(s0)
	bne	a5,zero,L23
	addi	a5,x0, 0
	j	L25
L24:
	lw	a5,-28(s0)
	slli	a5,a5,1
	sw	a5,-28(s0)
	lhu	a5,-24(s0)
	addi	a5,a5,-1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,-24(s0)
	lh	a5,-24(s0)
	bgt	a5,zero,L23
	addi	a5,x0,0
	j	L25
L23:
	lw	a5,-28(s0)
	andi	a5,a5,128
	beq	a5,zero,L24
L19:
	lh	a5,-22(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	lhu	a5,-24(s0)
	slli	a5,a5,7
	slli	a3,a5,16
	srai	a3,a3,16
	addi a5, a5, 1
    slli a5, a5, 15
	addi	a5,a5,-128
	and	a5,a3,a5
	slli	a5,a5,16
	srai	a5,a5,16
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a4,a5,16
	srli	a4,a4,16
	lw	a5,-28(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	andi	a5,a5,127
	slli	a5,a5,16
	srli	a5,a5,16
	or	a5,a4,a5
	slli	a5,a5,16
	srli	a5,a5,16
L25:
	addi	a0,a5,0
	lw	s0,60(sp)
	addi	sp,sp,64
	jr	ra
bf16_sub:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sh	a0,-20(s0)
	sh	a1,-24(s0)
	lhu	a4,-24(s0)
	addi	a5,x0, -1
    slli a5, a5, 15
	xor	a5,a4,a5
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,-24(s0)
	lhu	a5,-24(s0)
	add	a1,a5, x0
	lhu	a5,-20(s0)
	add	a0,a5, x0
	call	bf16_add
	addi	a5,a0, 0
	addi	a0,a5, 0
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra