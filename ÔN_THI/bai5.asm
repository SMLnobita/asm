# Đề 5: Phép nhân theo lưu đồ
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
    
    jal ra, nhan_theo_luu_do             # Gọi hàm nhân theo lưu đồ
    
    li t0, LEDS
    sw a0, 0(t0)                         # Xuất product ra LED
    
    j main_loop                          # Lặp lại liên tục

# Hàm nhân theo lưu đồ (Second Multiply Algorithm từ hình)
# Input: a0 = multiplicand, a1 = multiplier
# Output: a0 = product
nhan_theo_luu_do:
    addi sp, sp, -16                     # Prologue
    sw s0, 12(sp)                        # s0 = multiplicand
    sw s1, 8(sp)                         # s1 = multiplier
    sw s2, 4(sp)                         # s2 = product
    sw ra, 0(sp)
    
    mv s0, a0                            # multiplicand
    mv s1, a1                            # multiplier
    li s2, 0                             # product = 0
    li t0, 32                            # counter = 32 repetitions
    
nhan_luu_do_loop:
    andi t1, s1, 1                       # Test bit LSB của multiplier
    bne t1, zero, nhan_luu_do_add        # Nếu bit = 1 thì add
    j nhan_luu_do_shift                  # Nếu bit = 0 thì skip add
    
nhan_luu_do_add:
    add s2, s2, s0                       # 1a: product = product + multiplicand
    
nhan_luu_do_shift:
    slli s0, s0, 1                       # 2: Shift left multiplicand 1 bit
    srli s1, s1, 1                       # 3: Shift right multiplier 1 bit
    
    addi t0, t0, -1                      # Giảm counter
    bne t0, zero, nhan_luu_do_loop       # Lặp 32 lần
    
nhan_luu_do_end:
    mv a0, s2                            # Trả về product
    
    lw ra, 0(sp)                         # Epilogue
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    
    ret