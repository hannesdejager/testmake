{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* Basic view object deratives                                              *}
{****************************************************************************}
Unit STDViews;
  {$F-,O-,Q-,R-,S-}

Interface
  uses Objects, sBasic, sView, sInput, sTypes;


{***þ Button View þ***}
type
  PButton = ^TButton;
  TButton = Object(TView)
    Caption :PString;
    Command :Word;
    constructor Init(B :TBounds; Cap :String; Cm, Hc :Word);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   MouseInput(var Input :TMouseInput); virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    procedure   SetState(StateFlag :Word; Enable :Boolean); virtual;
    procedure   Pressed;
  end;

{***þ InputLine þ***}
  PInputLine = ^TInputLine;
  TInputLine = Object(TView)
    DataStr    :PString;
    Max        :Word;
    Cursor     :Byte;
    FirstChar  :Word;
    ValidSet   :TCharSet;
    constructor Init(Bounds :TBounds; MaxLen :Byte; InitStr :String; CharSet :TCharset);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   MouseInput(var Input :TMouseInput); virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    function    LastChar :Word;
    function    InsPos :Word;
    procedure   GetData(var Rec); virtual;
    procedure   SetData(var Rec); virtual;
    function    DataSize :Word; virtual;
    procedure   Changed; virtual;
    function    DispCount :Integer;
    private
      function   ValidOpr(Opr :Word) :Word;
      procedure  ControlOpr(Opr :Word; Key :Word);
  end;

{***þ List Scroller þ***}
type
  PListScroller = ^TListScroller;
  TListScroller = Object(TView)
    Items     :PCollection;
    FirstStr  :Word;
    FirstCol  :Byte;
    BarPos    :Byte;
    MaxStrLen :Byte;
    constructor Init(Bounds :TBounds; List :PCollection);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   MouseInput(var Input :TMouseInput); virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    procedure   Reset; virtual;
    function    CurStr  :Word;
    function    Count :Word; virtual;
    function    ItemPtr(Index :Word) :Pointer; virtual;
    procedure   NewItems(List :PCollection);
    function    GetString(Index :Word) :String; virtual;
    procedure   Selected(Index :Word); virtual;
    procedure   BarChanged; virtual;
    procedure   ItemsChanged; virtual;
    procedure   ScrollTo(Pos :Word);
    private
      function    ValidOpr(Opr :Byte; Key :Word) :Byte;
      procedure   ControlOpr(Opr :Byte; Key :Word);
      function    LastPos :Word;
      function    LastStr :Word;
      function    DispWidth :Word;
      function    DispHeight :Word;
  end;

{***þ Cluster Object þ***}
type
  PCluster = ^TCluster;
  TCluster = Object(TView)
    Value      :LongInt;
    EnableMask :LongInt;
    Selected   :Byte;
    Text       :PLPString;
    constructor Init(B :TBounds; Strings :PLPString; Hc :Word);
    destructor  Done; virtual;
    procedure   Art; virtual;
    function    ValidAmount :Byte;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    procedure   MouseInput(var Input :TMouseInput); virtual;
    function    On(Which :LongInt) :Boolean;
    procedure   GetData(var Rec); virtual;
    procedure   SetData(var Rec); virtual;
    function    DataSize :Word; virtual;
  end;

{***þ Static Text þ***}
type
  PStaticText = ^TStaticText;
  TStaticText = Object(TView)
    Text :PString;
    Font, CharSize, Colors :Byte;
    constructor Init(B :TBounds; AFont, ASize, AColor :Byte; AText :String);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   SetData(var Data); virtual;
    procedure   GetData(var Data); virtual;
    function    DataSize :Word; virtual;
  end;

{***þ Message Window appearance States þ***}
const
  mwfWarning      = $01;
  mwfError        = $02;
  mwfConfirmation = $03;
  mwfInformation  = $04;
  mwfOk           = $10;
  mwfYes          = $20;
  mwfNo           = $40;
  mwfCancel       = $80;

{***þ Message Window View Object þ***}
  { Created for the  MessageWindow function }
type
  PMessageWindow = ^TMessageWindow;
  TMessageWindow = Object(TViewGroup)
    Caption :PString;
    Colors  :LongInt;
    constructor Init(B :TBounds; ACaption, AText :String; AColors :LongInt);
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   Listen(var Speech :TSpeech); virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
  end;


{ MessageWindow function
  -----------------------
  Displays dialog box on the screen, using the bounds passed in parameter B,
  containing the formatted message passed in Text, and having an appearance
  described by the flags passed in Options.

  Options contains some combination of the mwfXXXX flag constants,
  determining which buttons appear in the message box and how then title looks
  like.

  MessageBox uses the TMessagewindow object to insert a modal view into the
  application object and then executes the newly inserted object.
  It also uses a TStatictext Object to display the given text centered and
  word-wrapped within the dialog box.

  When the message box finishes by means of a button press the application
  is redrawn by calling application^.redraw.
  }

  function MessageWindow(B :TBounds; Text :String; Options :Byte) :Word;




Implementation
  uses sGraph, graph, sProcs, consts, Main;

{****************************************************************************}
{*   TButton                                                                *}
{****************************************************************************}
constructor TButton.Init(B :TBounds; Cap :String; Cm, Hc :Word);
begin
  Inherited Init(B);
  Caption := NewStr(Cap);
  Command := cm;
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
  HelpCtx := Hc;
end;

destructor TButton.Done;
begin
  DisposeStr(Caption);
  Inherited Done;
end;


procedure TButton.Art;
  var C, TC :Word;
begin
  if StateOn(vsPressed) then C := LowerGrey else C := RaiseGrey;
  if StateOn(vsDisabled) then TC := 8 else
  begin
    if StateOn(vsSelected) then TC := ShadowGreen else TC := $C;
  end;
  Platform(0, 0, Size.X, Size.Y, C);
  Platform(1, 1, Size.X-1, Size.Y-1, C);
  if StateOn(vsPressed) then
    WriteStrXY(Size.X shr 1+2, size.Y shr 1+3,
      8, 0, 1, JustCenter, False, Caption^);
  WriteStrXY(Size.X shr 1, size.Y shr 1+1,
             TC, 0, 1, JustCenter, False, Caption^);
end;

procedure TButton.MouseInput(var Input :TMouseInput);
  var P :TPoint;
begin
  inherited MouseInput(Input);
  if not (Input.What = inMouseLD) then exit;
  SetState(vsPressed, True);
  while not MouseInputMatch(Input, inMouseUp) do
  begin
    if Input.What and inMouseMove <> 0 then { Mouse Movement }
		begin                                   { while pressed  }
      if PointIn(MouseWhere) then
      begin
        if not StateOn(vsPressed) then SetState(vsPressed, True)
      end
      else if StateOn(vsPressed) then SetState(vsPressed, False);
    end;
  end;
  if PointIn(MouseWhere) then Pressed;
end;

procedure TButton.KeybordInput(var Input :TKeybordInput);
begin
  inherited KeybordInput(Input);
  if Input.What and inKeybord <> 0 then
  case Input.Keycode of
    kbEnter :
      begin
        Pressed;
        InputHandled(Input);
      end;
  end;
end;

procedure TButton.SetState(StateFlag :Word; Enable :Boolean);
begin
  inherited SetState(StateFlag, Enable);
  if StateFlag and vsPressed <> 0 then Draw;
end;

procedure TButton.Pressed;
  var S :TSpeech;
begin
  SetState(vsPressed, True);
  PutMessage(spCommand, Command, nil);
  SetState(vsPressed, False);
end;

{****************************************************************************}
{*   TInputLine                                                             *}
{****************************************************************************}
constructor TInputLine.Init
  (Bounds :TBounds; MaxLen :Byte; InitStr :String; Charset :TCharSet);
begin
  Inherited Init(Bounds);
  ViewOptions := ViewOptions or voSelectAble or voFirstClick;
  GetMem(DataStr, MaxLen+1);
  DataStr^  := InitStr;
  Cursor    := 1;
  FirstChar := 1;
  Max := MaxLen;
  SetState(vsInsert, True);
  ValidSet := CharSet;
end;

destructor TInputLine.Done;
begin
  FreeMem(DataStr, Max+1);
  Inherited Done;
end;

procedure TInputLine.Art;
  var C :Word;
      S :String;
      X :Integer;
  var MarkBegin, MarkEnd :Byte;
begin
  Level(0, 0, Size.X, Size.Y, Raisegrey);
  Level(1, 1, Size.X-1, Size.Y-1, Raisegrey);
  Level(2, 2, Size.X-2, Size.Y-2, Lowergrey);
  Level(3, 3, Size.X-3, Size.Y-3, Lowergrey);
  if StateOn(vsSelected) then C := $8F01 else C := $8F07;
  Platform(4, 4, Size.X-4, Size.Y-4, C);
  S := Copy(DataStr^, FirstChar, DispCount);
  WriteStrXY(15, Size.Y shr 1-3, ShadowWhite,
             DefaultFont, 1, JustLeft+JustTop, False, S);
  SettextStyle(DefaultFont, HorizDir, 1);
  if Cursor <> 0 then X := 15+(Cursor-1)*TextWidth('X')
  else X := 15;
  if StateOn(vsSelected) then
  begin
    if StateOn(vsInsert) then Setcolor($A) else Setcolor($C);
    Line(X, 6, X, Size.Y-6);
  end;
end;

function TInputLine.LastChar :Word;
begin
  SettextStyle(DefaultFont, HorizDir, 1);
  LastChar :=
    MinWord(FirstChar + DispCount,Length(DataStr^));
end;

function TInputLine.InsPos :Word;
begin
  InsPos := FirstChar + Cursor-1;
end;

function TInputLine.ValidOpr(Opr :Word) :Word;
  var ValidOp:Boolean;
begin
  ValidOp:= True;
  Case Opr of
    qAppend,
    qInsert       :ValidOp := Length(DataStr^) < Max;
    qOverwrite    :ValidOp := InsPos <= Max;
    qDelete       :ValidOp := (Length(DataStr^) > 0) and
                              (InsPos <= Length(DataStr^));
    qBack         :ValidOp := InsPos > 1;
    qClear        :ValidOp := Length(DataStr^) > 0;
    qToggleIns    :ValidOp := True;
    qLeft         :ValidOp := InsPos > 1;
    qRight        :ValidOp := (InsPos <= Length(DataStr^)) and (InsPos < Max);
    qHome         :ValidOp := (InsPos > 1);
    qEnd          :ValidOp := (InsPos <= Length(DataStr^)) and (InsPos < Max);
  end;
  if ValidOp then ValidOpr := Opr else ValidOpr := qNone;
end;

procedure TInputLine.ControlOpr(Opr :Word; Key :Word);
  var I :Word;

{ Shifts each character, from position Index to position Lastshift in
	  Buffer, one position to the right. }
  procedure ShiftRight(Index, LastShift :Word);
  var I, J :Word;
      Size :Word;
  begin
    SettextStyle(DefaultFont, HorizDir, 1);
    J := DispCount;
    Size := Max;
    if LastShift = 0 then LastShift := J else
  	  LastShift := MinWord(J, LastShift);
    Index := MaxWord(MinWord(Index, J), 1);
    For I := LastShift downto Index do DataStr^[I+1] := DataStr^[I];
    DataStr^[Index] := #0;
  end;

  { Shifts each character, from position Index to position LastShift in
	  the buffer, one position to the left. }
  procedure ShiftLeft(Index, LastShift :Word);
    var I :Word;
        Size :Word;
  begin
    Size := Max;
    if LastShift = 0 then LastShift := Size else
  	  LastShift := MinWord(Size, LastShift);
    Index := MaxWord(MinWord(Index, Size), 2);
    For I := Index to LastShift do DataStr^[I-1] := DataStr^[I];
    DataStr^[LastShift] := #0;
  end;

begin
  { Check if the operation is valid }
  Opr := ValidOpr(Opr);
  { Do Operation }
  Case Opr of
    qAppend    :
      begin
        DataStr^ := DataStr^+ TKbKey(Key).CharCode;
        If Cursor = DispCount then Inc(FirstChar)
        else if Length(DataStr^) < Max then Inc(Cursor);
      end;
    qInsert    :
      begin
        ShiftRight(InsPos, Length(DataStr^));
        DataStr^[InsPos] := TKbKey(Key).CharCode;
        Inc(DataStr^[0]);
        If Cursor = DispCount then Inc(FirstChar)
        else if Length(DataStr^) < Max then Inc(Cursor);
      end;
    qOverwrite :
      begin
        DataStr^[InsPos] := TKbKey(Key).CharCode;
        If Cursor = DispCount then Inc(FirstChar)
        else Inc(Cursor);
      end;
    qDelete    :
      Begin
        ShiftLeft(InsPos+1, Length(DataStr^));
        Dec(DataStr^[0]);
      end;
    qBack      :
      Begin
        ShiftLeft(InsPos, Length(DataStr^));
        Dec(DataStr^[0]);
        if (Cursor > 1) and (FirstChar > 1) then Dec(FirstChar)
        else Dec(Cursor);
      end;
    qToggleIns :ToggleState(vsInsert);
    qClear :
      Begin
        DataStr^[0] := #0;
        Cursor    := 1;
        FirstChar := 1;
      end;
    qLeft         :if Cursor > 1 then Dec(Cursor) else Dec(FirstChar);
    qRight        :if Cursor < DispCount then Inc(Cursor) else Inc(FirstChar);
    qHome      :
      Begin
        FirstChar := 1;
        Cursor    := 1;
      end;
    qEnd    :
      begin
      end;
  end;
  { Input of the view has changed }
  if Opr <> qNone then Changed;
  if Opr in
    [qAppend, qInsert, qOverwrite, qDelete, qBack, qClear] then Changed;
  if Opr <> qNone then Draw
end;

procedure TInputLine.KeybordInput(var Input :TKeybordInput);
  var Operation :Word;
begin
  Inherited KeybordInput(Input);
  Operation := qNone;
  With Input do
  begin
    Case KeyCode of
      kbEsc      :Operation := qDelete;
      kbBack     :Operation := qBack;
      kbIns      :Operation := qToggleIns;
      kbDel      :if Keybord.StateOn(ksShift) then Operation := qClear
  	              else Operation := qDelete;
      kbLeft     :if ShiftState and ksShift <> 0 then
                  Operation := qMarkLeft
			            else Operation := qLeft;
      kbRight    :if ShiftState and ksShift <> 0 then
		              Operation := qMarkRight
		             else Operation := qRight;
      kbHome     :Operation := qHome;
      kbEnd      :Operation := qEnd;
      else { character key was typed }
        if CharCode in ValidSet then
        begin
          if InsPos > Length(DataStr^) then Operation := qAppend
          else if StateOn(vsInsert) then Operation := qInsert
		           else Operation := qOverwrite;
        end
        else Exit;
     end;
    ControlOpr(Operation, KeyCode);          { Do Operation }
  end;
  InputHandled(Input);
end;

procedure TInputLine.MouseInput(var Input :TMouseInput);
  var Operation :Word;
      P :TPoint;
begin
  Operation := qNone;
  with Input do
  begin
    if what and inMouseLD <> 0 then
    begin
      MakeLocal(Where, P);
      SettextStyle(DefaultFont, HorizDir, 1);
      P.X := P.X div TextWidth('X') + 1;
      if P.X > 2 then Dec(P.X, 2)
      else P.X := MinByte(DispCount, P.X);
      if Length(DataStr^) > 0 then
        if (P.X >= 1) and (P.X <= MinWord(LastChar-FirstChar+1, DispCount)) then
        begin
	   		  Cursor := P.X;
          Draw;
          Exit;
        end
        else if P.X  <= 0 then
        begin
			    Operation := qLeft;
        end
        else if P.X >= MinWord(LastChar-FirstChar+2, DispCount) then
        begin
			    Operation := qRight;
        end;
		end
    else Exit;
    ControlOpr(Operation, kbNoKey);          { Do Operation }
  end;
end;

procedure TInputLine.GetData(var Rec);
begin
  Move(DataStr^, Rec, Datasize);
end;

procedure TInputLine.SetData(var Rec);
begin    { Assume Rec is of type string }
  Move(Rec, DataStr^, Datasize);
  FirstChar := 1;
  Cursor := 1;
  Draw;
end;

function TInputLine.DataSize :Word;
begin
  DataSize := Max+1;
end;

procedure TInputLine.Changed;
begin
  Message(Owner, spNotify, msgChanged, DataStr);
end;

function TInputLine.DispCount :Integer;
begin
  SettextStyle(DefaultFont, HorizDir, 1);
  DispCount := (Size.X-25) div TextWidth('X');
end;

{****************************************************************************}
{*   TListScroller                                                          *}
{****************************************************************************}
constructor TListScroller.Init(Bounds :TBounds; List :PCollection);
  var I :Word;
begin
  Inherited Init(Bounds);
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
  Items := List;
  FirstCol := 1;
  if Count > 0 then
    for I := 0 to Count-1 do
      MaxStrLen := MaxInt(MaxStrLen, Length(GetString(I)));
end;

destructor TListScroller.Done;
begin
  if Items <> nil then Dispose(Items, Done);
  Inherited Done;
end;

procedure TListScroller.Art;
  var C :Word;
      I, J :Word;
      S, S2 :String;
      TxtHeight :Word;
begin
  Platform(0, 0, Size.X, Size.Y, $870F);
  if StateOn(vsSelected) then C := $0A else C := $08;
  SetColor(C);
  SetTextStyle(defaultfont, Horizdir, 1);
  SetTextJustify(LeftText, CenterText);
  TxtHeight := TextHeight('X')+3;
  SetColor(C);
  Platform(0, TxtHeight*(BarPos+1)-2, Size.X, TxtHeight*(BarPos+1)+10 , 9);
  J := 0;
  if Count > 0 then
    For I := FirstStr to LastStr do        { Each String  }
    begin
      Inc(J);
      S := GetString(I);            { Fetch String }
      S2 := Copy(S, FirstCol, MinInt(LastPos, Length(S))+1);
      OutTextXY(10, J*TxtHeight+TxtHeight shr 1, S2);
    end;
end;

procedure TListScroller.MouseInput(var Input :TMouseInput);
  var P :TPoint;
      Item :Integer;
begin
  inherited MouseInput(Input);
  if Input.What and inMouseLU <> 0 then
  begin
    MakeLocal(Input.Where, P);
    Item := (P.Y-16) div (TextHeight('X')+3);
    if (Item >= 0) and (Item < Count) then Selected(Item);
    InputHandled(Input);
  end;
end;

procedure TListScroller.KeybordInput(var Input :TKeybordInput);
begin
  if Input.What and inKeybord <> 0 then
  case Input.KeyCode of
    kbLeft   :ControlOpr(qLeft, kbLeft);
    kbRight  :ControlOpr(qRight, kbRight);
    kbUp     :ControlOpr(qUp, kbUp);
    kbDown   :ControlOpr(qDown, kbDown);
    kbPgDn   :ControlOpr(qEndX, kbPgDn);
    kbPgUp   :ControlOpr(qHomeX, kbPgUp);
		kbHome   :if Input.ShiftState and ksShift <> 0 then
              ControlOpr(qHomeX, kbHome) else ControlOpr(qHome, kbHome);
    kbEnd    :if Input.ShiftState and ksShift <> 0 then
              ControlOpr(qEndX, kbEnd) else ControlOpr(qEnd, kbEnd);
    kbEnter  :ControlOpr(qSelect, kbEnter);
    else begin inherited KeybordInput(Input); exit; end;
  end;
  InputHandled(Input);
end;

function TListScroller.ItemPtr(Index :Word) :Pointer;
begin
  if Count > 0 then ItemPtr := Items^.At(Index)
  else ItemPtr := nil;
end;

procedure TListScroller.NewItems(List :PCollection);
begin
  if Items <> nil then Dispose(Items, Done);
  Items := List;
  Reset;
  ItemsChanged;
end;

function TListScroller.GetString(Index :Word) :String;
begin
  Abstract('TListScroller.GetString');
end;

procedure TListScroller.BarChanged;
begin
end;

procedure TListScroller.ItemsChanged;
begin
end;

procedure TListScroller.Reset;
  var I :Word;
begin
  FirstStr := 0;
  Barpos   := 0;
  FirstCol := 1;
  MaxStrLen := 0;
  if Count > 0 then
    for I := 0 to Count-1 do
      MaxStrLen := MaxInt(MaxStrLen, Length(GetString(I)));
  Draw;
  BarChanged;
end;

function TListScroller.ValidOpr(Opr :Byte; Key :Word) :Byte;
  var OpValid :Boolean;
begin
  OpValid := False;
  if Count < 1 then exit;
  case opr of
    qUp    :OpValid := CurStr > 0;
    qDown  :OpValid := CurStr < Count-1;
    qEnd   :OpValid := CurStr < Count-1;
    qHome  :OpValid := CurStr > 0;
    qLeft,
    qHomeX  :OpValid := FirstCol > 1;
    qRight,
    qEndX   :OpValid :=
		    LastPos < MaxByte(Length(GetString(CurStr)), MaxStrLen);
    qSelect :OpValid := True;
  end;
  if OpValid then ValidOpr := opr else ValidOpr := qNone;
end;

procedure TListScroller.ControlOpr(opr :Byte; Key :Word);
  var OldCurr :Word;
begin
  OldCurr := CurStr;
  Opr := ValidOpr(Opr, Key);
  case Opr of
    qUp     :if Barpos > 0 then Dec(Barpos) else Dec(FirstStr);
    qDown   :if Barpos < DispHeight-1 then Inc(Barpos) else Inc(FirstStr);
    qHome   :begin FirstStr := 0; BarPos := 0; end;
    qEnd    :
		  begin
			  FirstStr := Count - MinInt(DispHeight, Count);
				BarPos   := MinInt(Count, DispHeight)-1;
			end;
    qLeft   :Dec(FirstCol);
    qRight  :Inc(FirstCol);
    qHomeX  :FirstCol := 1;
    qEndX   :FirstCol := MaxStrLen - DispWidth + 3;
    qSelect :Selected(CurStr);
  end;
  if Opr <> qNone then Draw;
  if OldCurr <> CurStr then BarChanged;
end;

procedure TListScroller.Selected(Index :Word);
begin
end;

function TListScroller.LastPos :Word;
begin
  LastPos := DispWidth + FirstCol-1;
end;

function TListScroller.CurStr :Word;
begin
  CurStr :=  FirstStr + BarPos;
end;

function TListScroller.Count :Word;
begin
  if Items <> nil then Count := Items^.Count else Count := 0;
end;

function TListScroller.LastStr :Word;
begin
  LastStr := MinWord(DispHeight + FirstStr-1, Count-1);
end;

function TListScroller.DispWidth :Word;
begin
  SettextStyle(DefaultFont, HorizDir, 1);
  DispWidth := (Size.X-16) div (TextWidth('X')+1);
end;

function TListscroller.DispHeight :Word;
begin
  SettextStyle(DefaultFont, HorizDir, 1);
  DispHeight := (Size.Y-16) div (TextHeight('X')+3);
end;

procedure TListScroller.ScrollTo(Pos :Word);
begin
  if Pos in [0..Count-1] then
  begin
    FirstStr := MinWord(Pos, Count-Dispheight);
    BarPos := Pos - Firststr;
    Draw;
  end;
end; { TListScroller.Scrollto }

{****************************************************************************}
{*   TCluster                                                               *}
{****************************************************************************}
constructor TCluster.Init(B :TBounds; Strings :PLPString; Hc :Word);
begin
  Inherited Init(B);
  Text := Strings;
  ViewOptions := Viewoptions or voSelectable or voFirstClick;
  Value := 0;
  HelpCtx := Hc;
end;

destructor TCluster.Done;
  var P, D :PLPString;
begin
  P := Text;
  while P <> nil do
  begin
    D := P;
    P := P^.Next;
    FreeLPString(D);
  end;
  inherited Done;
end;

procedure TCluster.Art;
  var I:Byte; P :PLPString; Sel :Boolean;
      Y :Integer; C :Word;
begin
  P := Text;
  SetTextStyle(2, HorizDir, 4);
  SetTextJustify(LeftText, TopText);
  Sel := StateOn(vsSelected);
  for I := 0 to ValidAmount-1 do
  begin
    Y := I*(TextHeight('X')+3);
    if StateOn(vsDisabled) then SetColor($08)
    else if sel then SetColor($A) else SetColor($C);
    OutTextXY(25, Y, P^.Value^);
    P := P^.Next;
    if (I = Selected) and (Sel) then Platform(0, Y+2, 20, Y+10, Lowergrey)
    else Platform(0, Y+2, 20, Y+10, Raisegrey);
    if ((1 shl I) and Value <> 0) and not StateOn(vsDisabled) then
      C := $0F0A else C := $0F08;
    Platform(4, Y+5, 15, Y+7, C);
  end;
end;

function TCluster.ValidAmount :Byte;
  var I :Byte; P :PLPString;
begin
  P := Text;
  I := 0;
  while (P <> nil) and (I < 32) do
  begin
    Inc(I);
    P := P^.Next;
  end;
  ValidAmount := I;
end;

procedure TCluster.KeybordInput(var Input :TKeybordInput);
begin
  inherited KeybordInput(Input);
  if Input.What and InKeybord = 0 then Exit;
  case Input.Keycode of
    kbUp   :
      begin
        if Selected = 0 then Selected := ValidAmount-1
        else Dec(Selected);
      end;
    kbDown :
      begin
        if Selected = ValidAmount-1 then Selected := 0
        else Inc(Selected);
      end;
    kbSpace :
      begin
        Value := Value xor (1 shl Selected);
      end;
    else Exit;
  end;
  InputHandled(Input);
  Draw;
end;

procedure TCluster.MouseInput(var Input :TMouseInput);
  var P :TPoint;
      Sel :Integer;
begin
  inherited MouseInput(Input);
  with Input do
  begin
    if What and (inMouseLD or inMouseLU) <> 0 then
    begin
      MakeLocal(Where, P);
      SetTextStyle(2, Horizdir, 4);
      Sel := P.Y div (TextHeight('X')+3);
      if (What and inMouseLD <> 0) and (sel < ValidAmount) and
         (Sel >= 0) then Selected := Sel
      else if Sel = Selected then Value := Value xor (1 shl Selected);
      InputHandled(Input);
      Draw;
    end;
  end;
end;

function TCluster.On(Which :LongInt) :Boolean;
begin
  On := Value and Which <> 0;
end;

procedure TCluster.GetData(var Rec);
begin
  Move(Value, Rec, DataSize);
end;

procedure TCluster.SetData(var Rec);
begin
  Move(Rec, Value, DataSize);
  Draw;
end;

function TCluster.DataSize :Word;
begin
  Case ValidAmount of
    1..8   :DataSize := 1;
    9..16  :DataSize := 2;
    17..32 :DataSize := 4;
  end;
end;


{****************************************************************************}
{*   TStaticText                                                            *}
{****************************************************************************}
constructor TStaticText.Init
  (B :TBounds; AFont, ASize, AColor :Byte; AText :String);
begin
  inherited Init(B);
  Text := NewStr(AText);
  Font := AFont;
  CharSize := ASize;
  Colors := AColor;
end;

destructor TStaticText.Done;
begin
  inherited done;
  DisposeStr(Text);
end;

procedure TStaticText.Art;
  var Y :Word;
      Position :Word;
      S :String[100];
      Len :Byte;
      Centered :Boolean;
      Line :String;

    function ReadNext :String;
      const Deviders :TCharSet = [#3, #13, ' '];
        var I :Byte;
    begin
      if Position > Len then ReadNext := ''
      else
      if Text^[Position] in Deviders then
      begin
        ReadNext := Text^[Position];
        Inc(Position);
      end
      else
      begin
        I := Position;
        while not (Text^[Position] in Deviders) and (Position <= Len)
        do Inc(Position);
        ReadNext := Copy(Text^, I, Position-I);
      end;
    end;

    Procedure PrintLine;
    begin
      if Centered then
      begin
        SetTextJustify(CenterText, TopText);
        if Line[Length(Line)] = ' ' then Dec(Line[0]);
        OutTextXY(Size.X shr 1, Y, Line);
      end
      else
      begin
        SetTextJustify(LeftText, TopText);
        OutTextXY(0, Y, Line);
      end;
      Inc(Y, TextHeight('X'));
      Line := '';
    end;

begin { TStatictext.Art }
  Platform(0, 0, Size.X, Size.Y, Colors div 16);
  SetTextStyle(Font, Horizdir, CharSize);
  SetColor(Colors mod 16);
  Centered := False;
  Position := 1;
  Y := 0;
  Len := Length(Text^);
  Line := '';
  S := ReadNext;
  while S <> '' do
  begin
    if S = #13 then begin PrintLine; Centered := False; end else
    if S = #3 then Centered := True else
    if S = ' ' then begin if Line <> '' then Line := Line+' '; end else
    if (TextWidth(Line+S) <= Size.X) then Line := Line+S
    else
      begin
        PrintLine;
        Line := S;
      end;
    S := ReadNext;
  end;
  PrintLine;
end; { TStatictext.Art }

procedure TStatictext.SetData(var Data);
begin
  DisposeStr(Text);
  Text := NewStr(String(Data));
  Draw;
end;

procedure TStatictext.GetData(var Data);
begin
  String(Data) := Text^;
end;

function TStatictext.DataSize :Word;
begin
  DataSize := Sizeof(String);
end;

{****************************************************************************}
{* TMessagewindow Object Implementation                                     *}
{****************************************************************************}
constructor TMessageWindow.Init
  (B :TBounds; ACaption, AText :String; AColors :LongInt);
begin
  inherited Init(B);
  { set fields }
  Caption := NewStr(ACaption);
  Colors  := AColors;
  { Add the text object }
  B.Assign(8, 36, Size.X-8, Size.Y-35);
  Append(New(PStatictext, Init(B, 2, 5, $70+Lo(Colors) mod 16 , AText)));
end; { Init }

destructor TMessageWindow.Done;
begin
  DisposeStr(Caption);
  inherited done;
end; { Done }

procedure TMessageWindow.Art;
begin
  Platform(0, 0, Size.X, Size.Y,  $F008);
  Platform(5, 5, Size.X-5, Size.Y-5,  $0F07);
  { Draw Caption }
  Platform(6, 6, Size.X-6, 26,  TLongRec(Colors).Hi);
  if Caption <> nil then
    WriteStrXY(Size.X shr 1, 13, Lo(Colors) div 16, 2, 5, JustCenter,
      False, Caption^);
end;{ Art }

procedure TMessageWindow.Listen(var Speech :TSpeech);
begin
  { React to button press }
  if Speech.Tone <> 0 then
  begin
    EndModal(Speech.What);
    SpeechHeard(Speech);
  end;
end; { Listen }

procedure TMessageWindow.KeybordInput(var Input :TKeybordInput);
begin
  inherited KeybordInput(Input);
  { React to Arrows for button selection }
  if Input.What <> inNothing then
  case Input.Keycode of
    kbLeft  :SelectPrevious;
    kbRight :SelectNext;
  end;
end; { KeybordInput }


{****************************************************************************}
{*  Public Routines                                                         *}
{****************************************************************************}
function MessageWindow(B :TBounds; Text :String; Options :Byte) :Word;
  const Caption :Array[mwfWarning..mwfInformation] of String[27] =
          ('Testmaker Waarskuwing', 'Testmaker Fout Rapportering',
           'TestMaker Bevestiging', 'TestMaker Informasie');
        Colors :Array[mwfWarning..mwfInformation] of LongInt =
          ($F80400E0, $F80400E0, $F80600F0, $F80900F0);
        ButtonName: array[0..3] of string[10] =
          ('Aanvaar', 'Ja', 'Nee', 'Kanselleer');
        Command: array[0..3] of word =
          (cmOK, cmYes, cmNo, cmCancel);
  var
    Win :TMessageWindow; I :Byte;
    ButtonList :Array[0..3] of PButton;
    ButtonCount :Byte; X, D :Integer;
begin
  { Initialize a TMessageWindow Object }
  Win.Init(B, Caption[Options mod 16], Text, Colors[Options mod 16]);
  with Win do
  begin
    { Add the buttons }
    D := 0;
    ButtonCount := 0;
    for I := 0 to 3 do
      if Options and ($10 shl I) <> 0 then
      begin
        Inc(ButtonCount);
        X := 10*Length(ButtonName[I])+5;
        B.Assign(D, Size.Y-25, D+X, Size.Y-10);
        ButtonList[ButtonCount-1] :=
          New(PButton, Init(B, ButtonName[I], Command[I], 0));
        D := D+X+10;
      end;
    X := Size.X shr 1 - (D-10) shr 1;
    for I := 0 to ButtonCount-1 do
    begin
      Inc(ButtonList[I]^.Origin.X, X);
      Append(ButtonList[I]);
    end;
    { execute the view }
    MessageWindow := Execute;
    { clean up }
    Done;
  end;
  { remove view }
  Application^.Draw;
end; { Function Messagewindow }


end. { Unit }