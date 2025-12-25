f32_to_bf16:
    srli t0, a0, 23 # f32bits >> 23
    andi t0, t0, 0xFF
    li t1, 0xFF
    beq t0, t1, f32_to_bf16_return_if_equal # if(((f32bits >> 23) & 0xFF) == 0xFF) return

f32_to_bf16_return:
    srli t0, a0, 16
    andi t0, t0, 1
    li t1, 0x7FFF
    add t0, t0, t1
    add a0, a0, t0
    
    srli a0, a0, 16
    and a0, a0, t1 
    jr ra
f32_to_bf16_return_if_equal:
    srli a0, a0, 16
    and a0, a0, t1
    jr ra