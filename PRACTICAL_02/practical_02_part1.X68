*-----------------------------------------------------------
* Title      :PRACTICAL_02, part1
* Written by :Mariia Vanaga
* Date       :19/01/2026
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    MOVE.L #%100, D0
    MOVE.L #$100, D1
    MOVE.L #100,  D2
    
    MOVE.L D0, $3000
    MOVE.L D1, $3010
    MOVE.L D2, $3020
    
    SIMHALT             

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
