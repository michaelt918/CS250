
.text
.globl main

main:
    addiu $sp, $sp, -4          # Shift stack and store $ra
    sw $ra, 0($sp)

    li $v0, 4                   # Print prompt
    la $a0, prompt
    syscall

    li $v0, 5                   # Read integer
    syscall

    move $a0, $v0               # Copy N to $a0
    jal recurse

    move $a0, $v0               # Print result
    li $v0, 1
    syscall

    lw $ra, 0($sp)              # Restore $ra
    addiu $sp, $sp, 4           # Clear stack
    jr $ra                      # Go home


recurse:
    # Save return address and other registers
    addiu $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # Check if n == 0
    move $s0, $a0
    beq $s0, $zero, base_case

    # Calculate 3 * (n - 1) + 1
    sub $s0, $s0, 1
    mul $s1, $s0, 3
    addi $s1, $s1, 1

    # Prepare to call recurse(n - 1)
    move $a0, $s0
    jal recurse

    # Restore $ra here
    lw $ra, 0($sp)

    add $s1, $v0, $s1
    move $v0, $s1

    # Restore other saved registers and stack
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

# Base case: return 2
base_case:
    li $v0, 2
    j end_recurse  # Jump to the end of recurse to restore $ra and other registers

end_recurse:
    # Restore saved registers and stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

.data
    prompt: .asciiz "Input an integer: "

