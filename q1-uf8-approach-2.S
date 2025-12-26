.data
overflow_1: .word 0x10
overflow_2: .word 0x30
overflow_3: .word 0x70
overflow_4: .word 0xF0
overflow_5: .word 0x1F0
overflow_6: .word 0x3F0
overflow_7: .word 0x7F0
overflow_8: .word 0xFF0
overflow_9: .word 0x1FF0
overflow_10: .word 0x3FF0
overflow_11: .word 0x7FF0
overflow_12: .word 0xFFF0
overflow_13: .word 0x1FFF0
overflow_14: .word 0x3FFF0
overflow_15: .word 0x7FFF0
pass_msg: .string "All test passed!"

newline: .string "\n"
.align 2
.text
.globl main

main:
    li a0, 54372
    jal uf8_encode  # call function
    
    add s0, x0, a0       # save result
    addi a7, x0, 1        # print integer
    addi a0, s0, 0
    ecall
    
    auipc a0, %pcrel_hi(newline)
    addi  a0, a0, %pcrel_lo(newline)
    addi a7, x0, 4
    ecall

    addi a7, x0, 10       # exit
    ecall

#	a0: 	x
#	t0:	n
# 	t1:	c 
#	t2:	y
clz:
	addi t0, x0, 32	# n = 32
	addi t1, x0, 16	# c = 16
clz_while:
	srl t2, a0, t1		# y = x >> c
	beq t2, x0, clz_skip
	sub t0, t0, t1		# n -= c
	addi a0, t2, 0 	# x = y
clz_skip:
	srli t1, t1, 1		# c >>= 1
	bnez t1, clz_while # while (c != 0)
clz_ret:
	sub a0, t0, a0	# return n - x
    jr ra

# a0: f1
# t0: mantissa
# t1: exponent
# t2: offset
uf8_decode:
    andi t0, a0, 0x0f    # mantissa = f1 & 0x0f
    srli t1, a0, 4       # exponent = f1 >> 4
    addi t2, x0, 15
    sub t2, t2, t1
    
    addi t3, x0, 0x7F    
    slli t3, t3, 8
    ori t3, t3, 0xFF 

    srl t3, t3, t2
    slli t3, t3, 4
    sll a0, t0, t1
    add a0, a0, t3
    jr ra

# a0: value
# t0: lz
# t1: msb
# t2: exponent
# t3: overflow
# t4: temp
# t5: mantissa
# t6: next_overflow
uf8_encode:
    addi t4, x0, 16
    blt a0, t4, encode_return_lt16 # if(value < 16) return value

encode_ge16: # function call, need to save ra, a0
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    addi s0, a0, 0 # save value

    jal clz
    addi t0, a0, 0    # lz
    addi t1, x0, 31  
    sub t1, t1, t0     # msb = 31 - lz

    addi t2, x0, 0 # exponent = 0 
    addi t3, x0, 0 # overflow = 0
    addi t4, x0, 5

encode_if_1:
    blt t1, t4,  encode_while_2 # if(msb < 5) goto encode_while_2
    addi t2, t1, -4 # exponent = msb - 4
encode_if_2:
    addi t4, x0, 15 
    ble t2, t4, encode_for_1 # if (exponent <= 15) goto encode_for_1
    addi t2, x0, 15

encode_overflow:   # calculate overflow using memory lookup
    auipc t3, %pcrel_hi(overflow_1)
    addi  t3, t3, %pcrel_lo(overflow_1) # t3 = base address of table
    addi t4, t2, -1      # t4 = exponent - 1
    slli t4, t4, 2       
    add t3, t3, t4       # t3 = &overflow_{exponent}
    lw t3, 0(t3)         # t3 = overflow


encode_while_1: # adjust exponent # need to be optimized
    beq t2, x0, encode_while_2
    slt t4, s0, t3 # t4 = (value < overflow)
    beq t4, x0, encode_while_2
    addi t3, t3, -16
    srli t3, t3, 1
    addi t2, t2, -1
    jal x0, encode_while_1

    
encode_while_2: # need to be optimized # find exact exponent
    addi t4, x0, 15
    bge t2, t4, encode_return
    slli t6, t3, 1
    addi t6, t6, 16
encode_if_3:
    blt s0, t6, encode_return
    addi t3, t6, 0
    addi t2, t2, 1
    jal x0,  encode_while_2
encode_return:   

    sub t5, s0, t3
    srl t5, t5, t2 # mantissa = (value - overflow) >> exponent
    slli a0, t2, 4 
    or a0, a0, t5

    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8    # restore stack 
    jr ra

encode_return_lt16:
    jr ra

