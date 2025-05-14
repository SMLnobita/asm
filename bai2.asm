.text
# Khai báo địa chỉ của các thiết bị ngoại vi
.equ KEY, 0xFF200050          # Địa chỉ của nút nhấn
.equ LEDS, 0xFF200000         # Địa chỉ của LED
.equ SWITCHES, 0xFF200040     # Địa chỉ của Switches

.global _start
_start:
    # Khởi tạo các thanh ghi
    la s0, KEY                # s0 = địa chỉ KEY
    la s1, LEDS               # s1 = địa chỉ LED
    la s2, SWITCHES           # s2 = địa chỉ Switches
    
    # Khởi tạo giá trị LED ban đầu (chỉ bật LED0)
    li s3, 1                  # s3 = 1 (trạng thái LED hiện tại, bật LED0)
    sw s3, 0(s1)              # Ghi giá trị s3 ra LED

MAIN_LOOP:
    # Kiểm tra nút nhấn
CHECK_KEY:
    lw a0, 0(s0)              # a0 = giá trị nút nhấn
    beq a0, zero, CHECK_KEY   # Nếu không có nút nào được nhấn, kiểm tra lại

    # Chờ nhả nút
WAIT_RELEASE:
    lw a1, 0(s0)              # a1 = giá trị nút nhấn
    bne a1, zero, WAIT_RELEASE # Nếu còn nút nhấn, tiếp tục chờ
    
    # Lưu giá trị nút nhấn
    mv a2, a0                 # a2 = a0 (giá trị nút nhấn)
    
    # Kiểm tra KEY1 (0x2) - Dịch trái LED17:0
    li a3, 2                  # a3 = 2 (mặt nạ cho KEY1)
    beq a2, a3, SHIFT_LEFT    # Nếu KEY1 được nhấn, dịch trái
    
    # Kiểm tra KEY2 (0x4) - Dịch phải LED9:0
    li a3, 4                  # a3 = 4 (mặt nạ cho KEY2)
    beq a2, a3, SHIFT_RIGHT   # Nếu KEY2 được nhấn, dịch phải
    
    # Kiểm tra KEY3 (0x8) - Lấy giá trị từ SW9:0
    li a3, 8                  # a3 = 8 (mặt nạ cho KEY3)
    beq a2, a3, LOAD_SWITCHES # Nếu KEY3 được nhấn, lấy giá trị switches
    
    j MAIN_LOOP               # Quay lại vòng lặp chính nếu không có phím nào khớp

SHIFT_LEFT:
    # Dịch trái LED17:0
    slli s3, s3, 1            # Dịch trái 1 bit
    
    # Kiểm tra nếu vượt quá LED17
    li a4, 0x20000            # a4 = 2^17 (bit thứ 18)
    blt s3, a4, WRITE_LEDS    # Nếu s3 < 2^17, không vượt quá LED17
    
    # Nếu vượt quá LED17, wrap around (reset về LED0)
    li s3, 1                  # s3 = 1 (bật LED0)
    j WRITE_LEDS              # Ghi ra LED

SHIFT_RIGHT:
    # Kiểm tra bit LSB (LED0)
    andi a5, s3, 1            # a5 = s3 & 1 (bit LSB)
    
    # Dịch phải toàn bộ LEDs
    srli s3, s3, 1            # Dịch phải 1 bit
    
    # Nếu LED0 = 1 trước khi dịch, đặt LED9 = 1 sau khi dịch
    beq a5, zero, WRITE_LEDS  # Nếu a5 = 0 (LED0 = 0), không cần làm gì
    
    # Đặt LED9 = 1 nếu LED0 = 1 trước khi dịch
    li a6, 0x200              # a6 = 2^9 (bit LED9)
    add s3, s3, a6            # Đặt bit LED9 = 1
    j WRITE_LEDS              # Ghi ra LED

LOAD_SWITCHES:
    # Đọc giá trị từ switches
    lw s3, 0(s2)              # s3 = giá trị switches
    li a7, 0x3FF              # a7 = 0x3FF (mặt nạ cho 10 bit thấp)
    and s3, s3, a7            # s3 = s3 & 0x3FF (giữ lại 10 bit thấp)
    # Không cần j WRITE_LEDS vì sẽ tiếp tục xuống WRITE_LEDS

WRITE_LEDS:
    # Ghi giá trị ra LED
    sw s3, 0(s1)              # Ghi giá trị s3 ra LED
    j MAIN_LOOP               # Quay lại vòng lặp chính

.end