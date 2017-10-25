TITLE Project 3     (project3.asm)

; Author: Mario Franco-Munoz		francomm@oregonstate.edu	
; CS271-400 / Assignment #3			Due Date: 10/30/2017 11:59pm
; Description: This program prompts the user to enter negative numbers between -100 and -1 (inclusive)
; and calculates and prints the average of the numbers entered.


INCLUDE Irvine32.inc

;Constants defenition section
LOW_LIMIT = -100
HIGH_LIMIT = -1

.data
;primary statements
intro1			BYTE	"Welcome to the Integer Accumulator by Mario Franco-Munoz",0
prompt1			BYTE	"What is your name?",0
greeting		BYTE	"Hello, ",0
instr1			BYTE	"Please enter numbers in [-100, -1]",0
instr2			BYTE	"Enter a non-negative number when you are finished to see results.",0
prompt2			BYTE	". Enter number: ",0
promp3			BYTE	": ",0
results1		BYTE	"You entered ",0
results2		BYTE	" valid numbers.",0
results3		BYTE	"The sum of your valid numbers is ",0
results4		BYTE	"The rounded average is ",0
results5		BYTE	"The average as a floating-point roundeed to the nearest .001 is ",0
farewell		BYTE	"Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ",0
farewell2		BYTE	".",0
extraCred1		BYTE	"**EC: 1. Number the lines during user input.",0
extraCred2		BYTE	"**EC: 2. Calculate and display the average as a floating-point number, rounded to the nearest .001",0

;for storing users name
namebuffer		BYTE	21 DUP(0)
nameByteCount	DWORD	?

;for calculating the mean
sum				SDWORD	?
count			SDWORD	0
intVal			SDWORD	?
rMean			SDWORD	?
mybool			DWORD	0	

;for displaying line numbers
linecount		DWORD	0

;extra credit 2 block for displaying result rounded to nearest .001
ctrlRound		WORD	010000000000b
ctrlSubst		WORD	?
firstNo			WORD	?
secondNo		WORD	?
thousand		WORD	1000
dblQuot			WORD	?


;*************************MAIN*************************************
.code
main PROC
	
	call	introduction
	call	userInput
	call	displayResults


	exit	; exit to operating system
main ENDP


;---------------------------------------------------------
; introduction
;
; Introduction to Integer Accumulator program. Introduces user to
; program, greets the user and prompts with initial instructions.
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
introduction PROC
	;extra credit statements
	mov		edx, OFFSET extraCred1
	call	WriteString
	call	CRLF
	mov		edx, OFFSET extraCred2
	call	WriteString
	call	CRLF
	call	CRLF

	;basic intro
	mov		edx, OFFSET intro1
	call	WriteString
	call	CRLF
	
	;prompt user for their name
	mov		edx, OFFSET prompt1
	call	WriteString
	call	CRLF
	
	;store their name
	mov		edx, OFFSET namebuffer
	
	;Greet user
	mov		edx, OFFSET greeting
	call	WriteString
	;call users name
	mov		edx, OFFSET namebuffer
	mov		ecx, SIZEOF namebuffer
	call	ReadString
	mov		nameByteCount, eax
	call	CRLF
	call	CRLF

	;display starting instructions
	mov		edx, OFFSET instr1
	call	WriteString
	call	CRLF

	ret
introduction ENDP

;---------------------------------------------------------
; userInput
;
; Userinput repeatedly prompts the user to enter a number. 
; Input is then verified to be weithin -100 and -1 (inclusive)
; Procedure ceases to sum and count numbers once a positive number is entered.
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
userInput PROC
	;do-while (post-test) loop to recieve numbers from user
	do:
		toosmall: 
			;display line numbers
			mov		eax, linecount
			inc		eax
			call	WriteDec
			mov		linecount, eax

			;prompt user to enter number
			mov		edx, OFFSET prompt2
			call	WriteString
			mov		eax, 0			;ensure that eax is clear before user input
			call	ReadInt
			
			;store the user input
			mov		intVal, eax
			
			;compare value entered against minimum (-100), instruct user to enter input again if value is less than -100
			cmp		intVal, LOW_LIMIT
			jl		toosmall
			
			;compare against upper limit (-1)
			cmp		intVal, HIGH_LIMIT
			jg		endLoop

			;add user input to running sum if input passed both prior input tests
			mov		eax, sum
			add		eax, intVal
			mov		sum, eax
			;increment the counter
			mov		eax, count
			inc		eax
			mov		count, eax

			;unconditionally jump until user enters a positive number
			jmp		do
	endLoop:

	ret
userInput ENDP
;---------------------------------------------------------
; displayResults
;
; displayResults calculates the average and displays the number 
; of valid integers entered by user, the sum of these valid numbers,
; and finaly displays average.
; Upon conclusion of these statements a farewell message is displayed to user.
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
displayResults PROC
	;output how many valid numbers were entered
	mov		edx, OFFSET results1
	call	WriteString
	mov		eax, count
	call	WriteDec
	mov		edx, OFFSET results2
	call	WriteString
	call	CRLF

	;output the sum of valid numbers entered
	mov		edx, OFFSET results3
	call	WriteString
	mov		eax, sum
	cwd
	call	WriteInt
	call	CRLF

	;calculate and store rounded average using signed division
	mov		edx, 0			;clear edx for sign extension (edx:eax sign extension)
	mov		eax, sum
	cdq						;convert to doubleword (to sign-extend EAX into EDX before performing division)
	mov		ebx, count
	idiv	ebx
	mov		rMean, eax

	;output rounded average
	mov		edx, OFFSET results4
	call	WriteString
	mov		eax, rMean
	call	WriteInt
	call	CRLF

	;output average as floating point, rounded to the nearest .001
	;(this code is based on chapter 12 of Assembly Language by ed.7 Irvine in conjunction with 
	; stackoverflow post:
	; (https://stackoverflow.com/questions/23358537/assembly-round-floating-point-number-to-001-precision-toward-%E2%88%9E)
	
	;convert sum and count to signed words (currently signed double words)
	mov			eax, sum
	cwd			
	mov			firstNo, ax
	mov			eax, count
	cwd
	mov			secondNo, bx
	

	fstcw		ctrlSubst					;use fstcw to store control word in a variable
	mov			ax, ctrlSubst
	and			ah,	11110011b
	or			ah,	00000000b				;rounding to nearest 0.001
	mov			ctrlRound, ax
	fldcw		ctrlRound					;load the now modified and ready control word
	

	fild		firstNo
	fidiv		secondNo
	fimul		thousand
	frndint
	fidiv		thousand
	mov			ax, thousand
	mov			dblQuot, ax

	fldcw		ctrlSubst


	;output floating point average
	mov		edx, OFFSET results5
	call	WriteString
	mov		ax, dblQuot
	call	WriteFloat
	call	CRLF


	;say goodbye
	mov		edx, OFFSET farewell
	call	WriteString
	mov		edx, OFFSET namebuffer
	call	WriteString
	mov		edx, OFFSET farewell2
	call	WriteString
	call	CRLF

	ret
displayResults ENDP
END main
