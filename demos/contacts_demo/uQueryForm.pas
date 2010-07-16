unit uQueryForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, main,GContacts;

type
  TfQuery = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    UpDown1: TUpDown;
    Label2: TLabel;
    Edit2: TEdit;
    UpDown2: TUpDown;
    Label4: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fQuery: TfQuery;

implementation

{$R *.dfm}

procedure TfQuery.Button1Click(Sender: TObject);
begin
  Contact.MaximumResults:=StrToIntDef(Edit1.Text,0);
  Contact.StartIndex:=StrToIntDef(Edit2.Text,0);
  if CheckBox2.Checked then
    Contact.UpdatesMin:=DateTimePicker1.DateTime;
  Contact.SortOrder:=TSortOrder(ComboBox1.ItemIndex);
  Contact.ShowDeleted:=CheckBox1.Checked;
  Contact.Contacts.Clear;
  ModalResult:=mrOk;
  Hide;
end;

procedure TfQuery.FormHide(Sender: TObject);
begin

  Form3.RetriveMyContacts;
end;

end.
