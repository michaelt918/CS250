.text

main:
    addiu $sp, $sp, -8   # Make room on stack for $ra and $a0
    sw $ra, 4($sp)       # Save $ra to stack
    sw $a0, 0($sp)       # Save $a0 to stack

    li $v0, 4            # Syscode for print string
    la $a0, prompt       # Address of prompt string
    syscall

    li $v0, 5            # Syscode for read int
    syscall              # $v0 holds integer

    lw $a0, 0($sp)       # Restore original $a0
    move $a0, $v0        # Copy the integer N into $a0
    jal byseven

    lw $ra, 4($sp)       # Restore original $ra
    addiu $sp, $sp, 8    # Clear stack memory
    jr $ra               # Go home

byseven:
    addi $t0, $zero, 1   # Initialize i = 1 in $t0
    addi $t1, $a0, 1     # Put N+1 in $t1

_loop:
    beq $t0, $t1, end_loop_
    mul $t2, $t0, 7      # Store 7*i in $t2
    li $v0, 1            # Syscall number for print int
    move $a0, $t2        # Put 7*i in $a0
    syscall

    la $a0, new_line     # Put newline character in $a0
    li $v0, 4            # Print str code
    syscall

    addi $t0, $t0, 1     # ++i
    j _loop

end_loop_:
    jr $ra               # Go back to main

.data
    prompt: .asciiz "Input a number: "
    new_line: .asciiz "\n"  # New line character for printf