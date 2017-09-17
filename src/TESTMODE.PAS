Unit Testmode;

Interface
  uses sView;





{ Testmode Type }
type
  PTestMode = ^TTestMode;
  TTestMode = Object(TViewGroup)
    constructor Init;
    procedure   Art; virtual;
  end;


Implementation
  uses SBasic, graph, sgraph;

{************************ TTestMode Object *********************************}
constructor TTestMode.Init;
  var B :TBounds;
begin
  B.Assign(0, 100, GetMaxX, 440);
  Inherited Init(B);
  ViewOptions := ViewOptions or voSelectable or voFirstClick;
end; { TTestMode.Init }

procedure TTestmode.Art;
begin
  PlatForm(0, 0, Size.X, Size.Y, $07);
  Level(2, 2, Size.X-2, Size.Y-2, RaiseGrey);
  Level(3, 3, Size.X-3, Size.Y-3, Raisegrey);
  Level(4, 4, Size.X-4, Size.Y-4, LowerGrey);
  Level(5, 5, Size.X-5, Size.Y-5, LowerGrey);
  PlatForm(10, 50, Size.X-10, Size.Y-10, $8FA4);
end; { TTestmode.Art }


end.