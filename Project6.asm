TITLE Program Template     (project6A.asm)

; Author: Mario Franco-Munoz
; CS-271 (400)/ Project 6               Due Date: 03-Dec-2017
; Description: This program prompts the user to enter ten unsigned integers
; calculates and displays the sum and truncated average. 
; Additionally the subtotal is displayed after each number that is input by the user.

INCLUDE Irvine32.inc

ARR_SIZE = 10

;---------------------------------------------------------
mDisplayString MACRO strBufAddress:REQ
;
; displayString macro takes a string OFFSET (address) and displays
; the contents of the string using the Irvine32.inc library.
;---------------------------------------------------------
	push	edx
	mov		edx, strBufAddress
	call	WriteString
	pop		edx
ENDM

;---------------------------------------------------------
mGetString MACRO strBuffer:REQ, prompt:REQ
;
; getString prompts the user to enter a string and the 
; macro then reads the contents of the input string using the
; Irvine32.inc procedure ReadString. As per ReadString requirements: the SIZEOF
; the string is saved to the ecx register and the OFFSET saved to the edx
; register prior to calling ReadString
;---------------------------------------------------------
	push	edx
	push	ecx

	;prompt user to enter a string
	mov		edx, prompt
	call	WriteString
	
	;read string section
	mov		edx, strBuffer
	mov		ecx, 29				;size of predefined stringBuffer - 1
	call	ReadString
	pop		edx
	pop		ecx
ENDM


.data
;title
title1			BYTE	"PROGRAMMING ASSIGNMENT 6 (option A): Designing low-level I/O procedures",0
title2			BYTE	"Written by: Mario Franco-Munoz",0
;instructions
instr1			BYTE	"Please provide 10 unsigned decimal integers.",0
instr2			BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0
instr3			BYTE	"After you have finished inputting the raw numbers I will display a list",0
instr4			BYTE	"of the integers, their sum, and their average value.",0
;prompts
prompt_unsigned	BYTE	"Please enter a number: ",0
error			BYTE	"ERROR: You did not enter an unsigned number or your number was too big.",0
tryAgain		BYTE	"Please try again: ",0
;results/end of program
results1		BYTE	"You entered the following numbers: ",0
sum				BYTE	"The sum of these numbers is: ",0
average			BYTE	"The average is: ",0
thankyou		BYTE	"Thanks for playing!",0
subtotal		BYTE	"The current subtotal is: ",0
;extra credit statements
extraCred1		BYTE	"**EC1:   Number each line of user input and display a running subtotal of the user's numbers.", 0
extraCred2		BYTE	"**EC2:   Handle signed integers.",0
extraCred3		BYTE	"**EC3:   Make your ReadVal and WriteVal procedures recursive.",0
extraCred4		BYTE	"**EC4:   Implement procedures ReadVal and Write Val for floating point values, using the FPU.",0

;array for number storage
numArray		DWORD	ARR_SIZE DUP(0)

;array for parsing string input
parser			DWORD	15 DUP(?)

;similar to parser, an array for separating a number into discrete digits for conversion to string
separator		SDWORD	15 DUP(?)
indexTrack		DWORD	0				;index counter for keep track of which element in the numArray to point to			

;string buffer for reading user input
stringBuffer	BYTE	30 DUP(?)

;output string
outputString	BYTE	40 DUP(0)

;general variables:
accum			DWORD	0
r_average		DWORD	0
arrSizeVar		DWORD	10
arrSum			DWORD	0
inputCount		DWORD	0
parsedCount		DWORD	0
displayCount	DWORD	10
carryCheck		DWORD	1

.code
main PROC

;introduction section
push	OFFSET instr4			;[ebp+36]
push	OFFSET instr3			;[ebp+32]
push	OFFSET instr2			;[ebp+28]
push	OFFSET instr1			;[ebp+24]
push	OFFSET extraCred3		;[ebp+20]
push	OFFSET extraCred1		;[ebp+16]
push	OFFSET title2			;[ebp+12]
push	OFFSET title1			;[ebp+8]
call	introduction

;Read Values from user section
push	OFFSET carryCheck				;[ebp+28]
push	OFFSET tryAgain					;[ebp+24]
push	OFFSET error					;[ebp+20]
push	OFFSET subtotal					;[ebp+16]
push	OFFSET inputCount				;[ebp+12]
push	arrSizeVar						;[ebp+8]
call	readVal

;display the numbers section
push	OFFSET results1			;[ebp+28]
push	OFFSET parsedCount		;[ebp+24]
push	OFFSET indexTrack		;[ebp+20]
push	OFFSET outputString		;[ebp+16]
push	OFFSET separator		;[ebp+12]
push	displayCount			;[ebp+8]
call	writeVal

;display sum and average section
push	OFFSET thankyou
push	OFFSET average
push	OFFSET arrSum
push	OFFSET sum		
call	displaySumAvg





	exit	; exit to operating system
main ENDP

;---------------------------------------------------------
; introduction uses the write string macro to display the title
; and initial instructions of the program
;
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp

	;display title
	mDisplayString [ebp+8]
	call		CRLF
	mDisplayString [ebp+12]
	call		CRLF

	;display extra credit statements
	mDisplayString [ebp+16]
	call		CRLF
	mDisplayString [ebp+20]
	call		CRLF
	call		CRLF


	;display instructions
	mDisplayString [ebp+24]
	call		CRLF
	mDisplayString [ebp+28]
	call		CRLF
	mDisplayString [ebp+32]
	call		CRLF
	mDisplayString [ebp+36]
	call		CRLF
	call		CRLF
	
	pop		ebp
	ret		34	
introduction ENDP

;---------------------------------------------------------
; readVal invokes the mGetString macro to get the user's string of digits.
; the string is then converted to numeric values (using an ascii conversion)
; If invalid input is detected, user is prompted to re-enter numbers.
;
; Preconditions: address of the array where values will be written needs to be pushed
; on the stack prior to calling readVal
;
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
readVal PROC
	push	ebp
	mov		ebp, esp
	pushad

	
	mov		ecx, [ebp+8]			;recursive counter

	;update recursive condition counter
	cmp		ecx, 0
	je		endRecursive_call

	;save contents of outer recursive counter
	push	ecx
	
	rePromptMarker:
	;call the string parser function to load parser array
	push	OFFSET prompt_unsigned		;ebp+32
	push	OFFSET parsedCount			;ebp+28
	push	OFFSET tryAgain				;ebp+24
	push	OFFSET error				;ebp+20
	push	OFFSET inputCount			;ebp+16
	push	OFFSET stringBuffer			;ebp+12
	push	OFFSET parser				;ebp+8
	call	stringParser
	
	;call the populateNumArr to combine the parsed contents and fill the numArray
	push	OFFSET carryCheck			;ebp+28
	push	OFFSET parsedCount			;ebp+24
	push	OFFSET inputCount			;ebp+20
	push	OFFSET accum				;ebp+16
	push	OFFSET numArray				;ebp+12
	push	OFFSET parser				;ebp+8
	call	populateNumArr

	;check if carry flag was set via carryCheck variable
	mov		edx, [ebp+28]
	mov		eax, [edx]
	cmp		eax, 0
	jne		noCarryError
	;"error" statement block
	mDisplayString [ebp+20]
	call	CRLF

	;"try again" statement block
	mDisplayString [ebp+24]
	call	CRLF
	
	;reset "carryCheck" flag
	mov		eax, 1
	mov		[edx], eax

	jmp		rePromptMarker

	noCarryError:

	;display the subtotal
	mDisplayString [ebp+16]
	push	OFFSET arrSum
	push	OFFSET numArray
	call	displaySum
	call	CRLF


	;increment input count
	mov		edx, [ebp+12]			;variable "inputCount"		
	mov		eax, [edx]
	inc		eax
	mov		[edx], eax


	;recursive function call
	pop		ecx
	dec		ecx
	push	OFFSET carryCheck
	push	OFFSET tryAgain
	push	OFFSET error
	push	OFFSET subtotal
	push	OFFSET inputCount
	push	ecx
	call	readVal

	;end of recursive loop
	endRecursive_call:
	
	popad
	pop		ebp
	ret		24
readVal ENDP


;---------------------------------------------------------
; stringParser is a subroutine that converts the string to an array of digits
;
; Preconditions: address of parser array (where single digits from string conversion are stored)
;	needs to be pushed on the stack prior to calling stringParser
; Recieves: 
; Returns:	
;---------------------------------------------------------
stringParser PROC
	push	ebp
	mov		ebp, esp
	pushad

	userprompt:

	;load inputCount variable
	mov		edx, [ebp+16]
	;display line of user input
	mov		eax, [edx]
	inc		eax
	call	WriteDec
	mov		eax, 0
	mov		al, 46
	call	WriteChar
	mov		al, 32
	call	WriteChar
	
	;load parser array
	mov		edi, [ebp+8]
	;load string buffer array
	mov		esi, [ebp+12]

	;initialize ebx
	mov		ebx, 0

	;use the mGetString macro to obtain a string from a user
	mGetString [ebp+12], [ebp+32]
	
	cld
	convert_parse:
	lodsb
		;check if count has beeen exceeded
		cmp		ebx, 11
		jge		breakLoop
		;check for null character
		cmp		eax, 0
		je		endloop

		;check if character ascii value is between 48 and 57
		cmp		eax, 48
		jl		breakLoop
		cmp		eax, 57
		jg		breakLoop

		;if character is within range convert it
		sub		eax, 48
		;store the digit in the parser array
		mov		[edi], eax
		add		edi, 4
		inc		ebx
	jmp		convert_parse
	breakLoop_carry:
	pop		ebx
	pop		edx
	breakLoop:

	;"error" statement block
	mDisplayString [ebp+20]
	call	CRLF

	;"try again" statement block
	mDisplayString [ebp+24]
	call	CRLF
	jmp		userprompt

	endloop:
	cmp		ebx, 0				
	je		breakLoop	;check for case in which enter key was pressed without any input

	mov		edx, [ebp+28]	;save/store the number of numbers that were parsed
	mov		[edx], ebx
	

	popad
	pop		ebp
	ret		28
stringParser ENDP


;---------------------------------------------------------
; populateNumArr is a subroutine (part of the readVal procedure) that
; fills an element in the numArray with the combined sum of the parser array.
;
; Preconditions: this procedure needs to be run AFTER running the stringParser
; procedure. Addresses of the parser array and numArray need need to be pushed on
; the stack - in that order.
; Recieves: EBX - length of number parsed by stringParser
; Returns:	none
;---------------------------------------------------------
populateNumArr PROC
	push	ebp
	mov		ebp, esp
	push	ecx
	push	eax
	push	ebx
	push	edx
	push	edi
	push	esi
	

	mov		esi, [ebp+8]				;store parser in esi
	mov		edi, [ebp+12]				;store numArray in edi


	;load ebx with parsed count
	mov		edx, [ebp+24]
	mov		ebx, [edx]

	;update the pointer for which element the parsed number will be stored in for the numArray
	push	ebx
	push	edx
	mov		edx, [ebp+20]
	mov		eax, [edx]
	mov		ebx, 4
	mul		ebx
	add		edi, eax
	pop		edx
	pop		ebx

	;load the loop counter
	mov		ecx, ebx
	;push	ebx

	;convert the parsed array into a single number and store it
	populate:
		;raise 10 to the power of the number's index
		mov		eax, 1
		mov		ebx, 10
		push	ecx
		sub		ecx, 1
		cmp		ecx, 0
		jle		skip_pow
		ten_pow:	
			mul		ebx
		loop	ten_pow
		skip_pow:
		pop		ecx
		;multiply 10^length-1 by the number in the k element of the parser array
		mov		ebx, [esi]
		mul		ebx					;10^(length-1) * parser[k]
		mov		edx, [ebp+16]
		add		[edx], eax
		jc		carryErrorFound
		;increment esi
		add		esi, 4
	loop	populate
	mov		ebx, [edx]
	mov		[edi], ebx

	;reset accumulator
	mov		eax, 0
	mov		[edx], eax

	;if carry flag was set, update the tracker variable
	jnc		noCarryErrorFound
	carryErrorFound:
	mov		edx, [ebp+28]
	mov		eax, 0
	mov		[edx], eax
	noCarryErrorFound:
	
	pop		esi
	pop		edi
	pop		edx
	pop		ebx
	pop		eax
	pop		ecx
	pop		ebp
	ret		24
populateNumArr ENDP

;---------------------------------------------------------
; displaySumAvg 
; This procedure displays the sum and average of the elements in the numArray
;
; Preconditions: output strings and arraySum variables need to be pushed
; (passed by reference) on the stack prior to calling this function.
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
displaySumAvg PROC
	push	ebp
	mov		ebp, esp
	pushad

	;"The sum of these numbers is:"
	mDisplayString	[ebp+8]
	mov		edx, [ebp+12]
	mov		eax, [edx]
	call	WriteDec
	call	CRLF

	;"The average is:"
	mDisplayString [ebp+16]

	;calculate and display average
	mov		ebx, ARR_SIZE
	cdq
	div		ebx
	call	WriteDec
	call	CRLF
	call	CRLF

	;goodbye statement
	mDisplayString [ebp+20]
	call	CRLF

	
	popad
	pop		ebp
	ret		16
displaySumAvg ENDP

;---------------------------------------------------------
; displaySum 
;
; sums the contents of the array elements and displays the sum by calling Irvine32 procedure WriteDec
; 
; preconditions: address of numArray for which elements will be
; summed for needs to be pushed on the stack prior to calling displaySum.
; address of arraySum also needs to be pushed on stack, for saving sum.
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
displaySum PROC
	push	ebp
	mov		ebp, esp
	push	ecx
	push	esi
	push	ebx
	push	eax
	push	edx

	;load numArray address
	mov		esi, [ebp+8]
	mov		ecx, ARR_SIZE
	
	;initialize accumulator
	mov		eax, 0

	;sum elements in numArray
	sumLoop:
		mov		ebx, [esi]
		add		eax, ebx
		add		esi, 4
	loop	sumLoop
	
	;display number
	call	WriteDec
	call	CRLF

	;save the result in the arrSum variable
	mov		edx, [ebp+12]
	mov		[edx], eax

	pop		edx
	pop		eax
	pop		ebx
	pop		esi
	pop		ecx
	pop		ebp
	ret		8
displaySum ENDP



;---------------------------------------------------------
; WriteVal 
;
; Preconditions: address of array storing numbers to be converted
; to a string needs to be pushed on the stack prior to calling this procedure
;
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
writeVal PROC
	push	ebp
	mov		ebp, esp
	pushad

	;load recursive counter
	mov		ecx, [ebp+8]

	cmp		ecx, 0
	jne		skipLast

	;Display the string (once recursion has concluded)
	mDisplayString	[ebp+28]
	call	CRLF
	mDisplayString	[ebp+16]
	call	CRLF
	jmp		exitRecursion
	skipLast:
	


	;separate the digits of the number using the separateDigits sub procedure
	push	OFFSET parsedCount			;[ebp+20]
	push	OFFSET indexTrack			;[ebp+16]
	push	OFFSET numArray				;[ebp+12]
	push	OFFSET separator			;[ebp+8]
	call	separateDigits

	;load separator array
	mov		esi, [ebp+12]
	;load output string array
	mov		edi, [ebp+16]

	;save ecx and load the loop counter for transfering separator array contents to outputString
	push	ecx
	mov		edx, [ebp+24]
	mov		ecx, [edx]

	;initialize edi to point at the last active element in the array
	mov		eax, ecx
	dec		eax
	mov		ebx, 4
	mul		ebx
	add		esi, eax

	;initialize esi to point at where new characters need to be input in the outputString
				;*this segment of code was adapted from the "Scaen for a Matching Character" segment
				;on Pg 356 Kip R. Irvine Assembly Language for x86 processors (7 ed)
	push	ecx
	mov		al, 0
	mov		ecx, LENGTHOF outputString
	cld
	repne	scasb
	dec		edi
	pop		ecx
				;*

	stringCreator:
		std					;reverse flag to traverse "separator" array in reverse
		lodsd
		cld					
		stosb
	loop	stringCreator

	;restore recursive loop counter
	pop		ecx

	;check if comma and space are necessary
	cmp		ecx, 1
	je		skipCommaSpace

	;store comma character
	mov		eax, 0
	mov		al, 44
	stosb
	
	;store spacecharacter
	mov		al, 32
	stosb
	
	skipCommaSpace:

	;update index tracker
	mov		edx, [ebp+20]
	mov		eax, [edx]
	add		eax, 4
	mov		[edx], eax


	;recursive function call
	dec		ecx
	push	OFFSET results1			;[ebp+28]
	push	OFFSET parsedCount		;[ebp+24]
	push	OFFSET indexTrack		;[ebp+20]
	push	OFFSET outputString		;[ebp+16]
	push	OFFSET separator		;[ebp+12]
	push	ecx						;[ebp+8]
	call	writeVal

	exitRecursion:


	popad
	pop		ebp
	ret		24
writeVal ENDP


;---------------------------------------------------------
; separateDigits 
;
; Preconditions: address of parser and numArray need to be pushed on the stack
; prior to calling this function. (in that order
;
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
separateDigits PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		edi, [ebp+8]		;load separator array
	mov		esi, [ebp+12]		;load numArray (array holding the numbers to be converted to string

	;update which element needs to be pointed to
	mov		edx, [ebp+16]
	mov		eax, [edx]
	add		esi, eax

	;load element of numArray that needs to be separated into discrete digits
	mov		eax, [esi]
	mov		ebx, 10
	
	;initialize the counter
	mov		ecx, 0

	;continously divide by 10 to get each discrete digit
	cld
	lodsd
	converter:
	inc		ecx
	cdq
	div		ebx
	cmp		eax, 0
	je		last_digit

	;remainder (stored in edx contains the discrete digit)
	add		edx, 48				;convert to ascii

	;load the result into the separator (note:*** digits will be loaded into this array in REVERSE order!)
	mov		[edi], edx
	add		edi, 4
	jmp		converter

	last_digit:
	;load the last digit
	add		edx, 48
	mov		[edi], edx

	;store the contents of the counter - this will tell the parent function how many numbers were separated
	mov		edx, [ebp+20]			
	mov		[edx], ecx					;update parsedCount


	popad
	pop		ebp
	ret		16
separateDigits ENDP

END main



