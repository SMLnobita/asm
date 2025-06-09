.equ SWITCHES,	0xff200040
.equ LEDS,	0xff200000
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	#A 3 den 0
	andi a0,t1,0xf
	#B 7 den 4
	srli t1,t1,4
	andi a1,t1,0xf
	#HamCon
	jal ra,Chia3Du1
	#In ra LEDS
	li t0,LEDS
	sw a0,0(t0)
	j Loop
Chia3Du1:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0
	mv s1,a1
	li s2,0
	
	mv a0,s0
	jal ra,ChiaDu
	add s2,s2,a0
	
	mv a0,s1
	jal ra,ChiaDu
	add s2,s2,a0
	
	mv a0,s2
	
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
	
ChiaDu:
	addi sp,sp,-8
	sw ra,0(sp)
	sw s0,4(sp)
	
	mv s0,a0
	li t0,3
	li t1,1
ChiaDu_Check:
	blt s0,x0,ZeroNe
	blt s0,t0,CheckDu
	addi s0,s0,-3
	j ChiaDu_Check
CheckDu:
	bne s0,t1,ZeroNe
	mv a0,t1
	j ChiaDu_End
ZeroNe:
	mv a0,x0
ChiaDu_End:
	lw ra,0(sp)
	lw s0,4(sp)
	addi sp,sp,8
	ret