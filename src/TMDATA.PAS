{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{****************************************************************************}
Unit TMData;
  {$F+,O+,Q-,R-,S-}

interface
  uses Objects, sTypes;

{***þ Program File Names þ***}
const
  CnfFile_Name    = 'TESTMAKE.CNF';
  DemoFile_Name   = 'DEMO.TMS';
  HelpFile_Name   = 'TESTMAKE.HLP';
  ResFile_Name    = 'TESTMAKE.RES';

{***þ HelpFile Errors þ***}
const
  HelpFile_Ok        = 0;
  HelpFile_NotFound  = 1;
  HelpFile_NoCtx     = 2;
  HelpFile_IOError   = 3;
  HelpFile_DataError = 4;

{***þ Testmaker Setfile signature þ***}
const
  TMFile_Signature = 'TMSET';

  TMFile_NoErr          = 0;
  TMFile_FormatErr      = 1;
  TMFile_InvalidName    = 2;
  TMFile_ReadErr        = 3;
  TMFile_WriteErr       = 4;
  TMFile_NotFound       = 5;

{***þ DataStream for save and load of Setfiles þ***}
type
  TDataStream = Object(TDosStream)
    procedure Error(Code, Info: Integer); virtual;
  end;


{***þ Data: Paper Description þ***}
type
  TTDescript = record
    Description :String[30];
    Password    :String[30];
    Mask        :Byte;
  end;

{***þ Data: Paper Header þ***}
type
  TTHeader = record
    Subject  :String[30];
    Number   :String[15];
    Standard :String[20];
    Grade    :String[15];
    Date     :String[20];
    Setter   :String[30];
    Time     :String[10];
  end;

{***þ Data object controlling data of a Testmaker setfile þ***}
type
  PPaperData = ^TPaperData;
  TPaperData = Object(TObject)
    FileName     :PString;
    Modified     :Boolean;
    Descript     :TTDescript;
    Header       :TTHeader;
    Items        :PCollection;
    Error        :Byte;
    constructor Init(F :String);
    destructor  Done; virtual;
    procedure   Load;
    procedure   Save;
    procedure   NotifyOfError;
    function    ValidFileName(Name :String) :Boolean;
    function    GetTruncfileName :String;
  end;

{***þ Helpfile controller þ***}
type
  PHelpFile = ^THelpFile;
  THelpFile = Object(TObject)
    Handle   :Text;
    CtxEnd   :Boolean;
    ErrorVal :Integer;
    constructor Init;
    destructor  Done; virtual;
    procedure   Error(Code :Integer);
    function    Readline :String;
    procedure   ScanToCtx(Ctx :Word);
    procedure   ScanToTopic(Topic :String);
  end;

{***þ Routines þ***}
  function GetfileNameOnly(FileName :String) :String;
  function GetResource(Name :String) :PObject;

{***þ Initialized vairables þ***}
const
  PaperData  :PPaperData  = nil;
  StartUpDir :PString = nil;


Implementation
  uses sProcs, sBasic, STDViews;

{ Takes a Full Path+File Name as Parameter and returns only the FileName }
function GetfileNameOnly(FileName :String) :String;
  var S :String;
      B :Byte;
begin
  S := FileName;
  for B := Length(S) downto 1 do
   if S[B] = '\' then
   begin
     S := copy(S, B+1, Length(S)-B);
     Break;
   end;
  S := SRemoveCh(S, ' ');
  GetFileNameOnly := S;
end;

{ Reads any resource object from Testmaker's resource file }
function GetResource(Name :String) :PObject;
  var RF :TResourceFile;
begin
  RF.Init(New(PBufStream, Init(StartUpDir^+'TESTMAKE.RES', stOpenRead, 510)));
  GetResource := RF.Get(Name);
  RF.Done;
end;

{ Specialized Datastream error handler }
procedure TDataStream.Error(Code, Info: Integer);
  var S :String;
      B :TBounds;
begin
  Status := Code;
  case Code of
    stError      :S := 'File access error';
    stInitError  :S := 'Cannot initialize File';
    stReadError  :S := 'Read beyond end of stream';
    stWriteError :S := 'Cannot expand stream';
    stGetError   :S := 'Get of unregistered object type';
    stPutError   :S := 'Put of unregistered object type';
  end;
  S := #3+S;
  B.Assign(125, 200, 515, 300);
  MessageWindow(B, S, mwfError+mwfOk);
end;


{****************************************************************************}
{*  TPaperdata Objet                                                       *}
{****************************************************************************}
{ Initializes the PaperData Object }
constructor TPaperData.Init(F :String);
begin
  Inherited Init;
  FileName := NewStr(F);
  New(Items, Init(1, 1));
end;

{ Does the disposal of the paperdata object }
destructor TPaperData.Done;
begin
  DisposeStr(FileName);
  if Items <> nil then Dispose(Items, Done);
  inherited done;
end;

{ This procedure does the actual reading of the data from the file. }
procedure TPaperData.Load;
  var F :TDataStream;
      S :String;
      Signature :Array[0..4] of Char;

    Procedure ReadPassword;
      var I :Byte; PW :String[30];
    begin
      F.Read(PW, Sizeof(PW));
      for I := 1 to Length(PW) do
      begin
        if PW[I] in [#2..#255] then Dec(PW[I]);
        if PW[I] = #1 then PW[I] := #255;
      end;
      Descript.Password := PW;
    end;

begin
  with F do
  begin
    Init(FileName^, stOpenRead);
    Read(Signature, Sizeof(Signature));
    with Descript do
    begin
      Read(Description, Sizeof(Description));
      ReadPassword;
      Read(Mask, Sizeof(Mask));
    end;
    Read(Header, Sizeof(Header));
    if Items <> nil then Dispose(Items, Done);
    Items := PCollection(F.Get);
    Done;
  end;
end;

procedure TPaperData.Save;
  var F :TDataStream;
      Signature :Array[0..4] of Char;

    Procedure WritePassword;
      var I :Byte;
    begin
      with Descript do
      begin
        for I := 1 to Length(Password) do
        begin
          Password[I] := Upcase(Password[I]);
          if Password[I] in [#1..#254] then Inc(Password[I]);
          if Password[I] = #255 then Password[I] := #1;
        end;
        F.Write(Password, Sizeof(Password));
        for I := 1 to Length(Password) do
        begin
          if Password[I] in [#2..#255] then Dec(Password[I]);
          if Password[I] = #1 then Password[I] := #255;
        end;
      end;{with}
    end;

begin
  with F do
  begin
    Init(FileName^, stCreate);
    Signature := TMFile_Signature;
    Write(Signature, Sizeof(Signature));
    with Descript do
    begin
      Write(Description, Sizeof(Description));
      WritePassword;
      Write(Mask, Sizeof(Mask));
    end;
    Write(Header, Sizeof(Header));
    Put(Items);
    Done;
  end;
  Modified := False;
end;

function TPaperData.GetTruncfileName :String;
begin
  GetTruncFileName := GetfileNameOnly(FileName^);
end;

procedure TPaperData.NotifyofError;
  var B :TBounds;
  const Errs :Array[1..4] of String[38] =
    ('Lˆer is nie ''n Testmaker stel lˆer nie',
     'Ongeldige lˆernaam of toegang geweier',
     'Kon nie vanaf Lˆer Lees nie',
     'Kon nie na Lˆer Skryf nie'
    );

begin
  if Error = TMFile_NoErr then exit;
  B.Assign(125,200,515,300);
  MessageWindow(B, #3+errs[Error], mwfError+mwfOk);
  Error := TMFile_NoErr;
end;

function TPaperData.ValidFileName(Name :String) :Boolean;
  var f :File;
begin
  Assign(F, Name);
  {$I-}
  Reset(F);
  Close(F);
  if IOResult <> 0 then
  begin
    Rewrite(F);
    Close(F);
    Erase(F);
  end;
  {$I+}
  if not(IOResult = 0) then Error := TMFile_InvalidName;
  ValidFileName := Error = TMFile_NoErr;
end;

{***************************************************************************}
{*  THelpFile Objet                                                        *}
{***************************************************************************}
constructor THelpFile.Init;
begin
  inherited Init;
  Assign(Handle, StartUpDir^+HelpFile_Name);
  {$I-}
  Reset(Handle);
  if IOResult <> 0 then Error(HelpFile_IOError);
  {$I+}
end; { THelpFile.Init }

destructor THelpFile.Done;
begin
  {$I-}
  Close(Handle);
  If IOResult <> 0 then Error(HelpFile_DataError);
  {$I+}
  inherited Done;
end; { THelpFile.Done }

procedure THelpFile.Error(Code :Integer);
  var S :String;
      B :TBounds;
begin
  if ErrorVal > HelpFile_Ok then Exit;
  ErrorVal := Code;
  case ErrorVal of
    HelpFile_NotFound  :S := 'Hulplˆer kon nie gevind word nie: Testmake.Hlp.';
    HelpFile_IOError   :S := 'Data lees fout met Hulplˆer: Testmake.Hlp';
    HelpFile_DataError :S := 'Data fout met Hulplˆer: Testmake.Hlp';
    else Exit;
  end;
  S := #3+S;
  B.Assign(125, 200, 515, 300);
  MessageWindow(B, S, mwfError+mwfOk);
end; { THelpFile.Error }

function THelpFile.Readline :String;
  var S :String;
begin
  if ErrorVal > HelpFile_Ok then Exit;
  ReadLine := '';
  {$I-}
  If not Eof(Handle) then
  begin
    Readln(Handle, S);
    if IOResult <> 0 then Error(HelpFile_IOError);
    if Pos('*Ctx:', S) = 1 then
    begin
      ReadLine := '';
      CtxEnd := True;
      Exit;
    end;
  end
  else
  begin
    S := '';
    CtxEnd := True;
  end;
  if IOResult <> 0 then Error(HelpFile_IOError);
  {$I+}
  Readline := S;
end; { THelpFile.Readline }

procedure THelpFile.ScanToCtx(Ctx :Word);
  var S :String;
      ValErr :Integer;
      Num :Integer;
      Found :Boolean;
begin
  if ErrorVal > HelpFile_Ok then Exit;
  {$I-}
  Reset(Handle);
  if IOResult <> 0 then Error(HelpFile_IOError);
  S := '';
  Found := False;
  while not Eof(Handle) Do
  begin
    Readln(Handle, S);
    if IOResult <> 0 then
    begin
      Error(HelpFile_IOError);
      Exit;
    end;
    if Pos('*Ctx:', S) = 1 then
    begin
      Delete(S, 1, Pos('=', S));
      Val(S, Num, ValErr);
      if (ValErr = 0) and (Num = Ctx) then
      begin
        Found := True;
        CtxEnd := False;
        Break;
      end;{if}
    end;{if}
  end;{while}
 if IOResult <> 0 then Error(HelpFile_IOError);
 {$I+}
 if not Found then Error(HelpFile_NoCtx);
end; { THelpFile.ScanToCtx }

procedure THelpFile.ScanToTopic(Topic :String);
  var S :String;
      Found :Boolean;
begin
  if ErrorVal > HelpFile_Ok then Exit;
  {$I-}
  Reset(Handle);
  if IOResult <> 0 then Error(HelpFile_IOError);
  S := '';
  Found := False;
  while not Eof(Handle) Do
  begin
    Readln(Handle, S);
    if IOResult <> 0 then
    begin
      Error(HelpFile_IOError);
      Exit;
    end;
    if Pos('*Ctx:', S) = 1 then
    begin
      Delete(S, 1, 5);
      Delete(S, Pos('=', S), Length(S));
      if S = Topic then
      begin
        Found := True;
        CtxEnd := False;
        Break;
      end;{if}
    end;{if}
  end;{while}
  if IOResult <> 0 then Error(HelpFile_IOError);
 {$I+}
 if not Found then Error(HelpFile_NoCtx);
end; { THelpFile.ScanToTopic }

begin
  RegisterType(RCollection);
end.  { Unit }