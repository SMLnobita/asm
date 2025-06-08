.equ SWITCHES,	0xff200040
.equ LEDS,	0xff200000
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	#N 3 den 0
	andi a0,t1,0xf
	#M 7 den 4
	srli t1,t1,4
	andi a1,t1,0xf
	#Ham con
	jal ra, UCLN
	#In ra led
	li t0,LEDS
	sw a1,0(t0)
	j Loop
UCLN:
	addi sp,sp,-12
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	
	mv s0,a0
	mv s1,a1
	beq s0,s1,KetQua
	beq s1,x0,KetQua
	beq s0,x0,TraVe
Check_M:
	bgt s0,s1,XuLy
	sub s1,s1,s0
	blt s1,s0,Check_M
	beq s0,s1,KetQua
	
XuLy:
	sub s0,s0,s1
	blt s0,s1,Check_M
	beq s0,s1,KetQua
TraVe:
	mv s0,s1
KetQua:
	mv a1,s0
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret
	