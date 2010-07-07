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
implementation

{$R GStrings.res}

end.
