{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* Commands and other constants                                             *}
{****************************************************************************}
Unit Consts;

Interface

{***� Notification Messages �***}
const
  msgItemSelected = 1;
  msgPosChanged   = 2;
  msgClicked      = 3;
  msgItemsChanged = 4;
  msgBarChanged   = 5;
  msgChanged      = 6;
  msgDirChanged   = 7;
  msgDriveChanged = 8;
  msgFileChanged  = 9;

{***� General Commands for views �***}
const
  cmQuit          = 1;
  cmClose         = 2;
  cmTerminate     = 3;
  cmDraw          = 4;
  cmNext          = 5;
  cmPrevious      = 6;
  cmOk            = 10;
  cmAccept        = 11;
  cmCancel        = 12;
  cmYes           = 13;
  cmNo            = 14;
  cmAgain         = 10;
  cmNew           = 12;
  cmInsertNew     = 13;
  cmAppendNew     = 14;
  cmEdit          = 15;
  cmDelete        = 16;
  cmLoad          = 17;
  cmSave          = 18;
  cmHelpDisplay   = 19;
  cmEndModal      = 20;

{***� Testmaker Modes �***}
const
  TMMode_None  = 0;
  TMMode_Edit  = 1;
  TMMode_Print = 4;

{***� Print OutPut Targets �***}
const
  PrintTarget_File    = 1;
  PrintTarget_Printer = 2;

{***� Paper Components �***}
const
  QuestionPaper  = 1;
  AnsweringSheet = 2;
  Memmo          = 4;

{***� Testmaker Password masks �***}
const
  Pass_None       = 0;
  Pass_PrintPaper = 1;
  Pass_PrintSheet = 2;
  Pass_PrintMemmo = 4;
  Pass_Edit       = 8;
  Pass_Print      = 14;

{***� Testmaker Item types �***}
const
  tmAfdeling  = 50;
  tmMonkey    = 51;
  tmColumnAB  = 52;
  tmColABN    = 53;
  tmTerms     = 54;
  tmMessage   = 55;

{***� Commands �***}
const
  cmSelectionMenu  = 100;
  cmEditMenu       = 101;
  cmEditNew        = 102;
  cmEditOld        = 103;
  cmTest           = 104;
  cmPrintMenu      = 106;
  cmPrinterConfig  = 107;
  cmAboutMessage   = 108;

  cmExeSet         = 150;
  cmExeHeader      = 151;
  cmExeLayOut      = 152;
  cmExeItem        = 153;

  cmDoneMode       = 170;
  cmDoneEditMode   = 171;
  cmDoneItem       = 172;

  cmStartPrinting  = 200;
  cmAcceptPrnCnf   = 201;
  cmCancelPrnCnf   = 202;
  cmDonePrnWin     = 203;

{***� Editor Commands �***}
  cmNewSetFile         = 220;
  cmLoadSetFile        = 221;
  cmSaveSetFile        = 222;
  cmSaveSetFileAs      = 223;

  cmQuestNext          = 233;
  cmQuestPrev          = 234;
  cmQuestBegin         = 235;
  cmQuestEnd           = 236;
  cmQuestNewAfter      = 237;
  cmQuestNewAt         = 238;
  cmQuestDelete        = 239;
  cmItemNext           = 240;
  cmItemPrev           = 241;
  cmToggleInstructions = 242;

  cmAcceptSet          = 1001;
  cmCancelSet          = 1002;
  cmAcceptHeader       = 1003;
  cmCancelHeader       = 1004;
  cmAcceptItem         = 1005;
  cmCancelItem         = 1006;
  cmDoneEditorActive   = 1007;
  cmGetViewData        = 1008;
  cmHidebuttons        = 1009;
  cmShowButtons        = 1010;
  cmToggleMenu         = 1011;
  cmSelectPrev         = 1012;
  cmSelectNext         = 1013;

  cmStatusText         = 1100;
  cmHelpClose          = 1200;
  cmPasswordProtect    = 1300;

{***� Another View state �***}
const
  vsModeChange = $1000;

{***� Testmaker PaperItem Objects �***}
  IAfdeling  = 50;
  IMonkey    = 51;
  IColumnAB  = 52;
  IColABN    = 53;
  ITerms     = 54;
  IMessage   = 55;

{***� Help contexts �***}
const
  hcNoContext        = 0;
  hcButOpstel        = 1;
  hcButTest          = 2;
  hcButPrint         = 4;
  hcButVerlaat       = 5;
  hcClustPrnTarget   = 6;
  hcILinePrnToFile   = 7;
  hcClustCombo       = 8;
  hcClust4TermAns    = 9;
  hcClustMonkAns     = 10;
  hcButStartPrn      = 11;
  hcButSourceFile    = 12;
  hcButPrnConfig     = 13;
  hcButPrnLeave      = 14;
  hcColsPerLine      = 15;
  hcLinesPerPage     = 16;
  hcPrinterList      = 17;
  hcButPrnCnfAccept  = 18;
  hcButPrnCnfCancel  = 19;


Implementation

end. { Unit }