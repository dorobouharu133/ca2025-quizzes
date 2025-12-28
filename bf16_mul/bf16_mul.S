.data
start: .string "BF16_MUL TESTS: \n"
newline: .string "\n"
pass_msg: .string "All tests passed!"
fail_msg: .string "Test failed!"

.text
.global main
.global bf16_mul
.global shift_and_add

main:
    la a0, start
    li a7, 4
    ecall
# maximal finite positive number x minimal finite normalized positive number
test1:
    li a0, 0x7F7F
    li a1, 0x0080
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x407F
    bne a0, t1,test_fail 

# NaN x 1.000000 = NaN
test2:
    li a0, 0x7FC0   
    li a1, 0x3F80    
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7FC0
    bne t0, t1,test_fail 

# +inf x (-inf) = (-inf)
test3:
    li a0, 0x7F80 
    li a1, 0xFF80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0xFF80
    bne t0, t1,test_fail

# 3.000000 x 2.000000 = 6.000000
test4:
    li a0, 0x4040 
    li a1, 0x4000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x40C0
    bne t0, t1,test_fail  

# 1.000000 x 1.000000 = 1.000000
test5:
    li a0, 0x3F80  
    li a1, 0x3F80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x3F80
    bne t0, t1,test_fail

# 0.000000 x (-0.000000) = (-0.000000)
test6:
    li a0, 0x0000
    li a1, 0x8000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x8000
    bne t0, t1,test_fail 

# +inf x 0.000000 = NaN
test7:
    li a0, 0x7F80
    li a1, 0x0000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7FC0
    bne t0, t1,test_fail

# maximal finite positive number x 2.000000 = +inf
test8:
    li a0, 0x7F7F
    li a1, 0x4000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7F80
    bne t0, t1,test_fail

# minimal finite normalized positive number x minimal finite normalized positive number = 0.000000
test9:
    li a0, 0x0080
    li a1, 0x0080
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x0000
    bne t0, t1,test_fail

# NaN x 1.000000 = NaN
test10:
    li a0, 0x7FC0
    li a1, 0x3F80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7FC0
    bne t0, t1,test_fail

# (-inf) x +inf = -inf
test11:
    li a0, 0xFF80
    li a1, 0x7F80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0xFF80
    bne t0, t1,test_fail

# 1.007812 x 1.007812 = 1.015625
test12:
    li a0, 0x3F81
    li a1, 0x3F81
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x3F82
    bne t0, t1,test_fail

# -2.000000 x 3.000000 = -6.000000
test13:
    li a0, 0xC000
    li a1, 0x4040
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0xC0C0
    bne a0, t1,test_fail

# minimal finite denormalized positive number x minimal finite denormalized positive number = 0.000000
test14:
    li a0, 0x0040
    li a1, 0x0040
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x0000
    bne t0, t1,test_fail

# 1.007812 x 2.000000 = 2.015625
test15:
    li a0, 0x3F81
    li a1, 0x4000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x4001
    bne t0, t1,test_fail

# 3.000000 x 0.500000 = 1.500000
test16:
    li a0, 0x4040
    li a1, 0x3F00
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x3FC0
    bne t0, t1,test_fail

# 5.000000 x 0.500000 = 2.500000
test17:
    li a0, 0x40A0
    li a1, 0x3F00
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x4020
    bne t0, t1,test_fail

# 2.250000 x 2.250000 = 5.062500
test18:
    li a0, 0x4010
    li a1, 0x4010
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x40A2
    bne t0, t1,test_fail

test_pass:
    la a0, pass_msg
    li a7, 4
    ecall
    jal x0, new_line

test_fail:
    la a0, fail_msg
    li a7, 4
    ecall
    
new_line:
    la a0, newline
    li a7, 4
    ecall

end:
    li a7, 10
    ecall

# a0: a
# a1: b
# t0: sign_a
# t1: sigb_b
# t2: exp_a
# t3: exp_b
# t4: mant_a
# t5: mant_b
# t6: temp
# s0: result_sign

bf16_mul:
    srli t0, a0, 15
    andi t0, t0, 1 # t0 = (a.bits >> 15) & 1
    srli t1, a1, 15
    andi t1, t1, 1 # t1 = (b.bits >> 15) & 1
    srli t2, a0, 7
    andi t2, t2, 0xFF # t2 = (a.bits >> 7) & 0xFF
    srli t3, a1, 7
    andi t3, t3, 0xFF # t3 = (b.bits >> 7) & 0xFF
    andi t4, a0, 0x7F # t4 = a.bits & 0x7F
    andi t5, a1, 0x7F # t5 = a.bits & 0x7F
    xor s0, t0, t1 # result_sign = sign_a ^ sign_b

bf16_mul_check_a_0xFF:
    addi t6, x0, 0xFF 
    bne t2, t6, bf16_mul_check_b_0xFF
    bne t4, x0, bf16_mul_return_a 
    bne t5, x0, bf16_mul_return_pInf
    bne t3, x0, bf16_mul_return_pInf
    jal x0, bf16_mul_return_NaN

bf16_mul_check_b_0xFF:
    addi t6, x0, 0xFF
    bne t3, t6, bf16_mul_check_zero
    bne t4, x0, bf16_mul_return_b
    bne t2, x0, bf16_mul_return_pInf
    bne t5, x0, bf16_mul_return_pInf
    jal x0, bf16_mul_return_NaN

bf16_mul_check_zero:
    or t6, t2, t4
    bne t6, x0, bf16_mul_exp_adjust
    or t6, t3, t5
    bne t6, x0, bf16_mul_exp_adjust
    jal x0, bf16_mul_return_zero

bf16_mul_exp_adjust:
bf16_mul_exp_adjust_a: # normalize a
    addi s1, t4, 0 # s1 = x = mant_a
    addi s2, x0, 0 # s2 = shift
    addi s3, x0, 0 # s3 = s

    addi t6, x0, 0xF
    slt s3, t6, s1 # s3 = (x > 0xF) ? 1 : 0
    xori s3, s3, 1 # s3 = (x <= 0xF) ? 1 : 0

    slli t6, s3, 2
    add s2, s2, t6 # shift += (s << 2)
    sll s1, s1, t6 # x <<= (s << 2)
    #
    addi t6, x0, 0x3F
    slt s3, t6, s1 # s3 = (x > 0x3F) ? 1 : 0
    xori s3, s3, 1 # s3 = (x <= 0x3F) ? 1 : 0
    
    slli t6, s3, 1
    add s2, s2, t6 # shift += (s << 1)
    sll s1, s1, t6 # x <<= (s << 1)
    #
    addi t6, x0, 0x7F
    slt s3, t6, s1 # s3 = (x > 0x7F) ? 1 : 0
    xori s3, s3, 1 # s3 = (x <= 0x7F) ? 1 : 0
    # s2: shift = # of leading zeros
    # s4: exp_adjust_a
    sltiu t6, t2, 1 # t6 = (exp_a == 0) ? 1 : 0
    or t2, t2, t6 # exp_a = (exp_a == 0) ? 1 : exp_a
    addi t6, t6, -1
    xori t6, t6, -1
    and s4, s2, t6
    
    and s2, s2, t6
    sll t4, t4, s2

    ori t4, t4, 0x80 # mant_a |= 0x80
bf16_mul_exp_adjust_b: # normalize b
    addi s1, t4, 0 # s1 = x = mant_b
    addi s2, x0, 0 # s2 = shift
    addi s3, x0, 0 # s3 = s

    addi t6, x0, 0xF
    slt s3, t6, s1 # s3 = (x > 0xF) ? 1 : 0
    xori s3, s3, 1 # s3 = (x <= 0xF) ? 1 : 0

    slli t6, s3, 2
    add s2, s2, t6 # shift += (s << 2)
    sll s1, s1, t6 # x <<= (s << 2)
    #
    addi t6, x0, 0x3F
    slt s3, t6, s1 # s3 = (x > 0x3F) ? 1 : 0
    xori s3, s3, 1 # s3 = (x <= 0x3F) ? 1 : 0
    
    slli t6, s3, 1
    add s2, s2, t6 # shift += (s << 1)
    sll s1, s1, t6 # x <<= (s << 1)
    #
    addi t6, x0, 0x7F
    slt s3, t6, s1 # s3 = (x > 0x7F) ? 1 : 0
    xori s3, s3, 1 # s3 = (x <= 0x7F) ? 1 : 0
    # s2: shift = # of leading zeros
    # s5: exp_adjust_b
    sltiu t6, t3, 1 # t6 = (exp_a == 0) ? 1 : 0
    or t3, t3, t6 # exp_a = (exp_a == 0) ? 1 : exp_a
    addi t6, t6, -1
    xori t6, t6, -1
    
    and s5, s2, t6
    
    and s2, s2, t6
    sll t5, t5, s2

    ori t5, t5, 0x80 # mant_b |= 0x80
    # s1: exp_adjust = exp_adjust_a + exp_adjust_b
    add s1, s4, s5
bf16_mul_normalize:
    # s2: result_mant
    # s3: result_exp
    # mul s2, t4, t5 # result_mant = mant_a * mant_b
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    addi a0, t4, 0
    addi a1, t5, 0
    jal ra, shift_and_add
    addi s2, a0, 0
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    addi sp, sp, 12
    add s3, t2, t3 # result_exp = exp_a + exp_b
    sub s3, s3, s5 # result_exp - exp_adjust_b
    sub s3, s3, s4 # result_exp - exp_adjust_a - exp_adjust_b
    addi s3, s3, -127 # result_exp -= BF16_EXP_BIAS

bf16_mul_normalize_check:
    srli t6, s2, 15
    addi t0, t6, 7 # t0 = (result_mant == 1) ? 8 : 7, shift_amount 
    srl s2, s2, t0 # result_mant >>= (shift_amount)
    add s3, s3, t6  # result_exp += t6

bf16_mul_normalize_check_result_exp_if_ge_0xFF:
    addi t6, x0, 0xFF
    bge s3, t6, bf16_mul_return_pInf

bf16_mul_normalize_check_result_exp_if_le_0:
    bgt s3, x0, bf16_mul_return
    addi t6, x0, -6
    blt s3, t6, bf16_mul_return_zero
    addi t6, x0, 1
    sub t6, t6, s3 # t6 = 1 - result_exp
    srl s2, s2, t6
    addi s3, x0, 0

bf16_mul_return:
    slli a0, s0, 15
    andi s3, s3, 0xFF
    slli s3, s3, 7
    or a0, a0, s3
    andi s2, s2, 0x7F
    or a0, a0, s2
    jr ra
    
bf16_mul_return_a:
    jr ra

bf16_mul_return_b:
    addi a0, a1, 0
    jr ra

bf16_mul_return_pInf:
    addi a0, s0, 0
    slli a0, a0, 15
    addi t6, x0, 0x7F
    slli t6, t6, 8
    ori t6, t6, 0x80
    or a0, a0, t6
    jr ra

bf16_mul_return_NaN:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0xC0
    jr ra

bf16_mul_return_zero:
    addi a0, s0, 0
    slli a0, a0, 15
    jr ra

# a0: multiplicand
# a1: multiplier
# t0: accumulator
# t1: multiplier_copy
# t2: bit0
shift_and_add:
    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    
    addi t0, x0, 0
    addi t1, a1, 0
    andi t2, a1, 1
shift_and_add_for_loop:
    andi t2, t1, 1
    beq t2, x0, shift_and_add_for_skip_add
    add t0, t0, a0
    
shift_and_add_for_skip_add:    
    slli a0, a0, 1
    srli t1, t1, 1
    bne t1, x0, shift_and_add_for_loop
shfit_and_add_end:
    addi a1, t0, 0
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    addi sp, sp, 12
    addi a0, a1, 0
    jr ra 