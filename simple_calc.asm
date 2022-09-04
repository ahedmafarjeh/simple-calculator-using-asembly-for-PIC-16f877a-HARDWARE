;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Project:		Interfacing PICs 
;	Source File Name:	VINTEST.ASM		
;	Devised by:		MPB		
;	Date:			19-12-05
;	Status:			Final version
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 	Demonstrates simple analogue input
;	using an external reference voltage of 2.56V
;	The 8-bit result is converted to BCD for display
;	as a voltage using the standard LCD routines.
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PROCESSOR 16F877A
;	Clock = XT 4MHz, standard fuse settings
	__CONFIG 0x3731

;	LABEL EQUATES	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	#INCLUDE "P16F877A.INC" 	; standard labels 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	
	cblock 0x25
d1
d2
d3
d11	
d12		
d13	
d21
d22
d23
counter
num1
num2
num
x
dgt
x2
digit_pos
op_num
RB0_count
huns
tens
ones
	endc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; PROGRAM BEGINS ;;;;;;;

	ORG	0		; Default start address 
	GOTO start 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Inerupt service routine
ISR
	ORG 004
	BCF INTCON,7 ;clear GIE to deny other interupt
	BCF	Select,RS	; set display command mode
	;check if we at 1st huns
 	MOVLW 1
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 0
	GOTO  huns1 
	;check if we at 1st tens 	
	MOVLW 2
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 0
	GOTO  tens1
	;check if we at 1st ones
	MOVLW 3
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 0
	GOTO  ones1  
	;check if we at operation
	MOVLW 4
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 0
	GOTO  operation 

	MOVLW 5
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 0
	GOTO  huns2 
	;check if we at 1st tens 	
	MOVLW 6
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 0
	GOTO  tens2
	;check if we at 1st ones
	MOVLW 7
	SUBWF digit_pos,W
	BTFSC STATUS,2 ; check if digit_pos is 0
	GOTO  ones2  
	GOTO cont

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	huns1
		MOVLW	0C0		; code to home cursor at first position
		CALL	send	; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT	; handle interrupt Timer 0
	; handle interrupt RB0
	RBO_INTR
		INCF d11
		MOVLW 3
		SUBWF d11,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_huns
		GOTO dis_RB0
	zero_huns
		CLRF d11
		GOTO dis_RB0
	TM0_INT
		INCF counter
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM0
		GOTO cont
	dis_TM0
		;here timer is arrive 2 second
		CLRF counter 
		INCF digit_pos
		MOVF d11,w
		MOVWF dgt
		call MUL_BY_100
		MOVF x2,w
		ADDWF num1,f
		CLRF x2
		GOTO dis_RB0
	dis_RB0
		MOVLW	030		; load ASCII offset
		ADDWF	d11,W
		CALL	send
		GOTO cont
	;;;;;;;;;;;;;;;;;;;;;
	;tens part
	tens1
		MOVLW	0C1		; code to home cursor
		CALL	send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1
		GOTO TM0_INT1
		
	RBO_INTR1
		INCF d12
		MOVLW 2
		SUBWF d11,W
		BTFSC STATUS,2
		GOTO rolling_tens_5_0
		MOVLW d'10'
		SUBWF d12,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_tens
		GOTO dis_RB01
	rolling_tens_5_0
		MOVLW 6
		SUBWF d12,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_tens
		GOTO dis_RB01
	zero_tens
		CLRF d12
		GOTO dis_RB01
	TM0_INT1
		INCF counter
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM01
		GOTO cont
	dis_TM01
		CLRF counter
		INCF digit_pos
		MOVF d12,w
		MOVWF dgt
		call MUL_BY_10
		MOVF x2,w
		ADDWF num1,f
		CLRF x2
		GOTO dis_RB01
	dis_RB01
		MOVLW	030		; load ASCII offset
		ADDWF	d12,W
		CALL	send
		GOTO cont
	;;;;;;;;;;;;;;;;;;;;;;
	;ones part
	ones1
		MOVLW	0C2		; code to home cursor
		CALL	send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1
		GOTO TM0_INT2
		
	RBO_INTR2
		INCF d13
		MOVLW 2
		SUBWF d11,W
		BTFSC STATUS,2
		GOTO chk_tens	
	normal
		MOVLW d'10'
		SUBWF d13,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_ones
		GOTO dis_RB02
	chk_tens
		MOVLW 5
		SUBWF d12,W
		BTFSC STATUS,2
		GOTO rolling_ones_5_0
		GOTO normal
	rolling_ones_5_0
		MOVLW 6
		SUBWF d13,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_ones
		GOTO dis_RB02
	
	zero_ones
		CLRF d13
		GOTO dis_RB02
	TM0_INT2
		INCF counter
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM02
		GOTO cont
	dis_TM02
		CLRF counter
		INCF digit_pos
		MOVF d13,w
		ADDWF num1,f
		GOTO dis_RB02
	dis_RB02
		MOVLW	030		; load ASCII offset
		ADDWF	d13,W
		CALL	send
		GOTO cont
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;for operation
	operation
		INCF RB0_count	
		MOVLW 1
		SUBWF RB0_count,W
		BTFSC STATUS,2
		GOTO first_click
	cont_oper
		MOVLW	0C3		; code to home cursor at first position
		CALL	send	; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1
		GOTO TM0_INT3
		
	RBO_INTR3
		MOVLW 0 
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO add_op
	mul_op
		DECF op_num
		MOVLW '*'
		CALL	send
		GOTO cont
	add_op
		INCF op_num
		MOVLW '+'
		CALL	send
		GOTO cont
	TM0_INT3
		INCF counter
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM03
		GOTO cont
	dis_TM03
		CLRF counter
		INCF digit_pos
		MOVLW 0 
		SUBWF op_num,W
		BTFSC STATUS,2
		GOTO mul_op
		GOTO add_op
		
	first_click
		INCF op_num
		GOTO cont_oper
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	huns2
		MOVLW	0C4		; code to home cursor at first position
		CALL	send	; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1  ; check if interrupt is from RB0 or Timer0 
		GOTO TM0_INT4	; handle interrupt Timer 0
	; handle interrupt RB0
	RBO_INTR4
		INCF d21
		MOVLW 3
		SUBWF d21,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_huns2
		GOTO dis_RB04
	zero_huns2
		CLRF d21
		GOTO dis_RB04
	TM0_INT4
		INCF counter
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM04
		GOTO cont
	dis_TM04
		;here timer is arrive 2 second
		CLRF counter 
		INCF digit_pos
		MOVF d21,w
		MOVWF dgt
		call MUL_BY_100
		MOVF x2,w
		ADDWF num2,f
		CLRF x2
		GOTO dis_RB04
	dis_RB04
		MOVLW	030		; load ASCII offset
		ADDWF	d21,W
		CALL	send
		GOTO cont
	;;;;;;;;;;;;;;;;;;;;;
	;tens part
	tens2
		MOVLW	0C5		; code to home cursor
		CALL	send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1
		GOTO TM0_INT5
		
	RBO_INTR5
		INCF d22
		MOVLW 2
		SUBWF d21,W
		BTFSC STATUS,2
		GOTO rolling_tens2_5_0
		MOVLW d'10'
		SUBWF d22,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_tens2
		GOTO dis_RB05
	rolling_tens2_5_0
		MOVLW 6
		SUBWF d22,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_tens2
		GOTO dis_RB05
	zero_tens2
		CLRF d22
		GOTO dis_RB05
	TM0_INT5
		INCF counter
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM05
		GOTO cont
	dis_TM05
		CLRF counter
		INCF digit_pos
		MOVF d22,w
		MOVWF dgt
		call MUL_BY_10
		MOVF x2,w
		ADDWF num2,f
		CLRF x2
		GOTO dis_RB05
	dis_RB05
		MOVLW	030		; load ASCII offset
		ADDWF	d22,W
		CALL	send
		GOTO cont
	;;;;;;;;;;;;;;;;;;;;;;
	;ones part
	ones2
		MOVLW	0C6		; code to home cursor
		CALL	send		; output it to display
		BSF	Select,RS	; and restore data mode
		BTFSS INTCON,1
		GOTO TM0_INT6
		
	RBO_INTR6
		INCF d23
		MOVLW 2
		SUBWF d21,W
		BTFSC STATUS,2
		GOTO chk_tens2	
	normal1
		MOVLW d'10'
		SUBWF d23,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_ones2
		GOTO dis_RB06
	chk_tens2
		MOVLW 1
		SUBWF d22,W
		BTFSC STATUS,2
		GOTO rolling_ones2_5_0
		GOTO normal1
	rolling_ones2_5_0
		MOVLW 6
		SUBWF d23,W
		BTFSC STATUS,2 ; check if huns is 3
		GOTO zero_ones2
		GOTO dis_RB06
	
	zero_ones2
		CLRF d23
		GOTO dis_RB06
	TM0_INT6
		INCF counter
		MOVLW d'40'
		SUBWF counter,W
		BTFSC STATUS,2 ;check if counter value is 20
		GOTO dis_TM06
		GOTO cont
	dis_TM06
		CLRF counter
		INCF digit_pos
		MOVF d23,w
		ADDWF num2,f
		GOTO dis_RB06
	dis_RB06
		MOVLW	030		; load ASCII offset
		ADDWF	d23,W
		CALL	send
	GOTO cont


	;;;;;;;;;;;;;;;;;;;;;;;;;;;

	cont
	MOVLW d'61'
	MOVWF TMR0
	BCF INTCON,1
	BCF INTCON,2
	BSF INTCON,7
RETFIE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Port & display setup.....................................
start
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;initialize all digits to zero
	MOVLW 0
	MOVWF d11
	MOVWF d12
	MOVWF d13
	MOVWF d21
	MOVWF d22
	MOVWF d23
	MOVWF counter
	CLRF op_num
	MOVLW 1
	MOVWF digit_pos
	CLRF RB0_count
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;some config. for LCD that connected with portA
	BANKSEL	TRISD		; Select bank 1
	CLRF	TRISD		; Display port is output 
	BANKSEL PORTD		; Select bank 0
	CLRF	PORTD		; Clear display outputs
	CALL	inid		; Initialise the display
	CLRF	dgt
	CLRF	x2
	CLRF	huns
	CLRF	tens
	CLRF	ones
	CLRF	num
	CLRF 	num1
	CLRF 	num2
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;print "ENTER OPERATION" in first line
	BCF	Select,RS	; set display command mode
	MOVLW	080		; code to home cursor
	CALL	send		; output it to display
	BSF	Select,RS	; and restore data mode
	CALL	putLCD		; display input
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;configuration for interupt on RB0 and TIMR0
	banksel OPTION_REG
	MOVLW B'11000111'
	MOVWF OPTION_REG
	BANKSEL TRISB
	MOVLW H'FF'
	MOVWF TRISB
	BANKSEL INTCON
	BSF INTCON,7 ; Globak=l interrupt enable
	BSF INTCON,4 ; RB0 interrupt enable
	BCF INTCON,1 ; RB0 interrrupt flag
	BSF INTCON,5 ;TIMR0 interrupt enable
	BCF INTCON,2 ;TIMR0 interrupt flag
	MOVLW d'61'
	MOVWF TMR0 ;TMR0 = 256 - (Fosc/4*F*PRE)-->Fosc=4MHZ, F = 1/(50ms),PRE = 256

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;now,just do nothing until interupt on RB0 occur
start2	
	BTFSS digit_pos,3
	GOTO rtrn
	BCF INTCON,5
	BCF	Select,RS	; and restore data mode
	MOVLW	0C7		; code to home cursor
	CALL    send		; output it to display
	BSF	Select,RS	; and restore data mode
    MOVLW '='  
    CALL    send   
   CALL print_result
	BTFSC op_num,0
	GOTO multi
	GOTO addition
multi 
	call mull_numbers
	GOTO sho
addition 
	call add_numbers
sho
	call get_digits
	call display
	call d_3sec
	GOTO start
rtrn
	GOTO	start2		; jump to start2 loop

putLCD
    
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'N'		; load volts code
	CALL	send		; and output
	MOVLW	'T'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'R'		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	'O'		; load volts code
	CALL	send		; and output
	MOVLW	'P'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'R'		; load volts code
	CALL	send		; and output
	MOVLW	'A'		; load volts code
	CALL	send		; and output
	MOVLW	'T'		; load volts code
	CALL	send		; and output
	MOVLW	'I'		; load volts code
	CALL	send		; and output
	MOVLW	'O'		; load volts code
	CALL	send		; and output
	MOVLW	'N'		; load volts code
	CALL	send		; and output

	RETURN			; done
    
print_result
	BCF	Select,RS	; and restore data mode
    MOVLW	080		; code to home cursor
    CALL    send		; output it to display
    BSF	Select,RS	; and restore data mode
    MOVLW	'R'		; load volts code
	CALL	send		; and output
	MOVLW	'E'		; load volts code
	CALL	send		; and output
	MOVLW	'S'		; load volts code
	CALL	send		; and output
	MOVLW	'U'		; load volts code
	CALL	send		; and output
	MOVLW	'L'		; load volts code
	CALL	send		; and output
	MOVLW	'T'		; load volts code
	CALL	send		; and output
    MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
	MOVLW	' '		; load volts code
	CALL	send		; and output
    
    RETURN			; done
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MUL_BY_100	
	MOVLW d'100'
	MOVWF x
	MOVF dgt,w
	loop3
		ADDWF x2,f 
		decfsz x,f
	GOTO loop3
RETURN			; done
MUL_BY_10	
	MOVLW d'10'
	MOVWF x
	MOVF dgt,w
	loop4
		ADDWF x2,f 
		decfsz x,f
	GOTO loop4
	CLRF dgt
RETURN			; done
	
get_digits
	BSF	STATUS,C	; set carry for subtract
	MOVLW	D'100'		; load 100
sub3 
	SUBWF	num		; and subtract from result
	INCF	huns		; count number of loops
	BTFSC	STATUS,C	; and check if done
	GOTO	sub3		; no, carry on

	ADDWF	num		; yes, add 100 back on
	DECF	huns		; and correct loop count

; Calculate tens digit.....................................

	BSF	STATUS,C	; repeat process for tens
	MOVLW	D'10'		; load 10
sub4
	SUBWF	num		; and subtract from result
	INCF	tens		; count number of loops
	BTFSC	STATUS,C	; and check if done
	GOTO	sub4		; no, carry on

	ADDWF	num		; yes, add 100 back on
	DECF	tens		; and correct loop count
	MOVF	num,W		; load remainder
	MOVWF	ones		; and store as ones digit

	RETURN			; done
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display
	BCF	Select,RS	; and restore data mode
	MOVLW	0C8		; code to home cursor
	CALL	send		; output it to display
	BSF	Select,RS	; and restore data mode
	MOVLW 030
	ADDWF huns
	ADDWF tens
	ADDWF ones
	MOVF huns,W
	call send
	MOVF tens,W
	call send
	MOVF ones,W
	call send
RETURN
;;;;;;;;;;;;;;;;;;;;;;;;
;Addition
add_numbers	
	MOVF num1,w
	ADDWF num2,w
	MOVWF num
RETURN
;MULTIPLICATION OF TWO NUMBERS
mull_numbers
	MOVF num1,w
	loop5
		ADDWF num,f 
		decfsz num2,f
	GOTO loop5	
RETURN
d_3sec
	movlw d'12'
	movwf d3
	loop3d
	movlw d'200'
	movwf d2
	loop2d
	movlw d'250'
	movwf d1
	loopd
	nop
	nop
	decfsz d1,f
	goto loopd 
	decfsz d2,f
	goto loop2d
	decfsz d3,f
	GOTO loop3d
return

; INCLUDED ROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Include LCD driver routines
;

	#INCLUDE "LCDIS.INC"
;	Contains routines:
;	inid:	Initialises display
;	onems:	1 ms delay
;	xms:	X ms delay
;		Receives X in W
;	send:	Sends a character to display
;		Receives: Control code in W (Select,RS=0)
;		  	  ASCII character code in W (RS=1)	
finl
	END	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
