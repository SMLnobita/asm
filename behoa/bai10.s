.equ SWITCHES,	0xff200040
.equ LEDS,	0xff200000
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	# 8-bit nhập từ SW[9:2]
	srli t1,t1,2
	andi a0,t1,0xff
	#Ham con
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
CheckDu:
	mv a0,s0
	jal ChiaNe
	beq a0,x0,ChiaHet
	li s1,0
	j TrongPhamVi
ChiaHet:
	li s1,1
TrongPhamVi:
	#0x18 < N < 0x40
	mv a1,s0
	li t0,0x18
	li t1,0x40
	blt a1,t0,NgoaiPhamVi
	bgt a1,t1,NgoaiPhamVi
	addi s1,s1,1
	j XuLyChung
NgoaiPhamVi:
	addi s1,s1,0
XuLyChung:
	li t1,1
	li t2,2
	beq s1,t1,LED_0_3
	beq s1,t2,LED_7_4
	li a0,0
	j Xong
LED_7_4:
	li a0,0xf0
	j Xong
LED_0_3:
	li a0,0xf
Xong:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret



ChiaNe:
	addi sp,sp,-8
	sw ra,0(sp)
	sw s0,4(sp)	
	
	mv s0,a0
	li t0,0x11
	li t1,1
ChiaNe_Check:
	beq s0,x0,ZeroNe
	blt s0,t0,ChiaNe_Xuly
	sub s0,s0,t0
	j ChiaNe_Check
ChiaNe_Xuly:
	bne s0,x0,PhatHienDu
	j ZeroNe
PhatHienDu:
	li a0,1
	j Done
ZeroNe:
	li a0,0
Done:
	lw ra,0(sp)
	lw s0,4(sp)
	addi sp,sp,8
	ret