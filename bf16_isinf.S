bf16_isinf:
    li t0, 0x7F80			# BF16_EXP_MASK
    and t1, a0, t0			# a.bits & BF16_EXP_MASK
    bne t1, t0, bf16_isinf_return_false

    andi t1, a0, 0x007F	# a.bits & BF16_MANT_MASK
    bne t1, x0, bf16_isinf_return_false # mantissa != 0

bf16_isinf_return_true:
    addi a0, x0, 1
    jr ra
    
bf16_isinf_return_false:
    addi a0, x0, 0
    jr ra