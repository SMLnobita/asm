.section .text
.equ SW, 0xFF200040            # Địa chỉ của switch (SW)
.equ HEX3_HEX0, 0xFF200020     # Địa chỉ của LED 7 đoạn HEX3-HEX0

.global _start
_start:
    ################################################################
    #                     Khởi tạo thanh ghi
    ################################################################
    # s1 = địa chỉ SW
    la s1, SW
    
    # s2 = địa chỉ HEX3_HEX0
    la s2, HEX3_HEX0
    
    # s3 = địa chỉ bảng giải mã 7 đoạn
    la s3, SEVEN_SEG_DECODE_TABLE

MAIN_LOOP:
    ################################################################
    #                     Đọc giá trị từ switch
    ################################################################
    # Đọc giá trị switch
    lw s4, 0(s1)               # s4 = giá trị từ SW
    
    ################################################################
    #                     Tách từng nhóm 4 bit
    ################################################################
    # Tách SW3:0 cho HEX0
    andi t0, s4, 0xF           # t0 = s4 & 0xF (4 bit thấp nhất)
    
    # Tách SW7:4 cho HEX1
    srli t1, s4, 4             # Dịch phải 4 bit
    andi t1, t1, 0xF           # t1 = (s4 >> 4) & 0xF (4 bit kế tiếp)
    
    # Tách SW11:8 cho HEX2
    srli t2, s4, 8             # Dịch phải 8 bit
    andi t2, t2, 0xF           # t2 = (s4 >> 8) & 0xF (4 bit tiếp theo)
    
    # Tách SW15:12 cho HEX3
    srli t3, s4, 12            # Dịch phải 12 bit
    andi t3, t3, 0xF           # t3 = (s4 >> 12) & 0xF (4 bit cao nhất)
    
    ################################################################
    #                     Giải mã và hiển thị
    ################################################################
    # Giải mã giá trị cho HEX0, HEX1, HEX2, HEX3
    mv a0, x0                  # Khởi tạo kết quả = 0
    
    # Giải mã HEX0 (SW3:0)
    add t4, s3, t0             # t4 = s3 + t0 (địa chỉ trong bảng mã)
    lb t4, 0(t4)               # t4 = giá trị 7 đoạn cho t0
    or a0, a0, t4              # a0 = a0 | t4 (đặt pattern HEX0)
    
    # Giải mã HEX1 (SW7:4)
    add t4, s3, t1             # t4 = s3 + t1 (địa chỉ trong bảng mã)
    lb t4, 0(t4)               # t4 = giá trị 7 đoạn cho t1
    slli t4, t4, 8             # t4 = t4 << 8 (dịch sang vị trí HEX1)
    or a0, a0, t4              # a0 = a0 | t4 (đặt pattern HEX1)
    
    # Giải mã HEX2 (SW11:8)
    add t4, s3, t2             # t4 = s3 + t2 (địa chỉ trong bảng mã)
    lb t4, 0(t4)               # t4 = giá trị 7 đoạn cho t2
    slli t4, t4, 16            # t4 = t4 << 16 (dịch sang vị trí HEX2)
    or a0, a0, t4              # a0 = a0 | t4 (đặt pattern HEX2)
    
    # Giải mã HEX3 (SW15:12)
    add t4, s3, t3             # t4 = s3 + t3 (địa chỉ trong bảng mã)
    lb t4, 0(t4)               # t4 = giá trị 7 đoạn cho t3
    slli t4, t4, 24            # t4 = t4 << 24 (dịch sang vị trí HEX3)
    or a0, a0, t4              # a0 = a0 | t4 (đặt pattern HEX3)
    
    # Hiển thị kết quả trên HEX3-HEX0
    sw a0, 0(s2)               # Ghi giá trị vào địa chỉ HEX3_HEX0
    
    # Vòng lặp liên tục để cập nhật hiển thị
    j MAIN_LOOP                # Quay lại vòng lặp chính

################################################################
#                         Bảng giải mã 7 đoạn
################################################################
.section .data
SEVEN_SEG_DECODE_TABLE:
    # Các mã hiển thị số 0-9 và A-F trên LED 7 đoạn
    # Bit 0 = a, 1 = b, 2 = c, 3 = d, 4 = e, 5 = f, 6 = g
    .byte 0b00111111          # 0 = 0x3F
    .byte 0b00000110          # 1 = 0x06
    .byte 0b01011011          # 2 = 0x5B
    .byte 0b01001111          # 3 = 0x4F
    .byte 0b01100110          # 4 = 0x66
    .byte 0b01101101          # 5 = 0x6D
    .byte 0b01111101          # 6 = 0x7D
    .byte 0b00000111          # 7 = 0x07
    .byte 0b01111111          # 8 = 0x7F
    .byte 0b01101111          # 9 = 0x6F
    .byte 0b01110111          # A = 0x77
    .byte 0b01111100          # b = 0x7C
    .byte 0b00111001          # C = 0x39
    .byte 0b01011110          # d = 0x5E
    .byte 0b01111001          # E = 0x79
    .byte 0b01110001          # F = 0x71

.end
