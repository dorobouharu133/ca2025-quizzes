.data
newline: .string "\n"
pass_msg: .string "bf16_sqrt All tests passed!"
fail_msg: .string "Tests failed!"
.text
.global bf16_sqrt
.global main

main:
# sqrt(+inf) = +inf
test_1:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0x80
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0x80
    bne s0, t0, test_failed

# sqrt(NaN) = NaN
test_2:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori a0, a0, 0xC0	
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0xC0
    bne s0, t0, test_failed

# sqrt(-1.000000) = NaN
test_3:
    addi a0, x0, 0xBF
    slli a0, a0, 8
    ori a0, a0, 0x80	
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x7F
    slli t0, t0, 8
    ori t0, t0, 0xC0
    bne s0, t0, test_failed

# sqrt(2.000000) = 1.414062
test_4:
    addi a0, x0, 0x40
    slli a0, a0, 8
    jal ra, bf16_sqrt   

    addi s0, a0, 0
    addi t0, x0, 0x3F
    slli t0, t0, 8
    ori t0, t0, 0xB5
    bne s0, t0, test_failed

# sqrt(1.000000) = 1.000000
test_5:
    addi a0, x0, 0x3F
    slli a0, a0, 8
    ori a0, a0, 0x80
    jal ra, bf16_sqrt
    addi t0, x0, 0x3F
    slli t0, t0, 8
    ori t0, t0, 0x80
    bne a0, t0, test_failed

# sqrt(0.000000) = 0.000000
test_6:
    addi a0, x0, 0
    jal ra, bf16_sqrt
    addi t0, x0, 0x0000
    bne a0, t0, test_failed

# sqrt(2648071397852762090550553127902248960.000000) = 1630303065108119552.000000
test_7:
    addi a0, x0, 0x7B
    slli a0, a0, 8
    ori a0, a0, 0xFF      
    jal ra, bf16_sqrt
    addi t0, x0, 0x5D
    slli t0, t0, 8
    ori t0, t0, 0xB5       
    bne a0, t0, test_failed

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
# t0: sign
# t1: exp 
# t2: mant 
# t3: temp
# t4: e
# t5: m
# t6: new_exp
# s0: low
# s1: high
# s2: result
# s3: mid
# s4: sq
# s5: new_mant
bf16_sqrt:
    srli t0, a0, 15
    srli t1, a0, 7
    andi t1, t1, 0xFF 	# exp = (a.bits >> 7) & 0xFF
    andi t2, a0, 0x7F	# mant = a.bits & 0x7F 

sqrt_special_case:
    addi t3, x0, 0xFF
    bne t1, t3, sqrt_skip_1 # if(exp != 0xFF) then goto sqrt_skip_1
    bne t2, x0, sqrt_return_a
    bne t0, x0, sqrt_return_bf16_nan
    jal x0, sqrt_return_a

sqrt_skip_1:
    bne t1, x0, sqrt_skip_2
    beq t2, x0, sqrt_return_bf16_zero
sqrt_skip_2:
    bne t0, x0, sqrt_return_bf16_nan
sqrt_skip_3:    
    beq t1, x0, sqrt_return_bf16_zero

    addi t4, t1, -127 	# e = exp - BF16_EXP_BIAS
    ori t5, t2, 0x80 	# m = 0x80 | mant
adjust_for_odd_exponents_if:
    andi t3, t4, 1
    beq t3, x0, adjust_for_odd_exponents_else
    slli t5, t5, 1
    addi t3, t4, -1 # t4 = (e - 1)
    srli t3, t3, 1
    addi t6, t3, 127 # new_exp = ((e-1) >> 1) + BF16_EXP_BIAS
    beq x0, x0, sqrt_binary_search_initialize
adjust_for_odd_exponents_else:
    srli t3, t4, 1
    addi t6, t3, 127

sqrt_binary_search_initialize:
    addi s0, x0, 90	# low = 90
    addi s1, x0, 256 # high = 256
    addi s2, x0, 128 # result = 128

sqrt_while_loop: # binary_search
    bgt s0, s1, sqrt_normalize_greater_equal
    add s3, s0, s1 # s3 = (low + high)
    srli s3, s3, 1 # mid = (low + high) >> 1
sqrt_mul: ## mul is not allowed, need to be modified !!
    # s4: sq
    # mid*mid implement
    mul s4, s3, s3 # sq = mid * mid, need to be replaced
    srli s4, s4, 7    
    
    # use branch
sqrt_while_loop_if:
    bgt s4, t5, sqrt_while_loop_else
    addi s2, s3, 0 # result = mid
    addi s0, s3, 1 # low = mid + 1
    jal x0, sqrt_while_loop 
sqrt_while_loop_else:
    addi s1, s3, -1 # high = mid - 1
    jal x0, sqrt_while_loop 

sqrt_normalize_greater_equal: # branchless
    addi t3, x0, 256
    sltu t3, s2, t3 # t3 = (result < 256) ? 1 : 0
    xori t3, t3, 1 # t3 = (t3) ? 0 : 1, reverse t3
    srl s2, s2, t3
    add t6, t6, t3 # t6: new_exp
    jal x0, sqrt_normalize_done
sqrt_normalize_less: 
    addi s6, x0, 128
sqrt_normalize_less_loop:    
    bge s2, s6, sqrt_normalize_done
    addi t3, x0, 1
    ble t6, t3, sqrt_normalize_done
    slli s2, s2, 1
    addi t6, t6, -1
    jal x0, sqrt_normalize_less_loop
    
sqrt_normalize_done:
    andi s5, s2, 0x7F # new_mant = result & 0x7F, use t2 to store new_mant
    
    addi t3, x0, 0xFF
    bge t6, t3, sqrt_return_pInf
    ble t6, x0, sqrt_return_bf16_zero
    andi t3, t6, 0xFF
    slli t3, t3, 7
    or a0, t3, s5 # .bits = (new_exp & 0xFF) << 7 | new_mant
    jr ra

sqrt_return_a:
    jr ra
sqrt_return_bf16_nan:
    li a0, 0x7FC0
    jr ra
sqrt_return_bf16_zero:
    andi a0, x0, 0
    jr ra
sqrt_return_pInf:
    addi a0, x0, 0x7F
    slli a0, a0, 8
    ori  a0, a0, 0x80
    jr ra
