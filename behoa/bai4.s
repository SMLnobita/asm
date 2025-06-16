.equ LEDS,	0xff200000
.equ SW,	0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SW
	lw t1,0(t0)
	#N 3 den 0
	andi a0,t1,0xf
	#M 5 den 4
	srli t1,t1,4
	andi a1,t1,0x3
	#Hamcon
	jal ra,HamMu
	#Led
	li t0,LEDS
	sw a1,0(t0)
	j Loop
HamMu:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0
	mv s1,a1
	li s2,1
	beq s1,x0,KetThuc
HamMu_Suly:
	mv a0,s2
	mv a1,s0
	jal ra,NhanNe
	mv s2,a0
	addi s1,s1,-1
	bgt s1,x0,HamMu_Suly
KetThuc:
	mv a1,s2
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret


NhanNe:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0
	mv s1,a1
	li s2,0
	li t0,32
LSB:
	andi t1,s1,1
	beq t1,x0,Suly
	add s2,s2,s0
Suly:
	slli s0,s0,1
	srli s1,s1,1
	addi t0,t0,-1
	bgt t0,x0,LSB
	mv a0,s2
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret