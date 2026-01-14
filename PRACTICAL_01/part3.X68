*-----------------------------------------------------------
* Title      :Practical_01
* Written by :Mariia Vanaga
* Date       :14/01/2026
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    MOVE.B #$64, D1     ;Load immediate value(100 in dec) into D1. 64hex conv to dec
    LEA text, A1        ; load address of text (text:   dc.b 'Data Register: ', 0)into A1
    MOVE #14, D0        ;load immediate value (14) into D0 .launches text on the screen(14) 
    TRAP #15            ;print. cant change
    
    MOVE #3, D0         ;load immediate value to (3) to D0
    TRAP #15            ;Execute TRAP (output on console)
    
    SIMHALT             
text:   dc.b 'Data Register: ', 0
    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
