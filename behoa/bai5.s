.equ SWITCHES, 0xff200040
.equ LEDS, 0xff200000
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	#Nut N 3-0
	andi a2,t1,0xf
	#Nut M 7-4
	srli t1,t1,4
	andi a3,t1,0xf
	#Ham cong
	jal ra,NhanV2
	#in Leds
	li t0,LEDS
	sw a1,0(t0)
	j Loop
NhanV2:
	addi sp,sp,-20
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	sw s3,16(sp)
	
	mv s0,a2	#CAND
	mv s1,a3	#ER
	li s2,0 	#PROB_LOW
	li s3,0		#PROB_HIGH
	li t4,32
Check_LSB:
	andi t1,s1,1
	beq t1,x0,NhanV2_SuLy
	add s3,s3,s0
NhanV2_SuLy:
	andi t2,s3,1
	srli s3,s3,1
	slli t2,t2,31
	srli s2,s2,1
	or s2,s2,t2
	
	srli s1,s1,1
	addi t4,t4,-1
	bgt t4,x0,Check_LSB
	
	mv a1,s2
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	lw s3,16(sp)
	addi sp,sp,20
	ret