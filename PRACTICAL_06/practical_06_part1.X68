    ORG    $1000
START:                  

    ;Move Trap Task to D0
    MOVE.B #2, D0
    ;Interupt and Trap Task
    TRAP #15
    
    LEA MESSAGE, A1
    MOVE.B #13, D0
    TRAP #15
    
END_PROG:

MESSAGE: DC.B 'Trap Task TEST', 0
    SIMHALT             

    END    START       

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
