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