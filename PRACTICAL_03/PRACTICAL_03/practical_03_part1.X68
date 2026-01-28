*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    LEA $4000, A1       ;Loading memory to A1 register
    MOVE.B #100, (A1)   ;Store the value 100(64) at memory location pointed by A1
    
    SIMHALT             

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
