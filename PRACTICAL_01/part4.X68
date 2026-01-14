*-----------------------------------------------------------
* Title      :Practical_01
* Written by :Mariia Vanaga
* Date       :14/01/2026
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    LEA text, A1        ;load address of text into A1
    MOVE #4, D0
    TRAP #15
    
    MOVE #14, D0        ; output Data Register:
    TRAP #15
    
    MOVE #3, D0         ; output 0
    TRAP #15
    
    SIMHALT             
text:   dc.b 'Data Register: ', 0
    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
