.text
.globl main
.align 2

main:
    # shift stack and save $ra, $s0, $s1, $s2
    addiu $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)              # $s0 stores location of first building
    sw $s1, 8($sp)              # $s1 stores location of current building, , 64($s1) stores efficiency of building, 68($s1) stores next building pointer
    sw $s2, 12($sp)             # $s2 stores location of last building

    li $s0, 0      # initialize head at 0 

    _make_linked_list:
        # make space in heap for building name, efficiency, next pointer
        li $v0, 9               # syscall 9 for allocating heap memory
        li $a0, 72              # 72 bits needed for listnode info, $a0 is num of bytes to allocate
        syscall
        move $s1, $v0           # heap mem address stored in $s1 (current node)

        # Prompt for building name, square footage, and annual electricity usage.
        la $a0, prompt_name     # $a0 is address of string to print
        li $v0, 4               # syscall 4 to print string
        syscall

        move $a0, $s1           # Tell syscall to put input string at $s1 (current node)
        li $a1, 64              # 64 bytes max length of string
        li $v0, 8               # syscall 8 to read string
        syscall

        jal _done_check
        bne $v0, $zero, _end_linked_list

        la $a0, prompt_sqft     # $a0 is address of string to print
        li $v0, 4               # syscall 4 to print string
        syscall

        li $v0, 5               # syscall 5 to read int (for sq footage)
        syscall
        mtc1   $v0, $f1         # Move integer from $v0 to $f1, $f1 holds sq footage
        cvt.s.w $f1, $f1        # Convert word in $f1 to single precision float

        la $a0, prompt_energy   # $a0 is address of string to print
        li $v0, 4               # syscall 4 to print string
        syscall

        li $v0, 6               # syscall 6 to read float (for electricity usage)
        syscall
        mov.s $f2, $f0          # copy electricty usage to $f2

        # check and handle for 0 square feet
        li.s $f3, 0.0           # initialize $f3 to hold 0.0 float
        c.eq.s $f1, $f3         # set condition flag to 1 if sq feet is 0.0, set flag to 0 otherwise
        bc1t _handle_zero       # branch to _handle_zero if sq feet is 0.0 (flag is 1)
        j _calc_eff             # jump to _calc_eff

        _handle_zero:
            li.s $f1, 1.0       # set sq feet (denominator) to 1.0
            li.s $f2, 0.0       # set energy usage (numerator) to 0.0
        
        # Compute energy efficiency (kWh/sq ft).
        _calc_eff:
            div.s $f4, $f2, $f1 # efficiency = energy usage / sq feet (efficiency stored in $f4)
            s.s $f4, 64($s1)    # put efficiency in correct spot after building name

        # Check if it's the first node
            beq $s0, $zero, _first_node
            sw $s1, 68($s2)     # Store address of new node in the 'next' pointer of the last node
            move $s2, $s1       # Update $s2 to point to the new last node
            j _make_linked_list

        _first_node:
            move $s0, $s1       # Set the head of the list to the first node
            move $s2, $s1       # Set the last node to the first node
            j _make_linked_list


# _done_check works
# _done_check returns 1 if string is "DONE\n and 0 otherwise"
_done_check:
    # Shift the stack and save $ra
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    # Load the base address of the string into $t0
    move $t0, $a0

    # Load the first byte (character) of the string into $t1
    lb $t1, 0($t0)
    # Compare the first byte to 'D'
    li $t2, 'D'
    bne $t1, $t2, _not_done

    # Load the second byte of the string
    lb $t1, 1($t0)
    # Compare the second byte to 'O'
    li $t2, 'O'
    bne $t1, $t2, _not_done

    # Load the third byte of the string
    lb $t1, 2($t0)
    # Compare the third byte to 'N'
    li $t2, 'N'
    bne $t1, $t2, _not_done

    # Load the fourth byte of the string
    lb $t1, 3($t0)
    # Compare the fourth byte to 'E'
    li $t2, 'E'
    bne $t1, $t2, _not_done

    # Load the fifth byte of the string
    lb $t1, 4($t0)
    # Compare the fifth byte to '\n'
    li $t2, 10
    bne $t1, $t2, _not_done

    # If all checks passed, set $v0 to 1 and return
    li $v0, 1
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

_not_done:
    # If any check failed, set $v0 to 0 and return
    li $v0, 0
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra


# checked this works
# _remove_new_line takes a string ending in \n and replaces \n with the null terminator 0
# $a0 is the address of the first character in the string.
_remove_new_line:
    # Shift $sp and store original $ra
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    # Initialize $t0 with the address of the first character in the string.
    # This will be used to traverse the string.
    move $t0, $a0

_remove_new_line_loop:
    # Load the byte (character) at the address pointed to by $t0 into $t1
    lb $t1, 0($t0)      # $t1 = *$t0

    # Check if the character is a newline ('\n')
    # If it is, replace it with the null terminator and exit the loop.
    li $t2, 10          # $t2 = 10 (ASCII value of '\n')
    beq $t1, $t2, _replace_newline 

    # If the current character is not the null terminator move on to the next character.
    addi $t0, $t0, 1   # $t0++
    j _remove_new_line_loop      # goto loop

_replace_newline:
    # Replace the newline character with the null terminator
    sb $zero, 0($t0)   # *$t0 = 0 (null terminator)

_remove_new_line_end:
    # Restore $ra and return from the function
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra             # Go home

_end_linked_list:
    li.s $f5, 0.0               # Initialize $f0 with 0
    move $s3, $s0               # copy $s0 (head) to $s3 for traversal

    _traverse_find_max:
        move $s0, $s3               # copy $s0 (head) to $s3 for traversal
        li.s $f6, -1.0
        c.eq.s $f5, $f6
        bc1t _end_main

        li.s $f5, -1.0

    _traverse_loop:
        beqz $s0 _end_traverse_max
        l.s $f4 64($s0)  # $f4 is storing the building effiency. 
        move $a0, $t2    # $t2 is storing the location of the max list node
        move $a1, $s0   # $s0 is storing the address of the current node in the linked list during traversal.
        c.eq.s $f5, $f4    # checks to see if the current node's building effiency is equal to the current max
        bc1t _name_compare
        c.lt.s $f5, $f4
        bc1t _set_max
        
        lw $s0, 68($s0)
        j _traverse_loop
        
        _set_max:
            mov.s $f5, $f4
            move $t2,  $s0
            lw $s0, 68($s0)
                   
        j _traverse_loop

# Entry point for main routine
_end_main:
    # Load back callee-saved registers from the stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    # Update the stack pointer
    addiu $sp, $sp, 12
    # Return to calling routine
    jr $ra

# Entry point for traverse max routine
_end_traverse_max:
    # Prepare arguments for _remove_new_line function
    move $a0, $t2
    # Save $t2 to stack
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    # Call _remove_new_line function
    jal _remove_new_line
    # Load back $t2 from stack
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    
    # Check if float equals -1.0
    li.s $f7, -1.0
    c.eq.s $f5, $f7
    bc1t _end_main  # Branch if condition true

    # Call _print_variables
    jal _print_variables
    li.s $f7, -1.0
    # Store -1.0 at location 64($t2)
    s.s $f7, 64($t2)
    # Jump to find max
    j _traverse_find_max

# Entry point for print variables routine
_print_variables:
    # Syscall to print something (building name)
    li $v0, 4
    syscall
    # Print space
    li $v0, 4
    la $a0, space_str
    syscall
    # Print float value
    li $v0, 2
    mov.s $f12, $f5
    syscall
    # Print newline
    li $v0, 4
    la $a0, new_line_str
    syscall
    # Return to calling routine
    jr $ra

# Entry point for name comparison
_name_compare:
    # Save callee-saved registers to stack
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)

# Loop for character-by-character comparison
_char_loop:
    # Load first characters of both strings
    lb $s0, 0($a0)
    lb $s1, 0($a1)
    # Check for end of either string
    beq $s0, $zero, _preferred_name_decision
    beq $s1, $zero, _preferred_name_decision
    # Compare characters
    bgt $s0, $s1, _preferred_name_decision
    blt $s0, $s1, _preferred_name_decision
    # Move to next characters in strings
    addiu $a0, $a0, 1
    addiu $a1, $a1, 1
    # Jump back to start of loop
    j _char_loop

# Decision point for preferred name based on comparison
_preferred_name_decision:
    # Restore callee-saved registers from stack
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    addi $sp, $sp, 20  # Update the stack pointer

    # Branch based on comparison result
    beq $s0, $s1, _traverse_loop
    j _set_max  # Jump to set max if not equal



            


.data
    prompt_name:   .asciiz "Building name: "
    prompt_sqft:   .asciiz "Square footage: "
    prompt_energy: .asciiz "Annual electricity (KwH): "
    done_str:      .asciiz "DONE\n"
    new_line_str:  .asciiz "\n"
    space_str:     .asciiz " "
