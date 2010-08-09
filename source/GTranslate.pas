{ ==============================================================================|
|Проект: Google API в Delphi                                                   |
|==============================================================================|
|unit: GTranslate                                                              |
|==============================================================================|
|Описание: Модуль для работы с переводчиком Google (AJAX Language API).        |
|==============================================================================|
|Зависимости:                                                                  |
|1. Для парсинга JSON-документов используется библиотека SuperObject           |
|==============================================================================|
| Автор: Vlad. (vlad383@gmail.com)                                             |
| Дата: 09.08.2010                                                             |
| Версия: см. ниже                                                             |
| Copyright (c) 2009-2010 WebDelphi.ru                                         |
|==============================================================================|
| ЛИЦЕНЗИОННОЕ СОГЛАШЕНИЕ                                                      |
|==============================================================================|
| ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ ЛЮБОГО ВИДА   |
| ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ  |
| ГАРАНТИЯМИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ  |
| И НЕНАРУШЕНИЯ ПРАВ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ    |
| ОТВЕТСТВЕННОСТИ ПО ИСКАМ О ВОЗМЕЩЕНИИ УЩЕРБА, УБЫТКОВ ИЛИ ДРУГИХ ТРЕБОВАНИЙ  |
| ПО ДЕЙСТВУЮЩИМ КОНТРАКТАМ, ДЕЛИКТАМ ИЛИ ИНОМУ, ВОЗНИКШИМ ИЗ, ИМЕЮЩИМ         |
| ПРИЧИНОЙ ИЛИ СВЯЗАННЫМ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ ИЛИ ИСПОЛЬЗОВАНИЕМ         |
| ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫМИ ДЕЙСТВИЯМИ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.    |
|                                                                              |
| This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF        |
| ANY KIND, either express or implied.                                         |
|==============================================================================|
| ОБНОВЛЕНИЯ КОМПОНЕНТА                                                        |
|==============================================================================|
| Последние обновления модуля GFeedBurner можно найти в репозитории по адресу: |
| http://github.com/googleapi                                                  |
|==============================================================================|
| История версий                                                               |
|==============================================================================|
|                                                                              |
|==============================================================================}
unit GTranslate;

interface

uses windows, msxml, superobject, classes, variants, sysutils, typinfo;

resourcestring
  rsLangUnknown = 'Неизвестный язык';
  rsLangAuto = 'Автоопределение';
  rsLang_en = 'английский';
  rsLang_ru = 'русский';
  rsLang_it = 'итальянский';
  rsLang_az = 'азербайджанский';
  rsLang_sq = 'албанский';
  rsLang_ar = 'арабский';
  rsLang_hy = 'армянский';
  rsLang_af = 'африкаанс';
  rsLang_eu = 'баскский';
  rsLang_be = 'белорусский';
  rsLang_bg = 'болгарский';
  rsLang_cy = 'валлийский';
  rsLang_hu = 'венгерский';
  rsLang_vi = 'вьетнамский';
  rsLang_gl = 'галисийский';
  rsLang_nl = 'голландский';
  rsLang_el = 'греческий';
  rsLang_ka = 'грузинский';
  rsLang_da = 'датский';
  rsLang_iw = 'иврит';
  rsLang_yi = 'идиш';
  rsLang_id = 'индонезийский';
  rsLang_ga = 'ирландский';
  rsLang_is = 'исландский';
  rsLang_es = 'испанский';
  rsLang_ca = 'каталанский';
  rsLang_zh_CN = 'китайский';
  rsLang_ko = 'корейский';
  rsLang_ht = 'Креольский (Гаити)';
  rsLang_lv = 'латышский';
  rsLang_lt = 'литовский';
  rsLang_mk = 'македонский';
  rsLang_ms = 'малайский';
  rsLang_mt = 'мальтийский';
  rsLang_de = 'немецкий';
  rsLang_no = 'норвежский';
  rsLang_fa = 'персидский';
  rsLang_pl = 'польский';
  rsLang_pt = 'португальский';
  rsLang_ro = 'румынский';
  rsLang_sr = 'сербский';
  rsLang_sk = 'словацкий';
  rsLang_sl = 'словенский';
  rsLang_sw = 'суахили';
  rsLang_tl = 'тагальский';
  rsLang_th = 'тайский';
  rsLang_tr = 'турецкий';
  rsLang_uk = 'украинский';
  rsLang_ur = 'урду';
  rsLang_fi = 'финский';
  rsLang_fr = 'французский';
  rsLang_hi = 'хинди';
  rsLang_hr = 'хорватский';
  rsLang_cs = 'чешский';
  rsLang_sv = 'шведский';
  rsLang_et = 'эстонский';
  rsLang_ja = 'японский';

  rsErrorDestLng = 'Перевод невозможен т.к. не определен язык перевода';
  rsErrorTrnsl = 'Во время перевода произошла ошибка: %s';

type
  TLanguageEnum = (unknown, lng_af, lng_sq, lng_ar, lng_hy, lng_az, lng_eu,
    lng_be, lng_bg, lng_my, lng_ca, lng_zh, lng_zh_CN, lng_zh_TW, lng_hr,
    lng_cs, lng_da, lng_nl, lng_en, lng_et, lng_tl, lng_fi, lng_fr, lng_gl,
    lng_ka, lng_de, lng_el, lng_gu, lng_ht, lng_iw, lng_hi, lng_hu, lng_is,
    lng_id, lng_iu, lng_ga, lng_it, lng_ja, lng_jw, lng_kn, lng_kk, lng_km,
    lng_ko, lng_ku, lng_ky, lng_lo, lng_la, lng_lv, lng_lt, lng_lb, lng_mk,
    lng_ms, lng_ml, lng_mt, lng_mi, lng_mr, lng_mn, lng_ne, lng_no, lng_oc,
    lng_or, lng_ps, lng_fa, lng_pl, lng_pt, lng_pt_PT, lng_pa, lng_qu, lng_ro,
    lng_ru, lng_sa, lng_gd, lng_sr, lng_sd, lng_si, lng_sk, lng_sl, lng_es,
    lng_su, lng_sw, lng_sv, lng_syr, lng_tg, lng_ta, lng_tt, lng_te, lng_th,
    lng_to, lng_tr, lng_uk, lng_ur, lng_uz, lng_ug, lng_vi, lng_cy, lng_yi,
    lng_yo);

  TLanguageRec = record
    Name: string;
    Ident: TLanguageEnum;
  end;

  TSpecials = set of AnsiChar;

const
  Languages: array [0 .. 57] of TLanguageRec =
    ((Name:rsLangAuto; Ident: unknown),
    (Name: rsLang_en; Ident: lng_en), (Name: rsLang_ru; Ident: lng_ru),
    (Name: rsLang_it; Ident: lng_it), (Name: rsLang_az; Ident: lng_az),
    (Name: rsLang_sq; Ident: lng_sq), (Name: rsLang_ar; Ident: lng_ar),
    (Name: rsLang_hy; Ident: lng_hy), (Name: rsLang_af; Ident: lng_af),
    (Name: rsLang_eu; Ident: lng_eu), (Name: rsLang_be; Ident: lng_be),
    (Name: rsLang_bg; Ident: lng_bg), (Name: rsLang_cy; Ident: lng_cy),
    (Name: rsLang_hu; Ident: lng_hu), (Name: rsLang_vi; Ident: lng_vi),
    (Name: rsLang_gl; Ident: lng_gl), (Name: rsLang_nl; Ident: lng_nl),
    (Name: rsLang_el; Ident: lng_el), (Name: rsLang_ka; Ident: lng_ka),
    (Name: rsLang_da; Ident: lng_da), (Name: rsLang_iw; Ident: lng_iw),
    (Name: rsLang_yi; Ident: lng_yi), (Name: rsLang_id; Ident: lng_id),
    (Name: rsLang_ga; Ident: lng_ga), (Name: rsLang_is; Ident: lng_is),
    (Name: rsLang_es; Ident: lng_es), (Name: rsLang_ca; Ident: lng_ca),
    (Name: rsLang_zh_CN; Ident: lng_zh_CN), (Name: rsLang_ko; Ident: lng_ko),
    (Name: rsLang_ht; Ident: lng_ht), (Name: rsLang_lv; Ident: lng_lv),
    (Name: rsLang_lt; Ident: lng_lt), (Name: rsLang_mk; Ident: lng_mk),
    (Name: rsLang_ms; Ident: lng_ms), (Name: rsLang_mt; Ident: lng_mt),
    (Name: rsLang_de; Ident: lng_de), (Name: rsLang_no; Ident: lng_no),
    (Name: rsLang_fa; Ident: lng_fa), (Name: rsLang_pl; Ident: lng_pl),
    (Name: rsLang_pt; Ident: lng_pt), (Name: rsLang_ro; Ident: lng_ro),
    (Name: rsLang_sr; Ident: lng_sr), (Name: rsLang_sk; Ident: lng_sk),
    (Name: rsLang_sl; Ident: lng_sl), (Name: rsLang_sw; Ident: lng_sw),
    (Name: rsLang_tl; Ident: lng_tl), (Name: rsLang_th; Ident: lng_th),
    (Name: rsLang_tr; Ident: lng_tr), (Name: rsLang_uk; Ident: lng_uk),
    (Name: rsLang_ur; Ident: lng_ur), (Name: rsLang_fi; Ident: lng_fi),
    (Name: rsLang_fr; Ident: lng_fr), (Name: rsLang_hi; Ident: lng_hi),
    (Name: rsLang_hr; Ident: lng_hr), (Name: rsLang_cs; Ident: lng_cs),
    (Name: rsLang_sv; Ident: lng_sv), (Name: rsLang_et; Ident: lng_et),
    (Name: rsLang_ja; Ident: lng_ja));

  cTranslateURL = 'http://ajax.googleapis.com/ajax/services/language/translate';
  cDetectURL = 'http://ajax.googleapis.com/ajax/services/language/detect';
  cTranslatedPath = 'responseData.translatedText';
  cDetectedLangPath = 'responseData.detectedSourceLanguage';
  cResponcePath = 'responseStatus';
  cResponceTextPath = 'responseDetails';
  APIVersion = '1.0';
  TranslatorVersion = '0.1';
  URLSpecialChar: TSpecials = [#$00 .. #$20, '_', '<', '>', '"', '%', '{', '}',
    '|', '\', '^', '~', '[', ']', '`', #$7F .. #$FF];

type
  TOnTranslate = procedure(const SourceStr, TranslateStr: string;
    LangDetected: TLanguageEnum) of object;
  TOnTranslateError = procedure(const Code: integer; Status: string) of object;

  TTranslator = class(TComponent)
  private
    FSourceLang: TLanguageEnum;
    FDestLang: TLanguageEnum;
    FOnTranslate: TOnTranslate;
    FOnTranslateError: TOnTranslateError;
    function GetDetectedLanguage(const DetectStr: string): TLanguageEnum;
    function GetRequestURL(SourceStr: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    function Translate(const SourceStr: string): string;
    function GetLanguagesNames: TStringList;
    function GetLangByName(const aName: string): TLanguageEnum;
  published
    property SourceLang: TLanguageEnum read FSourceLang write FSourceLang;
    property DestLang: TLanguageEnum read FDestLang write FDestLang;
    property OnTranslate: TOnTranslate read FOnTranslate write FOnTranslate;
    property OnTranslateError: TOnTranslateError read FOnTranslateError write
      FOnTranslateError;
  end;

procedure Register;
function EncodeURL(const Value: AnsiString): AnsiString; inline;
function EncodeTriplet(const Value: AnsiString; Delimiter: AnsiChar;
  Specials: TSpecials): AnsiString; inline;

implementation

procedure Register;
begin
  RegisterComponents('WebDelphi.ru', [TTranslator]);
end;

function EncodeTriplet(const Value: AnsiString; Delimiter: AnsiChar;
  Specials: TSpecials): AnsiString; inline;
var
  n, l: integer;
  s: AnsiString;
  c: AnsiChar;
begin
  SetLength(Result, Length(Value) * 3);
  l := 1;
  for n := 1 to Length(Value) do
  begin
    c := Value[n];
    if c in Specials then
    begin
      Result[l] := Delimiter;
      Inc(l);
      s := IntToHex(Ord(c), 2);
      Result[l] := s[1];
      Inc(l);
      Result[l] := s[2];
      Inc(l);
    end
    else
    begin
      Result[l] := c;
      Inc(l);
    end;
  end;
  Dec(l);
  SetLength(Result, l);
end;

function EncodeURL(const Value: AnsiString): AnsiString; inline;
begin
  Result := EncodeTriplet(Value, '%', URLSpecialChar);
end;

{ TTranslator }

constructor TTranslator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSourceLang := unknown;
  FDestLang := lng_ru;
end;

function TTranslator.GetDetectedLanguage(const DetectStr: string)
  : TLanguageEnum;
var
  aName: string;
  idx: integer;
begin
  aName := 'lng_' + StringReplace(DetectStr, '-', '_', [rfReplaceAll]);
  idx := GetEnumValue(TypeInfo(TLanguageEnum), aName);
  if idx > -1 then
    Result := TLanguageEnum(idx)
  else
    Result := unknown;
end;

function TTranslator.GetLangByName(const aName: string): TLanguageEnum;
var
  i: integer;
begin
  Result := unknown;
  for i := 0 to High(Languages) - 1 do
  begin
    if AnsiLowerCase(Trim(aName)) = AnsiLowerCase(Trim(Languages[i].Name)) then
    begin
      Result := Languages[i].Ident;
      break
    end;
  end;
end;

function TTranslator.GetLanguagesNames: TStringList;
var
  i: integer;
begin
  Result := TStringList.Create;
  for i := 0 to High(Languages) - 1 do
    Result.Add(Languages[i].Name);
end;

function TTranslator.GetRequestURL(SourceStr: string): string;
var
  source, dest: string;
begin
  source := '';
  if SourceLang <> unknown then
  begin
    source := StringReplace
      (GetEnumName(TypeInfo(TLanguageEnum), Ord(FSourceLang)), '_', '-',
      [rfReplaceAll]);
    Delete(source, 1, 4);
  end;
  dest := StringReplace(GetEnumName(TypeInfo(TLanguageEnum), Ord(FDestLang)),
    '_', '-', [rfReplaceAll]);
  Delete(dest, 1, 4);
  Result := EncodeURL(cTranslateURL + '?v=' + APIVersion + '&q=' + UTF8Encode
      (SourceStr) + '&langpair=' + source + '|' + dest);
end;

function TTranslator.Translate(const SourceStr: string): string;
var
  obj: ISuperObject;
  req: IXMLHttpRequest;
  s: PSOChar;
begin
  if FDestLang = unknown then
    raise Exception.Create(rsErrorDestLng);
  req := {$IFDEF VER210} CoXMLHTTP {$ELSE} CoXMLHTTPRequest {$ENDIF}.Create;
  req.open('GET', GetRequestURL(SourceStr), false, EmptyParam, EmptyParam);
  req.send(EmptyParam);
  s := PwideChar(req.responseText);
  obj := TSuperObject.ParseString(s, true);
  if obj.i[cResponcePath] = 200 then
  begin
    Result := (obj.s[cTranslatedPath]);
    if Assigned(FOnTranslate) then
    begin
      if FSourceLang <> unknown then
        FOnTranslate(SourceStr, Result, FSourceLang)
      else
        FOnTranslate(SourceStr, Result, GetDetectedLanguage
            (obj.s[cDetectedLangPath]))
    end;
  end
  else
  begin
    if Assigned(FOnTranslateError) then
      FOnTranslateError(obj.i[cResponcePath], obj.s[cResponceTextPath]);
  end;
end;

end.
