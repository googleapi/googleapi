program feedburner;

uses
  Forms,
  main in 'main.pas' {Form6},
  NativeXml in '..\..\addons\nativexml\NativeXml.pas',
  GFeedBurner in '..\..\source\GFeedBurner.pas',
  uTimeLine in 'uTimeLine.pas' {fTimeLine};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TfTimeLine, fTimeLine);
  Application.Run;
end.
