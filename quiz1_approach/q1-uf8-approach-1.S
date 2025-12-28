.data
pass_msg: .string "All tests passed!\n"
fail_msg: .string "Test failed for value: "
test_msg: .string "Testing value: "
arrow_msg: .string " -> decoded: "
encoded_msg: .string " -> re-encoded: "
newline: .string "\n"
.align 2
.text
.globl main

main:
    # s0 will be our loop counter (0-255)
    # s1 will store the original value
    # s2 will store the decoded value
    # s3 will store the re-encoded value
    addi s0, x0, 0          

test_loop:
    # Print current test value
    la a0, test_msg
    addi a7, x0, 4
    ecall
    mv a0, s0
    addi a7, x0, 1
    ecall

    # First decode the value
    addi a0, s0, 0
    addi s1, a0, 0    # Save original value
    jal uf8_decode
    addi s2, a0, 0    # Save decoded value

    # Print decoded value
    la a0, arrow_msg
    addi a7, x0, 4
    ecall
    addi a0, s2, 0
    addi a7, x0, 1
    ecall

    # Now encode the decoded value
    addi a0, s2, 0
    jal uf8_encode
    addi s3, a0, 0       # Save re-encoded value

    # Print re-encoded value
    la a0, encoded_msg
    addi a7, x0, 4
    ecall
    addi a0, s3, 0
    addi a7, x0, 1
    ecall
    
    la a0, newline
    addi a7, x0, 4
    ecall

    # Check if re-encoded value matches original
    bne s3, s1, test_fail

    # Increment counter and continue
    addi s0, s0, 1
    addi t0, x0, 256
    blt s0, t0, test_loop

    # All tests passed
    la a0, pass_msg
    addi a7, x0, 4
    ecall
    j exit

test_fail:
    la a0, fail_msg
    addi a7, x0, 4
    ecall
    addi a0, s1, 0
    addi a7, x0, 1
    ecall
    la a0, newline
    addi a7, x0, 4
    ecall

exit:
    addi a7, x0, 10         # exit
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
    
    addi t3, x0, 0x7F    # replace pseudo instruction li t3, 0x7FFF
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
    blt a0, t4, encode_return_lt16 # if(value < 16) then return value

encode_ge16: 
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    addi s0, a0, 0 # save value, help us not to access the memory

    jal clz
    addi t0, a0, 0    # lz
    addi t1, x0, 31  
    sub t1, t1, t0    # msb = 31 - lz

    addi t2, x0, 0 # exponent = 0 
    addi t3, x0, 0 # overflow = 0
    addi t4, x0, 5

encode_if_1:
    blt t1, t4,  encode_while_2 # if(msb < 5) goto encode_while_2
    addi t2, t1, -4 # exponent = msb - 4
encode_if_2:
    addi t4, x0, 15 
    ble t2, t4, encode_for_1 # if (exponent <= 15) goto encode_for_1
    li t2, 15

encode_for_1: 
    li t4, 1
    sll t4, t4, t2
    addi t4, t4, -1
    slli t4, t4, 4
    addi t3, t4, 0

encode_while_1:
    beq t2, x0, encode_while_2
    bge s0, t3, encode_while_2
    addi t3, t3, -16
    srli t3, t3, 1
    addi t2, t2, -1
    jal x0, encode_while_1

encode_while_2:
    li t4, 15
    bge t2, t4, encode_return
    slli t6, t3, 1
    addi t6, t6, 16

encode_if_3:
    blt s0, t6, encode_return # if(value < nextoverflow) then break
    addi t3, t6, 0
    addi t2, t2, 1
    jal x0, encode_while_2

encode_return:
    sub t5, s0, t3
    srl t5, t5, t2  # mantissa = (value - overflow) >> exponent
    slli a0, t2, 4
    or a0, a0, t5
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8
    jr ra    # can be omitted

encode_return_lt16:
    jr ra
