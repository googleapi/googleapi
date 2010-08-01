unit GConsts;

interface

uses uLanguage, SysUtils, Windows;

const
  CpProtocolVer = '3.0'; //версия протокола для Google Contacts
  CpNodeAlias = 'gContact:';//префикс XML-узлов, относящихся к Contacts
  CpGroupLink='http://www.google.com/m8/feeds/groups/%s/full';//URL на получение сведения о группах
  CpContactsLink='http://www.google.com/m8/feeds/contacts/default/full';//URL на получение сведений о контактах для пользователя по умолчанию
  CpPhotoLink = 'http://schemas.google.com/contacts/2008/rel#photo';
  CpDefaultCName = 'NoName Contact';

  gttNodeAlias ='gtt:';
  gdNodeAlias = 'gd:';//префикс узлов, относящихся к GData API
  sDefoultMimeType = 'application/atom+xml';
  sEventRelSuffix = 'event.';
  sImgRel = 'image/*'; //атрибут rel узла, содержащего изображения
  sAtomAlias = 'atom:'; //префикс узлов для формирования документа в формате Атом
  sXMLHeader = '<?xml version="1.0" encoding="UTF-8" ?>';//заголовок XML документа по умолчанию
  sDefoultEncoding = 'utf-8';//кодировка документов по умолчанию
  sRootNodeName= 'feed';//корневой элемент фида
  sNodeValueAttr = 'value';//аттрибут узлов для хранения какого-либо значения
  sNodePrimaryAttr = 'primary';
  sNodeDeletedAttr = 'deleted';
  sNodeCodeAttr = 'code';
  sNodeKeyAttr = 'key';
  sEntryNodeName = 'entry';//имя узла, который необходимо разобрать
  sNodeRelAttr = 'rel';//аттрибут rel узла
  sNodeLabelAttr ='label';//аттрибут label узла
  sNodeHrefAttr = 'href';//атрибут наличия ссылки в узле.
  sSchemaHref ='http://schemas.google.com/g/2005#';

  {цвета в HEX поддерживаемые Google API}
  sGoogleColors: array [1..21]of string = ('A32929','B1365F','7A367A','5229A3',
                                          '29527A','2952A3','1B887A','28754E',
                                          '0D7813','528800','88880E','AB8B00',
                                          'BE6D00','B1440E','865A5A','705770',
                                          '4E5D6C','5A6986','4A716C','6E6E41',
                                          '8D6F47');

  {часовые пояса}
  sGoogleTimeZones:  array [0..308,0..3]of string =
  (('Pacific/Apia','(GMT-11:00) Апия','-11,00',''),
   ('Pacific/Midway','(GMT-11:00) Мидуэй','-11,00',''),
   ('Pacific/Niue','(GMT-11:00) Ниуэ','-11,00',''),
   ('Pacific/Pago_Pago','(GMT-11:00) Паго-Паго','-11,00',''),
   ('Pacific/Fakaofo','(GMT-10:00) Факаофо','-10,00',''),
   ('Pacific/Honolulu','(GMT-10:00) Гавайское время','-10,00',''),
   ('Pacific/Johnston','(GMT-10:00) атолл Джонстон','-10,00',''),
   ('Pacific/Rarotonga','(GMT-10:00) Раротонга','-10,00',''),
   ('Pacific/Tahiti','(GMT-10:00) Таити','-10,00',''),
   ('Pacific/Marquesas','(GMT-09:30) Маркизские острова','-09,30',''),
   ('America/Anchorage','(GMT-09:00) Время Аляски','-09,00',''),
   ('Pacific/Gambier','(GMT-09:00) Гамбир','-09,00',''),
   ('America/Los_Angeles','(GMT-08:00) Тихоокеанское время','-08,00',''),
   ('America/Tijuana','(GMT-08:00) Тихоокеанское время – Тихуана','-08,00',''),
   ('America/Vancouver','(GMT-08:00) Тихоокеанское время – Ванкувер','-08,00',''),
   ('America/Whitehorse','(GMT-08:00) Тихоокеанское время – Уайтхорс','-08,00',''),
   ('Pacific/Pitcairn','(GMT-08:00) Питкэрн','-08,00',''),
   ('America/Dawson_Creek','(GMT-07:00) Горное время – Доусон Крик','-07,00',''),
   ('America/Denver','(GMT-07:00) Горное время    (America/Denver)','-07,00',''),
   ('America/Edmonton','(GMT-07:00) Горное время – Эдмонтон','-07,00',''),
   ('America/Hermosillo','(GMT-07:00) Горное время – Эрмосильо','-07,00',''),
   ('America/Mazatlan','(GMT-07:00) Горное время – Чиуауа, Мазатлан','-07,00',''),
   ('America/Phoenix','(GMT-07:00) Горное время – Аризона','-07,00',''),
   ('America/Yellowknife','(GMT-07:00) Горное время – Йеллоунайф','-07,00',''),
   ('America/Belize','(GMT-06:00) Белиз','-06,00',''),
   ('America/Chicago','(GMT-06:00) Центральное время','-06,00',''),
   ('America/Costa_Rica','(GMT-06:00) Коста-Рика','-06,00',''),
   ('America/El_Salvador','(GMT-06:00) Сальвадор','-06,00',''),
   ('America/Guatemala','(GMT-06:00) Гватемала','-06,00',''),
   ('America/Managua','(GMT-06:00) Манагуа','-06,00',''),
   ('America/Mexico_City','(GMT-06:00) Центральное время – Мехико','-06,00',''),
   ('America/Regina','(GMT-06:00) Центральное время – Реджайна','-06,00',''),
   ('America/Tegucigalpa','(GMT-06:00) Центральное время    (America/Tegucigalpa)','-06,00',''),
   ('America/Winnipeg','(GMT-06:00) Центральное время – Виннипег','-06,00',''),
   ('Pacific/Easter','(GMT-06:00) остров Пасхи','-06,00',''),
   ('Pacific/Galapagos','(GMT-06:00) Галапагос','-06,00',''),
   ('America/Bogota','(GMT-05:00) Богота','-05,00',''),
   ('America/Cayman','(GMT-05:00) Каймановы острова','-05,00',''),
   ('America/Grand_Turk','(GMT-05:00) Гранд Турк','-05,00',''),
   ('America/Guayaquil','(GMT-05:00) Гуаякиль','-05,00',''),
   ('America/Havana','(GMT-05:00) Гавана','-05,00',''),
   ('America/Iqaluit','(GMT-05:00) Восточное время – Икалуит','-05,00',''),
   ('America/Jamaica','(GMT-05:00) Ямайка','-05,00',''),
   ('America/Lima','(GMT-05:00) Лима','-05,00',''),
   ('America/Montreal','(GMT-05:00) Восточное время – Монреаль','-05,00',''),
   ('America/Nassau','(GMT-05:00) Нассау','-05,00',''),
   ('America/New_York','(GMT-05:00) Восточное время','-05,00',''),
   ('America/Panama','(GMT-05:00) Панама','-05,00',''),
   ('America/Port-au-Prince','(GMT-05:00) Порт-о-Пренс','-05,00',''),
   ('America/Toronto','(GMT-05:00) Восточное время – Торонто','-05,00',''),
   ('America/Caracas','(GMT-04:30) Каракас','-04,30',''),
   ('America/Anguilla','(GMT-04:00) Ангилья','-04,00',''),
   ('America/Antigua','(GMT-04:00) Антигуа','-04,00',''),
   ('America/Aruba','(GMT-04:00) Аруба','-04,00',''),
   ('America/Asuncion','(GMT-04:00) Асунсьон','-04,00',''),
   ('America/Barbados','(GMT-04:00) Барбадос','-04,00',''),
   ('America/Boa_Vista','(GMT-04:00) Боа-Виста','-04,00',''),
   ('America/Campo_Grande','(GMT-04:00) Кампу-Гранди','-04,00',''),
   ('America/Cuiaba','(GMT-04:00) Куяба','-04,00',''),
   ('America/Curacao','(GMT-04:00) Кюрасао','-04,00',''),
   ('America/Dominica','(GMT-04:00) Доминика','-04,00',''),
   ('America/Grenada','(GMT-04:00) Гренада','-04,00',''),
   ('America/Guadeloupe','(GMT-04:00) Гваделупа','-04,00',''),
   ('America/Guyana','(GMT-04:00) Гайана','-04,00',''),
   ('America/Halifax','(GMT-04:00) Атлантическое время – Галифакс','-04,00',''),
   ('America/La_Paz','(GMT-04:00) Ла-Пас','-04,00',''),
   ('America/Manaus','(GMT-04:00) Манаус','-04,00',''),
   ('America/Martinique','(GMT-04:00) Мартиника','-04,00',''),
   ('America/Montserrat','(GMT-04:00) Монсеррат','-04,00',''),
   ('America/Port_of_Spain','(GMT-04:00) Порт-оф-Спейн','-04,00',''),
   ('America/Porto_Velho','(GMT-04:00) Порто-Велью','-04,00',''),
   ('America/Puerto_Rico','(GMT-04:00) Пуэрто-Рико','-04,00',''),
   ('America/Rio_Branco','(GMT-04:00) Риу-Бранку','-04,00',''),
   ('America/Santiago','(GMT-04:00) Сантьяго','-04,00',''),
   ('America/Santo_Domingo','(GMT-04:00) Санто-Доминго','-04,00',''),
   ('America/St_Kitts','(GMT-04:00) Сент-Китс','-04,00',''),
   ('America/St_Lucia','(GMT-04:00) Сент-Люсия','-04,00',''),
   ('America/St_Thomas','(GMT-04:00) Сент-Томас','-04,00',''),
   ('America/St_Vincent','(GMT-04:00) Сент-Винсент','-04,00',''),
   ('America/Thule','(GMT-04:00) Тули','-04,00',''),
   ('America/Tortola','(GMT-04:00) Тортола','-04,00',''),
   ('Antarctica/Palmer','(GMT-04:00) Палмер','-04,00',''),
   ('Atlantic/Bermuda','(GMT-04:00) Бермуды','-04,00',''),
   ('Atlantic/Stanley','(GMT-04:00) Стэнли','-04,00',''),
   ('America/St_Johns','(GMT-03:30) Ньюфаундлендское время – Сент-Джонс','-03,30',''),
   ('America/Araguaina','(GMT-03:00) Арагуайна','-03,00',''),
   ('America/Argentina/Buenos_Aires','(GMT-03:00) Буэнос-Айрес','-03,00',''),
   ('America/Bahia','(GMT-03:00) Сальвадор','-03,00',''),
   ('America/Belem','(GMT-03:00) Белен','-03,00',''),
   ('America/Cayenne','(GMT-03:00) Кайенна','-03,00',''),
   ('America/Fortaleza','(GMT-03:00) Форталеза','-03,00',''),
   ('America/Godthab','(GMT-03:00) Годхоб','-03,00',''),
   ('America/Maceio','(GMT-03:00) Масейо','-03,00',''),
   ('America/Miquelon','(GMT-03:00) Микелон','-03,00',''),
   ('America/Montevideo','(GMT-03:00) Монтевидео','-03,00',''),
   ('America/Paramaribo','(GMT-03:00) Парамарибо','-03,00',''),
   ('America/Recife','(GMT-03:00) Ресифи','-03,00',''),
   ('America/Sao_Paulo','(GMT-03:00) Сан-Пауло','-03,00',''),
   ('Antarctica/Rothera','(GMT-03:00) Ротера','-03,00',''),
   ('America/Noronha','(GMT-02:00) Норонха','-02,00',''),
   ('Atlantic/South_Georgia','(GMT-02:00) Южная Георгия','-02,00',''),
   ('America/Scoresbysund','(GMT-01:00) Скорсби','-01,00',''),
   ('Atlantic/Azores','(GMT-01:00) Азорские острова','-01,00',''),
   ('Atlantic/Cape_Verde','(GMT-01:00) острова Зеленого мыса','-01,00',''),
   ('Africa/Abidjan','(GMT+00:00) Абиджан','+00,00',''),
   ('Africa/Accra','(GMT+00:00) Аккра','+00,00',''),
   ('Africa/Bamako','(GMT+00:00) Бамако    (Africa/Bamako)','+00,00',''),
   ('Africa/Banjul','(GMT+00:00) Банжул','+00,00',''),
   ('Africa/Bissau','(GMT+00:00) Бисау','+00,00',''),
   ('Africa/Casablanca','(GMT+00:00) Касабланка','+00,00',''),
   ('Africa/Conakry','(GMT+00:00) Конакри','+00,00',''),
   ('Africa/Dakar','(GMT+00:00) Дакар','+00,00',''),
   ('Africa/El_Aaiun','(GMT+00:00) Эль-Аюн','+00,00',''),
   ('Africa/Freetown','(GMT+00:00) Фритаун','+00,00',''),
   ('Africa/Lome','(GMT+00:00) Ломе','+00,00',''),
   ('Africa/Monrovia','(GMT+00:00) Монровия','+00,00',''),
   ('Africa/Nouakchott','(GMT+00:00) Нуакшот','+00,00',''),
   ('Africa/Ouagadougou','(GMT+00:00) Уагадугу','+00,00',''),
   ('Africa/Sao_Tome','(GMT+00:00) Сан-Томе','+00,00',''),
   ('America/Danmarkshavn','(GMT+00:00) Данмаркшавн','+00,00',''),
   ('Atlantic/Canary','(GMT+00:00) Канарские острова','+00,00',''),
   ('Atlantic/Faroe','(GMT+00:00) Фарерские острова','+00,00',''),
   ('Atlantic/Reykjavik','(GMT+00:00) Рейкьявик','+00,00',''),
   ('Atlantic/St_Helena','(GMT+00:00) остров Святой Елены','+00,00',''),
   ('Etc/GMT','(GMT+00:00) Время по Гринвичу    (без перехода на летнее время)','+00,00',''),
   ('Europe/Dublin','(GMT+00:00) Дублин','+00,00',''),
   ('Europe/Lisbon','(GMT+00:00) Лиссабон','+00,00',''),
   ('Europe/London','(GMT+00:00) Лондон    (Europe/London)','+00,00',''),
   ('Africa/Algiers','(GMT+01:00) Алжир','+01,00',''),
   ('Africa/Bangui','(GMT+01:00) Банги','+01,00',''),
   ('Africa/Brazzaville','(GMT+01:00) Браззавиль','+01,00',''),
   ('Africa/Ceuta','(GMT+01:00) Сеута','+01,00',''),
   ('Africa/Douala','(GMT+01:00) Дуала','+01,00',''),
   ('Africa/Kinshasa','(GMT+01:00) Киншаса','+01,00',''),
   ('Africa/Lagos','(GMT+01:00) Лагос','+01,00',''),
   ('Africa/Libreville','(GMT+01:00) Либревиль','+01,00',''),
   ('Africa/Luanda','(GMT+01:00) Луанда','+01,00',''),
   ('Africa/Malabo','(GMT+01:00) Малабо','+01,00',''),
   ('Africa/Ndjamena','(GMT+01:00) Нджамена','+01,00',''),
   ('Africa/Niamey','(GMT+01:00) Ниамей','+01,00',''),
   ('Africa/Porto-Novo','(GMT+01:00) Порто-Ново','+01,00',''),
   ('Africa/Tunis','(GMT+01:00) Тунис','+01,00',''),
   ('Africa/Windhoek','(GMT+01:00) Виндхук','+01,00',''),
   ('Europe/Amsterdam','(GMT+01:00) Амстердам','+01,00',''),
   ('Europe/Andorra','(GMT+01:00) Андорра','+01,00',''),
   ('Europe/Belgrade','(GMT+01:00) Центральноевропейское время    (Europe/Belgrade)','+01,00',''),
   ('Europe/Berlin','(GMT+01:00) Берлин','+01,00',''),
   ('Europe/Brussels','(GMT+01:00) Брюссель','+01,00',''),
   ('Europe/Budapest','(GMT+01:00) Будапешт','+01,00',''),
   ('Europe/Copenhagen','(GMT+01:00) Копенгаген','+01,00',''),
   ('Europe/Gibraltar','(GMT+01:00) Гибралтар','+01,00',''),
   ('Europe/Luxembourg','(GMT+01:00) Люксембург','+01,00',''),
   ('Europe/Madrid','(GMT+01:00) Мадрид','+01,00',''),
   ('Europe/Malta','(GMT+01:00) Мальта','+01,00',''),
   ('Europe/Monaco','(GMT+01:00) Монако','+01,00',''),
   ('Europe/Oslo','(GMT+01:00) Осло    (Europe/Oslo)','+01,00',''),
   ('Europe/Paris','(GMT+01:00) Париж','+01,00',''),
   ('Europe/Prague','(GMT+01:00) Центральноевропейское время (Europe/Prague)','+01,00',''),
   ('Europe/Rome','(GMT+01:00) Рим (Europe/Rome)','+01,00',''),
   ('Europe/Stockholm','(GMT+01:00) Стокгольм','+01,00',''),
   ('Europe/Tirane','(GMT+01:00) Тирана','+01,00',''),
   ('Europe/Vaduz','(GMT+01:00) Вадуц','+01,00',''),
   ('Europe/Vienna','(GMT+01:00) Вена','+01,00',''),
   ('Europe/Warsaw','(GMT+01:00) Варшава','+01,00',''),
   ('Europe/Zurich','(GMT+01:00) Цюрих','+01,00',''),
   ('Africa/Blantyre','(GMT+02:00) Блантайр','+02,00',''),
   ('Africa/Bujumbura','(GMT+02:00) Бужумбура','+02,00',''),
   ('Africa/Cairo','(GMT+02:00) Каир','+02,00',''),
   ('Africa/Gaborone','(GMT+02:00) Габороне','+02,00',''),
   ('Africa/Harare','(GMT+02:00) Хараре','+02,00',''),
   ('Africa/Johannesburg','(GMT+02:00) Йоханнесбург','+02,00',''),
   ('Africa/Kigali','(GMT+02:00) Кигали','+02,00',''),
   ('Africa/Lubumbashi','(GMT+02:00) Лубумбаши','+02,00',''),
   ('Africa/Lusaka','(GMT+02:00) Лусака','+02,00',''),
   ('Africa/Maputo','(GMT+02:00) Мапуту','+02,00',''),
   ('Africa/Maseru','(GMT+02:00) Масеру','+02,00',''),
   ('Africa/Mbabane','(GMT+02:00) Мбабане','+02,00',''),
   ('Africa/Tripoli','(GMT+02:00) Триполи','+02,00',''),
   ('Asia/Amman','(GMT+02:00) Амман','+02,00',''),
   ('Asia/Beirut','(GMT+02:00) Бейрут','+02,00',''),
   ('Asia/Damascus','(GMT+02:00) Дамаск','+02,00',''),
   ('Asia/Gaza','(GMT+02:00) Газа','+02,00',''),
   ('Asia/Jerusalem','(GMT+02:00) Jerusalem','+02,00',''),
   ('Asia/Nicosia','(GMT+02:00) Никосия    (Asia/Nicosia)','+02,00',''),
   ('Europe/Athens','(GMT+02:00) Афины','+02,00',''),
   ('Europe/Bucharest','(GMT+02:00) Бухарест','+02,00',''),
   ('Europe/Chisinau','(GMT+02:00) Кишинев','+02,00',''),
   ('Europe/Helsinki','(GMT+02:00) Хельсинки (Europe/Helsinki)','+02,00',''),
   ('Europe/Istanbul','(GMT+02:00) Стамбул (Europe/Istanbul)','+02,00',''),
   ('Europe/Kaliningrad','(GMT+02:00) Москва-01 – Калининград','+02,00','rus'),
   ('Europe/Kiev','(GMT+02:00) Киев','+02,00',''),
   ('Europe/Minsk','(GMT+02:00) Минск','+02,00',''),
   ('Europe/Riga','(GMT+02:00) Рига','+02,00',''),
   ('Europe/Sofia','(GMT+02:00) София','+02,00',''),
   ('Europe/Tallinn','(GMT+02:00) Таллинн','+02,00',''),
   ('Europe/Vilnius','(GMT+02:00) Вильнюс','+02,00',''),
   ('Africa/Addis_Ababa','(GMT+03:00) Аддис-Абеба','+03,00',''),
   ('Africa/Asmara','(GMT+03:00) Асмера','+03,00',''),
   ('Africa/Dar_es_Salaam','(GMT+03:00) Дар-эс-Салам','+03,00',''),
   ('Africa/Djibouti','(GMT+03:00) Джибути','+03,00',''),
   ('Africa/Kampala','(GMT+03:00) Кампала','+03,00',''),
   ('Africa/Khartoum','(GMT+03:00) Хартум','+03,00',''),
   ('Africa/Mogadishu','(GMT+03:00) Могадишо','+03,00',''),
   ('Africa/Nairobi','(GMT+03:00) Найроби','+03,00',''),
   ('Antarctica/Syowa','(GMT+03:00) Сиова','+03,00',''),
   ('Asia/Aden','(GMT+03:00) Аден','+03,00',''),
   ('Asia/Baghdad','(GMT+03:00) Багдад','+03,00',''),
   ('Asia/Bahrain','(GMT+03:00) Бахрейн','+03,00',''),
   ('Asia/Kuwait','(GMT+03:00) Кувейт','+03,00',''),
   ('Asia/Qatar','(GMT+03:00) Катар','+03,00',''),
   ('Asia/Riyadh','(GMT+03:00) Эр-Рияд','+03,00',''),
   ('Europe/Moscow','(GMT+03:00) Москва +00','+03,00','rus'),
   ('Indian/Antananarivo','(GMT+03:00) Антананариву','+03,00',''),
   ('Indian/Comoro','(GMT+03:00) Коморские острова','+03,00',''),
   ('Indian/Mayotte','(GMT+03:00) Майорка','+03,00',''),
   ('Asia/Tehran','(GMT+03:30) Тегеран','+03,30',''),
   ('Asia/Baku','(GMT+04:00) Баку','+04,00',''),
   ('Asia/Dubai','(GMT+04:00) Дубай','+04,00',''),
   ('Asia/Muscat','(GMT+04:00) Мускат','+04,00',''),
   ('Asia/Tbilisi','(GMT+04:00) Тбилиси','+04,00',''),
   ('Asia/Yerevan','(GMT+04:00) Ереван','+04,00',''),
   ('Europe/Samara','(GMT+04:00) Москва +01 – Самара','+04,00','rus'),
   ('Indian/Mahe','(GMT+04:00) Маэ','+04,00',''),
   ('Indian/Mauritius','(GMT+04:00) Маврикий','+04,00',''),
   ('Indian/Reunion','(GMT+04:00) Реюньон','+04,00',''),
   ('Asia/Kabul','(GMT+04:30) Кабул','+04,30',''),
   ('Asia/Aqtau','(GMT+05:00) Актау','+05,00',''),
   ('Asia/Aqtobe','(GMT+05:00) Актобе','+05,00',''),
   ('Asia/Ashgabat','(GMT+05:00) Ашгабат','+05,00',''),
   ('Asia/Dushanbe','(GMT+05:00) Душанбе','+05,00',''),
   ('Asia/Karachi','(GMT+05:00) Карачи','+05,00',''),
   ('Asia/Tashkent','(GMT+05:00) Ташкент','+05,00',''),
   ('Asia/Yekaterinburg','(GMT+05:00) Москва +02 – Екатеринбург','+05,00','rus'),
   ('Indian/Kerguelen','(GMT+05:00) Кергелен','+05,00',''),
   ('Indian/Maldives','(GMT+05:00) Мальдивы','+05,00',''),
   ('Asia/Calcutta','(GMT+05:30) Индийское время','+05,30',''),
   ('Asia/Colombo','(GMT+05:30) Коломбо','+05,30',''),
   ('Asia/Katmandu','(GMT+05:45) Катманду','+05,45',''),
   ('Antarctica/Mawson','(GMT+06:00) Моусон','+06,00',''),
   ('Antarctica/Vostok','(GMT+06:00) Восток','+06,00',''),
   ('Asia/Almaty','(GMT+06:00) Алматы','+06,00',''),
   ('Asia/Bishkek','(GMT+06:00) Бишкек','+06,00',''),
   ('Asia/Dhaka','(GMT+06:00) Дхака','+06,00',''),
   ('Asia/Omsk','(GMT+06:00) Москва +03 – Омск, Новосибирск','+06,00','rus'),
   ('Asia/Thimphu','(GMT+06:00) Тхимпху','+06,00',''),
   ('Indian/Chagos','(GMT+06:00) Чагос','+06,00',''),
   ('Asia/Rangoon','(GMT+06:30) Рангун','+06,30',''),
   ('Indian/Cocos','(GMT+06:30) Кокосовые острова','+06,30',''),
   ('Antarctica/Davis','(GMT+07:00) Davis','+07,00',''),
   ('Asia/Bangkok','(GMT+07:00) Бангкок','+07,00',''),
   ('Asia/Hovd','(GMT+07:00) Ховд','+07,00',''),
   ('Asia/Jakarta','(GMT+07:00) Джакарта','+07,00',''),
   ('Asia/Krasnoyarsk','(GMT+07:00) Москва +04 – Красноярск','+07,00','rus'),
   ('Asia/Phnom_Penh','(GMT+07:00) Пномпень','+07,00',''),
   ('Asia/Saigon','(GMT+07:00) Ханой','+07,00',''),
   ('Asia/Vientiane','(GMT+07:00) Вьентьян','+07,00',''),
   ('Indian/Christmas','(GMT+07:00) Рождественские острова','+07,00',''),
   ('Antarctica/Casey','(GMT+08:00) Кейси','+08,00',''),
   ('Asia/Brunei','(GMT+08:00) Бруней','+08,00',''),
   ('Asia/Choibalsan','(GMT+08:00) Чойбалсан','+08,00',''),
   ('Asia/Hong_Kong','(GMT+08:00) Гонконг','+08,00',''),
   ('Asia/Irkutsk','(GMT+08:00) Москва +05 – Иркутск','+08,00','rus'),
   ('Asia/Kuala_Lumpur','(GMT+08:00) Куала-Лумпур','+08,00',''),
   ('Asia/Macau','(GMT+08:00) Макау','+08,00',''),
   ('Asia/Makassar','(GMT+08:00) Макасар','+08,00',''),
   ('Asia/Manila','(GMT+08:00) Манила','+08,00',''),
   ('Asia/Shanghai','(GMT+08:00) Китайское время – Пекин','+08,00',''),
   ('Asia/Singapore','(GMT+08:00) Сингапур','+08,00',''),
   ('Asia/Taipei','(GMT+08:00) Тайбэй','+08,00',''),
   ('Asia/Ulaanbaatar','(GMT+08:00) Улан-Батор','+08,00',''),
   ('Australia/Perth','(GMT+08:00) Западное время – Перт','+08,00',''),
   ('Asia/Dili','(GMT+09:00) Дили','+09,00',''),
   ('Asia/Jayapura','(GMT+09:00) Джапура','+09,00',''),
   ('Asia/Pyongyang','(GMT+09:00) Пхеньян','+09,00',''),
   ('Asia/Seoul','(GMT+09:00) Сеул','+09,00',''),
   ('Asia/Tokyo','(GMT+09:00) Токио','+09,00',''),
   ('Asia/Yakutsk','(GMT+09:00) Москва +06 – Якутск','+09,00','rus'),
   ('Pacific/Palau','(GMT+09:00) Палау','+09,00',''),
   ('Australia/Adelaide','(GMT+09:30) Центральное время – Аделаида','+09,30',''),
   ('Australia/Darwin','(GMT+09:30) Центральное время – Дарвин','+09,30',''),
   ('Antarctica/DumontDUrville','(GMT+10:00) Дюмон-Дюрвиль','+10,00',''),
   ('Asia/Vladivostok','(GMT+10:00) Москва +07 – Южно-Сахалинск','+10,00','rus'),
   ('Australia/Brisbane','(GMT+10:00) Восточное время – Брисбен','+10,00',''),
   ('Australia/Hobart','(GMT+10:00) Восточное время – Хобарт','+10,00',''),
   ('Australia/Sydney','(GMT+10:00) Восточное время – Мельбурн, Сидней','+10,00',''),
   ('Pacific/Guam','(GMT+10:00) Гуам','+10,00',''),
   ('Pacific/Port_Moresby','(GMT+10:00) Порт-Морсби','+10,00',''),
   ('Pacific/Saipan','(GMT+10:00) Сайпан','+10,00',''),
   ('Pacific/Truk','(GMT+10:00) Трук    (Pacific/Truk)','+10,00',''),
   ('Asia/Magadan','(GMT+11:00) Москва +08 – Магадан','+11,00','rus'),
   ('Pacific/Efate','(GMT+11:00) Эфате','+11,00',''),
   ('Pacific/Guadalcanal','(GMT+11:00) Гвадалканал','+11,00',''),
   ('Pacific/Kosrae','(GMT+11:00) Kosrae','+11,00',''),
   ('Pacific/Noumea','(GMT+11:00) Нумеа','+11,00',''),
   ('Pacific/Ponape','(GMT+11:00) Понапе','+11,00',''),
   ('Pacific/Norfolk','(GMT+11:30) Норфолк','+11,30',''),
   ('Asia/Kamchatka','(GMT+12:00) Москва +09 – Петропавловск-Камчатский','+12,00','rus'),
   ('Pacific/Auckland','(GMT+12:00) Оклэнд','+12,00',''),
   ('Pacific/Fiji','(GMT+12:00) Фиджи','+12,00',''),
   ('Pacific/Funafuti','(GMT+12:00) Фунафути','+12,00',''),
   ('Pacific/Kwajalein','(GMT+12:00) Кваджелейн','+12,00',''),
   ('Pacific/Majuro','(GMT+12:00) Маджуро','+12,00',''),
   ('Pacific/Nauru','(GMT+12:00) Науру','+12,00',''),
   ('Pacific/Tarawa','(GMT+12:00) Тарава','+12,00',''),
   ('Pacific/Wake','(GMT+12:00) остров Вэйк','+12,00',''),
   ('Pacific/Wallis','(GMT+12:00) Уоллис','+12,00',''),
   ('Pacific/Enderbury','(GMT+13:00) острова Эндербери','+13,00',''),
   ('Pacific/Tongatapu','(GMT+13:00) Тонгатапу','+13,00',''),
   ('Pacific/Kiritimati','(GMT+14:00) Киритимати','+14,00',''));

var
{Диалоги}
  sc_ErrPrepareNode  :string;
  sc_ErrCompNodes    :string;
  sc_ErrWriteNode    :string;
  sc_ErrReadNode     :string;
  sc_ErrMissValue    :string;
  sc_ErrMissAgrument :string;
  sc_UnUsedTag       :string;
  sc_DuplicateLink   :string;
  sc_WrongAttr       :string;
  sc_RightAttrValues :string;
  sc_ErrCGroupCreate :string;
  sc_ErrNullAuth     :string;
  sc_ErrFileName     :string;
  sc_ErrFileNull     :string;
  sc_ErrSysGroup     :string;
  sc_ErrGroupLink    :string;

implementation

initialization
//загружаем строки из RES-файла, относящиеся к диалогам с пользователем
  sc_ErrPrepareNode  :=LoadStr(c_ErrPrepareNode);
  sc_ErrCompNodes    :=LoadStr(c_ErrCompNodes);
  sc_ErrWriteNode    :=LoadStr(c_ErrWriteNode);
  sc_ErrReadNode     :=LoadStr(c_ErrReadNode);
  sc_ErrMissValue    :=LoadStr(c_ErrMissValue);
  sc_ErrMissAgrument :=LoadStr(c_ErrMissAgrument);
  sc_UnUsedTag       :=LoadStr(c_UnUsedTag);
  sc_DuplicateLink   :=LoadStr(c_DuplicateLink);
  sc_WrongAttr       :=LoadStr(c_WrongAttr);
  sc_RightAttrValues :=LoadStr(c_RightAttrValues);
  sc_ErrCGroupCreate :=LoadStr(c_ErrCGroupCreate);
  sc_ErrNullAuth     :=LoadStr(c_ErrNullAuth);
  sc_ErrFileName     :=LoadStr(c_ErrFileName);
  sc_ErrFileNull     :=LoadStr(c_ErrFileNull);
  sc_ErrSysGroup     :=LoadStr(c_ErrSysGroup);
  sc_ErrGroupLink    :=LoadStr(c_ErrGroupLink);
end.
