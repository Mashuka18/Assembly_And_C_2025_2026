*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  
 
    LEA $4000, A2       ;Loading memory to A2 register
    MOVE.B #100, (A2)   ;Store the value 100(64) at memory location pointed by A2
    SUB.B #10, (A2)     ;Subtract values 100 - 10 at memory location pointed by A2 the output is 90(5A)

    SIMHALT             

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
