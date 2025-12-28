.data
newline: .string "\n"
pass_msg: .string "bf16_sqrt All tests passed!"
fail_msg: .string "Tests failed!"
.text
.globl bf16_sqrt
.globl __mulsi3
.globl main

main:
# sqrt(+inf) = +inf
test_1:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x80
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0x80
    bne s0, t0, test_failed

# sqrt(NaN) = NaN
test_2:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0xC0	
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0xC0
    bne s0, t0, test_failed

# sqrt(-1.000000) = NaN
test_3:
    addi a0, x0, 0xBF
    slli a0, a0, 8
    ori a0, a0, 0x80	
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0xC0
    bne s0, t0, test_failed

# sqrt(2.000000) = 1.414062
test_4:
    addi a0, x0, 0x40
    slli a0, a0, 8
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x3F
    slli t0, t0, 8
    ori t0, t0, 0xB5
    bne s0, t0, test_failed

# sqrt(1.000000) = 1.000000
test_5:
    addi a0, x0, 0x3F
    slli a0, a0, 8
    ori a0, a0, 0x80
    jal ra, bf16_sqrt
    addi t0, x0, 0x3F
    slli t0, t0, 8
    ori t0, t0, 0x80
    bne a0, t0, test_failed

# sqrt(0.000000) = 0.000000
test_6:
    addi a0, x0, 0
    jal ra, bf16_sqrt
    addi t0, x0, 0x0000
    bne a0, t0, test_failed

# sqrt(2648071397852762090550553127902248960.000000) = 1630303065108119552.000000
test_7:
    addi a0, x0, 0x7B
    slli a0, a0, 8
    ori a0, a0, 0xFF      
    jal ra, bf16_sqrt
    addi t0, x0, 0x5D
    slli t0, t0, 8
    ori t0, t0, 0xB5       
    bne a0, t0, test_failed

test_passed:
    la a0, pass_msg
    addi a7, x0, 4            
    ecall
    jal x0, end
test_failed:
    la a0, fail_msg
    addi a7, x0, 4            
    ecall
end:
    la a0, newline
    addi a7, x0, 4            
    ecall

    addi a7, x0, 10        
    ecall

bf16_sqrt:
	addi	sp,sp,-80
	sw	ra,76(sp)
	sw	s0,72(sp)
	addi	s0,sp,80
	sh	a0,-68(s0)
	lhu	a5,-68(s0)
	srli	a5,a5,15
	sh	a5,-38(s0)
	lhu	a5,-68(s0)
	srli	a5,a5,7
	slli	a5,a5,16
	srli	a5,a5,16
	slli	a5,a5,16
	srai	a5,a5,16
	andi	a5,a5,255
	sh	a5,-40(s0)
	lhu	a5,-68(s0)
	andi	a5,a5,127
	sh	a5,-42(s0)
	lh	a4,-40(s0)
	addi	a5,x0,255
	bne	a4,a5,L2
	lhu	a5,-42(s0)
	beq	a5,zero,L3
	lhu	a5,-68(s0)
	j	L20
L3:
	lhu	a5,-38(s0)
	beq	a5,zero,L5
	addi  a5, x0, -1
    slli  a5, a5, 15
	xori	a5,a5,-64
	j	L20
L5:
	lhu	a5,-68(s0)
	j	L20
L2:
	lh	a5,-40(s0)
	bne	a5,zero,L6
	lhu	a5,-42(s0)
	bne	a5,zero,L6
	addi	a5,x0,0
	j	L20
L6:
	lhu	a5,-38(s0)
	beq	a5,zero,L7
	addi  a5, x0, -1
    slli  a5, a5, 15
	xori	a5,a5,-64
	j	L20
L7:
	lh	a5,-40(s0)
	bne	a5,zero,L8
	addi	a5,x0,0
	j	L20
L8:
	lh	a5,-40(s0)
	addi	a5,a5,-127
	sw	a5,-48(s0)
	lhu	a5,-42(s0)
	ori	a5,a5,128
	slli	a5,a5,16
	srli	a5,a5,16
	sw	a5,-24(s0)
	lw	a5,-48(s0)
	andi	a5,a5,1
	beq	a5,zero,L9
	lw	a5,-24(s0)
	slli	a5,a5,1
	sw	a5,-24(s0)
	lw	a5,-48(s0)
	addi	a5,a5,-1
	srai	a5,a5,1
	addi	a5,a5,127
	sw	a5,-20(s0)
	j	L10
L9:
	lw	a5,-48(s0)
	srai	a5,a5,1
	addi	a5,a5,127
	sw	a5,-20(s0)
L10:
	addi	a5,x0,90
	sw	a5,-28(s0)
	addi	a5,x0,256
	sw	a5,-32(s0)
	addi	a5,x0,128
	sw	a5,-36(s0)
	j	L11
L13:
	lw	a4,-28(s0)
	lw	a5,-32(s0)
	add	a5,a4,a5
	srli	a5,a5,1
	sw	a5,-56(s0)
	lw	a1,-56(s0)
	lw	a0,-56(s0)
	call	__mulsi3
	addi	a5,a0, 0
	srli	a5,a5,7
	sw	a5,-60(s0)
	lw	a4,-60(s0)
	lw	a5,-24(s0)
	bgtu	a4,a5,L12
	lw	a5,-56(s0)
	sw	a5,-36(s0)
	lw	a5,-56(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
	j	L11
L12:
	lw	a5,-56(s0)
	addi	a5,a5,-1
	sw	a5,-32(s0)
L11:
	lw	a4,-28(s0)
	lw	a5,-32(s0)
	bleu	a4,a5,L13
	lw	a4,-36(s0)
	addi	a5,x0,255
	bleu	a4,a5,L14
	lw	a5,-36(s0)
	srli	a5,a5,1
	sw	a5,-36(s0)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
	j	L15
L14:
	lw	a4,-36(s0)
	addi	a5,x0,127
	bgtu	a4,a5,L15
	j	L16
L17:
	lw	a5,-36(s0)
	slli	a5,a5,1
	sw	a5,-36(s0)
	lw	a5,-20(s0)
	addi	a5,a5,-1
	sw	a5,-20(s0)
L16:
	lw	a4,-36(s0)
	addi	a5,x0,127
	bgtu	a4,a5,L15
	lw	a4,-20(s0)
	addi	a5,x0,1
	bgt	a4,a5,L17
L15:
	lw	a5,-36(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	andi	a5,a5,127
	sh	a5,-50(s0)
	lw	a4,-20(s0)
	addi	a5,x0,254
	ble	a4,a5,L18
    addi  a5, x0, -1
    slli  a5, a5, 15
	xori	a5,a5,-128
	j	L20
L18:
	lw	a5,-20(s0)
	bgt	a5,zero,L19
	addi	a5,x0,0
	j	L20
L19:
	lw	a5,-20(s0)
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,7
	slli	a4,a5,16
	srai	a4,a4,16
	addi  a5, x0, 1
    slli  a5, a5, 15
	addi	a5,a5,-128
	and	a5,a4,a5
	slli	a4,a5,16
	srai	a4,a4,16
	lh	a5,-50(s0)
	or	a5,a4,a5
	slli	a5,a5,16
	srai	a5,a5,16
	slli	a5,a5,16
	srli	a5,a5,16
L20:
	addi	a0,a5, 0
	lw	ra,76(sp)
	lw	s0,72(sp)
	addi	sp,sp,80
	jr	ra

__mulsi3:
    addi    t0, x0, 0
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
    addi    a0, t0, 0
    ret
