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
remStmnt	BYTE	" remainder "
remainder	DWORD	0
pSign		BYTE	" + ",0
minSign		BYTE	" - ",0
multSign	BYTE	" x ",0	
equalSign	BYTE	" = ",0	
diviSign	BYTE	" ö ",0  ; cmd output is in ANSI division symbol: ALT+0247


.code
main PROC

;Introduce author and program name
	mov		edx, OFFSET intro1
	call	WriteString
	call	CrLF
	call	CrLF

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
	mov		edx, OFFSET prompt2
	call	WriteString
	call	ReadInt
	mov		secondInt, eax
	call	CrLF

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
	mov		quotient, ebx
	mov		remainder, edx
	

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
	call	CrLF


;Display terminating message
	mov		edx, OFFSET goodBye
	call	WriteString
	call	CrLF

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
