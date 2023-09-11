ORG 0000H
LJMP MAIN

ORG 000BH
LJMP INTERRUPT

ORG 0030H            
;LCD initialization commands
MAIN:	
MOV P0, #0FFH              ; making P0 as input port
SETB P1.5
MOV A,#38H                 ; setup 2-line 5 x 7  matrix display
ACALL COMMAND 
ACALL DELAY
MOV A,#0EH                 ; display ON, cursor ON, cursor blinking
ACALL COMMAND
ACALL DELAY
MOV A,#01H                 ; clear the display
ACALL COMMAND
ACALL DELAY
MOV A,#080H                ; cursor home.. line1 position 1
ACALL COMMAND
ACALL DELAY
LJMP AGAIN1
; giving command to LCD
COMMAND:
MOV P2,A                   ; put command on port P2
CLR P3.1                   ; make RS = 0 indicating LCD that command is being given
CLR P3.0                   ; Make R/W’ = 0 indicating write operation
SETB P3.2                  ; make latch enable 1
ACALL DELAY
CLR P3.2                   ; make latch enable low
RET
; giving delay for proper execution
DELAY:
MOV R3,#0FFH
AGAIN : DJNZ R3,AGAIN
RET
; Display part
AGAIN1:
MOV A,#' '
ACALL LCDWRITE
ACALL DELAY
MOV A,#'P'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'R'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'O'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'J'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'E'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'C'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'T'
ACALL LCDWRITE
ACALL DELAY

ACALL DELAY1
MOV A,#01H
ACALL COMMAND
ACALL DELAY

MOV A,#' '
ACALL LCDWRITE
ACALL DELAY
ACALL LCDWRITE
ACALL DELAY
MOV A,#'T'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'E'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'M'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'P'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'E'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'R'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'A'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'T'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'U'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'R'
ACALL LCDWRITE
ACALL DELAY
MOV A,#'E'
ACALL LCDWRITE
ACALL DELAY
LJMP AGAIN2

LCDWRITE:
MOV P2,A                      ; putting data on ports
SETB P3.1                     ; make RS = 1( indicating data)
CLR P3.0                      ; R/W’ = 0
SETB P3.2                     ; Latch enable = 1
ACALL DELAY
CLR P3.2                      ; Latch enable = 0
RET



DELAY1:                
MOV R3,#0FFH
HERE1: MOV R5,#0FFH
HERE2: MOV 75H,#02FH
HERE3: DJNZ 75H,HERE3
HERE4: DJNZ R5,HERE2
DJNZ R3,HERE1
RET
; ADC0804 interfacing
AGAIN2:
SETB P3.5          		       ; active low output pin INTR’ =1 indicating start of conversion
SETB P3.3    	               ; RD’ = 1 INDICATING OUTPUT enable is not valid
CLR P3.4          	           ; WR’ = 0 
SETB P3.4       	           ; low to high transition of WR’ indicating start of conversion process
HERE5: JB P3.5,HERE5           ; waiting until INTR’ is made 0 by ADC0804 indicating end of conversion
CLR P3.3                       ; RD’ = 0 indicating output is ready to be accessed
MOV A,#0C1H                    ; next line command for LCD
ACALL COMMAND
ACALL DELAY
MOV TMOD,#02H                  ; Timer 0 in mode 2
MOV IE,#82H		               ; Interrupt Enable  = 1000_0010
MOV R1,P0                      ; get the converted digital data to R1
MOV A,R1                       ; get the data to accumulator
MOV R4,A                       ; R4 <-- A
ACALL COMPARE                  ; Now compare this temparature
MOV A,R4                       ; temperature to be modified to accumulator
LCALL CONVERSION               ; Convert the hexadecimal to decimal 
LCALL LCDWRITETMP              ; display the modified temperature on LCD
ACALL DELAY1
LJMP MAIN





; comparing ranges of temperatures
COMPARE:
CLR C
CJNE R1,#35,GAIN
GAIN: JNC GAIN1
CLR C
CJNE R1,#25,GAIN2
GAIN2: JNC GAIN3
CLR TR0
LJMP GAIN4                              
GAIN1: ACALL GREATER
LJMP GAIN4
GAIN3: ACALL LOWER
GAIN4: CLR C
RET

GREATER:  
CLR TR0
MOV R2,#0AAH
MOV TH0,#0FFH
SETB TR0
RET

LOWER:               
CLR TR0
MOV R2,#0AAH
MOV TH0,#1FH
SETB TR0
RET


; hexadecimal to decimal conversion of temperature values
CONVERSION:
MOV B,#10
DIV AB
MOV R7,B
MOV B,#10
DIV AB
MOV R6,B
 MOV A,R6
ADD A,#30H
MOV R6,A
MOV A,R7
ADD A,#30H
MOV R7,A
RET
; Displaying temperature values
LCDWRITETMP:
MOV A,R6
ACALL LCDWRITE
ACALL DELAY
MOV A,R7
ACALL LCDWRITE
ACALL DELAY
MOV A,#'C'
ACALL LCDWRITE
ACALL DELAY
RET

INTERRUPT:
CPL P1.5
CLR TR0
MOV 76H,R2
HERER: DJNZ 76H,HERER
SETB TR0
CPL P1.5
RETI     

END
