.equ SWITCHES,	0xff200040
.equ LEDS,	0xff200000
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	#SW tu 9 den 0
	andi a0,t1,0x3ff
	#Ham con
	jal ra,Day_0b1101
	#In ra LEDS
	li t0,LEDS
	sw a0,0(t0)
	j Loop
Day_0b1101:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0	#N
	li s1,0	#Luu ket qua
	li s2,0b1101	#Tim 1101
	
	li t0,7 #MAX=7
	li t1,0 #0 de dem toi 7
TimDaySo:
	beq t1,t0,KetThuc
	srl t2,s0,t1
	andi t2,t2,0xf
	beq s2,t2,TimThay
	j TiepTuc
TimThay:
	addi s1,s1,1
TiepTuc:
	addi t1,t1,1
	j TimDaySo
KetThuc:
	mv a0,s1
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret