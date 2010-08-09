program translate_demo;

uses
  Forms,
  main in 'main.pas' {Form6},
  GTranslate in '..\..\source\GTranslate.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
