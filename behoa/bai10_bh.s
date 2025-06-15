.equ LEDS,	0xff200000
.equ SW,	0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SW
	lw t1,0(t0)
	#N 8 bit 9 den 2
	srli t1,t1,2
	andi a0,t1,0xff
	#HamCon
	jal ra,TinhToan
	#In led
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
ChiaHetNe:
	li t0,0x11
	mv a0,s0
	mv a1,t0
	jal ra,ChiaDu
	beq a0,x0,ChiaHet
	j TrongPhamVi
ChiaHet:
	addi s1,s1,1
TrongPhamVi:
	#0x18 < N < 0x40.
	li t1,0x18
	li t2,0x40
	ble s0,t1,NgoaiPhamVi
	bge s0,t2,NgoaiPhamVi
	addi s1,s1,1
	j TinhToan_Suly
NgoaiPhamVi:
	addi s1,s1,0
TinhToan_Suly:
	li t1,1
	li t2,2
	beq s1,t1,Led_0_3
	beq s1,t2,Led_4_7
	li a0,0
	j TinhToan_Done
Led_0_3:
	li a0,0xf
	j TinhToan_Done
Led_4_7:
	li a0,0xf0
TinhToan_Done:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret
#Ham chia ne
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
	beq s0,x0,ZeroNe
	li a0,1
	j ChiaDu_Done
ZeroNe:
	li a0,0
ChiaDu_Done:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret