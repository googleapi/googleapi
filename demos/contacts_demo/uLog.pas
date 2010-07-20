unit uLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfLog = class(TForm)
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fLog: TfLog;

implementation

{$R *.dfm}

procedure TfLog.FormShow(Sender: TObject);
begin
  Memo1.Clear;
end;

end.
