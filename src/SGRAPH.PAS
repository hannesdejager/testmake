{****************************************************************************}
{*  TestMaker Test Paper Creating Tool                                      *}
{*    Edit by Hannes de Jager 1996 & 1997                                   *}
{*  Screen graphics support                                                 *}
{****************************************************************************}
Unit SGraph;
  {$F-,O-,Q-,R-,S-}

Interface
  uses Objects, SProcs, sInput;

{***þ Level Change Colors þ***}
const
  RaiseBlack   = $7800;
  LowerBlack   = $8700;
  RaiseBlue    = $F109;
  LowerBlue    = $1F09;
  RaiseGreen   = $F20A;
  LowerGreen   = $2F0A;
  RaiseCyan    = $B803;
  LowerCyan    = $8B03;
  RaiseRed     = $F40C;
  LowerRed     = $4F0C;
  RaiseMagenta = $F50D;
  LowerMagenta = $5F0D;
  RaiseGrey    = $F807;
  LowerGrey    = $8F07;
  RaiseYellow  = $F60E;
  LowerYellow  = $6F0E;

{***þ Shadow Write Colors þ***}
const
  ShadowBlue    = $29;
  ShadowGreen   = $3A;
  ShadowCyan    = $4B;
  ShadowRed     = $5C;
  ShadowMagenta = $6D;
  ShadowGrey    = $97;
  ShadowYellow  = $7E;
  ShadowWhite   = $1F;

{***þ Justification þ***}
const
  JustLeft    =  $01;
  JustRight   =  $02;
  JustTop     =  $04;
  JustBottom  =  $08;
  JustCenterX =  $10;
  JustCenterY =  $10;
  JustCenter  =  $30;

{***þ Bit Image Put Modes þ***}
const
  imgpmNormal = 0;
  imgpmCopy   = 0;
  imgpmXor    = 1;
  imgpmOr     = 2;
  imgpmAnd    = 3;
  imgpmNot    = 4;

{***þ Draw Settings Masks þ***}
const
  dsDrawColor      = $01;
  dsBGColor        = $02;
  dsFillColor      = $04;
  dsFillPattern    = $08;
  dsLineStyle      = $10;
  dsLinePattern    = $20;
  dsLineThickness  = $40;
  dsColor          = $03;
  dsFill           = $0C;
  dsLine           = $70;
  dsAll            = $FF;

{***þ Text Settings Masks þ***}
const
  tsFont        = $01;
  tsDirection   = $02;
  tsCharSize    = $04;
  tsXJustify    = $10;
  tsYJustify    = $20;
  tsJustify     = $30;
  tsAll         = $FF;

{***þ Color type þ***}
type
  TColor = Word;

{***þ BitMap Type þ***}
type
  PBitmap = ^TBitmap;
  TBitmap = record
    Width    :Word;
    Height   :Word;
    Reserved :Word;
    Image    :record end;
  end;

{***þ BitMap Image object þ***}
type
  PBitImage = ^TBitImage;
  TBitImage = Object(TObject)
    Bitmap  :PBitmap;
    constructor Init(X1, Y1, X2, Y2 :Integer);
    destructor  Done; virtual;
    constructor Load(var S :TStream);
    function    Height :Word;
    procedure   Put(X, Y :Integer; PutMode :Byte);
    function    Size   :Word;
    procedure   Store(var S: TStream);
    function    Width  :Word;
  end;


{***þ ViewPort Type þ***}
type
 PViewPort = ^TViewPort;
 TViewPort = Object(TObject)
   Origin :TPoint;
   Size   :TPoint;
   Clip   :Boolean;
   constructor GetActive;
   constructor Assign(X1, X2, Y1, Y2 :Integer; ClipIt :Boolean);
   destructor  Done; virtual;
   procedure   AbsPoint(var P :TPoint);
   procedure   SetActive;
   procedure   FullScreen;
 end;

{***þ Draw Settings type þ***}
type
  PDrawSettings = ^TDrawSettings;
  TDrawSettings = Object(TObject)
    DrawColor     :TColor;
    BGColor       :TColor;
    FillColor     :TColor;
    FillPattern   :Word;
    LineStyle     :Word;
    LinePattern   :Word;
    LineThickness :Word;
    constructor GetActive;
    constructor Assign(DCol, BGCol, FillCol :TColor; FPat, LStyle, LPat, LThick :Word);
    procedure   SetActive(Which :Word);
    procedure   Defaults;
  end;

{***þ Text Settings type þ***}
type
  PTextSettings = ^TTextSettings;
  TTextSettings = Object(TObject)
    Font      :Byte;
    Vertical  :Boolean;
    CharSize  :Word;
    Just      :Byte;
    constructor GetActive;
    constructor Assign(fnt :Byte; Vert :Boolean; ChSize :Word; AJust :Byte);
    procedure   SetActive(Which :Word);
    procedure   Defaults;
  end;

{***þ Settings type for Save and restore of Settings þ***}
type
  PSettings = ^TSettings;
  TSettings = Record
    ViewPort :TViewPort;
    Draw     :TDrawSettings;
    Text     :TTextSettings;
  end;

{***þ Drawing þ***}

  { WriteStrXY draws a string at Position (X, Y) Colors in Colors,
    the font Font, the givven Character Size, justification and String S.
    If Vert is true the text are displayed vertically.
    Two digit hexadecimal format are used for the colors. The least
    significant digit represents the foreground color whereas the other digit
    represents the color of the shadow. The Most significant digit is
    zero if no shadow is added, else the color value+1.
    Thus to display White Text with a black shadow, the color parameter would
    be $1F }
  procedure WriteStrXY(X, Y :Integer; Colors :Byte; Font, ChrSize,
                       Just :Word; Vert :Boolean;  S :String);

  { Works the same way as WriteStrXY, but does a Integer to String conversion
    with a certain width at first }
  procedure WriteIntXY(X, Y :Integer; Colors :Byte; Font, ChrSize,
                       Just :Word; Vert :Boolean; Num :Word; Width :Byte);

  { Displays a 3-dimentional platform using a 4-digit hexadecimal
    representation for the color values. If $ABCD is a color value then :
     A = Left & top frame Line color of the Platform.
     B = Bottom & right frame Line color of the Platform.
     C = Fill style+1
     D = Fill Color }
  procedure PlatForm(X1, Y1, X2, Y2 :Integer; Colors :Word);

  { Level works the same way as Platform exept that it does not fill the
    inner part.}
  procedure Level(X1, Y1, X2, Y2 :Integer; Colors :Word);

  { LevelColors is a 4-digit hex color value used for procedure Platform
    and -Level. SwapLevel will swap the level of the platform. In other words
    if the color value ($2002) made the platform appear raised when passed to
    Platform it will now make it appear Lowered($0202) }
  function  SwapLevel(LevelColors :Word) :Word;

  { Draws a circle. (X, Y) is the center, R is the radius and C the colors }
  { A 2-digit hex format is used for the color representation. In $XY
    X = Fill Style value +1
    Y = Color }
  procedure DrawCircle(X, Y, R :Integer; C :Word);

  { Draws a 3D Line in the Colors C (3 colors = 3 hex digits) }
  procedure Line3D(X1, Y1, X2, Y2 :Integer; C :Word);

{ Initialization & Cleanup }
  { Initializes the graphics driver }
  procedure InitGraphics;

  { Shuts down the graphics driver }
  procedure DoneGraphics;


{***þ Stream Registration Record þ***}
const
  RBitImage :TStreamRec = (
    ObjType: 10000;
    VmtLink: Ofs(TypeOf(TBitImage)^);
    Load: @TBitImage.Load;
    Store: @TBitImage.Store);


Implementation
  uses Graph, stypes, GrDrivs;

{****************************************************************************}
{*  Bit Image                                                               *}
{****************************************************************************}
{ Initializes the object and gets the image from the screen }
constructor TBitImage.Init(X1, Y1, X2, Y2 :Integer);
begin
  Inherited Init;
  GetMem(BitMap, ImageSize(X1, Y1, X2, Y2));
  GetImage(X1, Y1, X2, Y2, BitMap^);
end;

{ Free Memmory used by the object }
destructor TBitImage.Done;
begin
  if BitMap <> nil then FreeMem(Bitmap, Size);
  Inherited Done;
end;

{ Loads the object from the Stream S }
constructor TBitImage.Load(var S :TStream);
  var W, H :Word;
begin
  TObject.Init;
  S.Read(W, sizeof(Word));
  S.Read(H, sizeof(Word));
  GetMem(BitMap, ImageSize(0, 0, W, H));
  with BitMap^ do
  begin
    Width := W;
    Height := H;
    S.Read(Reserved, ImageSize(0, 0, W, H) - 2*sizeof(Word));
  end; {with}
end;

{ Returns the Height of the image in Pixels }
function TBitImage.Height :Word;
begin
  if BitMap <> nil then Height := Bitmap^.Height else Height := 0;
end;

{ Displays the image at (X,Y) using the asm instruction PutMode }
procedure TBitImage.Put(X, Y :Integer; PutMode :Byte);
begin
  if Bitmap <> nil then PutImage(X, Y, Bitmap^, PutMode);
end;

{ Returns the Size of the Image in Bytes }
function TBitImage.Size :Word;
begin
  Size := ImageSize(0, 0, Width, Height);
end;

{ Stores the Object to the Stream S }
procedure TBitImage.Store(var S: TStream);
begin
  if Bitmap <> nil then S.Write(Bitmap^, Size);
end;

{ Returns the width of the view in Pixels }
function TBitImage.Width :Word;
begin
  if BitMap <> nil then Width := Bitmap^.Width else Width := 0;
end;

{****************************************************************************}
{*  View Port                                                              *}
{****************************************************************************}
{ Sets the viewport to the givven values }
constructor TViewPort.Assign(X1, X2, Y1, Y2 :Integer; ClipIt :Boolean);
begin
  Inherited Init;
  Origin.X := X1;
  Origin.Y := Y1;
  Size.X := X2-X1;
  Size.Y := Y2-Y1;
  Clip := ClipIt;
  SetViewPort(X1, X2, Y1, Y2, ClipIt);
end; { TViewPort.Assign }

{ Set the object fields to the values of the current viewport }
constructor TViewPort.GetActive;
  var Port :ViewPortType;
begin
  GetViewsettings(Port);
  with Port do
  begin
    Origin.X := X1;
    Origin.Y := X2;
    Size.X := X2-X1;
    Size.Y := Y2-Y1;
    Self.Clip := Clip;
  end;
end; { TViewPort.GetActive }

{ destructs the object and set the viewport of the screen to fullsize }
destructor TViewPort.Done;
begin
  FullScreen;
  inherited Done;
end; { TViewPort.Done }

{ converts the Point P to absolute screen coordinates }
procedure TViewPort.AbsPoint(var P :TPoint);
begin
  P.X := Origin.X+P.X;
  P.Y := Origin.Y+P.Y;
end; { TViewPort.AbsPoint }

{ Sets the screen viewport to the values of the object }
procedure TViewPort.SetActive;
begin
  SetViewPort(Origin.X, Origin.Y, Origin.X+Size.X,
              Origin.X+Size.X, Clip);
end; { TViewPort.SetActive }

{ Sets the Viewport to FullScreen }
procedure TViewPort.FullScreen;
begin
  SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOn);
end; { TViewPort.FullScreen }

{****************************************************************************}
{*  Draw Settings Object                                                   *}
{****************************************************************************}
{ Obtains all the current Drawing settings and stores it in the object }
constructor TDrawSettings.GetActive;
  var Fill :FillSettingsType;
      Line :LineSettingsType;
begin
  inherited Init;
  DrawColor := GetColor;
  BGColor := GetBkColor;
  GetFillSettings(Fill);
  FillColor := Fill.Color;
  FillPattern := Fill.Pattern;
  GetLineSettings(Line);
  LineStyle := Line.LineStyle;
  LinePattern := Line.Pattern;
  LineThickness := Line.ThickNess;
end; { TDrawSettings.GetActive }

{ Assigns certain values to the object field }
constructor TDrawSettings.Assign(DCol, BGCol, FillCol :TColor; FPat, LStyle, LPat, LThick :Word);
begin
  Inherited Init;
  DrawColor     := DCol;
  BGColor       := BGCol;
  FillColor     := FillCol;
  FillPattern   := FPat;
  LineStyle     := LStyle;
  LinePattern   := LPat;
  LineThickNess := LThick;
end; { TDrawSettings.Assign }

{ Set the active drawing settings to those described in Which
 Which is a combination of the dsXXXX constants }
procedure TDrawSettings.SetActive(Which :Word);
  var Fill :FillSettingsType;
      Line :LineSettingsType;
begin
  if Which and dsDrawColor  <> 0 then SetColor(DrawColor);
  if Which and dsBGColor    <> 0 then SetBkColor(BGColor);
  if Which and dsFill <> 0 then
  begin
    if Which and dsFill <> dsFill then
    begin
      GetFillSettings(Fill);
      if Which and dsFillColor <> 0 then SetFillStyle(Fill.Pattern, FillColor)
      else SetFillStyle(FillPattern, Fill.Color)
    end {if}
    else SetFillStyle(FillPattern, FillColor);
  end; {if}
  if Which and dsLine <> 0 then
  begin
    if Which and dsLine <> dsLine then
    begin
      GetLineSettings(Line);
      if Which and dsLineStyle <> 0 then Line.LineStyle := LineStyle;
      if Which and dsLinePattern <> 0 then Line.Pattern := LinePattern;
      if Which and dsLineThickness <> 0 then Line.Thickness := Linethickness;
      with Line do SetLineStyle(LineStyle, LinePattern, Linethickness);
    end
    else SetLineStyle(LineStyle, LinePattern, Linethickness);
  end; {if}
end; { TDrawSettings.SetActive }

{ Sets the Fields of the object to the default drawing settings }
procedure TDrawSettings.Defaults;
begin
  DrawColor   := White;
  BGColor     := LightGray;
  FillColor   := White;
  FillPattern := SolidFill;
  LineStyle   := Solidln;
  LinePattern := 0;
  LineThickNess := NormWidth;
end; { TDrawSettings.Defualts }

{****************************************************************************}
{*  Test Settings                                                          *}
{****************************************************************************}
{ Retrieves the active settings for text writing and stores it within the
  object fields }
constructor TTextSettings.GetActive;
  var TextSet :TextSettingsType;
begin
  inherited Init;
  GetTextSettings(TextSet);
  with TextSet do
  begin
    Self.Font := Font;
    Self.CharSize := CharSize;
    Vertical := Direction = VertDir;
    Case Horiz of
      LeftText   :Just := JustLeft;
      RightText  :Just := JustRight;
      CenterText :Just := JustCenterX;
    end;
    Case Vert of
      TopText    :Just := Just + JustLeft;
      BottomText :Just := Just + JustBottom;
      CenterText :Just := Just + JustCenterY;
    end; {case}
  end; {with}
end; { TTextSettings.GetActive }

{ Assigns certain values to the object fields }
constructor TTextSettings.Assign
  (fnt :Byte; Vert :Boolean; ChSize :Word; AJust :Byte);
begin
  Inherited Init;
  Font := fnt;
  Vertical := Vert;
  CharSize := ChSize;
  Just := AJust;
end; { TTextSettings.Assign }

{ Sets the active text writing settings to the values within the object fields }
procedure TTextSettings.SetActive(Which :Word);
  var TextSet :TextSettingsType;
begin
  GetTextSettings(TextSet);
  with TextSet do
  begin
    if Which and tsfont <> 0 then Font := Self.Font;
    if Which and tsDirection <> 0 then
      if Vertical then Direction := VertDir else Direction := HorizDir;
    if Which and tsCharSize <> 0 then CharSize := Self.CharSize;
    if Just and JustRight   <> 0 then Horiz := RightText else
      if Just and JustCenterX <> 0 then Horiz := CenterText else
        Horiz := LeftText;
    if Just and JustBottom  <> 0 then Vert := BottomText else
      if Just and JustCenterY <> 0 then Vert := CenterText else
        Vert := TopText;
    SetTextstyle(Font, Direction, Charsize);
    SetTextJustify(Horiz, Vert);
  end; {with}
end; { TTextSettings.SetActive }

{ Set the Fields of the object to the default text write settings }
procedure TtextSettings.Defaults;
begin
  Font     := DefaultFont;
  Vertical := False;
  CharSize := 1;
  Just     := JustLeft+JustTop;
end; { TTextSettings.Defaults }


{****************************************************************************}
{*  Routines                                                               *}
{****************************************************************************}
{ function described in interface }
Procedure WriteStrXY
  (X, Y :Integer; Colors :Byte; Font, ChrSize, Just :Word;
   Vert :Boolean; S :String);
  var TS :TTextSettings;
begin
  TS.Assign(font, Vert, ChrSize, Just);
  TS.SetActive(tsAll);
  if not (Colors in [0..$F]) then
  begin
    Dec(Colors, $10);
    SetColor(Colors div 16);
    MoveTo(X+ChrSize, Y+ChrSize);
    OutText(S);
  end; {if}
  SetColor(Colors mod 16);
  MoveTo(X, Y);
  OutText(S);
end; { WriteStrXY }

{ function described in interface }
Procedure WriteIntXY
  (X, Y :Integer; Colors :Byte; Font, ChrSize, Just :Word;
   Vert :Boolean; Num :Word; Width :Byte);
  var TS :TTextSettings;
      S  :String;
begin
  TS.Assign(font, Vert, ChrSize, Just);
  TS.SetActive(tsAll);
  S := SInt(Num, Width);
  if not (Colors in [0..$F]) then
  begin
    if Colors = ShadowWhite then SetColor(0) else SetColor(Colors div 16);
    MoveTo(X+6-ChrSize, Y+6-ChrSize);
    OutText(S);
  end; {if}
  SetColor(Colors mod 16);
  MoveTo(X, Y);
  OutText(S);
end; { WriteIntXY }

{ function described in interface }
procedure Level(X1, Y1, X2, Y2 :Integer; Colors :Word);
begin
  SetColor(Hi(Colors) div 16);
  Line(X1, Y1, X2, Y1); Line(X1, Y1, X1, Y2);
  SetColor(Hi(Colors) mod 16);
  Line(X2, Y1, X2, Y2); Line(X1+1, Y2, X2, Y2);
end; { Level }

{ function described in interface }
function SwapLevel(LevelColors :Word) :Word;
begin
  SwapLevel := (Hi(LevelColors) div 16 + Hi(LevelColors) mod 16*16) shl 8
               + Lo(LevelColors);
end; { SwapLevel }

{ function described in interface }
procedure PlatForm(X1, Y1, X2, Y2 :Integer; Colors :Word);
begin
  SetFillStyle(Lo(Colors) div 16+1, Lo(Colors) mod 16);
  Bar(X1, Y1, X2, Y2);
  if Colors > $FF then Level(X1, Y1, X2, Y2, Colors);
end; { Platform }

{ function described in interface }
procedure SwapColors(var Colors :Byte);
begin
  Colors := Colors div 16 + Colors Mod 16 * 16;
end; { SwapColors }

{ function described in interface }
procedure DrawCircle(X, Y, R :Integer; C :Word);
begin
  SetColor(Lo(C) mod 16);
  Circle(X, Y, R);
  if C > $F then
  begin
    SetFillStyle(Lo(C) div 16+1, Hi(C) mod 16);
    FillEllipse(X, Y, R, R);
  end; {if}
end; { DrawCircle }

{ function described in interface }
procedure Line3D(X1, Y1, X2, Y2 :Integer; C :Word);
begin
  Setcolor(Lo(C) div 16);
  Line(X1, Y1, X2, Y2);
  if Y1 = Y2 then Line(X1, Y1+2, X2, Y2+2) else Line(X1+2, Y1, X2+2, Y2);
  Setcolor(Lo(C) mod 16);
  if Y1 = Y2 then Line(X1, Y1+1, X2, Y2+1) else Line(X1+1, Y1, X2+1, Y2);
end; { Line3D }

{ function described in interface }
procedure InitGraphics;
  Var Gd,Gm:Integer;

  procedure Error(Msg :String);
  begin
    Writeln(Msg);
    Halt(1);
  end; {sub proc Error}

Begin
  { Register EGA/VGA Driver }
  if RegisterBGIdriver(@Data_EGAVGADriver) < 0 then
    Error('Grafika Fout: EGA/VGA Aandrywer kon nie gelaai word nie!');
  if (RegisterBGIfont(@Data_GothicFont) < 0) or
     (RegisterBGIfont(@Data_SansSerifFont) < 0) or
     (RegisterBGIfont(@Data_SmallFont) < 0) or
     (RegisterBGIfont(@Data_TriplexFont) < 0) then
    Error('Grafika Fout: Kon nie font laai nie !');
  Gd := Detect;
  InitGraph(Gd, Gm, '');
  If GraphResult <> GrOk then Error('Grafika Inisialiserings Fout !');
end; { InitGraphics }

{ function described in interface }
Procedure DoneGraphics;
begin
  CloseGraph;
  RestoreCrtMode;
end; { DoneGraphics }

begin
  RegisterType(RBitImage);
end. { Unit }