# a0: a
# a1: b
# t0: sign_a
# t1: sign_b
# t2: exp_a
# t3: exp_b
# t4: mant_a
# t5: mant_b
# t6: temp
# s0: exp_diff
# s1: result_sign
# s2: result_exp
# s3: result_mant
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
    sub s0, t2, t3 # exp_diff = exp_a - exp_b
    
bf16_add_align_if: # need to be improved
    ble s0, x0, bf16_add_align_else_if
    addi s2, t2, 0 # result_exp = exp_a
    li t6, 8
    bgt s0, t6, bf16_add_return_a
    srl t5, t5, s0 # mant_b >>= exp_diff
    jal x0, bf16_add_align_done

bf16_add_align_else_if:
    beq s0, x0, bf16_add_align_else
    addi s2, t3, 0 # result_exp = exp_b
    li t6, -8
    blt s0, t6, bf16_add_return_b
    neg t6, s0
    srl t4, t4, t6 # mant_a >>= -exp_diff
    jal x0, bf16_add_align_done

bf16_add_align_else:
    addi s2, t2, 0 # result_exp = exp_a

bf16_add_align_done:
    bne t0, t1, bf16_add_skip1 # if(sign_a != sign_b) goto bf16_add_skip1
    addi s1, t0, 0 # result_sign = sign_a
    add s3, t4, t5 # result_mant = mant_a + mant_b
    andi t6, s3, 0x100
    beq t6, x0, bf16_add_return # if (result_mant & 0x100) == 0 return bf16_add_return
    srli s3, s3, 1 # result_mant >>= 1
    addi s2, s2, 1 # result_exp += 1
    li t6, 0xFF
    blt s2, t6, bf16_add_return # if (result_exp < 0xFF) return bf16_add_return
    slli a0, s1, 15 # result_sign << 15
    li t6, 0x7F80
    or a0, a0, t6 # result_sign << 15 | 0x7F80
    jr ra

bf16_add_skip3:
    blt t4, t5, bf16_add_skip4
    addi s1, t0, 0 # result_sign = sign_a
    sub s3, t4, t5 # result_mant = mant_a - mant_b
    jal x0, bf16_add_skip5
    
bf16_add_skip4:
    addi s1, t1, 0 # result_sign = sign_b
    sub s3, t5, t4 # result_mant = mant_b - mant_a
    
bf16_add_skip5:
    beq s3, x0, bf16_add_return_bf16_zero
    
bf16_add_while:
    li t6, 0x80
    and t6, s3, t6
    beq t6, x0, bf16_add_return
    slli s3, s3, 1
    addi s2, s2, -1
    ble s2, x0, bf16_add_return_bf16_zero
    jal x0, bf16_add_while

bf16_add_return:
    slli t6, s1, 15 # result_sign << 15
    andi a0, s2, 0xFF # result_exp & 0xFF
    slli a0, a0, 7 # (result_exp & 0xFF) << 7
    or t6, a0, t6 # result_sign << 15 | (result_exp & 0xFF) << 7
    andi t6, s3, 0x7F # result_mant & 0x7F
    or a0, t6, a0 # result_sign << 15 | (result_exp & 0xFF) << 7 | (result_mant & 0x7F)
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
    li a0, 0x0000
    jr ra