# BÁO CÁO THỰC HÀNH: GIAO TIẾP VỚI THIẾT BỊ NGOẠI VI

## 1. MỤC TIÊU

Thực hành giúp sinh viên hiểu và thiết kế các chương trình Assembly giao tiếp giữa CPU RISC-V và các thành phần ngoại vi trên bo mạch DE1-SoC, bao gồm:
- Các LED 7 đoạn (HEX0 – HEX7)
- Các nút nhấn (Push Button)
- Các công tắc (Switches)

## 2. LÝ THUYẾT

### 2.1. Địa chỉ các thiết bị ngoại vi

| Tên thành phần | Địa chỉ |
|----------------|---------|
| LEDs | 0xFF200000 |
| Switches | 0xFF200040 |
| Push buttons | 0xFF200050 |
| Seven-segment displays (HEX3 -> HEX0) | 0xFF200020 |
| Seven-segment displays (HEX5 -> HEX4) | 0xFF200030 |

### 2.2. Bảng mã cho LED 7 đoạn

| Thập phân | Mã LED ở dạng nhị phân | Mã LED ở dạng thập lục phân |
|-----------|-------------------------|----------------------------|
| 0 | 0b011 1111 | 0x3F |
| 1 | 0b000 0110 | 0x06 |
| 2 | 0b101 1011 | 0x5B |
| 3 | 0b100 1111 | 0x4F |
| 4 | 0b110 0110 | 0x66 |
| 5 | 0b110 1101 | 0x6D |
| 6 | 0b111 1101 | 0x7D |
| 7 | 0b000 0111 | 0x07 |
| 8 | 0b111 1111 | 0x7F |
| 9 | 0b110 0111 | 0x67 |
| A | 0b111 0111 | 0x77 |
| B | 0b111 1100 | 0x7C |
| C | 0b011 1001 | 0x39 |
| D | 0b101 1110 | 0x5E |
| E | 0b111 1001 | 0x79 |
| F | 0b111 0001 | 0x71 |

## 3. BÀI TẬP THỰC HÀNH

### 3.1. Bài 1: Đếm lên/xuống và hiển thị trên 7 đoạn

#### Mô tả:
Viết chương trình Assembly thực hiện chức năng:
- Khi nhấn KEY1: đếm lên
- Khi nhấn KEY2: đếm xuống
- Xuất giá trị đếm từ 0 đến 32 ra hai LED 7 đoạn HEX1 và HEX0

#### Code:
```assembly
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
```

#### Giải thích:
1. **Khởi tạo**:
   - Khởi tạo các thanh ghi và biến đếm ban đầu = 0

2. **Xử lý nút nhấn**:
   - Chờ đến khi phát hiện nút được nhấn (`CHECK_KEY`)
   - Chờ đến khi nút được thả ra để tránh đếm nhiều lần (`WAIT`)
   - Kiểm tra nút nào được nhấn (`KEY_DECODE`): 
     - KEY1: tăng biến đếm
     - KEY2: giảm biến đếm

3. **Kiểm tra giới hạn**:
   - Nếu biến đếm > 32: reset về 0
   - Nếu biến đếm < 0: reset về 32

4. **Chuyển đổi thành chục và đơn vị**:
   - Dùng phép chia thủ công (vòng lặp DIV_LOOP) để tính hàng chục và đơn vị

5. **Hiển thị trên LED 7 đoạn**:
   - Tìm mã 7 đoạn tương ứng cho hàng chục và đơn vị qua hàm `GET_PATTERN`
   - Ghi các mã này vào vùng nhớ tạm `HEX_SEGMENTS`
   - Ghi word từ `HEX_SEGMENTS` ra địa chỉ của LED 7 đoạn

### 3.2. Bài 2: Dịch LED và đọc giá trị từ switches

#### Mô tả:
Viết chương trình Assembly thực hiện chức năng:
- Khi nhấn KEY1: LED17:0 dịch sang trái
- Khi nhấn KEY2: LED9:0 dịch sang phải
- Khi nhấn KEY3: Lấy giá trị từ SW9:0 đưa lên LED17:0

#### Code:
```assembly
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
```

#### Giải thích:
1. **Khởi tạo**:
   - Khai báo địa chỉ của các thiết bị ngoại vi: KEY, LEDS, SWITCHES
   - Khởi tạo giá trị LED ban đầu (bật LED0)

2. **Kiểm tra nút nhấn**:
   - Chờ cho đến khi có nút được nhấn (`CHECK_KEY`)
   - Chờ cho đến khi nút được thả ra (`WAIT_RELEASE`)
   - Kiểm tra nút nào được nhấn:
     - KEY1: Dịch trái LED17:0
     - KEY2: Dịch phải LED9:0
     - KEY3: Lấy giá trị từ SW9:0

3. **Dịch trái LED17:0**:
   - Dịch trái LED hiện tại 1 bit
   - Nếu vượt quá LED17, reset về LED0

4. **Dịch phải LED9:0**:
   - Lưu trạng thái của LED0 trước khi dịch
   - Dịch phải toàn bộ LED 1 bit
   - Nếu LED0 = 1 trước khi dịch, đặt LED9 = 1 sau khi dịch (wrap-around)

5. **Lấy giá trị từ switches**:
   - Đọc giá trị từ switches
   - Giữ lại 10 bit thấp (SW9:0)
   - Ghi giá trị này ra LED

### 3.3. Bài 3: Giải mã từ switches ra LED 7 đoạn

#### Mô tả:
Viết code assembly thực hiện chức năng giải mã:
- SW3:0 ra LED 7 đoạn HEX0
- SW7:4 ra LED 7 đoạn HEX1
- SW11:8 ra LED 7 đoạn HEX2
- SW15:12 ra LED 7 đoạn HEX3

#### Code:
```assembly
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
```

#### Giải thích:
1. **Khởi tạo**:
   - Khai báo địa chỉ của các thiết bị ngoại vi: SWITCHES và HEX3_HEX0
   - Khởi tạo thanh ghi s2 trỏ đến bảng mã SEVEN_SEG_DECODE_TABLE

2. **Vòng lặp chính**:
   - Đọc giá trị từ Switches và lưu vào s4
   - Khởi tạo biến kết quả s5 = 0 (để lưu mã 7 đoạn cho cả 4 LED)

3. **Xử lý từng nhóm 4 bit Switches**:
   - **Cho SW3:0 (HEX0)**:
     - Lấy 4 bit thấp của s4 bằng phép AND với 0xF
     - Tra bảng SEVEN_SEG_DECODE_TABLE để tìm mã hiển thị
     - Lưu mã này vào s5 (vị trí thấp nhất, tương ứng với HEX0)
   
   - **Cho SW7:4 (HEX1)**:
     - Dịch phải s4 4 bit, sau đó lấy 4 bit thấp
     - Tra bảng để tìm mã hiển thị
     - Dịch trái mã này 8 bit (vị trí HEX1) và kết hợp vào s5
   
   - **Cho SW11:8 (HEX2)**:
     - Dịch phải s4 8 bit, sau đó lấy 4 bit thấp
     - Tra bảng để tìm mã hiển thị
     - Dịch trái mã này 16 bit (vị trí HEX2) và kết hợp vào s5