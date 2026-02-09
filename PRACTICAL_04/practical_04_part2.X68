    ORG    $1000
START:                  
    MOVE.B #100, $3000      ;Move health to memory location $3000
    
    ;move location of player into data register 
    ;X first Byte 0 to 15
    ;Y second byte 0 to 15
    
    MOVE.B #$12, D2         ; 0001 0010      
    
    ;move location of NPC into data register 
    ;X first Byte 0 to 15
    ;Y second byte 0 to 15

    MOVE.B #$22, D3         ; 0010 0010

    AND.B D2, D3            ;bitwise AND D2 and D3. Whats new location of Player D2 = 0001 0010
                                                                                ;D3 = 0010 0010
                                                                                ;     --------
                                                                                ;AND  0000 0010 ($02)
        
    LEA $3000, A1           ;load memory address $300 into address register A1
    
    SUB.B #20, (A1)         ;Hit by NPC. Non player character
    
    ADD.B #10, (A1)         ;Pickup health found
    
    SIMHALT             

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
