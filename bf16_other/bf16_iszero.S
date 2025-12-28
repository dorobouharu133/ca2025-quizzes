bf16_iszero:
    addi t0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0xFF
    and t1, a0, t0
    beq t1, x0, bf16_iszero_return_true
    
bf16_iszero_return_false:
    addi a0, x0, 0
    jr ra
    
bf16_iszero_return_true: 
    addi a0, x0, 1
    jr ra