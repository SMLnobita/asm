.data
SEVEN_SEG_DECODE_TABLE: 
    .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111
    .byte 0b01100110, 0b01101101, 0b01111101, 0b00000111
    .byte 0b01111111, 0b01100111, 0b00000000, 0b00000000
    .byte 0b00000000, 0b00000000, 0b00000000, 0b00000000
.equ SWITCHES,	0xff200040
.equ HEX_Base,	0xff200020
.text
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	#A 3 den 0
	andi a0,t1,0xf
	#B 7 den 3
	srli t1,t1,4
	andi a1,t1,0xf
	#HamCon
	jal ra,addHaiSo
	jal ra,InRaLed
	j Loop
addHaiSo:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0
	mv s1,a1
	li s2,0
	
	add s2,s0,s1
	mv a0,s2
	
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
InRaLed:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)	#SUM
	sw s1,8(sp)	#Chuc
	sw s2,12(sp)#Don vi
	
	mv s0,a0
	li s1,0
	mv s2,s0
	li t0,10
InRaLedNe:
	blt s2,t0,InRaLed_Done
	sub s2,s2,t0
	addi s1,s1,1
	j InRaLedNe
InRaLed_Done:
	#So chuc
	mv a0,s1
	jal ra,Led7Doan
	mv t1,a0
	#So don vi
	mv a0,s2
	jal ra,Led7Doan
	mv t2,a0
	
	slli t1,t1,8
	or t1,t1,t2
	
	li t0,HEX_Base
	sw t1,0(t0)
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
Led7Doan:
	addi sp,sp,-8
	sw ra,0(sp)
	sw s0,4(sp)
	
	
	mv s0,a0
	li t0,9
	blt s0,x0,ZeroNe
	bgt s0,t0,ZeroNe
	
	
	la t0,SEVEN_SEG_DECODE_TABLE
	add t0,t0,s0
	lb a0,0(t0)
	j Led7Doan_Done
ZeroNe:
	li a0,0x0
	j Led7Doan_Done
Led7Doan_Done:
	lw ra,0(sp)
	lw s0,4(sp)
	addi sp,sp,8
	ret