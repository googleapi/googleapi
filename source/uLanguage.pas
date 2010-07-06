unit uLanguage;

interface

uses Windows,Dialogs,SysUtils;

{$DEFINE RUSSIAN}

{$IFDEF RUSSIAN}
  {$I Languages\lang_russian.inc}
{$ELSE}
  {$I Languages\lang_english.inc}
{$ENDIF}

procedure Test;

implementation

procedure Test;
begin
  ShowMessage(rcErrPrepareNode);
//  LoadResourceModule()
end;

initialization

end.
