# Đề 1: Tính x10 = 1 + 3 + 5 + ... + (2*N + 1)

.equ LEDS, 0xFF200000
.equ SWITCHS, 0xFF200040

.text
.globl _start

_start:
    li sp, 0x03FFFFFC                    # Khởi tạo stack

main_loop:
    li t0, SWITCHS
    lw t1, 0(t0)                         # Đọc switch
    srli t1, t1, 2                       # Lấy SW[5:2]
    andi a0, t1, 0xF                     # Mask 4-bit N
    
    jal ra, tinh_tong_le                 # Gọi hàm tính tổng
    
    li t0, LEDS
    sw a0, 0(t0)                         # Xuất kết quả ra LED
    
    j main_loop                          # Lặp lại liên tục

# Hàm tính tổng dãy số lẻ: 1 + 3 + 5 + ... + (2*N + 1)
tinh_tong_le:
    addi sp, sp, -16                     # Prologue
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw ra, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0                            # s0 = N
    li s1, 0                             # s1 = tổng
    li s2, 1                             # s2 = số lẻ hiện tại
    
    blt s0, zero, tinh_tong_le_end
    
tinh_tong_le_loop:
    add s1, s1, s2                       # sum += current_odd
    addi s2, s2, 2                       # next odd number
    addi s0, s0, -1                      # N--
    bge s0, zero, tinh_tong_le_loop
    
tinh_tong_le_end:
    mv a0, s1                            # Trả về kết quả
    
    lw s2, 0(sp)                         # Epilogue
    lw ra, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    
    ret                                  # Trả về caller