.equ LEDS,	0xff200000
.equ SW,	0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SW
	lw t1,0(t0)
	#N 10 bit 9 den 0
	andi a0,t1,0x3ff
	#Ham con
	jal ra,TimKiem
	#in ra led
	li t0,LEDS
	sw a0,0(t0)
	j Loop
	
TimKiem:
	addi sp,sp,-12
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	
	mv s0,a0
	li s1,0
	li t0,0b1101
Suly:
	beq s0,x0,TimKiemDone
	andi t1,s0,0xf
	beq t1,t0,TimThay
	j TiepTuc
TimThay:
	addi s1,s1,1
TiepTuc:
	srli s0,s0,1
	j Suly
TimKiemDone:
	mv a0,s1
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret

	