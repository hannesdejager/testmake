{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* This init implements all the views and routines used for the Edit Mode   *}
{* of Testmaker.                                                             *}
{****************************************************************************}
Unit EditMode;
  {$F+,O+,Q-,R-,S-}

interface
  Uses Objects, sView, sTypes, Quests;

{***þ Buttonbar view þ***}
type
  PButtonBar = ^TButtonBar;
  TButtonBar = Object(TViewGroup)
    constructor Init;
    procedure   Art; virtual;
  end;

{***þ Main Edit View þ***}
type
  PEditMode = ^TEditMode;
  TEditMode = Object(TViewGroup)
    Buttonbar :PButtonBar;
    Active :PView;
    constructor Init;
    destructor  Done; virtual;
    procedure   Art; virtual;
    procedure   Listen(var Speech :TSpeech); virtual;
    procedure   GotFocus; virtual;
    procedure   NewActive(View :PView);
    procedure   SetWindow;
    procedure   HeaderWindow;
    procedure   LayoutWindow;
    procedure   ItemWindow;
    procedure   CloseQuestionWindow;
    procedure   ItemQuestionNext;
    procedure   ItemQuestionPrev;
    procedure   ItemQuestionDelete;
    procedure   ItemQuestionBegin;
    procedure   ItemQuestionEnd;
    procedure   ItemQuestionNewAfter;
    procedure   ItemQuestionNewAt;
    procedure   StoreActive;
  end;


Implementation
  uses sBasic, Graph, sGraph, STDViews, Consts, TMData, sProcs,
       Selector, Main;

{***þ Set Info Input window þ***}
type
  PSetView = ^TSetView;
  TSetView = Object(TViewGroup)
    constructor Init;
    procedure   Art; virtual;
  end;

{***þ Header Info Input Window þ***}
  PHeaderView = ^THeaderView;
  THeaderView = Object(TViewGroup)
    constructor Init;
    procedure   Art; virtual;
  end;

{***þ Layout Selection View þ***}
type
  PLayOutView = ^TLayOutView;
  TLayOutView = Object(TViewGroup)
    List    :PLayoutList;
    Buttons :Array[1..3] of PButton;
    constructor Init;
    procedure   Art; virtual;
    function    ConfirmDelete :Word;
    procedure   Listen(var Speech :TSpeech); virtual;
    procedure   RemoveButtons;
    procedure   InsertButtons;
  end;

{****************************************************************************}
{*  TSetView                                                               *}
{****************************************************************************}
constructor TSetView.Init;
  var B :TBounds;
begin
  B.Assign(110, 100, 530, 300);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
  Lock;
  { Description Line }
  B.Assign(110, 30, 400, 50);
  Append(New(PInputLine, Init(B, 30, '', [#32..#254])));
  { Password Line }
  B.Assign(110, 65, 400, 85);
  Append(New(PInputLine, Init(B, 30, '', [#32..#254])));
{ Password cluster }
  B.Assign(110, 110, Size.X-10, Size.Y-30);
  Append(New(PCluster, Init(B,
                         NewLPstring('Druk van Vraestel',
                         NewLPstring('Druk van Antwoordblad',
                         NewLPstring('Druk van Memmorandum',
                         NewLPString('Redigering',
                         nil)))), HcClustCombo)));
  { Accept button }
  B.Assign(10, Size.Y-23, 100, Size.Y-8);
  Append(New(PButton, Init(B, 'Aanvaar', cmAcceptSet, 0)));
  { Cancel button }
  B.Assign(Size.X-100, Size.Y-23, Size.X-10, Size.Y-8);
  Append(New(PButton, Init(B, 'Kanselleer', cmCancelSet, 0)));
  SelectNext;
  Unlock;
end; { TSetView.Init }

Procedure TSetView.Art;
begin
  Platform(0, 0, Size.X, Size.Y, $F007);
  Platform(1, 1, Size.X-1, Size.Y-1, $F007);
  Platform(3, 5, Size.X-3, 25, $F001);
  WriteStrXY(Size.X shr 1, 10, $1E, 2, 5, JustCenter, False, 'Stel Verwysing');
  WriteStrXY(10, 25, $1A, 4, 1, JustLeft+JustTop, False, 'Beskrywing');
  WriteStrXY(10, 60, $1A, 4, 1, JustLeft+JustTop, False, 'Wagwoord');
  WriteStrXY(100, 95, $E, 2, 5, JustLeft+JustTop, False, 'Wagwoord het betrekking op :');
  { Divider Lines }
  Setcolor(8);
  Line(10, 57, Size.X-10, 57);
  Setcolor($F);
  Line(10, 58, Size.X-10, 58);
  Setcolor($8);
  Line(10, 59, Size.X-10, 59);
  Setcolor(8);
  Line(10, Size.Y-30, Size.X-10, Size.Y-30);
  Setcolor($F);
  Line(10, Size.Y-31, Size.X-10, Size.Y-31);
  Setcolor($8);
  Line(10, Size.Y-32, Size.X-10, Size.Y-32);
end; { TSetView.Art }

{****************************************************************************}
{*  THeaderView                                                               *}
{****************************************************************************}
constructor THeaderView.Init;
  var B :TBounds;
begin
  B.Assign(110, 70, 530, 320);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
  Lock;
  { Subject Line }
  B.Assign(110, 35, 300, 55);
  Append(New(PInputLine, Init(B, 30, '', [#32..#254])));
  { PaperNumber Line }
  B.Assign(110, 60, 300, 80);
  Append(New(PInputLine, Init(B, 15, '', [#32..#254])));
  { Standard Line }
  B.Assign(110, 85, 300, 105);
  Append(New(PInputLine, Init(B, 20, '', [#32..#254])));
  { Grade Line }
  B.Assign(110, 110, 300, 130);
  Append(New(PInputLine, Init(B, 15, '', [#32..#254])));
  { Date Line }
  B.Assign(110, 135, 300, 155);
  Append(New(PInputLine, Init(B, 20, '', [#32..#254])));
  { Setter Line }
  B.Assign(110, 160, 300, 180);
  Append(New(PInputLine, Init(B, 30, '', [#32..#254])));
  { Time Line }
  B.Assign(110, 185, 300, 205);
  Append(New(PInputLine, Init(B, 10, '', [#32..#254])));
  { Accept button }
  B.Assign(10, 225, 100, 240);
  Append(New(PButton, Init(B, 'Aanvaar', cmAcceptHeader, 0)));
  { Cancel button }
  B.Assign(Size.X-100, 225, Size.X-10, 240);
  Append(New(PButton, Init(B, 'Kanselleer', cmCancelHeader, 0)));
  SelectNext;
  Unlock;
end; { THeaderView.Init }

Procedure THeaderView.Art;
  var I :Word;
    Procedure WriteLabel(Y :Integer; Str :String);
    begin
      SetColor(0);
      OutTextXY(26, Y+1, Str);
      SetColor(6);
      OutTextXY(25, Y, Str);
    end; { Writelabel }
begin
  Platform(0, 0, Size.X, Size.Y, $F007);
  Platform(1, 1, Size.X-1, Size.Y-1, $F007);
  Platform(3, 5, Size.X-3, 25, $F001);
  WriteStrXY(Size.X shr 1, 10, $1E, 2, 5, JustCenter, False,
    'Vraestel Opskrif');
  SetTextJustify(LeftText, TopText);
  SetTextStyle(3, Horizdir, 1);
  WriteLabel(30, 'Vak');
  WriteLabel(55, 'Nommer');
  WriteLabel(80, 'Vlak');
  WriteLabel(105, 'Graad');
  WriteLabel(130, 'Datum');
  WriteLabel(155, 'Opsteller');
  WriteLabel(180, 'Tyd');
  Line3D(10, 215, Size.X-10, 215, $8F);
end; { THeaderView.Art }

{****************************************************************************}
{*  TLayOutView                                                               *}
{****************************************************************************}
constructor TLayOutView.Init;
  var B :TBounds;
begin
  B.Assign(80, 100, 530, 300);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
  Lock;
  { List }
  B.Assign(15, 65, 265, Size.Y-38);
  New(List, Init(B));
  Append(List);
  { Buttons }
  B.Assign(285, 75, 440, 95);
  Buttons[1] := New(PButton, Init(B, 'Las ''n Item aan', cmAppendNew, 0));
  B.Assign(285, 105, 440, 125);
  Buttons[2] := New(PButton, Init(B, 'Voeg ''n Item in', cmInsertNew, 0));
  B.Assign(285, 135, 440, 155);
  Buttons[3] := New(PButton, Init(B, 'Verwyder ''n Item', cmDelete, 0));
  InsertButtons;
  Unlock;
end; { TLayOutView.Init }

procedure TLayOutView.Art;
  var I :Word;
begin
  Platform(0, 0, Size.X, Size.Y, $F007);
  Platform(1, 1, Size.X-1, Size.Y-1, $F007);
  Platform(3, 5, Size.X-3, 25, $F001);
  WriteStrXY(Size.X shr 1, 10, $1E, 2, 5, JustCenter, False,
    'Vraestel Uitleg ');
  Setcolor(8);
  Line3D(10, 57, Size.X-10, 57, $8F);
  Line3D(10, Size.Y-30, Size.X-10, Size.Y-30, $8F);
  Line3D(275, 59, 275, Size.Y-30, $8F);
end; { TLayOutView.Art }

procedure TLayOutView.Listen(var Speech :TSpeech);
begin
  if Speech.Tone = spCommand then
    case Speech.What of
      cmInsertNew   :List^.InsertItem;
      cmAppendNew   :List^.AppendItem;
      cmDelete      :if ConfirmDelete = cmYes then  List^.Delete;
      cmHideButtons :RemoveButtons;
      cmShowButtons :InsertButtons;
      else begin inherited Listen(Speech); end;
    end;
  SpeechHeard(Speech);
end; { TLayOutView.Listen }

{ ConfirmDelete will display a messagebox to confirm whether to delete a item
  or not. }
function TLayOutView.ConfirmDelete :Word;
  var B :TBounds;
begin
  B.Assign(125,200,515,300);
  ConfirmDelete :=
    MessageWindow(B, #3'Destruktiewe Operasie - Gaan voort ?',
      mwfWarning+mwfYes+mwfNo)
end; { TLayOutView.ConfirmDelete }

{ RemoveButtons will disable all buttons within the view }
procedure TLayOutView.RemoveButtons;
  var I :Byte;
begin
  Lock;
  for I := 1 to 3 do Remove(Buttons[I]);
  Unlock;
  Draw;
end; { TLayOutView.RemoveButtons }

{ InsertButtons will enable all buttons within the view }
procedure TLayOutView.InsertButtons;
  var I :Byte;
begin
  Lock;
  for I := 1 to 3 do Append(Buttons[I]);
  Unlock;
  Draw;
  SelectNext;
end; { TLayOutView.InsertButtons }

{****************************************************************************}
{*  TButtonBar                                                             *}
{****************************************************************************}
constructor TButtonBar.Init;
  var B :TBounds;
begin
  B.Assign(20, 10, 620, 35);
  Inherited Init(B);
  { Set View Options }
  ViewOptions := ViewOptions or voSelectable or vofirstClick;
  { Add Buttons }
  Lock;
  B.Assign(10, 5, 60, 20);
  Append(New(PButton, Init(B, 'Open', cmLoadsetFile, 0)));
  B.Assign(70, 5, 120, 20);
  Append(New(PButton, Init(B, 'Stoor', cmSaveSetFile, 0)));
  B.Assign(130, 5, 210, 20);
  Append(New(PButton, Init(B, 'Stoor As', cmSaveSetFileAs, 0)));
  B.Assign(250, 5, 300, 20);
  Append(New(PButton, Init(B, 'Stel', cmExeSet, 0)));
  B.Assign(310, 5, 380, 20);
  Append(New(PButton, Init(B, 'Opskrif', cmExeHeader, 0)));
  B.Assign(390, 5, 450, 20);
  Append(New(PButton, Init(B, 'Uitleg', cmExeLayout, 0)));
  B.Assign(Size.X-85, 5, Size.X-5, 20);
  Append(New(PButton, Init(B, 'Verlaat', cmDoneEditMode, 0)));
  SelectNext;
  UnLock;
end; { TButtonBar.Init }

procedure TButtonbar.Art;
begin
  PlatForm(0, 0, Size.X, Size.Y, $0F23);
end; { TButtonBar.Art }

{****************************************************************************}
{*  TEditMode                                                              *}
{****************************************************************************}
constructor TEditMode.Init;
  var B :TBounds;
begin
  CurrentMode := TMMode_Edit;
  B.Assign(0, 100, GetMaxX, 440);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
  { Insert ButtonBar }
  Lock;
  Buttonbar := New(PButtonBar, Init);
  Append(ButtonBar);
  Unlock;
end; { TEditmode.Init }

destructor TEditMode.Done;
begin
  inherited done;
end; { TEditmode.Done }

procedure TEditMode.Art;
begin
  PlatForm(0, 0, Size.X, Size.Y, $07);
  Level(2, 2, Size.X-2, Size.Y-2, RaiseGrey);
  Level(3, 3, Size.X-3, Size.Y-3, Raisegrey);
  Level(4, 4, Size.X-4, Size.Y-4, LowerGrey);
  Level(5, 5, Size.X-5, Size.Y-5, LowerGrey);
  PlatForm(10, 50, Size.X-10, Size.Y-10, $8FA4);
  PlatForm(Size.X shr 1-50, 37, Size.X shr 1 +50, 47, $0F09);
  WriteStrXY(Size.X shr 1, 41, $0F, 2, 4, JustCenter, False,
    PaperData^.GetTruncFileName);
end; { TEditmode.Art }

procedure TEditMode.Listen(var Speech :TSpeech);
begin
  if Speech.Tone = spCommand then
  case Speech.What of
    cmExeSet       :SetWindow;
    cmExeHeader    :HeaderWindow;
    cmExeLayOut    :LayOutWindow;
    cmExeItem      :ItemWindow;
    cmAcceptSet    :
      begin
        Active^.GetData(PaperData^.Descript);
        PaperData^.Modified := True;
        NewActive(nil);
      end;
    cmAcceptHeader :
      begin
        Active^.Getdata(PaperData^.Header);
        PaperData^.Modified := True;
        NewActive(nil);
      end;
    cmAcceptItem :
      begin
        PPAperItem_Data(PaperData^.Items^.At(CurrentItem))^.
          GetViewData(PPAperItem_View(Active));
        PaperData^.Modified := True;
        NewActive(nil);
      end;
    cmGetViewData :StoreActive;
    cmCancelHeader,
    cmCancelSet,
    cmCancelItem,
    cmDoneEditorActive :NewActive(nil);
    cmQuestNext   :ItemquestionNext;
    cmQuestPrev   :ItemQuestionPrev;
    cmQuestDelete :ItemquestionDelete;
    cmQuestBegin  :ItemQuestionBegin;
    cmQuestEnd    :ItemQuestionEnd;
    cmQuestNewAfter :ItemQuestionNewAfter;
    cmQuestNewAt  :ItemQuestionNewAt;
    cmToggleMenu  :SelectNext;
    cmSelectNext  :if ActiveView = PView(ButtonBar)
                   then ButtonBar^.SelectNext;
    cmSelectPrev  :if ActiveView = PView(ButtonBar)
                   then ButtonBar^.SelectPrevious;
    else begin Inherited Listen(Speech); exit; end;
  end;
  SpeechHeard(Speech);
end; { TEditmode.Listen }

{ Displays a new string on the statusline. }
procedure TEditMode.GotFocus;
begin
  PutMessage(spCommand, cmStatustext,
    NewStr('Testmaker Redigerings modus:  F1 - Hulp  F9 - Lokale Menu en terug'));
end;

{ Executes the PaperSet Info Input Window }
procedure TEditMode.SetWindow;
begin
  if PaperData^.Descript.Mask <> 0 then
  begin
    Message(Application, spCommand, cmPasswordProtect, nil);
    if not Access then Exit;
  end;
  Lock;
  NewActive(New(PSetView, Init));
  SetData(PaperData^.Descript);
  Unlock;
  Draw;
end; { TEditmode.SetWindow }

{ Executes the Header Info Input window }
procedure TEditMode.HeaderWindow;
begin
  if PaperData^.Descript.Mask and Pass_Edit <> 0 then
  begin
    Message(Application, spCommand, cmPasswordProtect, nil);
    if not Access then Exit;
  end;
  Lock;
  NewActive(New(PHeaderView, Init));
  SetData(PaperData^.Header);
  Unlock;
  Draw;
end; { TEditmode.HeaderWindow }

{ Executes the Layout selection window }
procedure TEditMode.LayoutWindow;
begin
  if PaperData^.Descript.Mask and Pass_Edit <> 0 then
  begin
    Message(Application, spCommand, cmPasswordProtect, nil);
    if not Access then Exit;
  end;
  Lock;
  NewActive(New(PLayOutView, Init));
  Unlock;
  Draw;
end; { TEditmode.LayoutWindow }

{ Execute the currently selected Question in the layout window }
procedure TEditMode.ItemWindow;
begin
  Lock;
  with PPAperItem_Data(PaperData^.Items^.At(CurrentItem))^ do
  begin
    NewActive(New_PaperItem_View(Itemtype));
    SetViewdata(PPaperItem_View(Active));
  end;
  Unlock;
  Draw;
end; { TEditmode.ItemWindow }

{ Terminates a Question Window and stores its data }
procedure TEditMode.CloseQuestionWindow;
begin
  with PPAperItem_Data(PaperData^.Items^.At(CurrentItem))^ do
  begin
    GetViewdata(PQuestionItem_View(Active));
    NewActive(nil);
  end;
end; { TEditmode.CloseQuestionWindow }

{ Removes the currently displayed sub-window of the edit mode and insert a
  the new Window View }
procedure TEditMode.NewActive(View :PView);
  var AddNew :Boolean;
begin
  { if a active view exist check if it will terminate }
  if Active <> nil then
    if Active^.Valid(cmTerminate) then AddNew := True
    else
    begin
      if View <> nil then Dispose(View, Done);
      AddNew := False;
    end
  else AddNew := true;
  { Add the new view }
  if AddNew then
  begin
    Lock;
    if Active <> nil then
    begin
      StoreActive;
      Delete(Active);
    end;
    Active := View;
    if Active <> nil then Append(Active);
    Unlock;
    Draw;
  end
end; { TEditmode.NewActive }

{ Displays the next sub-question record of the current question }
procedure TEditMode.ItemQuestionNext;
  var Item :PQuestionItem_Data;
begin
  Item := PaperData^.Items^.At(CurrentItem);
  with Item^ do
    if Current+1 < List^.Count then
    begin
      GetViewData(PQuestionItem_View(Active));
      Inc(Current);
      SetViewData(PQuestionItem_View(Active));
    end;
end; { TEditmode.ItemQuestionNext }

{ Displays the previous sub-question record of the current question }
procedure TEditMode.ItemQuestionPrev;
  var Item :PQuestionItem_Data;
begin
  Item := PaperData^.Items^.At(CurrentItem);
  with Item^ do
    if Current > 0 then
    begin
      GetViewData(PQuestionItem_View(Active));
      Dec(Current);
      SetViewData(PQuestionItem_View(Active));
    end;
end; { TEditmode.ItemQuestionPrev }

{ Deletes the current sub-question record of the current question
  and then displays the next record }
procedure TEditMode.ItemQuestionDelete;
  var Item :PQuestionItem_Data;
begin
  Item := PaperData^.Items^.At(CurrentItem);
  with Item^ do
  begin
    if List^.Count > 0 then
    begin
      List^.AtFree(Current);
      if List^.Count = 0 then List^.AtInsert(0, GetNew) else
        if (Current = List^.Count) and (Current > 0) then Dec(Current);
      SetViewData(PQuestionItem_View(Active));
      Changed;
    end
  end;
end; { TEditmode.ItemQuestionDelete }

{ Displays the first sub-question record of the current question }
procedure TEditMode.ItemQuestionBegin;
  var Item :PQuestionItem_Data;
begin
  Item := PaperData^.Items^.At(CurrentItem);
  with Item^ do
    if Current > 0 then
    begin
      GetViewData(PQuestionItem_View(Active));
      Current := 0;
      SetViewData(PQuestionItem_View(Active));
    end;
end; { TEditmode.ItemQuestionBegin }

{ Displays the last sub-question record of the current question }
procedure TEditMode.ItemQuestionEnd;
  var Item :PQuestionItem_Data;
begin
  Item := PaperData^.Items^.At(CurrentItem);
  with Item^ do
  begin
    if Current+1 < List^.Count then
    begin
      GetViewData(PQuestionItem_View(Active));
      Current := List^.Count-1;
      SetViewData(PQuestionItem_View(Active));
    end;
  end;
end;  { TEditmode.ItemQuestionEnd }

{ Creates a new sub-question record for the current question and displays
  its empty fields. It is inserted after the current record position }
procedure TEditMode.ItemQuestionNewAfter;
  var Item :PQuestionItem_Data;
      P :PObject;
begin
  Item := PaperData^.Items^.At(CurrentItem);
  with Item^ do
  begin
    P := GetNew;
    if P <> nil then
    begin
      GetViewData(PQuestionItem_View(Active));
      Inc(Current);
      List^.AtInsert(Current, P);
      SetViewData(PQuestionItem_View(Active));
      Changed;
    end;
  end;
end;  { TEditmode.ItemQuestionNewAfter }

{ Creates a new sub-question record for the current question and displays
  its empty fields. It is inserted at the current record position }
procedure TEditMode.ItemQuestionNewAt;
  var Item :PQuestionItem_Data;
      P :PObject;
begin
  Item := PaperData^.Items^.At(CurrentItem);
  with Item^ do
  begin
    P := GetNew;
    if P <> nil then
    begin
      GetViewData(PQuestionItem_View(Active));
      List^.AtInsert(Current, P);
      SetViewData(PQuestionItem_View(Active));
      Changed;
    end;
  end;
end; { TEditmode.ItemQuestionNewAt }


{ Stores the data of the current sub-question record of the current question }
procedure TEditMode.StoreActive;
begin
  if PaperData^.Items^.Count > 0 then
    if IsQuestionView(Active) then
       PQuestionItem_Data(PaperData^.Items^.At(CurrentItem))^.
         GetViewData(PQuestionItem_View(Active));
end; { TEditmode.StoreActive }

end. { Unit }