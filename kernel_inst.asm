j Main
j Interrupt
j Exception

Main:
lui $s0, 0x4000
# $s0 = base data address
addiu $t0, $0, -2048
sw $t0, 0($s0)
sw $t0, 4($s0)
# TH, TL = -2048
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
sw $31, 12($sp)
jal StoreState
addiu $sp, $sp, 16
lui $s0, 0x4000
jal InterruptHandler
addiu $sp, $sp, -16
jal LoadState
lw $31, 12($sp)
addiu $k0, $k0, -4
jr $k0

Exception:
sw $31, 12($sp)
jal StoreState
addiu $sp, $sp, 16
lui $s0, 0x4000
jal ExceptionHandler
addiu $sp, $sp, -16
jal LoadState
lw $31, 12($sp)
addiu $k0, $k0, -4
jr $k0

StoreState:
sw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
jr $ra

LoadState:
lw $s0, 0($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
jr $ra

Restore:
jr $ra

# State Code Structure
# switch 0 ~ reset
# switch 1 ~ interrupting

InterruptHandler:
andi $s1, $k1, 1
# 0: Timer, 1: UART
beq $s1, $0, TimerInterruptHandler
j UARTInterruptHandler

ExceptionHandler:
lw $s1, 16($s0)
# $s1 = switch
andi $s1, $s1, 2
bne $s1, $0, Restore
j ExceptionHandler

TimerInterruptHandler:
lw $s2, 8($s0)
# s2 = TCON
addiu $s1, $0, -7
# s1 = 0xffffff9
and $s2, $s2, $s1
# clear bit 1 and 2
sw $s2, 8($s0)

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
addiu $s2, $0, 63
sw $s2, 0($sp)
addiu $s2, $0, 6
sw $s2, 4($sp)
addiu $s2, $0, 91
sw $s2, 8($sp)
addiu $s2, $0, 79
sw $s2, 12($sp)
addiu $s2, $0, 102
sw $s2, 16($sp)
addiu $s2, $0, 109
sw $s2, 20($sp)
addiu $s2, $0, 125
sw $s2, 24($sp)
addiu $s2, $0, 7
sw $s2, 28($sp)
addiu $s2, $0, 127
sw $s2, 32($sp)
addiu $s2, $0, 111
sw $s2, 36($sp)
addiu $s2, $0, 119
sw $s2, 40($sp)
addiu $s2, $0, 124
sw $s2, 44($sp)
addiu $s2, $0, 57
sw $s2, 48($sp)
addiu $s2, $0, 94
sw $s2, 52($sp)
addiu $s2, $0, 123
sw $s2, 56($sp)
addiu $s2, $0, 113
sw $s2, 60($sp)

BCDScan:
lw $s2, 20($s0) # 0x40000014, BCD control
andi $s2, $s2, 0x0f00
# extract ano
srl $s1, $s2, 9
# combination of $s1 = $s2 >> 8(get ano) and $s1 = $s2 >> 1(part of ano control logic)
# ano control logic
# ano = (ano == 0b1000) ? 0b0100:
#      (ano == 0b0100) ? 0b0010:
#      (ano == 0b0010) ? 0b0001:
#      (ano == 0b0001) ? 0b1000
bne $s1, $0, Skip
addiu $s1, $0, 8
# $s1 = ano for the sequel
Skip:
addiu $s2, $0, 1
beq $s1, $s2, a1r
sll $s2, $s2, 1
beq $s1, $s2, a1l
sll $s2, $s2, 1
beq $s1, $s2, a0r
a0l:
andi $s2, $a0, 0x00f0
srl $s2, $s2, 4
j BCD7seg
a0r:
andi $s2, $a0, 0x000f
j BCD7seg
a1l:
andi $s2, $a1, 0x00f0
srl $s2, $s2, 4
j BCD7seg
a1r:
andi $s2, $a1, 0x000f

BCD7seg:
sll $s2, $s2, 2
add $s2, $sp, $s2
lw $s2, 0($s2)
# load bcd translation
sll $s1, $s1, 8
add $s1, $s1, $s2
# Concatenate ano and bcd
sw $s1, 20($s0) # 0x40000014, BCD control

DisableTCON:
lw $s1, 8($s0)
# $s1 = TCON
ori $s1, $s1, 2
# set TCON[1] = 1
sw $s1, 8($s0)
j Restore

UARTInterruptHandler:
lw $s1, 32($s0) # UART_CON
andi $s1, $s1, 4
beq $s1, $0, UARTInterruptHandler
lw $s1, 24($s0) # UART_TXD
addi $s1,$0,-2
and $k1,$k1,$s1
j Restore