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
	#Ham con
	jal ra,TinhToan
	li t0,LEDS
	sw a0,0(t0)
	j Loop
TinhToan:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0
	li s1,0
	li t0,0x14
	li t1,0x41
TinhToan_Suly:
	mv a0,s0
	mv a1,t0
	jal ra, ChiaNe
	beq a0,x0,ChiaHet
	j LonHon
ChiaHet:
	addi s1,s1,1
LonHon:
	bgt s0,t1,LonHon_Suly
	j TiepTuc
LonHon_Suly:
	addi s1,s1,1
TiepTuc:
	li t1,1
	li t2,2
	beq s1,t1,Led_0_3
	beq s1,t2,Led_0_9
	li a0,0
	j Done
Led_0_3:
	li a0,0xf
	j Done
Led_0_9:
	li a0,0x3ff
Done:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
#Ham
ChiaNe:
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
	j ChinaNe_Done
ZeroNe:
	li a0,0
ChinaNe_Done:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret