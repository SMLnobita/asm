# Đề 12: Điều khiển dịch bit LED bằng KEY
# KEY[1]: dịch trái, KEY[2]: dịch phải, KEY[3]: đọc switch
.equ SWITCHES,	0xff200040
.equ LEDS,	0xff200000
.equ KEYS,	0xff200050
.global _start
_start:
	li sp,0x03fffffc
	li s0,0
Loop:
	jal ra,KiemTraNutNhan
	#Key1
	li t0,1
	beq a0,t0,RunKey1
	#Key2
	li t0,2
	beq a0,t0,RunKey2
	#Key3
	li t0,3
	beq a0,t0,RunKey3
	j Loop
RunKey1:
	slli s0,s0,1
	j CapNhapLed
RunKey2:
	srli s0,s0,1
	j CapNhapLed
RunKey3:
	li t0,SWITCHES
	lw s0,0(t0)
CapNhapLed:
	li t0,LEDS
	sw s0,0(t0)
DoiThaNut:
	jal ra, KiemTraNutNhan
	bne a0,x0,DoiThaNut
	j Loop
	
#Hamcon
KiemTraNutNhan:
	addi sp,sp,-8
	sw ra,0(sp)
	sw s0,4(sp)
	
	li t0,KEYS
	lw s0,0(t0)
	
	#Kiem tra KEY1
	andi t1,s0,0x2
	bne t1,x0,NhanKEY1
	
	#Kiem tra KEY2
	andi t1,s0,0x4
	bne t1,x0,NhanKEY2
	
	#Kiem tra kEY3
	andi t1,s0,0x8
	bne t1,x0,NhanKEY3
	
	li a0,0
	j Done
NhanKEY1:
	li a0,1
	j Done
NhanKEY2:
	li a0,2
	j Done
NhanKEY3:
	li a0,3
Done:
	lw ra,0(sp)
	lw s0,4(sp)
	addi sp,sp,8
	ret
