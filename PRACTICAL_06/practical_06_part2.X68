        ORG     $1000          ; Program starts at memory address $1000
START:

;=================================================
; TASK 0 (Prints exactly D1.W characters and then moves to a new line (CR + LF).)
; Display string using LENGTH (adds new line) in D1.W
; Adds CR + LF at the end
; A1 = address of string
; D1.W = number of characters
;=================================================
        LEA     MSG_LEN,A1     ; Load address of string into A1
        MOVE.W  #18,D1         ; String length = 18 characters
        ;MOVEQ   Only works with numbers -128 to +127
        ;Always loads into a data register (D0–D7)
        ;MOVEQ is like quickly putting a small number in your pocket 
        ;(D-register) so you can hand it to the simulator immediately.
        MOVEQ   #0,D0          ; Task number 0
        TRAP    #15            ; Call system service

;=================================================
; TASK 1
; Display string using LENGTH (NO new line) in D1.W
; Does NOT add CR + LF
;=================================================
        LEA     MSG_LEN,A1     ; Load same string address
        MOVE.W  #18,D1         ; Same length
        MOVEQ   #1,D0          ; Task number 1
        TRAP    #15            ; Execute

;=================================================
; TASK 2
; Read string from keyboard
; A1 = buffer address
; String stored NULL terminated
; D1.W returns length
;=================================================
        LEA     BUFFER,A1      ; Load buffer address
        MOVEQ   #2,D0          ; Task number 2
        TRAP    #15            ; Wait for user input

;=================================================
; TASK 3
; Display signed decimal number in D1.L
;=================================================
        MOVE.L  #-12345,D1     ; Put signed number in D1
        MOVEQ   #3,D0          ; Task number 3
        TRAP    #15            ; Display number

;=================================================
; TASK 4
; Read a decimal number from keyboard
; Number returned in D1.L
;=================================================
        MOVEQ   #4,D0          ; Task number 4
        TRAP    #15            ; Read number

        MOVEQ   #3,D0          ; Task 3 again
        TRAP    #15            ; Display the number entered

;=================================================
; TASK 5
; Read single character from keyboard
; Character returned in D1.B
;=================================================
        MOVEQ   #5,D0          ; Task number 5
        TRAP    #15            ; Wait for key press

;=================================================
; TASK 6
; Display single character stored in D1.B
;=================================================
        MOVEQ   #6,D0          ; Task number 6
        TRAP    #15            ; Print character

;=================================================
; TASK 7
; Check if key is pending
; D1.B = 1 if key waiting
; D1.B = 0 if no key
;=================================================
        MOVEQ   #7,D0          ; Task number 7
        TRAP    #15            ; Check keyboard

        CMP.B   #1,D1          ; Compare D1 with 1
        ;Branch if Not Equal
        ;It’s a conditional jump
        ;If the Zero flag = 0 => it jumps to the label you specify
        ;If Zero flag = 1 => it does not jump, continues to next instruction
        BNE     NO_KEY         ; If not equal, skip reading

        MOVEQ   #5,D0          ; If key exists, read it
        TRAP    #15            ; Execute

NO_KEY:

;=================================================
; TASK 8
; Get time since midnight
; Returned in D1.L (hundredths of seconds)
;=================================================
        MOVEQ   #8,D0          ; Task number 8
        TRAP    #15            ; Get system time

        MOVEQ   #3,D0          ; Display that time
        TRAP    #15

;=================================================
; TASK 11
; Move cursor
; High byte = column (0–79)
; Low byte  = row (0–31)
;=================================================
        MOVE.W  #$0A05,D1      ; Column 10, Row 5
        MOVEQ   #11,D0         ; Task number 11
        TRAP    #15

;=================================================
; TASK 12
; Keyboard echo control
; 0 = OFF
; Non-zero = ON
;=================================================
        MOVE.B  #0,D1          ; Turn echo OFF
        MOVEQ   #12,D0         ; I want to run Task 12 (keyboard echo control)
        TRAP    #15

        MOVE.B  #1,D1          ; Turn echo ON (Sets D1.B = 1)
        MOVEQ   #12,D0         
        TRAP    #15

;=================================================
; TASK 13
; Display NULL-terminated string
; Adds CR + LF
;=================================================
        LEA     MSG_NULL,A1    ; Load string address
        MOVEQ   #13,D0         ; Task 13
        TRAP    #15

;=================================================
; TASK 14
; Display NULL-terminated string
; NO CR + LF
;=================================================
        LEA     MSG_NULL,A1    ;Puts the memory address of the string MSG_NULL into register A1 
        MOVEQ   #14,D0         ;Run Task 14
        TRAP    #15

;=================================================
; TASK 16
; Adjust display properties
; 0 = hide input prompt
; 1 = show input prompt
; 2 = no newline when Enter pressed
; 3 = add newline (default)
;=================================================
        MOVE.B  #0,D1          ; Hide prompt
        MOVEQ   #16,D0         ; Selects Task 16 to run.
        TRAP    #15

        MOVE.B  #1,D1          ; Task 16 interprets non-zero as “Show input prompt”
        MOVEQ   #16,D0
        TRAP    #15

;=================================================
; TASK 17
; Display NULL string (no CR/LF)
; Then display number in D1.L
;=================================================
        LEA     MSG_NUM,A1     ; Load text
        MOVE.L  #1234,D1       ; Load number
        MOVEQ   #17,D0
        TRAP    #15

;=================================================
; TASK 18
; Display NULL string (no CR/LF)
; Then read number into D1.L
;=================================================
        LEA     MSG_READ,A1    ; Puts the memory address of the string into A1
        MOVEQ   #18,D0
        TRAP    #15

;=================================================
; TASK 19
; Key state OR last scan code
; If D1 = 0 ? return last key scan code
;=================================================
        ;Take the D1 register and wipe it completely clean — no numbers left inside.
        ;CLR = it zeros out the register completely.
        CLR.L   D1             ; Set D1 to 0
        MOVEQ   #19,D0
        TRAP    #15

;=================================================
; TASK 20
; Display signed number in field width
; D2.B = width
;=================================================
        MOVE.L  #5678,D1       ; Number to display
        ;If the number has fewer digits than 8, it will be padded with spaces on the left.
        MOVEQ   #8,D2          ; Field width = 8 columns
        MOVEQ   #20,D0
        TRAP    #15

;=================================================
; TASK 21
; Set font color and style
; D1.L = $00BBGGRR
; D2.B bits: 0=Bold,1=Italic,2=Underline,3=Strike
;=================================================
        MOVE.L  #$000000FF,D1  ; Red color
        MOVEQ   #1,D2          ; Bold ON
        MOVEQ   #21,D0
        TRAP    #15

;=================================================
; TASK 22
; Read character at Row,Col
; High word = Row
; Low word  = Col
;=================================================
        MOVE.L  #$0005000A,D1  ; Row 5, Column 10
        MOVEQ   #22,D0
        TRAP    #15

        MOVEQ   #6,D0          ; Display that character
        TRAP    #15

;=================================================
; CLEAR SCREEN (Task 11 special case)
; D1.W = $FF00
;=================================================
        MOVE.W  #$FF00,D1
        MOVEQ   #11,D0
        TRAP    #15

;=================================================
; TASK 9
; Terminate program (halt simulator)
;=================================================
        MOVEQ   #9,D0
        TRAP    #15


;================= DATA SECTION ==================
MSG_LEN:    DC.B 'Length string demo'
MSG_NULL:   DC.B 'Null terminated demo',0
MSG_NUM:    DC.B 'Number = ',0
MSG_READ:   DC.B 'Enter number: ',0
BUFFER:     DS.B 80

        END START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
