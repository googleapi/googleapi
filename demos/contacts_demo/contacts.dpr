program contacts;

uses
  Forms,
  main in 'main.pas' {Form3},
  Profile in 'Profile.pas' {ProfileForm},
  GoogleLogin in '..\..\source\GoogleLogin.pas',
  GContacts in '..\..\source\GContacts.pas',
  GHelper in '..\..\source\GHelper.pas',
  NativeXml in '..\..\addons\nativexml\NativeXml.pas',
  GDataCommon in '..\..\source\GDataCommon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TProfileForm, ProfileForm);
  Application.Run;
end.
