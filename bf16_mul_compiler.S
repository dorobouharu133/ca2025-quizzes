.data
start: .string "BF16_MUL TESTS: \n"
newline: .string "\n"
pass_msg: .string "All tests passed!"
fail_msg: .string "Test failed!"

.text
.global main
.global bf16_mul

main:
    la a0, start
    addi a7, x0, 4
    ecall
test1:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x7F # maximal finite positive number  
    addi a1, x0, 0x80 # minimal normalized number
    jal ra, bf16_mul
    addi t0, a0, 0
    addi t1, x0, 0x40
    slli t1, t1, 8
    ori t1, t1, 0x7F
    bne a0, t1,test_fail 
    
test2:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0xC0 # NaN
    addi a1, x0, 0x3F 
    slli a1, a1, 8
    ori a1, a1, 0x80
    jal ra, bf16_mul
    addi t0, a0, 0
    addi t1, x0, 0x7F
    slli t1, t1, 8
    ori t1, t1, 0xC0 # NaN
    bne a0, t1,test_fail 
    
test3:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x80 # +inf   
    addi a1, x0, 0xFF
    slli a1, a1, 8
    ori a1, a1, 0x80 # -inf
    jal ra, bf16_mul
    addi t0, a0, 0
    addi t1, x0, 0xFF
    slli t1, t1, 8
    ori t1, t1, 0x80 # -inf
    bne a0, t1,test_fail

test4:
    addi a0, x0, 0x40
    slli a0, a0, 8
    ori a0, a0, 0x40 # 3.000000
    addi a1, x0, 0x40
    slli a1, a1, 8
    ori a1, a1, 0x00 # 2.000000
    jal ra, bf16_mul
    addi t0, a0, 0
    addi t1, x0, 0x40
    slli t1, t1, 8
    ori t1, t1, 0xC0 # 6.000000
    bne a0, t1,test_fail  
    
test_pass:
    la a0, pass_msg
    addi a7, x0, 4
    ecall
    jal new_line

test_fail:
    la a0, fail_msg
    addi a7, x0, 4
    ecall
    
new_line:
    la a0, newline
    addi a7, x0, 4
    ecall

end:
    addi a7, x0, 10
    ecall

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
	bne	a4,a5,L2
	lhu	a5,-22(s0)
	beq	a5,zero,L3
	lhu	a5,-52(s0)
	j	L27
L3:
	lh	a5,-20(s0)
	bne	a5,zero,L5
	lhu	a5,-24(s0)
	bne	a5,zero,L5
	li	a5,-32768
	xori	a5,a5,-64
	j	L27
L5:
	lh	a5,-42(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
    addi  a5, x0, 1
	slli  a5, a5, 15
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	L27
L2:
	lh	a4,-20(s0)
	li	a5,255
	bne	a4,a5,L7
	lhu	a5,-24(s0)
	beq	a5,zero,L8
	lhu	a5,-56(s0)
	j	L27
L8:
	lh	a5,-18(s0)
	bne	a5,zero,L10
	lhu	a5,-22(s0)
	bne	a5,zero,L10
	addi  a5, x0, 1
	slli  a5, a5, 15
	xori	a5,a5,-64
	j	L27
L10:
	lh	a5,-42(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	addi  a5, x0, 1
	slli  a5, a5, 15
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	L27
L7:
	lh	a5,-18(s0)
	bne	a5,zero,L11
	lhu	a5,-22(s0)
	beq	a5,zero,L12
L11:
	lh	a5,-20(s0)
	bne	a5,zero,L13
	lhu	a5,-24(s0)
	bne	a5,zero,L13
L12:
	lhu	a5,-42(s0)
	slli	a5,a5,15
	slli	a5,a5,16
	srli	a5,a5,16
	j	L27
L13:
	sh	zero,-26(s0)
	lh	a5,-18(s0)
	bne	a5,zero,L14
	j	L15
L16:
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
L15:
	lhu	a5,-22(s0)
	andi	a5,a5,128
	beq	a5,zero,L16
	li	a5,1
	sh	a5,-18(s0)
	j	L17
L14:
	lhu	a5,-22(s0)
	ori	a5,a5,128
	sh	a5,-22(s0)
L17:
	lh	a5,-20(s0)
	bne	a5,zero,L18
	j	L19
L20:
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
L19:
	lhu	a5,-24(s0)
	andi	a5,a5,128
	beq	a5,zero,L20
	li	a5,1
	sh	a5,-20(s0)
	j	L21
L18:
	lhu	a5,-24(s0)
	ori	a5,a5,128
	sh	a5,-24(s0)
L21:
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
	addi  a5, x0, 1
	slli  a5, a5, 15
	and	a5,a4,a5
	beq	a5,zero,L22
	lw	a5,-32(s0)
	srli	a5,a5,8
	andi	a5,a5,127
	sw	a5,-32(s0)
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
	j	L23
L22:
	lw	a5,-32(s0)
	srli	a5,a5,7
	andi	a5,a5,127
	sw	a5,-32(s0)
L23:
	lw	a4,-36(s0)
	li	a5,254
	ble	a4,a5,L24
	lh	a5,-42(s0)
	slli	a5,a5,15
	slli	a4,a5,16
	srai	a4,a4,16
	addi  a5, x0, 1
	slli  a5, a5, 15
	addi	a5,a5,-128
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
	j	L27
L24:
	lw	a5,-36(s0)
	bgt	a5,zero,L25
	lw	a4,-36(s0)
	li	a5,-6
	bge	a4,a5,L26
	lhu	a5,-42(s0)
	slli	a5,a5,15
	slli	a5,a5,16
	srli	a5,a5,16
	j	L27
L26:
	li	a4,1
	lw	a5,-36(s0)
	sub	a5,a4,a5
	lw	a4,-32(s0)
	srl	a5,a4,a5
	sw	a5,-32(s0)
	sw	zero,-36(s0)
L25:
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
	addi  a5, x0, 1
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
	lw	a5,-32(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	andi	a5,a5,127
	slli	a5,a5,16
	srli	a5,a5,16
	or	a5,a4,a5
	slli	a5,a5,16
	srli	a5,a5,16
L27:
	addi a0,a5, 0
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra

__mulsi3:
    li      t0, 0
mul_loop:
    beq     a1, x0, mul_end
    andi    t1, a1, 1
    beq     t1, x0, skip_add
    add     t0, t0, a0
skip_add:
    slli    a0, a0, 1
    srli    a1, a1, 1
    j       mul_loop
mul_end:
    mv      a0, t0
    ret