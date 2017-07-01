0x00000000:
j Main
0x00000004:
j Interrupt
0x00000008:
j Exception

Main:

# TODO: Timer start
# sw TCON_start_value, TCON_address

# TODO: read two integers from UART, into $a0, $a1
# uart_in read
# lw $a0, uart_in
# uart_in read
# lw $a1, uart_in

GCD:
slt $at, $a0, $a1
beq $at, $0, Minus
subu $a1, $a1, $a0
beq $a1, $0, Ret0
j GCD

Minus:
subu $a0, $a0, $a1
beq $a0, $0, Ret1
j GCD

Ret0:
addu $v0, $a0, $0
# TODO: break

Ret1:
addu $v0, $a1, $0
# TODO: break

Interrupt:
sw $1, 0($sp)
sw $2, 4($sp)
sw $3, 8($sp)
sw $4, 12($sp)
sw $5, 16($sp)
sw $6, 20($sp)
sw $7, 24($sp)
sw $8, 28($sp)
sw $9, 32($sp)
sw $10, 36($sp)
sw $11, 40($sp)
sw $12, 44($sp)
sw $13, 48($sp)
sw $14, 52($sp)
sw $15, 56($sp)
sw $16, 60($sp)
sw $17, 64($sp)
sw $18, 68($sp)
sw $19, 72($sp)
sw $20, 76($sp)
sw $21, 80($sp)
sw $22, 84($sp)
sw $23, 88($sp)
sw $24, 92($sp)
sw $25, 96($sp)
sw $26, 100($sp)
sw $27, 104($sp)
sw $28, 108($sp)
sw $29, 112($sp)
sw $30, 116($sp)
sw $31, 120($sp)
jal InterruptHandler
lw $1, 0($sp)
lw $2, 4($sp)
lw $3, 8($sp)
lw $4, 12($sp)
lw $5, 16($sp)
lw $6, 20($sp)
lw $7, 24($sp)
lw $8, 28($sp)
lw $9, 32($sp)
lw $10, 36($sp)
lw $11, 40($sp)
lw $12, 44($sp)
lw $13, 48($sp)
lw $14, 52($sp)
lw $15, 56($sp)
lw $16, 60($sp)
lw $17, 64($sp)
lw $18, 68($sp)
lw $19, 72($sp)
lw $20, 76($sp)
lw $21, 80($sp)
lw $22, 84($sp)
lw $23, 88($sp)
lw $24, 92($sp)
lw $25, 96($sp)
lw $26, 100($sp)
lw $27, 104($sp)
lw $28, 108($sp)
lw $29, 112($sp)
lw $30, 116($sp)
lw $31, 120($sp)
addiu $k0, $k0, -4
jr $k0


Exception:
sw $1, 0($sp)
sw $2, 4($sp)
sw $3, 8($sp)
sw $4, 12($sp)
sw $5, 16($sp)
sw $6, 20($sp)
sw $7, 24($sp)
sw $8, 28($sp)
sw $9, 32($sp)
sw $10, 36($sp)
sw $11, 40($sp)
sw $12, 44($sp)
sw $13, 48($sp)
sw $14, 52($sp)
sw $15, 56($sp)
sw $16, 60($sp)
sw $17, 64($sp)
sw $18, 68($sp)
sw $19, 72($sp)
sw $20, 76($sp)
sw $21, 80($sp)
sw $22, 84($sp)
sw $23, 88($sp)
sw $24, 92($sp)
sw $25, 96($sp)
sw $26, 100($sp)
sw $27, 104($sp)
sw $28, 108($sp)
sw $29, 112($sp)
sw $30, 116($sp)
sw $31, 120($sp)
jal ExceptionHandler
lw $1, 0($sp)
lw $2, 4($sp)
lw $3, 8($sp)
lw $4, 12($sp)
lw $5, 16($sp)
lw $6, 20($sp)
lw $7, 24($sp)
lw $8, 28($sp)
lw $9, 32($sp)
lw $10, 36($sp)
lw $11, 40($sp)
lw $12, 44($sp)
lw $13, 48($sp)
lw $14, 52($sp)
lw $15, 56($sp)
lw $16, 60($sp)
lw $17, 64($sp)
lw $18, 68($sp)
lw $19, 72($sp)
lw $20, 76($sp)
lw $21, 80($sp)
lw $22, 84($sp)
lw $23, 88($sp)
lw $24, 92($sp)
lw $25, 96($sp)
lw $26, 100($sp)
lw $27, 104($sp)
lw $28, 108($sp)
lw $29, 112($sp)
lw $30, 116($sp)
lw $31, 120($sp)
addiu $k0, $k0, -4
jr $k0

# State Code Structure
# switch 0 ~ reset
# switch 1 ~ interrupting

InterruptHandler:
lw $k1, 104($sp)
andi $t0, $k1, 1
# 0: Timer, 1: UART
beq $t0, $0, TimerInterruptHandler
j UARTInterruptHandler

ExceptionHandler:
# TODO: switch address 
# lw $t0, switch_address
srl $t0, $t0, 1
andi $t0, $t0, 1
bne $t0, $0, Restore
j ExceptionHandler

Restore:
jr $ra

TimerInterruptHandler:
# lw cond, state_code_address
# processing cond
# bne cond, $0, Restore
# j TimerInterruptHandler

UARTInterruptHandler:
# lw cond, state_code_address
# processing cond
# bne cond, $0, Restore
# j UARTInterruptHandler

