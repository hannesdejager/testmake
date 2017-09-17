{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* Support for Interrupt Handlers                                           *}
{****************************************************************************}
Unit SInts;
  {$F-,O-,Q-,R-,S-}

Interface

{***þ Values of Interrupt Services þ***}
const
	intClock     = $1A;
	intKeybord   = $16;
	intMouse     = $33;
	intMSDos     = $21;
  intPrinter   = $17;
	intVideo     = $10;
  vecCtrlC     = $23;
  vecCritical  = $24;
  vecCtrlBreak = $1B;
  vecPrintScr  = $05;

{***þ Handler swap record  þ***}
type
	PIntHandler = ^TIntHandler;
	TIntHandler = record
		Vector    :Byte;
		Address   :Pointer;
	end;

{***þ Routines þ***}

 { Returns the address stored in a specified interrupt vector.}
	function  GetIntVector (IntNo :Byte) :Pointer;
 { Sets a specified interrupt vector to a specified address. }
	procedure SetIntVector (IntNo :Byte; Adress :Pointer);
 { Installs the Interrupt Handler Handler.Address at the Vector Handler.Vector}
	procedure InitHandler  (var Handler :TIntHandler);
 { Swaps the current handler at vector Handler.Vector with the givven one }
	procedure DoneHandler  (var Handler :TIntHandler);
 { Returns the current state of Break Flag in Dos }
	function  GetDosCBreak :Boolean;
 { Sets the state of the Break-Flag in Dos  }
	procedure SetDosCBreak (On :Boolean);


Implementation

{ Returns the address stored in a spesified software interrupt vector }
function GetIntVector(IntNo :Byte) :Pointer; assembler;
asm
	MOV  AH, 35H
	MOV  AL, IntNo
	Int  intMSDos
	MOV  DX, ES
	MOV  AX, BX
end;

{ Sets a spesified software interrupt vector to a spesified address }
procedure SetIntVector(IntNo :Byte; Adress :Pointer); assembler;
asm
	PUSH  DS
	LDS   DX, Adress
	MOV   AL, IntNo
	MOV   AH, 25H
	Int   intMSDos
	POP   DS
end;

	{ Installs an Interrupt Handler }
procedure InitHandler(var Handler :TIntHandler);
	var P :Pointer;
begin
	with Handler do
	begin
		if Address = nil then exit;
		{ Swap Handler.Adress with the vector address }
		P := GetIntVector(Vector);
		SetIntVector(Vector, Address);
		Address := P;
	end;
end;

	{ Removes an Interrupt Handler - Replacing the original }
Procedure DoneHandler(var Handler :TIntHandler);
begin
	InitHandler(Handler);
end;

	{ Returns the state of the DOS Break Flag }
function GetDosCBreak :Boolean; assembler;
asm
	MOV	   AX, 3300H
	INT	   intMsDos
	MOV    AL, DL
end;

	{ Sets the state of the DOS Break Flag }
procedure SetDosCBreak(On :Boolean); assembler;
asm
	MOV  DL, On
	MOV  AX, 3301H
	INT  intMsDos
end;


end.  { Unit }