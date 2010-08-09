<<<<<<< HEAD
unit Unit2;
=======
unit Unit2;
>>>>>>> remotes/origin/master

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, GMailSMTP, synachar,TypInfo, ComCtrls,blcksock;

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
    GMailSMTP1: TGMailSMTP;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure GMailSMTP1Status(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
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
var i:integer;
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

procedure TForm2.GMailSMTP1Status(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
begin
  Application.ProcessMessages;
  StatusBar1.Panels[0].Text:=GetEnumName(TypeInfo(THookSocketReason),ord(Reason))+
   ' '+Value;
end;

end.
<<<<<<< HEAD

=======
>>>>>>> remotes/origin/master
