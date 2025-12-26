# bf16_div Register Lifetime

|Register|Name|Phase 1|Phase 2|
|t0||||
|t1||||
|t2||||
|t3||||
|t4||||
|t5||||
|a0|Input a|||
|a1||Input b||

bf16_div:
|Register|Name|
|t0|sign_a|
|t1|sign_b|
|t2|exp_a|
|t3|exp_b|
|t4|mant_a|
|t5|mant_b|
|t6|-|-|
|s0|result_sign|

bf16_div_check_exp_b_0xFF:
|Register|Name||
|t0|sign_a|-|
|t1|sign_b|-|
|t2|exp_a|-|
|t3|exp_b|-|
|t4|mant_a|-|
|t5|mant_b|-|
|t6|temp|Mask|
|s0|result_sign|-|

bf16_div_check_b_NaN_inf:
|Register|Name||
|t0|sign_a|-|
|t1|sign_b|-|
|t2|exp_a|-|
|t3|exp_b|-|
|t4|mant_a|-|
|t5|mant_b|-|
|t6|temp|-|
|s0|result_sign|-|

bf16_div_check_exp_a_0xFF:

bf16_div_check_a_NaN_inf: