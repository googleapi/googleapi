unit newevent;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,GCalendar,GDataCommon;

type
  TForm2 = class(TForm)
    GroupBox1: TGroupBox;
    Label15: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label21: TLabel;
    Label16: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit4: TEdit;
    Edit5: TEdit;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    Button3: TButton;
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses main;

{$R *.dfm}

procedure TForm2.Button3Click(Sender: TObject);
var Event: TCelenrarEvent;
    Rem: TgdReminder;
begin
  Event:=TCelenrarEvent.Create;
  Event.title:=Edit4.Text;
  Event.Description:=Edit5.Text;
  Event.When.startTime:=Trunc(DateTimePicker1.Date);
  Event.When.endTime:=Trunc(DateTimePicker4.Date);
  Event.Reminders.Clear;
  if CheckBox1.Checked then
   begin
     Rem:=TgdReminder.Create(nil);
     Rem.Period:=tpMinutes;
     Rem.PeriodValue:=10;
     Rem.Method:=tmSMS;
     Event.Reminders.Add(Rem);
   end;
  if CheckBox2.Checked then
   begin
     Rem:=TgdReminder.Create(nil);
     Rem.Period:=tpMinutes;
     Rem.PeriodValue:=10;
     Rem.Method:=tmEmail;
     Event.Reminders.Add(Rem);
   end;
  if CheckBox3.Checked then
   begin
     Rem:=TgdReminder.Create(nil);
     Rem.Period:=tpMinutes;
     Rem.PeriodValue:=10;
     Rem.Method:=tmAlert;
     Event.Reminders.Add(Rem);
   end;
  Form1.MyCelendars.AllCelendars[Form1.ComboBox1.ItemIndex].AddSingleEvent(Event);
  ModalResult:=mrOk;
  Form1.ComboBox1Change(self);
  Hide;
end;

end.
