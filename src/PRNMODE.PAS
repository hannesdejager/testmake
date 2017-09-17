{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{  Contains all the code used to implement the Print Mode of Testmaker      *}
{****************************************************************************}
Unit PrnMode;
  {$F+,O+,Q-,R-,S-}

{ This Unit implements all the code used for the PRINT MODE of
  Testmaker. }

Interface
  uses Objects, sBasic, sView, STDViews, consts;

{***þ Available Printer types þ***}
const
  ASCIIPrinter   = 0;
  EpsonPrinter   = 1;
  HPLaserPrinter = 2;
  PostScrPrinter = 3;
  IBMPrinter     = 4;

{***þ Available Text Styles þ***}
const
  Style_Normal    = $00;
  Style_Bold      = $01;
  Style_Italic    = $02;
  Style_UnderLine = $04;

{***þ Printer States þ***}
const
  Prn_TimedOut    = $01;
  Prn_IOError     = $08;
  Prn_Selected    = $10;
  Prn_OutOfPaper  = $20;
  Prn_Acknowledge = $40;
  Prn_NotBusy     = $80;
  Prn_Ready       = Prn_Selected+Prn_NotBusy; { not a mask }

{***þ PrinterCodes þ***}
const
  ASCIIEndLine  = #13#10;
  ASCIIEndPage  = #12;

  EpsonInit      = #17#27'@';
  EpsonDone      = '';
  EpsonItalic    = #27'4';
  EpsonNoItalic  = #27'5';
  EpsonBold      = #27'E'#27'G';
  EpsonNoBold    = #27'F'#27'H';
  EpsonULine     = #27'-'#1;
  EpsonNoULine   = #27'-'#0;
  EpsonHQuality  = #27'x'#1;
  EpsonDraft     = #27'x'#0;
  EpsonEndLine   = ASCIIEndLine;
  EpsonStartPage = '';
  EpsonEndPage   = ASCIIEndPage;

  HPInit         = #27'E'#27'(10U'#27'&k0S'#27'(s3T';
  HPDone         = #12;
  HPItalic       = #27'(s1S';
  HPNoItalic     = #27'(s0S';
  HPBold         = #27'(s3B';
  HPNoBold       = #27'(s0B';
  HPULine        = #27'&dD';
  HPNoULine      = #27'&d@';
  HPHQuality     = '';
  HPDraft        = '';
  HPEndLine      = EpsonEndLine;
  HPStartPage    = EpsonStartPage;
  HPEndPage      = EpsonEndPage;

  PSInit1        = #4'%!PS-Adobe-3.0'#13#10'initgraphics'#13#10+
                   +'/fnr /Courier findfont 10 scalefont def'#13#10
                   +'/fni /Courier-Oblique findfont 10 scalefont def'#13#10
                   +'/fnb /Courier-Bold findfont 10 scalefont def'#13#10;
  PSInit2        =  '/fnbi /Courier-BoldOblique findfont 10 scalefont def'#13#10
                   +'/newl {20 currentpoint exch pop 12 sub moveto} def'#13#10
                   +'/newp {20 765 moveto} def'#13#10
                   +'fnr setfont'#13#10;
  PSDone         = #4;
  PSNormal       = 'fnr setfont'#13#10;
  PSItalic       = 'fni setfont'#13#10;
  PSBold         = 'fnb setfont'#13#10;
  PSBoldItalic   = 'fnbi setfont'#13#10;
  PSULine        = '';
  PSNoULine      = '';
  PSHQuality     = '';
  PSDraft        = '';
  PSEndLine      = 'newl'#13#10;
  PSStartPage    = 'newp'#13#10;
  PSEndPage      = 'showpage'#13#10;
  PSPreData      = '(';
  PSPostData     = ') show'#13#10;

  IBMInit       = #17;
  IBMDone       = '';
  IBMItalic     = '';
  IBMNoItalic   = '';
  IBMBold       = EpsonBold;
  IBMNoBold     = EpsonNoBold;
  IBMULine      = EpsonULine;
  IBMNoULine    = EpsonNoULine;
  IBMHQuality   = EpsonHQuality;
  IBMDraft      = EpsonDraft;
  IBMEndLine    = EpsonEndLine;
  IBMStartPage  = EpsonStartPage;
  IBMEndPage    = EpsonEndPage;


{***þ Print OutPut Errors þ***}
const
  PrintErr_NoError     = 0;
  PrintErr_Init        = 1;
  PrintErr_Write       = 2;
  PrintErr_Close       = 3;
  PrintErr_OutOfPaper  = 4;
  PrintErr_Busy        = 5;
  PrintErr_NotReady    = 6;

{***þ Print Settings record þ***}
type
  PPrintSettings = ^TPrintSettings;
  TPrintSettings = record
    Target   :Byte;        { Output target combination }
    FileName :String[79];  { Name of file to print to }
    Combo    :Byte;        { Paper component combination }
    CharsPl  :String[3];   { Characters per line }
    LinesPp  :String[2];   { Lines per page }
    Printer  :Byte;        { Printer type }
  end;

{***þ Print options window þ***
 This window lets the user spesify the following output options :
   þ Print to a file ?
   þ The filename of the file to print to.
   þ Output to Printer ?
   þ The paper component combination to print (Questionpaper, memmo and/or
     answering sheet).
   þ Enter another menu with Printer options. }
type
  PPrintOptionsWin = ^TPrintOptionsWin;
  TPrintOptionsWin = Object(TViewGroup)
    constructor Init;
    procedure   Art; virtual;
    procedure   GotFocus; virtual;
  end;

{***þ Printer options window þ***
 This window allows the user to spesify the following
   þ The Type of Printer in use
   þ The maximum amount of characters per line
   þ The maximum amount of lines per page. }
type
  PPrinterConfigWin = ^TPrinterConfigWin;
  TPrinterConfigWin = Object(TViewGroup)
    constructor Init;
    procedure   Art; virtual;
  end;

{***þ Print Target Oject þ***}
type
  PPrintTarget = ^TPrintTarget;
  TPrintTarget = Object(TObject)
    ColsperLine :Byte;
    Column      :Byte;
    LineCount   :Byte;
    LinesPerPage:Byte;
    PageCount   :Byte;
    Attributes  :Byte;
    ErrorValue  :Byte;
    constructor Init(Lines, Cols :Byte);
    procedure Advance(Pages, Lines, Cols :Integer); virtual;
    procedure Error(Code :Integer); virtual;
    procedure SetAttr(Attr :Byte; On :Boolean); virtual;
    procedure SendText(Text :String); virtual;
  end;

{***þ File Print Target Oject þ***}
type
  PFilePrintTarget = ^TFilePrintTarget;
  TFilePrintTarget = Object(TPrintTarget)
    TextFile :Text;
    constructor Init(Lines, Cols :Byte; FileName :String);
    destructor  Done; virtual;
    procedure   Advance(Pages, Lines, Cols :Integer); virtual;
    procedure   Error(Code :Integer); virtual;
    procedure   SendText(Text :String); virtual;
  end;

{***þ Printer Target Oject þ***}
type
  PPrinter = ^TPrinter;
  TPrinter = Object(TPrintTarget)
    Emulation :Byte;
    TextAttr  :Byte;
    constructor Init(Lines, Cols :Byte; AEmulation :Byte);
    destructor  Done; virtual;
    procedure Advance(Pages, Lines, Cols :Integer); virtual;
    procedure Error(Code :Integer); virtual;
    procedure SetAttr(Attr :Byte; On :Boolean); virtual;
    procedure SendText(Text :String); virtual;
    procedure ErrorOnStatus(Status :Byte);
    function  GetStatus :Byte;
    procedure SendCode(Code :String);
  end;


{ When all settings are set this procedure is called to start printing
  the document(s) }
  procedure StartPrinting;

{***þInitialized PrintSettings variable þ***}
const
  PrintSettings:TPrintSettings =
    (Target   :3;
     FileName :'DEMO.PAP';
     Combo    :QuestionPaper+AnsweringSheet+Memmo;
     CharsPL  :'70';
     LinesPP  :'55';
     Printer  :EpsonPrinter);


Implementation
  uses sGraph, Graph, sProcs, TMData, Dos, Quests, Strings, Printer, sInts;

{****************************************************************************}
{*  TPrintOptionsWin                                                        *}
{****************************************************************************}
constructor TPrintOptionsWin.Init;
  var B :TBounds;
      View :PView;
  const ValidFileChars = [#32..#255] -
                         [';','''','=','+','<','>','|','"','[',']'];
begin
  B.Assign(90, 150, GetMaxX-92, 360);
  inherited Init(B);
  ViewOptions := ViewOptions or voSelectable;
  Lock;
  { Add Output Destination Selection Cluster }
  B.Assign(20, 60, 140, 100);
  Append(New(PCluster, Init(B,
           NewLPString('Afvoer na Lˆer',
           NewLPString('Afoer na drukker',
           nil)), HcClustPrnTarget)));
  { Add FileName InputLine }
  B.Assign(Size.X-200, 60, Size.X-20, 80);
  View := New(PInputLine, Init(B, 79, '', ValidFileChars));
  View^.HelpCtx := HcILinePrnToFile;
  Append(View);
  { Add Output Destination Selection Cluster }
  B.Assign(20, 120, 165, 160);
  Append(New(PCluster, Init(B,
           NewLPString('Druk Vraestel Uit',
           NewLPString('Druk Antwoordblad Uit',
           NewLPString('Druk Memmorandum Uit',
           nil))), HcClustCombo)));
  { Add Buttons }
  B.Assign(20, Size.Y-30, 120, Size.Y-15);
  Append(New(PButton, Init(B, 'Begin Druk', cmStartPrinting, hcButStartPrn)));
  B.Assign(130, Size.Y-30, Size.X-240, Size.Y-15);
  Append(New(PButton, Init(B, 'Bronlˆer', cmLoadSetFile, hcButSourcefile)));
  B.Assign(Size.X-230, Size.Y-30, Size.X-110, Size.Y-15);
  Append(New(PButton, Init(B, 'Konfigurasie', cmPrinterConfig, hcButPrnConfig)));
  B.Assign(Size.X-100, Size.Y-30, Size.X-20, Size.Y-15);
  Append(New(PButton, Init(B, 'Verlaat', cmDonePrnWin, hcButPrnLeave)));
  SelectNext;
  Unlock;
end; { TPrintOptionsWin.Init }

procedure TPrintOptionsWin.Art;
  var P :PBitImage;
begin
  { Frame and title }
  Platform(0, 0, Size.X, Size.Y, $F808);
  Platform(5, 5,  Size.X-5, Size.Y-5, LowerGrey);
  Platform(6, 6,  Size.X-6, 26, $F002);
  WriteStrXY(Size.X shr 1, 12, $1E, 2, 5, JustCenter, False,
    'Uitdruk Opsies vir '+PaperData^.GetTruncFileName);
  { Divider Lines & Titles }
  WriteStrXY(Size.X shr 1, 45, $1F, 0, 1, JustCenter, False,
    'Afvoer Teiken');
  Line3D(10, 50, Size.X-10, 50, $8F);
  WriteStrXY(Size.X shr 1, 105, $1F, 0, 1, JustCenter, False,
    'Vraestel Komponent Kombinasie');
  Line3D(10, 110, Size.X-10, 110, $8F);
  Line3D(10, Size.Y-40, Size.X-10, Size.Y-40, $8F);
  { Filename label }
  WriteStrXY(Size.X-250, 70, $0E, 2, 4, JustLeft+JustCenterY, False,
    'Naam van Lˆer:');
  P := PBitImage(GetResource('Printer'));
  if P <> nil then
  begin
    P^.Put(10, 25, XorPut);
    Dispose(P, Done);
  end;
  P := PBitImage(GetResource('Papers1'));
  if P <> nil then
  begin
    P^.Put(210, 125, XorPut);
    P^.Put(250, 125, XorPut);
    P^.Put(290, 125, XorPut);
    Dispose(P, Done);
  end;
end; { TPrintOptionsWin.Art }

procedure TPrintOptionsWin.GotFocus;
begin
  PutMessage(spCommand, cmStatustext,
    NewStr('Testmaker afvoer modus: Spesifiseer afvoer opsies F1 - Hulp'));
end;


{****************************************************************************}
{*  TPrinterList                                                            *}
{*  This is a scrollable list of available printers                         *}
{****************************************************************************}
type
  PPrinterList = ^TPrinterList;
  TPrinterList = Object(TListScroller)
    constructor Init;
    function    Count :Word; virtual;
    function    DataSize :Word; virtual;
    function    GetString(Index :Word) :String; virtual;
    procedure   Getdata(var Rec); virtual;
    procedure   SetData(var Rec); virtual;
  end;

constructor TPrinterList.Init;
  var B :TBounds;
begin
  B.Assign(20, 125, 240, 165);
  Inherited Init(B, nil);
  HelpCtx := hcPrinterList;
end;

function TPrinterList.Count :Word;
begin
  Count := 5;
end;

function TPrinterList.GetString(Index :Word) :String;
begin
  case Index of
    0 :GetString := 'ASCII Teks drukker';
    1 :GetString := 'Epson en versoenbares';
    2 :GetString := 'Hewlet-Packard LaserJet en versoenbares';
    3 :GetString := 'ADOBE(R) PostScript(R)';
    4 :GetString := 'IBM Drukker';
  end;
end; { TPrinterList.GetString }

procedure TPrinterList.GetData(var Rec);
begin
  Byte(Rec) := CurStr;
end; { TPrinterList.Getdata }

procedure TPrinterList.SetData(var Rec);
begin
  ScrollTo(Byte(Rec));
end; { TPrinterList.SetData  }

function TPrinterList.DataSize :Word;
begin
  DataSize := Sizeof(Byte);
end;

{****************************************************************************}
{*  TPrintConfigWin                                                         *}
{****************************************************************************}
constructor TPrinterConfigwin.Init;
  var B :TBounds;
      View :PView;
begin
  B.Assign(120, 170, 500, 350);
  inherited Init(B);
  ViewOptions := ViewOptions or voSelectable;
  Lock;
  { Characters per line inputline }
  B.Assign(130, 55, 190, 75);
  View := New(PInputLine, Init(B, 3, '', ['0'..'9']));
  View^.HelpCtx := hcColsPerLine;
  Append(View);
  { Lines per page inputline }
  B.Assign(300, 55, 350, 75);
  View := New(PInputLine, Init(B, 2, '', ['0'..'9']));
  View^.HelpCtx := hcLinesPerPage;
  Append(View);
  { Printer List }
  Append(New(PPrinterList, Init));
  { Buttons }
  B.Assign(Size.X-120, Size.Y-60, Size.X-20, Size.Y-45);
  Append(New(PButton, Init(B, 'Aanvaar', cmAcceptPrnCnf, hcButPrnCnfAccept)));
  B.Assign(Size.X-120, Size.Y-35, Size.X-20, Size.Y-20);
  Append(New(PButton, Init(B, 'Kanselleer', cmCancelPrnCnf, hcButPrnCnfCancel)));
  SelectNext;
  Unlock;
end; { TPrinterConfigwin.Init }

procedure TPrinterConfigWin.Art;
begin
  { Frame and title }
  Platform(0, 0, Size.X, Size.Y, $F808);
  Platform(5, 5,  Size.X-5, Size.Y-5, LowerGrey);
  Platform(6, 6,  Size.X-6, 26, $F002);
  WriteStrXY(Size.X shr 1, 12, $1E, 2, 5, JustCenter, False,
    'Drukker konfigurasie');
  { Divider Lines & Titles }
  WriteStrXY(Size.X shr 1, 40, $1F, 0, 1, JustCenter, False, 'Dokument');
  Line3D(10, 45, Size.X-10, 45, $8F);
  WriteStrXY((Size.X-120) shr 1, 95, $1F, 0, 1, JustCenter, False, 'Drukker');
  Line3D(10, 100, Size.X-10, 100, $8F);
  Line3D(Size.X-130, 102, Size.X-130, Size.Y-10, $8F);
  { Labels }
  WriteStrXY(20, 60, $0E, 2, 4, JustLeft, False, 'Karakters per lyn');
  WriteStrXY(200, 60, $0E, 2, 4, JustLeft, False, 'Lyne per bladsy');
  WriteStrXY(20, 110, $0E, 2, 4, JustLeft, False, 'Drukker tipe');
end; { TPrinterConfigWin.Art }

{****************************************************************************}
{*  TPrintTarget                                                            *}
{****************************************************************************}
constructor TPrintTarget.Init(Lines, Cols :Byte);
begin
  Inherited Init;
  LinesPerPage := Lines;
  ColsPerLine := Cols;
end;

procedure TPrintTarget.Advance(Pages, Lines, Cols :Integer);
begin
  Abstract('TPrintTarget.Advance')
end; { TPrintTarget.Advance }

procedure TPrintTarget.SetAttr(Attr :Byte; On :Boolean);
begin
end; { TPrintTarget.SetAttr }

procedure TPrintTarget.SendText(Text :String);
begin
  Abstract('TPrintTarget.SendText')
end; { TPrintTarget.SendText }

procedure TPrintTarget.Error(Code :Integer);
begin
  ErrorValue := Code;
end; { TPrintTarget.Error }

{****************************************************************************}
{*  TFilePrintTarget                                                        *}
{****************************************************************************}
constructor TFilePrintTarget.Init(Lines, Cols :Byte; FileName :String);
begin
  Inherited Init(Lines, Cols);
  Assign(TextFile, FileName);
  {$I-}
  Rewrite(TextFile);
  {$I+}
  if IOResult <> 0 then Error(PrintErr_Init);
end;

destructor TFilePrintTarget.Done;
begin
  {$I-}
  Close(TextFile);
  if IOResult <> 0 then Error(PrintErr_Close);
  {$I+}
  Inherited Done;
end;

{ Anvances the current file page position an certain amount of
  Pages, Lines and/or columns }
procedure TFilePrintTarget.Advance(Pages, Lines, Cols :Integer);
  var I :Byte;
begin
  if ErrorValue <> PrintErr_NoError then Exit;
  {$I-}
  if Pages > 0 then
  begin
    Column := 0;
    for I := 1 to LinesPerPage-LineCount+1 do Writeln(TextFile);
    SendText(SPad('-- Nuwe Bladsy', '-', ColsPerLine));
    Writeln(TextFile);
    Column := 0;
    LineCount := 0;
    Inc(PageCount);
  end; {if}
  if Lines > 0 then
  begin
    for I := 1 to Lines do
    begin
      Inc(LineCount);
      if LineCount >= LinesPerPage then Advance(1, 0, 0)
      else Writeln(TextFile);
    end;
    Column := 0;
  end;
  if Cols > 0 then
    for I := 1 to Cols do
    if Column < ColsPerLine then
    begin
      Write(TextFile, ' ');
      Inc(Column);
    end; {if}
  {$I+}
  if IOResult <> 0 then Error(PrintErr_Write);
end; { TFilePrintTarget.Advance }

procedure TFilePrintTarget.Error(Code :Integer);
  var S :String;
      B :TBounds;
begin
  if ErrorValue <> PrintErr_NoError then Exit;
  ErrorValue := Code;
  case Code of
    1 :S := 'Fout met open van lˆer: '+TextRec(TextFile).Name;
    2 :S := 'Fout met skryf na lˆer: '+TextRec(TextFile).Name;
    3 :S := 'Fout met toemaak van lˆer: '+TextRec(TextFile).Name;
  end;
  B.Assign(125,200,515,300);
  MessageWindow(B, #3+S, mwfError+mwfOk);
end; { TFilePrintTarget.Error }

procedure TFilePrintTarget.SendText(Text :String);
begin
  if ErrorValue <> PrintErr_NoError then Exit;
  {$I-}
  SSetLen(Text, MaxInt(0, MinInt(Length(Text), ColsPerLine-Column)));
  Write(TextFile, Text);
  Inc(Column, Length(Text));
  {$I+}
  if IOResult <> 0 then Error(PrintErr_Write);
end; { TFilePrintTarget.SendText }

{****************************************************************************}
{*  TPrinter                                                                *}
{****************************************************************************}
{ Initializes the Printer by setting the LPT1 Device to raw mode
  and sending the initialization code for the printer.
  If the printer status check fails an error is produced }
constructor TPrinter.Init(Lines, Cols :Byte; AEmulation :Byte);
  var Status :byte;

  { Sets the Device to raw mode using Dos function calls }
  procedure DeviceToRaw(var Device :Text); assembler;
  asm
	    LES   DI, Device
	    MOV   BX, WORD PTR ES:[DI]
	    MOV   AX, 4400H
	    INT   21H
	    TEST  DX, 0080H
 	    JZ    @End
  	  OR    DL, 20H
  	  MOV   DH, DH
  	  MOV   AX, 4401H
	    INT   21H
    @End:
  end;

begin
  Inherited Init(Lines, Cols);
  { Check status }
  Status := GetStatus;
  ErrorOnStatus(Status);
  if Status <> Prn_Ready then
  begin
    Error(PrintErr_NotReady);
    Exit;
  end;
  DeviceToRaw(Lst);
  { Get emulation used }
  Emulation := AEmulation;
  { Send Initialization Code to LPT1 device }
  case Emulation of
    IBMPrinter,
    EpsonPrinter   :
      begin
        SendCode(EpsonInit);
        SendCode(EpsonHQuality);
      end;
    HPLaserPrinter :SendCode(HPInit);
    PostScrPrinter :
      begin
        SendCode(PSInit1); SendCode(PSInit2);
        SendCode(PSStartPage);
      end;
  end; {case}
end; { TPrinter.Init }

destructor TPrinter.Done;
begin
  { Sends code to the printer to indicate a end of print job condition }
  case Emulation of
    ASCIIPrinter   :if LineCount > 0 then SendCode(ASCIIEndPage);
    IBMPrinter     :
      begin
        if LineCount > 0 then SendCode(IBMEndPage);
        SendCode(IBMDone);
      end;
    EpsonPrinter   :
      begin
        if LineCount > 0 then SendCode(EpsonEndPage);
        SendCode(EpsonDone);
      end;
    HPLaserPrinter :
      begin
        if LineCount > 0 then SendCode(HPEndPage);
        SendCode(HPDone);
      end;
    PostScrPrinter :
      begin
        if LineCount > 0 then SendCode(PSEndPage);
        SendCode(PSDone);
      end;
  end; {case}
  inherited Done;
end; { TPrinter.Done }

procedure TPrinter.Advance(Pages, Lines, Cols :Integer);
  var I, PrevAttr :Byte;

  { Sends a Form Feed Instruction to the Printer }
  procedure NewPage;
  begin
    case Emulation of
      ASCIIPrinter,
      EpsonPrinter,
      HPLaserPrinter,
      IBMPrinter     :SendCode(ASCIIEndPage);
      PostScrPrinter :begin SendCode(PSEndPage); SendCode(PSStartPage); end;
    end; {case}
  end;{ sub proc newpage }

  { Sends Line Feed instruction to the Printer }
  procedure NewLine;
  begin
    case Emulation of
      ASCIIPrinter,
      EpsonPrinter,
      HPLaserPrinter,
      IBMPrinter     :SendCode(ASCIIEndLine);
      PostScrPrinter :SendCode(PSEndLine);
    end; {case}
  end; { sub proc NewLine }

begin
  if ErrorValue <> PrintErr_NoError then Exit;
  PrevAttr := TextAttr;
  SetAttr($F, False);
  if Pages > 0 then
  begin
    NewPage;
    Column := 0;
    LineCount := 0;
    Inc(PageCount);
  end; {if}
  if Lines > 0 then
  begin
    for I := 1 to Lines do
    begin
      Inc(LineCount);
      if LineCount >= LinesPerPage then Advance(1, 0, 0)
      else NewLine;
    end; {for}
    Column := 0;
  end; {if}
  if Cols > 0 then SendText(SFill(' ', Cols));
  SetAttr(PrevAttr, True);
end; { TPrinter.Advance }

{ Send codes to the printer to select a text attribute
  such as Bold or Italics }
procedure TPrinter.SetAttr(Attr :Byte; On :Boolean);
  var S: String;

  procedure Underline;
  begin
    case emulation of
      EpsonPrinter   :S := S+EpsonULine;
      HPLaserPrinter :S := S+HPULine;
      IBMPrinter     :S := S+IBMULine;
      PostScrPrinter :S := S+PSULine;
    end;
    TextAttr := TextAttr or Style_UnderLine;
  end; { sub proc Underline }

  procedure NoUnderline;
  begin
    case emulation of
      EpsonPrinter   :S := S+EpsonNoULine;
      HPLaserPrinter :S := S+HPNoULine;
      IBMPrinter     :S := S+IBMNoULine;
      PostScrPrinter :S := S+PSNoULine;
    end; {case}
    TextAttr := TextAttr and not Style_UnderLine;
  end; {NoUnderline}

  procedure Bold;
  begin
    case emulation of
      EpsonPrinter   :S := S+EpsonBold;
      HPLaserPrinter :S := S+HPBold;
      IBMPrinter     :S := S+IBMBold;
      PostScrPrinter :S := S+PSBold;
    end; {case}
    TextAttr := TextAttr or Style_Bold;
  end; { sub proc bold }

  procedure NoBold;
  begin
    case emulation of
      EpsonPrinter   :S := S+EpsonNoBold;
      HPLaserPrinter :S := S+HPNoBold;
      IBMPrinter     :S := S+IBMNoBold;
      PostScrPrinter :S := S+PSNormal;
    end; {case}
    TextAttr := TextAttr and not Style_Bold;
  end; { sub proc NoBold }

  procedure Italic;
  begin
    case emulation of
      EpsonPrinter   :S := S+EpsonItalic;
      HPLaserPrinter :S := S+HPItalic;
      IBMPrinter     :S := S+IBMItalic;
      PostScrPrinter :S := S+PSItalic;
    end; {case}
    TextAttr := TextAttr or Style_Italic;
  end; { sub proc Italic }

  procedure NoItalic;
  begin
    case emulation of
      EpsonPrinter   :S := S+EpsonNoItalic;
      HPLaserPrinter :S := S+HPNoItalic;
      IBMPrinter     :S := S+IBMNoItalic;
      PostScrPrinter :S := S+PSNormal;
    end; {case}
    TextAttr := TextAttr and not Style_Italic;
  end; { sub proc NoItalic }

  procedure BoldItalic;
  begin
    if emulation = PostScrPrinter then S := S+PSBoldItalic;
  end; { sub proc BoldItalic }

begin
  S := '';
  if Attr and Style_Underline <> 0 then
    if On then Underline else NoUnderline;
  if Attr and Style_Bold <> 0 then
    if On then Bold else NoBold;
  if Attr and Style_Italic <> 0 then
    if On then Italic else NoItalic;
  if (TextAttr and Style_Italic <> 0) and
     (TextAttr and Style_Bold <> 0) then BoldItalic;
  SendCode(S);
end; { TPrinter.SetAttr }

procedure TPrinter.SendText(Text :String);

 { Strips the most significant bit of each character in text
   and do some conversion to ensure that extended characters is somehow
   printed. }
  procedure StripMSBs;
    var I :Byte;
  begin
    for I := 1 to Length(Text) do
      if Text[I] > #127 then
      case Text[I] of
        'Í'     :Text[I] := '=';
        'Ä'     :Text[I] := '-';
        '‹'     :Text[I] := 'i';
        '„'     :Text[I] := 'a';
        'ˆ','‰' :Text[I] := 'e';
        else     Text[I] := ' ';
      end; {case}
  end; { sub proc StripMSBs }

begin { TPrinter.SendText }
  if ErrorValue <> PrintErr_NoError then Exit;
  ErrorOnStatus(GetStatus);
  {$I-}
  SSetLen(Text, MaxInt(0, MinInt(Length(Text), ColsPerLine-Column)));
  case Emulation of
    IBMPrinter  :;
    HPLaserPrinter :;
    else StripMSBs;
  end;
  if ErrorValue = PrintErr_NoError then
  begin
    if Emulation = PostScrPrinter then Write(Lst, PSPreData);
    Write(Lst, Text);
    if Emulation = PostScrPrinter then Write(Lst, PSPostData);
    Inc(Column, Length(Text));
  end;
  {$I+}
  If IOResult <> 0 then Error(PrintErr_Write);
  ErrorOnStatus(GetStatus);
end; { TPrinter.SendText }

{ Called whenever an error occurs. An error dialog will appear. }
procedure TPrinter.Error(Code :Integer);
  var S :String;
      B :TBounds;
begin
  if ErrorValue <> PrintErr_NoError then Exit;
  ErrorValue := Code;
  case Code of
    PrintErr_Init       :S := 'Fout met inisialisering van drukker.';
    PrintErr_Write      :S := 'Fout met afvoer na drukker.';
    PrintErr_OutOfPaper :S := 'Drukker rapporteer fout: Geen papier.';
    PrintErr_Busy       :S := 'Drukker rapporteer besig.';
    PrintErr_NotReady   :S := 'Drukker is nie gereed.';
    else exit;
  end;
  B.Assign(125,200,515,300);
  MessageWindow(B, #3+S, mwfError+mwfOk);
end; { TPrinter.Error }

procedure TPrinter.ErrorOnStatus(Status :Byte);
  var Err :Byte;
begin
  if Status <> Prn_Ready then
  begin
    Err := PrintErr_NoError;
    if Status and Prn_OutOfPaper <> 0 then Err := PrintErr_OutOfPaper
    else if Status and Prn_Selected = 0 then Err := PrintErr_Init
    else if Status and Prn_IOError <> 0 then Err := PrintErr_Write;
    if Err <> PrintErr_NoError then Error(Err);
  end; {if}
end; { TPrinter.ErrorOnStatus }

function TPrinter.GetStatus :Byte; assembler;
asm
  MOV  AH, 02
  MOV  DX, 0
  Int  IntPrinter
  MOV  AL, AH
end; { TPrinter.GetStatus }

procedure TPrinter.SendCode(Code :String);
begin
  if ErrorValue <> PrintErr_NoError then Exit;
  ErrorOnStatus(GetStatus);
  {$I-}
  if ErrorValue = PrintErr_NoError then Write(Lst, Code);
  {$I+}
  If IOResult <> 0 then Error(PrintErr_Write);
  ErrorOnStatus(GetStatus);
end; { TPrinter.SendCode }

{****************************************************************************}
{*  TQuestionPaperPrinter                                                   *}
{*    This object uses the TPrintTarget object as well as the internal      *}
{*    paper data to print a Question Paper                                  *}
{****************************************************************************}
type
  TQuestionPaperPrinter = object
    AfdNum      :Char; { Current "Afdeling" }
    QuestNum    :Byte; { Current question number }
    SubQuestNum :Byte; { Current sub-question number }
    Target      :PPrintTarget; { Printer object }
    constructor PrintAll(Printer :PPrintTarget);
    private
      procedure PrintAfd(Item :PPaperItem_Data);
      procedure PrintColABN(Item :PPaperItem_Data);
      procedure PrintColumnAB(Item :PPaperItem_Data);
      procedure PrintHeader;
      procedure PrintMessage(Item :PPaperItem_Data);
      procedure PrintMonkey(Item :PPaperItem_Data);
      procedure PrintTerm(Item :PPaperItem_Data);
      procedure PrintMarks;
  end;

{ This constructor is called to activate the object and to do all the printing }
constructor TQuestionPaperPrinter.PrintAll(Printer :PPrintTarget);
  { A foreach support sub procedure that will call the correct
    object method for each item in the data list }
  procedure PrintItem(Item :PPaperItem_Data); far;
  begin
    { Each new item starts with a space }
    with Target^ do if LineCount > 0 then Advance(0, 1, 0);
    { Select item }
    case Item^.ItemType of
      TMAfdeling :PrintAfd(Item);
      TMColABN   :PrintColABN(Item);
      TMColumnAB :PrintColumnAB(Item);
      TMMessage  :PrintMessage(Item);
      TMMonkey   :PrintMonkey(Item);
      TMTerms    :PrintTerm(Item);
    end; { case }
  end; { sub-procedure PrintItem }

begin { TQuestionPaperPrinter.PrintAll }
  Target := Printer;
  AfdNum := 'A';
  QuestNum := 1;
  PrintHeader;
  PaperData^.Items^.ForEach(@PrintItem);
  PrintMarks;
end; { TQuestionPaperPrinter.PrintAll }

{ Prints a "Afdeling" Item }
Procedure TQuestionPaperPrinter.PrintAfd(Item :PPaperItem_Data);
  var S :String;
begin
  with Target^ do
  begin
    { Fetch String to be printed }
    S := Item^.Signature+' '+AfdNum+' - '+PAfdeling_Data(Item)^.Data;
    { Center the text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SetAttr($F, False);
    { Underlined Bold Text }
    SetAttr(Style_Bold+Style_UnderLine, True);
    SendText(S);
    { Next Line }
    Advance(0, 1, 0);
    SetAttr($F, False);
  end;
  Inc(AfdNum);
  QuestNum := 1;
end; { TQuestionPaperPrinter.PrintAfd }

{ Prints a Four Column Question Type }
Procedure TQuestionPaperPrinter.PrintColABN(Item :PPaperItem_Data);

  var I :Byte;
      S :String;

  { Adds line drawing characters to the string at the relevant positions
    to create each line of the column }
  procedure AddLines(var S :String; C1, C2, C3 :Char);
  begin
    S[0] := Char(Target^.ColsPerLine);
    S[1] := C1;
    S[Length(S)*2 div 3] := C2;
    S[Length(S)] := C3;
  end;

  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubColABN); far;
    var SW, IW :TWrapper;
  begin
    with Target^ do
    begin
      S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'. ';
      { Assign word wrappers }
      with SubItem^ do
      begin
        SW.AssignStr(#5+S+Statement[1]+' '+StateMent[2],
           ColsPerLine*2 div 3 -4, Length(S));
        IW.AssignStr(#5'A. '+Items[1]+#13#5'B. '+Items[2],
          ColsPerLine-ColsPerline*2 div 3 - 3, 3);
      end;
      { Print Each Line of the current sub question }
      while (not SW.IsDone) or (not IW.IsDone) do
      begin
        S := SFill(' ', ColsPerLine);
        Insert(SW.NextLine, S, 3);
        Insert(IW.NextLine, S, ColsPerline*2 div 3 + 2);
        S[0] := Char(ColsPerLine);
        AddLines(S, '³', '³', '³');
        SetAttr($F, False);
        SendText(S);
        Advance(0, 1, 0);
      end; {while}
      Inc(SubQuestNum);
    end; {with}
  end; { sub-procedure DoSubItem }

begin { TQuestionPaperPrinter.PrintColABN }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Betrekkings kolomme';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    SetAttr($F, False);
    { Print Column Header }
      { First Line }
    S := SFill('Ä', ColsPerLine);
    AddLines(S, 'Ú', 'Â', '¿');
    SendText(S);
    Advance(0, 1, 0);
      { Second Line }
    S := '  Stelling';
    S := SPad(S, ' ', ColsPerLine);
    Insert('Items', S, Length(S)*2 div 3 + 2);
    AddLines(S, '³', '³', '³');
    SendText(S);
    Advance(0, 1, 0);
      { Third Line }
    S := SFill('Ä', ColsPerLine);
    AddLines(S, 'Ã', 'Å', '´');
    SendText(S);
    Advance(0, 1, 0);
    { Print Each Sub Question }
    SetAttr($F, False);
    PColABN_Data(Item)^.List^.ForEach(@DoSubItem);
    { Close Column }
    S := SFill('Ä', ColsPerLine);
    AddLines(S, 'À', 'Á', 'Ù');
    SendText(S);
    Advance(0, 1, 0);
    with PColABN_Data(Item)^  do
    begin
      { Print Marks }
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      SetAttr(Style_Italic+Style_Underline, True);
      SendText(S);
    end;
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TQuestionPaperPrinter.PrintColABN }

{ Prints a two column question type }
Procedure TQuestionPaperPrinter.PrintColumnAB(Item :PPaperItem_Data);
  var S :String;

  { Adds Column A text to Txt }
  procedure AddColumnA(SubItem :PSubColumnAB; var Txt :PChar;
                       var Size :Word; var Indent :Byte);
    var I      :Byte;
  begin
    if SubItem^.ColumnA[1] = '' then
    begin
      Txt := nil;
      Size := 0;
      Exit;
    end;
    { Calculate Size }
    Size := 10;
    for I := 1 to 4 do Inc(Size, Length(SubItem^.ColumnA[I]+' '));
    { Get Memmory }
    StrGetMem(Txt, Size);
    if SubItem^.ColumnA[1] <> '' then
      StrPCat(Txt, SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'. ');
    Indent := StrLen(Txt);
    for I := 1 to 4 do StrPCat(Txt, #5+SubItem^.ColumnA[I]+' ');
  end; { sub proc AddcolumnA }

  { Adds Column B text to Txt }
  procedure AddColumnB(SubItem :PSubColumnAB; var Txt :PChar; var Size :Word);
    var I :Byte;
  begin
    if SubItem^.ColumnB[1] = '' then
    begin
      Txt := nil;
      Size := 0;
      Exit;
    end;
    { Calculate Size }
    Size := 3;
    for I := 1 to 4 do Inc(Size, Length(SubItem^.ColumnB[I]+' '));
    { Get Memmory }
    StrGetMem(Txt, Size);
    if SubItem^.ColumnB[1] <> '' then
      StrPCat(Txt, Char(Ord(SubQuestNum)+ord('A')-1)+'. ');
    for I := 1 to 4 do StrPCat(Txt, SubItem^.ColumnB[I]+' ');
  end; { AddColumnB }

  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubColumnAB); far;
    var ItemB  :PSubColumnAB;
        SizeA, SizeB :Word;
        TxtA, TxtB :PChar;
        WA, WB :TWrapper;
        IndentA :Byte;
  begin
    with PColumnAB_Data(Item)^ do
      ItemB := List^.At(Ord(Order[Char(SubQuestNum+64)])-65);
    { Get Text and Buffer Sizes }
    AddColumnA(SubItem, TxtA, SizeA, IndentA);
    AddColumnB(ItemB, TxtB, SizeB);
    with Target^ do
    begin
      { Assign Wrappers }
      WA.AssignText(TxtA, ColsPerLine*5 div 8 - 1, IndentA);
      WB.AssignText(TxtB, ColsPerLine*3 div 8 - 1, 3);
      { Print Each Line }
      while (not WA.IsDone) or (not WB.IsDone) do
      begin
        S := WA.NextLine;
        S := SPad(S, ' ', ColsperLine*5 div 8 - 1);
        SSetLen(S, ColsPerLine*5 div 8 - 1);
        S := S+'³ ';
        S := S+WB.NextLine;
        S := SPad(S, ' ', ColsPerLine);
        SSetLen(S, ColsPerLine);
        SetAttr($F, False);
        SendText(S);
        Advance(0, 1, 0);
      end;{while}
      { Add Column Line for empty line }
      S := SFill(' ', ColsPerLine);
      S[ColsperLine*5 div 8] := '³';
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end;{with}
    { Dispose Text }
    StrFreemem(TxtA, SizeA);
    StrFreemem(TxtB, SizeB);
    Inc(SubQuestNum);
  end; { sub proc DoSubItem }

begin
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Kolom A & B';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    SetAttr($F, False);
    with PColumnAB_Data(Item)^ do
    begin
      { Draw Column Topic and Lines }
      S := 'Kolom A';
      S := SPad(S, ' ', ColsPerLine*5 div 8);
      SSetLen(S, ColsPerLine*5 div 8);
      S := S+' Kolom B';
      S := SPad(S, ' ', ColsPerLine);
      SSetLen(S, ColsPerLine);
      SendText(S);
      Advance(0, 1, 0);
      S := SFill('Ä', ColsPerLine);
      S[ColsperLine*5 div 8] := 'Â';
      SendText(S);
      Advance(0, 1, 0);
      SetAttr($F, False);
      List^.ForEach(@DoSubItem);
      Advance(0, 1, 0);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Italic Text }
      SetAttr(Style_Italic+Style_Underline, True);
      SendText(S);
    end;
    { Normal Text }
    SetAttr($F, False);
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TQuestionPaperPrinter.PrintColumnAB }

{ Prints the Header of the Question Paper }
Procedure TQuestionPaperPrinter.PrintHeader;
  var S :String;
begin
  with Target^ do
  begin
    { Set Bold Style }
    SetAttr(Style_Bold, True);
    { Print a DoubleLine with the word "Vraestel" in center }
    S := SFill(#205, ColsPerLine);
    Insert(' Vraestel ', S, (ColsPerLine-10) shr 1 + 1);
    SendText(S);
    Advance(0, 1, 0); { To Next Line }
    { Write all Header Data in a spesific format }
    with PaperData^.Header do
    begin
      { Write Subject and Paper Number }
      SendText(' '+Subject);
      SendText(' '+Number);
      { Flush Text Right }
      Advance(0, 0, ColsPerLine-Length(Standard+Grade)-Column-2);
      SendText(Standard);
      SendText(' '+Grade);
      { Next Line second column }
      Advance(0, 1, 1);
      SendText(Date);
      { Center Text }
      Advance(0, 0,
       (Column + ColsPerLine-Length(Setter)-21-Length(Time)) shr 1 - Column);
      SendText('Tyd: '+Time);
      { Flush Text Right }
      Advance(0, 0, ColsPerLine-Length(Setter)-Column-16);
      SendText('Opgestel deur: '+Setter);
    end; { PrintHeader }
    { Print a DoubleLine }
    Advance(0, 1, 0);
    SendText(SFill(#205, ColsPerLine));
    { Normal Text }
    Advance(0, 1, 0);
    SetAttr($F, False);
  end; { with }
end; { TQuestionPaperPrinter.PrintHeader }

Procedure TQuestionPaperPrinter.PrintMessage(Item :PPaperItem_Data);
  var I :Byte;
      Text :PChar;
      W :TWrapper;

begin
  { Get memmory to concat all the strings of the TTMessage record }
  StrGetMem(Text, sizeof(TTMessage));
  { Concatenates all the strings returning Text }
  with PMessage_Data(Item)^.Data do
    for I := 1 to 5 do StrPCat(Text, Message[I]+' ');
  with Target^ do
  begin
    { Assign Wrapper }
    W.AssignText(Text, ColsPerLine-2, 0);
    { Bold+Italic Text }
    SetAttr(Style_Bold+Style_Italic, True);
    { Print each line op the wrapper }
    while not W.IsDone do
    begin
      SendText('* '+W.NextLine);
      Advance(0, 1, 0);
    end;
    { Normal Text }
    SetAttr($F, False);
  end;
  StrFreeMem(Text, Sizeof(TTMessage));
end; { TQuestionPaperPrinter.PrintMessage }

{ Prints a Monkey Puzzle Type Question }
Procedure TQuestionPaperPrinter.PrintMonkey(Item :PPaperItem_Data);
  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubMonkey); far;
    var Question, Options :PChar;
        QBufLen, OBufLen :Word;
        I, C :Byte;
        QW, OW :TWrapper; { Question- & Option wrapper }
  begin
    { Detemine buffer lengths needed to store the question and options }
    QBufLen := 8;
    OBufLen := 0;
    for I := 1 to 3 do Inc(QBufLen, Length(SubItem^.Question[I])+1);
    for I := 1 to 5 do Inc(OBufLen, Length(SubItem^.Options[I])+5);
    { Get Memmory for Question & Option Text }
    StrGetMem(Question, QBuflen);
    StrGetMem(Options, OBuflen);
    StrPCat(Question, #5+SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'. ');
    C := StrLen(Question)-1;
    for I := 1 to 3 do StrPCat(Question, SubItem^.Question[I]+' ');
    for I := 1 to 5 do if SubItem^.Options[I] <> '' then
      StrPCat(Options, #13#5+Char(I+64)+'. '+SubItem^.Options[I]);
    with Target^ do
    begin
      { Assign wrappers }
      QW.AssignText(Question, ColsPerLine, C);
      OW.AssignText(Options, ColsPerLine-C, 3);
      { Print Sub-Question }
      while not QW.IsDone do
      begin
        SetAttr($F, False);
        SendText(QW.NextLine);
        Advance(0, 1, 0);
      end;
      Advance(0, 0, C);
      while not OW.IsDone do
      begin
        SetAttr($F, False);
        SendText(OW.NextLine);
        Advance(0, 1, C);
      end;
      Advance(0, 1, 0);
    end; {with}
    { Free Memmory of Question- & Option Text }
    StrFreeMem(Question, QBuflen);
    StrFreeMem(Options, OBuflen);
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

 var S :String;

begin { TQuestionPaperPrinter.PrintMonkey }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' -  Multi Keuse';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PMonkeyPuzzle_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Italic Text }
      SetAttr(Style_Italic+Style_Underline, True);
      SendText(S);
    end;
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TQuestionPaperPrinter.PrintMonkey }

{ Prints a Term-type question }
Procedure TQuestionPaperPrinter.PrintTerm(Item :PPaperItem_Data);

  { Prints a Sub Item }
  procedure DoSubItem(SubItem :PSubTerm); far;
    var I :Byte;
        BufLen :Word;
        Text :PChar;
        W :TWrapper;
        NumLen :Byte;
  begin
    { Calculate Text Buffer Length }
    BufLen := 10;
    for I := 1 to 3 do Inc(BufLen, Length(SubItem^.Question[I])+1);
    { Get Memmory }
    StrGetMem(Text, BufLen);
    { Get Text }
    StrPCat(Text, #5+SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'. ');
    NumLen := StrLen(Text)-1;
    for I := 1 to 3 do StrPCat(Text, SubItem^.Question[I]+' ');
    with Target^ do
    begin
      { Assign Wrapper Text }
      W.AssignText(Text, ColsPerLine, NumLen);
      { Print Wrapper Lines }
      while not W.IsDone do
      begin
        SetAttr($F, False);
        SendText(W.NextLine);
        Advance(0, 1, 0);
      end;
    end; {with}
    StrFreeMem(Text, BufLen);
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

  var S :String;

begin { TQuestionPaperPrinter.PrintTerm }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Terme vir Omskrywings';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    SetAttr($F, False);
    with PTerm_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      Advance(0, 1, 0);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Italic Text }
      SetAttr(Style_Italic+Style_Underline, True);
      SendText(S);
    end;
    { Normal Text }
    SetAttr($F, False);
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TQuestionPaperPrinter.PrintTerm }

procedure TQuestionPaperPrinter.PrintMarks;
begin
end; { TQuestionPaperPrinter.PrintMarks }

{****************************************************************************}
{*  TAnsweringSheetPrinter                                                  *}
{*    This object uses the TPrintTarget object as well as the internal      *}
{*    paper data to print a Answering Sheet                                 *}
{****************************************************************************}
type
  TAnsweringSheetPrinter = Object
    AfdNum      :Char; { Current "Afdeling" }
    QuestNum    :Byte; { Current question number }
    SubQuestNum :Byte; { Current sub-question number }
    Target      :PPrintTarget; { Printer object }
    procedure PrintAll(ATarget :PPrintTarget);
    private
      procedure PrintAfd(Item :PPaperItem_Data);
      procedure PrintColABN(Item :PPaperItem_Data);
      procedure PrintColumnAB(Item :PPaperItem_Data);
      procedure PrintHeader;
      procedure PrintMonkey(Item :PPaperItem_Data);
      procedure PrintTerm(Item :PPaperItem_Data);
  end;

{ this procedure is called to Print all the items on a answering sheet }
procedure TAnsweringSheetPrinter.PrintAll(ATarget :PPrintTarget);
  { A foreach support sub procedure that will call the correct
    object method for each item in the data list }
  procedure PrintItem(Item :PPaperItem_Data); far;
  begin
    { Select item }
    case Item^.ItemType of
      TMAfdeling :PrintAfd(Item);
      TMColABN  :PrintColABN(Item);
      TMColumnAB :PrintColumnAB(Item);
      TMMonkey   :PrintMonkey(Item);
      TMTerms    :PrintTerm(Item);
      else Exit;
    end; { case }
    with Target^ do if LineCount > 0 then Advance(0, 1, 0);
  end; { sub-procedure PrintItem }
begin
  Target := ATarget;
  AfdNum := 'A';
  QuestNum := 1;
  PrintHeader;
  PaperData^.Items^.ForEach(@PrintItem);
end; { TAnsweringSheetPrinter.PrintAll }

{ Prints a "Afdeling" indicator on the target }
procedure TAnsweringSheetPrinter.PrintAfd(Item :PPaperItem_Data);
  var S :String;
begin
  with Target^ do
  begin
    { Fetch String to be printed }
    S := Item^.Signature+' '+AfdNum+' - '+PAfdeling_Data(Item)^.Data;
    { Center the text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    { Underlined Bold Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    SendText(S);
    { Normal Text }
    SetAttr($F, False);
    { Next Line }
    Advance(0, 1, 0);
  end; {with}
  Inc(AfdNum);
  QuestNum := 1;
end; { TAnsweringSheetPrinter.PrintAfd }

procedure TAnsweringSheetPrinter.PrintColABN(Item :PPaperItem_Data);
  var I :Byte;
      S :String;

  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubColABN); far;
  begin
    with Target^ do
    begin
      S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.    ';
      S := S+'A    B    Beide    Geen';
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end; {with}
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

begin { TQuestionPaperPrinter.PrintColABN }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Betrekkings kolomme';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    { Normal Text }
    with PColABN_Data(Item)^  do
    begin
      { Print Each Sub Question }
      List^.ForEach(@DoSubItem);
      { Print Marks }
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Underline+Italic Text }
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end; {with}
    { Normal Text }
    SetAttr($F, False);
    Advance(0, 1, 0);
  end; {with}
  Inc(QuestNum);
end; { TAnsweringSheetPrinter.PrintColABN }

procedure TAnsweringSheetPrinter.PrintColumnAB(Item :PPaperItem_Data);
  var S :String;

  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubColumnAB); far;
  begin
    { Get Number }
    S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.  ';
    S := S+SFill('_', 4);
    with Target^ do
    begin
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end;
    Inc(SubQuestNum);
  end; { Sub-procedure DoSubItem }

begin { TAnsweringSheetPrinter.PrintColumnAB }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Kolom A & B';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PColumnAB_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Underline+Italic Text }
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end;
    { Normal Text }
    SetAttr($F, False);
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TAnsweringSheetPrinter.PrintColumnAB }

procedure TAnsweringSheetPrinter.PrintHeader;
  var S :String;
begin
  with Target^ do
  begin
    { Set Bold Style }
    SetAttr($F, False);
    SetAttr(Style_Bold, True);
    { Print a DoubleLine with the word "Vraestel" in center }
    S := SFill(#205, ColsPerLine);
    Insert(' Antwoordblad ', S, (ColsPerLine-10) shr 1 + 1);
    SendText(S);
    Advance(0, 1, 0); { To Next Line }
    { Normal Text }
    SetAttr($F, False);
    { Write all Header Data in a spesific format }
    with PaperData^.Header do
    begin
      { Write Subject and Paper Number }
      SendText(' '+Subject);
      SendText(' '+Number);
      { Flush Text Right }
      Advance(0, 0, ColsPerLine-Length(Standard+Grade)-Column-2);
      SendText(Standard);
      SendText(' '+Grade);
      { Next Line second column }
      Advance(0, 1, 1);
      SendText(Date);
      { Center Text }
      Advance(0, 0,
       (Column + ColsPerLine-Length(Setter)-21-Length(Time)) shr 1 - Column);
      SendText('Tyd: '+Time);
      { Flush Text Right }
      Advance(0, 0, ColsPerLine-Length(Setter)-Column-16);
      SendText('Opgestel deur: '+Setter);
    end; {with}
    { Print a DoubleLine }
    Advance(0, 1, 0);
    SendText(SFill(#205, ColsPerLine));
    Advance(0, 1, 0);
    { Normal Text }
    SetAttr($F, False);
  end; {with}
end; { TAnsweringSheetPrinter.PrintHeader }

{ Prints the text neccersary }
procedure TAnsweringSheetPrinter.PrintMonkey(Item :PPaperItem_Data);
  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubMonkey); far;
    var I :Byte;
        S :String;
  begin
    S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.   ';
    for I := 1 to 5 do
      if SubItem^.Options[I] <> '' then S := S+Char(I+Ord('A')-1)+'   ';
    with Target^ do
    begin
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end; {with}
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

 var S :String;

begin { TQuestionPaperPrinter.PrintMonkey }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' -  Multi Keuse';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PMonkeyPuzzle_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Underline+Italic Text }
      SetAttr($F, False);
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end;
    { Normal Text }
    SetAttr($F, False);
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TAnsweringSheetPrinter.PrintMonkey }

procedure TAnsweringSheetPrinter.PrintTerm(Item :PPaperItem_Data);
  var S :String;

  { Prints a Sub Item }
  procedure DoSubItem(SubItem :PSubTerm); far;
    var I :Byte;
  begin
    { Get Number }
    S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.  ';
    S := S+SFill('_', 30);
    with Target^ do
    begin
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end; {with}
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

begin { TQuestionPaperPrinter.PrintTerm }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Terme vir Omskrywings';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PTerm_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Underline+Italic Text }
      SetAttr($F, False);
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end; {with}
    { Normal Text }
    SetAttr($0F, False);
    Advance(0, 1, 0);
  end; {with}
  Inc(QuestNum);
end; { TAnsweringSheetPrinter.PrintTerm }

{****************************************************************************}
{*  TMemmoPrinter                                                           *}
{*    This object uses the TPrintTarget object as well as the internal      *}
{*    paper data to print a Memmo                                           *}
{****************************************************************************}
type
  TMemmoPrinter = Object
    AfdNum      :Char; { Current "Afdeling" }
    QuestNum    :Byte; { Current question number }
    SubQuestNum :Byte; { Current sub-question number }
    Target      :PPrintTarget; { Printer object }
    procedure PrintAll(ATarget :PPrintTarget);
    private
      procedure PrintAfd(Item :PPaperItem_Data);
      procedure PrintColABN(Item :PPaperItem_Data);
      procedure PrintColumnAB(Item :PPaperItem_Data);
      procedure PrintHeader;
      procedure PrintMonkey(Item :PPaperItem_Data);
      procedure PrintTerm(Item :PPaperItem_Data);
  end;

{ this procedure is called to Print all the items on a answering sheet }
procedure TMemmoPrinter.PrintAll(ATarget :PPrintTarget);
  { A foreach support sub procedure that will call the correct
    object method for each item in the data list }
  procedure PrintItem(Item :PPaperItem_Data); far;
  begin
    { Select item }
    case Item^.ItemType of
      TMAfdeling :PrintAfd(Item);
      TMColABN   :PrintColABN(Item);
      TMColumnAB :PrintColumnAB(Item);
      TMMonkey   :PrintMonkey(Item);
      TMTerms    :PrintTerm(Item);
      else Exit;
    end; { case }
    with Target^ do if LineCount > 0 then Advance(0, 1, 0);
  end; { sub-procedure PrintItem }

begin { TMemmoPrinter.PrintAll }
  Target := ATarget;
  AfdNum := 'A';
  QuestNum := 1;
  PrintHeader;
  PaperData^.Items^.ForEach(@PrintItem);
end; { TMemmoPrinter.PrintAll }

{ Prints a "Afdeling" indicator on the target }
procedure TMemmoPrinter.PrintAfd(Item :PPaperItem_Data);
  var S :String;
begin
  with Target^ do
  begin
    { Fetch String to be printed }
    S := Item^.Signature+' '+AfdNum+' - '+PAfdeling_Data(Item)^.Data;
    { Center the text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    { Underlined Bold Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    SendText(S);
    { Normal Text }
    SetAttr($F, False);
    { Next Line }
    Advance(0, 1, 0);
  end;
  Inc(AfdNum);
  QuestNum := 1;
end; { TMemmoPrinter.PrintAfd }

procedure TMemmoPrinter.PrintColABN(Item :PPaperItem_Data);
  var I :Byte;
      S :String;

  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubColABN); far;
  begin
    with Target^ do
    begin
      S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.  ';
      with SubItem^ do
      begin
        if Answer = 0 then S := S+'Geen'
        else if Answer and 1 = Answer then S := S+'A'
        else if Answer and 2 = Answer then S := S+'B'
        else if Answer and 3 = Answer then S := S+'Beide';
      end;
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end; {with}
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

begin { TMemmoPrinter.PrintColABN }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Betrekkings kolomme';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PColABN_Data(Item)^  do
    begin
      { Print Each Sub Question }
      List^.ForEach(@DoSubItem);
      { Print Marks }
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
      { Underline+Italic Text }
      SetAttr($F, False);
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end;
    { Normal Text }
    SetAttr($0F, False);
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TMemmoPrinter.PrintColABN }

procedure TMemmoPrinter.PrintColumnAB(Item :PPaperItem_Data);
  var S :String;

  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubColumnAB); far;
  begin
    { Get Number }
    S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.  ';
    with PColumnAB_Data(Item)^ do
      S := S+Order[char(SubQuestNum+ord('A')-1)];
    with Target^ do
    begin
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end;
    Inc(SubQuestNum);
  end; { Sub-procedure DoSubItem }

begin { TMemmoPrinter.PrintColumnAB }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Kolom A & B';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PColumnAB_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
     { Underline+Italic Text }
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end;
    Advance(0, 1, 0);
  end;
  Inc(QuestNum);
end; { TMemmoPrinter.PrintColumnAB }

procedure TMemmoPrinter.PrintHeader;
  var S :String;
begin
  with Target^ do
  begin
    { Set Bold Style }
    SetAttr($F, False);
    SetAttr(Style_Bold, True);
    { Print a DoubleLine with the word "Vraestel" in center }
    S := SFill(#205, ColsPerLine);
    Insert(' Memmorandum ', S, (ColsPerLine-10) shr 1 + 1);
    SendText(S);
    Advance(0, 1, 0); { To Next Line }
    { Write all Header Data in a spesific format }
    with PaperData^.Header do
    begin
      { Write Subject and Paper Number }
      SendText(' '+Subject);
      SendText(' '+Number);
      { Flush Text Right }
      Advance(0, 0, ColsPerLine-Length(Standard+Grade)-Column-2);
      SendText(Standard);
      SendText(' '+Grade);
      { Next Line second column }
      Advance(0, 1, 1);
      SendText(Date);
      { Center Text }
      Advance(0, 0,
       (Column + ColsPerLine-Length(Setter)-21-Length(Time)) shr 1 - Column);
      SendText('Tyd: '+Time);
      { Flush Text Right }
      Advance(0, 0, ColsPerLine-Length(Setter)-Column-16);
      SendText('Opgestel deur: '+Setter);
    end; { PrintHeader }
    { Print a DoubleLine }
    Advance(0, 1, 0);
    SendText(SFill(#205, ColsPerLine));
    { Normal Text }
    Advance(0, 2, 0);
    SetAttr($0F, False);
  end; { with }
end; { TMemmoPrinter.PrintHeader. }

{ Prints the text neccersary }
procedure TMemmoPrinter.PrintMonkey(Item :PPaperItem_Data);
  var S :String;

  { Prints each sub item }
  procedure DoSubItem(SubItem :PSubMonkey); far;
    var I :Byte;
       procedure AddAnswer(Bit :Byte);
       begin
         if S <> '' then S := S+' en/of ';
         S := S+Char(Bit + Ord('A'));
       end;
  begin
    S := '';
    for I := 0 to 5 do
      if (1 shl  I) and SubItem^.Answer <> 0 then AddAnswer(I);
    S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.  ' + S;
    with Target^ do
    begin
      SetAttr($F, False);
      SendText(S);
      Advance(0, 1, 0);
    end; {with}
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

begin { TMemmoPrinter.PrintMonkey }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' -  Multi Keuse';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PMonkeyPuzzle_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
     { Underline+Italic Text }
      SetAttr($F, False);
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end; {with}
    { Normal Text }
    SetAttr($F, False);
    Advance(0, 1, 0);
  end; {with}
  Inc(QuestNum);
end; { TMemmoPrinter.PrintMonkey }

procedure TMemmoPrinter.PrintTerm(Item :PPaperItem_Data);
  var S :String;

  { Prints a Sub Item }
  procedure DoSubItem(SubItem :PSubTerm); far;
    var I, Indent :Byte;
        W :TWrapper;
  begin
    { Get Number }
    S := SInt(QuestNum, 0)+'.'+SInt(SubQuestNum, 0)+'.  ';
    Indent := Length(S);
    { Get Items }
    with SubItem^ do
    begin
      S := S+Terms[1];
      if (Terms[1] <> '') and (Terms[2] <> '') then S := S+' of ';
      S := S+Terms[2];
    end; {with}
    with Target^ do
    begin
      W.AssignStr(S, ColsPerLine, Indent);
      while not W.IsDone do
      begin
        SetAttr($F, False);
        SendText(W.NextLine);
        Advance(0, 1, 0);
      end; {while}
    end; {with}
    Inc(SubQuestNum);
  end; { sub-procedure DoSubItem }

begin { TMemmoPrinter.PrintTerm }
  SubQuestNum := 1;
  with Target^ do
  begin
    { Bold+Underline Text }
    SetAttr($F, False);
    SetAttr(Style_Bold+Style_UnderLine, True);
    { Fetch String }
    S := 'Vraag '+SInt(QuestNum, 0)+' - '+'Terme vir Omskrywings';
    { Center Text }
    Advance(0, 0, (ColsPerLine-Length(S)) shr 1 + 1);
    SendText(S);
    Advance(0, 2, 0);
    with PTerm_Data(Item)^ do
    begin
      List^.ForEach(@DoSubItem);
      S := 'Punte :('+Mark+'x'+SInt(List^.Count, 0)+
           ' = '+SInt((Ord(Mark)-48)*List^.Count, 0)+')';
      { Flush Right }
      Advance(0, 0, ColsPerLine-Length(S));
     { Underline+Italic Text }
      SetAttr($F, False);
      SetAttr(Style_UnderLine+Style_Italic, True);
      SendText(S);
    end; {with}
    { Normal Text }
    SetAttr($0F, False);
    Advance(0, 1, 0);
  end; {with}
  Inc(QuestNum);
end; { TMemmoPrinter.PrintTerm }

{****************************************************************************}
{*  Routines                                                                *}
{****************************************************************************}
{ Called to print the Question Paper }
procedure PrintQuestionPaper(Target :PPrintTarget);
  var Printer :TQuestionPaperPrinter;
begin
  Printer.PrintAll(Target);
end;

{ Called to print the answering sheet }
procedure PrintAnsweringSheet(Target :PPrintTarget);
  var Printer :TAnsweringSheetPrinter;
begin
  Printer.PrintAll(Target);
end;

{ Called to print the Memmo }
procedure PrintMemmo(Target :PPrintTarget);
  var Printer :TMemmoPrinter;
begin
  Printer.PrintAll(Target);
end;


{ Prints all the chosen papers(as spesified in PrintSettings.Combo)
  to the PrintTarget ATarget }
procedure PrintPapers(ATarget :PPrintTarget);
  var B :TBounds;

  { Advances to the next page on the target, ensuring first
    that the current page is not a new page }
  procedure NextPage;
  begin
    with ATarget^ do
      if LineCount > 0 then Advance(1, 0, 0);
  end;

begin
  { if No Paper Component is selected }
  if PrintSettings.Combo = 0 then
  begin
    B.Assign(125,200,515,300);
    MessageWindow(B, #3'Geen vraestel komponent is gekies vir uitdruk nie',
      mwfError+mwfOk);
    exit;
  end; {if}
  if not (ATarget^.ColsPerLine in [40..250]) then
  begin
    B.Assign(125,200,515,300);
    MessageWindow(B, #3'Ongeldige waarde vir Karakters per lyn (40..250)',
      mwfError+mwfOk);
    exit;
  end; {if}
  if not (ATarget^.LinesPerPage > 2) then
  begin
    B.Assign(125,200,515,300);
    MessageWindow(B, #3'Ongeldige waarde vir Lyne per badsy (2..99)',
      mwfError+mwfOk);
    exit;
  end; {if}
  with PrintSettings do
  begin
    if Combo and QuestionPaper <> 0 then PrintQuestionPaper(ATarget);
    if Combo and AnsweringSheet <> 0 then
    begin
      NextPage;
      PrintAnsweringsheet(ATarget);
    end;
    if Combo and Memmo <> 0 then
    begin
      NextPage;
      PrintMemmo(ATarget);
    end;{if}
  end; {with}
end; { procedure PrintPapers }

procedure StartPrinting;
  var P :PPrintTarget;
      B1, B2 :Word; Err :Integer;
      B :TBounds;
begin
  with PrintSettings do
  begin
    if Target = 0 then
    begin
      B.Assign(125,200,515,300);
      MessageWindow(B, #3'Geen Teiken is vir afvoer.', mwfError+mwfOk);
      exit;
    end; {if}
    Val(LinesPP, B1, Err);
    Val(CharsPL, B2, Err);
    if B2 > 250 then B2 := 0;
    if Target and PrintTarget_File <> 0 then
    begin
      P := New(PFilePrintTarget, Init(B1, B2, FileName));
      PrintPapers(P);
      Dispose(P, Done);
    end; {if}
    if Target and PrintTarget_Printer <> 0 then
    begin
      P := New(PPrinter, Init(B1, B2, Printer));
      PrintPapers(P);
      Dispose(P, Done);
    end;{if}
  end; {with}
end; { StartPrinting }

end. { Unit }