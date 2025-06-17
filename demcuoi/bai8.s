.equ LEDS,0xff200000
.equ SW,0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SW
	lw t1,0(t0)
	#N 3 den 0
	andi a0,t1,0xf
	#M 7 den 4
	srli t1,t1,4
	andi a1,t1,0xf
	#Hamcon
	jal ra,Chia3Du1
	#Led
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
Chia3Du1_Suly:
	li t0,3
	mv a0,s0
	mv a1,t0
	jal ra,ChiaDu
	bne a0,x0,Cong
	j TiepTuc
Cong:
	addi s2,s2,1
TiepTuc:
	li t0,3
	mv a0,s1
	mv a1,t0
	jal ra,ChiaDu
	bne a0,x0,DoneNe
	j Xong
DoneNe:
	addi s2,s2,1
Xong:
	mv a0,s2
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret


ChiaDu:
	addi sp,sp,-12
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	
	mv s0,a0
	mv s1,a1
	li t0,1
Suly:
	blt s0,s1,Check
	sub s0,s0,s1
	j Suly
Check:
	beq s0,t0,Du
	li a0,0
	j Done
Du:
	li a0,1
Done:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret