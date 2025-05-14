.text 
#khai báo địa chỉ của Button (KEY) và led 7 đoạn
.equ KEY, 0xFF200050
.equ HEX3_HEX0, 0xFF200020
.global _start

_start:
    # Khởi tạo các thanh ghi
    la s1, KEY                    # s1 = địa chỉ KEY
    la s2, SEVEN_SEG_DECODE_TABLE # s2 = địa chỉ bảng mã 7 đoạn
    li s3, 0                      # s3 = 0 (biến đếm, bắt đầu từ 0)
    la s4, HEX_SEGMENTS           # s4 = địa chỉ HEX_SEGMENTS

Loop:
    # đặt các hằng số tạm
    li t1, 2                      # t1 = 2 (bitmask cho KEY1, 0b10)
    li t2, 4                      # t2 = 4 (bitmask cho KEY2, 0b100)
    li t3, 32                     # t3 = 32 (giá trị tối đa)
    li t4, 10                     # t4 = 10 (để tính toán hàng chục)

    # Kiểm tra có key được nhấn hay không
CHECK_KEY:
    lh t5, 0(s1)                  # t5 = giá trị tại địa chỉ KEY
    beq t5, zero, CHECK_KEY       # Nếu t5 == 0 thì nhảy tới CHECK_KEY

    # Chờ tới khi thả Key ra
WAIT:
    lh t6, 0(s1)                  # t6 = giá trị tại địa chỉ KEY
    bne t6, zero, WAIT            # Nếu t6 != 0 thì nhảy tới WAIT

    #Kiểm tra KEY nào được nhấn và thực hiện tăng hoặc giảm biến đếm tương ứng
KEY_DECODE:
    # Kiểm tra KEY1 (tăng giá trị)
    and a0, t5, t1                # a0 = t5 & t1 (kiểm tra KEY1)
    beq a0, t1, INCREMENT         # Nếu KEY1 được nhấn, nhảy tới INCREMENT
    # Kiểm tra KEY2 (giảm giá trị)
    and a0, t5, t2                # a0 = t5 & t2 (kiểm tra KEY2)
    beq a0, t2, DECREMENT         # Nếu KEY2 được nhấn, nhảy tới DECREMENT
    j CHECK_LIMITS                # Nhảy tới kiểm tra giới hạn

INCREMENT:
    addi s3, s3, 1                # s3 = s3 + 1 (tăng biến đếm)
    j CHECK_LIMITS                # Nhảy tới kiểm tra giới hạn

DECREMENT:
    addi s3, s3, -1               # s3 = s3 - 1 (giảm biến đếm)

    # Kiểm tra biến đếm >32 thì reset về 0 và < 0 thì reset về 32
CHECK_LIMITS:
    # Kiểm tra nếu s3 > 32 thì reset về 0
    bgt s3, t3, RESET_TO_ZERO     # Nếu s3 > 32, nhảy tới RESET_TO_ZERO
    # Kiểm tra nếu s3 < 0 thì reset về 32
    blt s3, zero, RESET_TO_MAX    # Nếu s3 < 0, nhảy tới RESET_TO_MAX
    j CONVERT_TO_DECIMAL          # Nhảy tới chuyển đổi thành chục và đơn vị

RESET_TO_ZERO:
    li s3, 0                      # s3 = 0
    j CONVERT_TO_DECIMAL          # Nhảy tới chuyển đổi thành chục và đơn vị

RESET_TO_MAX:
    li s3, 32                     # s3 = 32
    j CONVERT_TO_DECIMAL          # Nhảy tới chuyển đổi thành chục và đơn vị

    # Giải mã biến đếm thành hàng chục và hàng đơn vị
CONVERT_TO_DECIMAL:
    mv t5, s3                     # t5 = s3 (sao chép biến đếm)
    # Tính hàng chục bằng phép chia thủ công
    li t6, 0                      # t6 = 0 (hàng chục)
DIV_LOOP:
    blt t5, t4, DIV_DONE          # Nếu t5 < 10, kết thúc vòng lặp
    sub t5, t5, t4                # t5 = t5 - 10
    addi t6, t6, 1                # t6 = t6 + 1 (tăng hàng chục)
    j DIV_LOOP                    # Lặp lại
DIV_DONE:
    # Bây giờ t6 = hàng chục, t5 = hàng đơn vị

    # Dùng giá trị chục và đơn vị tra bảng SEVEN_SEG_DECODE_TABLE
SEVEN_SEG_DECODER:
    # Xử lý hàng đơn vị
    mv a0, t5                     # a0 = t5 (hàng đơn vị)
    jal GET_PATTERN               # Gọi hàm lấy pattern
    mv a2, a0                     # a2 = pattern cho hàng đơn vị
    sb a2, 0(s4)                  # Lưu byte vào vị trí đầu tiên của HEX_SEGMENTS

    # Xử lý hàng chục
    mv a0, t6                     # a0 = t6 (hàng chục)
    jal GET_PATTERN               # Gọi hàm lấy pattern
    mv a2, a0                     # a2 = pattern cho hàng chục
    sb a2, 1(s4)                  # Lưu byte vào vị trí thứ hai của HEX_SEGMENTS

    # Đọc 1 word từ địa chỉ HEX_SEGMENTS và store word (sw) vào địa chỉ của Led 7 đoạn
    lw a2, 0(s4)                  # Đọc 1 word từ HEX_SEGMENTS
    la a3, HEX3_HEX0              # a3 = địa chỉ HEX3_HEX0
    sw a2, 0(a3)                  # Lưu word vào địa chỉ HEX3_HEX0

    # Quay lại nhãn loop
    j Loop

    # Hàm con để lấy pattern từ bảng SEVEN_SEG_DECODE_TABLE
GET_PATTERN:
    # a0 = chỉ số (0-9)
    la t0, SEVEN_SEG_DECODE_TABLE # t0 = địa chỉ bảng
    add t0, t0, a0                # t0 = t0 + a0 (địa chỉ của pattern)
    lb a0, 0(t0)                  # a0 = pattern tại địa chỉ t0
    jr ra                         # Trở về

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