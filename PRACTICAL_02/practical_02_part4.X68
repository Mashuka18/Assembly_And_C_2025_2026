*-----------------------------------------------------------
* Title      :practical_02, PART4
* Written by :Mariia Vanaga
* Date       :19/01/2026
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    MOVE.L #$10, D0
    MOVE.L #%10, D1
    MOVE.L #10, D2
    
    MOVE.L D0, $2000
    MOVE.L D1, $2010
    MOVE.L D2, $2020
    
    MOVE.W #10, $2020
    MOVE.W #%10, $2010
    MOVE.W #$10, $2000

    MOVE.B #10, $2020
    MOVE.B #%10001010, $2010
    MOVE.B #$A, $2000
    
    MOVE.L #$F, D0
    MOVE.L #%10001111, D1
    MOVE.L #15, D2
    
    MOVE.L $2000, D0
    MOVE.L $2010, D1
    MOVE.L $2020, D2

    

    SIMHALT             

    END    START       


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
