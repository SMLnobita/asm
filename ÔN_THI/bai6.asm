# Đề 6: Phép nhân theo lưu đồ
# multiplicand x12 = SW[3:0], multiplier x13 = SW[7:4], product x11

.equ LEDS, 0xFF200000
.equ SWITCHS, 0xFF200040

.text
.globl _start

_start:
    li sp, 0x03FFFFFC                    # Khởi tạo stack

main_loop:
    li t0, SWITCHS
    lw t1, 0(t0)                         # Đọc switch
    andi a0, t1, 0xF                     # x12 = SW[3:0] (multiplicand)
    srli t1, t1, 4
    andi a1, t1, 0xF                     # x13 = SW[7:4] (multiplier)
    
    jal ra, nhan_theo_luu_do_v2          # Gọi hàm nhân theo lưu đồ version 2
    
    li t0, LEDS
    sw a0, 0(t0)                         # Xuất product ra LED
    
    j main_loop                          # Lặp lại liên tục

# Hàm nhân theo lưu đồ version 2 (theo hình trong đề 6)
# Thuật toán: Test Multiplier0, nếu = 1 thì add multiplicand vào left half của product
# Input: a0 = multiplicand, a1 = multiplier
# Output: a0 = product
nhan_theo_luu_do_v2:
    addi sp, sp, -20                     # Prologue
    sw s0, 16(sp)                        # s0 = multiplicand
    sw s1, 12(sp)                        # s1 = multiplier
    sw s2, 8(sp)                         # s2 = product (64-bit, chỉ dùng 32-bit thấp)
    sw s3, 4(sp)                         # s3 = product high (left half)
    sw ra, 0(sp)
    
    mv s0, a0                            # multiplicand
    mv s1, a1                            # multiplier
    li s2, 0                             # product low = 0
    li s3, 0                             # product high = 0
    li t0, 32                            # counter = 32 repetitions
    
nhan_v2_loop:
    # 1. Test Multiplier0
    andi t1, s1, 1                       # Kiểm tra bit LSB của multiplier
    bne t1, zero, nhan_v2_add            # Nếu bit = 1 thì add
    j nhan_v2_shift                      # Nếu bit = 0 thì skip add
    
nhan_v2_add:
    # 1a. Add multiplicand to the left half of product
    add s3, s3, s0                       # product_high += multiplicand
    
nhan_v2_shift:
    # 2. Shift the Product register right 1 bit
    andi t2, s3, 1                       # Lấy bit LSB của product_high
    srli s3, s3, 1                       # Shift right product_high
    slli t2, t2, 31                      # Đưa bit LSB lên MSB
    srli s2, s2, 1                       # Shift right product_low
    or s2, s2, t2                        # Nối bit từ product_high xuống
    
    # 3. Shift the Multiplier register right 1 bit
    srli s1, s1, 1                       # Shift right multiplier
    
    addi t0, t0, -1                      # Giảm counter
    bne t0, zero, nhan_v2_loop           # Lặp 32 lần
    
nhan_v2_end:
    mv a0, s2                            # Trả về product (phần thấp)
    
    lw ra, 0(sp)                         # Epilogue
    lw s3, 4(sp)
    lw s2, 8(sp)
    lw s1, 12(sp)
    lw s0, 16(sp)
    addi sp, sp, 20
    
    ret