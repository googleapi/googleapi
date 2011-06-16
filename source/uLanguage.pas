unit uLanguage;

interface

const
  GStringsMaxId = 58000;
  //Dialogs
  c_ErrPrepareNode =  GStringsMaxId - 1;
  c_ErrCompNodes =    GStringsMaxId - 2;
  c_ErrWriteNode =    GStringsMaxId - 3;
  c_ErrReadNode =     GStringsMaxId - 5;
  c_ErrMissValue =    GStringsMaxId - 6;
  c_ErrMissAgrument = GStringsMaxId - 7;
  c_UnUsedTag =       GStringsMaxId - 8;
  c_DuplicateLink =   GStringsMaxId - 9;
  c_WrongAttr =       GStringsMaxId - 10;
  c_RightAttrValues = GStringsMaxId - 11;
  c_ErrCGroupCreate = GStringsMaxId - 12;
  c_ErrNullAuth =     GStringsMaxId - 13;
  c_ErrFileName =     GStringsMaxId - 14;
  c_ErrFileNull =     GStringsMaxId - 15;
  c_ErrSysGroup =     GStringsMaxId - 106;
  c_ErrGroupLink =    GStringsMaxId - 107;
{Variables}
//gContact:calendarLink rel values
  c_Work =            GStringsMaxId - 16;
  c_Home =            GStringsMaxId - 17;
  c_FreeBusy =        GStringsMaxId - 18;
//gContact:externalId  rel values
  c_AccId =           GStringsMaxId - 19;
  c_AccCostumer =     GStringsMaxId - 20;
  c_AccNetwork =      GStringsMaxId - 21;
  c_AccOrg =          GStringsMaxId - 22;
//gContact:event rel values
  c_EvntAnniv =       GStringsMaxId - 23;
  c_EvntOther =       GStringsMaxId - 24;
//gContact:gender values
  c_Male =            GStringsMaxId - 25;
  c_Female =          GStringsMaxId - 26;
//gContact:Jot rel values
  c_JotHome =         GStringsMaxId - 27;
  c_JotWork =         GStringsMaxId - 28;
  c_JotOther =        GStringsMaxId - 29;
  c_JotKeywords =     GStringsMaxId - 30;
  c_JotUser =         GStringsMaxId - 31;
//gContact:Priority rel values
  c_PriorityLow =     GStringsMaxId - 32;
  c_PriorityNormal =  GStringsMaxId - 33;
  c_PriorityHigh =    GStringsMaxId - 34;
//gContact:Relation rel values
  c_RelationAssistant =  GStringsMaxId - 35;
  c_RelationBrother =    GStringsMaxId - 36;
  c_RelationChild =      GStringsMaxId - 37;
  c_RelationDomestPart = GStringsMaxId - 38;
  c_RelationFather =     GStringsMaxId - 39;
  c_RelationFriend =     GStringsMaxId - 40;
  c_RelationManager =    GStringsMaxId - 41;
  c_RelationMother =     GStringsMaxId - 42;
  c_RelationParent =     GStringsMaxId - 43;
  c_RelationPartner =    GStringsMaxId - 44;
  c_RelationReffered =   GStringsMaxId - 45;
  c_RelationRelative =   GStringsMaxId - 46;
  c_RelationSister =     GStringsMaxId - 47;
  c_RelationSpouse =     GStringsMaxId - 48;
//gContact:sensitivity rel values
  c_SensitivConf =       GStringsMaxId - 49;
  c_SensitivNormal =     GStringsMaxId - 50;
  c_SensitivPersonal =   GStringsMaxId - 51;
  c_SensitivPrivate =    GStringsMaxId - 52;
//gContact: SystemGroup rel values
  c_SysGroupContacts =   GStringsMaxId - 53;
  c_SysGroupFriends=     GStringsMaxId - 54;
  c_SysGroupFamily=      GStringsMaxId - 55;
  c_SysGroupCoworkers =  GStringsMaxId - 56;
//gContact: WebSite rel values
  c_WebsiteHomePage =    GStringsMaxId - 57;
  c_WebsiteBlog =        GStringsMaxId - 58;
  c_WebsiteProfile =     GStringsMaxId - 59;
  c_WebsiteHome =        GStringsMaxId - 60;
  c_WebsiteWork =        GStringsMaxId - 61;
  c_WebsiteOther =       GStringsMaxId - 62;
  c_WebsiteFtp =         GStringsMaxId - 63;
//gd:eventStatus values
  c_EventCancel    =     GStringsMaxId - 64;
  c_EventConfirm   =     GStringsMaxId - 65;
  c_EventTentative =     GStringsMaxId - 66;
//gd:visibility values
  c_EventConfident =     GStringsMaxId - 67;
  c_EventDefault =       GStringsMaxId - 68;
  c_EventPrivate =       GStringsMaxId - 69;
  c_EventPublic =        GStringsMaxId - 70;
//gd:transparency values
  c_EventOpaque =        GStringsMaxId - 71;
  c_EventTransp =        GStringsMaxId - 72;
//gd:attendeeType Values
  c_EventOptional =      GStringsMaxId - 73;
  c_EventRequired =      GStringsMaxId - 74;
//gd:attendeeStatus Values
  c_EventAccepted =      GStringsMaxId - 75;
  c_EventDeclined =      GStringsMaxId - 76;
  c_EventInvited =       GStringsMaxId - 77;
  c_EventTentativ =      GStringsMaxId - 78;
//gd:email rel values
  c_EmailHome =          GStringsMaxId - 79;
  c_EmailOther =         GStringsMaxId - 80;
  c_EmailWork =          GStringsMaxId - 81;
//gd:im rel values
  c_ImHome =             GStringsMaxId - 82;
  c_ImNetMeeting =       GStringsMaxId - 83;
  c_ImOther =            GStringsMaxId - 84;
  c_ImWork =             GStringsMaxId - 85;
//gd:phoneNumber rel values
  c_PhoneAssistant =     GStringsMaxId - 86;
  c_PhoneCallback =      GStringsMaxId - 87;
  c_PhoneCar =           GStringsMaxId - 88;
  c_PhoneCompanymain =   GStringsMaxId - 89;
  c_PhoneFax =           GStringsMaxId - 90;
  c_PhoneHome =          GStringsMaxId - 91;
  c_PhoneHomefax =       GStringsMaxId - 92;
  c_PhoneIsdn =          GStringsMaxId - 93;
  c_PhoneMain =          GStringsMaxId - 94;
  c_PhoneMobile =        GStringsMaxId - 95;
  c_PhoneOther =         GStringsMaxId - 96;
  c_PhoneOtherfax =      GStringsMaxId - 97;
  c_PhonePager =         GStringsMaxId - 98;
  c_PhoneRadio =         GStringsMaxId - 99;
  c_PhoneTelex =         GStringsMaxId - 100;
  c_PhoneTtytdd =        GStringsMaxId - 101;
  c_PhoneWork =          GStringsMaxId - 102;
  c_PhoneWorkfax =       GStringsMaxId - 103;
  c_PhoneWorkmobile =    GStringsMaxId - 104;
  c_PhoneWorkpager =     GStringsMaxId - 105;

implementation

{$R GStrings.res}

end.