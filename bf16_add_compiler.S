.data
start: .string "BF16_ADD TESTS: \n"
newline: .string "\n"
pass_msg: .string "All tests passed!"
fail_msg: .string "Test failed!"

.text
.global main
.global bf16_add

main:
    la a0, start
    addi a7, x0, 4
    ecall

# 1.0 + (-1.0) = 0.0
test1:
    addi a0, x0, 0x3F
    slli a0, a0, 8
    ori a0, a0, 0x80
    addi a1, x0, 0xBF
    slli a1, a1, 8
    ori a1, a1, 0x80
    jal ra, bf16_add
    addi t1, x0, 0x00
    bne a0, t1,test_fail 

# maximum finite positive number + minimal normalized number = positive infinity
test2:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x7F
    addi a1, x0, 0x7F
    slli a1, a1, 8
    ori a1, a1, 0x7F    
    jal ra, bf16_add
    addi t1, x0, 0x7F
    slli t1, t1, 8
    ori t1, t1, 0x80
    bne a0, t1,test_fail 

# 1.0000000 + 2^-8 = 1.000000
test3:
    addi a0, x0, 0x3F
    slli a0, a0, 8
    ori a0, a0, 0x80
    addi a1, x0, 0x3B
    slli a1, a1, 8
    ori a1, a1, 0x80 
    jal ra, bf16_add
    addi t1, x0, 0x3F
    slli t1, t1, 8
    ori t1, t1, 0x80
    bne a0, t1,test_fail

# inf + (-inf) = NaN
test4:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x80
    addi a1, x0, 0xFF   
    slli a1, a1, 8
    ori a1, a1, 0x80
    jal ra, bf16_add
    addi t1, x0, 0x7F
    slli t1, t1, 8
    ori t1, t1, 0xC0
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

bf16_add:
	slli	a0,a0,16
	srli	a0,a0,16
	slli	a1,a1,16
	srli	a1,a1,16
	srli	a5,a0,7
	srli	a4,a1,7
	andi	a5,a5,0xff
	li	a3,255
	srli	a7,a0,15
	srli	t1,a1,15
	andi	a4,a4,0xff
	andi	a6,a0,127
	andi	a2,a1,127
	beq	a5,a3,L48
	beq	a4,a3,L29
	bne	a5,zero,L4
	beq	a6,zero,L29
	bne	a4,zero,L5
	beq	a2,zero,L49
	li	a3,0
	add	a5,a6,a2
	beq	a7,t1,L17
L16:
	sub	a5,a2,a6
	bgeu	a6,a2,L50
L19:
	li	a0,0
	mv	a7,t1
	bne	a5,zero,L21
L36:
	ret
L4:
	slli	a3,a5,16
	srai	a3,a3,16
	beq	a4,zero,L51
	sub	a5,a5,a4
	slli	t3,a5,16
	srai	t3,t3,16
	slli	a5,a5,16
	ori	a6,a6,128
	ori	a2,a2,128
	srli	a5,a5,16
	ble	t3,zero,L10
L8:
	li	a4,8
	bgt	t3,a4,L36
	sra	a2,a2,a5
	sub	a5,a6,a2
	bne	a7,t1,L21
	slli	a2,a2,16
	srli	a2,a2,16
L15:
	add	a5,a6,a2
	andi	a4,a5,256
	beq	a4,zero,L17
L23:
	addi	a3,a3,1
	slli	a2,a3,16
	srli	a2,a2,16
	slli	a3,a3,16
	li	a4,255
	srli	a5,a5,1
	srai	a3,a3,16
	bne	a2,a4,L17
	li	a5,32768
	li	a4,-32768
	addi	a5,a5,-128
	and	a4,a0,a4
	or	a0,a4,a5
	ret
L5:
	neg	t3,a4
	slli	t3,t3,16
	ori	a2,a2,128
	srai	t3,t3,16
L9:
	li	a5,-8
	bge	t3,a5,L52
L29:
	mv	a0,a1
	ret
L48:
	bne	a6,zero,L36
	bne	a4,a5,L36
	mv	a0,a1
	bne	a2,zero,L36
	li	a0,32768
	addi	a0,a0,-64
	beq	a7,t1,L29
	ret
L22:
	slli	a3,a2,16
	srai	a3,a3,16
	slli	a5,a5,1
	ble	a3,zero,L32
L21:
	andi	a4,a5,128
	addi	a2,a3,-1
	beq	a4,zero,L22
L17:
	slli	a3,a3,7
	slli	a7,a7,15
	or	a7,a7,a3
	andi	a5,a5,127
	or	a7,a7,a5
	slli	a0,a7,16
	srli	a0,a0,16
	ret
L51:
	beq	a2,zero,L36
	ori	a6,a6,128
	mv	t3,a3
	j	L8
L32:
	li	a0,0
	ret
L52:
	neg	t3,t3
	slli	a3,a4,16
	srai	a3,a3,16
	sra	a6,a6,t3
	beq	a7,t1,L53
	sub	a5,a2,a6
	mv	a7,t1
	j	L21
L49:
	ret
L53:
	slli	a6,a6,16
	srli	a6,a6,16
	j	L15
L50:
	sub	a5,a6,a2
	mv	t1,a7
	j	L19
L10:
	bne	t3,zero,L9
	bne	a7,t1,L16
	add	a5,a6,a2
	j	L23