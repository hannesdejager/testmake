{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* Routines for general use                                                 *}
{****************************************************************************}
Unit SProcs;
  {$F-,O-,Q-,R-,S-}

Interface
   Uses sTypes;

{***� Error trapping routines �***}
  procedure Abort(S :String);
  procedure Abstract(Method :String);

{ ***� Bounding routines �*** }
  function BoundByte (x, Lox, Hix :Byte) :Byte;
  function MaxByte   (x, y :Byte)        :Byte;
  function MaxInt    (x, y :Integer)     :Integer;
  function MinByte   (x, y :Byte)        :Byte;
  function MinInt    (x, y :Integer)     :Integer;
  function SubSmallW (x, y :Word)        :Word;

{ ***� Bit & Memmory routines �*** }
  procedure ClearMem  (var Rec; Size :Word);
  function  EnoughMem (Size :Word) :Boolean;
  function  CompMem   (var Source, Dest; Len :Word) :Boolean;
  procedure MoveMem   (var Source, Dest; Count :Word);

{***� Disk & File relative routines �***}
  function DirExists(Path :TExtrFile) :Boolean;
  function DriveValid(Drive: Char): Boolean;
  function FileExists(Name :TExtrFile) :Boolean;
  function GetCurPath :String;
  function GetCurrentDrive :Char;
  function GetExeDir  :String;
  function PhysDriveValid(Drive :Char) :Boolean;

{***� Linking �***}
  procedure FreeLPString(var Item :PLPString);
  function  NewLPString(Val :String; NextLink :PLPString) :PLPString;

{***� Returns the Minimum value of the two in Word format �***}
function MinWord(x, y :Word) :Word; inline(
  $58/     { POP AX }
  $5B/     { POP BX }
  $39/$D8/ { CMP AX, BX  - Compare AX to BX          }
  $76/$02/ { JBE 2 bytes - Jump two bytes if AX < BX }
  $89/$D8  { MOV AX, BX  - Put BX in AX              }
); { end MinWord }

  {***� Returns the Maximum value of the two in Word format �***}
function MaxWord(x, y :Word) :Word; inline(
  $58/     { POP AX }
  $5B/     { POP BX }
  $39/$D8/ { CMP AX, BX  - Compare AX to BX           }
  $73/$02/ { JBE 2 bytes - Jump two bytes if AX >= BX }
  $89/$D8  { MOV AX, BX  - Put BX in AX               }
); { end MaxWord }

{***� Ensures x is within the bounds Lox..Hix else returning Lox or Hix �***}
function BoundWord(x, Lox, Hix :Word) :Word; inline(
  $59/     { POP CX }
  $5B/     { POP BX }
  $58/     { POP AX }
  $39/$D8/ { CMP AX, BX  - Compare AX to BX           }
  $73/$02/ { JAE 2 bytes - Jump two bytes if AX >= BX }
  $89/$D8/ { MOV AX, BX  - Put BX in AX               }
  $39/$C8/ { CMP AX, CX  - Compare AX to CX           }
  $76/$02/ { JBE 2 bytes - Jump two bytes if AX <= CX }
  $89/$C8  { MOV AX, CX }
); { End BoundWord }

{***� String handling routines �***}
  function  SInt       (Num :LongInt; Width :Byte) :String;
  function  SUpper     (Str :String) :String;
  function  SFill      (Ch :Char; Len :Byte)   :String;
  function  SRemoveCh  (Str :String; ch :Char) :String;
  function  SPad       (Str :String; Ch :Char; Len :Byte) :String;
  function  SFScan     (Str :String; Ch :Char) :Byte;
  { Sets the length of a string }
  procedure SSetLen    (Str :String; Len :Byte);
    inline($58/  { POP AX }
           $5F/  { POP DI }
           $07/  { POP ES }
           $AA   { STOSB  }
    );{ Str[0] := Char(Len) }

{***� PChar type routines �***}
  procedure StrFreeMem(var P :PChar; StrLen :Word);
  procedure StrGetMem(var P :PChar; StrLen :Word);
  function  StrRemoveCh  (Str :PChar; Ch :Char) :PChar;
  procedure StrPCat(Dest :PChar; Source :String);

{***� PString type routines �***}
  function  NewStr     (Str: String): PString;
  function  GetStr     (Size :Byte) :PString;
  procedure DisposeStr (Str :PString);

{***� Control Characters used by the TWrapper Object �***}
const
  Wrapper_Left     = #2;
  Wrapper_Center   = #3;
  Wrapper_Right    = #4;
  Wrapper_Indent   = #5;
  Wrapper_CR       = #13;

{***� TWrapper Object �***
 This object is used to return wrapped text out of a continuous string. }
type
  TWrapper = Object
    Text       :PChar;
    Width      :Word;
    IndentSize :Byte;
    LineCount  :Byte;
    procedure AssignText(AText :PChar; AWidth, AIndent :Byte);
    procedure AssignStr(S :String; AWidth, AIndent :Byte);
    function  NextLine :String;
    function  IsDone :Boolean;
    private
      Dyanamic   :Boolean;
      Position   :PChar;
      Allignment :Char;
      Indent     :Boolean;
  end;



Implementation
  Uses Dos, Graph, Crt, strings;

{ Aborts the program displaying an error message. Used for program debugging }
procedure Abort(S :String);
begin
  RestoreCrtMode;
  TextAttr := $07;
  Writeln(' Program Aborted : '+S);
  Readln;
  Halt(1);
end; { Abort }

{ Called whenever a call was made to a abstract method }
procedure Abstract(Method :String);
begin
  Abort('Abstract Method Called --- '+Method);
end;


	{***� Returns the Minimum value of the two in Byte format �***}
function MinByte(x, y :Byte) :Byte; assembler;
asm
	MOV   AL, x  { Put x in the result register (AL for a Byte function) }
  CMP   AL, y  { Compare x and y                                       }
  JBE   @End   { if x <= y then goto end                               }
  MOV   AL, y  { Result register := y                                  }
@End:
end; { Minbyte }

  {***� Returns the Maximum value of the two in Byte format �***}
function MaxByte(x, y :Byte) :Byte; assembler;
asm
	MOV   AL, x    { Put x in the result register (AL for a Byte function) }
  CMP   AL, y    { Compare x and y                                       }
  JAE   @End     { if x >= y then goto end                               }
  MOV   AL, y    { else set y the result                                 }
@End:
end; { MaxByte }

  {***� Ensures x is within the bounds Lox..Hix else returning Lox or Hix �***}
function BoundByte(x, Lox, Hix :Byte) :Byte; assembler;
asm
	MOV   AL, x     { Saves x in Result Register      }
  CMP   AL, Lox   { Compare x to Lox                }
  JAE   @2        { if >= then do second validation }
  MOV   AL, Lox   { else bound x                    }
@2:
  CMP   AL, Hix   { Compare x to Hix                }
  JBE   @End      { if <= then allright - goto end  }
  MOV   AL, Hix   { else bound x                    }
@End:
end; { BoundByte }

  {***� Subtracts the Smallest value from the Largest �***}
function SubSmallW(x, y :Word) :Word; Assembler;
asm
	MOV   BX, x    { BX := x                     }
  MOV   AX, y    { AX := y                     }
  CMP   BX, AX   { Compare BX and AX (x and y) }
  JBE   @1       { if BX <= AX then Goto @1    }
  MOV   BX, y    { BX := y                     }
  MOV   AX, x    { AX := x                     }
@1:
  SUB   AX, BX   { AX := AX - BX  (AX = Result) }
end; { SubSmallW }

	{***� Returns the Minimum value of the two in Integer format �***}
function MinInt(x, y :Integer) :Integer;
begin
	If x < y then MinInt := x else MinInt := y;
end;

	{***� Returns the Maximum value of the two in Integer format �***}
function MaxInt(x, y :Integer) :Integer;
begin
	If x > y then MaxInt := x else MaxInt := y;
end;

{***� Bit & Memmory routines �***}
{ Clears an area of memmory by filling it with zeros }
procedure ClearMem(var Rec; Size :Word); assembler;
asm
  LES  DI, Rec    { Load Rec Pointer }
  MOV  CX, Size   { Store Size }
  XOR  AL, AL     { Clear AL   }
  REP  STOSB      { Move Bytes }
end; { ClearMem }

{***� Moves Count bytes of memmory from Source to Dest �***}
procedure MoveMem(var Source, Dest; Count :Word); assembler;
asm
  PUSH  DS          { Save Data Segment   }
  LDS   SI, Source  { Load Source Pointer }
  LES   DI, Dest    { Load Dest Pointer }
  MOV   CX, Count   { Set Count }
  CLD               { Set Direction to forward }
  REP   MOVSB       { Move Bytes }
  POP   DS          { Restore Data Segment }
end; { MoveMem }

{***� Compares 2 areas of memmory up to Len Bytes - Does no error checking �***}
function CompMem(var Source, Dest; Len : Word) :Boolean; assembler;
asm
  PUSH    DS              { Save Data segment }
  MOV     CX, Len         { Set Len }
  JCXZ    @@0             { Quit if Len = 0, returning True }
  LDS     SI, Source      { Load Source pointer }
  LES     DI, Dest        { Load Dest pointer }
  CLD                     { Set direction to forward }
  REPZ    CMPSB           { Compare the two areas }
  JZ      @@0             { Return True if the compare was completed }
  MOV     CL, True
@@0:
  MOV     AL, CL          { If CL = 0, return True, otherwise return False }
  XOR     AL, True
  POP     DS              { Restore Data segment }
end; { CompMem }

{ Returns true if a free memmory block of Size bytes is available }
function EnoughMem (Size :Word) :Boolean;
begin
  EnoughMem := MemAvail >= Size;
end; { EnoughMem }

{ Returns true if the file described in name exists }
function FileExists(Name :TExtrFile) :Boolean;
  var SR :SearchRec;
begin
  FindFirst(Name, ReadOnly+Hidden+SysFile+Archive, SR);
  FileExists := DosError = 0;
end;

{ Tells if a certain directory exists. }
function DirExists(Path :TExtrFile) :Boolean;
  var SR :SearchRec;
begin
  FindFirst(Path, directory, SR);
  DirExists := DosError = 0;
  if Path = '\' then DirExists := True;
  if (Path[2] = ':') and
     ((Length(Path) = 2) or ((Length(Path) = 3) and (Path[3] = '\')))
  then DirExists := DriveValid(Path[1]);
end; { Func DirExists }

{ Returns the current drive as reported by Dos }
function GetCurrentDrive :Char; Assembler;
asm
  MOV AH, 19H
  INT 21H
  ADD AL, 'A'
end;

{ Tells if a givven drive is valid }
function DriveValid(Drive: Char): Boolean; assembler;
asm
  MOV AH, 19H    { Save the current drive in BL }
  INT 21H
  MOV BL, AL
  MOV DL, Drive	{ Select the given drive }
  SUB DL, 'A'
  MOV AH, 0EH
  INT 21H
  MOV AH, 19H	{ Retrieve what DOS thinks is current }
  INT 21H
  MOV CX, False { Assume false }
  CMP AL, DL		{ Is the current drive the given drive? }
  JNE @@1
  MOV CX, True  { It is, so the drive is valid }
  MOV DL, BL	  { Restore the old drive }
  MOV AH, 0EH
  INT 21H
@@1:
  XCHG AX, CX { Put the return value into AX }
end; { func DriveValid }

{ Tells if a givven drive is valid. Also check that the logical name/letter
  corresponds to the physical name }
function PhysDriveValid(Drive :Char) :Boolean;
  { Gets the logical drive map for the physical one as reported by dos }
  function GetLogicalMap(Drv :Char) :Byte; assembler;
  asm
    MOV  AX, 440EH
    MOV  BL, Drv
    SUB  BL, 'A'-1
    INT  21H
  end; { GetLogicalMap }
  var Map :Byte;
begin
  Map := GetLogicalMap(Drive);
  PhysDriveValid := DriveValid(Drive) and
                    ((Map = 0) or (Map = ord(Drive)-64));
end; { func PhysDriveValid }

{***� Returns the current directory on the active drive �***}
function GetCurPath :String; assembler;
asm
  PUSH DS
  MOV  AH, 19H     { Get Current Drive }
  INT  21H
  ADD  AL, 'A'
  LES  DI, @Result { Load Result Pointer }
  PUSH DI
  INC  DI
  PUSH DI
  STOSB
  MOV  AL, ':'     { Add ':\' }
  STOSB
  MOV  AL, '\'
  STOSB
  MOV  AH, 47H     { Get Path }
  MOV  DL, 0
  PUSH ES
  POP  DS
  MOV  SI, DI
  INT  21H
  POP  DI          { Calculate Length }

	MOV	  CX, $FF
	XOR	  AL, AL
  REPNE SCASB
	MOV	 AX, $FE
	SUB	 AX, CX
  POP  DI
  STOSB
  POP  DS
end; { GetCurPath }

{ Returns the Path where the currently executing Exe file resides }
function GetExeDir  :String;
  var S :String;
begin
  S := ParamStr(0);
  Repeat
    Dec(S[0])
  Until S[Length(S)] = '\';
  GetExeDir := S;
end; { GetExeDir }

{ Sets up a new String Linking(PLPString) record for use with linkrd lists
  of Strings }
function NewLPString(Val :String; NextLink :PLPString) :PLPString;
  var P :PLPString;
begin
  New(P);
  with P^ do
  begin
    Value := NewStr(Val);
    Next := NextLink;
  end;
  NewLPString := P;
end; { NewLPString }

{***� Disposes of a String Linking record �***}
procedure FreeLPString(var Item :PLPString);
begin
  with Item^ do DisposeStr(Value);
  Dispose(Item);
  Item := nil;
end; { FreeLPString }

{***� Converts a Integer to a string �***}
function SInt (Num :LongInt; Width :Byte) :String;
  var S :String;
begin
  Str(Num:Width, S);
  SInt := S;
end; { SInt }

  {***� Converts a string to Uppercase �***}
function SUpper(Str :String) :String; Assembler;
asm
  PUSH   DS
  { Load pointers & set direction to forward }
  LDS    SI, Str
  LES    DI, @Result
  CLD
  { Load & store size }
  LODSB
  STOSB
  XOR    AH, AH
  XCHG   AX, CX
  JCXZ   @3

@1:
  { Load Character }
  LODSB
  { Convertion section }
  CMP    AL, 'a'
  JB     @2
  CMP    AL, 'z'
  JA     @2
  SUB    AL, 20H
@2:
  { Store character }
  STOSB
  LOOP   @1
@3:
  POP    DS
end; { SUpper }

  {***� Fills a String up to Len with Character ch �***}
function SFill(Ch :Char; Len :Byte) :String; assembler;
asm
  {Load Pointer & set direction to forward }
  LES    DI, @Result
  CLD
  {Store Size}
  MOV    AL, Len
  XOR    AH, AH
  MOV    CX, AX
  STOSB
  {Store Characters}
  MOV    AL, &Ch
  REP    STOSB
end; { SFill }

  {***� Removes all occurances of Ch in Str �***}
function SRemoveCh(Str :String; Ch :Char) :String; Assembler;
asm
  {Save Data Segment}
  PUSH    DS
  {Load Pointers & set direction to forward }
  CLD
  LDS    SI, Str      {Source}
  LES    DI, @Result  {Destination}
  {Load Source Size}
  LODSB
  MOV    BX, 01H
  Xor    AH, AH
  XCHG   AX, CX
  JCXZ   @3
@1:
  LODSB
  CMP    AL, &Ch
  JE     @2
  MOV    ES:[DI+BX], AL
  INC    BX
@2:
  LOOP   @1

@3:
  DEC    BX
  MOV    ES:[DI], BL
  POP    DS
end; { SRemoveCh }

function SPad(Str :String; Ch :Char; Len :Byte) :String;
  var CurrLen : Byte;
begin
  CurrLen := MinWord(Length(Str), Len);
  SSetLen(Str, Len);
  FillChar(Str[Succ(CurrLen)], Len - CurrLen, Ch);
  SPad := Str;
end; { SPad }

{***� Returns an Index to the First occurance of Ch in Str �***}
function SFScan(Str: String; Ch: Char): Byte; assembler;
asm
	CLD
	LES	   DI, Str
  MOV    CL, ES:[DI]
  XOR    CH, CH
  MOV    BX, CX
  INC    DI
	MOV	   AL, &Ch
	REPNE	 SCASB
	MOV    AX, 0
	CWD
  JNE	   @End
  MOV    AX, BX
  SUB    AX, CX
@End:
end; { SFScan }

{�� PChar type routines �����-������-������-������-������-������-������-����-}
{ Deallocates memmory of a PChar string with a spesific size on the heap. }
procedure StrFreeMem(var P :PChar; StrLen :Word);
begin
  if P <> nil then
  begin
    P^ := #0;
    FreeMem(P, StrLen+1);
  end;
end; { StrFreemem }

{ Allocates memmory for a PChar string on the heap }
procedure StrGetMem(var P :PChar; StrLen :Word);
begin
  GetMem(P, StrLen+1);
  P^ := #0;
end;

{***� Removes all occurances of Ch in Str �***}
function StrRemoveCh(Str :PChar; Ch :Char) :PChar; assembler;
asm
  { Set Up Registers }
  CLD
	LES	  DI, Str
  MOV   AX, DI
  MOV   DX, ES
  PUSH  AX
  PUSH  DX
  { Check for nil pointer }
  CMP   DI, 0
  JNE   @CheckEnd
  MOV   CX, ES
  JCXZ  @End
@CheckEnd:
  { Calculate Length - Save In CX }
	MOV	  CX, 0FFFFH
	XOR	  AL, AL
	REPNE	SCASB
	MOV	  DX, 0FFFEH
	SUB	  DX, CX
  MOV   CX, DX
  { Set Up Registers }
  PUSH  DS
  LDS   SI, Str  { Source }
  LES   DI, Str  { Destination }
  MOV   AH, &Ch
  { Check for Empty String }
  JCXZ   @3
  { Copy the relevant characters }
@1:
  LODSB
  CMP    AL, AH
  JE     @2
  STOSB
@2:
  LOOP   @1

@3:
  { Save null terminator }
  XOR    AL, AL
  STOSB

  POP    DS

@End:
  { Load Result Pointer }
  POP    DX
  POP    AX
end; { StrRemoveChar }

{ Adds the Pascal string Source to the end of Dest.
  No length Checking is performed. The destination buffer must have
  room for at least Length(Source)+1 characters.}
procedure StrPCat(Dest :PChar; Source :String);
  var P :PChar;
begin
  { Set P to point to where the null terminator should be placed }
  P := StrEnd(Dest)+length(Source);
  { copy the characters }
  Move(Source[1], StrEnd(Dest)^, Length(Source));
  { Set null terminator }
  P^ := #0;
end; { StrPCat }


{�� PString type routines �����-������-������-������-������-������-������-��-}
function NewStr(Str: String): PString;
  var P :PString;
begin
  if Length(Str) > 0 then GetMem(P, Length(Str)+1) else P := nil;
  MoveMem(Str[0], P^[0], Length(Str)+1);
  NewStr := P;
end;

{***� Allocates Size Space for a String on the Heap �***}
function GetStr(Size :Byte) :PString;
  var P :PString;
begin
  if Size > 255 then Size := 255;
  if Size > 0 then
  begin
    GetMem(P, Size+1);
    SSetLen(P^, 0);
  end {if}
  else P := nil;
  GetStr := P;
end; { func GetStr }

{ Disposes of a dyanamic string allocated by NewStr or GetStr }
procedure DisposeStr(Str :PString);
begin
  if Str <> nil then FreeMem(Str, Length(Str^)+1);
end;

{****************************************************************************}
{*  TWrapper object tool                                                          *}
{****************************************************************************}
{ Assigns Text to the Text Field of the wrapper and initializes it }
procedure TWrapper.AssignText(AText :PChar; AWidth, AIndent :Byte);
begin
  Text := AText;
  Width := AWidth;
  Position := Text;
  Allignment := Wrapper_Left;
  IndentSize := AIndent;
  Indent := False;
  Dyanamic := False;
  LineCount := 0;
end; { TWrapper.AssignText }

{ Assigns a String to the Text Field of the wrapper and initializes it }
procedure TWrapper.AssignStr(S :String; AWidth, AIndent :Byte);
begin
  StrGetMem(Text, Length(S));
  AssignText(StrPCopy(Text, S), AWidth, AIndent);
  Dyanamic := True;
end; { TWrapper.AssignStr }

{ This function is used to return the wrapped text line by line
  If the end of the text is reached it returns an empty string }
function TWrapper.NextLine :String;

  var S :String;
      Line :String;
      WordCount :Byte;

   { Returns the next available continious word }
   function ScanNext :String;
     const Deviders :TCharSet = [Wrapper_Left, Wrapper_Center,
                                 Wrapper_Right, Wrapper_Indent,
                                 Wrapper_Cr, ' ', ',','-', '(',')'];
       var S :String;
   begin
     { If End of String is reached }
     if Position = StrEnd(Text) then ScanNext := ''
     else
     { if a devider was found at current position }
     if Position^ in Deviders then
     begin
       ScanNext := Position^;
       Inc(Position);
     end
     else
     { regular character was found at current position }
     begin
       S := '';
       while not (Position^ in Deviders) and
                 (Position < StrEnd(Text)) do
       begin
         S := S+Position^;
         Inc(Position);
       end;
       ScanNext := S;
     end; { else }
   end; { sub func ScanNext }

   { Alligns the text by adding the relevant amount of Spaces at the front
     of the current output Line. Then sets the allignment to left. }
   procedure Allign;
   begin
     case Allignment of
       Wrapper_Left   :;
       Wrapper_Center :Line := SFill(' ', (Width - Length(Line)) shr 1) +Line;
       Wrapper_Right  :Line := SFill(' ', Width - Length(Line)) +Line;
     end; {case}
     Allignment := Wrapper_Left;
   end; { sub proc Allign }

begin { TWrapper.NextLine }
  NextLine := '';
  WordCount := 0;
  if Text = nil then Exit;
  S := ScanNext;
  if Indent and (LineCount > 0) and (S <> '') then
    Line := SFill(' ', IndentSize)
  else Line := '';
  while S <> '' do
  begin
    { A Cr is detected }
    if S = Wrapper_Cr then begin Indent := False; Allign; Break; end
    else
    { Left allignment control character is detected }
    if S = Wrapper_Center then Allignment := Wrapper_Center
    else
    { Center allignment control character is detected }
    if S = Wrapper_Center then Allignment := Wrapper_Center
    else
    { Right allignment control character is detected }
    if S = Wrapper_Right then Allignment := Wrapper_Right
    else
    { Indent control character was detected }
    if S = Wrapper_Indent then Indent := True
    else
    { Space is detected }
    if S = ' ' then begin if Line <> '' then Line := Line+' '; end
    { Word Is Detected }
    else
    if Length(Line+S) <= Width then begin Line := Line+S; Inc(WordCount); end
    else
      begin
        if WordCount > 0 then begin Dec(Position, Length(S)); Break; end
        else
        begin
          Dec(Position, Length(Line+S)-Width+1);
          S[0] := Char(Width-Length(Line)-1);
          Line := Line+S+'-';
          Break;
        end; {else}
      end; {else}
    S := ScanNext;
  end; {while}
  if Line <> '' then
  begin
    { Truncate spaces }
    if Line[Length(Line)] = ' ' then Dec(Line[0]);
    Allign;
  end;
  if Position^ = #0 then
    if Dyanamic then begin StrDispose(Text); Text := nil; end
    else Text := nil;
  NextLine := Line;
  Inc(LineCount);
end; { TWrapper.NextLine }

{ Called to check if any more text is left in the wrapper buffer }
function TWrapper.IsDone :Boolean;
begin
  IsDone := Text = nil;
end;

end. { Unit }