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
    beq t2, x0, bf16_div_return_NaN
    beq t4, x0, bf16_div_return_NaN
    jal x0, bf16_div_return_signed_zero

bf16_div_check_exp_a_0xFF: # maybe optimize later
    bne t2, t6, bf16_div_check_a_NaN_inf
    bne t4, x0, bf16_div_return_a
    jal x0, bf16_div_return_signed_inf

bf16_div_check_a_NaN_inf: # maybe optimize later
    bne t2, x0, bf16_div_a_explicit_one
    bne t4, x0, bf16_div_a_explicit_one
    jal x0, bf16_div_return_signed_zero

bf16_div_a_explicit_one:
    beq t2, x0, bf16_div_b_explicit_one
    ori t4, t4, 0x80 # mant_a |= 0x80

bf16_div_b_explicit_one:
    beq t3, x0, bf16_div_division
    ori t5, t5, 0x80 # mant_b |= 0x80

bf16_div_division: # should be optimized
    # t6: loop times
    # s1: dividend
    # s2: divisor
    # s3: quotient
    # s4: counter
    addi s1, t4, 0   # dividend = mant_a
    slli s2, t5, 1   # divisor = mant_b << 1
    addi s3, x0, 0   # quotient = 0
    addi t6, x0, 16  # loop times = 16
    addi s4, x0, 0   # counter = 0
bf16_div_division_loop:
    bge s4, t6, bf16_div_division_loop_end
    slli s3, s3, 1   # quotient <<= 1
    slli s1, s1, 1    # dividend <<= 1

    blt s1, s2, bf16_div_division_loop_sub_skip
bf16_div_division_loop_sub:
    sub s1, s1, s2 # dividend -= divisor
    ori s3, s3, 1   # quotient |= 1
bf16_div_division_loop_sub_skip:
    addi s4, s4, 1   # i++
    jal x0, bf16_div_division_loop

bf16_div_division_loop_end:
    # s5: result_exp
    add s5, t2, x0 # result_exp = exp_a
    sub s5, s5, t3 # result_exp -= exp_b
    addi s5, s5, 127 # result_exp += bias (127)

bf16_div_normalize_exp_a:
    bne t2, x0, bf16_div_normalize_exp_b
    addi s5, s5, -1

bf16_div_normalize_exp_b:
    bne t3, x0, bf16_div_normalize_quotient_if
    addi s5, s5, 1

bf16_div_normalize_quotient_if:
    addi t6, x0, 0x80
    slli t6, t6, 8 # t6 = 0x8000
    and t4, s3, t6 # t4 = quotient & 0x8000
    beq t4, x0, bf16_div_normalize_quotient_else
    srli s3, s3, 8 # quotient >>= 8
    jal x0, bf16_div_normalize_quotient_end

bf16_div_normalize_quotient_else:

bf16_div_normalize_quotient_clz:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)
    
    addi a0, s3, 0
    jal ra, branchless_16_bit_clz
    addi t6, a0, 0 # t6 = # of leading zeros

    lw ra, 0(sp)
    lw a0, 4(sp)
    addi sp, sp, 8

    addi t4, s5, -1 # t4 = result_exp - 1
    bge t6, t4, bf16_div_normalize_quotient_clz_sub_result_exp_minus_1

bf16_div_normalize_quotient_clz_sub_clz:
    sub s5, s5, t6 # result_exp -= leading_zeros
    sll s3, s3, t6 # quotient <<= leading_zeros
    jal x0, bf16_div_normalize_quotient_clz_end

bf16_div_normalize_quotient_clz_sub_result_exp_minus_1:
    addi s5, x0, 1
    sll s3, s3, t4

bf16_div_normalize_quotient_clz_end:
    srli s3, s3, 8 # quotient >>= 8

bf16_div_normalize_quotient_end:
    andi s3, s3, 0x7F # quotient & 0x7F

bf16_div_return:
    addi t6, x0, 0xFF
    bge s5, t6, bf16_div_return_signed_inf
    ble s5, x0, bf16_div_return_signed_zero
    slli a0, s0, 15 # result_sign << 15
    andi s5, s5, 0xFF
    slli s5, s5, 7 # result_exp << 7
    or a0, a0, s5
    andi s3, s3, 0x7F
    or a0, a0, s3
    jr ra

bf16_div_return_a:
    jr ra

bf16_div_return_b:
    addi a0, a1, 0
    jr ra

bf16_div_return_signed_zero:
    slli a0, s0, 15 # result_sign << 15
    jr ra

bf16_div_return_signed_inf:
    slli a0, s0, 15 # result_sign << 15
    addi t6, x0, 0x7F
    slli t6, t6, 8
    ori t6, t6, 0x80
    or a0, a0, t6 # return Inf
    jr ra

bf16_div_return_NaN:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0xC0
    jr ra
# a0: mant_a
# t0: x
# t1: s
# t2: shift
# t3: temp
# t4: temp2
branchless_16_bit_clz:
    addi sp, sp, -20
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)
    
    addi t0, a0, 0  # x = mant_a
    addi t1, x0, 0  # s = 0
    addi t2, x0, 0  # shift = 0

    addi t3, x0, 0x00FF
    slt t1, t3, t0 # s = (x > 0x00FF) ? 1 : 0
    xori t1, t1, 1 # s = (x <= 0x00FF) ? 1 : 0
    slli t4, t1, 3
    add t2, t2, t4 # shift += (s << 3)
    sll t0, t0, t4 # x <<= (s << 3)

    addi t3, x0, 0xF
    slli t3, t3, 8
    ori t3, t3, 0xFF
    slt t1, t3, t0 # s = (x > 0x0FFF) ? 1 : 0
    xori t1, t1, 1 # s = (x <= 0x0FFF) ? 1 : 0
    slli t4, t1, 2
    add t2, t2, t4 # shift += (s << 2)
    sll t0, t0, t4 # x <<= (s << 2)

    addi t3, x0, 0x3F
    slli t3, t3, 8
    ori t3, t3, 0xFF
    slt t1, t3, t0 # s = (x > 0x3FFF) ? 1 : 0
    xori t1, t1, 1 # s = (x <= 0x3FFF) ? 1 : 0
    slli t4, t1, 1
    add t2, t2, t4 # shift += (s << 1)
    sll t0, t0, t4 # x <<= (s << 1)

    addi t3, x0, 0x7F
    slli t3, t3, 8
    ori t3, t3, 0xFF
    slt t1, t3, t0 # s = (x > 0x7FFF) ? 1 : 0
    xori t1, t1, 1 # s = (x <= 0x7FFF) ? 1 : 0
    slli t4, t1, 0
    add t2, t2, t4 # shift += (s << 0)
    sll t0, t0, t4 # x <<= (s << 0)

    addi a0, t2, 0  # return shift

    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    lw t4, 16(sp)
    addi sp, sp, 20

    jr ra