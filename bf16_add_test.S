.data
start: .string "BF16_MUL TESTS: \n"
newline: .string "\n"
pass_msg: .string "All tests passed!"
fail_msg: .string "Test failed!"

.text
.global main
.global bf16_mul

main:
    la a0, start
    addi a7, x0, 4
    ecall

# 1.0 + (-1.0) = 0.0
test1:
    addi a0, x0, 0x3F
    slli a0, a0, 8
    ori a0, a0, 0x80
    addi a1, x0, 0xBF
    slli a1, a1, 8
    ori a1, a1, 0x80
    jal ra, bf16_add
    addi t1, x0, 0x00
    bne a0, t1,test_fail 

# maximum finite positive number + minimal normalized number = positive infinity
test2:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x7F
    addi a1, x0, 0x7F
    slli a1, a1, 8
    ori a1, a1, 0x7F    
    jal ra, bf16_add
    addi t1, x0, 0x7F
    slli t1, t1, 8
    ori t1, t1, 0x80
    bne a0, t1,test_fail 

# 1.0000000 + 2^-8 = 1.000000
test3:
    addi a0, x0, 0x3F
    slli a0, a0, 8
    ori a0, a0, 0x80
    addi a1, x0, 0x3B
    slli a1, a1, 8
    ori a1, a1, 0x80 
    jal ra, bf16_add
    addi t1, x0, 0x3F
    slli t1, t1, 8
    ori t1, t1, 0x80
    bne a0, t1,test_fail

# inf + (-inf) = NaN
test4:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x80
    addi a1, x0, 0xFF   
    slli a1, a1, 8
    ori a1, a1, 0x80
    jal ra, bf16_add
    addi t1, x0, 0x7F
    slli t1, t1, 8
    ori t1, t1, 0xC0
    bne a0, t1,test_fail  

test_pass:
    la a0, pass_msg
    addi a7, x0, 4
    ecall
    jal new_line

test_fail:
    la a0, fail_msg
    addi a7, x0, 4
    ecall
    
new_line:
    la a0, newline
    addi a7, x0, 4
    ecall

end:
    addi a7, x0, 10
    ecall