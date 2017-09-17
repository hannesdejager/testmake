  {****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{****************************************************************************}
Unit Main;
  {$F+,O+,Q-,R-,S-}

Interface
  Uses Objects, sGraph, Graph, sView, sInput,  STDViews, sTypes,
       Selector, consts, EditMode, TMData;

{***þ StatusLine object þ***}
type
  PStatusLine = ^TStatusLine;
  TStatusLine = Object(Tview)
    Text :PString;
    constructor Init(TextStr :String);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   DisplayText(TextStr :String);
  end;

{***þ HelpViewer þ***}
type
  PHelpViewer =^THelpViewer;
  THelpViewer = Object(TViewGroup)
    Helpfile :PHelpFile;
    Context  :Word;
    constructor Init(HlpFile :PHelpFile; Ctx :Word);
    procedure   Art; virtual;
    procedure   Listen(var Speech :TSpeech); virtual;
  end;

{***þ Program controller object þ***}
type
  PProgram = ^TProgram;
  TProgram = Object(TViewGroup)
    Active :PViewGroup;
    constructor Init;
    destructor  Done;      virtual;
    procedure   Art;       virtual;
    procedure   Listen(var Speech :TSpeech); virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    procedure   MouseInput(var Input :TMouseInput); virtual;
    procedure   Run;
    procedure   NewActive(New :PViewGroup);
    function    ConfirmSave :Word;
    procedure   NewSet(Name :String);
    procedure   LoadSet;
    procedure   SaveSet;
    procedure   SaveSetAs;
    procedure   AboutMessage;
    procedure   LoadConfig;
    procedure   SaveConfig;
  end;

{***þ Initialized variables þ***}
const
  Application :PProgram       = nil;
  StatusLine  :PStatusLine    = nil;
  CurrentItem :Word           = 0;
  CurrentMode :Byte           = 0;
  Access      :Boolean        = False;


Implementation
  uses sBasic, sProcs, PrnMode, graphics, sInts, Testmode;

{****************************************************************************}
{*  StatusLine                                                             *}
{****************************************************************************}
constructor TStatusLine.Init(TextStr :String);
  var B :TBounds;
begin
  StatusLine := @Self;
  B.Assign(0, 450, GetMaxX, GetMaxY);
  Inherited Init(B);
  Text := NewStr(TextStr);
end;

destructor TStatusLine.Done;
begin
  DisposeStr(Text);
  inherited Done;
end;

Procedure TStatusLine.Art;
begin
  Platform(0, 0, Size.X, Size.Y, RaiseGrey);
  Platform(5, 5, Size.X-5, Size.Y-5, LowerGrey);
  if Text <> nil then WriteStrXY
    (20, 12, ShadowWhite, 0, 1, JustLeft+JustTop, False, Text^);
end;

{ Displays the text TextStr on the statusline }
Procedure TStatusLine.DisplayText(TextStr :String);
begin
  DisposeStr(Text);
  Text := NewStr(TextStr);
  Draw;
end;

{****************************************************************************}
{*  THelpViewer                                                            *}
{****************************************************************************}
constructor THelpViewer.Init(HlpFile :PHelpFile; Ctx :Word);
  var B :TBounds;
begin
  B.Assign(50, 120, GetMaxX-50, GetMaxY-50);
  inherited Init(B);
  Context := Ctx;
  Lock;
  B.Assign(100, Size.Y-30, Size.X-100, Size.Y-10);
  Append(New(Pbutton, Init(B, 'Sluit Hulp Venster', cmHelpClose, 0)));
  HelpFile := HlpFile;
  Unlock;
end;

procedure THelpViewer.Art;
  var S :String;
      Y :Integer;
begin
  Platform(0, 0, Size.X, Size.Y,  $F008);
  Platform(5, 5, Size.X-5, Size.Y-5,  $8B03);
  { Draw Caption }
  Platform(6, 6, Size.X-6, 26,  $F807);
  Platform(10, 35, Size.X-10, Size.Y-40,  $0B03);
  WriteStrXY(Size.X shr 1, 13, $0E, 2, 5, JustCenter,
    False, 'Testmaker Hulp Stelsel');
  S := '';
  Y := 40;
  HelpFile^.ScanToCtx(Context);
  while (Y < Size.Y-45) and
        not(HelpFile^.CtxEnd) and
        not(HelpFile^.ErrorVal <> HelpFile_Ok) do
  Begin
    S := HelpFile^.ReadLine;
    SSetLen(S, MinByte(Length(S), (Size.X-30) div TextWidth('X')));
    WriteStrXY(15, Y, $1F, 0, 1, 0, False, S);
    Inc(Y, TextHeight(S));
  end; {while}
end; { THelpviewer.Art }

procedure THelpViewer.Listen(var Speech :TSpeech);
begin
  if Speech.Tone = spCommand then
    if Speech.What = cmHelpClose then
    begin
      EndModal(cmHelpClose);
      SpeechHeard(Speech);
    end; {if}
end; { THelpViewer.Listen }

{****************************************************************************}
{*  TProgram                                                               *}
{****************************************************************************}
constructor TProgram.Init;
  var B :TBounds;
begin
  StartUpDir := NewStr(GetExeDir);
  Application := @Self;
  { Initialize systems }
  InitGraphics;
  InitInput;
  { Initialize self }
  B.Assign(0, 0, GetMaxX, GetMaxY);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable;
  { Set DataFile name to noname }
  NewSet('NAAMLOOS.TMS');
  { Add Views }
  Lock;
  { Add StatusLine }
  Append(New(PStatusLine, Init('Welkom by Testmaker - Kies asseblief ''n Opsie')));
  { Add and set active view }
  Active := New(PModeSelector, Init);
  Append(Active);
  Unlock;
end;

procedure TProgram.Run;
begin
  Execute;
end;

destructor TProgram.Done;
begin
  Dispose(PaperData, Done);
  Inherited Done;
  DoneInput;
  DoneGraphics;
  DisposeStr(StartUpDir);
end;

procedure TProgram.Art;
  var P :PBitImage;
begin
  PlatForm(0, 0, Size.X, Size.Y, 0);
  Platform(0, 0, 110, 90, RaiseGrey);
  Platform(530, 0, getMaxX, 90, RaiseGrey);
  Platform(125, 0, 515, 70, RaiseGrey);
  WriteStrXY(140, 60, ShadowWhite, 1, 2, JustBottom+JustLeft, True, 'TEST');
  WriteStrXY(175, 55, ShadowWhite, 1, 7, JustBottom+JustTop, False, 'MAKER');
  P := PBitImage(GetResource('Book1'));
  if P <> nil then
  begin
    P^.Put(10, 10, XorPut);
    P^.Put(40, 30, XorPut);
    P^.Put(70, 50, XorPut);
    Dispose(P, Done);
  end; {if}
end; { TProgram.Art }

procedure TProgram.Listen(var Speech :TSpeech);

     { Pops up a Password input window }
     function GetPassword :Boolean;
       var B :TBounds;
     begin
       GetPassword := True;
       if Access then Exit;
       if ExecView(New(PPasswordWin,
         Init(PaperData^.Descript.Password))) = cmYes then
       begin
         GetPassword := True;
         Access := True;
       end {if}
       else
       begin
         GetPassword := False;
         B.Assign(125,200,515,300);
         MessageWindow(B, #3'Wagwoord nie korrek.'#13#3'Toegang geweier.',
         mwfError+mwfOk);
       end; {else}
     end; {sub func GetPassword }

     { Starts to print a Testmaker setfile }
     procedure StartPrinting;
     begin
       Active^.GetData(PrintSettings);
       if PaperData^.Descript.Mask and PrintSettings.Combo <> 0 then
         if GetPassword then PrnMode.StartPrinting else
       else PrnMode.StartPrinting;
     end; { sub proc StartPrinting }

     { Closes the editmode, selector mode etc. }
     procedure DoneMode(EditMode :Boolean);
     begin
       if EditMode then
       begin
         Speech.What := ConfirmSave;
         if Speech.What = cmYes then SaveSet
         else if Speech.What = cmCancel then Exit;
       end; {if}
       if Active^.Valid(cmTerminate) then
       NewActive(New(PModeSelector, Init));
       CurrentMode := TMMode_None;
     end; { sub proc DoneMode }

     { Executes the Printer options window }
     procedure PrintOptionsWin;
     begin
       LoadConfig;
       NewActive(New(PPrintOptionsWin, Init));
       Active^.SetData(PrintSettings);
       if PaperData^.FileName^ = 'NAAMLOOS.TMS' then LoadSet;
       if PaperData^.FileName^ = 'NAAMLOOS.TMS' then DoneMode(False);
     end; { sub proc PrintOptionsWin }

     { Display the help context discribed in Speech.Infoword }
     procedure HelpDisplay;
       var HlpFile :THelpFile;
     begin
       with HlpFile do
       begin
         Init;
         ScanToCtx(Speech.InfoWord);
         if Errorval = HelpFile_Ok then
           ExecView(New(PHelpViewer, Init(@HlpFile, Speech.InfoWord)));
         Done;
       end; {with}
     end; { Sub proc HelpDisplay }

begin { TProgram.Listen }
  if Speech.Tone <> spNone then
  case Speech.What of
    cmSelectionMenu :NewActive(New(PModeSelector, Init));
    cmEditMenu :
      begin
        if PaperData^.Descript.Mask and Pass_Edit <> 0 then
          if GetPassword then NewActive(New(PEditMode, Init)) else
        else NewActive(New(PEditMode, Init));
      end;
    cmTest  :
      begin
        if PaperData^.Descript.Mask and Pass_Edit <> 0 then
          if GetPassword then NewActive(New(PTestMode, Init)) else
        else NewActive(New(PTestMode, Init));
      end;
    cmPrintMenu     :PrintOptionsWin;
    cmDoneEditMode  :DoneMode(True);
    cmDoneMode      :DoneMode(False);
    cmDonePrnWin :
      begin
        Active^.GetData(Printsettings);
        SaveConfig;
        DoneMode(False);
      end;
    cmSaveSetFile   :SaveSet;
    cmSaveSetFileAs :SaveSetAs;
    cmLoadSetFile   :LoadSet;
    cmAboutMessage  :AboutMessage;
    cmStartPrinting :StartPrinting;
    cmStatusText :
      begin
        StatusLine^.DisplayText(Speech.InfoPString^);
        DisposeStr(Speech.InfoPString);
      end;
    cmPrinterConfig :
      begin
        Lock;
        Active^.GetData(Printsettings);
        NewActive(New(PPrinterConfigWin, Init));
        Active^.SetData(Printsettings.CharsPL);
        Unlock;
        Draw;
      end;
    cmAcceptPrnCnf :
      begin
        Active^.GetData(PrintSettings.CharsPl);
        SaveConfig;
        PrintOptionsWin;
      end;
    cmCancelPrnCnf :PrintOptionsWin;
    cmPasswordProtect :GetPassword;
    cmHelpDisplay :HelpDisplay;
    else begin inherited Listen(Speech); exit; end;
  end;
  SpeechHeard(Speech);
end; { TProgram.Listen }

procedure TProgram.KeybordInput(var Input :TKeybordInput);
begin
  inherited KeybordInput(Input);
  if Input.What <> inNothing then
  Case Input.KeyCode of
    kbF9 :Message(Active, spCommand, cmToggleMenu, nil);
    kbLeft, kbUp :Message(Active, spCommand, cmSelectPrev, nil);
    kbRight, kbDown :Message(Active, spCommand, cmSelectNext, nil);
  end;
end;

procedure TProgram.MouseInput(var Input :TMouseInput);
  var HelpViews :Array[1..3] of TBounds;
      Clicked   :Byte;
begin
  inherited MouseInput(Input);
  if Input.What and inMouseDown <> 0 then
  begin
    HelpViews[1].Assign(0, 0, 110, 90);
    HelpViews[2].Assign(125,1,515,70);
    HelpViews[3].Assign(530, 0, getMaxX, 90);
    for Clicked := 1 to 3 do
      if HelpViews[Clicked].WithIn(Input.Where) then
      begin
        Case Clicked of
          1 :PutMessage(spCommand, cmHelpDisplay, Ptr(0, 1));
          2 :PutMessage(spCommand, cmAboutMessage, nil);
        end;{case}
        InputHandled(Input);
      end; {if}
  end; {if}
end; { TProgram.MouseInput }

 { Executes a new sub view or Mode }
procedure TProgram.NewActive(New :PViewGroup);
begin
  Lock;
  Delete(Active);
  Active := New;
  Append(Active);
  Unlock;
  Draw;
end;

 { Opens a new setfile. It first asks if the currently opened file must be closed. }
procedure TProgram.NewSet;
begin
  if PaperData <> nil then
  begin
    case ConfirmSave of
      cmCancel :Exit;
      cmYes    :PaperData^.Save;
      cmNo     :;
     end;{case}
    Dispose(PaperData, Done);
  end;{if}
  New(PaperData, Init(Name));
end;  { TProgram.NewSet }

{ Loads a Testmaker setfile }
procedure TProgram.LoadSet;
begin
  { Ask if current setfile should be saved }
  case ConfirmSave of
    cmCancel :Exit;
    cmYes    :PaperData^.Save;
    cmNo     :;
  end;
  case ExecView(New(PSetLister, Init(True))) of
    cmAccept :
      begin
        Lock;
        Message(Active, spCommand, cmDoneEditorActive, nil);
        PaperData^.Load;
        Unlock;
        Active^.Draw;
        Access := False;
      end;
    cmCancel :;
  end;{case}
end; { TProgram.LoadSet }

{ Saves the active setfile }
procedure TProgram.SaveSet;
begin
  if PaperData^.FileName^ = 'NAAMLOOS.TMS' then SaveSetAs
  else
  begin
    Message(Active, spCommand, cmGetViewData, nil);
    PaperData^.Save;
    Unlock;
  end; {else}
end; { TProgram.SaveSet }

{ Saves the current setfile to another name }
procedure TProgram.SaveSetAs;
begin
  PaperData^.Modified := True;
  case ExecView(New(PSetLister, Init(False))) of
    cmAccept :
      begin
        Message(Active, spCommand, cmGetViewData, nil);
        PaperData^.Save;
      end;
    cmCancel :;
  end; {case}
end; { TProgram.SaveSetAs }

{ Pops up a confirmationbox which asks whether to save
  the current setfile or not }
function TProgram.ConfirmSave :Word;
  var B :TBounds;
begin
  if not PaperData^.Modified then
  begin
    ConfirmSave := cmNo;
    Exit;
  end;
  B.Assign(125, 200, 515, 300);
  ConfirmSave :=
    MessageWindow(B, #3'Stoor '+PaperData^.GetTruncFileName+'?',
      mwfConfirmation+mwfYes+mwfNo+mwfCancel)
end; { TProgram.ConfirmSave }

{ Pops up the About Testmaker Window }
procedure TProgram.AboutMessage;
  var B :TBounds;
begin
  B.Assign(120,100,500,350);
  MessageWindow(B, #3'Testmaker Weergawe 1.0 - Demonstrasie Program'#13+
                   #13+
                   #13+
                   #3'Alle Programmering gedoen deur:'#13+
                   #13+
                   #3'Hannes de Jager'#13+
                   #3'Posbus 112'#13+
                   #3'Reitz'#13+
                   #3'9810'#13+
                   #3'Tel: (058) 86 31304'#13+
                   #13+
                   #13+
                   #3'Grafika Sketsies verkry by Cedric Sceepers.'+
                   #3'Kontak my indien u enige vrae of aanbevelings het.',
                    mwfInformation+mwfOk);
end; { TProgram.AboutMessage }

{ Loads the Printsettings from the configuration file }
procedure TProgram.LoadConfig;
  var F :File of TPrintSettings;
      B :TBounds;
begin
  {$I-}
  Assign(F, StartUpDir^+CnfFile_Name);
  Reset(F);
  Read(F, PrintSettings);
  Close(F);
  {$I+}
  if IOResult <> 0 then
  begin
    B.Assign(125, 200, 515, 300);
    MessageWindow(B, #3'Kon nie drukker konfigurasie laai nie.'#13+
                     #3'Oorspronklike konfigurasie word gebruik',
                      mwfError+mwfOk);
  end;
end; { TProgram.LoadConfig }

{ Saves the Printsettings to the configuration file }
procedure TProgram.SaveConfig;
  var F :File of TPrintSettings;
      B :TBounds;
begin
  {$I-}
  Assign(F, StartUpDir^+CnfFile_Name);
  Rewrite(F);
  Write(F, PrintSettings);
  Close(F);
  {$I+}
  if IOResult <> 0 then
  begin
    B.Assign(125, 200, 515, 300);
    MessageWindow(B, 'Kon nie drukker konfigurasie stoor nie.',
                      mwfError+mwfOk);
  end; {if}
end; { TProgram.SaveConfig }

end. { Unit }