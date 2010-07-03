program CelendarAPI;

uses
  Forms,
  main in 'main.pas' {Form1},
  GCalendar in '..\GCalendar.pas',
  GDataCommon in '..\GDataCommon.pas',
  GHelper in '..\GHelper.pas',
  GoogleLogin in '..\GoogleLogin.pas',
  GData in '..\GData.pas',
  newevent in 'newevent.pas' {Form2},
  NativeXml in '..\..\Utils\NativeXml.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
