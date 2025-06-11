.equ LEDS,	0xff200000
.equ SWITCHES,	0xff200040
.global _start
_start:
	li sp,0x03fffffc
Loop:
	li t0,SWITCHES
	lw t1,0(t0)
	#SW tu 7 den 0
	andi a0,t1,0xff
	#Ham Con
	jal ra,SoNguyenTo
	#in ra led
	li t0,LEDS
	bne a0,x0,SangLED
	sw x0,0(t0)
	j Loop
SangLED:
	li t1,0xFFFFFFFF
	sw t1,0(t0)
	j Loop
SoNguyenTo:
	addi sp,sp,-16
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)
	sw s2,12(sp)
	
	mv s0,a0
	li t0,2
	
	#Cac truong hop dat biet
	blt s0,t0,Ko_SoNguyenTo
	beq s0,t0,La_SoNguyenTo
	#Check N la chan hay le
	andi t1,s0,1
	bne t1,x0,TimGioiHan
	j Ko_SoNguyenTo
TimGioiHan:
	li s1,3
	li s2,1
SoNguyenTo_Suly:# i*i > N
	mv a0,s1
	mv a1,s1
	jal ra,NhanNe
	bgt a0,s0,KiemTra
	mv s2,s1 #IMAX
	addi s1,s1,2
	j SoNguyenTo_Suly
KiemTra:
	li s1,3
KiemTra_Suly:#i > i_max
	bgt s1,s2,La_SoNguyenTo
	# Kiểm tra N % i == 0
	mv a0,s0
	mv a1,s1
	jal ra,ChiaNe
	beq a0,x0,Ko_SoNguyenTo
	addi s1,s1,2
	j KiemTra_Suly
La_SoNguyenTo:
	li a0,1
	j SoNguyenTo_Done
Ko_SoNguyenTo:
	li a0,0
SoNguyenTo_Done:
	lw ra,0(sp)
	lw s0,4(sp)
	lw s1,8(sp)
	lw s2,12(sp)
	addi sp,sp,16
	ret
	
	
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
	beq t1,x0,NhanNe_Suly
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
	