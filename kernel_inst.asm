j Main
j Interrupt
j Exception

Main:
lui $s0, 0x4000
# $s0 = base data address
lui $t0, 0xffff
ori $t0, $t0, 0xffff
sw $t0, 4($s0)
# TL = 0xffffffff
addiu $t0, $0, 3
sw $t0, 8($s0)
# TCON = 3

jal UARTRead
lw $a0, 28($s0) # 0x4000001c, UART_RXD
jal UARTRead
lw $a1, 28($s0)

add $s0, $a0, $0
add $s1, $a1, $0
j GCD 

UARTRead:
lw $t0, 32($s0) # 0x40000020, UART_CON
andi $t0, $t0, 8
beq $t0, $0, UARTRead
jr $ra

GCD:
slt $at, $s0, $s1
beq $at, $0, Minus
subu $s1, $s1, $s0
beq $s1, $0, Ret0
j GCD

Minus:
subu $s0, $s0, $s1
beq $s0, $0, Ret1
j GCD

Ret0:
addu $v0, $s0, $0
j LEDOut

Ret1:
addu $v0, $s1, $0

LEDOut:
lui $s0, 0x4000
sw $v0, 12($s0) # 0x4000000c, LEDs

UARTWrite:
sw $v0, 24($s0) # 0x40000018, UART_TXD

Finished:
j Finished

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
addiu $sp, $sp, 124
jal InterruptHandler
addiu $sp, $sp, -124
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
addiu $sp, $sp, 124
jal ExceptionHandler
addiu $sp, $sp, -124
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
addiu $t0, $sp, -124
lw $k1, 104($t0)
andi $t0, $k1, 1
# 0: Timer, 1: UART
beq $t0, $0, TimerInterruptHandler
j UARTInterruptHandler

ExceptionHandler:
lui $t0, 0x4000
lw $t0, 16($t0)
# $t0 = switch
andi $t0, $t0, 2
bne $t0, $0, Restore
j ExceptionHandler

Restore:
jr $ra

TimerInterruptHandler:
lui $t0, 0xffff
ori $t0, $t0, 0xfff9
# t0 = 0xffffff9
lui $t1, 0x4000
lw $t2, 8($t1)
# t1 = TCON
and $t2, $t2, $t0
# clear bit 1 and 2
sw $t2, 8($t1)

# 32'b0111111
# 32'b0000110
# 32'b1011011
# 32'b1001111
# 32'b1100110
# 32'b1101101
# 32'b1111101
# 32'b0000111
# 32'b1111111
# 32'b1101111
# 32'b1101111
# 32'b1111100
# 32'b0111001
# 32'b1011110
# 32'b1111011
# 32'b1110001
addiu $t1, $0, 63
sw $t1, 0($sp)
addiu $t1, $0, 6
sw $t1, 4($sp)
addiu $t1, $0, 91
sw $t1, 8($sp)
addiu $t1, $0, 79
sw $t1, 12($sp)
addiu $t1, $0, 102
sw $t1, 16($sp)
addiu $t1, $0, 109
sw $t1, 20($sp)
addiu $t1, $0, 125
sw $t1, 24($sp)
addiu $t1, $0, 7
sw $t1, 28($sp)
addiu $t1, $0, 127
sw $t1, 32($sp)
addiu $t1, $0, 111
sw $t1, 36($sp)
addiu $t1, $0, 111
sw $t1, 40($sp)
addiu $t1, $0, 124
sw $t1, 44($sp)
addiu $t1, $0, 57
sw $t1, 48($sp)
addiu $t1, $0, 94
sw $t1, 52($sp)
addiu $t1, $0, 123
sw $t1, 56($sp)
addiu $t1, $0, 113
sw $t1, 60($sp)

BCDScan:
lui $s2, 0x4000
lw $t2, 20($s2) # 0x40000014, BCD control
andi $t0, $t2, 0x0f00
# extract ano
srl $s0, $t0, 9
# combination of $t0 = $t0 >> 8(get ano) and $t0 = $t0 >> 1(part of ano control logic)
# ano control logic
# ano = (ano == 0b1000) ? 0b0100:
#      (ano == 0b0100) ? 0b0010:
#      (ano == 0b0010) ? 0b0001:
#      (ano == 0b0001) ? 0b1000
bne $s0, $0, Skip
addiu $s0, $0, 8
# $s0 = ano for the sequel
Skip:
addiu $t2, $0, 1
addiu $t3, $0, 2
addiu $t4, $0, 4
beq $s0, $t2, a1r
beq $s0, $t3, a1l
beq $s0, $t4, a0r
a0l:
andi $s1, $a0, 0x00f0
srl $s1, $s1, 4
j BCD7seg
a0r:
andi $s1, $a0, 0x000f
j BCD7seg
a1l:
andi $s1, $a1, 0x00f0
srl $s1, $s1, 4
j BCD7seg
a1r:
andi $s1, $a1, 0x000f

BCD7seg:
sll $t2, $s1, 2
add $t2, $sp, $t2
lw $t2, 0($t2)
# load bcd translation
sll $t0, $s0, 8
add $v0, $t0, $t2
# Concatenate ano and bcd
sw $v0, 20($s2) # 0x40000014, BCD control

DisableTCON:
lui $t1, 0x4000
lw $t2, 8($t1)
# t1 = TCON
ori $t2, $t2, 2
# set TCON[1] = 1
sw $t2, 8($t1)

j Restore

UARTInterruptHandler:
lui $s0, 0x4000
lw $t1, 32($s0) # UART_CON
andi $t1, $t1, 4
beq $t1, $0, UARTInterruptHandler
lw $t0, 24($s0) # UART_TXD
j Restore