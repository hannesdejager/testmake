{****************************************************************************}
{*  TestMaker Test Paper Creating Tool                                      *}
{*    Edit by Hannes de Jager 1996 & 1997                                   *}
{*  Basic object types                                                      *}
{*                                                                          *}
{* Implementation of the following objects                                  *}
{*   ş TBounds for screen coordinates                                       *}
{*   ş TFileCollection  : A collection of files                             *}
{*   ş TDriveCollection : A collection of drives                            *}
{****************************************************************************}
Unit sBasic;
  {$F-,O-,Q-,R-,S-}

interface
  uses Objects, sTypes;

{***ş TBounds object ş***}
type
  TBounds = object(TRect)
    function  WithIn(P :TPoint) :Boolean;
    function  Width  :Integer;
    function  Height :Integer;
  end;

{***ş File Collection ş***}
type
  PFileItem = ^TFileItem;
  TFileItem = record
    Attr :Byte;
    Time :Longint;
    Size :Longint;
    Name :TFileStr;
  end;

  PFileCollection = ^TFileCollection;
  TFileCollection = Object(TCollection)
    procedure FreeItem(Item: Pointer); virtual;
  end;

{***ş Drive Collection ş***}
type
  PDriveItem = ^TDriveItem;
  TDriveItem = record
    Drive  :Char;
    Volume :String[11];
    Size   :LongInt;
    Free   :LongInt;
  end;

  PDriveCollection = ^TDriveCollection;
  TDriveCollection = Object(TCollection)
    procedure FreeItem(Item: Pointer); virtual;
  end;



implementation

{ Returns true if the given point resides within then bounding rectangle
  represented by the object }
function TBounds.WithIn(P :TPoint) :Boolean;
begin
  WithIn := (P.X >= A.X) and (P.X <= B.X) and
            (P.Y >= A.Y) and (P.Y <= B.Y);
end;

{ Returns the width of the bounding rectangle }
function TBounds.Width :Integer;
begin
  Width := B.X-A.X;
end;

{ Returns the width of the height of the bounding rectangle }
function TBounds.Height :Integer;
begin
  Height := B.Y-A.Y;
end;

{****************************************************************************}
{*  TFileCollection                                                              *}
{****************************************************************************}
procedure TFileCollection.FreeItem(Item :Pointer);
begin
  Dispose(PFileItem(Item));
end;

{****************************************************************************}
{*  TDriveCollection                                                              *}
{****************************************************************************}
procedure TDriveCollection.FreeItem(Item :Pointer);
begin
  Dispose(PDriveItem(Item));
end;



end. { Unit }