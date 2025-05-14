.section .text
.equ KEY, 0xFF200050
.equ HEX3_HEX0, 0xFF200020

.global _start
_start:
    ################################################################
    #                     Khởi tạo thanh ghi
    ################################################################
    # s1 = KEY (địa chỉ cổng I/O cho nút nhấn)
    la s1, KEY
    
    # s2 = địa chỉ nhãn SEVEN_SEG_DECODE_TABLE 
    la s2, SEVEN_SEG_DECODE_TABLE
    # s3 = 0
    mv s3, x0
LOOP:
    ################################################################
    #                     Đặt các hằng số tạm
    ################################################################
    mv t0, x0     # t0 = zero
    li t1, 2      # t1 = 0x2 (bitmask cho KEY1)
    li t3, 4      # t3 = 0x4 (bitmask cho KEY2)
    li t4, 32     # t4 = 32 (giá trị tối đa)
    li t5, 10     # t5 = 10 (để chia lấy hàng chục)

    # s6 = địa chỉ nhãn HEX_SEGMENTS
    la s6, HEX_SEGMENTS

CHECK_KEY:
    ################################################################
    #           Chờ nhấn phím: đọc halfword từ địa chỉ KEY
    ################################################################
    lh t6, 0(s1)                # t6 = giá trị của KEY
    beq t6, x0, CHECK_KEY       # nếu t6 == 0 thì nhảy tới nhãn CHECK_KEY
WAIT:
    # Chờ nhả phím
    lh a7, 0(s1)                # a7 = giá trị của KEY (thay thế t7)
    bne a7, x0, WAIT            # nếu a7 != 0 thì nhảy tới nhãn WAIT

    andi t6, t6, 0x6            # Lọc chỉ bit 1 và 2 (KEY1 và KEY2)

KEY_DECODE:
    ################################################################
    #     Kiểm tra từng bit (KEY1, KEY2) và tăng/giảm biến đếm
    ################################################################
    # Kiểm tra KEY1
    and a0, t6, t1
    beq a0, t1, CONG            # Nếu nhấn KEY1 → tăng
    # Kiểm tra KEY2
    and a0, t6, t3
    beq a0, t3, TRU             # Nếu nhấn KEY2 → giảm
    j CHECK_KQ
CONG:
    addi s3, s3, 1
    j CHECK_KQ
TRU:
    addi s3, s3, -1
CHECK_KQ:
    bgt s3, t4, RESET_TO_ZERO
    blt s3, x0, RESET_TO_MAX
    j CONVERT_TO_DECIMAL
RESET_TO_ZERO:
    li s3, 0
    j CONVERT_TO_DECIMAL
RESET_TO_MAX:
    li s3, 32
    j CONVERT_TO_DECIMAL
CONVERT_TO_DECIMAL:
    mv t6, s3                   # t6 = s3 (sao chép biến đếm)
    li a7, 0                    # a7 = 0 (hàng chục) (thay thế t7)
DIV_LOOP:
    blt t6, t5, DIV_DONE        # Nếu t6 < 10, kết thúc vòng lặp
    sub t6, t6, t5              # t6 = t6 - 10 (không phải t4)
    addi a7, a7, 1              # a7 = a7 + 1 (tăng hàng chục) (thay thế t7)
    j DIV_LOOP                  # Lặp lại
DIV_DONE:
SEVEN_SEG_DECODER:
    # Xử lý hàng đơn vị
    mv a0, t6                   # a0 = t6 (hàng đơn vị)
    jal GET_PATTERN             # Gọi hàm lấy pattern
    mv a2, a0                   # a2 = pattern cho hàng đơn vị
    sb a2, 0(s6)                # Lưu byte vào vị trí đầu tiên của HEX_SEGMENTS
    
    # Xử lý hàng chục
    mv a0, a7                   # a0 = a7 (hàng chục) (thay thế t7)
    jal GET_PATTERN             # Gọi hàm lấy pattern
    mv a2, a0                   # a2 = pattern cho hàng chục
    sb a2, 1(s6)                # Lưu byte vào vị trí thứ hai của HEX_SEGMENTS
    
    lw a2, 0(s6)                # Đọc 1 word từ HEX_SEGMENTS
    la a3, HEX3_HEX0            # a3 = địa chỉ HEX3_HEX0
    sw a2, 0(a3)                # Lưu word vào địa chỉ HEX3_HEX0
    j LOOP                      # Quay lại vòng lặp LOOP

GET_PATTERN:
    # a0 = chỉ số (0-9)
    la t0, SEVEN_SEG_DECODE_TABLE # t0 = địa chỉ bảng
    add t0, t0, a0              # t0 = t0 + a0 (địa chỉ của pattern)
    lb a0, 0(t0)                # a0 = pattern tại địa chỉ t0
    jr ra                       # Trở về (không phải j LOOP)

################################################################
#                         Vùng dữ liệu
################################################################
.section .data
.skip 3
N:
    .byte 16

SEVEN_SEG_DECODE_TABLE:
    .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111
    .byte 0b01100110, 0b01101101, 0b01111101, 0b00000111
    .byte 0b01111111, 0b01100111, 0b00000000, 0b00000000
    .byte 0b00000000, 0b00000000, 0b00000000, 0b00000000

# cấp phát 1 word (4 byte) giá trị 0
HEX_SEGMENTS:
    .word 0

.end
