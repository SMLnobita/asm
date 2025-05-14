.text 
# Khai báo địa chỉ của các thiết bị ngoại vi
.equ SWITCHES, 0xFF200040        # Địa chỉ của Switches
.equ HEX3_HEX0, 0xFF200020       # Địa chỉ của HEX3-HEX0
.global _start

_start:
    # Khởi tạo các thanh ghi
    la s0, SWITCHES               # s0 = địa chỉ SWITCHES
    la s1, HEX3_HEX0              # s1 = địa chỉ HEX3_HEX0
    la s2, SEVEN_SEG_DECODE_TABLE # s2 = địa chỉ bảng mã 7 đoạn

MAIN_LOOP:
    # Đọc giá trị từ Switches
    lw s4, 0(s0)                  # s4 = giá trị Switches
    
    # Khởi tạo word kết quả bằng 0
    li s5, 0                      # s5 = 0 (word kết quả cho HEX3-HEX0)
    
    # Xử lý SW3:0 cho HEX0
    mv t0, s4                     # t0 = s4 (giá trị Switches)
    andi t0, t0, 0xF              # t0 = t0 & 0xF (4 bit thấp)
    add t1, s2, t0                # t1 = s2 + t0 (địa chỉ trong bảng)
    lb t2, 0(t1)                  # t2 = giá trị tại địa chỉ t1 (mã 7 đoạn)
    mv s5, t2                     # s5 = t2 (mã HEX0)
    
    # Xử lý SW7:4 cho HEX1
    mv t0, s4                     # t0 = s4 (giá trị Switches)
    srli t0, t0, 4                # t0 = t0 >> 4 (dịch phải 4 bit)
    andi t0, t0, 0xF              # t0 = t0 & 0xF (4 bit)
    add t1, s2, t0                # t1 = s2 + t0 (địa chỉ trong bảng)
    lb t2, 0(t1)                  # t2 = giá trị tại địa chỉ t1 (mã 7 đoạn)
    slli t2, t2, 8                # t2 = t2 << 8 (dịch trái 8 bit để đến vị trí HEX1)
    or s5, s5, t2                 # s5 = s5 | t2 (kết hợp mã HEX1)
    
    # Xử lý SW11:8 cho HEX2
    mv t0, s4                     # t0 = s4 (giá trị Switches)
    srli t0, t0, 8                # t0 = t0 >> 8 (dịch phải 8 bit)
    andi t0, t0, 0xF              # t0 = t0 & 0xF (4 bit)
    add t1, s2, t0                # t1 = s2 + t0 (địa chỉ trong bảng)
    lb t2, 0(t1)                  # t2 = giá trị tại địa chỉ t1 (mã 7 đoạn)
    slli t2, t2, 16               # t2 = t2 << 16 (dịch trái 16 bit để đến vị trí HEX2)
    or s5, s5, t2                 # s5 = s5 | t2 (kết hợp mã HEX2)
    
    # Xử lý SW15:12 cho HEX3
    mv t0, s4                     # t0 = s4 (giá trị Switches)
    srli t0, t0, 12               # t0 = t0 >> 12 (dịch phải 12 bit)
    andi t0, t0, 0xF              # t0 = t0 & 0xF (4 bit)
    add t1, s2, t0                # t1 = s2 + t0 (địa chỉ trong bảng)
    lb t2, 0(t1)                  # t2 = giá trị tại địa chỉ t1 (mã 7 đoạn)
    slli t2, t2, 24               # t2 = t2 << 24 (dịch trái 24 bit để đến vị trí HEX3)
    or s5, s5, t2                 # s5 = s5 | t2 (kết hợp mã HEX3)
    
    # Ghi word kết quả ra HEX3_HEX0
    sw s5, 0(s1)                  # Ghi giá trị s5 ra HEX3_HEX0
    
    # Đợi một chút trước khi quét lại
    li t3, 100000                 # t3 = 100000 (độ trễ)
DELAY_LOOP:
    addi t3, t3, -1               # t3 = t3 - 1
    bne t3, zero, DELAY_LOOP      # Nếu t3 != 0, tiếp tục đợi
    
    # Quay lại main loop
    j MAIN_LOOP                   # Lặp lại quá trình

# Đảm bảo căn chỉnh dữ liệu đúng
.section .data
.align 4                          # Căn chỉnh theo bội số của 4 bytes
SEVEN_SEG_DECODE_TABLE:
    .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111
    .byte 0b01100110, 0b01101101, 0b01111101, 0b00000111
    .byte 0b01111111, 0b01100111, 0b01110111, 0b01111100
    .byte 0b00111001, 0b01011110, 0b01111001, 0b01110001

.end