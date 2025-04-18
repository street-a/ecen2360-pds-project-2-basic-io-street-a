
    .text
    .global update_leds_from_switches
    
update_leds_from_switches:
    
    subi sp, sp, 12          
    stw r8, 0(sp)            
    stw r9, 4(sp)           
    stw r10, 8(sp)          
    
   
    movia r8, 0xFF200040    
    movia r9, 0xFF200000     
    
    
    ldw r10, 0(r8)          
    
    
    stw r10, 0(r9)           
    
    ldw r8, 0(sp)            
    ldw r9, 4(sp)            
    ldw r10, 8(sp)           
    addi sp, sp, 12         
    
    ret                     
