unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, httpsend,synautil,synacode,SuperObject;

type
  TForm6 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  Form6: TForm6;

implementation

uses msxml;

{$R *.dfm}

procedure SuperMethod(const This, Params: ISuperObject;
  var Result: ISuperObject);
var
  obj: ISuperObject;
begin
  with Form6.Memo1.Lines do
  begin
    BeginUpdate;
    try
      Clear;
      case Params.I['responseStatus'] of
        200:
          for obj in Params['responseData'] do
            Add(obj.Format('%translatedText% - (%detectedSourceLanguage%)'));
        else
          Add(Params.S['responseDetails']);
      end;
    finally
      EndUpdate;
    end;
  end;
end;


procedure TForm6.Button1Click(Sender: TObject);
var obj: ISuperObject;
    req: IXMLHttpRequest;
    s: PSOChar;
begin
  req:=CoXMLHTTP.Create;

req.open('GET',
'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q='+UTF8Encode(Edit1.Text)+'&langpair=|ru',
false, EmptyParam, EmptyParam);
req.send(EmptyParam);
s:=PwideChar(req.responseText);
obj:=TSuperObject.ParseString(s,true);
ShowMessage(IntToStr(obj.I['responseStatus']));
ShowMessage(obj.S['responseData.translatedText']);//
ShowMessage(obj.S['responseData.detectedSourceLanguage']);
//Memo1.Lines.Add(o.AsObject.S['responseData'])
end;


end.
