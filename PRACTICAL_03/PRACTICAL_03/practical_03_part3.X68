*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    LEA HEALTH, A3      ;Loads the address of HEALTH into address register A3
    SUB.B #10, (A3)     ;This subtracts 10 from the byte stored at HEALTH
;This program does not print anything to the screen. It only changes a value in memory and then halts    
    SIMHALT

HEALTH dc.b $64             
    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
