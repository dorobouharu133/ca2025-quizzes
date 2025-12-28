.data
newline: .string "\n"
pass_msg: .string "bf16_div All tests passed!"
fail_msg: .string "Tests failed!"
.text
.globl bf16_div
.globl branchless_16_bit_clz
.globl main

main:
# 0x7F7F / 0x0080, maximal finite positive number / minimal normalized number = +inf
test_1:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x7F
    addi a1, x0, 0x80
    jal ra, bf16_div   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0x80
    bne s0, t0, test_failed

# NaN / 1.000000 = NaN
test_2:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0xC0
    addi a1, x0, 0x3F
    slli a1, a1, 8
    ori a1, a1, 0x80
    jal ra, bf16_div   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0xC0
    bne s0, t0, test_failed

# +inf / (-inf) = NaN
test_3:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x80
    addi a1, x0, 0xFF
    slli a1, a1, 8
    ori a1, a1, 0x80
    jal ra, bf16_div   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0xC0
    bne s0, t0, test_failed

# 3.000000 / 2.000000 = 1.500000
test_4:
    addi a0, x0, 0x40 # 3.000000
    slli a0, a0, 8
    ori a0, a0, 0x40
    addi a1, x0, 0x40 # 2.000000
    slli a1, a1, 8
    ori a1, a1, 0x00
    jal ra, bf16_div   

    addi s0, a0, 0
    addi t0, x0, 0x3F # 1.500000
    slli t0, t0, 8
    ori t0, t0, 0xC0
    bne s0, t0, test_failed


test_passed:
    la a0, pass_msg
    li a7, 4            
    ecall
    jal x0, end
test_failed:
    la a0, fail_msg
    li a7, 4            
    ecall
end:
    la a0, newline
    li a7, 4            
    ecall

    li a7, 10        
    ecall

bf16_div:
	addi	sp,sp,-80
	sw	s0,76(sp)
	addi	s0,sp,80
	sh	a0,-68(s0)
	sh	a1,-72(s0)
	lhu	a5,-68(s0)
	srli	a5,a5,15
	sh	a5,-38(s0)
	lhu	a5,-72(s0)
	srli	a5,a5,15
	sh	a5,-40(s0)
	lhu	a5,-68(s0)
	srli	a5,a5,7
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a5,a5,255
	sh	a5,-42(s0)
	lhu	a5,-72(s0)
	srli	a5,a5,7
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a5,a5,255
	sh	a5,-44(s0)
	lhu	a5,-68(s0)
	andi	a5,a5,127
	sh	a5,-18(s0)
	lhu	a5,-72(s0)
	andi	a5,a5,127
	sh	a5,-20(s0)
	lhu	a5,-38(s0)
	add	a4,a5, x0
	lhu	a5,-40(s0)
	xor	a5,a4,a5
	sh	a5,-46(s0)
	lh	a4,-44(s0)
	addi	a5,x0,255
	bne	a4,a5,L2
	lhu	a5,-20(s0)
	beq	a5,zero,L3
	lhu	a5,-72(s0)
	j	L28
L3:
	lh	a4,-42(s0)
	addi	a5,x0,255
	bne	a4,a5,L5
	lhu	a5,-18(s0)
	bne	a5,zero,L5
    addi a5, x0, -1
    slli  a5, a5, 15
	xori	a5,a5,-64
	j	L28
L5:
	lhu	a5,-46(s0)
	slli	a5,a5,15
	slli	a5,a5,16
	srli	a5,a5,16
	j	L28
L2:
	lh	a5,-44(s0)
	bne	a5,zero,L7
	lhu	a5,-20(s0)
	bne	a5,zero,L7
	lh	a5,-42(s0)
	bne	a5,zero,L8
	lhu	a5,-18(s0)
	bne	a5,zero,L8
	addi a5, x0, -1
    slli  a5, a5, 15
	xori	a5,a5,-64
	j	L28
L8:
	lh	a5,-46(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	addi a5, x0, -1
    slli  a5, a5, 15
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	L28
L7:
	lh	a4,-42(s0)
	addi	a5,x0,255
	bne	a4,a5,L10
	lhu	a5,-18(s0)
	beq	a5,zero,L11
	lhu	a5,-68(s0)
	j	L28
L11:
	lh	a5,-46(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	addi a5, x0, -1
    slli  a5, a5, 15
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	L28
L10:
	lh	a5,-42(s0)
	bne	a5,zero,L13
	lhu	a5,-18(s0)
	bne	a5,zero,L13
	lhu	a5,-46(s0)
	slli	a5,a5,15
	slli	a5,a5,16
	srli	a5,a5,16
	j	L28
L13:
	lh	a5,-42(s0)
	beq	a5,zero,L14
	lhu	a5,-18(s0)
	ori	a5,a5,128
	sh	a5,-18(s0)
L14:
	lh	a5,-44(s0)
	beq	a5,zero,L15
	lhu	a5,-20(s0)
	ori	a5,a5,128
	sh	a5,-20(s0)
L15:
	lhu	a5,-18(s0)
	slli	a5,a5,15
	sw	a5,-24(s0)
	lhu	a5,-20(s0)
	sw	a5,-52(s0)
	sw	zero,-28(s0)
	sw	zero,-32(s0)
	j	L16
L18:
	lw	a5,-28(s0)
	slli	a5,a5,1
	sw	a5,-28(s0)
	addi	a4,x0,15
	lw	a5,-32(s0)
	sub	a5,a4,a5
	lw	a4,-52(s0)
	sll	a5,a4,a5
	lw	a4,-24(s0)
	bltu	a4,a5,L17
	addi	a4,x0,15
	lw	a5,-32(s0)
	sub	a5,a4,a5
	lw	a4,-52(s0)
	sll	a5,a4,a5
	lw	a4,-24(s0)
	sub	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-28(s0)
	ori	a5,a5,1
	sw	a5,-28(s0)
L17:
	lw	a5,-32(s0)
	addi	a5,a5,1
	sw	a5,-32(s0)
L16:
	lw	a4,-32(s0)
	addi	a5,x0,15
	ble	a4,a5,L18
	lh	a4,-42(s0)
	lh	a5,-44(s0)
	sub	a5,a4,a5
	addi	a5,a5,127
	sw	a5,-36(s0)
	lh	a5,-42(s0)
	bne	a5,zero,L19
	lw	a5,-36(s0)
	addi	a5,a5,-1
	sw	a5,-36(s0)
L19:
	lh	a5,-44(s0)
	bne	a5,zero,L20
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
L20:
	lw	a4,-28(s0)
	addi a5, x0, -1
    slli  a5, a5, 15
	and	a5,a4,a5
	beq	a5,zero,L23
	lw	a5,-28(s0)
	srli	a5,a5,8
	sw	a5,-28(s0)
	j	L22
L25:
	lw	a5,-28(s0)
	slli	a5,a5,1
	sw	a5,-28(s0)
	lw	a5,-36(s0)
	addi	a5,a5,-1
	sw	a5,-36(s0)
L23:
	lw	a4,-28(s0)
	addi a5, x0, -1
    slli  a5, a5, 15
	and	a5,a4,a5
	bne	a5,zero,L24
	lw	a4,-36(s0)
	addi	a5,x0,1
	bgt	a4,a5,L25
L24:
	lw	a5,-28(s0)
	srli	a5,a5,8
	sw	a5,-28(s0)
L22:
	lw	a5,-28(s0)
	andi	a5,a5,127
	sw	a5,-28(s0)
	lw	a4,-36(s0)
	addi	a5,x0,254
	ble	a4,a5,L26
	lh	a5,-46(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	addi a5, x0, -1
    slli  a5, a5, 15
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	L28
L26:
	lw	a5,-36(s0)
	bgt	a5,zero,L27
	lhu	a5,-46(s0)
	slli	a5,a5,15
	slli	a5,a5,16
	srli	a5,a5,16
	j	L28
L27:
	lh	a5,-46(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	lw	a5,-36(s0)
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,7
	slli	a3,a5,16
	srai	a3,a3,16
	addi a5, x0, -1
    slli  a5, a5, 15
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
L28:
	addi	a0,a5,0
	lw	s0,76(sp)
	addi	sp,sp,80
	jr	ra
