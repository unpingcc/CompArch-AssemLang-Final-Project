TITLE PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures (Proj6_UNPINGCC.asm)

; Author: Cassidy Unpingco
; Last Modified: 6/07/2022
; OSU email address: UNPINGCC@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date:6/7/2022
; Description: This program utilizes two macros and several procedures to produce an array of signed 10 user entered numbers and outputs them for display, displays 
; the truncated average as well as the sums. The assignment is designed to utilize low level i/o like string primitives and builds upon everything we've learned in
;this course.

INCLUDE Irvine32.INC

; (insert macro definitions here)
mGetString MACRO UserPromptAddress, Buffer, LengthOfBuff
;--------------------------------------------------------------------------
;Name:mGetString
;Preconditions: recieves UserPromptAddress, Buffer, LengthOfBuff
;Postconditions: Registers edx and ECX are modified and cleared
;Receives; UserPromptAddress, Buffer, LengthOfBuff
;Returns reads string based on recieved input
;--------------------------------------------------------------------------
; display prompt (Input param, ref) 
; input user keyboard entry into mem ( ouput param, ref) 
;counter (input param, by value) for len of string 
	PUSH	EDX
	PUSH	ECX
	MOV		EDX, UserPromptAddress
	CALL	WriteString
	MOV		EDX, Buffer
	MOV		ECX, LengthOfBuff
	CALL	ReadString
	POP		ECX
	POP		EDX

ENDM

mDisplayString MACRO AddressString
;--------------------------------------------------------------------------
;Name: mDisplayString
;Preconditions an addressString must be passed to maco 
;Postconditions: makes changes to edx and clears edx
;Receives: AddressString
;Returns a written string for display
;--------------------------------------------------------------------------
;print string 
	PUSH	EDX
	MOV		EDX, AddressString
	CALL	WriteString
	POP		EDX

ENDM
ARRAYSIZE = 10
HIGHRANGE = 2147483647 ;(2^31 -1) 
LOWRANGE  =	-2147483647 ;(-2^31) 
ASCII_LO  = 48
ASCII_HI  =	57
ASCII_P	  = 43
ASCII_N	  = 45
USERSIZE  = 11


.data

TitleLabel		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 10,13, "Written by Cassidy Unpingco",10,13,10,13,0
ProgInstruc		BYTE	"Please provide 10 signed decimal integers.", 10,13, "Each number needs to be small enough to fit inside a 32 bit register.", 10,13, "After you have finished inputting the raw numbers I will display a", 10,13, "list of the integers, their sum, and their average value." ,10,13,10,13,0 
SignNumEntry	BYTE	"Enter a signed number:",0 
ErrorAlert		BYTE	"You did not enter a signed number or your number was too large.", 10,13, "Please try again:",0 
NumsEntered		BYTE	"You entered the following numbers:", 0 
NumSum			BYTE	10,13,"The sum of these numbers is: ", 0 
TruncAvg		BYTE	10,13,"The truncated average is: ", 0 
ThxBye			BYTE	10,13,"Thanks for playing!", 0
Spacer			BYTE	", ",0
NegVal			DWORD	?
UserArray		SDWORD	ARRAYSIZE DUP(?)



.code
main PROC

	PUSH	OFFSET TitleLabel
	PUSH	OFFSET ProgInstruc
	CALL	StartProgram
	PUSH	OFFSET UserArray
	PUSH	LENGTHOF UserArray
	PUSH	OFFSET SignNumEntry
	PUSH	OFFSET NegVal
	PUSH	OFFSET ErrorAlert
	CALL	GetUserInput
	
	PUSH	OFFSET	UserArray
	PUSH	LENGTHOF UserArray
	PUSH	OFFSET	NumsEntered
	PUSH	OFFSET	Spacer
	CALL	DisplayNumsEntered

	PUSH	OFFSET	UserArray
	PUSH	LENGTHOF UserArray
	PUSH	OFFSET NumSum
	PUSH	OFFSET TruncAvg
	CALL	SumTrunc

	PUSH	OFFSET ThxBye
	CALL	Farewell
	
	Invoke ExitProcess,0	; exit to operating system
main ENDP

StartProgram PROC USES EDX
	PUSH	EBP 
	MOV		EBP, ESP 
	MOV		EDX, [EBP +16] ;TITLEINTRO 16
	mDisplayString	EDX
	MOV		EDX, [EBP +12] ; 12
	mDisplayString	EDX
	POP		EBP
	RET		8
	
StartProgram ENDP

GetUserInput PROC	USES ESI ECX EAX
;--------------------------------------------------------------------------
;This procedure creates a stack and sets up the loop for ReadVal 
;convert using string primitives the strng of ASCII digits to its numeric value rep
;validate user input as valid 
;store in mem (output param, ref
;Name: GetUserInput 
;Preconditions CALLs ReadVal Procedure, Array must be set up to handle the input of the program 
;Postconditions: USES ESI ECX EAX
;Receives; length of array, empty array, prompts, error message, neg val.
;Returns None
;--------------------------------------------------------------------------
	PUSH	EBP
	MOV		EBP, ESP 
	MOV		ESI, [EBP+36] 
	MOV		ECX, [EBP + 32] ;LENGTHOF ARRAY 
	viewArray:
			MOV		EAX, [EBP + 28] ;Prompt
			PUSH	EAX
			PUSH	[EBP +24] ;NegVal
			PUSH	[EBP + 20] ;ERROR MSG

			CALL	ReadVal
			POP		[ESI]
			ADD		ESI, 4
			LOOP	viewArray
	POP		EBP
	RET		20
GetUserInput ENDP


ReadVal PROC USES	EAX EBX
;--------------------------------------------------------------------------
;;invoke mGetString 
;convert using string primitives the string of ASCII digits to its numeric value rep
;validate user input as valid 
;store in mem (output param, ref
;Name: ReadVal 
;Preconditions USES	EAX EBX, LOCAL variable UserNum dictated by USERSIZE CONSTANT, AND ValidNum
;Postconditions: MODIFIES REGISTERS AND CALLS UPON VALIDATENUMS PROCEDURE
;Receives; USERSIZE CONSTANT, USER INPUT
;Returns NONE
;--------------------------------------------------------------------------

	LOCAL UserNum[USERSIZE]: BYTE, ValidNum: SDWORD 
	PUSH	ESI
	PUSH	ECX
	MOV		EAX, [EBP + 16] 
	LEA		EBX, UserNum
	readLoop: 
		
		mGetString		EAX, EBX, LENGTHOF UserNum
		MOV				EBX, [EBP +8] 
		PUSH			EBX
		LEA				EAX, ValidNum
		PUSH			EAX
		LEA				EAX, UserNum
		PUSH			EAX
		PUSH			LENGTHOF UserNum
		CALL			ValidNumbers
		POP				EDX
		MOV				[EBP+16], EDX
		MOV				EAX, ValidNum
		CMP				EAX, 1
		MOV				EAX, [EBP+12]
		LEA				EBX, UserNum
		JNE				readLoop
		JMP				_end
_end: 
		POP		ECX
		POP		ESI
		RET		8
ReadVal ENDP 

ValidNumbers	PROC USES ESI ECX	EAX	EDX
;ValidNumbers is part of ReadVal in that it validates the input recieved by the user. 
;If input is valid it then CALLs upon a converter to convert the str to ints.
;Name: ValidNumbers
;Preconditions  USES ESI ECX	EAX	EDX LOCAL variable NumTooBig to track size of input
;Postconditions: Changes NegVal to account for any sign changes for input
;Receives; USERSIZE CONSTANT, USER INPUT
;Returns int values into the array
;--------------------------------------------------------------------------

	LOCAL	NumTooBig:SDWORD

		MOV		ESI, [EBP +12]
		MOV		ECX, [EBP+8]
		CLD
		MOV		EBX, 0

		LODSB
		CMP				AL, ASCII_N
		JE				_NegFlag
		cmp				AL, ASCII_P
		JE				_PosFlag
		JMP				_LoadString
		
_NegFlag: 
		push	EBX
		mov		EBX, 1	
		pop		EBX
		dec		ECX
		JMP		_NextPartofString

_PosFlag:
		push	EBX
		mov		EBX, 1	
		pop		EBX
		dec		ECX

_NextPartofString: 
		LODSB
		

_LoadString:
		CMP		AL, 0 
		JE		_SwitchingToInt
		CMP		AL, ASCII_LO
		JL		_invalidInput
		CMP		AL, ASCII_HI
		JA		_invalidInput
		LOOP	_LoadString
		JMP		_SwitchingToInt

_invalidInput:
	MOV		EDX, [EBP+20] 
	mDisplayString	EDX
	MOV		EDX, [EBP +16] 
	MOV		EAX, 0 
	MOV		[EDX], EAX
	JMP		_recordVal

_SwitchingToInt:
		MOV		EDX, [EBP +8] 
		CMP		ECX, EDX
		JE		_invalidInput
		LEA		EAX, NumTooBig
		MOV		EDX, 0 
		MOV		[EAX], EDX
		PUSH	[EBP+12] 
		PUSH	[EBP +8] 
		LEA		EDX, NumTooBig
		PUSH	EDX
		CALL	ConversionToNum
		MOV		EDX, NumTooBig
		CMP		EDX, 1
		JE		_invalidInput
		MOV		EDX, [EBP+16]
		MOV		EAX, 1
		MOV		[EDX],EAX

_recordVal:
	POP		EDX
	MOV		[EBP+20], EDX
	RET		12

ValidNumbers ENDP

ConversionToNum PROC USES ESI ECX EAX EBX EDX 

	LOCAL Number: SDWORD
	MOV		ESI, [EBP +16] 
	MOV		ECX, [EBP+12]
	LEA		EAX, Number
	XOR		EBX, EBX
	MOV		[EAX], EBX
	XOR		EAX, EAX
	XOR		EDX, EAX
	CLD 
	 
_LoadDigits:
	LODSB

	CMP		EAX, 0
	je		_endInsertion
	CMP		EAX, ASCII_N
	JE		_CONTINUE
	CMP		EAX, ASCII_P
	JE		_CONTINUE
	SUB		EAX, ASCII_LO
_CONTINUE:
	MOV		EBX, EAX
	MOV		EAX, Number
	MOV		EDX, 10 
	mul		EDX
	jc		_tooLargeNumber ; check for carry after multiply
	ADD		EAX, EBX ;ADD the digit to the converted value
	jc		_tooLargeNumber 
	MOV		Number, EAX ; store temporary value from EAX
	MOV		EAX, 0 
	LOOP	_LoadDigits

_endInsertion:
	MOV		EAX, Number
	MOV		[EBP + 16], EAX ; move converted value to stack
	JMP		_finishedHere

; change isTooLarge if value does not fit in 32-bit register

_tooLargeNumber:
	MOV		EBX, [EBP + 8] ; isTooLarge is at [EBP + 8]
	MOV		EAX, 1 ; set isTooLarge to true
	MOV		[EBX], EAX
	MOV		EAX, 0
	MOV		[EBP + 16], EAX
_finishedHere:
	RET		8
ConversionToNum ENDP

WriteVal PROC USES EAX
;--------------------------------------------------------------------------
;This procedure writes the values of the result string and CALLs upon 
;the display macro to print the value. 
;convert numeric SDWROD value (input param, by value) to a string of ASCII digits
;invoke mDisplayString to print the ASCII rep 
;Name: WriteVal
;Preconditions USES EAX, Proc SwitchtoStr, signs are effectively checked in order
;to print strings appropriately.
;Postconditions: EAX and result string are moved into registers
;Receives: result string
;Returns EAX value
;--------------------------------------------------------------------------
	LOCAL resultString[USERSIZE]:BYTE
	LEA		EAX, resultString
	PUSH	EAX
	PUSH	[EBP + 8]
	CALL	SwitchToStr
	LEA		EAX, resultString
	mDisplayString EAX ; print the value
	RET		4

WriteVal ENDP

SwitchToStr PROC USES EAX EBX ECX
LOCAL	holdChar:SDWORD
;  division of integer by 10
	MOV		EAX, [EBP + 8]
	MOV		EBX, 10
	MOV		ECX, 0
	CLD
; counts the value of digits


; pushs the digits in reverse order

_divTen:
	CDQ
	DIV		EBX
	PUSH	EDX
	CLD
	INC		ECX ;increment the value of ECX
	CMP		AL, ASCII_N
	JE		_SignChar
	CMP		AL, ASCII_P
	JE		_SignChar
	CMP		EAX, 0 
	JNE		_divTen
	MOV		edi, [EBP + 12] ; move into destination char array
	JMP		_LoadChar	
;store the character in the array

_SignChar: 
	CALL	WriteChar
	POP		EAX
	SUB		ECX, 1
	CLD

	JMP		_divTen

_LoadChar:
	POP		holdChar
	MOV		AL,  BYTE PTR holdChar
	ADD		AL, 48
	STOSB
	LOOP	_LoadChar
	MOV		AL, 0
	STOSB
	RET		8
 SwitchToStr ENDP


 DisplayNumsEntered PROC	USES ESI EBX ECX EDX 
 ;--------------------------------------------------------------------------
;This procedure displays the the array of input for the user utilizing the mDisplayString MACRO
;Name: DisplayNumsEntered
;Preconditions USES ESI EBX ECX EDX, WriteVal Procedure is CALLed to loop through values
;Postconditions: EAX and result string are moved into registers
;Receives: result string, array 
;Returns display string and array of inputes
;--------------------------------------------------------------------------
 
	PUSH	EBP
	MOV		EBP, ESP 
	MOV		EDX, [EBP+28] 
	mDisplayString	EDX
	MOV		ESI, [EBP +36] 
	MOV		ECX,[EBP +32]
	MOV		EBX, 1

_displayValue:
	PUSH	[ESI]
	CALL	WriteVal ;CALL the procedure WriteVal
	ADD		ESI, 4
	CMP		EBX, [EBP + 32]
	JGE		_endDisplayList
	MOV		EDX, [EBP + 24] ;spacer
	mDisplayString EDX
	INC		EBX
	LOOP _displayValue

_endDisplayList:
	CALL	Crlf
	POP		EBP
	RET		16
 DisplayNumsEntered ENDP

 ;------------------------------------------------------------------------------
; Procedure SumTrunc displays the sum and truncated average of an array of integers.
;Name: WriteValSumTrunc
;Preconditions USES ESI EDX ECX EAX ebx Array needs to be filled and passed to this proc
;Postconditions: xor is used to clear overflow and carry flags
;Receives; Array of user input
;Returns Sum and Trunc Average
;--------------------------------------------------------------------------
;------------------------------------------------------------------------------
SumTrunc PROC USES ESI EDX ECX EAX ebx

	PUSH	EBP
	MOV		EBP, ESP
	MOV		EDX, [EBP + 32] ; 
	mDisplayString EDX
	MOV		ESI, [EBP + 40] ; array value at [EBP + 40]
	MOV		ECX, [EBP + 36] ; LENGTHOF array is present at [EBP + 36]
	XOR		EAX, EAX ; perform XOR to clear overflow and carry flags

_summedValues:
	ADD		EAX, [ESI]
	ADD		ESI, 4
	loop	_summedValues
	
	PUSH	EAX	;display sum
	CALL	WriteVal
	CALL	Crlf

; calculate and display average
	MOV		EDX, [EBP + 28] 
	mDisplayString	EDX
	CDQ
	MOV		ebx, [EBP + 36] ; LENGTHOF userarray is presnt at[EBP + 36]
	DIV		ebx 
	PUSH	EAX
	CALL	WriteVal ; CALL WriteVal to print the value
	CALL	Crlf
	POP		EBP
	RET		16
SumTrunc ENDP
;---------------------------------------------------------------
; Procedure Farewell displays the program exit message.;
;Name: Farewell
;Preconditions String has been pushed to the stack
;Postconditions: Utilizes
;Receives; String 
;Returns: Farewell String
;---------------------------------------------------------------
 Farewell PROC USES EDX
	PUSH	EBP
	MOV		EBP, ESP
	CALL	Crlf
	MOV		EDX, [EBP + 12]
	mDisplayString EDX
	CALL	Crlf
	POP		EBP
	RET		4
Farewell ENDP



END main


