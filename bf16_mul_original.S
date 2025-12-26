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
    li a7, 4
    ecall
test1:
    li a0, 0x7F7F # maximal finite positive number  
    li a1, 0x0080 # minimal normalized number
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x407F
    bne a0, t1,test_fail 
    
test2:
    li a0, 0x7FC0 # NaN   
    li a1, 0x3F80    
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7FC0 # NaN
    bne a0, t1,test_fail 
    
test3:
    li a0, 0x7F80 # +inf   
    li a1, 0xFF80 # -inf 
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0xFF80 # +inf
    bne a0, t1,test_fail

test4:
    li a0, 0x4040 # 3.000000   
    li a1, 0x4000 # 2.000000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x40C0 # 6.000000
    bne a0, t1,test_fail  
    
test_pass:
    la a0, pass_msg
    li a7, 4
    ecall
    jal new_line

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
# t1: sign_b
# t2: exp_a
# t3: exp_b
# t4: mant_a
# t5: mant_b
# t6: temp
# s0: exp_adjust
# s1: result_exp
# s2: result_mant
# s3: result_sign
bf16_mul:
    srli t0, a0, 15
    andi t0, t0, 1 # sign_a
    srli t1, a1, 15
    andi t1, t1, 1 # sign_b
    srli t2, a0, 7
    andi t2, t2, 0xFF # exp_a
    srli t3, a1, 7
    andi t3, t3, 0xFF # exp_b
    andi t4, a0, 0x7F # mant_a
    andi t5, a1, 0x7F # mant_b

    xor s3, t0, t1

# Special cases
bf16_mul_special_cases_if1:
    li t6, 0xFF
    bne t2, t6, bf16_mul_special_cases_if2

    # a = Inf/NaN
    bne t4, x0, bf16_mul_return_bf16_nan
    or t6, t3, t5
    beq t6, x0, bf16_mul_return_bf16_nan # Inf * 0 = NaN
    slli a0, s3, 15
    li t6, 0x7F80
    or a0, a0, t6
    jal x0, bf16_mul_return

bf16_mul_special_cases_if2:
    li t6, 0xFF
    bne t3, t6, bf16_mul_special_cases_if3

    # b = Inf/NaN
    bne t5, x0, bf16_mul_return_bf16_nan
    or t6, t2, t4
    beq t6, x0, bf16_mul_return_bf16_nan # 0 * Inf = NaN
    slli a0, s3, 15
    li t6, 0x7F80
    or a0, a0, t6
    jal x0, bf16_mul_return

bf16_mul_special_cases_if3:
    or t6, t2, t4
    beq t6, x0, bf16_mul_return_result_sign_shift # a == 0
    or t6, t3, t5
    beq t6, x0, bf16_mul_return_result_sign_shift # b == 0

# Normalize / denormal
bf16_mul_exp_adjust:
    addi s0, x0, 0

bf16_mul_exp_adjust_if_a:
    bne t2, x0, bf16_mul_exp_adjust_else_a
    
bf16_mul_exp_adjust_while_a:
    andi t6, t4, 0x40
    bne t6, x0, bf16_mul_exp_adjust_while_skip_a
    beq t4, x0, bf16_mul_exp_adjust_while_skip_a
    slli t4, t4, 1
    addi s0, s0, -1
    j bf16_mul_exp_adjust_while_a
    
bf16_mul_exp_adjust_while_skip_a:
    slli t4, t4, 1
    addi t2, x0, 1
    j bf16_mul_exp_adjust_if_b

bf16_mul_exp_adjust_else_a:
    ori t4, t4, 0x80

bf16_mul_exp_adjust_if_b:
    bne t3, x0, bf16_mul_exp_adjust_else_b
    
bf16_mul_exp_adjust_while_b:
    andi t6, t5, 0x40
    bne t6, x0, bf16_mul_exp_adjust_while_skip_b
    beq t5, x0, bf16_mul_exp_adjust_while_skip_b
    slli t5, t5, 1
    addi s0, s0, -1
    j bf16_mul_exp_adjust_while_b
    
bf16_mul_exp_adjust_while_skip_b:
    slli t5, t5, 1
    addi t3, x0, 1
    j bf16_mul_result_mant

bf16_mul_exp_adjust_else_b:
    ori t5, t5, 0x80

# mantissa multiply
bf16_mul_result_mant:
    mul s2, t4, t5
    add s1, t2, t3
    addi s1, s1, -127
    add s1, s1, s0

bf16_mul_result_mant_handling_if:
    li t6, 0x8000
    and t6, s2, t6
    beq t6, x0, bf16_mul_result_mant_handling_else
    # >= 2.0
    srli s2, s2, 8
    andi s2, s2, 0x7F
    addi s1, s1, 1
    j bf16_mul_result_mant_handling_done
    
bf16_mul_result_mant_handling_else:
    srli s2, s2, 7
    andi s2, s2, 0x7F
    
bf16_mul_result_mant_handling_done:
    # exponent overflow / underflow
    blt s1, x0, bf16_mul_skip1   # exp < 0 -> underflow
    li t6, 0xFF
    bge s1, t6, bf16_mul_result_exp_cornor_case  # exp >= 255 -> overflow
    j bf16_mul_skip2

bf16_mul_result_exp_cornor_case:
    slli a0, s3, 15
    li t6, 0x7F80
    or a0, a0, t6
    jal x0, bf16_mul_return

bf16_mul_skip1:
    ori s2, s2, 0x80
    addi t6, x0, 1
    sub t6, t6, s1
    li t0, 8
    bge t6, t0, bf16_mul_result_exp_lt_n6
    srl s2, s2, t6
    addi s1, x0, 0
    j bf16_mul_skip2

bf16_mul_skip2:
    slli t6, s3, 15
    andi a0, s1, 0xFF
    slli a0, a0, 7
    or a0, a0, t6
    andi t6, s2, 0x7F
    or a0, a0, t6
    jal x0, bf16_mul_return

bf16_mul_result_exp_lt_n6:
    slli a0, s3, 15
    jal x0, bf16_mul_return

bf16_mul_return:
    jr ra

bf16_mul_return_b:
    addi a0, a1, 0
    jr ra

bf16_mul_return_bf16_nan:
    li a0, 0x7FC0
    jr ra

bf16_mul_return_result_sign_shift:
    slli a0, s3, 15
    jr ra