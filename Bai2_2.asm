.section .text
.equ KEY, 0xFF200050          # Địa chỉ của nút nhấn KEY
.equ LEDR, 0xFF200000         # Địa chỉ của LED đỏ (LED17:0)
.equ SW, 0xFF200040           # Địa chỉ của switch (SW9:0)

.global _start
_start:
    ################################################################
    #                     Khởi tạo thanh ghi
    ################################################################
    # s1 = địa chỉ KEY
    la s1, KEY
    
    # s2 = địa chỉ LEDR
    la s2, LEDR
    
    # s3 = địa chỉ SW
    la s3, SW
    
    # s4 = giá trị hiện tại của LED, khởi tạo là 1
    li s4, 1                  # Bắt đầu với bit thấp nhất được bật (0...001)
    
    # Lưu giá trị ban đầu vào LED
    sw s4, 0(s2)

LOOP:
    ################################################################
    #                     Đặt các hằng số tạm
    ################################################################
    li t1, 2                  # t1 = 0x2 (bitmask cho KEY1, 0b10)
    li t2, 4                  # t2 = 0x4 (bitmask cho KEY2, 0b100)
    li t3, 8                  # t3 = 0x8 (bitmask cho KEY3, 0b1000)
    li t4, 0x3FFFF            # t4 = bitmask cho LED17:0 (18 bit)
    li t5, 0x3FF              # t5 = bitmask cho LED9:0 (10 bit)

CHECK_KEY:
    ################################################################
    #           Chờ nhấn phím: đọc halfword từ địa chỉ KEY
    ################################################################
    lh t6, 0(s1)              # t6 = giá trị của KEY
    beq t6, x0, CHECK_KEY     # nếu t6 == 0 thì nhảy tới CHECK_KEY

WAIT:
    # Chờ nhả phím
    lh a7, 0(s1)              # a7 = giá trị của KEY
    bne a7, x0, WAIT          # nếu a7 != 0 thì nhảy tới WAIT

KEY_DECODE:
    ################################################################
    #     Kiểm tra từng bit KEY và thực hiện chức năng tương ứng
    ################################################################
    # Kiểm tra KEY1 - Dịch trái LED17:0
    and a0, t6, t1
    beq a0, t1, SHIFT_LEFT
    
    # Kiểm tra KEY2 - Dịch phải LED9:0
    and a0, t6, t2
    beq a0, t2, SHIFT_RIGHT
    
    # Kiểm tra KEY3 - Đọc giá trị SW9:0 vào LED17:0
    and a0, t6, t3
    beq a0, t3, READ_SWITCH
    
    j DISPLAY_LED             # Nếu không nhấn phím nào, hiển thị LED hiện tại

SHIFT_LEFT:
    ################################################################
    #     Dịch trái LED17:0 (nhân 2) và đảm bảo nằm trong 18 bit
    ################################################################
    slli s4, s4, 1            # Dịch trái 1 bit (nhân 2)
    and s4, s4, t4            # Giữ chỉ 18 bit thấp nhất (LED17:0)
    
    # Nếu tất cả LED đều tắt sau khi dịch, đặt lại bit thấp nhất
    bne s4, x0, DISPLAY_LED   # Nếu s4 != 0, hiển thị LED hiện tại
    li s4, 1                  # Nếu s4 == 0, đặt lại bit thấp nhất (0...001)
    j DISPLAY_LED

SHIFT_RIGHT:
    ################################################################
    #     Dịch phải LED9:0 (chia 2) và đảm bảo nằm trong 10 bit
    ################################################################
    # Tách phần LED9:0 (10 bit thấp)
    and a0, s4, t5            # a0 = s4 & 0x3FF (10 bit thấp)
    
    # Dịch phải phần LED9:0
    srli a0, a0, 1            # Dịch phải 1 bit (chia 2)
    
    # Xóa 10 bit thấp của s4 và giữ phần LED17:10
    li a1, 0xFFFFFC00         # a1 = ~0x3FF (bitmask để giữ bit 10-31)
    and s4, s4, a1            # s4 = s4 & ~0x3FF (xóa 10 bit thấp)
    
    # Kết hợp phần LED17:10 với phần LED9:0 đã dịch
    or s4, s4, a0             # s4 = s4 | a0 (kết hợp)
    
    # Nếu 10 bit thấp đều bằng 0, đặt bit cao nhất của phần 10 bit
    and a0, s4, t5            # Kiểm tra 10 bit thấp
    bne a0, x0, DISPLAY_LED   # Nếu có bit nào bật, hiển thị LED hiện tại
    ori s4, s4, 0x200         # Nếu tất cả bit thấp tắt, bật bit thứ 9 (0x200)
    j DISPLAY_LED

READ_SWITCH:
    ################################################################
    #     Đọc giá trị từ SW9:0 đưa lên LED17:0
    ################################################################
    lw a0, 0(s3)              # Đọc giá trị từ SW
    and s4, a0, t5            # Chỉ lấy 10 bit thấp (SW9:0)
    j DISPLAY_LED

DISPLAY_LED:
    ################################################################
    #     Hiển thị giá trị trên LED
    ################################################################
    sw s4, 0(s2)              # Ghi giá trị s4 vào địa chỉ LED
    j LOOP                    # Quay lại vòng lặp chính

.end
