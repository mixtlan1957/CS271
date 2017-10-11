TITLE Project 2     (project2.asm)

; Author: Mario Franco-Munoz		francomm@oregonstate.edu	
; CS271-400 / Assignment #2			Due Date: 10/15/2017 11:59pm
; Description: 


INCLUDE Irvine32.inc

; (insert constant definitions here)
MIN_FIB = 1
MAX_FIB = 46
TAB = 9
PERIOD = 46
NUMS_PER_ROW = 5


.data
;messages
intro1		BYTE	"Fibonacci Numbers",0
intro2		BYTE	"Programmed by Mario Franco-Munoz",0
prompt1		BYTE	"What's your name? ",0
greeting	BYTE	"Hello, ",0
prompt2		BYTE	"Enter the number of Fibonacci terms to be displayed",0
prompt3		BYTE	"Give the number as an integer in the range [1 .. 46].",0
prompt4		BYTE	"How many Fibonacci terms do you want? ",0
errorMsg	BYTE	"Out of range. Enter a number in [1 .. 46]",0
exitMsg1	BYTE	"Results certified by Leonardo Pisano.",0
exitMsg2	BYTE	"Goodbye, ",0

;values
namebuffer	BYTE	21 DUP(0)
byteCount	DWORD	?
choice		DWORD	?
rowCount	DWORD	0
fibnum		DWORD	1
prevnum		DWORD	0
temp		DWORD	?



EC1			BYTE	"**EC: Extra Credit Option 1, display the numbers in aligned columns.",0


.code
main PROC

	call	introduction
	call	userInstructions
	call	displayFibs
	call	farewell

	exit	; exit to operating system
main ENDP

;---------------------------------------------------------
; introduction
;
; Introduction to Fibonacci display program. Asks user for
; their first name and stores it.
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
introduction PROC
	;basic intro
	mov		edx,OFFSET intro1
	call	WriteString
	call	CRLF
	mov		edx,OFFSET intro2
	call	WriteString
	Call	CRLF
	mov		edx, OFFSET EC1
	call	WriteString
	call	CRLF
	call	CRLF
	
	;ask user for his name
	mov		edx, OFFSET prompt1
	call	WriteString

	;store the users name
	mov		edx,OFFSET namebuffer
	mov		ecx,SIZEOF namebuffer
	call	ReadString
	mov		byteCount, eax

	ret
introduction ENDP

;---------------------------------------------------------
; sumof
;
; Greets the user by name entered in introduction procedure
; and provides instructions on useage of program. Asks
; and stores user response for how many Fibonacci terms to
; be displayed. If integer value outside of range is provided
; user is prompted to enter values again.
; Receives: None
; Returns: None
;---------------------------------------------------------
userInstructions PROC
	;greet user
	mov		edx, OFFSET greeting
	call	Writestring
	mov		edx, OFFSET namebuffer
	call	WriteString
	call	CRLF

	;prompt user with instructions
	mov		edx, OFFSET prompt2 
	call	WriteString
	call	CRLF
	mov		edx, OFFSET prompt3
	call	WriteString
	call	CRLF
	
	;do-while user verification loop (post test loop) with nested statement
	do:
		mov		edx, OFFSET prompt4
		call	WriteString
		call	ReadInt
		mov		choice, eax
		
		cmp		choice, MAX_FIB
		jg		error
		cmp		choice, MIN_FIB
		jl		error
		jmp		goodInput

		;if input was not good display error message
		error:
			mov		edx, OFFSET errorMsg
			call	WriteString
			call	CRLF
			jmp		do
	;if input was good, exit loop
	goodInput:
	ret
userInstructions ENDP

;---------------------------------------------------------
; displayFibs
; 
; Displays numbers of Fibonacci sequence
; Recieves: None 
; Returns: None
;---------------------------------------------------------
displayFibs PROC
	mov		ecx, choice
	fibSequence:
			mov		eax, fibnum
			call	WriteDec
			cmp		fibnum, 14930352
			jge		tabMarker
			mov		al, TAB
			call	WriteChar
	tabmarker:							;only include an extra tab if number isn't already 8 digits long
			mov		al, TAB
			call	WriteChar
			mov		eax, fibnum			;re-load fibnum (part of eax register contains tab character)
			mov		ebx, fibnum
			add		eax, prevnum		
			mov		prevnum, ebx		;update previous number
			mov		fibnum, eax			;save updated fibnum (next numbmer in sequence to display)
			inc		rowCount
			;check if new row is needed
			cmp		rowCount, NUMS_PER_ROW
			jne		nocrlf
			mov		rowCount, 0
			call	CRLF
			nocrlf:
			loop	fibSequence
	call	CRLF
	call	CRLF
	ret
displayFibs ENDP
;---------------------------------------------------------
; farewell
;
; Displays farewell message
; Recieves: None
; Retrurns: None
;---------------------------------------------------------
farewell PROC
	mov		edx, OFFSET exitMsg1
	call	WriteString
	call	CRLF
	mov		edx, OFFSET exitMsg2
	call	WriteString
	call	CRLF

	ret
farewell ENDP


END main
