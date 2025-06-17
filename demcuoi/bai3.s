.equ LEDS, 0xff200000
.equ SW,0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	#N từ SW[3:0], M từ SW[7:4]
	li t0,SW
	lw t1,0(t0)
	#N 3 den 0
	andi a0,t1,0xf
	#M 7 den 4
	srli t1,t1,4
	andi a1,t1,0xf
	#Hamcon
	jal ra,UCLN
	#Led
	li t0,LEDS
	sw a0,0(t0)
	j Loop

UCLN:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0 #N
	mv s1,a1 #M
	li s2,0
	beq s0,x0,BangS1
	beq s1,x0,BangS0
UCLN_Suly:
	beq s0,s1,UCLN_Done
	bgt s0,s1,A_SUB_B
	sub s1,s1,s0
	j UCLN_Suly
A_SUB_B:
	sub s0,s0,s1
	j UCLN_Suly
BangS1:
	mv a0,s1
	j Done
BangS0:
	mv a0,s0
	j Done
UCLN_Done:
	mv a0,s1
Done:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret