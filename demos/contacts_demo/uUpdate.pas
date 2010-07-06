unit uUpdate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,main, ComCtrls;

type
  TfUpdateContact = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Edit4: TEdit;
    Button1: TButton;
    Label5: TLabel;
    DateTimePicker1: TDateTimePicker;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fUpdateContact: TfUpdateContact;

implementation

{$R *.dfm}

procedure TfUpdateContact.Button1Click(Sender: TObject);
begin
  Selected.TagName.FamilyName.Value:=Edit1.Text;
  Selected.TagName.GivenName.Value:=Edit2.Text;
  Selected.TagName.AdditionalName.Value:=Edit3.Text;
  Selected.TagName.FullName.Value:=Edit1.Text+' '+Edit2.Text+' '+Edit3.Text;
  Selected.PrimaryEmail:=Edit4.Text;
  Selected.TagBirthDay.Date:=DateTimePicker1.DateTime;
  Selected.TagBirthDay.ShotrFormat:=true;
  Contact.UpdateContact(Selected);
  ModalResult:=mrOk;
  Form3.ListBox1.Items[Form3.ListBox1.ItemIndex]:=Selected.ContactName;

  Hide;
end;

end.
