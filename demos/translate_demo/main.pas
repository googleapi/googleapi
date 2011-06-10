unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,GTranslate,typinfo, ExtCtrls,  Clipbrd;

type
  TForm6 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    ComboBox1: TComboBox;
    //Translator1: TTranslator;
    Label3: TLabel;
    Label4: TLabel;
    ComboBox2: TComboBox;
    Label5: TLabel;
    Edit2: TEdit;
    Translator1: TTranslator;
    procedure Button1Click(Sender: TObject);
    procedure Translator1Translate(const SourceStr, TranslateStr: string;
      LangDetected: TLanguageEnum);
    procedure Translator1TranslateError(const Code: Integer; Status: string);
    procedure FormShow(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
  private
  public

  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

procedure TForm6.Button1Click(Sender: TObject);
begin
  Translator1.Key:=Edit2.Text;
  Translator1.Translate(Edit1.Text)
end;


procedure TForm6.ComboBox1Change(Sender: TObject);
begin
  Translator1.SourceLang:=Translator1.GetLangByName(ComboBox1.Items[ComboBox1.ItemIndex]);
end;

procedure TForm6.ComboBox2Change(Sender: TObject);
begin
  Translator1.DestLang:=Translator1.GetLangByName(ComboBox2.Items[ComboBox2.ItemIndex]);
end;

procedure TForm6.FormShow(Sender: TObject);
begin
  ComboBox1.Items.Assign(Translator1.GetLanguagesNames);
  ComboBox2.Items.Assign(Translator1.GetLanguagesNames);
end;

procedure TForm6.Translator1Translate(const SourceStr, TranslateStr: string;
  LangDetected: TLanguageEnum);
begin
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Исходный текст '+SourceStr);
  Memo1.Lines.Add('Перевод '+TranslateStr);
end;

procedure TForm6.Translator1TranslateError(const Code: Integer; Status: string);
begin
  Memo1.Lines.Add('Ошибка '+IntToStr(Code)+' '+Status)
end;

end.
