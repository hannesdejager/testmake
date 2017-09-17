{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{****************************************************************************}
Program TestMaker;
  Uses {TMOvrlay,} Main;

{O Main     }   { Unit files to overlay }
{O TMData   }
{O Selector }
{O EditMode }
{O PRNMode  }


{***þ Program Object variable þ***}
var TM :TProgram;

begin
  TM.Init; { Initialize the Programs }
  TM.Run;  { Run the Program }
  TM.Done; { Cleanup Operations }
end.