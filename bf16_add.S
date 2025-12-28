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

# a0: a
# a1: b
# t0: sign_a
# t1: sign_b
# t2: exp_a
# t3: exp_b
# t4: mant_a
# t5: mant_b
# t6: temp
bf16_add:
    srli t0, a0, 15
    andi t0, t0, 1 # sign_a = (a.bits >> 15) & 1
    srli t1, a1, 15
    andi t1, t1, 1 # sign_b = (a.bits >> 15) & 1
    srli t2, a0, 7
    andi t2, t2, 0xFF # exp_a = (a.bits >> 7) & 0xFF
    srli t3, a1, 7
    andi t3, t3, 0xFF # exp_b = (a.bits >> 7) & 0xFF
    andi t4, a0, 0x7F # mant_a = a.bits & 0x7F
    andi t5, a1, 0x7F # mant_b = b.bits & 0x7F

bf16_add_special_cases:
    li t6, 0xFF
    bne t2, t6, bf16_add_check_b_inf_nan
    beq t3, t6, bf16_add_return_exp_b_0xFF

bf16_add_check_b_inf_nan:
    beq t3, t6, bf16_add_return_b

    or t6, t2, t4 
    beq t6, x0, bf16_add_return_b
    or t6, t3, t5
    beq t6, x0, bf16_add_return_a
    beq t2, x0, bf16_add_skip1
    ori t4, t4, 0x80 # mant_a |= 0x80

bf16_add_skip1:
    beq t3, x0, bf16_add_skip2
    ori t5, t5, 0x80 # mant_b |= 0x80

bf16_add_skip2:
    slli t4, t4, 3
    slli t5, t5, 3
bf16_add_align_branchless:
    # a0: a
    # a1: b
    # s0: unsigned_a
    # s1: unsigned_b
    # t6: temp, used as mask
    addi t6, x0, 0x7F
    slli t6, t6, 8 
    ori t6, t6, 0xFF # mask = 0x7FFF

    and s0, a0, t6 # unsigned_a = a.bits & mask
    and s1, a1, t6 # unsigned_b = b.bits & mask
    slt t6, s0, s1 # t6 = (|A| < |B|) ? 1 : 0
    sub t6, x0, t6 # t6 = (|A| < |B|) ? 0xFFFF : 0x0
    
bf16_add_branchless_swap_sign:
    # swap sign bit
    # t0: sign_a
    # t1: sign_b
    # t6: mask (0xFFFF or 0x0000)
    # s0: sign_a ^ sign_b
    xor s0, t0, t1 # s0 = sign_a ^ sign_b
    and s0, s0, t6 # use mask to check swap or not
    xor t0, t0, s0
    xor t1, t1, s0

bf16_add_branchless_swap_exponent:
    # swap exponent
    # t2: exp_a
    # t3: exp_b
    # t6: mask (0xFFFF or 0x0000)
    # s0: exp_a ^ exp_b
    xor s0, t2, t3 # s0 = exp_a ^ exp_b
    and s0, s0, t6
    xor t2, t2, s0
    xor t3, t3, s0
    
bf16_add_branchless_swap_mantissa:
    # swap mantissa
    # t4: mant_a
    # t5: mant_b
    # t6: mask (0xFFFF or 0x0000)
    # s0: mant_a ^ mant_b
    xor s0, t4, t5 # s0 = mant_a ^ mant_b
    and s0, s0, t6
    xor t4, t4, s0
    xor t5, t5, s0
    addi s1, t2, 0
    # s3: exp_diff
    # t6: mask
    sub s3, t2, t3 # exp_diff = exp_a - exp_b
    
    addi t6, x0, 8
    slt t6, t6, s3
    sub t6, x0, t6 # t6 = (8 < exp_diff) ? 0xFFFF : 0
    xori t6, t6, -1 # t6 = ~t6
    
    # align mant_b
    sra t5, t5, s3 # mant_b >>= exp_diff
    and t5, t5, t6 # mant_b &= ~mask

bf16_add_sign_compare:
    # t0: sign_a 
    # t1: sign_b 
    # t4: mant_a
    # t5: mant_b
    # s1: exp_a (bigger)
    xor t6, t0, t1 
    bne t6, x0, bf16_add_diff_sign

bf16_add_same_sign: 
    add s3, t4, t5 # result_mant = mant_a + mant_b

    andi t2, s3, 0x800 # result & 0x800, check if carry out
    beq t2, x0, bf16_add_return 
    srli s3, s3, 1 # result_mant >>= 1
    addi s1, s1, 1 # result_exp += 1
    addi t6, x0, 0xFF # check for overflow 
    bge s1, t6, bf16_add_return_overflow    
    jal x0, bf16_add_return

bf16_add_diff_sign: 
    sub s3, t4, t5 # result_mant = mant_a - mant_b 
    beq s3, x0, bf16_add_return_bf16_zero

bf16_add_normalize_loop: # normalize, maybe can optimize later
    andi t6, s3, 0x400 
    bne t6, x0, bf16_add_return 
    slli s3, s3, 1 # result_mant <<= 1
    addi s1, s1, -1 # result_exp -= 1
    blt s1, x0, bf16_add_return_bf16_zero
    jal x0, bf16_add_normalize_loop

bf16_add_return:
    # t0: result_sign
    # s1: result_exp
    # s3: result_mant
    srli s3, s3, 3
    slli t0, t0, 15 # result_sign << 15
    andi s1, s1, 0xFF # result_exp & 0xFF
    slli s1, s1, 7 # result_exp << 7
    andi s3, s3, 0x7F # result_mant & 0x7F
    or a0, t0, s1
    or a0, a0, s3
    jr ra

bf16_add_return_a:
    jr ra

bf16_add_return_b:
    addi a0, a1, 0
    jr ra

bf16_add_return_bf16_nan:
    li a0, 0x7FC0
    jr ra

bf16_add_return_exp_b_0xFF:
    bne t5, x0, bf16_add_return_b # if mant_b != 0 return b (NaN)
    xor t6, t0, t1
    beq t6, x0, bf16_add_return_b # if sign_a == sign_b return b (Inf)
    jal x0, bf16_add_return_bf16_nan # else return NaN

bf16_add_return_bf16_zero:
    addi a0, x0, 0
    jr ra

bf16_add_return_overflow:
    slli t0, t0, 15 # result_sign << 15
    addi t6, x0, 0x7F
    slli t6, t6, 8
    ori t6, t6, 0x80
    or a0, t0, t6 # return Inf
    jr ra