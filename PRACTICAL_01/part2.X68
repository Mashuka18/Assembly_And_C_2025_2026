*-----------------------------------------------------------
* Title      :Practical_01
* Written by :Mariia Vanaga
* Date       :14/01/2026
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:
                  
    MOVE.L #%00001111, D1   ;Load value to D1
    
    MOVE.B D1, D2           ;Copy Byte
    
    MOVE.B D1, $2000        ;Store byte from D1 to memory location $2000
    
    MOVE.B $2000, D2        ;Load byte from memory into D2
    
    MOVE.B $2000, $3000     ;copy byte from $2000 to memory location $3000
    
    SIMHALT             

    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
