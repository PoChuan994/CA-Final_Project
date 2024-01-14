.data 
	t0_u: .word 0xACE49DCF		 # upper bits of test data0
	t0_l: .word 0xFC12BAF6		 # upper bits of test data0
	t1_u: .word 0xEA295883		 # upper bits of test data1
	t1_l: .word 0x3D019820		 # upper bits of test data1
	t2_u: .word 0x112AB2BE		 # upper bits of test data2
	t2_l: .word 0x04BB7B06		 # upper bits of test data2
	TEST_DATA_NUMS: .word 3
    str1: .string "The test data is "
    str2: .string "Result is "
    str3: .string "\n"
.text
    la    s0, t0_u                # address of upper bits of 1st test data
    li    s1, 0                   # int i=0
    lw    s2, TEST_DATA_NUMS      # nums of test data
    li    s5, 4                   # n=4, specified string 1111
    
main_for_loop:
    beq   s1, s2, Exit
    addi  s1, s1, 1               # i++
    # load test data into s3, s4 registers
    lw    s3, 0(s0)
    lw    s4, 4(s0)
    addi  s0, s0, 4               # address of next test data
    li    s7, 0                   # s7 = pos = 0
    # [tO, t1] = [s3, s4] = test data
    mv    t0, s3
    mv    t1, s4
fs:
    jal   ra, CLZ
    # x = x << clz
    li    t0, 32
    sub   t0, s0, s6
    srl   a4, s4, t0
    sll   a3, s3, s6
    or    a3, a3, a4    # a3 = s3 << clz; s3: upper bits of test data
    sll   a4, s4, s6    # a4 = s4 << clz; s4: lower bits of test data
    # [a3, a4] = [s3, s4] << clz
    add   s7, s7, s6
    # x=-x, [t0, t1] = - [a3, a4]
    xori  t0, a3, -1
    xori  t1, s4, -1
    jal   ra, CLZ
    # check: clz > n
    bge   s6, s5, Output
    mv    a3, t0
    mv    a4, t1
    li    t3, 32
    sub   t3, t3, s6
    srl   t1, a4, t3
    sll   t0, a3, s6
    or    t0, t0, t1
    sll   t1, a4, s6
    add   s7, s7, s6
    j     fs
CLZ:
    addi sp, sp, -4
    sw    ra, 0(sp)
    # x |= (x>>1)
    srli  t3, t1, 1    # shift lower bits of test data right with 1 bit
    slli  t2, t0, 31   # shift upper bits of test data left with 31 bits 
    or    t3, t2, t3   # combine to get new lower bits of test data
    srli  t2, t0, 1    # shift upper bound of test data right with 1 bit
    or    t0, t0, t2   # [0~31]x | [0~31](x >> 1)
    or    t1, t1, t3   # [32~63]x | [32~63](x >> 1)
    # x |= (x>>2);
    srli  t3, t1, 2  
    slli  t2, t0, 30  
    or    t3, t2, t3  
    srli  t2, t0, 2   
    or    t0, t0, t2  
    or    t1, t1, t3 
    # x |= (x>>4);
    srli  t3, t1, 4  
    slli  t2, t0, 28  
    or    t3, t2, t3  
    srli  t2, t0, 4   
    or    t0, t0, t2  
    or    t1, t1, t3  
    # x |= (x>>8);
    srli  t3, t1, 8  
    slli  t2, t0, 24  
    or    t3, t2, t3  
    srli  t2, t0, 8   
    or    t0, t0, t2  
    or    t1, t1, t3
    # x |= (x>>16);
    srli  t3, t1, 16  
    slli  t2, t0, 16  
    or    t3, t2, t3  
    srli  t2, t0, 16   
    or    t0, t0, t2  
    or    t1, t1, t3
    # x |= (x>>32)
    li    t2, 0
    add   t3, t0, zero
    or    t0, t0, t2
    or    t1, t1, t3
    # x -= ((x >> 1) & 0x5555555555555555)
    andi  t4, t0, 0x1
    srli  t3, t0, 1
    srli  t2, t1, 1
    slli  t4, t4, 31
    or    t2, t2, t4
    li    t4, 0x55555555
    and   t3, t3, t4
    and   t2, t2, t4
    sub   t0, t0, t3
    sub   t1, t1, t2
    #x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333)
    andi  t4, t0, 0x3
    srli  t3, t0, 2
    srli  t2, t1, 2
    slli  t4, t4, 30
    or    t2, t2, t4
    li    t4, 0x33333333
    and   t3, t3, t4        
    and   t2, t2, t4        
    and   t0, t0, t4
    and   t1, t1, t4
    add   t0, t0, t3
    add   t1, t1, t2
    #x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    andi  t4, t0, 0xf
    srli  t3, t0, 4
    srli  t2, t1, 4
    slli  t4, t4, 28
    or    t2, t2, t4
    add   t3, t3, t0
    add   t2, t2, t1
    li    t4, 0x0f0f0f0f
    and   t0, t3, t4
    and   t1, t2, t4
    #x += (x >> 8)
    andi  t4, t0, 0xff
    srli  t3, t0, 8
    srli  t2, t1, 8
    slli  t4, t4, 24
    or    t2, t2, t4
    add   t0, t0, t3
    add   t1, t1, t2
    #x += (x >> 16)
    li    t4, 0xffff
    and   t4, t4, t0
    srli  t3, t0, 16
    srli  t2, t1, 16
    slli  t4, t4, 16
    or    t2, t2, t4
    add   t0, t0, t3
    add   t1, t1, t2
    #x += (x >> 32)
    mv    t2, t0
    and   s4, t0, x0
    add   t1, t0, s4
    add   t1, t1, t2
    #64 - (x & 0x7f)
    andi  t1, t1, 0x7f
    li    t4, 64
    sub   s6, t4, t1    # store the clz into s6 register
    lw      ra, 0(sp)
    addi    sp, sp, 4
    jalr    ra
    # end of CLZ
    

Output:
    la    a0, str1
    li    a7, 4
    ecall
    mv    a0, s3
    li    a7, 34
    ecall
    mv    a0, s4
    #li    a7, 34
    ecall
    la    a0, str3
    li    a7, 4
    ecall
    la    a0, str2
    #li    a7, 4
    ecall
    # print result

    mv    a0, s7
    li    a7, 1
    ecall
    la    a0, str3
    li    a7, 4
    ecall
    j    main_for_loop
    
Exit:
    li    a7, 10
    ecall 
