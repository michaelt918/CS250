.text
    # test blt, bne, jal, j, jr instructions
    # $r5 will have the 'test number' before each branch/jump
    # if $r6 is ever non-zero, something screwed up. (other failure conditions are also possible, of course)
    addi $r1, $r0, 11
    addi $r2, $r0, 12
    addi $r3, $r0, 12
    addi $r4, $r0, 13

    addi $r5, $r0, 1            # TEST 1
    ble $r2, $r1, fail1          # 12<=11: branch is *NOT* taken
    
    addi $r5, $r0, 2            # TEST 2
    ble $r2, $r3, le_equal      # 12<=12: branch is taken
    
    # TEST FAIL if you get here
    addi $r6, $r0, 22           # shouldn't be executed
    halt                        # shouldn't be executed
    
    
le_equal:
    addi $r5, $r0, 3            # TEST 3
    ble $r2, $r4, le_less       # 12<=13: branch is taken
    
    # TEST FAIL if you get here
    addi $r6, $r0, 23           # shouldn't be executed
    halt                        # shouldn't be executed

fail1:
    # TEST FAIL if you get here
    addi $r6, $r0, 30           # shouldn't be executed
    halt                        # shouldn't be executed

le_less:
    addi $r1, $r0, -1
    
    addi $r5, $r0, 4            # TEST 4
    ble $r1, $r2, le_neg_less   # -1<=12: branch is taken
    
    # TEST FAIL if you get here
    addi $r6, $r0, 24           # shouldn't be executed
    halt                        # shouldn't be executed

le_neg_less:
    addi $r5, $r0, 5            # TEST 5
    bne $r2, $r3, fail2          # 12!=12: branch is *NOT* taken
    
    addi $r5, $r0, 6            # TEST 6
    bne $r2, $r4, ne_notequal   # 12!=13: branch is taken
    
    # TEST FAIL if you get here
    addi $r6, $r0, 26           # shouldn't be executed
    halt                        # shouldn't be executed
    
ne_notequal:
    addi $r5, $r0, 7            # TEST 7
    j continue_test             # jump over the following fail code
    
    # TEST FAIL if you get here
    addi $r6, $r0, 27           # shouldn't be executed
    halt                        # shouldn't be executed
    
continue_test:
    addi $r5, $r0, 8            # TEST 8
    jal my_func                 # procedure call
    # we should return here after my_func
    
    # END OF TESTS
    addi $r5, $r0, 10           # set r5 to 10 in celebration    
    halt                        # Natural end of program (halt loops forever here)

my_func:
    addi $r1, $r1, 2            # increment $r1 from -1 up to +1
    addi $r5, $r0, 9            # TEST 9
    jr $r7                      # return
    
    # TEST FAIL if you get here
    addi $r6, $r0, 29           # shouldn't be executed
    halt                        # shouldn't be executed


fail2:
    # TEST FAIL if you get here
    addi $r6, $r0, 31           # shouldn't be executed
    halt                        # shouldn't be executed

.data
