# Đề 3: Tính UCLN của N và M
# N từ SW[3:0], M từ SW[7:4]

.equ LEDS, 0xFF200000
.equ SWITCHS, 0xFF200040

.text
.globl _start

_start:
    li sp, 0x03FFFFFC                    # Khởi tạo stack

main_loop:
    li t0, SWITCHS
    lw t1, 0(t0)                         # Đọc switch
    andi a0, t1, 0xF                     # N = SW[3:0]
    srli t1, t1, 4
    andi a1, t1, 0xF                     # M = SW[7:4]
    
    jal ra, tinh_ucln                    # Gọi hàm tính UCLN
    
    li t0, LEDS
    sw a0, 0(t0)                         # Xuất kết quả ra LED
    
    j main_loop                          # Lặp lại liên tục

# Hàm tính UCLN (thuật toán Euclid)
# Input: a0 = N, a1 = M
# Output: a0 = UCLN(N, M)
tinh_ucln:
    addi sp, sp, -12                     # Prologue
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)
    
    mv s0, a0                            # s0 = N
    mv s1, a1                            # s1 = M
    
    # Xử lý trường hợp đặc biệt
    bne s0, zero, check_m                # Nếu N != 0 thì kiểm tra M
    mv s0, s1                            # Nếu N = 0 thì UCLN = M
    j ucln_end
    
check_m:
    bne s1, zero, ucln_loop              # Nếu M != 0 thì bắt đầu thuật toán
    j ucln_end                           # Nếu M = 0 thì UCLN = N
    
ucln_loop:
    beq s0, s1, ucln_end                 # Nếu N = M thì kết thúc
    blt s0, s1, ucln_swap                # Nếu N < M thì swap
    
    sub s0, s0, s1                       # N = N - M
    j ucln_loop
    
ucln_swap:
    sub s1, s1, s0                       # M = M - N
    j ucln_loop
    
ucln_end:
    mv a0, s0                            # Trả về UCLN
    
    lw ra, 0(sp)                         # Epilogue
    lw s1, 4(sp)
    lw s0, 8(sp)
    addi sp, sp, 12
    
    ret