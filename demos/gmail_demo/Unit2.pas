unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, GMailSMTP, synachar,TypInfo;

type
  TForm2 = class(TForm)
    Label7: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label8: TLabel;
    ListBox2: TListBox;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    Edit2: TEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    Edit3: TEdit;
    btn1: TButton;
    btn2: TButton;
    lbl5: TLabel;
    Edit4: TEdit;
    lbl6: TLabel;
    Edit5: TEdit;
    chk1: TCheckBox;
    Label2: TLabel;
    ComboBox1: TComboBox;
    GMailSMTP1: TGMailSMTP;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.btn1Click(Sender: TObject);
begin
if OpenDialog1.Execute then
  begin
    ListBox2.Items.Add(OpenDialog1.FileName);
    GMailSMTP1.AttachFiles.Add(OpenDialog1.FileName);
    ShowMessage('Новый файл добавлен в сообщение');
  end;
end;

procedure TForm2.btn2Click(Sender: TObject);
begin
if ListBox2.ItemIndex>0 then
  begin
    GMailSMTP1.AttachFiles.Delete(ListBox2.ItemIndex);
    ListBox2.Items.Delete(ListBox2.ItemIndex);
    ShowMessage('Файл удален из сообщения');
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  GMailSMTP1.AddText(Memo1.Text);
  Memo1.Lines.Clear;
  ShowMessage('Фрагмент сообщения успешно добавлен');
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  GMailSMTP1.AddHTML(Memo1.Text);
  Memo1.Lines.Clear;
  ShowMessage('Фрагмент сообщения успешно добавлен');
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
GMailSMTP1.Login:=Edit4.Text;
GMailSMTP1.Password:=Edit5.Text;
GMailSMTP1.FromEmail:=Edit1.Text;
GMailSMTP1.Recipients.Clear;
GMailSMTP1.Recipients.Add(Edit2.Text);
if GMailSMTP1.SendMessage(Edit3.Text, chk1.Checked) then
  ShowMessage('Письмо отправлено')
else
  ShowMessage('Отправка не удалась')
end;

procedure TForm2.ComboBox1Change(Sender: TObject);
begin
  GMailSMTP1.HeaderCodePage:=TMimeChar(GetEnumValue(TypeInfo(TMimeChar),ComboBox1.Items[ComboBox1.ItemIndex]));
end;

procedure TForm2.FormCreate(Sender: TObject);
var Charset: TMimeChar;
    All:set of TMimeChar;

begin
ComboBox1.Items.Clear;
  for Charset:=ISO_8859_1 to CP1125 do
    ComboBox1.Items.Add(GetEnumName(TypeInfo(TMimeChar),ord(Charset)));
ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(GetEnumName(TypeInfo(TMimeChar),ord(GMailSMTP1.HeaderCodePage)))
end;

end.

