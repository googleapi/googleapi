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

implementation

{$R GStrings.res}

end.
