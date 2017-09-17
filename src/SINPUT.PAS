{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* Support for Keybord and Mouse event handling                             *}
{****************************************************************************}
Unit SInput;
  {$F+,O-,Q-,R-,S-}

Interface
	Uses Objects, sBasic, sInts, sTypes;

{**þ KEYBORD MANAGER þ***************************************************** }

{ ***þ Keybord key record for typecasting þ*** }
type
	TKbKey = record
		Case Integer of
			0 : (KeyCode :Word);
			1 : (CharCode :Char;
					 ScanCode :Byte);
	end;

{***þ Keybord Event Flag  þ***}
const
	inKeyDown         = $0100;     { Key was pressed  }
	inKeyUp           = $0200;     { Key was released }
	inkbStateChanged  = $0400;     { Keybord state changed }

{***þ Extended Keybord Codes þ***}
const
	kbNoKey     = $0000;

	kbUp        = $4800;
	kbDown      = $5000;
	kbLeft      = $4B00;  kbCtrlLeft  = $7300;
	kbRight     = $4D00;  kbCtrlRight = $7400;

	kbIns       = $5200;
	kbDel       = $5300;
	kbHome      = $4700;  kbCtrlHome  = $7700;
	kbEnd       = $4F00;  kbCtrlEnd   = $7500;
	kbPgUp      = $4900;  kbCtrlPgUp  = $8400;
	kbPgDn      = $5100;  kbCtrlPgDn  = $7600;

	kbEsc       = $011B;
	kbTab       = $0F09;
	kbBack      = $0E08;  kbCtrlBack  = $0E7F;
	kbSpace     = $3920;
	kbEnter     = $1C0D;  kbCtrlEnter = $1C0A;

	kbGrayMinus = $4A2D;
	kbGreyMul   = $372A;
	kbGrayPlus  = $4E2B;

												 { Function Keys }
	kbF1    = $3B00;  kbAltF1  = $6800;  kbCtrlF1  = $5E00; kbShiftF1  = $5400;
	kbF2    = $3C00;  kbAltF2  = $6900;  kbCtrlF2  = $5F00; kbShiftF2  = $5500;
	kbF3    = $3D00;  kbAltF3  = $6A00;  kbCtrlF3  = $6000; kbShiftF3  = $5600;
	kbF4    = $3E00;  kbAltF4  = $6B00;  kbCtrlF4  = $6100; kbShiftF4  = $5700;
	kbF5    = $3F00;  kbAltF5  = $6C00;  kbCtrlF5  = $6200; kbShiftF5  = $5800;
	kbF6    = $4000;  kbAltF6  = $6D00;  kbCtrlF6  = $6300; kbShiftF6  = $5900;
	kbF7    = $4100;  kbAltF7  = $6E00;  kbCtrlF7  = $6400; kbShiftF7  = $5A00;
	fkbF8    = $4200;  kbAltF8  = $6F00;  kbCtrlF8  = $6500; kbShiftF8  = $5B00;
	kbF9    = $4300;  kbAltF9  = $7000;  kbCtrlF9  = $6600; kbShiftF9  = $5C00;
	kbF10   = $4400;  kbAltF10 = $7100;  kbCtrlF10 = $6700; kbShiftF10 = $5D00;

	kbAlt1  = $7800;
	kbAlt2  = $7900;
	kbAlt3  = $7A00;
	kbAlt4  = $7B00;
	kbAlt5  = $7C00;
	kbAlt6  = $7D00;
	kbAlt7  = $7E00;
	kbAlt8  = $7F00;
	kbAlt9  = $8000;
	kbAlt0  = $8100;

	kbAltA  = $1E00;  kbCtrlA  = $1E01;
	kbAltB  = $3000;  kbCtrlB  = $3002;
	kbAltC  = $2E00;  kbCtrlC  = $2E03;
	kbAltD  = $2000;  kbCtrlD  = $2004;
	kbAltE  = $1200;  kbCtrlE  = $1205;
	kbAltF  = $2100;  kbCtrlF  = $2106;
	kbAltG  = $2200;  kbCtrlG  = $2207;
	kbAltH  = $2300;  kbCtrlH  = $2308;
	kbAltI  = $1700;  kbCtrlI  = $1709;
	kbAltJ  = $2400;  kbCtrlJ  = $240A;
	kbAltK  = $2500;  kbCtrlK  = $250B;
	kbAltL  = $2600;  kbCtrlL  = $260C;
	kbAltM  = $3200;  kbCtrlM  = $320D;
	kbAltN  = $3100;  kbCtrlN  = $310E;
	kbAltO  = $1800;  kbCtrlO  = $180F;
	kbAltP  = $1900;  kbCtrlP  = $1910;
	kbAltQ  = $1000;  kbCtrlQ  = $1011;
	kbAltR  = $1300;  kbCtrlR  = $1312;
	kbAltS  = $1F00;  kbCtrlS  = $1F13;
	kbAltT  = $1400;  kbCtrlT  = $1414;
	kbAltU  = $1600;  kbCtrlU  = $1615;
	kbAltV  = $2F00;  kbCtrlV  = $2F16;
	kbAltW  = $1100;  kbCtrlW  = $1117;
	kbAltX  = $2D00;  kbCtrlX  = $2D18;
	kbAltY  = $1500;  kbCtrlY  = $1519;
	kbAltZ  = $2C00;  kbCtrlZ  = $2C1A;

	kbAltEqual = $8300; kbAltMinus  = $8200;

	kbShiftTab  = $0F00;
	kbPrintScr  = $FE00;
	kbCtrlBreak = $FF00;
	kbCtrlPrtSc = $7200;

{***þ Keybord Shift State Flags þ***}
	ksNone      = $00;
	ksRShift    = $01;
	ksLShift    = $02;
	ksShift     = $03;
	ksCtrl      = $04;
	ksAlt       = $08;
	ksScroll    = $10;
	ksNum       = $20;
	ksCaps      = $40;
	ksInsert    = $80;
	ksAllShifts = $0F;
	ksAllStates = $F0;
	ksAll       = $FF;

{***þ Keybord Object controller þ***}
type
	TKeybord = Object(TObject)
		constructor Init;
		destructor Done; virtual;
		function   ReadKey :Word;
		function   WaitKey :Word;
		function   ReadUpCase :Word;
		function   WaitUpCase :Word;
		function   ReadLegal(Legal :TCharSet) :Word;
		function   WaitLegal(Legal :TCharSet) :Word;
		function   Pressed :Boolean;
		function   StatesOn(Flags :Byte) :Boolean;
		function   StateOn(Flags :Byte) :Boolean;
		function   GetState :Byte;
		procedure  SetState(Flags :Byte; On :Boolean);
		procedure  ClearBuf;
		procedure  PushKey(Key :Word);
		procedure  SetTypeRate(Rate, Delay :Byte);
		procedure  ToggleState(Flags :Byte);
	end;

{ ***þ The keybord controlller þ*** }
var
	Keybord :TKeybord;

{ ***þ Status of the keybord þ*** }
var
	KeybState :Byte absolute $0000:$0417;


{**þ MOUSE MANAGER þ******************************************************* }

{***þ Mouse Button State Masks  þ***}
const
	mbLeft   = $01;  { Left   Button is down }
	mbRight  = $02;  { Right  Button is down }
	mbCenter = $04;  { Center Button is down }

{***þ Mouse Input Masks  þ***}
	inMouseMove   = $0001;  { Mouse Movement }
	inMouseLD     = $0002;  { Left   Button was pressed  }
	inMouseLU     = $0004;  { Left   Button was released }
	inMouseRD     = $0008;  { Right  Button was pressed  }
	inMouseRU     = $0010;  { Left   Button was released }
	inMouseCD     = $0020;  { Center Button was pressed  }
	inMouseCU     = $0030;  { Center Button was released }
	inMouseDown   = $002A;  { A Button was pressed  }
	inMouseUp     = $0054;  { A Button was released }
	inMouseButton = $007E;  { A button was pressed or released }

{***þ Initialized variables þ***}
const
	MouseAvail   :Boolean = False;    { Indicate if a mouse is available   }
	MouseBCount  :Byte = 0;           { The amount of buttons on the mouse }
	MouseReverse :Boolean = False;    { Switch button 1 and button 3       }
	MouseDDelay  :Word = 6;           { Double-Click time interval         }

{***þ Mouse Status variables þ***}
var
	MouseWhere   :TPoint;    { Position of the Mouse Pointer               }
	MouseButtons :Byte;      { Tells which buttons is depressed            }
	MouseEvent   :Word;      { The kind of interrupt that occured          }
	MouseDouble  :Boolean;   { Indicates if a double click occurred or not }
	MouseIntFlag :Boolean;   { Set to true if a mouse event occurred       }

{***þ Mouse control Routines  þ***}

  { Initializes the mouse driver by enabling the mouse interrupt handler
    and showing the mouse pointer. }
	procedure InitMouse;
  { Terminates the Mouse driver by disabling the mouse interrupt handler and
    hiding the mouse }
	procedure DoneMouse;
  { Shows the Mouse Pointer }
	procedure ShowMouse;
  { Hides the Mouse Pointer }
	procedure HideMouse;
  { Move the Mouse Pointer to the specified Location }
	procedure SetMousePos(X, Y :Integer);


{**þ INPUT MANAGER þ*********************************************************}

{***þ Input Interrupt Masks þ***}
const
	inNothing = $0000; { No Input }
	inMouse   = $00FF; { Mouse Input }
	inKeybord = $0F00; { Keybord Input }

{***þ Keybord Input transfer record þ***}
type
	TKeybordInput = record
		What :Word;
		Case Word of
			inNothing :(HandledBy :Pointer);
			inKeybord :(
				ShiftState :Byte;
				Case Integer of
					0 : (KeyCode :Word);
					1 : (CharCode :Char;
							 ScanCode :Byte)
      );
	end;

{***þ Mouse Input transfer record þ***}
type
  TMouseInput = record
    What :Word;
    Case Word of
      inNothing :(HandledBy :Pointer);
      inMouse   :(
        Where   :TPoint;
        Buttons :Byte;
        Double  :Boolean;
      );
  end;

{***þ Routines þ***}
  { Initializes the Input Manager }
	procedure InitInput;
  { Shuts down the Input Manager }
	procedure DoneInput;
  { Obtains keybord Input, returning the result in Input
    If wait is true the procedure waits until a key becomes available.
    If Upcase is true, the CharCode field of Input is converted to Uppercase }
	procedure GetKeyInput(var Input :TKeybordInput; Wait, Upcase :Boolean);
  { Same as GetKeyInput, but ignoring input which Charcode is not contained
    in Legal }
	procedure GetLegalKeyInput(var Input :TKeybordInput; Wait, Upcase :Boolean;
                             Legal :TCharSet);
  { Obtaines the Current Mouse State as Input }
	procedure GetMouseInput(var Input :TMouseInput);
  { Does the same as GetMouseInput then returns true if Mask match
    Input.What }
	function  MouseInputMatch(var Input :TMouseInput; Mask :Word) :Boolean;
  { Does the same as MouseInputMatch, but to return true, the Mouse Pointer
    has to be within the area Bounds }
  function  MouseInputMatchIn(var Input :TMouseInput; Mask :Word;
                         Bounds :TBounds) :Boolean;


Implementation

{**þ KEYBORD þ***************************************************************}

{ The Previous state of the Control-Break Flag in Dos }
var
	LastDosCBreak :Boolean;

{__Keybord Interrupt Handlers________________________________________________}
procedure Push_PrintScr_Key;
begin
	Keybord.PushKey(kbPrintScr);
end;

procedure Push_CtrlBreak_Key;
begin
	Keybord.PushKey(kbCtrlBreak);
end;

 { Control-Break Interrupt Handler }
Procedure IHCtrlBreak; assembler;
asm
	{ Save Registers to Modify }
	PUSH  DS
	PUSH  AX
	PUSH  BX
	{ Push kbCtrlBreak on the keybord data stream }
	MOV   BX, SEG @DATA
	MOV   DS, BX
	CALL  Push_CtrlBreak_Key
	{ Restore Rgisters }
	POP   BX
	POP   AX
	POP   DS
	{ Return from interrupt }
	IRET
end; { IHCtrlBreak }

	{ Control-C Interrupt Handler }
Procedure IHCtrlC; assembler;
asm
	IRET      { Does nothing - Program does not terminate however }
end; { IHCtrlC }

{***þ Constants for Installing and removing interrupt handlers þ***}
const
  HCtrlBreak :TIntHandler =
    (Vector :vecCtrlBreak; Address :@IHCtrlBreak);
	HCtrlC :TIntHandler =
    (Vector :vecCtrlC; Address :@IHCtrlC);

{__TKeybord Implementation___________________________________________________}
constructor TKeybord.Init;
begin
	Inherited Init;
	{ Install Interrupt Handlers }
	InitHandler(HCtrlBreak);
	InitHandler(HCtrlC);
	{ Set the Dos Break flag to off }
	LastDosCBreak := GetDosCBreak;
	SetDosCBreak(False);
	{ Clear the keybord buffer }
	ClearBuf;
end; { TKeybord.Init }

destructor TKeybord.Done;
begin
	{ Uninstall Interrupt handlers }
	DoneHandler(HCtrlC);
	DoneHandler(HCtrlBreak);
	{ Set original Dos Break State }
	SetDosCBreak(LastDosCBreak);
	{ Clear the keybord buffer }
	ClearBuf;
	inherited done;
end; { TKeybord.Done }

	{ Reads input from the keybord - If a key has been pressed, it is
		returned as result. Otherwise, kbNoKey is returned  }
function TKeybord.ReadKey :Word; assembler;
asm
	{ Check keybord status }
	MOV   AH, 01H
	INT   IntKeybord
	{ If Zero flag is set then no key was available }
	JZ    @NoKey
	{ Get the key that was available }
	MOV   AH, 00H
	INT   IntKeybord
	JMP   @End
	{ Result is kbNoKey }
@NoKey:
	MOV   AX, kbNokey
@End:
end; { TKeybord.ReadKey }

	{ Waits for key to be pressed on the keybord and return it as result }
function TKeybord.WaitKey :Word; assembler;
asm
	{ Get Keybord key  }
	MOV   AH, 00H
	INT   IntKeybord
end; { TKeybord.WaitKey }

  { Calls ReadKey and then ensures a uppercase Charcode }
function TKeybord.ReadUpCase :Word;
	var Key :Word;
begin
	Key := ReadKey;
	TKbKey(Key).CharCode := Upcase(TKbKey(Key).CharCode);
	ReadUpCase := Key;
end; { TKeybord.ReadUpCase }

 { Wait for a key then does the same as ReadUpCase }
function TKeybord.WaitUpCase :Word;
	var Key :Word;
begin
	Key := WaitKey;
	TKbKey(Key).CharCode := Upcase(TKbKey(Key).CharCode);
	WaitUpCase := Key;
end; { TKeybord.WaitUpCase }

 { Reads a Key from the keybord, ignoring those not having a
   charcode contained in Legal }
function TKeybord.ReadLegal(Legal :TCharSet) :Word;
	var Key :Word;
begin
	Key	:= ReadKey;
	if not (TKbKey(Key).CharCode in Legal) then ReadLegal := kbNoKey
	else ReadLegal := Key;
end; { TKeybord.ReadLegal }

  { Same effect as ReadLegal, Only waits for the Key }
function TKeybord.WaitLegal(Legal :TCharSet) :Word;
	var Key :Word;
begin
	Repeat
		Key	:= WaitKey;
	Until TKbKey(Key).CharCode in Legal;
end; { TKeybord.WaitLegal }

	{ Pushes a keybord keycode on the keybord data stream.
		The same result is achieved as when a key was pressed on the keybord }
procedure TKeybord.PushKey(Key :Word); assembler;
asm
	{ Push key on keybord data stream }
	MOV   AH, 05H
	MOV   CX, Key
	Int   IntKeybord
end; { TKeybord.PushKey }

 {  Returns true if a key has been pressed on the keyboard. }
function TKeybord.Pressed :Boolean; assembler;
asm
	MOV   AH, 01H      { Check keybord status - Int 16h function 01h }
	INT   IntKeybord
	JZ    @NoKey       { If Zero flag is set then no key was available }
	MOV   AL, True
	JMP   @End
@NoKey:
	MOV   AL, False
@End:
end; { TKeybord.Pressed }

	{ Clears the keyboard buffer }
procedure TKeybord.ClearBuf;
begin
	while Pressed do WaitKey;
end;

	{ Sets the typematic rate and delay of the keybord }
procedure TKeybord.SetTypeRate(Rate, Delay :Byte);
begin
	Rate := Abs(Rate-$1F);  { Reverse order of rate - 0 = 31; 31 = 0 etc. }
	asm
		MOV   AH, 03h         { function 03H             }
		MOV   AL, 05h         { Required extra parameter }
		MOV   BH, Delay
		MOV   BL, Rate
		CMP   BH, 3           { Delay must not exceed 3 }
		JBE   @1
		MOV   BH, 3
	@1:
		CMP   BL, 1Fh         { Rate must not exceed 1FH (31) }
		JBE   @2
		MOV   BL, 1Fh
	@2:
		INT   IntKeybord      { Excecute Interrupt 16H }
	end;
end; { TKeybord.SetTypeRate }

	{ Checks whether or not all the bits in Flags are present in
		the keybord status byte at adress $0000:$0417, thus telling
		if a keybord shift state is on or off                     	}
function TKeybord.StatesOn(Flags :Byte) :Boolean; assembler;
asm
	MOV   AH, 02H           { Get Keybord flags - Int 16H function 02H }
	INT   IntKeybord
	AND   AL, Flags         { Remove bits that do not match flags }
	CMP   AL, Flags         { Check if all the flags is present   }
	JE    @1
	MOV   AL, False         { kbShiftOn = false if all is not present }
	JMP   @End
@1:
	MOV   AL, True          { kbShiftOn = true if all is present }
@End:
end; { TKeybord.StatesOn }

function TKeybord.StateOn(Flags :Byte) :Boolean; assembler;
asm
	MOV   AH, 02H           { Get Keybord flags - Int 16H function 02H }
	INT   IntKeybord
	AND   AL, Flags         { Remove bits that do not match flags  }
	CMP   AL, 0             { Check if any of the flags is present }
	JA    @1
	MOV   AL, False         { kbShiftOn = false if all is not present }
	JMP   @End
@1:
	MOV   AL, True          { kbShiftOn = true if all is present }
@End:
end; { TKeybord.StateOn }

function TKeybord.GetState :Byte; assembler;
asm
	{ Get Keybord flags }
	MOV   AH, 02H
	INT   IntKeybord
end; { TKeybord.GetState }

	{ Sets the keybord shift state contained in Flags according to On }
procedure TKeybord.SetState(Flags :Byte; On :Boolean);
begin
	if On then KeybState := KeybState or Flags
	else KeybState := Keybstate - (KeybState and Flags);
end;

	{ Sets the keybord shift state contained in flags to its current opposite }
procedure TKeybord.ToggleState(Flags :Byte);
begin
	KeybState := KeybState xor Flags;
end;


{**þ MOUSE þ*****************************************************************}
var
	LastClock :LongInt; { The number of clock counts since midnight since
  											the last mouse button have been pressed }

 { Check if a double-click occured on the mouse }
function IsDouble :Boolean; near;
	var ClockNow :LongInt;
begin
	asm
		MOV  AH, 00h              { Get number of clock tics since midnight }
		INT  IntClock
		MOV  ClockNow.Word, DX    { Save that number as ClockNow }
		MOV  ClockNow.Word+2, CX
	end;
	IsDouble := (ClockNow - LastClock) <= MouseDDelay;
		{ A double-click occured if the number of clock tics that occurred
			since the last button was down <= MouseDDelay }
	LastClock := ClockNow;
end; { IsDouble }

procedure IHMouseEvent; far; assembler;
asm
	PUSH  DS                                   { Save Registers         }
  PUSHF
	PUSH  AX

	MOV  AX, SEG @Data                         { Obtain Data Segment    }
	MOV  DS, AX

  POP   AX                                   { Restore AX }
  PUSH  AX

	MOV  DS:MouseIntflag, True
	CMP  DS:MouseReverse, False                { Check if MouseReverse is set }
	JE   @2
	MOV  AL, BL                                { Switch bit 0 and bit 1 }
	AND  AL, 01                                {        if true         }
	AND  BL, 02
	SHL  AL, 1
	SHR  BL, 1
	OR   BL, AL
@2:
	MOV   DS:MouseButtons, BL                   { Set MouseButtons value }
	MOV   Word Ptr DS:[MouseWhere].TPoint.X, CX { Set Mouse Location     }
	MOV   Word Ptr DS:[MouseWhere].TPoint.Y, DX
	MOV   DS:MouseEvent, AX                     { Set up the Event flags }

	CMP   DS:MouseButtons, 0                   { Do not Check for Double-   }
	JE    @3                                   { click if no button is down }
	PUSH  AX
	PUSH  DX
	PUSH  CX
	CALL  IsDouble                             { Check for a double-click  }
	MOV   MouseDouble, AL                      { Save Value in MouseDouble }
	POP   CX
	POP   DX
	POP   AX
@3:
  POP  AX
  POPF
	POP  DS                                    { Restore Data Segment (DS) }
end; { IHMouseEvent }

	{ Initializes the Mouse Manager and shows the mouse pointer in the
		upper left corner of the screen }
procedure InitMouse; assembler;
asm
	XOR   AX, AX                  { Function 00h - Reset Mouse & get Status }
	INT   IntMouse                { Execute Int 33h(51) - Mouse Interrupt   }
	CMP   AX, 0                   { AX = Mouse Available?                   }
	JE    @End                    { Do not Initialize Handler               }
																{   if no Mouse is available              }

	MOV   MouseAvail, True        { Set Variable MouseAvail to True         }
	MOV   MouseBCount, BL         { Set the number of buttons on the mouse  }

	MOV   AX, 000Ch               { Function 0Ch(12) - Set User defined     }
																{                    Mouse Event Handler  }
	MOV   CX, 007Fh               { Set EventMask of Mouse Interrupts       }
	MOV   DX, SEG IHMouseEvent    { Set Address of Mouse Interrupt Handler  }
	MOV   ES, DX
	MOV   DX, OFFSET IHMouseEvent
	INT   IntMouse                { Execute Interrupt 33h(51)               }

	MOV   AX, 01h                 { Function 01h(1) - Show Mouse Pointer    }
	INT   IntMouse                { Execute Interrupt 33h                   }

  MOV  AX, 0004h                { Move the mouse pointer to the upper    }
	MOV  CX, 0                    { Left corner using Int 33H function 04H }
	MOV  DX, 0
	INT  IntMouse

@End:
end; { InitMouse }

	{ Disables the Mouse Manager and hides the mouse pointer }
procedure DoneMouse; assembler;
asm
	MOV   MouseAvail, False   { Set variable - no mouse is available         }
	MOV   MouseBCount, 0      { Mouse has no buttons for no mouse is enabled }
	MOV   AX, 0021h           { Function 21h(33) - Reset Mouse Driver        }
	INT   IntMouse            { Execute Interrupt 33h(51)                    }
end; { DoneMouse }

	{ Hides the mouse pointer - The mouse device driver still
															tracks the pointer }
procedure HideMouse; assembler;
asm
	MOV   AX, 0002h
	INT   IntMouse
end; { HideMouse }

	{ Shows the Mouse Pointer on the screen }
procedure ShowMouse; assembler;
asm
	MOV   AX, 0001h           { function 01h(1) - Show mouse pointer }
	INT   IntMouse            { Execute Interrupt 33h(51)            }
end; { ShowMouse }


	{ Moves the mouse pointer to a certain location on the screen }
Procedure SetMousePos(X, Y :Integer); assembler;
asm
	MOV  AX, 0004h            { function 04h(4) - Move mouse pointer }
	MOV  CX, X                { Set Horizontal position              }
	MOV  DX, Y                { Set Vertical position                }
  INT  IntMouse             { Execute Interrupt 33h(51)            }
	MOV  AX, 0003
  INT  IntMouse
  MOV  Word Ptr MouseWhere, CX
	MOV  Word Ptr MouseWhere+2, DX
end; { SetMousePos }


{**þ INPUT MANAGER þ*********************************************************}
procedure GetKeyInput(var Input :TKeybordInput; Wait, Upcase :Boolean);
begin
	with Input do
	begin
		if Wait then
			if Upcase then KeyCode := Keybord.WaitUpcase
      else KeyCode := Keybord.WaitKey
    else
      if Upcase then KeyCode := Keybord.ReadUpcase
      else KeyCode := Keybord.ReadKey;
    if KeyCode <> kbNokey then What := inKeybord
    else What := inNothing;
    ShiftState := Keybord.GetState;
  end;
end; { GetKeyInput }

procedure GetLegalKeyInput
  (var Input :TKeybordInput; Wait, Upcase :Boolean; Legal :TCharSet);
begin
  GetKeyInput(Input, Wait, UpCase);
	With Input do
    if not (Charcode in Legal) then What := kbNoKey;
end; { GetLegalKeyIput }

procedure GetMouseInput(var Input :TMouseInput);
begin
  if MouseIntFlag then
  with input do
  begin
    What    := MouseEvent;
    Buttons := MouseButtons;
    Where   := MouseWhere;
    Double  := MouseDouble;
	end else
  with input do
  begin
    What    := inNothing;
    Double  := False;
	end;
  MouseIntFlag := False;
end; { GetMouseInput }

function MouseInputMatch(var Input :TMouseInput; Mask :Word) :Boolean;
begin
  GetMouseInput(Input);
	MouseInputMatch := Mask and Input.What <> 0;
end; { MouseInputMatch }

function MouseInputMatchIn
  (var Input :TMouseInput; Mask :Word; Bounds :TBounds) :Boolean;
begin
  MouseInputMatchIn := MouseInputMatch(Input, Mask) and
                       (Bounds.Within(Input.Where));
end; { MouseInputMatchIn }

procedure InitInput;
begin
  Keybord.Init;
  InitMouse;
end; { InitInput }

procedure DoneInput;
begin
  DoneMouse;
  Keybord.Done;
end; { DoneInput }

end. { Unit }