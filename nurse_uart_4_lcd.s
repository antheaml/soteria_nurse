#include <xc.inc>
    
global  UART_Setup, UART_Transmit_Message, UART_Loop_message, UART_Transmit_Byte

; **************************************************************************************
; ----- Module which sets up UART communication required to send messages to LCD screen
; **************************************************************************************

psect	udata_acs   ; reserve data space in access ram
UART_counter: ds    1	    ; reserve 1 byte for variable UART_counter

psect	uart_code,class=CODE
UART_Setup:
    bsf	    SPEN	; enable
    bcf	    SYNC	; synchronous
    bcf	    BRGH	; slow speed
    bsf	    TXEN	; enable transmit
    bcf	    BRG16	; 8-bit generator only
    movlw   103		; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1, A	; set baud rate
    bsf	    TRISC, PORTC_TX1_POSN, A	; TX1 pin is output on RC6 pin								
					; must set TRISC6 to 1
    return

UART_Transmit_Message:
    ; ****************************************************************************************
    ; ----- Subroutine which transmits message stored at FSR2 with length stored in W via UART
    ; ****************************************************************************************
    movwf   UART_counter, A
UART_Loop_message:
    movf    POSTINC2, W, A
    call    UART_Transmit_Byte
    decfsz  UART_counter, A
    bra	    UART_Loop_message
    return

UART_Transmit_Byte:	    
    ; **************************************************
    ; ----- Subroutine which transmits byte stored in W
    ; **************************************************
    btfss   TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte
    movwf   TXREG1, A
    return


