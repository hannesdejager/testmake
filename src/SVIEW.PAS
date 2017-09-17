{****************************************************************************}
{*  TestMaker Test Paper Creating Tool                                      *}
{*    Edit by Hannes de Jager 1996                                          *}
{*  View and Group objects                                                  *}
{****************************************************************************}
Unit SView;
  {$F-,O-,Q-,R-,S-}

Interface
  Uses Objects, sBasic, sInput, sTypes;

{***þ View Communication Constants þ***}
const
  spNone      = $00;
  spCommand   = $01;
  spRespond   = $02;
  spNotify    = $04;
  spRecommend = $08;
  spRequest   = $10;


{***þ View Options þ***}
const
 voSelectable = $0001;
 voFirstclick = $0002;
 voMoveable   = $0004;

{***þ View States þ***}
const
  vsVisible    = $0001;
  vsModal      = $0002;
  vsSelected   = $0004;
  vsPressed    = $0008;
  vsDisabled   = $0010;
  vsInsert     = $0020;
  vsDeleted    = $F000;

{***þ View Pointer þ***}
type
  PView = ^TView;
  PViewGroup = ^TViewGroup;

{***þ View Communication transfer Record þ***}
  TSpeech = record
    Talker  :PView; { The View that called }
    Tone    :Word;  { Command, Respond, Notify or Recomend }
    What    :Word;
    case Word of    { Info }
      0 :(InfoPtr     :Pointer);
      1 :(InfoPChar   :PChar);
	  2 :(InfoPString :PString);
      3 :(InfoLong    :LongInt);
      4 :(InfoWord    :Word);
      5 :(InfoInt     :Integer);
      6 :(InfoByte    :Byte);
      7 :(InfoShort   :ShortInt);
      8 :(InfoChar    :Char);
  end;

{***þ View Object þ***}
  TView = Object(TObject)
    Owner       :PViewGroup;
    Next        :PView;
    Origin      :TPoint;
    Size        :TPoint;
    ViewOptions :Word;
    ViewState   :Word;
    InputMask   :Word;
    HelpCtx     :Word;
    constructor Init(Bounds :TBounds);
    procedure   Art; virtual;
    function    Previous :PView;
    procedure   Draw; virtual;
    procedure   MouseInput(var Input :TMouseInput); virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    procedure   Listen(var Speech :TSpeech); virtual;
    procedure   Speak(Listener :PView; var Speech :TSpeech);
    function    Message(Listener :PView; ATone, AWhat :Word; Info :Pointer) :PView;
    procedure   PutSpeech(var Speech :TSpeech);
    function    StateOn(StateFlags :Word) :Boolean;
    procedure   SetState(StateFlag :Word; Enable :Boolean); virtual;
    procedure   ToggleState(StateFlag :Word);
    function    PointIn(P :TPoint) :Boolean;
    procedure   PutMessage(ATone, AWhat :Word; Info :Pointer);
    procedure   SpeechHeard(var speech :TSpeech);
    function    ID :Word; virtual;
    function    Palette :PPalette; virtual;
    function    GetColor(Color :Word) :Word;
    procedure   MakeLocal(Source :TPoint; var Dest :TPoint);
    procedure   MakeGlobal(Source :TPoint; var Dest :TPoint);
    function    Execute :Word; virtual;
    procedure   EndModal(Condition :Word);
    procedure   InputHandled(var Input);
    procedure   Select;
    function    Valid(Command :Word) :Boolean; virtual;
    procedure   Turn; virtual;
    procedure   Terminate; virtual;
    procedure   Getdata(var Rec); virtual;
    procedure   SetData(var Rec); virtual;
    function    DataSize :Word; virtual;
    procedure   GotFocus; virtual;
    procedure   LostFocus; virtual;
    procedure   Lock;
    procedure   Unlock;
    function    Locked :Boolean;
    private
       LockCount :Word;
  end;

{***þ View Group Object þ***}
  TViewGroup = Object(TView)
    LastView   :PView;
    ActiveView :PView;
    constructor Init(Bounds :TBounds);
    destructor  Done; virtual;
    procedure   Append(View :PView);
    procedure   Insert(View, Target :PView);
    procedure   Remove(View :PView);
    procedure   Delete(View :PView);
    procedure   ForEach(Action :Pointer);
    function    FirstThat(Condition :Pointer) :PView;
    procedure   Draw; virtual;
    procedure   MouseInput(var Input :TMouseInput); virtual;
    procedure   KeybordInput(var Input :TKeybordInput); virtual;
    procedure   SelectNext;
    procedure   SelectPrevious;
    procedure   SelectWithMouse(Where :TPoint);
    procedure   Listen(var Speech :TSpeech); virtual;
    function    ExecView(P :PView) :Word;
    function    Valid(Command :Word) :Boolean; virtual;
    procedure   Turn; virtual;
    procedure   Getdata(var Rec); virtual;
    procedure   SetData(var Rec); virtual;
    function    DataSize :Word; virtual;
    private
      function    ViewWithPoint(Where :TPoint) :PView;
      procedure   DrawSubViews;
  end;


Implementation
  uses sProcs, Graph, consts;

const
  { The Word returned when a model view terminates }
  ModalEndCondition :Word = 0;
  { The next message to be send to the modal view }
  NextMessage :TSpeech =
    (Talker :nil;
     Tone   :spNone;
     What   :0);

{****************************************************************************}
{*  TView                                                                   *}
{****************************************************************************}
constructor TView.Init(Bounds :TBounds);
begin
  Inherited Init;
  Origin := TPoint(Bounds.A);
  Size.X := Bounds.Width;
  Size.Y := Bounds.Height;
  ViewState := vsVisible;
  InputMask := $FF00;
  if MouseAvail then inputMask := inkeybord or inMouse;
end;

procedure TView.Art;
begin
  Abstract('TView.Art');
end;

procedure TView.Draw;
  var HideMousePointer :Boolean;
      P :TPoint; B :TBounds;
begin
  if Locked then Exit;
  if not StateOn(vsVisible) then Exit;
  ClearMem(P, Sizeof(P));
  MakeGlobal(P, P);
  B.Assign(P.X-10, P.Y-10, P.X+Size.X+10, P.Y+Size.Y+10);
  HideMousePointer := MouseAvail and B.Within(MouseWhere);
  SetViewPort(P.X, P.Y, P.X+Size.X, P.Y+Size.Y, ClipOn);
  if HideMousePointer then HideMouse;
  Art;
  if HideMousePointer then ShowMouse;
end;

function TView.Previous :PView;
  var P :PView;
begin
  P := @Self;
  while (P^.Next <> @self) do P := P^.Next;
  Previous := P;
end;

procedure TView.MouseInput(var Input :TMouseInput);
begin
end;

procedure TView.KeybordInput(var Input :TKeybordInput);
begin;
  if Input.What and inKeyDown <> 0 then
    case Input.KeyCode of
     kbCtrlBreak :PutMessage(spCommand, cmQuit, nil);
     kbF1 :
       Putmessage(spCommand, cmHelpDisplay, Ptr(0, HelpCtx));
     else Exit;
   end;
   InputHandled(Input);
end;

function TView.StateOn(StateFlags :Word) :Boolean;
  var P :PView;
begin
  StateOn := StateFlags and ViewState <> 0;
  if not
   (StateFlags and (vsSelected or vsDisabled or vsVisible) <> 0) then exit;
  P    := @Self;
  while P <> nil do
  begin
    if not(P^.ViewState and StateFlags <> 0) then StateOn := False;
    P := P^.Owner;
  end;
end;

procedure TView.SetState(StateFlag :Word; Enable :Boolean);
  var Speech :TSpeech;
begin
  Case Enable of
    True  :ViewState := ViewState or StateFlag;
    False :ViewState := ViewState - (ViewState and StateFlag);
  end;
  if StateFlag and vsDisabled <> 0 then
  begin
    SetState(vsSelected, False);
    if Owner <> nil then Owner^.SelectNext;
  end;
  if StateFlag and vsSelected <> 0 then
  begin
    if Enable then GotFocus else LostFocus;
    Draw;
  end;
  if StateFlag and vsVisible <> 0 then
  with Speech do
  begin
    Talker := @Self;
    Tone   := spCommand;
    What   := cmDraw;
    Speak(Owner, Speech);
  end;
end;

procedure TView.ToggleState(StateFlag :Word);
begin
  SetState(StateFlag, not (ViewState and StateFlag <> 0));
end;

function TView.PointIn(P :TPoint) :Boolean;
begin
  MakeLocal(P, P);
  PointIn := (P.X >= 0) and (P.X <= Size.X) and
             (P.Y >= 0) and (P.Y <= Size.Y);
end;

procedure TView.Speak(Listener :PView; var Speech :TSpeech);
begin
  if Listener <> nil then Listener^.Listen(Speech);
end;

procedure TView.PutSpeech(var Speech :TSpeech);
begin
  NextMessage := Speech;
end;

function TView.Message
  (Listener :PView; ATone, AWhat :Word; Info :Pointer) :PView;
  var Speech :TSpeech;
begin
  with Speech do
  begin
    Talker  := @Self;
    Tone    := ATone;
    What    := AWhat;
    InfoPtr := Info;
  end;
  if Listener <> nil then Listener^.Listen(Speech);
  with Speech do
    if Tone = spNone then Message := Talker else Message := nil;
end;

procedure TView.PutMessage(ATone, AWhat :Word; Info :Pointer);
  var Speech :TSpeech;
begin
  with speech do
  begin
    Talker  := @Self;
    Tone    := ATone;
    What    := AWhat;
    InfoPtr := Info;
  end;
  PutSpeech(Speech);
end;

procedure TView.SpeechHeard(var Speech :TSpeech);
begin
  with Speech do
  begin
    Talker := @Self;
    Tone := spNone;
  end;
end;

procedure TView.Listen(var Speech :TSpeech);
begin
  if Speech.Tone = spCommand then
  Case Speech.What of
    cmDraw      :Draw;
    cmTerminate :Terminate;
    cmEndModal  :EndModal(cmEndModal);
  end;
end;

function TView.ID :Word;
begin
  Abstract('TView.ID');
end;

function TView.Palette :PPalette;
begin
  Abstract('TView.Palette');
end;

function TView.GetColor(Color :Word) :Word;
  var Pal :PPalette;
begin
  Pal := Palette;
  if (Color > Length(Pal^)) or (Color = 0) then GetColor := $00
  else
    Getcolor := Byte(Pal^[Color]);
end;

procedure TView.MakeLocal(Source :TPoint; var Dest :TPoint);
  var P :PView;
begin
  Dest := Source;
  P    := @Self;
  while P <> nil do
  begin
    Dest.X := Dest.X - P^.Origin.X;
    Dest.Y := Dest.Y - P^.Origin.Y;
    P := P^.Owner;
  end;
end;

procedure TView.MakeGlobal(Source :TPoint; var Dest :TPoint);
  var P :PView;
begin
  Dest := Source;
  P := @Self;
  while P <> nil do
  begin
    Dest.X := Dest.X + P^.Origin.X;
    Dest.Y := Dest.Y + P^.Origin.Y;
    P := P^.Owner;
  end
end;

function TView.Execute :Word;
  var MInput :TMouseInput;
      KInput  :TKeybordInput;
      Transfer :Boolean;
      Speech   :TSpeech;
begin
  if StateOn(vsDisabled) then Exit;
  SetState(vsModal+vsSelected, True);
  repeat
    Speech := NextMessage;
    NextMessage.Tone := spNone;
    if Speech.Tone <> spNone then Listen(Speech);
    GetKeyInput(KInput, False, False);
    with KInput do
      if What and InputMask <> 0 then KeybordInput(KInput);
    GetMouseInput(MInput);
    with MInput Do
      if (What and InputMask <> 0) and PointIn(Where) then MouseInput(MInput);
    Turn;
  until not StateOn(vsModal);
  Execute := ModalEndCondition;
end;

procedure TView.EndModal(Condition :Word);
begin
  if not StateOn(vsModal) or not Valid(cmClose) then Exit;
  SetState(vsModal, False);
  ModalEndCondition := Condition;
end;

procedure TView.InputHandled(var Input);
begin
  with TKeybordInput(Input) do
  begin
    What := inNothing;
    HandledBy := @Self;
  end;
end;

procedure TView.Select;
begin
  if not ((Owner <> nil) and (ViewOptions and voSelectable <> 0)) or
     StateOn(vsSelected) or StateOn(vsDisabled) then exit;
  if Owner^.ActiveView <> nil then
    Owner^.ActiveView^.SetState(vsSelected, False);
  Owner^.ActiveView := @Self;
  SetState(vsSelected, True);
end;

function TView.Valid(Command :Word) :Boolean;
begin
  Valid := True;
end;

procedure TView.Turn;
begin
end;

procedure TView.Terminate;
begin
  if Valid(cmTerminate) then
  begin
    SetState(vsDeleted, True);
    if Message(Owner, spNotify, cmTerminate, @Self) = nil then EndModal(cmQuit);
  end;
end;

procedure TView.Getdata(var Rec);
begin
end;

procedure TView.SetData(var Rec);
begin
end;

function TView.DataSize :Word;
begin
  DataSize := 0;
end;

procedure TView.Lock;
begin
  if LockCount < 65535 then Inc(LockCount);
end;

procedure TView.Unlock;
begin
  if LockCount > 0 then Dec(LockCount);
end;

function TView.Locked :Boolean;
  var P :PViewGroup;
begin
  P := @Self;
  Locked := False;
  while P <> nil do
  begin
    if P^.LockCount > 0 then Locked := True;
    P := P^.Owner;
  end;
end;

procedure TView.GotFocus;
begin
end;

procedure TView.LostFocus;
begin
end;


{****************************************************************************}
{*  TViewGroup                                                              *}
{****************************************************************************}
constructor TViewGroup.Init(Bounds :TBounds);
begin
  inherited Init(Bounds);
  LastView   := nil;
  ActiveView := nil;
end;

destructor TViewGroup.Done;
    procedure FreeView(View :PView); far;
    begin
      Dispose(View, Done);
    end;
begin
  Lock;
  ForEach(@FreeView);
  Unlock;
  inherited Done;
end;

procedure TViewGroup.Append(View :PView);
begin
  {$IFNDEF FinalVersion}
  if View = nil then Abort('Append of nil View');
  {$EndIf}
  View^.Owner := @Self;        { Set view's owner }
  if LastView <> nil then      { if there are already views in the list }
  begin
	  View^.Next := LastView^.Next;
    LastView^.Next := View;
    LastView := View;
  end
  else                         { if this view is the only one in the list }
  begin
    View^.Next := View;
    LastView := View;
  end;
  View^.Select;
end;

procedure TViewGroup.Insert(View, Target :PView);
begin
  {$IFNDEF FinalVersion}
  if View = nil then Abort('Insert of nil View');
  {$EndIf}
  if (Target = nil) or (LastView = nil) then begin Append(View); exit; end;
  with View^ do
  begin
    View^.Owner := @Self;        { Set view's owner }
    View^.Next := Target^.Next;
    Target^.Next := View;
    Select;
  end;
end;

procedure TViewGroup.Remove(View :PView);
begin
  {$IFNDEF FinalVersion}
  if View = nil then Abort('Remove of nil View');
  {$EndIf}
  if View = LastView then LastView := View^.Previous;
  Lock;
  if View = ActiveView then SelectNext;
  Unlock;
  View^.Previous^.Next := View^.Next;
  if View = LastView then LastView := nil;
  if View = ActiveView then Activeview := nil;
  Draw;
end;

procedure TViewGroup.Delete(View :PView);
begin
  {$IFNDEF FinalVersion}
  if View = nil then Abort('Delete of nil View');
  {$EndIf}
  Remove(View);
  Dispose(View, Done);
  View := nil;
end;

{ ForEach Help Routines }
function CallerFrame: Word; inline(
  $8B/$46/$00  { MOV   AX, [BP] }
);
procedure ActionCall(View :PView; Action :Pointer; Frame :Word); near; assembler;
asm
  LES    DI, View
  PUSH   ES                { Pass Parameter - View }
  PUSH   DI
  PUSH   WORD  PTR Frame   { Pass Callers Stack Frame }
  CALL   DWORD PTR Action  { Call Local Procedure }
end;
  { procedure Action(View :PView); far; local; }
procedure TViewGroup.ForEach(Action :Pointer);
  var First, P, P2 :PView;
      CallerStackFrame :Word;
begin
  if LastView = nil then exit; { Can't do an action on an empty List }
  CallerStackFrame := CallerFrame;
  First := LastView^.Next;
  P := First;         { Set P to point to First View }
  repeat
    P2 := P;
    if P2 <> nil then
    begin
      P := P^.Next;
      ActionCall(P2, Action, CallerStackFrame);
    end;
  until P = First;
end;

function ConditionCall
  (View :PView; Condition :Pointer; Frame :Word) :Boolean; near; assembler;
asm
  LES    DI, View
  PUSH   ES                  { Pass Parameter - View }
  PUSH   DI
  PUSH   WORD  PTR Frame     { Pass Callers Stack Frame }
  CALL   DWORD PTR Condition { Call Local Procedure }
end;

  { function Action(View :PView) :Boolean; far; local; }
function TViewGroup.FirstThat(Condition :Pointer) :PView;
  var P :PView;
      CallerStackFrame :Word;
begin
  FirstThat := nil;
  if LastView = nil then exit; { Can't do an action on an empty List }
  CallerStackFrame := CallerFrame;
  P := LastView^.Next;         { Set P to point to First View }
  repeat
    if ConditionCall(P, Condition, CallerStackFrame) then
    begin
      FirstThat := P;
      Break;
    end else FirstThat := nil;
    P := P^.Next;
  until P = LastView^.Next;
end;

procedure TViewGroup.Draw;
begin
  if Locked then Exit;
  inherited Draw;
  DrawSubViews;
end;

procedure TViewGroup.MouseInput(var Input :TMouseInput);
  var Transfer :Boolean;
begin
  with Input do
  begin
    if What and inMouseDown <> 0 then
    begin
		  Transfer := ActiveView^.PointIn(Where);
      if not Transfer then
      begin
        SelectWithMouse(Where);
        if ActiveView^.PointIn(Where) then
          if not ActiveView^.ViewOptions and voFirstClick <> 0 then
          begin
    			  InputHandled(Input);
            Transfer := False;
          end
          else Transfer := True;
      end;
    end
    else Transfer := True;
  end;
  Transfer := Transfer and (ActiveView <> nil);
  if Transfer then ActiveView^.MouseInput(Input);
end;

procedure TViewGroup.KeybordInput(var Input :TKeybordInput);
begin
  if ActiveView = nil then exit;
  ActiveView^.KeybordInput(Input);
  Inherited KeybordInput(Input);
  if Input.What <> inNothing then
  case Input.KeyCode of
    kbTab :
      begin
        SelectNext;
        InputHandled(Input);
      end;
    kbShiftTab :
      begin
        SelectPrevious;
        InputHandled(Input);
      end;
    else Exit;
  end;
End;

procedure TViewGroup.SelectNext;
  var P, A :PView;
begin
  if ActiveView = nil then exit;
  A := ActiveView;
  P := ActiveView^.Next;
  while (ActiveView = A) and (P <> A) do
  begin
    P^.Select;
    P := P^.Next;
  end;
end;

procedure TViewGroup.SelectPrevious;
  var P, A :PView;
begin
  if ActiveView = nil then exit;
  A := ActiveView;
  P := ActiveView^.Previous;
  while (ActiveView = A) and (P <> A) do
  begin
    P^.Select;
    P := P^.Previous;
  end;
end;

procedure TViewGroup.SelectWithMouse(Where :TPoint);
  var P :PView;
begin
  P := ViewWithPoint(Where);
  if P <> nil then  P^.Select;
end;

procedure TViewgroup.Listen(var Speech :TSpeech);
    procedure SpeakToThisOne(View :PView); far;
    begin
      if not View^.StateOn(vsDisabled) then View^.Listen(Speech);
    end;
begin
  inherited Listen(Speech);
  if Speech.Tone = spCommand then
    Case Speech.What of
      cmDraw :
        begin
          Draw;
          SpeechHeard(Speech);
        end;
      cmNext :
        begin
          SelectNext;
          SpeechHeard(Speech);
        end;
      cmPrevious :
        begin
          SelectPrevious;
          SpeechHeard(Speech);
        end;
      cmQuit :EndModal(cmQuit);
    end;
  ForEach(@SpeakToThisOne);
end;

function TViewGroup.ExecView(P :PView) :Word;
begin
  Lock;
  Append(P);
  Unlock;
  ExecView := P^.Execute;
  Delete(P);
end;

function TViewGroup.Valid(Command :Word) :Boolean;
    procedure CheckForValid(View :PView); far;
    begin
      if Not View^.Valid(Command) then Valid := False;
    end;
begin
  Valid := True;
  ForEach(@CheckForValid);
end;

Procedure TViewGroup.Turn;
    procedure ViewTurn(View :PView); far;
    begin
      if View^.StateOn(vsDeleted) then Delete(View) else
        if not View^.StateOn(vsDisabled) then View^.Turn;
    end;
begin
  ForEach(@ViewTurn);
end;

procedure TViewGroup.Getdata(var Rec);
   procedure GetViewData(View :PView); far;
     var Amount :Word;
   begin
     View^.GetData(Rec);
     Amount := View^.DataSize;
     asm
       MOV  BX, [BP+6]              { Get Parent's Stack Frame }
       MOV  AX, SS:[BX+OFFSET Rec]  { Put ParamsIndex in AX    }
       ADD  AX, Amount
       MOV  SS:[BX+OFFSET Rec], AX
     end;
   end;
begin
  ForEach(@GetViewData);
end;

procedure TViewGroup.SetData(var Rec);
   procedure SetViewData(View :PView); far;
     var Amount :Word;
   begin
     View^.SetData(Rec);
     Amount := View^.DataSize;
     asm
       MOV  BX, [BP+6]              { Get Parent's Stack Frame }
       MOV  AX, SS:[BX+OFFSET Rec]  { Put ParamsIndex in AX    }
       ADD  AX, Amount
       MOV  SS:[BX+OFFSET Rec], AX
     end;
   end;
begin
  ForEach(@SetViewData);
end;

function TViewGroup.DataSize :Word;
  var Total :Word;
     procedure GetViewSize(View :PView); far;
     begin
       Inc(Total, View^.DataSize);
     end;
begin
  Total := 0;
  ForEach(@GetViewSize);
  DataSize := Total;
end;

function TViewGroup.ViewWithPoint(Where :TPoint) :PView;
    function ContainsMouse(View :PView) :Boolean; far;
    begin
      ContainsMouse := View^.PointIn(Where);
    end;
begin
  ViewWithPoint := FirstThat(@ContainsMouse);
end;

procedure TViewGroup.DrawSubViews;
    procedure DrawThisView(View :PView); far;
    begin
      if View <> nil then View^.Draw;
    end;
begin
  ForEach(@DrawThisView);
end;


end.  { Unit }