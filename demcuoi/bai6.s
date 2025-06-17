.equ LEDS,0xff200000
.equ SW,0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SW
	lw t1,0(t0)
	#multiplicand x12 = SW[3:0]
	andi a2,t1,0xf
	# multiplier x13 = SW[7:4] 
	srli t1,t1,4
	andi a3,t1,0xf
	#Hamcon
	jal ra,NhanNe
	#LED
	li t0,LEDS
	sw a1,0(t0)
	j Loop
NhanNe:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a2
	mv s1,a3
	li s2,0
	li t0,32
LSB:
	andi t1,s1,1
	beq t1,x0,Check
	add s2,s2,s0
Check:
	slli s0,s0,1
	srli s1,s1,1
	addi t0,t0,-1
	bgt t0,x0,LSB
	mv a1,s2
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
	