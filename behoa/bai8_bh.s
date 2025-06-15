.equ LEDS,	0xff200000
.equ SW,	0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SW
	lw t1,0(t0)
	#A 4 bit 3 den 0
	andi a0,t1,0xf
	#B 4 bit 7 den 4
	srli t1,t1,4
	andi a1,t1,0xf
	#Ham Con
	jal ra,Chia3Du1
	#In ra led
	li t0,LEDS
	sw a0,0(t0)
	j Loop
Chia3Du1:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0	#A
	mv s1,a1	#B
	li s2,0
Chia3Du1_Suly:
	li t0,3
	mv a0,s0
	mv a1,t0
	jal ra,ChiaDu
	add s2,s2,a0
	
	li t0,3
	mv a0,s1
	mv a1,t0
	jal ra,ChiaDu
	add s2,s2,a0
Chia3Du1_Done:
	mv a0,s2
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
	
	
ChiaDu:
	addi sp,sp,-12
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	
	mv s0,a0
	mv s1,a1
Suly:
	blt s0,s1,Check
	sub s0,s0,s1
	j Suly
Check:
	li t0,1
	beq s0,t0,Du
	li a0,0
	j ChiaNeDone
Du:
	li a0,1
ChiaNeDone:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret