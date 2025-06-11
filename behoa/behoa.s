#HamChia
ChiaNe:
	addi sp,sp,-12
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	
	mv s0,a0	#Số bị chia
	mv s1,a1	#Số chia
ChiaNe_Suly:
	blt s0,s1,KetQua
	sub s0,s0,s1
	j ChiaNe_Suly
KetQua:
	mv a0,s0
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	addi sp,sp,12
	ret
#HamNhan
NhanNe:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0	#CAND
	mv s1,a1	#ER
	li s2,0		#PROB
	li t0,32
NhanNe_LSB:
	andi t1,s1,1
	beq t1,0,NhanNe_Suly
	add s2,s2,s0
NhanNe_Suly:
	slli s0,s0,1
	srli s1,s1,1
	addi t0,t0,-1
	bgt t0,x0,NhanNe_LSB
	mv a0,s2
NhanNe_Xong:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
	