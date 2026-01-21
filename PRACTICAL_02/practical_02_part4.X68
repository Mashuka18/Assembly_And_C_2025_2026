*-----------------------------------------------------------
* Title      :practical_02, PART4
* Written by :Mariia Vanaga
* Date       :19/01/2026
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    MOVE.L #$10, D0  ;hexadecimal number loaded into D0 
    MOVE.L #%10, D1  ;binary number loaded into D1
    MOVE.L #10, D2  ;decimal number loaded into D0
    
    MOVE.L D0, $2000   ;value from D0 to memory location $2000(8)
    MOVE.L D1, $2010  ;value from D1 to memory location $2010
    MOVE.L D2, $2020  ;value from D2 to memory location $2020
    
    MOVE.W #10, $2020  ;dec number loaded into memory location $2020 (4)
    MOVE.W #%10, $2010
    MOVE.W #$10, $2000

    MOVE.B #10, $2020 ;dec number loaded into memory location $2020 (2)
    MOVE.B #%10001010, $2010
    MOVE.B #$A, $2000
    
    MOVE.L #$F, D0
    MOVE.L #%10001111, D1
    MOVE.L #15, D2 ;dec number loaded into D2 (8)

    
    MOVE.L $2000, D0 ;from memory to register
    MOVE.L $2010, D1
    MOVE.L $2020, D2

    

    SIMHALT             

    END    START       



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
