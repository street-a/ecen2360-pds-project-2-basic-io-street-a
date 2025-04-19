.equ SEVEN_SEG_BASE, 0xFF200020
.equ BUTTONS_BASE, 0xFF200050
.equ DELAY_MS, 10

.section .text
.global _start

_start:
    movia sp, 0x10000000
    
    movi r16, 0
    movi r17, 0
    movi r18, 0
    
    movi r19, 0
    movi r20, 0
    
    movi r21, 0
    movi r22, 0
    
    call display_time

main_loop:
    movia r8, BUTTONS_BASE
    ldwio r23, 0(r8)
    
    andi r24, r23, 0x1
    andi r25, r23, 0x2
    srli r25, r25, 1
    
    movi r2, 1
    beq r21, r2, check_b0_release
    br check_b1
    
check_b0_release:
    bne r24, r0, check_b1
    
    xori r19, r19, 1
    movi r20, 0
    
check_b1:
    movi r2, 1
    beq r22, r2, check_b1_release
    br state_update
    
check_b1_release:
    bne r25, r0, state_update
    
    beq r19, r0, reset_time
    xori r20, r20, 1
    br state_update
    
reset_time:
    movi r16, 0
    movi r17, 0
    movi r18, 0
    call display_time
    br state_update
    
state_update:
    mov r21, r24
    mov r22, r25
    
    beq r19, r0, delay
    
    addi r18, r18, 1
    movi r2, 100
    blt r18, r2, check_display
    
    movi r18, 0
    addi r17, r17, 1
    movi r2, 60
    blt r17, r2, check_display
    
    movi r17, 0
    addi r16, r16, 1
    movi r2, 100
    blt r16, r2, check_display
    
    movi r16, 0
    
check_display:
    beq r20, r0, update_display
    br delay
    
update_display:
    call display_time
    
delay:
    movi r4, DELAY_MS
    call delay_ms
    
    br main_loop

display_time:
    subi sp, sp, 20
    stw ra, 0(sp)
    stw r2, 4(sp)
    stw r3, 8(sp)
    stw r4, 12(sp)
    stw r5, 16(sp)
    
    mov r3, r18
    movi r4, 10
    div r2, r3, r4
    mul r4, r2, r4
    sub r4, r3, r4
    call digit_to_7seg
    mov r5, r2
    
    mov r4, r2
    call digit_to_7seg
    slli r2, r2, 8
    or r5, r5, r2
    
    mov r3, r17
    movi r4, 10
    div r2, r3, r4
    mul r4, r2, r4
    sub r4, r3, r4
    call digit_to_7seg
    slli r2, r2, 16
    or r5, r5, r2
    
    mov r4, r2
    call digit_to_7seg
    slli r2, r2, 24
    or r5, r5, r2
    
    movia r3, SEVEN_SEG_BASE
    stwio r5, 0(r3)
    
    mov r3, r16
    movi r4, 10
    div r2, r3, r4
    mul r4, r2, r4
    sub r4, r3, r4
    call digit_to_7seg
    mov r5, r2
    
    mov r4, r2
    call digit_to_7seg
    slli r2, r2, 8
    or r5, r5, r2
    
    movia r3, SEVEN_SEG_BASE
    addi r3, r3, 0x10
    stwio r5, 0(r3)
    
    ldw ra, 0(sp)
    ldw r2, 4(sp)
    ldw r3, 8(sp)
    ldw r4, 12(sp)
    ldw r5, 16(sp)
    addi sp, sp, 20
    ret

digit_to_7seg:
    movi r2, 0
    
    movi r3, 0
    beq r4, r3, digit_0
    movi r3, 1
    beq r4, r3, digit_1
    movi r3, 2
    beq r4, r3, digit_2
    movi r3, 3
    beq r4, r3, digit_3
    movi r3, 4
    beq r4, r3, digit_4
    movi r3, 5
    beq r4, r3, digit_5
    movi r3, 6
    beq r4, r3, digit_6
    movi r3, 7
    beq r4, r3, digit_7
    movi r3, 8
    beq r4, r3, digit_8
    movi r3, 9
    beq r4, r3, digit_9
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

delay_ms:
    subi sp, sp, 12
    stw ra, 0(sp)
    stw r2, 4(sp)
    stw r3, 8(sp)
    
    movi r2, 50000
    mul r3, r4, r2
    
delay_loop:
    subi r3, r3, 1
    bgt r3, r0, delay_loop
    
    ldw ra, 0(sp)
    ldw r2, 4(sp)
    ldw r3, 8(sp)
    addi sp, sp, 12
    ret
