bf16_sub:
    addi t0, x0, 0x80
    slli t0, t0, 8
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a1, 0(sp)
    xor a1, a1, t0      # negate b
    jal bf16_add
    lw a1, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    jr ra