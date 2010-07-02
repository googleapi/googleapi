unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, GCalendar,GDataCommon,Math, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox1: TComboBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ComboBox2: TComboBox;
    GroupBox1: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label21: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit4: TEdit;
    Label16: TLabel;
    Edit5: TEdit;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    MyCelendars: TGoogleCalendar;
    Event: TCelenrarEvent;
  end;

var
  Form1: TForm1;

implementation

uses newevent;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var i:integer;
begin
MyCelendars:=TGoogleCalendar.Create(Edit1.Text,Edit2.Text);
if MyCelendars.Login then
  begin
    label4.Caption:='Подключен';
    MyCelendars.RetriveCelendars(true); //получаем список календарей на чтение/запись
    label7.Caption:=IntToStr(MyCelendars.AllCelendars.Count);
    ComboBox1.Items.Clear;
    for I := 0 to MyCelendars.AllCelendars.Count - 1 do
       ComboBox1.Items.Add(MyCelendars.AllCelendars[i].title);
  end
else
  label4.Caption:='Нет соединения';
end;

procedure TForm1.Button2Click(Sender: TObject);
var Rem: TgdReminder;
begin
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
  if Event.Update then
    ShowMessage('Мероприятие обновлено')
  else
    ShowMessage('Во время обновления произошла ошибка');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
Event.DeleteThis;
ComboBox1Change(self);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
Form2.ShowModal;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var i,count:integer;
begin
 ComboBox2.Items.Clear;
 count:=MyCelendars.AllCelendars[ComboBox1.ItemIndex].RetrieveEvents;
 for I := 0 to Count - 1 do
    ComboBox2.Items.Add(MyCelendars.AllCelendars[ComboBox1.ItemIndex].Event[i].title);
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
var i:integer;
begin
CheckBox1.Checked:=false;
CheckBox2.Checked:=false;
CheckBox3.Checked:=false;
  Event:=TCelenrarEvent.Create();
  Event:=MyCelendars.AllCelendars[ComboBox1.ItemIndex].Event[ComboBox2.ItemIndex];
  label12.Caption:=DateTimeToStr(Event.PublishedTime);
  label14.Caption:=DateTimeToStr(Event.UpdateTime);
  Edit4.Text:=Event.title;
  Edit5.Text:=Event.Description;
  DateTimePicker1.Date:=Event.When.startTime;
  DateTimePicker4.Date:=Event.When.endTime;
  for i:=0 to Event.Reminders.Count-1 do
    begin
      case Event.Reminders[i].Method of
        tmAlert:CheckBox3.Checked:=true;
        tmEmail:CheckBox2.Checked:=true;
        tmSMS:CheckBox1.Checked:=true;
      end;
    end;
end;

end.
