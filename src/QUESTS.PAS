{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{*                                                                          *}
{* Implementation of the following important objects                        *}
{*   þ Layout Selection List                                                *}
{*   þ Data objects for each paper item                                     *}
{*   þ View objects for each paper item                                     *}
{****************************************************************************}
Unit Quests;
  {$F-,O-,Q-,R-,S-}

Interface
  uses Objects, sBasic, sView, sTypes, STDViews;

{ This unit implements all the views, transfer objects and routines
  neccesary for the Question Items of the Edit Mode.
}

{****************************************************************************}
{* Basic Items                                                              *}
{****************************************************************************}

{***þ Abstract Paper-Item View þ***}
type
  PPaperItem_View = ^TPaperItem_View;
  TPaperItem_View = Object(TViewGroup)
    constructor Init(B :TBounds);
    function    GetCaption :String; virtual;
    procedure   Art; virtual;
  end;

{***þ Counter View þ***}
type
  PCounterView = ^TCounterView;
  TCounterView = Object(TView)
    Current :Word;
    Amount  :Word;
    procedure   Art; virtual;
    procedure   GetData(var Rec); virtual;
    procedure   SetData(var Rec); virtual;
    function    DataSize :Word; virtual;
  end;

{***þ Question-Paper-Item View þ***}
type
  PQuestionItem_View = ^TQuestionItem_View;
  TQuestionItem_View = Object(TPaperItem_View)
    constructor Init(B :TBounds);
    procedure   Art; virtual;
  end;

{***þ Abstract Paper-Item Data Object þ***}
type
  PPaperItem_Data = ^TPaperItem_Data;
  TPaperItem_Data = Object(TObject)
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
    procedure   SetViewData(View :PPaperItem_View); virtual;
    procedure   GetViewData(View :PPaperItem_View); virtual;
    function    Itemtype :Byte; virtual;
    function    Signature :String;
  end;

{***þ Question-Paper-Item Data Object þ***}
type
  PQuestionItem_Data = ^TQuestionItem_Data;
  TQuestionItem_Data = Object(TPaperItem_Data)
    Current :Word;
    List    :PCollection;
    Mark    :Char;
    constructor Init;
    destructor  Done; virtual;
    procedure   FreeList;
    function    GetNew :PObject; virtual;
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
    procedure   Changed; virtual;
  end;

{***þ LayOutList þ***}
type
  PLayoutList = ^TLayoutList;
  TLayoutList = Object(TListScroller)
    TypeSelect :Boolean;
    PrevPos    :Word;
    constructor Init(var B :TBounds);
    function    GetString(Index :Word) :String; virtual;
    function    Count :Word; virtual;
    procedure   InsertItem;
    procedure   AppendItem;
    procedure   Selected(Index :Word); virtual;
    procedure   Delete;
    procedure   BarChanged; virtual;
  end;

  { Returns a name for the spesific question paper item}
  function Get_PaperItem_Signature(Itemtype :Byte) :String;
  { Constructs a new PaperItem View Object. The object type
    is determined by the itemtype parameter }
  function New_PaperItem_View(Itemtype :Byte) :PPaperItem_View;
  { Constructs a new PaperItem Data Object. The derived object type
    is determined by the itemtype parameter }
  function New_PaperItem_Data(Itemtype :Byte) :PPaperItem_Data;
  { Returns true if the givven view object is a descendant of
    PQuestionItem_Data }
  function IsQuestionView(View :PView) :Boolean;


{****************************************************************************}
{* Afdeling Item deritaves                                                  *}
{****************************************************************************}
type
  TTAfdeling = string[30];

type
  PAfdeling_View = ^TAfdeling_View;
  TAfdeling_View = Object(TPaperItem_View)
    constructor Init;
    procedure   Art; virtual;
    function    ID :Word; virtual;
  end;

type
  PAfdeling_Data = ^TAfdeling_Data;
  TAfdeling_Data = Object(TPaperItem_Data)
    Data :TTAfdeling;
    function  Itemtype :Byte; virtual;
    procedure SetViewData(View :PPaperItem_View); virtual;
    procedure GetViewData(View :PPaperItem_View); virtual;
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
  end;

{****************************************************************************}
{* Column A & B & None Item                                                 *}
{****************************************************************************}
type
  PTColABN = ^TTColABN;
  TTColABN = record
    tCurrent   :Word;
    tAmount    :Word;
    tPoints    :String[1];
    tStatement :Array[1..2] of String[60];
    tItems     :Array[1..2] of String[20];
    tAnswer    :Byte;
  end;

type
  PSubColABN = ^TSubColABN;
  TSubColABN = Object(TObject)
    Statement :Array[1..2] of String[60];
    Items     :Array[1..2] of String[20];
    Answer    :Byte;
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
  end;

type
  PColABN_View = ^TColABN_View;
  TColABN_View = Object(TQuestionItem_View)
    constructor Init;
    function    GetListedName :String; virtual;
    function    ID :Word; virtual;
    procedure   Art; virtual;
  end;

type
  PColABN_Data = ^TColABN_Data;
  TColABN_Data = Object(TQuestionItem_Data)
    function  Itemtype :Byte; virtual;
    procedure SetViewData(View :PPaperItem_View); virtual;
    procedure GetViewData(View :PPaperItem_View); virtual;
    function  GetNew :PObject; virtual;
  end;

{****************************************************************************}
{* Column A & B Item                                                        *}
{****************************************************************************}
type
  PTColumnAB = ^TTColumnAB;
  TTColumnAB = record
    tCurrent  :Word;
    tAmount   :Word;
    tPoints   :String[1];
    tQuestion :Array[1..4] of String[80];
    tAnswer   :Array[1..4] of String[80];
  end;

type
  PSubColumnAB = ^TSubColumnAB;
  TSubColumnAB = Object(TObject)
    ColumnA  :Array[1..4] of String[80];
    ColumnB  :Array[1..4] of String[80];
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
  end;

type
  PColumnAB_View = ^TColumnAB_View;
  TColumnAB_View = Object(TQuestionItem_View)
    constructor Init;
    function    GetListedName :String; virtual;
    function    ID :Word; virtual;
    procedure   Art; virtual;
  end;

type
  PColumnAB_Data = ^TColumnAB_Data;
  TColumnAB_Data = Object(TQuestionItem_Data)
    Order :Array['A'..'Z'] of Char;
    constructor Init;
    function  Itemtype :Byte; virtual;
    procedure SetViewData(View :PPaperItem_View); virtual;
    procedure GetViewData(View :PPaperItem_View); virtual;
    function  GetNew :PObject; virtual;
    procedure Changed; virtual;
    procedure NewOrder;
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
  end;

{****************************************************************************}
{* Message Item                                                             *}
{****************************************************************************}
type
  TTMessage = record
    Message :Array[1..5] of String[60];
  end;

type
  PMessage_View = ^TMessage_View;
  TMessage_View = Object(TPaperItem_View)
    constructor Init;
    function    ID :Word; virtual;
    procedure   Art; virtual;
  end;

type
  PMessage_Data = ^TMessage_Data;
  TMessage_Data = Object(TPaperItem_Data)
    Data :TTMessage;
    function  Itemtype :Byte; virtual;
    procedure SetViewData(View :PPaperItem_View); virtual;
    procedure GetViewData(View :PPaperItem_View); virtual;
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
  end;

{****************************************************************************}
{* Monkey Puzzle Item                                                           *}
{****************************************************************************}
type
  TTMonkeyPuzzle = record
    tCurrent  :Word;
    tAmount   :Word;
    tPoints   :String[1];
    tQuestion :Array[1..3] of String[80];
    tOptions  :Array[1..5] of String[80];
    tAnswer   :Byte;
  end;

type
  PSubMonkey = ^TSubMonkey;
  TSubMonkey = Object(TObject)
    Question :Array[1..3] of String[80];
    Options  :Array[1..5] of String[80];
    Answer   :Byte;
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
  end;

type
  PMonkeyPuzzle_View = ^TMonkeyPuzzle_View;
  TMonkeyPuzzle_View = Object(TQuestionItem_View)
    constructor Init;
    destructor  Done; virtual;
    function    ID :Word; virtual;
    procedure   Art; virtual;
  end;

type
  PMonkeyPuzzle_Data = ^TMonkeyPuzzle_Data;
  TMonkeyPuzzle_Data = Object(TQuestionItem_Data)
    function  Itemtype :Byte; virtual;
    procedure SetViewData(View :PPaperItem_View); virtual;
    procedure GetViewData(View :PPaperItem_View); virtual;
    function  GetNew :PObject; virtual;
  end;

{****************************************************************************}
{* Term Question Item                                                          *}
{****************************************************************************}
type
  PTTerm = ^TTTerm;
  TTTerm = record
    tCurrent  :Word;
    tAmount   :Word;
    tPoints   :String[1];
    tQuestion :Array[1..3] of String[80];
    tTerms    :Array[1..2] of String[25];
  end;

type
  PSubTerm = ^TSubTerm;
  TSubTerm = Object(TObject)
    Question :Array[1..3] of String[80];
    Terms    :Array[1..2] of String[25];
    constructor Load(var S: TStream);
    procedure   Store(var S: TStream); virtual;
  end;

type
  PTerm_View = ^TTerm_View;
  TTerm_View = Object(TQuestionItem_View)
    constructor Init;
    function    GetListedName :String; virtual;
    function    ID :Word; virtual;
    procedure   Art; virtual;
  end;

type
  PTerm_Data = ^TTerm_Data;
  TTerm_Data = Object(TQuestionItem_Data)
    function  Itemtype :Byte; virtual;
    procedure SetViewData(View :PPaperItem_View); virtual;
    procedure GetViewData(View :PPaperItem_View); virtual;
    function  GetNew :PObject; virtual;
  end;


Implementation
  uses Consts, sInput, TMData, sGraph, graph, sProcs, Main;

{****************************************************************************}
{*  Stream Registration records                                             *}
{****************************************************************************}
const
  RPaperItem_Data :TStreamRec = (
    ObjType: 1000;
    VmtLink: Ofs(TypeOf(TPaperItem_Data)^);
    Load: @TPaperItem_Data.Load;
    Store: @TPaperItem_Data.Store);

  RQuestionItem_Data :TStreamRec = (
    ObjType: 1001;
    VmtLink: Ofs(TypeOf(TQuestionItem_Data)^);
    Load: @TQuestionItem_Data.Load;
    Store: @TQuestionItem_Data.Store);

  RAfdeling_Data :TStreamRec = (
    ObjType: 1002;
    VmtLink: Ofs(TypeOf(TAfdeling_Data)^);
    Load: @TAfdeling_Data.Load;
    Store: @TAfdeling_Data.Store);

  RSubColABN :TStreamRec = (
    ObjType: 1003;
    VmtLink: Ofs(TypeOf(TSubColABN)^);
    Load: @TSubColABN.Load;
    Store: @TSubColABN.Store);

  RColABN_Data :TStreamRec = (
    ObjType: 1004;
    VmtLink: Ofs(TypeOf(TColABN_Data)^);
    Load: @TColABN_Data.Load;
    Store: @TColABN_Data.Store);

  RSubColumnAB :TStreamRec = (
    ObjType: 1005;
    VmtLink: Ofs(TypeOf(TSubColumnAB)^);
    Load: @TSubColumnAB.Load;
    Store: @TSubColumnAB.Store);

  RColumnAB_Data :TStreamRec = (
    ObjType: 1006;
    VmtLink: Ofs(TypeOf(TColumnAB_Data)^);
    Load: @TColumnAB_Data.Load;
    Store: @TColumnAB_Data.Store);

  RSubMonkey :TStreamRec = (
    ObjType: 1007;
    VmtLink: Ofs(TypeOf(TSubMonkey)^);
    Load: @TSubMonkey.Load;
    Store: @TSubMonkey.Store);

  RMonkeyPuzzle_Data :TStreamRec = (
    ObjType: 1008;
    VmtLink: Ofs(TypeOf(TMonkeyPuzzle_Data)^);
    Load: @TMonkeyPuzzle_Data.Load;
    Store: @TMonkeyPuzzle_Data.Store);

  RMessage_Data :TStreamRec = (
    ObjType: 1009;
    VmtLink: Ofs(TypeOf(TMessage_Data)^);
    Load: @TMessage_Data.Load;
    Store: @TMessage_Data.Store);

  RSubTerm :TStreamRec = (
    ObjType: 1010;
    VmtLink: Ofs(TypeOf(TSubTerm)^);
    Load: @TSubTerm.Load;
    Store: @TSubTerm.Store);

  RTerm_Data :TStreamRec = (
    ObjType: 1011;
    VmtLink: Ofs(TypeOf(TTerm_Data)^);
    Load: @TTerm_Data.Load;
    Store: @TTerm_Data.Store);


{****************************************************************************}
{*  TPaperItem_View                                                         *}
{****************************************************************************}
constructor TPaperItem_View.Init(B :TBounds);
begin
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
end; { TPaperItem_View.Init }

{ Retuns the Name accociated with the ID of the paper item }
function TPaperItem_View.GetCaption :String;
begin
  GetCaption := Get_PaperItem_Signature(ID);
end; { TPaperItem_View.GetCaption }

procedure TPaperItem_View.Art;
begin
  Platform(0, 0, Size.X, Size.Y,  $F008);
  Platform(5, 5, Size.X-5, Size.Y-5,  $0F07);
  Platform(6, 6, Size.X-6, 26,  $F001);
  WriteStrXY(Size.X shr 1, 13, $1E, 2, 5, JustCenter, False, GetCaption);
end; { TPaperItem_View.Art }

{****************************************************************************}
{*  TQuestionItem_View                                                      *}
{****************************************************************************}
procedure TCounterView.Art;
begin
  Platform(0, 0, Size.X, Size.Y, $0F09);
  WriteStrXY(Size.X shr 1, Size.Y shr 1-1, $F, 2, 4, JustCenter, False,
    SInt(Current, 0)+' van '+SInt(Amount, 0));
end; { TCounterView.Art }

procedure TCounterView.GetData(var Rec);
  type TTCount = record
         tCurrent, tAmount :Word;
       end;
begin
  with TTCount(Rec) do
  begin
    tCurrent := Current;
    tAmount  := Amount;
  end;
end; { TCounterView.GetData }

procedure TCounterView.SetData(var Rec);
  type TTCount = record
         tCurrent, tAmount :Word;
       end;
begin
  with TTCount(Rec) do
  begin
    Current := tCurrent;
    Amount  := tAmount;
  end;
  Draw;
end; { TCounterView.SetData }

function TCounterView.DataSize :Word;
begin
  DataSize := Sizeof(Word) shl 1;
end; { TCounterView.DataSize }

{****************************************************************************}
{*  TQuestionItem_View                                                      *}
{****************************************************************************}
constructor TQuestionItem_View.Init(B :TBounds);
begin
  Inherited Init(B);
  Lock;
  B.Assign(Size.X-100, 10, Size.X-10, 22);
  Append(New(PCounterView, Init(B)));
  { Control Buttons }
  B.Assign(10, Size.Y-25, 80, Size.Y-10);
  Append(New(PButton, Init(B, 'Vorige', cmQuestPrev, 0)));
  B.Assign(90, Size.Y-25, 170, Size.Y-10);
  Append(New(PButton, Init(B, 'Volgende', cmQuestNext, 0)));
  B.Assign(180, Size.Y-25, 240, Size.Y-10);
  Append(New(PButton, Init(B, 'Begin', cmQuestBegin, 0)));
  B.Assign(250, Size.Y-25, 310, Size.Y-10);
  Append(New(PButton, Init(B, 'Einde', cmQuestEnd, 0)));
  B.Assign(320, Size.Y-25, 390, Size.Y-10);
  Append(New(PButton, Init(B, 'Nuwe Na', cmQuestNewAfter, 0)));
  B.Assign(400, Size.Y-25, 490, Size.Y-10);
  Append(New(PButton, Init(B, 'Nuwe Voor', cmQuestNewAt, 0)));
  B.Assign(500, Size.Y-25, 580, Size.Y-10);
  Append(New(PButton, Init(B, 'Verwyder', cmQuestDelete, 0)));
  { Amount-for-each-question Line}
  B.Assign(53, 68, 98, 88);
  Append(New(PInputLine, Init(B, 1, '1', ['1'..'9'])));
  Unlock;
end; { TQuestionItem_View.Init }

procedure TQuestionItem_View.Art;
begin
  Inherited Art;
  Level(10, 35, 140, 115, Lowergrey);
  Level(15, 40, 135, 110, Raisegrey);
  WriteStrXY(35, 45, $0, 2, 4, JustLeft+JustTop, False, 'Punte Toegeken');
  WriteStrXY(35, 105, $0, 2, 4, JustLeft+Justbottom, False, 'Aan Elke Vraag');
  Line3D(10, Size.Y-35, Size.X-10, Size.Y-35, $8F);
end; { TQuestionItem_View.Art }

{****************************************************************************}
{*  TPaperItem_Data                                                             *}
{****************************************************************************}
procedure TPaperItem_Data.SetViewData(View :PPaperItem_View);
begin
  {$IFNDEF FinalVersion}
  Abstract('TPaperItem_Data.SetViewData');
  {$EndIf}
end; { TPaperItem_Data.SetViewData }

procedure TPaperItem_Data.GetViewData(View :PPaperItem_View);
begin
  PaperData^.Modified := True;
end; { TPaperItem_Data.GetViewData }

function TPaperItem_Data.Itemtype :Byte;
begin
  {$IFNDEF FinalVersion}
  Abstract('TPaperItem_Data.Itemtype');
  {$EndIf}
end; { TPaperItem_Data.ItemType }

function TPaperItem_Data.Signature :String;
begin
  Signature := Get_PaperItem_Signature(ItemType);
end; { TPaperItem_Data.Signature }

constructor TPaperItem_Data.Load(var S: TStream);
begin
  {$IFNDEF FinalVersion}
  Abstract('TPaperItem_Data.Load');
  {$EndIf}
end; { TPaperItem_Data.Load }

procedure TPaperItem_Data.Store(var S: TStream);
begin
  {$IFNDEF FinalVersion}
  Abstract('TPaperItem_Data.Store');
  {$EndIf}
end; { TPaperItem_Data.Store }

{****************************************************************************}
{*  TQuestionItem_Data                                                      *}
{****************************************************************************}
constructor TQuestionItem_Data.Init;
begin
  Inherited Init;
  System.New(List, Init(1, 1));
  List^.Insert(GetNew);
  Mark := '3';
end; { TQuestionItem_Data.Init }

destructor TQuestionItem_Data.Done;
begin
  FreeList;
  Inherited Done;
end; { TQuestionItem_Data.Done }

procedure TQuestionItem_Data.FreeList;
begin
  if List <> nil then Dispose(List, Done);
  List := nil;
end; { TQuestionItem_Data.FreeList }

{ constructs a new question object }
function TQuestionItem_Data.GetNew :PObject;
begin
  {$IFNDEF FinalVersion}
  Abstract('TQuestionItem_Data.GetNew');
  {$EndIf}
end; { TQuestionItem_Data.GetNew }

{ Loads the question from the Stream S }
constructor TQuestionItem_Data.Load(var S: TStream);
begin
  Current := 0;
  S.Read(Mark, Sizeof(Mark));
  List := PCollection(S.Get);
end; { TQuestionItem_Data.Load }

{ Stores the question to the Stream S }
procedure TQuestionItem_Data.Store(var S: TStream);
begin
  S.Write(Mark, Sizeof(Mark));
  S.Put(List);
end; { TQuestionItem_Data.Store }

procedure TQuestionItem_Data.Changed;
begin
end;

{****************************************************************************}
{*  TLayOutList                                                             *}
{****************************************************************************}
constructor TLayOutList.Init(var B :TBounds);
begin
  Inherited Init(B, nil);
  TypeSelect := False;
end; { TLayOutList.Init }

function TLayOutList.GetString(Index :Word) :String;
begin
  if TypeSelect then GetString := Get_PaperItem_Signature(Index+tmAfdeling)
  else
    if PaperData^.Items^.Count > 0 then
      GetString := PPaperItem_Data(PaperData^.Items^.At(Index))^.Signature
    else GetString := '';
end; { TLayOutList.GetString }

function TLayoutList.Count :Word;
begin
  if TypeSelect then Count := 6 else Count := PaperData^.Items^.Count;
end; { TLayOutList.Count }

procedure TLayoutList.Selected(Index :Word);
begin
  if TypeSelect then
  begin
    TypeSelect := False;
    PaperData^.Items^.AtInsert(PrevPos, New_PaperItem_Data(Index+tmAfdeling));
    Lock;
    Reset;
    Unlock;
    Message(Owner, spCommand, cmShowButtons, nil);
  end
  else PutMessage(spCommand, cmExeItem, PaperData^.Items^.At(CurStr));
end; { TLayOutList.Selected }

procedure TLayOutList.InsertItem;
begin
  if TypeSelect then Exit;
  PrevPos := CurStr;
  TypeSelect := True;
  Lock;
  Select;
  Reset;
  Unlock;
  Message(Owner, spCommand, cmHideButtons, nil);
  PaperData^.Modified := True;
end; { TLayOutList.InsertItem }

procedure TLayOutList.AppendItem;
begin
  if TypeSelect then Exit;
  PrevPos := Count;
  TypeSelect := True;
  Lock;
  Select;
  Reset;
  Unlock;
  Message(Owner, spCommand, cmHideButtons, nil);
  PaperData^.Modified := True;
end; { TLayOutList.AppendItem }

procedure TLayOutList.Delete;
begin
  if TypeSelect then Exit;
  if Count > 0 then PaperData^.Items^.AtFree(CurStr);
  Reset;
  PaperData^.Modified := True;
end; { TLayOutList.Delete }

procedure TLayOutList.BarChanged;
begin
  CurrentItem := CurStr;
end; { TLayOutList.BarChanged }

{****************************************************************************}
{* Afdeling Item                                                            *}
{****************************************************************************}
constructor TAfdeling_View.Init;
  var B :TBounds;
      I :Integer;
begin
  B.Assign(70, 90, 570, 195);
  Inherited Init(B);
  Lock;
  B.Assign(200, 35, 475, 55);
  Append(New(PInputLine, Init(B, 30, '', [#32..#255])));
  B.Assign(20, Size.Y-25, 100, Size.Y-10);
  Append(New(PButton, Init(B, 'Aanvaar', cmAcceptItem, 0)));
  B.Assign(385, Size.Y-25, 475, Size.Y-10);
  Append(New(PButton, Init(B, 'Kanselleer', cmCancelItem, 0)));
  SelectNext;
  Unlock;
end;

function TAfdeling_View.ID :Word;
begin
  ID := IAfdeling;
end;

procedure TAfdeling_View.Art;
begin
  Inherited Art;
  WriteStrXY(20, 32, $16, 1, 1, JustLeft+JustTop, False, 'Meer Beskrywend');
  Line3D(10, Size.Y-35, 485, Size.Y-35, $8F);
end;

function TAfdeling_Data.Itemtype :Byte;
begin
  Itemtype := tmAfdeling;
end;

procedure TAfdeling_Data.SetViewData(View :PPaperItem_View);
begin
  View^.SetData(Data);
end;

procedure TAfdeling_Data.GetViewData(View :PPaperItem_View);
begin
  inherited GetViewData(View);
  View^.GetData(Data);
end;

constructor TAfdeling_Data.Load(var S: TStream);
begin
  S.Read(Data, Sizeof(Data));
end;

procedure TAfdeling_Data.Store(var S: TStream);
begin
  S.Write(Data, Sizeof(Data));
end;

{****************************************************************************}
{* Column A & B & None Item                                                 *}
{****************************************************************************}
constructor TColABN_View.Init;
  var B :TBounds;
      i :Byte;
      Ans :PCluster;
begin
  B.Assign(25, 65, 615, 270);
  Inherited Init(B);
  Lock;
  { Statement }
  for I := 0 to 1 do
  begin
    B.Assign(150, 65+I*20, 470, 85+I*20);
    Append(New(PInputLine, Init(B, 60, '', [#32..#255])));
  end;
  { Items }
  B.Assign(90, 135, 285, 155);
  Append(New(PInputLine, Init(B, 20, '', [#32..#255])));
  B.Assign(380, 135, 575, 155);
  Append(New(PInputLine, Init(B, 20, '', [#32..#255])));
  { Answer Cluster }
  B.Assign(505, 72, 565, 100);
  Ans := New(PCluster, Init(B,
                         NewLPString('Item 1',
                         NewLPstring('Item 2',
                         nil)),
                        HcClust4TermAns));
  Append(Ans);
  Ans^.Value := 0;
  for I := 1 to 7 do SelectNext;
  Unlock;
end;

function TColABN_View.GetListedName :String;
begin
  GetListedName := 'Term Betrekking';
end;

function TColABN_View.ID :Word;
begin
  ID := IColABN;
end;

procedure TColABN_View.Art;
begin
  Inherited Art;
  WriteStrXY(15, 130, $16, 1, 1, JustLeft+JustTop, False, 'Item 1');
  WriteStrXY(305, 130, $16, 1, 1, JustLeft+JustTop, False, 'Item 2');
  WriteStrXY(250, 50, $16, 1, 1, JustLeft+JustBottom, False, 'Stelling');
  WriteStrXY(535, 40, $16, 1, 1, JustCenter, False, 'Antwoord');
  Level(495, 65, 572, 105, LowerGrey);
end;

{* Data Objects *}
constructor TSubColABN.Load(var S: TStream);
begin
  S.Read(Statement, sizeof(StateMent));
  S.Read(Items, sizeof(Items));
  S.Read(Answer, sizeof(Answer));
end;

procedure TSubColABN.Store(var S: TStream);
begin
  S.Write(Statement, sizeof(StateMent));
  S.Write(Items, sizeof(Items));
  S.Write(Answer, sizeof(Answer));
end;

function TColABN_Data.Itemtype :Byte;
begin
  Itemtype := tmColABN;
end;

procedure TColABN_Data.SetViewData(View :PPaperItem_View);
  var Data :TTColABN;
begin
  with Data do
    with PSubColABN(List^.At(Current))^ do
    begin
      tPoints    := Mark;
      tCurrent   := Current+1;
      tAmount    := List^.Count;
      tAnswer    := Answer;
      Move(Statement, tStatement, Sizeof(tStatement));
      Move(Items, tItems, Sizeof(tItems));
    end; {with}
  View^.SetData(Data);
end;

procedure TColABN_Data.GetViewData(View :PPaperItem_View);
  var Data :TTColABN;
begin
  inherited GetViewData(View);
  View^.GetData(Data);
  with Data do
    with PSubColABN(List^.At(Current))^ do
    begin
      Mark := tPoints[1];
      Answer := tAnswer;
      Move(tStatement, Statement, Sizeof(Statement));
      Move(tItems, Items, Sizeof(Items));
    end; {with}
end;

function TColABN_Data.GetNew :PObject;
begin
  GetNew := New(PSubColABN, Init);
end;

{****************************************************************************}
{* Column A & B Item                                                        *}
{****************************************************************************}
constructor TColumnAB_View.Init;
  var B :TBounds;
      I :Byte;
begin
  B.Assign(25, 65, 615, 315);
  Inherited Init(B);
  Lock;
  { Question }
  for I := 0 to 3 do
  begin
    B.Assign(170, 35+I*20, 580, 55+I*20);
    Append(New(PInputLine, Init(B, 80, '', [#32..#255])));
  end;
  { Answer }
  for I := 0 to 3 do
  begin
    B.Assign(170, 130+I*20, 580, 150+I*20);
    Append(New(PInputLine, Init(B, 80, '', [#32..#255])));
  end;
  for I := 1 to 7 do SelectNext;
  Unlock
end; {Init}

function TColumnAB_View.GetListedName :String;
begin
  GetListedName := 'Kolom A - Kolom B';
end;

function TColumnAB_View.ID :Word;
begin
  ID := IColumnAB;
end;

procedure TColumnAB_View.Art;
begin
  Inherited Art;
  WriteStrXY(140, 110, $16, 1, 1, JustLeft+JustBottom, True, 'Kolom A');
  WriteStrXY(35, 120, $16, 1, 1, JustLeft+JustTop, False, 'Betrokke');
  WriteStrXY(45, 150, $16, 1, 1, JustLeft+JustTop, False, 'Kolom');
  WriteStrXY(65, 180, $16, 1, 1, JustLeft+JustTop, False, 'B');
  WriteStrXY(140, 190, $16, 1, 1, JustLeft+JustBottom, True, 'Opsie');
end;

{* Data Objects *}
constructor TSubColumnAB.Load(var S: TStream);
begin
  S.Read(ColumnA, sizeof(ColumnA));
  S.Read(ColumnB, sizeof(ColumnB));
end;

procedure TSubColumnAB.Store(var S: TStream);
begin
  S.Write(ColumnA, sizeof(ColumnA));
  S.Write(ColumnB, sizeof(ColumnB));
end;

constructor TColumnAB_Data.Init;
begin
  Inherited Init;
  { Shuffle Order }
  Order['A'] := 'A';
end;

function TColumnAB_Data.Itemtype :Byte;
begin
  Itemtype := tmColumnAB;
end;

procedure TColumnAB_Data.SetViewData(View :PPaperItem_View);
  var Data :TTColumnAB;
begin
  with Data do
    with PSubColumnAB(List^.At(Current))^ do
    begin
      tPoints  := Mark;
      tCurrent := Current+1;
      tAmount  := List^.Count;
      Move(ColumnA, tQuestion, Sizeof(tQuestion));
      Move(ColumnB, tAnswer, Sizeof(tAnswer));
    end;
  View^.SetData(Data);
end;

procedure TColumnAB_Data.GetViewData(View :PPaperItem_View);
  var Data :TTColumnAB;
begin
  inherited GetViewData(View);
  View^.GetData(Data);
  with Data do
    with PSubColumnAB(List^.At(Current))^ do
    begin
      Mark := tPoints[1];
      Move(tQuestion, ColumnA, Sizeof(ColumnA));
      Move(tAnswer, ColumnB, Sizeof(ColumnB));
    end;
end;

function TColumnAB_Data.GetNew :PObject;
begin
  GetNew := New(PSubColumnAB, Init);
end;

constructor TColumnAB_Data.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Order, Sizeof(Order));
end;

procedure TColumnAB_Data.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Order, Sizeof(Order));
end;

procedure TColumnAB_Data.Changed;
begin
  NewOrder;
end;

{ Shuffles the column B items }
procedure TColumnAB_Data.NewOrder;
  var I :Char;

  function Valid(Ch :Char) :Boolean;
    var J :Char;
  begin
    Valid := True;
    for J := 'A' to Pred(I) do if Order[J] = Ch then Valid := False;
    if Ch = #0 then Valid := False;
  end;

begin
  Randomize;
  for I := 'A' to Char(List^.Count-1+Ord('A')) do
  begin
    Order[I] := #0;
    while not Valid(Order[I]) do
      Order[I] := Char(Random(List^.Count)+Ord('A'));
  end;
end;

{****************************************************************************}
{* Message Item                                                             *}
{****************************************************************************}
constructor TMessage_View.Init;
  var B :TBounds;
      I :Byte;
begin
  B.Assign(25, 65, 500, 260);
  Inherited Init(B);
  Lock;
  for I := 0 to 4 do
  begin
    B.Assign(20, 50+I*20, 450, 70+I*20);
    Append(New(PInputLine, Init(B, 60, '', [#32..#255])));
  end;
  B.Assign(20, Size.Y-25, 100, Size.Y-10);
  Append(New(PButton, Init(B, 'Aanvaar', cmAcceptItem, 0)));
  B.Assign(360, Size.Y-25, 450, Size.Y-10);
  Append(New(PButton, Init(B, 'Kanselleer', cmCancelItem, 0)));
  SelectNext;
  Unlock;
end; { TMessage_View.Init }

function TMessage_View.ID :Word;
begin
  ID := IMessage;
end;

procedure TMessage_View.Art;
begin
  inherited Art;
  WriteStrXY(20, 20, $06, 5, 1, JustLeft+JustTop, False, 'Boodskap :');
  Line3D(10, 160, Size.X-10, 160, $8F);
end;

{* Data Object *}
function TMessage_Data.Itemtype :Byte;
begin
  Itemtype := tmMessage;
end;

procedure TMessage_Data.SetViewData(View :PPaperItem_View);
begin
  View^.SetData(Data);
end;

procedure TMessage_Data.GetViewData(View :PPaperItem_View);
begin
  inherited GetViewData(View);
  View^.GetData(Data);
end;

constructor TMessage_Data.Load(var S: TStream);
begin
  S.Read(Data, Sizeof(Data));
end;

procedure TMessage_Data.Store(var S: TStream);
begin
  S.Write(Data, Sizeof(Data));
end;

{****************************************************************************}
{* Monkey Puzzle Item                                                           *}
{****************************************************************************}
constructor TMonkeyPuzzle_View.Init;
  var B :TBounds;
      I :Byte;
      Ans :PCluster;
begin
  B.Assign(25, 65, 615, 315);
  Inherited Init(B);
  Lock;
  { Question Lines }
  for I := 0 to 2 do
  begin
    B.Assign(170, 35+I*20, 580, 55+I*20);
    Append(New(PInputLine, Init(B, 80, '', [#32..#255])));
  end;
  { Option Lines }
  for I := 0 to 4 do
  begin
    B.Assign(170, 110+I*20, 580, 130+I*20);
    Append(New(PInputLine, Init(B, 80, '', [#32..#255])));
  end;
  { Answer Cluster }
  B.Assign(90, 140, 130, 200);
  Ans := New(PCluster, Init(B,
                         NewLPString('A.',
                         NewLPstring('B.',
                         NewLPstring('C.',
                         NewLPstring('D.',
                         NewLPstring('E.',
                         nil))))
                        ), HcClustMonkAns));
  Append(Ans);
  Ans^.Value := 0;
  for I := 1 to 7 do SelectNext;
  Unlock;
end; { TMonkeyPuzzle_View.Init }

destructor TMonkeyPuzzle_View.Done;
begin
  Inherited Done;
end;

function TMonkeyPuzzle_View.ID :Word;
begin
  ID := IMonkey;
end;

procedure TMonkeyPuzzle_View.Art;
begin
  Inherited Art;
  WriteStrXY(140, 90, $16, 1, 1, JustLeft+JustBottom, True, 'Vraag');
  WriteStrXY(140, 180, $16, 1, 1, JustLeft+JustBottom, True, 'Opsies');
  WriteStrXY(20, 115, $16, 1, 1, JustLeft+JustTop, False, 'Antwoorde');
end;


{* Data Objects *}
constructor TSubMonkey.Load(var S: TStream);
begin
  S.Read(Question, sizeof(Question));
  S.Read(Options, sizeof(Options));
  S.Read(Answer, sizeof(Answer));
end;

procedure TSubMonkey.Store(var S: TStream);
begin
  S.Write(Question, sizeof(Question));
  S.Write(Options, sizeof(Options));
  S.Write(Answer, sizeof(Answer));
end;

function TMonkeyPuzzle_Data.Itemtype :Byte;
begin
  Itemtype := tmMonkey;
end;

procedure TMonkeyPuzzle_Data.SetViewData(View :PPaperItem_View);
  var Data :TTMonkeyPuzzle;
begin
  with Data do
    with PSubMonkey(List^.At(Current))^ do
    begin
      tPoints  := Mark;
      tCurrent := Current+1;
      tAmount  := List^.Count;
      tAnswer  := Answer;
      Move(Question, tQuestion, Sizeof(tQuestion));
      Move(Options, tOptions, Sizeof(tOptions));
    end;
  View^.SetData(Data);
end;

procedure TMonkeyPuzzle_Data.GetViewData(View :PPaperItem_View);
  var Data :TTMonkeyPuzzle;
begin
  inherited GetViewData(View);
  View^.GetData(Data);
  with Data do
    with PSubMonkey(List^.At(Current))^ do
    begin
      Mark := tPoints[1];
      Answer := tAnswer;
      Move(tQuestion, Question, Sizeof(Question));
      Move(tOptions, Options, Sizeof(Options));
    end;
end;

function TMonkeyPuzzle_Data.GetNew :PObject;
begin
  GetNew := New(PSubMonkey, Init);
end;

{****************************************************************************}
{* Term Question Item                                                          *}
{****************************************************************************}
constructor TTerm_View.Init;
  var B :TBounds;
      I :Byte;
begin
  B.Assign(25, 65, 615, 300);
  Inherited Init(B);
  Lock;
  { Question Lines }
  for I := 0 to 2 do
  begin
    B.Assign(160, 55+I*20, 570, 75+I*20);
    Append(New(PInputLine, Init(B, 80, '', [#32..#255])));
  end;
  { Posible-answer Lines}
  B.Assign(15, 135, 250, 155);
  Append(New(PInputLine, Init(B, 25, '', [#32..#255])));
  B.Assign(15, 165, 250, 185);
  Append(New(PInputLine, Init(B, 25, '', [#32..#255])));
  for I := 1 to 7 do SelectNext;
  Unlock;
end;

function TTerm_View.GetListedName :String;
begin
  GetListedName := 'Terme';
end;

function TTerm_View.ID :Word;
begin
  ID := ITerms;
end;

procedure TTerm_View.Art;
begin
  Inherited Art;
  WriteStrXY(365, 35, $16, 1, 1, JustCenter, False, 'Omskrywing');
  WriteStrXY(390, 140, $16, 1, 1, JustCenter, False, 'Moontlike');
  WriteStrXY(390, 170, $16, 1, 1, JustCenter, False, 'Antwoorde');
end;

{* Data Objects *}
constructor TSubTerm.Load(var S: TStream);
begin
  S.Read(Question, sizeof(Question));
  S.Read(Terms, sizeof(Terms));
end;

procedure TSubTerm.Store(var S: TStream);
begin
  S.Write(Question, sizeof(Question));
  S.Write(Terms, sizeof(Terms));
end;

function TTerm_Data.Itemtype :Byte;
begin
  Itemtype := tmTerms;
end;

procedure TTerm_Data.SetViewData(View :PPaperItem_View);
  var Data :TTTerm;
begin
  with Data do
    with PSubTerm(List^.At(Current))^ do
    begin
      tPoints  := Mark;
      tCurrent := Current+1;
      tAmount  := List^.Count;
      Move(Question, tQuestion, Sizeof(tQuestion));
      Move(Terms, tTerms, Sizeof(tTerms));
    end;
  View^.SetData(Data);
end;

procedure TTerm_Data.GetViewData(View :PPaperItem_View);
  var Data :TTTerm;
begin
  inherited GetViewData(View);
  View^.GetData(Data);
  with Data do
    with PSubTerm(List^.At(Current))^ do
    begin
      Mark := tPoints[1];
      Move(tQuestion, Question, Sizeof(Question));
      Move(tTerms, Terms, Sizeof(Terms));
    end;
end;

function TTerm_Data.GetNew :PObject;
begin
  GetNew := New(PSubTerm, Init);
end;


{****************************************************************************}
{*  Public Routines                                                         *}
{****************************************************************************}

{ Returns a string signature for the givven itemtype }
function Get_PaperItem_Signature(Itemtype :Byte) :String;
begin
  case Itemtype of
    tmAfdeling :Get_PaperItem_Signature := 'Afdeling';
    tmMonkey   :Get_PaperItem_Signature := 'Multi Keuse';
    tmColumnAB :Get_PaperItem_Signature := 'Kolom A & B';
    tmColABN   :Get_PaperItem_Signature := 'BetrekkingsTerme';
    tmTerms    :Get_PaperItem_Signature := 'Terme en Omskrywings';
    tmMessage  :Get_PaperItem_Signature := 'Boodskap';
    {$IFNDEF FinalVersion}
    else Abort('Invalid Paper Item Type -- Get_PaperItem_Signature');
    {$EndIf}
  end;
end; { Get_PaperItem_Signature }

{ Constructs a new PaperItem View object depending on the Itemtype var }
function New_PaperItem_View(Itemtype :Byte) :PPaperItem_View;
begin
  case Itemtype of
    tmAfdeling :New_PaperItem_View := New(PAfdeling_View, Init);
    tmMonkey   :New_PaperItem_View := New(PMonkeyPuzzle_View, Init);
    tmColumnAB :New_PaperItem_View := New(PColumnAB_View, Init);
    tmColABN   :New_PaperItem_View := New(PColABN_View, Init);
    tmTerms    :New_PaperItem_View := New(PTerm_View, Init);
    tmMessage  :New_PaperItem_View := New(PMessage_View, Init);
    {$IFNDEF FinalVersion}
    else Abort('Invalid Paper Item Type -- Get_PaperItem_View');
    {$EndIf}
  end;
end; { New_PaperItem_View }

{ Constructs a new PaperItem Data object depending on the Itemtype var }
function New_PaperItem_Data(Itemtype :Byte) :PPaperItem_Data;
begin
  case Itemtype of
    tmAfdeling :New_PaperItem_Data := New(PAfdeling_Data, Init);
    tmMonkey   :New_PaperItem_Data := New(PMonkeyPuzzle_Data, Init);
    tmColumnAB :New_PaperItem_Data := New(PColumnAB_Data, Init);
    tmColABN   :New_PaperItem_Data := New(PColABN_Data, Init);
    tmTerms    :New_PaperItem_Data := New(PTerm_Data, Init);
    tmMessage  :New_PaperItem_Data := New(PMessage_Data, Init);
    {$IFNDEF FinalVersion}
    else Abort('Invalid Paper Item Type -- Get_PaperItem_View');
    {$EndIf}
  end;
end; { New_PaperItem_Data }

{ Returns true if the view View is a descendant of TQuestionItem_View }
function IsQuestionView(View :PView) :Boolean;
  var P :Pointer;
begin
  IsQuestionView := False;
  if View = nil then Exit;
  P := Typeof(View^);
  IsQuestionView := (P = typeof(TMonkeyPuzzle_View)) or
                    (P = typeof(TColABN_View)) or
                    (P = typeof(TColumnAB_View)) or
                    (P = typeof(TTerm_View));
end; { IsQuestionView }


begin
  { Stream Registration }
  RegisterType(RPaperItem_Data);
  RegisterType(RQuestionItem_Data);
  RegisterType(RAfdeling_Data);
  RegisterType(RSubColABN);
  RegisterType(RColABN_Data);
  RegisterType(RSubColumnAB);
  RegisterType(RColumnAB_Data);
  RegisterType(RSubMonkey);
  RegisterType(RMonkeyPuzzle_Data);
  RegisterType(RMessage_Data);
  RegisterType(RSubTerm);
  RegisterType(RTerm_Data);
end. { Unit }