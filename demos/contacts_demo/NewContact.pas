unit NewContact;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, GContacts, ComCtrls, GDataCommon,main;

type
  TfNewContact = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Button1: TButton;
    DateTimePicker1: TDateTimePicker;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fNewContact: TfNewContact;

implementation

{$R *.dfm}

procedure TfNewContact.Button1Click(Sender: TObject);
var NewContact: TContact;
    Phone: TgdPhoneNumber;
begin
  NewContact:=TContact.Create();
  NewContact.TagName.FamilyName.Value:=Edit1.Text;
  NewContact.TagName.GivenName.Value:=Edit2.Text;
  NewContact.TagName.AdditionalName.Value:=Edit3.Text;
  NewContact.TagName.FullName.Value:=Edit1.Text+' '+Edit2.Text+' '+Edit3.Text;
  NewContact.PrimaryEmail:=Edit4.Text;
  NewContact.TagBirthDay.Date:=DateTimePicker1.Date;
  Phone:=TgdPhoneNumber.Create();
  Phone.Rel:=tp_Home;
  Phone.Text:=Edit5.Text;
  NewContact.Phones.Add(Phone);
  Contact.AddContact(NewContact);
  Hide;

end;

end.
