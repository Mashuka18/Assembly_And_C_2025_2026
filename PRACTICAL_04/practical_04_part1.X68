    ORG    $1000
START:                  
    MOVE.B #100, $3000      ;Move health to Memory Location $3000 --> 60
    
    LEA $3000, A1           ;Load memory address $3000 into Adress Register A1
    
    SUB.B #20, (A1)         ;Hit by NPC. Non Player Character --> 50
    
    ADD.B #10, (A1)         ;pickup Health Found --> 5A
    SIMHALT             

    END    START  

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
