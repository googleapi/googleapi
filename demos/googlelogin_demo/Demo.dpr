program Demo;

uses
  Forms,
  main in 'main.pas' {Form11},
  uGoogleLogin in '..\..\packages\googleLogin_pack\uGoogleLogin.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm11, Form11);
  Application.Run;
end.
