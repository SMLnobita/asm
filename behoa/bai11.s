.equ SWITCHES,	0xff200040
.equ LEDS,	0xff200000
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	#SW 8Bit tu 9 den 2
	srli t1,t1,2
	andi a0,t1,0xff
	#HamCon
	jal ra,TinhToan
	#In ra LEDS
	li t0,LEDS
	sw a0,0(t0)
	j Loop
TinhToan:
	addi sp,sp,-12
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	
	mv s0,a0
	li s1,0
	li t0,0x41
CheckDu:
	mv a0,s0
	jal ra,ChiaNe
	beq a0,x0,ChiaHet
	j LonHon
ChiaHet:
	addi s1,s1,1
LonHon:
	#0x41
	mv a1,s0
	bgt a1,t0,ThoaDieuKien
	j Ham_Xuly
ThoaDieuKien:
	addi s1,s1,1
Ham_Xuly:
	li t1,1
	li t2,2
	beq s1,t1,LED_0_3
	beq s1,t2,LED_0_9
	li a0,0
	j Xong
LED_0_3:
	li a0,0xf
	j Xong
LED_0_9:
	li a0,0x3ff
Xong:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret
#Ham chia het hoac du
ChiaNe:
	addi sp,sp,-8
	sw ra,0(sp)
	sw s0,4(sp)
	
	mv s0,a0
	li t0,0x14
ChiaNe_XuLy:
	beq s0,t0,ZeroNe
	blt s0,t0,KiemTra
	sub s0,s0,t0
	j ChiaNe_XuLy
KiemTra:
	bne s0,x0,Du
	j ZeroNe
Du:
	li a0,1
	j Done
ZeroNe:
	li a0,0
Done:
	lw ra,0(sp)
	lw s0,4(sp)
	addi sp,sp,8
	ret