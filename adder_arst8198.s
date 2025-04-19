.equ JTAG_UART_BASE, 0xFF201000
.equ SEVEN_SEG_BASE, 0xFF200020
.equ BUFFER_SIZE, 16

.section .data
input_buffer:
    .space BUFFER_SIZE
prompt:
    .asciz "Enter number: "

.section .text
.global _start

_start:
    movia sp, 0x10000000
    movi r16, 0

main_loop:
    movia r4, prompt
    call print_string_jtag
    
    movia r4, input_buffer
    movi r5, BUFFER_SIZE
    call get_line_jtag
    
    movia r4, input_buffer
    call atoi
    
    add r16, r16, r2
    
    movi r4, 10000
    bgeu r16, r4, overflow
    br display_sum
    
overflow:
    movi r16, 0
    
display_sum:
    mov r4, r16
    call display_on_seven_seg
    
    br main_loop

atoi:
    subi sp, sp, 16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    
    mov r16, r4
    movi r2, 0
    
atoi_loop:
    ldb r17, 0(r16)
    beq r17, r0, atoi_done
    
    movi r18, '0'
    blt r17, r18, atoi_done
    movi r18, '9'
    bgt r17, r18, atoi_done
    
    muli r2, r2, 10
    
    subi r17, r17, '0'
    add r2, r2, r17
    
    addi r16, r16, 1
    br atoi_loop
    
atoi_done:
    ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16
    ret

display_on_seven_seg:
    subi sp, sp, 16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    
    movia r16, SEVEN_SEG_BASE
    mov r17, r4
    
    movi r18, 0
    
    movi r4, 10
    div r5, r17, r4
    mul r4, r5, r4
    sub r4, r17, r4
    call digit_to_7seg
    or r18, r18, r2
    
    mov r17, r5
    movi r4, 10
    div r5, r17, r4
    mul r4, r5, r4
    sub r4, r17, r4
    call digit_to_7seg
    slli r2, r2, 8
    or r18, r18, r2
    
    mov r17, r5
    movi r4, 10
    div r5, r17, r4
    mul r4, r5, r4
    sub r4, r17, r4
    call digit_to_7seg
    slli r2, r2, 16
    or r18, r18, r2
    
    mov r4, r5
    call digit_to_7seg
    slli r2, r2, 24
    or r18, r18, r2
    
    stw r18, 0(r16)
    
    ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16
    ret

digit_to_7seg:
    movi r2, 0
    
    movi r5, 0
    beq r4, r5, digit_0
    movi r5, 1
    beq r4, r5, digit_1
    movi r5, 2
    beq r4, r5, digit_2
    movi r5, 3
    beq r4, r5, digit_3
    movi r5, 4
    beq r4, r5, digit_4
    movi r5, 5
    beq r4, r5, digit_5
    movi r5, 6
    beq r4, r5, digit_6
    movi r5, 7
    beq r4, r5, digit_7
    movi r5, 8
    beq r4, r5, digit_8
    movi r5, 9
    beq r4, r5, digit_9
    ret
    
digit_0:
    movi r2, 0x3F
    ret
digit_1:
    movi r2, 0x06
    ret
digit_2:
    movi r2, 0x5B
    ret
digit_3:
    movi r2, 0x4F
    ret
digit_4:
    movi r2, 0x66
    ret
digit_5:
    movi r2, 0x6D
    ret
digit_6:
    movi r2, 0x7D
    ret
digit_7:
    movi r2, 0x07
    ret
digit_8:
    movi r2, 0x7F
    ret
digit_9:
    movi r2, 0x6F
    ret

get_line_jtag:
    subi sp, sp, 20
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    stw r19, 16(sp)
    
    mov r16, r4
    mov r17, r5
    movi r18, 0
    
get_char_loop:
    beq r18, r17, get_line_done
    
    call get_char_jtag
    
    movi r19, '\r'
    beq r2, r19, get_line_done
    movi r19, '\n'
    beq r2, r19, get_line_done
    
    stb r2, 0(r16)
    
    mov r4, r2
    call put_char_jtag
    
    addi r16, r16, 1
    addi r18, r18, 1
    br get_char_loop
    
get_line_done:
    stb r0, 0(r16)
    
    movi r4, '\r'
    call put_char_jtag
    movi r4, '\n'
    call put_char_jtag
    
    ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    ldw r19, 16(sp)
    addi sp, sp, 20
    ret

get_char_jtag:
    movia r8, JTAG_UART_BASE
    
get_char_wait:
    ldwio r9, 0(r8)
    andi r10, r9, 0x8000
    beq r10, r0, get_char_wait
    
    andi r2, r9, 0xFF
    ret

put_char_jtag:
    movia r8, JTAG_UART_BASE
    
put_char_wait:
    ldwio r9, 4(r8)
    andhi r9, r9, 0xFFFF
    beq r9, r0, put_char_wait
    
    stwio r4, 0(r8)
    ret

print_string_jtag:
    subi sp, sp, 8
    stw ra, 0(sp)
    stw r16, 4(sp)
    
    mov r16, r4
    
print_loop:
    ldb r4, 0(r16)
    beq r4, r0, print_done
    
    call put_char_jtag
    
    addi r16, r16, 1
    br print_loop
    
print_done:
    ldw ra, 0(sp)
    ldw r16, 4(sp)
    addi sp, sp, 8
    ret
