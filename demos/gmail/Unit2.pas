unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, GMailSMTP;

type
  TForm2 = class(TForm)
    Label7: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label8: TLabel;
    ListBox2: TListBox;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    GMailSMTP1: TGMailSMTP;
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  GMailSMTP1.AddText(Memo1.Text);
  Memo1.Lines.Clear;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  GMailSMTP1.AddHTML(Memo1.Text);
  Memo1.Lines.Clear;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
GMailSMTP1.SendMessage('Test', false);
end;

procedure TForm2.N3Click(Sender: TObject);
begin
if OpenDialog1.Execute then
  begin
    ListBox2.Items.Add(OpenDialog1.FileName);
    GMailSMTP1.AttachFiles.Add(OpenDialog1.FileName)
  end;
end;

procedure TForm2.N4Click(Sender: TObject);
begin
if ListBox2.ItemIndex>0 then
  begin
    GMailSMTP1.AttachFiles.Delete(ListBox2.ItemIndex);
    ListBox2.Items.Delete(ListBox2.ItemIndex);
  end;
end;

end.
