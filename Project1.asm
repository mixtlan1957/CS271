TITLE Program Template     (template.asm)

; Author: Mario Franco-Munoz		francomm@oregonstate.edu	
; CS271-400 / Project #1			Date: 09/26/2017
; Description: This program will display the author and program title on the output screen and prompt the user
;	for two numbers. The sum, difference, product, (integer) quotient and remainder of the numbers is then calculated
;	and terminating message is displayed.

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data
intro1		BYTE	"         Project 1: Elementary Arithmetic    by Mario Franco-Munoz",0	
intro2		BYTE	"Enter 2 numbers, and I'll show you the sum, difference,",0
intro3		BYTE	"product, quotient, and remainder.",0
prompt1		BYTE	"First number: ",0
firstInt	DWORD	?
prompt2		BYTE	"Second number: ",0
secondInt	DWORD	?
goodBye		BYTE	"Impressed?   Bye!",0
sum			DWORD	0
difference	DWORD	0
product		DWORD	0
quotient	DWORD	0
remStmnt	BYTE	" remainder ",0
remainder	DWORD	0
pSign		BYTE	" + ",0
minSign		BYTE	" - ",0
multSign	BYTE	" x ",0	
equalSign	BYTE	" = ",0	
diviSign	BYTE	" ö ",0  ; cmd output is in ANSI division symbol: ALT+0247

extraCred1	BYTE	"**EC: 1. Repeat until the user chooses to quit.",0
extraCred2	BYTE	"**EC: 2. Validate the second number to be less than the first.",0
extraCred3	BYTE	"**EC: 3. Calculate and display the quotient as a floating-point number, rounded to the nearest .001.",0
playAgain	BYTE	"Would you like to run program again?",0
rptPrompt1	BYTE	"1. Enter 1 to run program again.",0
rptPrompt2	BYTE	"2. Enter 2 to exit.",0
yesSelect	DWORD	1
choice		DWORD	?
diviErr		BYTE	"The second number must be less than the first!",0

;EC#3 data block
floatDivi	BYTE	"Divison displayed as a float, rounded to the nearest 0.001:",0
ctrlRound	WORD	010000000000b
ctrlSubst	WORD	?
firstNo		WORD	?
secondNo	WORD	?
thousand	WORD	1000
dblQuot		WORD	?

.code
main PROC
mov eax, edx

;Introduce author and program name
	mov		edx, OFFSET intro1
	call	WriteString
	call	CrLF
	call	CrLF

;Jump point if user decides to run program again.
RunAgain:	

;Display instructions for user
	mov		edx, OFFSET intro2
	call	WriteString
	call	CrLF
	mov		edx, OFFSET intro3
	call	WriteString
	call	CrLF
	call	CrLF

;Prompt the user to enter two numbers and store them
	mov		edx, OFFSET prompt1
	call	WriteString
	call	ReadInt
	mov		firstInt, eax
	mov		firstNo, ax				;16 bit version for EC#3 option
	mov		edx, OFFSET prompt2
	call	WriteString
	call	ReadInt
	mov		secondInt, eax
	mov		secondNo, ax			;16 bit version for EC#3 option
	call	CrLF

;EC#2: Jump to end of program if second number is greater than the first
	mov		eax, firstInt
	cmp		eax, secondInt
	jl		DivisionError

;Calculate the sum, difference, product, (integer) quotient and remainder of the numbers
	;sum calculation
	mov		eax, firstInt
	add		eax, secondInt
	mov		sum, eax

	;difference calculation
	mov		eax, firstInt
	sub		eax, secondInt
	mov		difference, eax


	;product calculation
	mov		eax, firstInt
	mov		ebx, secondInt
	mul		ebx
	mov		product, eax

	;quotient and remainder calculation
	mov		eax, firstInt
	cdq
	mov		ebx, secondInt
	div		ebx
	mov		quotient, eax
	mov		remainder, edx
	
	;extra credit option #3 block
	fstcw		ctrlSubst
	mov			ax, ctrlSubst
	and			ah,	11110011b
	or			ah,	00000000b				;rounding to nearest 0.001
	mov			ctrlRound, ax
	fldcw		ctrlRound
	
	fild		firstNo
	fidiv		secondNo
	fimul		thousand
	frndint
	fidiv		thousand
	mov			ax, thousand
	mov			dblQuot, ax

	fldcw		ctrlSubst

	

;Display the results
	;display sum
	mov		eax, firstInt
	call	WriteDec
	mov		edx, OFFSET pSign
	call	WriteString
	mov		eax, secondInt
	call	WriteDec
	mov		edx, OFFSET equalSign
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLF

	;display difference
	mov		eax, firstInt
	call	WriteDec
	mov		edx, OFFSET minSign
	call	WriteString
	mov		eax, secondInt
	call	WriteDec
	mov		edx, OFFSET equalSign
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLF

	;display product
	mov		eax, firstInt
	call	WriteDec
	mov		edx, OFFSET multSign
	call	WriteString
	mov		eax, secondInt
	call	WriteDec
	mov		edx, OFFSET equalSign
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLF

	;display quotient with remainder
	mov		eax, firstInt
	call	WriteDec
	mov		edx, OFFSET diviSign
	call	WriteString
	mov		eax, secondInt
	call	WriteDec
	mov		edx, OFFSET equalSign
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET remStmnt
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLF
	
	;display floating point version of quotient rounded to nearest 0.001 (EC option3)
	mov		edx, OFFSET floatDivi
	call	WriteString
	call	CrLF
	mov		eax, firstInt
	call	WriteDec
	mov		edx, OFFSET diviSign
	call	WriteString
	mov		eax, secondInt
	call	WriteDec
	mov		edx, OFFSET equalSign
	call	WriteString
	mov		ax, dblQuot
	call	WriteFloat
	call	CrLF
	call	CrLF


;#EC1: Ask user if they want to run again
	mov		edx, OFFSET playAgain
	call	WriteString
	call	CrLF
	mov		edx, OFFSET rptPrompt1
	call	WriteString
	call	CrLF
	mov		edx, OFFSET rptPrompt2
	call	WriteString
	call	CrLF
	call	ReadInt
	cmp		eax, YesSelect
	je		RunAgain
	

;Display terminating message (Default branch - first number larger than second)
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLF

	exit

;jump point if second number was greater than first
DivisionError:
	mov		edx, OFFSET diviErr
	call	WriteString
	call	CrLF

;#EC1: Ask user if they want to run again
	mov		edx, OFFSET playAgain
	call	WriteString
	call	CrLF
	mov		edx, OFFSET rptPrompt1
	call	WriteString
	call	CrLF
	mov		edx, OFFSET rptPrompt2
	call	WriteString
	call	CrLF
	call	ReadInt
	cmp		eax, YesSelect
	je		RunAgain

;Display terminating message
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLF

	exit

main ENDP


END main
