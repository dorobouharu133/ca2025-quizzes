# a0: a
# a1: b
# t0: sign_a
# t1: sign_b
# t2: exp_a
# t3: exp_b
# t4: mant_a
# t5: mant_b
# t6: temp
# s0: result_sign
bf16_div:
    srli t0, a0, 15
    andi t0, t0, 1 # t0 = (a.bits >> 15) & 1, sign_a

    srli t1, a1, 15
    andi t1, t1, 1 # t1 = (b.bits >> 15) & 1, sign_b

    srli t2, a0, 7
    andi t2, t2, 0xFF # t2 = (a.bits >> 7) & 0xFF, exp_a

    srli t3, a1, 7
    andi t3, t3, 0xFF # t3 = (b.bits >> 7) & 0xFF, exp_b

    andi t4, a0, 0x7F # t4 = a.bits & 0x7F, mant_a
    andi t5, a1, 0x7F # t5 = a.bits & 0x7F, mant_b

    xor s0, t0, t1 # result_sign = sign_a ^ sign_b

bf16_div_check_exp_b_0xFF: # maybe optimize later
    addi t6, x0, 0xFF
    bne t3, t6, bf16_div_check_b_NaN_inf
    bne t5, x0, bf16_div_return_b
    bne t2, t6, bf16_div_return_signed_zero
    bne t4, x0, bf16_div_return_signed_zero
    jal x0, bf16_div_return_NaN
bf16_div_check_b_NaN_inf: # maybe optimize later
    bne t3, x0, bf16_div_check_exp_a_0xFF
    bne t5, x0, bf16_div_check_exp_a_0xFF
    bne t2, x0, bf16_div_return_NaN
    bne t4, x0, bf16_div_return_NaN
    jal x0, bf16_div_return_signed_zero

bf16_div_check_exp_a_0xFF: # maybe optimize later
    bne t2, t6, bf16_div_check_a_NaN_inf
    bne t4, x0, bf16_div_return_a
    jal x0, bf16_div_return_signed_inf
bf16_div_check_a_NaN_inf: # maybe optimize later
    bne t1, x0, bf16_div_a_explicit_one
    bne t4, x0, bf16_div_a_explicit_one
    jal x0, bf16_div_return_signed_zero
bf16_div_a_explicit_one:
    beq t4, x0, bf16_div_b_explicit_one
    ori t4, t4, 0x80 # mant_a |= 0x80
bf16_div_b_explicit_one:
    beq t5, x0, bf16_div_b_division
    ori t5, t5, 0x80 # mant_b |= 0x80

bf16_div_b_division:
    # s0: divident
    # s1: quotient
    # t5: divisor, equal to mant_b
    slli s0, t4, 15 # divident = mant_a << 15

    addi s2, x0, 0
    addi t6, x0, 16
bf16_div_division_for_loop: # should be optimize later
    # t6: 16
    # t4: 15-i
    # t5: divisor << (15-i)
    bge s2, t6, bf16_div_normalize
    slli s1, s1, 1 # quotient <<= 1
    addi t4, x0, 15
    sub t4, t4, s2 # t4 = 15 - i
    slli t5, t5, t4 # t5 = divisor << (15 - i)
    blt s0, t5, bf16_div_division_skip_subtract
    sub s0, s0, t5 # divident -= divisor << (15 - i)
    ori s1, s1, 1 # quotient |= 1

bf16_div_division_skip_subtract:
    addi s2, s2, 1
    jal x0, bf16_div_division_for_loop

bf16_div_normalize:
    # s3: result_exp
    addi s3, t2, 0 # result_exp = exp_a
    sub s3, s3, t3 # result_exp -= exp_b
    addi s3, s3, 127 # result_exp += BF16_EXP_BIAS

bf16_div_normalize_exp_a: # can be optimized later
    bne t2, x0, bf16_div_normalize_exp_b
    addi s3, s3, -1

bf16_div_normalize_exp_b: # can be optimized later
    bne t3, x0, bf16_div_normalize_quotient
    addi s3, s3, -1

bf16_div_normalize_quotient_if: # can be optimized later
    # t4: quotient & 0x8000
    # t6: temp, mask for 0x8000
    addi t6, x0, 0x80
    slli t6, t6, 8
    andi t4, s1, t6
    beq t4, x0, bf16_div_normalize_quotient_else
    srli s1, s1, 8 # quotient >>= 8
    jal x0, bf16_div_normalize_finish

bf16_div_normalize_quotient_else: # should be optimized later
    addi t5, x0, 1
bf16_div_normalize_quotient_else_while_loop:
    # t4: quotient & 0x8000
    # t5: 1
    # t6: temp, mask for 0x8000
    bne t4, x0, bf16_div_normalize_quotient_else_while_loop_finish
    bge s3, t5, bf16_div_normalize_quotient_else_while_loop_finish
    slli s1, s1, 1 # quotient <<= 1
    addi s3, s3, -1
    jal x0, bf16_div_normalize_quotient_else_while_loop
bf16_div_normalize_quotient_else_while_loop_finish:
    srli s1, s1, 8 # quotient >>= 8

bf16_div_normalize_finish:
    # t6: temp, 0xFF
    andi t6, t6, 0xFF # quotient &= 0xFF
    bgt s3, t6, bf16_div_return_signed_inf
    ble s3, x0, bf16_div_return_signed_zero
    addi a0, s0, 0 # a0: result_sign
    slli a0, a0, 15 # a0: result_sign << 15
    andi s3, s3, 0xFF
    slli s3, s3, 7 # s3: (result_exp & 0xFF) << 7
    or a0, a0, s3
    andi s1, s1, 0x7F # s1: quotient & 0x7F
    or a0, a0, s1
    jr ra

bf16_div_return_b:
    addi a0, a1, 0
    jr ra

bf16_div_return_signed_zero:
    slli a0, s0, 15 # result_sign << 15
    jr ra

bf16_div_return_NaN:
    addi a0, x0, 0x7FC0
    jr ra