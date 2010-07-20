unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GoogleLogin, StdCtrls, GHelper,GContacts,Generics.Collections,NativeXml,
  ExtCtrls, ComCtrls, ToolWin, Menus, ImgList,JPEG, ExtDlgs,TypInfo;

type
  TForm3 = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Label5: TLabel;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    ImageList1: TImageList;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    ComboBox2: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    ComboBox3: TComboBox;
    Label9: TLabel;
    Label10: TLabel;
    ListBox2: TListBox;
    Label11: TLabel;
    ComboBox4: TComboBox;
    Label12: TLabel;
    ComboBox5: TComboBox;
    Label13: TLabel;
    Label14: TLabel;
    ComboBox6: TComboBox;
    Label15: TLabel;
    ComboBox7: TComboBox;
    Image1: TImage;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    ToolButton3: TToolButton;
    OpenPictureDialog1: TOpenPictureDialog;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Label16: TLabel;
    Label20: TLabel;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    procedure ComboBox1Change(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox5Change(Sender: TObject);
    procedure ComboBox6Change(Sender: TObject);
    procedure ComboBox7Change(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
  private
    //TOnRetriveXML
    procedure RetriveXML (const FromURL:string);
    //TOnBeginParse
    procedure BeginParse (const What: TParseElement; Total, Number: integer);
    //OnEndParse
    procedure EndParse(const What: TParseElement; Element: TObject);
    //OnReadData
     procedure ReadData(const TotalBytes:int64; ReadBytes: int64);
  public
     procedure RetriveMyContacts;
  end;

var
  Form3: TForm3;
  Contact: TGoogleContact;
  Loginer: TGoogleLogin;
  GmailContact: string;
  List:TList<TContact>;
  Selected: TContact;

implementation

uses Profile, uLog, uQueryForm, uUpdate, NewContact;

{$R *.dfm}

procedure TForm3.BeginParse(const What: TParseElement; Total, Number: integer);
begin
  case What of
    T_Contact: fLog.Memo1.Lines.Add('Парсим контакт №'+IntToStr(Number)+' всего контактов '+IntToStr(Total));
    T_Group: fLog.Memo1.Lines.Add('Парсим группу №'+IntToStr(Number)+' всего групп '+IntToStr(Total));
  end;
end;

procedure TForm3.ComboBox1Change(Sender: TObject);
var i:integer;
begin
  if ComboBox1.ItemIndex>0 then
    begin
      ListBox1.Items.Clear;
      List:=TList<TContact>.Create;
      List:=Contact.ContactsByGroup[ComboBox1.Items[ComboBox1.ItemIndex]];
      for i:=0 to List.Count - 1 do
        begin
          if List[i].TagTitle.Value='' then
            if List[i].PrimaryEmail<>'' then
              ListBox1.Items.Add(List[i].PrimaryEmail)
            else
              ListBox1.Items.Add('NoName Contact')
          else
            ListBox1.Items.Add(List[i].ContactName)
        end;
    end
 else
   begin
     ListBox1.Items.Clear;
     for i:=0 to Contact.Contacts.Count - 1 do
        begin
          if Contact.Contacts[i].TagTitle.Value='' then
            if Contact.Contacts[i].PrimaryEmail<>'' then
              ListBox1.Items.Add(Contact.Contacts[i].PrimaryEmail)
            else
              ListBox1.Items.Add('NoName Contact')
          else
              ListBox1.Items.Add(Contact.Contacts[i].TagTitle.Value)
        end;
   end;

end;

procedure TForm3.ComboBox2Change(Sender: TObject);
begin
  Label7.Caption:=Selected.Emails[ComboBox2.ItemIndex].RelToString;
end;

procedure TForm3.ComboBox3Change(Sender: TObject);
begin
  Label9.Caption:=Selected.Phones[ComboBox3.ItemIndex].RelToString
end;

procedure TForm3.ComboBox4Change(Sender: TObject);
begin
  label17.Caption:=Selected.WebSites[ComboBox4.ItemIndex].RelToString;
end;

procedure TForm3.ComboBox5Change(Sender: TObject);
begin
  label13.Caption:=Selected.Relations[ComboBox5.ItemIndex].RelToString;
end;

procedure TForm3.ComboBox6Change(Sender: TObject);
begin
  Label18.Caption:=Selected.IMs[ComboBox6.ItemIndex].ImProtocolToString;
end;

procedure TForm3.ComboBox7Change(Sender: TObject);
begin
  label19.Caption:=Selected.UserFields[ComboBox7.ItemIndex].Value
end;

procedure TForm3.EndParse(const What: TParseElement; Element: TObject);
begin
  case What of
    T_Group: fLog.Memo1.Lines.Add('Получена группа '+ (Element as TContactGroup).Title);
    T_Contact:fLog.Memo1.Lines.Add('Получен контакт '+ (Element as TContact).ContactName);
  end;
end;

procedure TForm3.ListBox1Click(Sender: TObject);
var i:integer;
begin
try
  Selected:=TContact.Create();
  if ComboBox1.ItemIndex=0 then
    Selected:=Contact.Contacts[ListBox1.ItemIndex]
  else
    Selected:=Contact.ContactByGroupIndex[ComboBox1.Items[ComboBox1.ItemIndex],ListBox1.ItemIndex];


  Image1.Picture.Assign(Contact.RetriveContactPhoto(Selected,
                                      ExtractFilePath(Application.ExeName)+'noimage.jpg'));
  label2.Caption:=Selected.TagName.FullNameString;
  label4.Caption:=Selected.TagOrganization.OrgName.Value+' '
                      +Selected.TagOrganization.OrgTitle.Value;
  Label20.Caption:=Selected.TagBirthDay.ServerDate;

  ComboBox2.Items.Clear;
  for I := 0 to Selected.Emails.Count-1 do
    ComboBox2.Items.Add(Selected.Emails[i].Address);
  if ComboBox2.Items.Count>0 then
    begin
      ComboBox2.ItemIndex:=0;
      ComboBox2Change(self);
    end
  else
    Label7.Caption:='---';

  ComboBox3.Items.Clear;
  for I := 0 to Selected.Phones.Count - 1 do
    ComboBox3.Items.Add(Selected.Phones[i].Text);
  if ComboBox3.Items.Count>0 then
    begin
      ComboBox3.ItemIndex:=0;
      ComboBox3Change(self);
    end
  else
     Label9.Caption:='---';

  ComboBox4.Items.Clear;
    for I := 0 to Selected.WebSites.Count - 1 do
    ComboBox4.Items.Add(Selected.WebSites[i].Href);
  if ComboBox4.Items.Count>0 then
    begin
      ComboBox4.ItemIndex:=0;
      ComboBox4Change(self);
    end
  else
    label17.Caption:='---';

  ComboBox5.Items.Clear;
  for I := 0 to Selected.Relations.Count - 1 do
    ComboBox5.Items.Add(Selected.Relations[i].Value);

  if ComboBox5.Items.Count>0 then
    begin
      ComboBox5.ItemIndex:=0;
      ComboBox5Change(self);
    end
  else
    label13.Caption:='---';

  ComboBox6.Items.Clear;
  for I := 0 to Selected.IMs.Count - 1 do
    ComboBox6.Items.Add(Selected.IMs[i].Address);
  if ComboBox6.Items.Count>0 then
    begin
      ComboBox6.ItemIndex:=0;
      ComboBox6Change(self);
    end
  else
    Label18.Caption:='---';

  ComboBox7.Items.Clear;
  for I := 0 to Selected.UserFields.Count - 1 do
    ComboBox7.Items.Add(Selected.UserFields[i].Key);
  if ComboBox7.Items.Count>0 then
    begin
     ComboBox7.ItemIndex:=0;
     ComboBox7Change(self);
    end
  else
    label19.Caption:='---';

  ListBox2.Items.Clear;
  for I := 0 to Selected.PostalAddreses.Count - 1 do
    ListBox2.Items.Add(Selected.PostalAddreses[i].FormattedAddress.Value)

except

end;
end;

procedure TForm3.ReadData(const TotalBytes:int64; ReadBytes: int64);
begin
  fLog.Memo1.Lines.Add('Прочитано '+IntToStr(ReadBytes)+' из '+IntToStr(TotalBytes))
end;

procedure TForm3.RetriveMyContacts;
var  iCounterPerSec: TLargeInteger;
     T1, T2: TLargeInteger; //значение счётчика ДО и ПОСЛЕ операции
begin
//  if Loginer.LastResult=lrOk then
//    begin
      //затачиваем события
      Contact.OnRetriveXML:=RetriveXML;
      Contact.OnBeginParse:=BeginParse;
      Contact.OnEndParse:=EndParse;
      Contact.OnReadData:=ReadData;
      fLog.Show;
      //засекаем время
      QueryPerformanceFrequency(iCounterPerSec);
      QueryPerformanceCounter(T1);
      StatusBar1.Panels[1].Text:=IntToStr(Contact.RetriveGroups);
      StatusBar1.Panels[3].Text:=IntToStr(Contact.RetriveContacts);
      //показываем затраченное на загрузку время
      QueryPerformanceCounter(T2);
      StatusBar1.Panels[5].Text:=(FormatFloat('0.0000', (T2 - T1) / iCounterPerSec) + ' сек.');


      ListBox1.Items.Clear;
      ListBox1.Items.Assign(Contact.ContactsNames);

      ComboBox1.Items.Assign(Contact.GroupsNames);
      ComboBox1.Items.Insert(0,'Все');
      ComboBox1.ItemIndex:=0;


      Form3.ToolButton3.Enabled:=true;
      Form3.ToolButton4.Enabled:=true;
      Form3.ToolButton5.Enabled:=true;
      Form3.ToolButton6.Enabled:=true;
      Form3.ToolButton7.Enabled:=true;
      Form3.ToolButton8.Enabled:=true;
      Form3.ToolButton9.Enabled:=true;
      Form3.ToolButton10.Enabled:=true;
      Form3.ToolButton11.Enabled:=true;
      Form3.ToolButton12.Enabled:=true;
 //   end;
end;

procedure TForm3.RetriveXML(const FromURL: string);
begin
  fLog.Memo1.Lines.Add('Получаем данные с URL '+FromURL)
end;

procedure TForm3.ToolButton10Click(Sender: TObject);
var S: string;
begin
 if InputQuery('Введите название группы','Название группы',S) then
   if Contact.AddContactGroup(S,Contact.Gmail) then
     begin
       ComboBox1.Clear;
       ComboBox1.Items.Assign(Contact.GroupsNames);
       ComboBox1.Items.Insert(0,'Все');
     end;
end;

procedure TForm3.ToolButton11Click(Sender: TObject);
var S:string;
begin
 if ComboBox1.ItemIndex>0 then
  begin
    if InputQuery('Новое название группы','Новое название',S) then
      begin
        Contact.Groups[ComboBox1.ItemIndex-1].Title:=S;
        Contact.UpdateContactGroup(ComboBox1.ItemIndex-1);
        ComboBox1.Items.Assign(Contact.GroupsNames);
        ComboBox1.Items.Insert(0,'Все');
      end;
  end;
end;

procedure TForm3.ToolButton12Click(Sender: TObject);
begin
 if ComboBox1.ItemIndex>0 then
  begin
    if Contact.DeleteContactGroup(Contact.Groups[ComboBox1.ItemIndex-1])then
      begin
        ComboBox1.Items.Assign(Contact.GroupsNames);
        ComboBox1.Items.Insert(0,'Все');
      end
    else
      ShowMessage('Группа НЕ удалена');
  end;
end;

procedure TForm3.ToolButton1Click(Sender: TObject);
begin
  ProfileForm.Show;
end;

procedure TForm3.ToolButton2Click(Sender: TObject);
begin
  fQuery.ShowModal;
end;

procedure TForm3.ToolButton3Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
     Contact.UpdatePhoto(ListBox1.ItemIndex,OpenPictureDialog1.FileName);
end;

procedure TForm3.ToolButton4Click(Sender: TObject);
begin
  Contact.DeletePhoto(ListBox1.ItemIndex);
end;

procedure TForm3.ToolButton5Click(Sender: TObject);
begin
 if Contact.DeleteContact(ListBox1.ItemIndex) then
   begin
      ShowMessage('Контакт удален. Контактов осталось '+IntToStr(Contact.Contacts.Count));
      ListBox1.Items.Delete(ListBox1.ItemIndex);
   end
 else
   ShowMessage('Удаление контакта не удалось');
end;

procedure TForm3.ToolButton6Click(Sender: TObject);
begin
fNewContact.Show
end;

procedure TForm3.ToolButton7Click(Sender: TObject);
begin
  fUpdateContact.Edit1.Text:=Selected.TagName.FamilyName.Value;
  fUpdateContact.Edit2.Text:=Selected.TagName.GivenName.Value;
  fUpdateContact.Edit3.Text:=Selected.TagName.AdditionalName.Value;
  fUpdateContact.Edit4.Text:=Selected.PrimaryEmail;
  fUpdateContact.DateTimePicker1.Date:=Selected.TagBirthDay.Date;
  fUpdateContact.ShowModal;
end;

procedure TForm3.ToolButton8Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    Contact.SaveContactsToFile(SaveDialog1.FileName);
end;

procedure TForm3.ToolButton9Click(Sender: TObject);
var i:integer;
begin
  if OpenDialog1.Execute then
    if Length(OpenDialog1.FileName)>0 then
      begin
        Contact:=TGoogleContact.Create(self);
        Contact.LoadContactsFromFile(OpenDialog1.FileName);
        for I := 0 to Contact.Contacts.Count - 1 do
           ListBox1.Items.Add(Contact.Contacts[i].ContactName);
        ComboBox1.Items.Add('Все');
        ComboBox1.ItemIndex:=0;
      end;
end;

end.
