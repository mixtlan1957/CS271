 TITLE Program Template     (project5.asm)

; Author: Mario Franco-Munoz
; Course / Project ID                Due Date: 11/19/2017
; Description: This program prompts the user to enter a number of 
; random numbers to be generated. Program then generates the random numbers
; calculates and displays the median and displays the sorted list.

INCLUDE Irvine32.inc

HI_RAND = 999
LOW_RAND = 10
MIN_IN = 10
MAX_IN = 200
NUMS_PER_ROW = 10

.data

title1		BYTE	"Sorting Random Integers                   Ptrogrammed by Mario Franco-Munoz",0
intro1		BYTE	"This program generates random numbers in the range [100 .. 999],",0
intro2		BYTE	"displays the original list, sorts the list, and calculates the",0
intro3		BYTE	"median value. Finally, it displays the list sorted in descending order.",0
prompt1		BYTE	"How many numbers should be generated? [10 .. 200]: ",0
error1		BYTE	"Invalid input",0
unsorted	BYTE	"The unsorted random numbers:",0
sorted		BYTE	"The sorted list:",0
median		BYTE	"The median is ",0
extraCred1	BYTE	"**EC2: Use a recursive sorting algorithm. (Used recursive bubble sort).", 0

randArr		DWORD 200 DUP(?)



.code
main PROC
;call randomize in order to use random range Irvine32 procedure
call	Randomize



;introduction section
push	OFFSET intro3
push	OFFSET intro2
push	OFFSET intro1
push	OFFSET title1
call	introduction


;getData section
push	OFFSET error1
push	OFFSET prompt1
call	getData

;fill array section
push	OFFSET randArr
call	fillArray

;display unsorted array section
push	OFFSET unsorted
push	OFFSET randArr
call	displayList

;sort array section
mov		ecx, eax			;preload the recursive loop flag
push	eax
push	OFFSET randArr
call	sortList
pop		eax

;display median section
push	OFFSET median
push	OFFSET randArr
call	displayMedian

;display sorted array section
push	OFFSET sorted
push	OFFSET randArr
call	displayList



	exit	; exit to operating system
main ENDP

;---------------------------------------------------------
; introduction
;
; Introduction to random generator and sorter (project5) program. 
; Displays title and provides initial description of program.
; Preconditions: address of statements must be pushed on the stack.
; Recieves:	None
; Returns:	None
;---------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp

	;title display
	mov		edx, [ebp+8]
	call	WriteString
	call	CRLF

	;First introduction line
	mov		edx, [ebp+12]
	call	WriteString
	call	CRLF

	;Second introduction line
	mov		edx, [ebp+16]
	call	WriteString
	call	CRLF

	;third introduction line
	mov		edx, [ebp+20]
	call	WriteString
	call	CRLF

	;display extra credit statement
	mov		edx, OFFSET extraCred1
	call	WriteString

	call	CRLF
	call	CRLF

	pop		ebp
	ret		16
introduction ENDP

;---------------------------------------------------------
; getData 
;
; getData requests that the user enter a number between 10 and 200
; signifying the number of random numbers to be generated. If number
; entered is not within the specified range, the user is re-prompted to enter
; a valid entry. User input (number of random numbers to be generated) is then
; stored in the EAX regester
; Preconditions: address of statements must be pushed on the stack
; Recieves:	None
; Returns:	EAX - (request - number of random numbers value)
;---------------------------------------------------------
getData PROC
	push	ebp
	mov		ebp, esp

	validate_loop:
		;prompt the user to enter a number between 10 and 200
		mov		edx, [ebp+8]
		call	WriteString
	
		;read user input
		mov		eax, 0					;ensure that eax is cleared
		call	ReadInt

		;validate user input
		cmp		eax, MIN_IN
		jl		invalid
		cmp		eax, MAX_IN
		jg		invalid
		jmp		endDoWhile

		;if user input is invalid - reprompt
		invalid:
			mov		edx, [ebp+12]
			call	WriteString
			call	CRLF
			jmp		validate_loop

	endDoWhile:
		call	CRLF
		;EAX contains validated user input
	pop		ebp
	ret		8
getData ENDP

;---------------------------------------------------------
; fillArray
;
; fillArray uses the Irvine32 procedure "RandomRange" to fill
; the predefined randArr with random numbers with a number of random numbers
; equal to that selected by the user
; Preconditions: number of random numbers to be generated needs to be in EAX register
; prior to calling fillArray
; Recieves:	EAX (request - number of random numbers value)
; Returns:	None
;---------------------------------------------------------
fillArray PROC
	push	ebp
	mov		ebp, esp

	;set the loop counter & save the user's choice
	mov		ecx, eax
	push	eax

	;load the array
	mov		esi, [ebp+8]

	;forloop to populate array with elements
	forloop_marker:
		mov		eax, HI_RAND
		inc		eax
		sub		eax, LOW_RAND
		call	RandomRange
		mov		[esi], eax
		add		esi, 4
	loop	forloop_marker

	pop		eax
	pop		ebp
	ret		4
fillArray ENDP

;---------------------------------------------------------
; sortArray
;
; sortArray uses the bubblesort algorithm to recursively sort the contents
; of the array. This function is based on the C/C++ code found at:
; "http://www.geeksforgeeks.org/recursive-bubble-sort/" implemented into assembely code by me.
; Preconditions: Address of array to be sorted needs to be passed
; by reference on the system stack.
; Recieves:	ECX (request - number of random numbers value)
; Returns:	None
;---------------------------------------------------------
sortList PROC
	push	ebp
	mov		ebp, esp
	
	;load array
	mov		esi, [ebp+8]

	;body of recursive function
	cmp		ecx, 1
	je		endRecursive_call
	push	esi

	;save contents of outer recusrive loop
	push	ecx
	dec		ecx
	;inner bubble sort loop
	inner:
		mov		eax, [esi]
		mov		ebx, [esi+4]
		cmp		eax, ebx
		jle		no_swap	
		;if the next element in the array is larger than the previous element, swap values.
		;edx is used as a placeholder, eax contains element n and ebx contains n+1
		mov		edx, eax
		mov		eax, ebx
		mov		ebx, edx
		mov		[esi], eax
		mov		[esi+4], ebx

		no_swap:
		add		esi, 4				;increment the array pointer
	loop	inner
	
	;restore and decrement ecx for outer recursive loop
	pop		ecx
	dec		ecx

	;reset the stack
	call	sortList				;recursive function call
	endRecursive_call:
	pop		ebp
	ret		4
sortList ENDP

;---------------------------------------------------------
; displayList
;
; displayList outputs the contents of the array of generated values.
; Preconditions: Address of array to be sorted needs to be passed
; by reference on the system stack.
; Recieves:	EAX (request - number of random numbers value)
; Returns:	None
;---------------------------------------------------------
displayList PROC
	push	ebp
	mov		ebp, esp

	;set the loop counter & save EAX's value
	mov		ecx, eax
	push	eax

	;load array
	mov		esi, [ebp+8]

	;output statement
	mov		edx, [ebp+12]
	call	WriteString
	call	CRLF

	;print contents of array
	mov		ebx, 0					; use ebx to keep track of how return statement
	for_loop_header:
		inc		ebx
		mov		eax, [esi]		
		call	WriteDec
		mov		eax, 0
		mov		al, 9
		call	WriteChar

		;check if a return is necessary
		cmp		ebx, NUMS_PER_ROW
		jne		no_return
		mov		ebx, 0
		call	CRLF

		no_return:
		;increment esi
		add		esi, 4
	loop	for_loop_header
	
	call	CRLF
	call	CRLF

	pop		eax
	pop		ebp
	ret		8
displayList ENDP

;---------------------------------------------------------
; displayMedian
;
; displayMedian outputs the median of the populated and sorted array.
; Preconditions: address of sorted array needs to be pushed on the stack.
; Recieves:	EAX (request - number of random numbers value)
; Returns:	None
;---------------------------------------------------------
displayMedian PROC
	push	ebp
	mov		ebp, esp

	;load array
	mov		esi, [ebp+8]

	;display output message
	mov		edx, [ebp+12]
	call	WriteString
	;save contents of eax and output space character
	push	eax
	mov		eax, 0
	mov		al, 32
	call	WriteChar
	pop		eax

	;find the median
	;first check to see if number of elements is odd or even
	push	eax					;save user input
	mov		ebx, 2
	cdq
	div		ebx
	cmp		edx, 0
	jne		odd

	;load the index'd value
	mov		ebx, 4
	mul		ebx
	add		esi, eax
	
	;find the average of the two middle values
	mov		eax, [esi]
	add		eax, [esi-4]
	mov		ebx, 2
	cdq
	div		ebx
	
	;check if rounding is necessary
	cmp		edx, 0
	je		noRound
	;if rounding is necessary increment by 1 since, decimal portion will always be .5 since we are dividing by 2
	inc		eax

	noRound:
	jmp		endcase

	;if number of elements to find the median is odd, then the index is simply the result of the division
	odd:
	mov		ebx, 4
	mul		ebx
	add		esi, eax
	mov		eax, [esi]

	endcase:
	call	WriteDec
	pop		eax						;restore user input

	;display period and return
	push	eax
	mov		eax, 0
	mov		al, 0
	call	WriteChar
	pop		eax
	call	CRLF
	call	CRLF

	pop		ebp
	ret		8
displayMedian ENDP

END main
