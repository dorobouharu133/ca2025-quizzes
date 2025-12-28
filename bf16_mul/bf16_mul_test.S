.data
start: .string "BF16_MUL TESTS: \n"
newline: .string "\n"
pass_msg: .string "All tests passed!"
fail_msg: .string "Test failed!"

.text
.global main
.global bf16_mul
.global shift_and_add

main:
    la a0, start
    li a7, 4
    ecall
# maximal finite positive number x minimal finite normalized positive number
test1:
    li a0, 0x7F7F
    li a1, 0x0080
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x407F
    bne a0, t1,test_fail 

# NaN x 1.000000 = NaN
test2:
    li a0, 0x7FC0   
    li a1, 0x3F80    
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7FC0
    bne t0, t1,test_fail 

# +inf x (-inf) = (-inf)
test3:
    li a0, 0x7F80 
    li a1, 0xFF80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0xFF80
    bne t0, t1,test_fail

# 3.000000 x 2.000000 = 6.000000
test4:
    li a0, 0x4040 
    li a1, 0x4000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x40C0
    bne t0, t1,test_fail  

# 1.000000 x 1.000000 = 1.000000
test5:
    li a0, 0x3F80  
    li a1, 0x3F80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x3F80
    bne t0, t1,test_fail

# 0.000000 x (-0.000000) = (-0.000000)
test6:
    li a0, 0x0000
    li a1, 0x8000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x8000
    bne t0, t1,test_fail 

# +inf x 0.000000 = NaN
test7:
    li a0, 0x7F80
    li a1, 0x0000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7FC0
    bne t0, t1,test_fail

# maximal finite positive number x 2.000000 = +inf
test8:
    li a0, 0x7F7F
    li a1, 0x4000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7F80
    bne t0, t1,test_fail

# minimal finite normalized positive number x minimal finite normalized positive number = 0.000000
test9:
    li a0, 0x0080
    li a1, 0x0080
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x0000
    bne t0, t1,test_fail

# NaN x 1.000000 = NaN
test10:
    li a0, 0x7FC0
    li a1, 0x3F80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x7FC0
    bne t0, t1,test_fail

# (-inf) x +inf = -inf
test11:
    li a0, 0xFF80
    li a1, 0x7F80
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0xFF80
    bne t0, t1,test_fail

# 1.007812 x 1.007812 = 1.015625
test12:
    li a0, 0x3F81
    li a1, 0x3F81
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x3F82
    bne t0, t1,test_fail

# -2.000000 x 3.000000 = -6.000000
test13:
    li a0, 0xC000
    li a1, 0x4040
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0xC0C0
    bne a0, t1,test_fail

# minimal finite denormalized positive number x minimal finite denormalized positive number = 0.000000
test14:
    li a0, 0x0040
    li a1, 0x0040
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x0000
    bne t0, t1,test_fail

# 1.007812 x 2.000000 = 2.015625
test15:
    li a0, 0x3F81
    li a1, 0x4000
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x4001
    bne t0, t1,test_fail

# 3.000000 x 0.500000 = 1.500000
test16:
    li a0, 0x4040
    li a1, 0x3F00
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x3FC0
    bne t0, t1,test_fail

# 5.000000 x 0.500000 = 2.500000
test17:
    li a0, 0x40A0
    li a1, 0x3F00
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x4020
    bne t0, t1,test_fail

# 2.250000 x 2.250000 = 5.062500
test18:
    li a0, 0x4010
    li a1, 0x4010
    jal ra, bf16_mul
    addi t0, a0, 0
    li t1, 0x40A2
    bne t0, t1,test_fail

test_pass:
    la a0, pass_msg
    addi a7, x0, 4
    ecall
    jal x0, new_line

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
