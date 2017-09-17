{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* Constants and types for general use                                      *}
{****************************************************************************}
Unit sTypes;

Interface

const
{***þ Control Operation Constants þ***}
  qNone         = 0;
  qUp           = 1;    { Movement }
  qDown         = 2;
  qLeft         = 3;
  qRight        = 4;
  qHome         = 5;
  qEnd          = 6;
  qHomeX        = 7;
  qEndX         = 8;
  qHomeY        = 9;
  qEndY         = 10;
  qMarkLeft     = 11;
  qMarkRight    = 12;
  qSelect       = 13;   { selection }
  qTag          = 14;
  qEdit         = 15;   { edit }
  qAppend       = 16;
  qInsert       = 17;
  qOverWrite    = 18;
  qDelete       = 19;
  qBack         = 20;
  qClear        = 21;
  qToggleIns    = 22;   { toggle }
  qConvertUpper = 23;   { conversion }
  qConvertLower = 24;

{***þ Character set þ***}
type
  TCharSet = Set of Char;
  TCommandSet = set of Byte;

{***þ Typecasting Arrays þ***}
type
	TByteArray    = array[0..$FFFE] of Byte;
	TWordArray    = array[0..$7FFE] of Word;
	TLongArray    = array[0..$3FFE] of LongInt;
	TPointerArray = array[0..$3FFE] of Pointer;

{***þ Typecasting Buffers þ***}
type
  TByteBuffer = array[1..32768] of Byte;
  TCharBuffer = array[1..32768] of Char;
  TWordBuffer = array[1..16384] of Word;

{***þ Typecasting Records þ***}
	TLongRec = record
		case Integer of
			0 : (Long            :LongInt);
			1 : (Ptr             :Pointer);
			2 : (Offset, Segment :Word);
			3 : (Lo, Hi          :Word);
			4 : (B1, B2, B3, B4  :Byte);
	end;

	TWordRec = record
		case Integer of
			0 :(W :Word);
			1 :(Lo, Hi: Byte);
	end;

{***þ String Types with defined length þ***}
type
  String8  = String[8];
  String32 = String[32];
  String5  = String[5];
  String17 = String[17];

{***þ File name string types þ***}
type
	TFileExt   = String[3];
	TFileName  = String[8];
	TFileStr   = String[12];
  TDirStr    = String[12];
	TExtrFile  = String[79];

{***þ String Relative þ***}
type
  PString = ^String;
  PPalette = ^TPalette;
  TPalette = String;

{***þ General Types þ***}
type
  TOffset = LongInt;

{***þ Date data record with numeric format þ***}
type
  PDateRecord = ^TDateRecord;
  TDateRecord = record
    Year, Month, Day, DayofWeek :Word;
  end;

{***þ Date data record with numeric and string format
       used for fancy displays of dates þ***}
  TFancyDate = record
    DayofWeek :PString;
    Day       :Word;
    Month     :PString;
    Year      :Word;
  end;

{***þ Linking þ***}
type
  PLPString = ^TLPString;
  TLPString = record
    Value :PString;
    Next  :PLPString;
  end;


Implementation


end.  { Unit }