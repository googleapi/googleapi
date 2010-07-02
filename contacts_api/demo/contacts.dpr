program contacts;

uses
  Forms,
  main in 'main.pas' {Form3},
  Profile in 'Profile.pas' {ProfileForm},
  GoogleLogin in '..\..\clientlogin\GoogleLogin.pas',
  GHelper in '..\..\gdata_units\GHelper.pas',
  NativeXml in '..\..\Utils\NativeXml.pas',
  GContacts in '..\source\GContacts.pas',
  GDataCommon in '..\..\gdata_units\GDataCommon.pas',
  GData in '..\..\gdata_units\GData.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TProfileForm, ProfileForm);
  Application.Run;
end.
