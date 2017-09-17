{****************************************************************************}
{* TestMaker Test Paper Creating Tool                                       *}
{*   Edit by Hannes de Jager 1996 & 1997                                    *}
{* Unit for overlay process                                                 *}
{****************************************************************************}
Unit TMOVRLAY;

Interface

Implementation
  uses Overlay, Crt;

begin
  Clrscr;
  Writeln('Testmaker Weergawe 1.0');
  Writeln('Deur: Hannes de Jager (1997)');
  { Initialize overlay manager }
  OvrInit('TESTMAKE.OVR');
  { Halt on error }
  if OvrResult <> 0 then
  begin
    Writeln('Fout : TESTMAKE.OVR kon nie gelaai word nie !');
    Halt(1);
  end;
  { Try to use EMS }
  OvrInitEms;
  if OvrResult <> 0 then
    Writeln('Ems geheue ondersteuning huidiglik nie beskikbaar.')
  else  Writeln('TESTMAKE.OVR is in Ems geheue gelaai.');
  OvrResult := OvrOk;
end. { Unit }