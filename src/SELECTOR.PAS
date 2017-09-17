{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{*                                                                          *}
{* Implementation of the following objects                                  *}
{*   þ Password input window                                                *}
{*   þ File load and save window                                            *}
{*   þ Main Menu Mode Selector                                              *}
{****************************************************************************}
Unit Selector;
  {$F+,O+,Q-,R-,S-}

Interface
  uses Objects, sBasic, sView, sGraph, sInput, STDViews, sTypes, Dos,
       consts;

{***þ The Popup password window þ***}
type
  ttPassword = String[30];

type
  PPasswordWin  = ^TPasswordWin;
  TPasswordWin = Object(TViewGroup)
    Password :PString;
    constructor Init(PW :String);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   Listen(var Speech :TSpeech); virtual;
  end;

{***þ Data transfer record for TInfoPane þ***}
type
  TTInfoPane = record
    tMask      :String[12];
    tDirectory :String[79];
  end;

{***þ INFO PANE þ***}
type
  PInfoPane = ^TInfoPane;
  TInfoPane = Object(TView)
    Mask, Directory :PString;
    constructor Init;
    destructor  Done; virtual;
    procedure   Art; virtual;
    function    DataSize :Word; virtual;
    procedure   SetData(var Data); virtual;
  end;

{***þ FILE LISTER þ***}
type
  PFileLister = ^TFileLister;
  TFileLister = Object(TListscroller)
    Mask :PString;
    constructor Init;
    destructor  Done; virtual;
    procedure   BarChanged; virtual;
    function    GetString(Index :Word) :String; virtual;
    procedure   Selected(Index :Word); virtual;
    procedure   Update;
  end;

{***þ DIRECTORY LISTER þ***}
type
  PDirLister = ^TDirLister;
  TDirLister = Object(TListScroller)
    constructor Init;
    function    GetString(Index :Word) :String; virtual;
    procedure   Selected(Index :Word); virtual;
    procedure   Update;
  end;

{***þ DRIVELISTER þ***}
  PDriveLister = ^TDriveLister;
  TDriveLister = Object(TListScroller)
    MaxHeight :Integer;
    constructor Init;
    function    GetString(Index :Word) :String; virtual;
    procedure   Selected(Index :Word); virtual;
    procedure   Update;
  end;

{***þ File, Directory and Drive LISTER þ***}
type
  PSetLister = ^TSetLister;
  TSetLister = Object(TViewGroup)
    PrevPath  :PString;
    DriveList :PDriveLister;
    DirList   :PDirLister;
    FileList  :PFileLister;
    NameLine  :PInputline;
    InfoPane  :PInfoPane;
    LoadMode  :Boolean;
    constructor Init(InLoadMode :Boolean);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   Listen(var Speech :TSpeech); virtual;
    function    SetFileName(Name :String) :boolean;
  end;

{***þ Mode Selector þ***}
type
  PModeSelector = ^TModeSelector;
  TModeSelector = Object(TViewGroup)
    constructor Init;
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    procedure   GotFocus; virtual;
  end;

{***þ Routines þ***}
  function GetFiles(Mask :TFileName) :PFileCollection;
  function GetDirs :PFileCollection;
  function GetDrives :PDriveCollection;

Implementation
  uses Graph, Main, sProcs, sMsg, TMData;

constructor TPasswordWin.Init(PW :String);
  var B :TBounds;
begin
  { Center }
  B.Assign(GetMaxX shr 1 - 170, GetMaxY shr 1 - 50,
           GetMaxX shr 1+ 170, GetMaxY shr 1 + 50);
  inherited Init(B);
  Lock;
  B.Assign(90, 35, Size.X-15, 55);
  Append(New(PInputLine, Init(B, 30, '', [#32..#255])));
  B.Assign(20, 70, Size.X-20, 85);
  Append(New(PButton, Init(B, 'Aanvaar', cmAccept, hcNoContext)));
  SelectNext;
  Unlock;
  Password := NewStr(PW);
end; { TPasswordWin.Init }

destructor TPasswordWin.Done;
begin
  DisposeStr(Password);
  inherited Done;
end; { TPasswordWin.Done }

procedure TPasswordwin.Art;
begin
  Platform(0, 0, Size.X, Size.Y, $F008);
  Platform(5, 5, Size.X-5, Size.Y-5, $8B09);
  { Draw Caption }
  Platform(6, 6, Size.X-6, 26,  $F805);
  WriteStrXY(Size.X shr 1, 13, $0E, 2, 5, JustCenter,
    False, 'Testmaker Wagwoord Proteksie');
  WriteStrXY(20, 38, $0E, 2, 4, JustLeft, False, 'Wagwoord :');
end; { TPasswordWin.Art }

procedure TPasswordWin.Listen(var Speech :TSpeech);
  var Tf :ttPassword;
begin
  if Speech.Tone = spCommand then
    if Speech.What = cmAccept then
    begin
      GetData(Tf);
      if SUpper(TF) = SUpper(Password^) then
        EndModal(cmYes) else EndModal(cmNo);
    end;
end;

{****************************************************************************}
{*  TInfopane                                                               *}
{*  The infopane is a view displaying the current directory and file mask   *}
{****************************************************************************}
constructor TInfoPane.Init;
  var B :TBounds;
      S :String;
begin
  B.Assign(30, 160, 420, 170);
  inherited Init(B);
  Mask := NewStr('*.TMS');
  GetDir(0, S);
  Directory := NewStr(S);
end; { TInfoPane.Init }

destructor TInfoPane.Done;
begin
  inherited done;
end; { TInfoPane.Done }

procedure TInfoPane.Art;
begin
  Platform(0, 0, Size.X, Size.Y, $7707);
  Platform(Size.X-80, 0, Size.X, Size.Y, $0F09);
  Platform(0, 0, Size.X-85, Size.Y, $0F09);
  WriteStrXY(Size.X-40, 4, $F, 2, 4, JustCenter, False, Mask^);
  SetTextJustify(LeftText, CenterText);
  OutTextXY(8, 4, Directory^);
end; { TInfoPane.Art }

function TInfoPane.DataSize :Word;
begin
  DataSize := 79+12;
end; { TInfoPane.DataSize }

procedure TInfoPane.SetData(var Data);
begin
  { Free previous values }
  if Mask <> nil then DisposeStr(Mask);
  if Mask <> nil then DisposeStr(Directory);
  with TTInfoPane(Data) do
  begin
    Mask := NewStr(tMask);
    Directory := NewStr(tDirectory);
  end;
  Draw;
end; { TInfoPane.SetData }

{****************************************************************************}
{*  TFileLister                                                             *}
{*  The FileLister Object is a view object providing a scrollable list of   *}
{*  file names obtained from the current directory                          *}
{****************************************************************************}
constructor TFileLister.Init;
  var B :TBounds;
begin
  B.Assign(30, 50, 150, 140);
  inherited Init(B, GetFiles('*.TMS'));
  Mask := NewStr('*.TMS');
end; { TFileLister.Init }

destructor TFileLister.Done;
begin
  if Mask <> nil then DisposeStr(Mask);
  Inherited Done;
end; { TFileLister.Done }

{ Called whenever the current directory have changed.
  It sets up a new list of the files in the current directory by calling
  NewItems and then notifies the owner of the object }
procedure TFileLister.Update;
begin
  NewItems(GetFiles(Mask^));
  Message(Owner, spNotify, msgFileChanged, nil);
end; { TFileLister.Update }

function TFileLister.GetString(Index :Word) :String;
  var P :PFileItem;
begin
  P := PFileItem(ItemPtr(Index));
  if P <> nil then GetString := P^.Name else GetString := '';
end; { TFileLister.GetString }

Procedure TFileLister.Selected(Index :Word);
begin
  Message(Owner, spCommand, cmAccept, nil);
end; { TFileLister.Selected }

procedure TFileLister.BarChanged;
begin
  Message(Owner, spNotify, msgFileChanged, nil);
end; { TFileLister.BarChanged }

{****************************************************************************}
{*  TDirLister                                                              *}
{*  The DirLister Object is a view object providing a scrollable list of    *}
{*  directory names obtained from the current directory                     *}
{****************************************************************************}
constructor TDirLister.Init;
 var B :TBounds;
begin
  B.Assign(160, 50, 280, 140);
  inherited Init(B, GetDirs);
end; { TDirLister.Init }

{ Called whenever the current path has changed. Constructs a new list
  of Items and then notifies the owner of the List object }
procedure TDirLister.Update;
begin
  NewItems(GetDirs);
  Message(Owner, spNotify, msgDirChanged, nil);
end; { TDirLister.Update }

function TDirLister.GetString(Index :Word) :String;
  var P :PFileItem;
begin
  P := PFileItem(ItemPtr(Index));
  if P <> nil then GetString := P^.Name else GetString := '';
end; { TDirLister.Getstring }

procedure TDirLister.Selected(Index :Word);
  var Dir :TDirStr;
      B :TBounds;
begin
  { Change to newly selected directory }
  Dir := GetString(Index);
  if Dir = 'No Sub-Dirs' then exit;
  {$I-}
  ChDir(Dir);
  { Display error Message if Error }
  if (IOResult <> 0) then
  begin
    B.Assign(125,200,515,300);
    MessageWindow(B, #3'Gids ongeldig of aandrywer nie gereed',
                  mwfError+mwfOk);
  end
  { Update if no error }
  else Update;
  {$I+}
end; { TDirLister.Selected }

{****************************************************************************}
{*  TDriveLister                                                            *}
{*  The DriveLister Object is a view object providing a scrollable list of  *}
{*  all the valid drives on the computer, as well as their volume labels    *}
{****************************************************************************}
constructor TDriveLister.Init;
  var B :TBounds;
begin
  B.Assign(290, 50, 420, 140);
  inherited Init(B, GetDrives);
end; { TDriveLister.Init }

{ Updates the scrollers list by calling Update.
  Then it notifies the owner of the View object }
procedure TDriveLister.Update;
begin
  NewItems(GetDrives);
  Message(Owner, spNotify, msgDriveChanged, nil);
end; { TDriveLister.Update }

function TDriveLister.GetString(Index :Word) :string;
begin
  with PDriveItem(ItemPtr(Index))^ do
    GetString := Drive + ': ' + Volume;
end; { TDriveLister.GetString }

procedure TDriveLister.Selected(Index :Word);
  var Drive :Char;
      B :TBounds;
begin
  if Count > 0 then Drive := PDriveItem(Items^.At(Index))^.Drive;
  if Drivevalid(Drive) then
  begin
    {$I-}

    ChDir(Drive+':');
    {$I+}
    { Display error Message on error }
    if (IOResult <> 0) or (DiskSize(ord(Drive)-64) < 1) then
    begin
      B.Assign(125,200,515,300);
      MessageWindow(B, #3'Aandrywer ongeldig of nie gereed',  mwfError+mwfOk)
    end
    { Update if no error }
    else Update;
  end;
end; { TDriveLister.Selected }

{****************************************************************************}
{*  TSetLister                                                              *}
{*  The SetLister Object is a view group using all of the above views to    *}
{*  implement a Open file toolbox.                                          *}
{****************************************************************************}
constructor TSetLister.Init(InLoadMode :Boolean);
  var B :TBounds;
      S :String[80];
  const ValidFileChars = [#32..#255] -
                         [';','''','=','+','<','>','|','"','[',']','\'];
begin
  B.Assign(20, 100, GetMaxX-22, 280);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable;
  GetDir(0, S);
  PrevPath := NewStr(S);
  LoadMode := InLoadMode;
  Lock;
  { Lists }
  New(FileList, Init);
  New(DirList, Init);
  New(DriveList, Init);
  Append(FileList);
  Append(DirList);
  Append(DriveList);
  { NameLine }
  B.Assign(440, 50, Size.X-30, 70);
  NameLine := New(PInputLine, Init(B, 12,
                  FileList^.GetString(FileList^.CurStr), ValidFileChars));
  Append(NameLine);
  { Buttons }
  B.Assign(440, 80, Size.X-30, 110);
  if LoadMode then S := 'Laai Lˆer' else S := 'Stoor Lˆer';
  Append(New(PButton, Init(B, S, cmAccept, 0)));
  B.Assign(440, 120, Size.X-30, 140);
  Append(New(PButton, Init(B, 'Kanselleer', cmCancel, 0)));
  B.Assign(440, 120, Size.X-30, 140);
  InfoPane := New(PInfoPane, Init);
  Append(InfoPane);
  SelectNext;
  { update the object self }
  Message(@Self, spNotify, msgFileChanged, nil);
  Unlock;
end; { TSetLister.Init }

destructor TSetLister.Done;
begin
  {$I-}
  ChDir(PrevPath^);
  If IOResult <> 0 then
    Abort('Fatal Error :Disk not Ready --- TSetLister.Done');
  {$I+}
  DisposeStr(PrevPath);
  inherited done;
end; { TSetLister.Done }

procedure TSetLister.Art;
  var C :Byte; S:String[20];
      P :PBitImage;
begin
  if LoadMode then
  begin
    C := $0C;
    S := 'TestMaker Lˆer Open';
  end
  else
  begin
    C := $09;
    S := 'TestMaker Leˆr Stoor';
  end;
  Platform(0, 0, Size.X, Size.Y, $F808);
  Platform(5, 5,  Size.X-5, Size.Y-5, LowerGrey);
  Platform(6, 6,  Size.X-6, 26, $F000+C);
  WriteStrXY(Size.X shr 1, 12, $1E, 2, 5, JustCenter, False, S);
  { Tags }
  WriteStrXY(90, 45, ShadowWhite, 1, 1, JustCenterX+JustBottom, False, 'Leˆrs:');
  WriteStrXY(230, 45, ShadowWhite, 1, 1, JustCenterX+JustBottom, False, 'Dirs:');
  WriteStrXY(360, 45, ShadowWhite, 1, 1, JustCenterX+JustBottom, False, 'Aandrywers:');
  WriteStrXY(490, 45, ShadowWhite, 1, 1, JustCenterX+JustBottom, False, 'Naam:');
  P := PBitImage(GetResource('Papers1'));
  if P <> nil then
  begin
    P^.Put(445, 142, XorPut);
    P^.Put(475, 142, XorPut);
    P^.Put(505, 142, XorPut);
    P^.Put(535, 142, XorPut);
    Dispose(P, Done);
  end;
end; { TSetLister.Art }

procedure TSetLister.Listen(var Speech :TSpeech);

    { Updates the FileName Input Line }
    procedure UpdateNameLine;
      var S :String[12];
    begin
      S := SRemoveCh(FileList^.GetString(FileList^.CurStr), ' ');
      NameLine^.SetData(S);
    end;

    { Updates the FileList and Info Pane on a directory change }
    procedure UpdateDirChange;
      var Info :TTinfoPane;
          S :String;
    begin
      FileList^.Update;
      with info do
      begin
        tMask := SUpper(FileList^.Mask^);
        GetDir(0, S);
        tDirectory := S;
      end;
      InfoPane^.SetData(Info);
    end;

    { Called when the user chooses a certain filename to be opened }
    Procedure AcceptFile;
      var S :String[12];
          S2 :String[79];
    begin
      NameLine^.GetData(S);
      if S = '' then Exit;
      if (SFScan(S, '*') > 0) or (SFScan(S, '?') > 0) then
      begin
        with FileList^ do
        begin
          if Mask <> nil then DisposeStr(Mask);
          Mask := NewStr(S);
        end;
        UpdateDirChange;
      end
      else
      begin
        GetDir(0, S2);
        if S2[Length(S2)] = '\' then Dec(S2[0]);
        if SetFileName(S2+'\'+S) then EndModal(cmAccept);
      end;
    end;

begin { TSetLister.Listen }
  Case Speech.Tone of
    spCommand :
      case Speech.What of
        cmAccept :AcceptFile;
        cmCancel :EndModal(cmCancel);
        else begin inherited Listen(Speech); exit; end;
      end;
    spNotify :
      case Speech.What of
        msgFileChanged  :UpdateNameLine;
        msgDirChanged   :UpdateDirChange;
        msgDriveChanged :DirList^.Update;
        else begin inherited Listen(Speech); exit; end;
      end;
  end;
  SpeechHeard(Speech);
end; { TSetLister.Listen }

function TSetLister.SetFileName(Name :String) :boolean;
  var f :File;
      B :TBounds;
begin
  SetFileName := True;
  { Add a .TMS extention if none exists }
  if SFScan(Name, '.') = 0 then Name := Name+'.TMS';
  if LoadMode then
  begin
    { Display error if no such file exists }
    if not FileExists(Name) then
    begin
      B.Assign(125,200,515,300);
      MessageWindow(B, #3'Lˆer kon nie gevind word nie', mwfError+mwfOk);
      SetFileName := False;
      Name := '';
      NameLine^.SetData(Name);
      Exit;
    end;
  end {if}
  else
  begin
    { Confirm Overwrite }
    if FileExists(Name) then
    begin
      B.Assign(125,200,515,300);
      if MessageWindow(B, #3'Herskryf '+GetFileNameOnly(Name)+' ?',
                       mwfConfirmation+mwfYes+mwfNo) = cmNo then
      begin
        SetFileName := False;
        Exit;
      end;
    end;{if}
  end;{else}
  { Do not set global filename if not valid }
  if not PaperData^.ValidFilename(Name) then
  begin
    SetFileName := False;
    PaperData^.NotifyOfError;
  end {if}
  else
  begin
    SetFilename := True;
    if LoadMode then
    begin
      Dispose(PaperData, Done);
      New(PaperData, Init(Name));
    end
    else
    begin
      DisposeStr(PaperData^.FileName);
      PaperData^.FileName := NewStr(Name);
    end;
  end; {else}
end; { TSetLister.SetFileName }


{****************************************************************************}
{*  TModeSelector                                                           *}
{*  The Modeselector is a menu view object providing scrollable buttons for *}
{*  the main menu options, producing a command by means of the buttons when *}
{*  a option is chosen.                                                     *}
{****************************************************************************}
constructor TModeSelector.Init;
  var B :TBounds;
begin
  B.Assign(20, 130, GetMaxX-22, 400);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable;
  { Add Buttons }
  Lock;
  B.Assign(25, 25, 240, 75);
  Append(New(PButton, Init(B, 'Stel ''n Toets Op', cmEditMenu, hcButOpstel)));
  B.Assign(25, 80, 240, 130);
  Append(New(PButton, Init(B, 'Doen ''n Toets', cmTest, hcButTest)));
  B.Assign(25, 135, 240, 185);
  Append(New(PButton, Init(B, 'Maak ''n Uitdruk', cmPrintMenu, hcButPrint)));
  B.Assign(25, 190, 240, 240);
  Append(New(PButton, Init(B, 'Verlaat TestMaker', cmQuit, hcButVerlaat)));
  SelectNext;
  Unlock;
end; { TModeSelector.Init }

destructor TModeSelector.Done;
begin
  Inherited Done;
end; { TModeSelector.Done }

procedure TModeSelector.Art;
  var P :PBitImage;
begin
  Platform(0, 0, Size.X, Size.Y, RaiseGrey);
  Level(260, 15, Size.X-15, Size.Y-15, RaiseGrey);
  Platform(15, 15, 250, Size.Y-15, LowerGrey+$80);
  P := PBitImage(GetResource('IntroLogo'));
  if P <> nil then
  begin
    P^.Put(265, 20, NormalPut);
    Dispose(P, Done);
  end;
end; { TModeSelector.Art }

procedure TModeSelector.KeybordInput(var Input :TKeybordInput);
begin
  inherited KeybordInput(Input);
  case Input.Keycode of
    kbUp   :SelectPrevious;
    kbDown :SelectNext;
  end;
end; { TModeSelector.KeybordInput }

procedure TModeSelector.GotFocus;
begin
  PutMessage(spCommand, cmStatustext, NewStr('Testmaker Hoofmenu : Kies asseblief ''n modus'));
end;

{****************************************************************************}
{*  Routines                                                                *}
{****************************************************************************}

{ GetFiles obtain a list of all the files in the current directory
  and save it in a PFileCollection type }
function GetFiles(Mask :TFileName) :PFileCollection;
  var Files    :PFileCollection;
      FileInfo :SearchRec;
      FileItem :PFileItem;

    { Insert spaces into the filename, ensuring it is 12 characters wide }
    procedure PadName(var FileItem :TFileItem);
      var S :TFileStr;
          DotPos :Byte;
    begin
      S := FileItem.Name;
      DotPos := SFScan(S, '.');
      if DotPos = 0 then Exit;
      SSetLen(FileItem.Name, DotPos - 1);
      System.Delete(S, 1, DotPos-1);
      FileItem.Name := SPad(FileItem.Name, ' ', 8);
      FileItem.Name := Concat(FileItem.Name, S);
    end;

    { Copies FileRec into FileItem }
    procedure Transfer(FileRec :SearchRec; var FileItem :TFileItem); assembler;
      const Size = Sizeof(TFileItem);
    asm
      PUSH DS
      LDS  SI, FileRec
      LES  DI, FileItem
      ADD  SI, 21            { Set Pointer to Attr field of FileRec }
      MOV  CX, Size
      REP  MOVSB             { Copy }
      POP  DS
    end;

begin
  { construct List }
  New(Files, Init(20, 5));
  { Fill List }
  FindFirst(Mask, Hidden+Archive, FileInfo);
  while DosError = 0 do
  begin
    New(FileItem);
    Transfer(FileInfo, FileItem^);
    PadName(FileItem^);
    Files^.Insert(FileItem);
    FindNext(FileInfo);
  end;
  { Return Value }
  GetFiles := Files;
end; { procedure GetFiles }

{ GetDirs obtains the names of the sub-directories in the current directory
  and sets up a list. }
function GetDirs :PFileCollection;
  var DirInfo :SearchRec;
      DirItem :PFileItem;
      Dirs    :PFileCollection;
      S       :String;

    { Insert spaces into the filename, ensuring it is 12 characters wide }
    procedure PadName(var FileItem :TFileItem);
      var S :TFileStr;
          DotPos :Byte;
    begin
      S := FileItem.Name;
      DotPos := SFScan(S, '.');
      if (DotPos = 0) or (DotPos = 1) then Exit;
      SSetLen(FileItem.Name, DotPos - 1);
      System.Delete(S, 1, DotPos-1);
      FileItem.Name := SPad(FileItem.Name, ' ', 8);
      FileItem.Name := Concat(FileItem.Name, S);
    end;

    { Copies FileRec into FileItem }
    procedure Transfer(FileRec :SearchRec; var FileItem :TFileItem); assembler;
      const Size = Sizeof(TFileItem);
    asm
      PUSH DS
      LDS  SI, FileRec
      LES  DI, FileItem
      ADD  SI, 21            { Set Pointer to Attr field of FileRec }
      MOV  CX, Size
      REP  MOVSB             { Copy }
      POP  DS
    end;

begin
  { construct list }
  New(Dirs, Init(10, 2));
  { Fill List }
  FindFirst('*.*', Directory, DirInfo);
  while DosError = 0 do
  begin
    with DirInfo do
      if (Name <> '.') and (Attr = Directory) then
      begin
        New(DirItem);
        Transfer(DirInfo, DirItem^);
        PadName(DirItem^);
        Dirs^.Insert(DirItem);
      end;
    FindNext(DirInfo);
  end;
  GetDirs := Dirs;
end; { Getdirs }

{ Fills a List with the names and volumes of all the valid drives
  on the computer. }

function GetDrives :PDriveCollection;
  var I :Char;
      DriveItem :PDriveItem;
      Drives    :PDriveCollection;
      VolInfo   :SearchRec;
begin
  New(Drives, Init(3, 1));
  for I := 'A' to 'Z' do
  if PhysDriveValid(I) then
  begin
    FindFirst(I+':\*.*', VolumeID, VolInfo);
    if Doserror = 0 then VolInfo.Name := SRemoveCh(VolInfo.Name, '.')
    else VolInfo.Name := 'Geen Volume';
    { set record }
    New(DriveItem);
    with DriveItem^ do
    begin
      Drive  := I;
      Size   := DiskSize(ord(I)-64);
      if Size > 0 then
      begin
        Volume := VolInfo.Name;
        Free   := DiskFree(ord(I)-64)
      end
      else
      begin
        Free := 0;
        Volume := 'Nie Gereed';
      end;
    end;
    Drives^.Insert(DriveItem);
  end;
  GetDrives := Drives;
end; { GetDrives }


end. { Unit }