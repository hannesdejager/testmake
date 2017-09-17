{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edited by Hannes de Jager 1996 & 1997                                  *}
{* Installation Program                                                     *}
{****************************************************************************}

{$F-,I-,O-,Q-,R-,S-}

program TestMaker_Install;
  uses sProcs, Objects, Dos, Crt;

{***þ Program Errors þ***}
const
  ErrDirCreate    = 1;
  ErrDiskSpace    = 2;
  ErrIncorrectDos = 3;
  ErrInvalidDrive = 4;
  ErrSourceOpen   = 5;
  ErrSourceRead   = 6;
  ErrSourceTarget = 7;
  ErrTargetOpen   = 8;
  ErrTargetWrite  = 9;

{***þ File Transfer Info Record þ***}
type
  PFileObject = ^TFileObject;
  TFileObject = Object(TObject)
    Essential :Boolean;
    Name      :String[12];
    Size      :LongInt;
  end;

{***þ File Copier Machine þ***}
  TFileCopy = Object(TObject)
    ErrCode   :Integer;
    SourceDir :PString;
    TargetDir :PString;
    FileList  :PCollection;
    Bytes     :LongInt;
    constructor Init(SDir, TDir :String; FileLst :PCollection);
    destructor  Done; virtual;
    function    CalcSize :LongInt;
    procedure   CopyAll;
    procedure   CopyFile(FileObj :PFileObject);
    function    EnoughDisk :Boolean;
    procedure   Error(Code :Integer);
    function    Overwrite(FileObj :PFileObject) :Boolean;
    procedure   ToTargetDir;
  end;

{***þ A type holding the characters used for drawing a text frame þ***}
type
  TFrame = array[1..8] of Char;

{***þ Two Frames þ***}
const
  SingleFrame: TFrame = 'ÚÄ¿³³ÀÄÙ';
  DoubleFrame: TFrame = 'ÉÍ»ººÈÍ¼';


{ Writes an amount of characters at a specific coordinate to the screen
  in a spesific color. }
procedure WriteChar(X, Y :Byte; Count :Word; Ch :Char; Attr :Byte);
  var I :Word;
begin
  GotoXY(X, Y);
  TextAttr := Attr;
  for I := 1 to Count do Write(Ch);
end;

{ Writes a string at a specific coordinate to the screen in a spesific color.}
procedure WriteStr(X, Y :Byte; S :String; Attr :Byte);
begin
  GotoXY(X, Y);
  TextAttr := Attr;
  Write(S);
end;

{ Creates a framed text window on the screen. }
procedure FrameWin(X1, Y1, X2, Y2 :Byte; Title: String;
                   TitleAttr, FrameAttr, FillAttr: Byte; Frame :TFrame);
var
  W, H, Y: Word;
begin
  Window(X1, Y1, X2+1, Y2);
  TextAttr := FillAttr;
  ClrScr;
  W := X2 - X1 + 1;
  H := Y2 - Y1 + 1;
  WriteChar(1, 1, 1, Frame[1], FrameAttr);
  WriteChar(2, 1, W - 2, Frame[2], FrameAttr);
  WriteChar(W, 1, 1, Frame[3], FrameAttr);
  if Length(Title) > W - 2 then Title[0] := Chr(W - 2);
  WriteStr((W - Length(Title)) shr 1 + 1, 1, Title, TitleAttr);
  for Y := 2 to H - 1 do
  begin
    WriteChar(1, Y, 1, Frame[4], FrameAttr);
    WriteChar(W, Y, 1, Frame[5], FrameAttr);
  end;
  WriteChar(1, H, 1, Frame[6], FrameAttr);
  WriteChar(2, H, W - 2, Frame[7], FrameAttr);
  WriteChar(W, H, 1, Frame[8], FrameAttr);
  Inc(WindMin, $0101);
  Dec(WindMax, $0102);
  GotoXY(1, 1);
end; { FrameWin }

{ Adds a backslash '\' to the givven path }
function AddSlash(S :String) :String;
begin
  if S[Length(S)] <> '\' then AddSlash := S+'\' else AddSlash := S;
end;

{ Removes the last backslash '\' from the givven path }
function StripSlash(S :String) :String;
begin
  if S[Length(S)] = '\' then Dec(S[0]);
  if (S[Length(S)] = ':') or (S = '') then S := S+'\';
  StripSlash := S;
end;

{ Displays a String on the bottomline of the screen }
procedure StatusStr(S :String; Attr :Word);
begin
  TextAttr := Attr;
  Window(1, 1, 80, 25);
  GotoXY(1, 25);
  ClrEol;
  Write(' '+S);
end; { StatusStr }

{ Initializes the object and creates the target directory if nessercary. }
constructor TFileCopy.Init(SDir, TDir :String; FileLst :PCollection);

   { Called to confirm a directory creation }
   function DirCreate :Boolean;
   begin
     if ErrCode <> 0 then Exit;
     StatusStr('Die gids kon nie gevind word nie. '+
               'Skep ''n nuwe gids ? [J/N] ', $6F);
     DirCreate := Upcase(Readkey) = 'J';
   end; { sub procedure DirCreate }

   { Called when the target directory needs to be created }
   procedure CreateTargetDir;
   begin
     if ErrCode <> 0 then Exit;
     StatusStr('Besig om gids te skep : ...', $2F);
     {$I-}
     MkDir(TargetDir^);
     if IOResult <> 0 then Error(ErrDirCreate);
     {$I+}
     StatusStr('', $77);
   end; { sub procedure CreateTargetDir }

   { Tells if Dos 3.0 or higher is present }
   function DosSatisfy :Boolean;
   begin
     DosSatisfy := Hi(DosVersion) >= 3;
   end;

begin { Init }
  inherited Init;
  { Check for Dos version }
  if not DosSatisfy then
  begin
    Error(errIncorrectDos);
    Done;
    Fail;
  end;
  { Add drive name at front of Target directory }
  if TDir = '' then TDir := GetCurPath;
  if TDir[2] <> ':' then
    if TDir[1] <> '\' then TDir := GetCurrentDrive+':\'+TDir
    else TDir := GetCurrentDrive+':'+TDir;
  SourceDir := NewStr(SUpper(StripSlash(SDir)));
  TargetDir := NewStr(SUpper(StripSlash(TDir)));
  { Screen Display }
  FrameWin(3, 9, 77, 12, ' Gidse ', $1E, $1E, $1F, SingleFrame);
  WriteStr(2, 1, 'Oorsprong Gids : '+SourceDir^, $1F);
  WriteStr(2, 2, 'TeikenGids     : '+TargetDir^, $1F);
  { Check for valid Target drive }
  if not PhysDriveValid(TargetDir^[1]) then
  begin
    Error(ErrInvalidDrive);
    Done;
    Fail;
  end; {if}
  { Check for source and destination overlap }
  if SourceDir^ = TargetDir^ then
  begin
    Error(ErrSourceTarget);
    Done;
    Fail;
  end; {if}
  FileList  := FileLst;
  if not DirExists(TargetDir^) then
    if DirCreate then CreateTargetDir
    else
    begin
      Done;
      Fail;
    end;{else}
  if ErrCode <> 0 then Exit;
  { Check for enough Free Disk space }
  if not EnoughDisk then
  begin
    Error(ErrDiskSpace);
    Fail;
  end;
end; { TFileCopy.Init }

{ Disposes of the object and changes to the target directory. }
destructor TFileCopy.Done;
begin
  ToTargetDir;
  if FileList <> nil then Dispose(FileList, Done);
  DisposeStr(SourceDir);
  DisposeStr(TargetDir);
  Inherited Done;
end; { TFileCopy.Done }

{ Calculates the sum of all the filesizes }
function TFileCopy.CalcSize :LongInt;
  var Size :LongInt;
    procedure IncSize(Item: PFileObject); far;
    begin
      Inc(Size, Item^.Size);
    end; { sub procedure IncSize }
begin
  Size := 0;
  FileList^.ForEach(@IncSize);
  CalcSize := Size;
end; { TFileCopy.CalcSize }

{ Copies all the files in FileList from source to destination }
procedure TFileCopy.CopyAll;
    procedure CopyItem(Item: PFileObject); far;
    begin
      CopyFile(Item);
    end; { sub procedure CopyItem }
begin
  FrameWin(3, 16, 77, 21, ' Kopie‰rings proses ', $1A, $1A, $1F, SingleFrame);
  FileList^.ForEach(@CopyItem);
end; { TFileCopy.CopyAll }

{ Copies the file at index of the list to the distination directory. }
procedure TFileCopy.CopyFile(FileObj :PFileObject);
  const MaxBufSize = $F000;
  var SF, TF  :file;
      SN, TN  :String;
      Buffer  :Pointer;
      DidXFer :LongInt;
      ToXFer  :LongInt;
begin
  Window(4, 17, 76, 20);
  TextAttr := $1F;
  if ErrCode <> 0 then Exit;
  if FileObj = nil then exit;
  with FileObj^ do
  begin
    SN := AddSlash(SourceDir^)+Name;
    TN := AddSlash(TargetDir^)+Name;
    { Update Display }
    Writeln('  Oorsprong Gids : '+AddSlash(SourceDir^));
    Writeln('  Teiken Gids    : '+AddSlash(TargetDir^));
    Writeln('  Lˆernaam       : ', Name);
    Write('  Grepe          : ', Bytes, ' van ', CalcSize);
    {$I-}
    Assign(SF, SN);
    Assign(TF, TN);
    {Open Files}
    Reset(SF, 1);
    if IOResult <> 0 then
    begin
      Error(ErrSourceOpen);
      ErrCode := 0;
      Exit;
    end; {if}
    if FileExists(TN) then
      if not Overwrite(FileObj) then
      begin
        Close(SF);
        ErrCode := 0;
        Exit;
      end; {if}
    Rewrite(TF, 1);
    if IOResult <> 0 then
    begin
      Error(ErrTargetOpen);
      Close(SF);
      ErrCode := 0;
      Exit;
    end; {if}
    { Transfer }
    DidXFer := 0;
    Repeat
      ToXFer := Size - DidXFer;
      if ToXFer > MaxBufSize then ToXFer := MaxBufSize;
      GetMem(Buffer, ToXFer);
      BlockRead(SF, Buffer^, ToXFer);
      If IOResult <> 0 then
      begin
        Error(ErrSourceRead);
        ErrCode := 0;
        Exit;
      end; {if}
      BlockWrite(TF, Buffer^, ToXFer);
      If IOResult <> 0 then
      begin
        Error(errTargetWrite);
        ErrCode := 0;
        Exit;
      end; {if}
      Inc(DidXFer, ToXFer);
      FreeMem(Buffer, ToXFer);
    Until DidXFer = Size;
    { Close Files }
    Close(SF);
    Close(TF);
    {$I+}
    Inc(Bytes, Size);
  end; {with}
end; { TFileCopy.CopyFile }


{ Tells if enough disk space is available to install the program }
function TFileCopy.EnoughDisk :Boolean;
begin
  EnoughDisk := CalcSize < DiskFree(Ord(TargetDir^[1])-64);
end; { TFileCopy.EnoughDisk }

{ Called whenever an error occurs. It displays an error on the BottomLine
  and sets ErrCode to Code }
procedure TFileCopy.Error(Code :Integer);
  var S :String;
begin
  ErrCode := Code;
  S := 'Fout : ';
  case Code of
    errDirCreate    :S := S+'Kon nie Gids skep nie. Geen installasie';
    errDiskSpace    :S := S+'Nie voldoende stoorspasie ! Geen installasie';
    errIncorrectDos :S := S+'DOS 3.0 of ho‰r is nodig om Testmaker te gebruik';
    errInvalidDrive :S := S+'Ongeldige aandrywer gespesifiseer';
    errSourceOpen   :S := S+'Kon nie bronlˆer open nie';
    errSourceRead   :S := S+'Kon nie van bronlˆer lees nie';
    errSourceTarget :S := S+'Bron en teiken gids kan nie dieselfde wees nie';
    errTargetOpen   :S := S+'Kon nie teikenlˆer skep nie';
    errTargetWrite  :S := S+'Kon nie na teikenlˆer skryf nie';
  end;
  StatusStr(S, $4F);
  ReadKey;
  StatusStr('', $77);
end; { TFileCopy.Error }

{ Called to confirm a file overwrite when a spesified target file
  already exists. }
function TFileCopy.Overwrite(FileObj :PFileObject) :Boolean;
begin
  StatusStr('Die teikenlˆer bestaan reeds. Herskryf ? [J/N] ', $4F);
  Overwrite := Upcase(Readkey) = 'J';
  StatusStr('', $77);
end;

{ Called to change the path to the target directory }
procedure TFileCopy.ToTargetDir;
  var I :Integer;
begin
  if ErrCode <> 0 then Exit;
  {$I-}
  ChDir(TargetDir^);
  {$I+}
  I := IOResult;
end; { TFileCopy.ToTargetDir }


{*********************}
{  Routines           }
{*********************}

{ Gets the target directory from the user }
function GetTargetDir :String;
  var S :String;
begin
  WriteStr(2, 2, 'Teiken Gids    : ', $1F);
  Readln(S);
  GetTargetDir := S;
end;

{ Sets up a collection list of all the files needed to be transferred. }
function SetUpList :PCollection;
  { List of Testmaker Files }
  const FileList :Array[1..6] of TFileObject = (
    (Essential :False; Name :'DEMO.TMS'),
    (Essential :False; Name :'TESTMAKE.CNF'),
    (Essential :True;  Name :'TESTMAKE.EXE'),
    (Essential :False; Name :'TESTMAKE.HLP'),
    (Essential :True;  Name :'TESTMAKE.OVR'),
    (Essential :False; Name :'TESTMAKE.RES'));

  var List :PCollection;
      Item :PFileObject;
      I :Byte;
      F :File;
      FileName :String;
begin
  New(List, Init(6, 0));
  for I := 1 to 6 do
  begin
    FileName := GetExeDir+FileList[I].Name; { Startup Dir + Name }
    if FileExists(FileName) then
    begin
      {$I-}
      Assign(F, FileName);
      Reset(F, 1);
      FileList[I].Size := FileSize(F);
      Close(F);
      {$I+}
      If IOResult <> 0 then
      begin
        StatusStr('Fout met lees van lˆer : '+FileList[I].Name, $4F);
        if FileList[I].Essential then Exit;
      end {if}
      else
      begin { Add to List }
        New(Item, Init);
        Item^ := FileList[I];
        List^.Insert(Item);
      end;{else}
    end {if fileExists}
    else
    begin
      StatusStr('Fout, lˆer kon nie gevind word nie : '+FileList[I].Name, $4F);
      if FileList[I].Essential then Exit;
    end; {else}
  end; {for}
  SetUpList := List;
end; { SetupList }




var
  Copier :TFileCopy;


begin { Program Install }
  { Initial Display }
  WriteChar(1, 1, 80*25, '°', $70);
  FrameWin(3, 1, 77, 5, '', $00, $1E, $1F, DoubleFrame);
  WriteStr(17, 2, 'T E S T M A K E R    I N S T A L E R I N G', $1F);
  FrameWin(3, 9, 77, 12, ' Gidse ', $1A, $1A, $1F, SingleFrame);
  WriteStr(2, 1, 'Oorsprong Gids : '+SUpper(GetExeDir), $1F);
  { Copy files }
  if Copier.Init(GetExeDir, GetTargetDir, SetupList) then
  begin
    Copier.CopyAll;
    Copier.Done;
    StatusStr('Druk enige sleutel. ', $74);
    Readkey;
  end;
  { Clear Screen for Exit }
  Window(1, 1, 80, 25);
  TextAttr := $07;
  Clrscr;
end. { Program }