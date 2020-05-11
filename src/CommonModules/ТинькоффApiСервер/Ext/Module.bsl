﻿
#Область ПрограммныйИнтерфейс

// Создает новую сессию.
//	В сессию сохраняется "sessionid".
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//
Процедура ОткрытьСессию(Сессия) Экспорт

	Сессия = НоваяСессия();
	
	Метод = "session";
	ПараметрыЗапроса = ПараметрыЗапроса();
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса);
	
	Если Не ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия) Тогда
		Возврат;
	КонецЕсли;	
	
	Сессия.Вставить("sessionid", РезультатЗапроса.Ответ.payload);
	
КонецПроцедуры

// Закрывает текущую сессию.
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//
Процедура ЗакрытьСессию(Сессия) Экспорт

	Сессия = НоваяСессия();
	
	Метод = "sign_out";
	ПараметрыЗапроса = ПараметрыЗапроса();
	ПараметрыЗапроса.Вставить("sessionid", Сессия.sessionid);
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса);
	
	Если Не ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия) Тогда
		Возврат;
	КонецЕсли;	
	
КонецПроцедуры

// Выполняет запрос на авторизацию. В сессию сохраняется "sessionid".
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//  ИмяПользователя  - Строка - ИмяПользователя.
//  Пароль  - Строка - Пароль.
//
Процедура ВыполнитьАвторизацию(Сессия, ИмяПользователя, Пароль) Экспорт

	Если Сессия = Неопределено Тогда
		ОткрытьСессию(Сессия);	
	КонецЕсли; 
	
	Метод = "sign_up";
	ПараметрыЗапроса = ПараметрыЗапросаАвторизации();
	ПараметрыЗапроса.Вставить("sessionid", Сессия.sessionid);
	ПараметрыЗапроса.Вставить("username", ИмяПользователя);
	ПараметрыЗапроса.Вставить("password", Пароль);
	
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса);
	
	Если Не ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия) Тогда
		Возврат;
	КонецЕсли;	
	
	Сессия.Вставить("ПодтверждениеВхода", (РезультатЗапроса.Ответ.resultCode = "WAITING_CONFIRMATION"));
	Сессия.Вставить("initialOperationTicket", РезультатЗапроса.Ответ.operationTicket);
	
	Если Не Сессия.ПодтверждениеВхода Тогда
		Сессия.Вставить("accessLevel", РезультатЗапроса.Ответ.payload.accessLevel);
	КонецЕсли; 
	
КонецПроцедуры

// Выполняет подтверждение входа по одноразовому коду.
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//  КодПодтверждения  - Строка - Код подтверждения.
//
Процедура ПодтвердитьАвторизацию(Сессия, КодПодтверждения) Экспорт

	Метод = "confirm";
	ПараметрыЗапроса = ПараметрыЗапросаПодтвержденияАвторизации();
	ПараметрыЗапроса.Вставить("sessionid", Сессия.sessionid);
	ПараметрыЗапроса.Вставить("secretValue", КодПодтверждения); 
	ПараметрыЗапроса.Вставить("initialOperationTicket", Сессия.initialOperationTicket); 
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса);
	
	Если Не ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия) Тогда
		Возврат;
	КонецЕсли;	
	
	Сессия.Вставить("accessLevel", РезультатЗапроса.Ответ.payload.accessLevel);

КонецПроцедуры

// Выполняет повышение уровня доступа с "CANDIDATE" до "CLIENT".
//	Необходимо для некоторых запросов, например, для получения данных по операциям.
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//
Процедура ПовыситьУровеньДоступа(Сессия) Экспорт
	
	Метод = "level_up";
	ПараметрыЗапроса = ПараметрыЗапроса();
	ПараметрыЗапроса.Вставить("sessionid", Сессия.sessionid);
	
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса);
	
	Если Не ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия) Тогда
		Возврат;
	КонецЕсли;	

КонецПроцедуры

// Проверяет активность сессии. 
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//
// Возвращаемое значение:
//   Булево   - Истина, если сессия активна.
//
Функция СессияАктивна(Сессия) Экспорт

	Если Сессия = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли; 
	
	Метод = "session_status";
	ПараметрыЗапроса = ПараметрыЗапросаАвторизации();
	ПараметрыЗапроса.Вставить("sessionid", Сессия.sessionid);
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса);
	
	Возврат (РезультатЗапроса.Ответ.resultCode = "ОК");
	  
КонецФункции

// Возвращает данные по операциям за период.
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//  НачалоПериода  - Дата - Начало периода, за который запрашиваются операции.
//  КонецПериода  - Дата - Конец периода, за который запрашиваются операции.
//
Функция ПолучитьОперацииЗаПериод(Сессия, НачалоПериода, КонецПериода) Экспорт
	
	Если ТребуетсяПовышениеУровняДоступа(Сессия) Тогда
		ПовыситьУровеньДоступа(Сессия);
	КонецЕсли; 
	
	Метод = "operations";
	ПараметрыЗапроса = ПараметрыЗапроса();
	ПараметрыЗапроса.Вставить("sessionid", Сессия.sessionid);
	ПараметрыЗапроса.Вставить("start", ПреобразоватьДатуВUnixTime(НачалоПериода));
	ПараметрыЗапроса.Вставить("end", ПреобразоватьДатуВUnixTime(КонецПериода));
	
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса);
	
	Если Не ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия) Тогда
		Возврат Неопределено;
	КонецЕсли;	
	
	Возврат РезультатЗапроса;
	
КонецФункции

// Возвращает данные по операциям за период в формате Excel.
//
// Параметры:
//  Сессия  - Структура - Сессия, см. НоваяСессия().
//  НачалоПериода  - Дата - Начало периода, за который запрашиваются операции.
//  КонецПериода  - Дата - Конец периода, за который запрашиваются операции.
//
// Возвращаемое значение:
//   Структура   - Результат выполнения запроса.
//		* ОписаниеОповещения - ОписаниеОповещения - Процедура, которая будет вызвана после подтверждения входа.
//
Функция ПолучитьОперацииЗаПериодВФорматеExcel(Сессия, НачалоПериода, КонецПериода) Экспорт
	
	Если ТребуетсяПовышениеУровняДоступа(Сессия) Тогда
		ПовыситьУровеньДоступа(Сессия);
	КонецЕсли; 
	
	Метод = "export_operations";
	
	ПараметрыЗапроса = ПараметрыЗапроса();
	ПараметрыЗапроса.Вставить("sessionid", Сессия.sessionid);
	ПараметрыЗапроса.Вставить("start", ПреобразоватьДатуВUnixTime(НачалоПериода));
	ПараметрыЗапроса.Вставить("end", ПреобразоватьДатуВUnixTime(КонецПериода));
	ПараметрыЗапроса.Вставить("format", "xls");
	
	РезультатЗапроса = ВыполнитьЗапросКСервису(Метод, ПараметрыЗапроса, Истина);
	
	Если Не ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия) Тогда
		Возврат Неопределено;
	КонецЕсли;	
	
	Возврат РезультатЗапроса;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Функция-конструктор сессии.
//
// Возвращаемое значение:
//   Структура   - Параметры сессии.
//
Функция НоваяСессия()

	Сессия = Новый Структура;
	Сессия.Вставить("Отказ", Ложь);
	Сессия.Вставить("ТекстОшибки", "");
	Сессия.Вставить("ПодтверждениеВхода", Ложь);
	Сессия.Вставить("sessionid", "");
	Сессия.Вставить("accessLevel", "");
	Сессия.Вставить("initialOperationTicket", "");
	
	Возврат Сессия;
	  
КонецФункции

Функция ТребуетсяПовышениеУровняДоступа(Сессия)

	Возврат (Сессия.accessLevel = "CANDIDATE");	

КонецФункции

// Преобразует дату в дату формате UnixTime.
//	Дата в формате UnixTime это количество секунд прошедших с 01.01.1970 г.
//	Выражается строкой 16 символов.	
//
// Параметры:
//  Дата1С  - Дата - Дата.
//
// Возвращаемое значение:
//   Строка   - Дата формате UnixTime.
//
Функция ПреобразоватьДатуВUnixTime(Дата1С)

	Возврат Формат(Дата1С - Дата(1970, 1, 1, 1, 0, 0), "ЧС=-3; ЧГ=0");

КонецФункции

// Преобразует дату формате UnixTime в дату.
//	Дата в формате UnixTime это количество секунд прошедших с 01.01.1970 г.
//	Выражается строкой 16 символов.	
//
// Параметры:
//  UnixTime  - Строка - Дата формате UnixTime.
//
// Возвращаемое значение:
//   Дата   - Дата.
//
Функция ПреобразоватьUnixTimeВДату(UnixTime)
	Возврат Дата(1970, 1, 1, 1, 0, 0) + Число(Лев(UnixTime, 13));
КонецФункции

Функция ПроверитьРезультатЗапроса(РезультатЗапроса, Сессия)
	
	Если РезультатЗапроса.Отказ Тогда
		Сессия.Вставить("Отказ", Истина);
		Сессия.Вставить("ТекстОшибки", "Не удалось выполнить запрос к серверу");
		Возврат Ложь;
	КонецЕсли; 
	
	Если ТипЗнч(РезультатЗапроса.Ответ) = Тип("Структура") Тогда
	
		Если РезультатЗапроса.Ответ.resultCode = "INTERNAL_ERROR" Тогда
			Сессия.Вставить("Отказ", Истина);
			Сессия.Вставить("ТекстОшибки", РезультатЗапроса.Ответ.plainMessage);
			Возврат Ложь;
		КонецЕсли; 
		
		Если РезультатЗапроса.Ответ.resultCode = "INVALID_REQUEST_DATA" Тогда
			Сессия.Вставить("Отказ", Истина);
			Сессия.Вставить("ТекстОшибки", РезультатЗапроса.Ответ.plainMessage);
			Возврат Ложь;
		КонецЕсли; 
		
	КонецЕсли; 

	Возврат Истина;
	
КонецФункции

Функция ПараметрыЗапросаАвторизации()
	
	ПараметрыЗапроса = ПараметрыЗапроса();
	ПараметрыЗапроса.Вставить("username");
	ПараметрыЗапроса.Вставить("password");
	
	Возврат ПараметрыЗапроса;

КонецФункции

Функция ПараметрыЗапросаПодтвержденияАвторизации()

	ПараметрыЗапроса = ПараметрыЗапроса();
	ПараметрыЗапроса.Вставить("initialOperation", "sign_up");
	ПараметрыЗапроса.Вставить("confirmationType", "SMSBYID");
	ПараметрыЗапроса.Вставить("secretValue", );
	
	Возврат ПараметрыЗапроса;

КонецФункции

Функция ПараметрыЗапроса()
	
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("origin", "web%2Cib5%2Cplatform");

	Возврат ПараметрыЗапроса;
	
КонецФункции

Функция ПараметрыПодключения()
	
	ПараметрыПодключения = Новый Структура;
	ПараметрыПодключения.Вставить("ИмяПользователя", "Bazil1c");
	ПараметрыПодключения.Вставить("Пароль", "VJcN2i6NWQcrfac");
	ПараметрыПодключения.Вставить("Адрес", "api.tinkoff.ru/v1/");

	Возврат ПараметрыПодключения;
	
КонецФункции

// Выполняет запрос к серверу.
//
// Параметры:
//  АдресРесурса  - Строка - Адрес ресурса сервера.
//  ПараметрыЗапроса  - Структура - Параметры запроса к серверу.
//  ДвоичныеДанные  - Булево - Признак получения результат в виде двоичных данных.
//
// Возвращаемое значение:
//   Структура   - Результат выполнения запроса.
//		* Отказ - Булево - Признак неудачного выполнения запроса.
//		* Ответ - Структура - Результат запроса.
//		* АдресВоВременномХранилище - Строка - Адрес, по которому размещены двоичные данные.
//			Используется, если требуется получить результат в виде двоичных данных.
//
Функция ВыполнитьЗапросКСервису(АдресРесурса, ПараметрыЗапроса, ДвоичныеДанные = Ложь)

	Если ПараметрыЗапроса.Свойство("ПараметрыПодключения") Тогда
		ПараметрыПодключения = ПараметрыЗапроса.ПараметрыПодключения;
	Иначе
		ПараметрыПодключения = ПараметрыПодключения();
	КонецЕсли; 
	
	РезультатЗапроса = Новый Структура;
	РезультатЗапроса.Вставить("Ответ", Неопределено);
	РезультатЗапроса.Вставить("АдресВоВременномХранилище", Неопределено);
	РезультатЗапроса.Вставить("Отказ", Ложь);
	
	ДополнитьАдресРесурсаПараметрамиЗапроса(АдресРесурса, ПараметрыЗапроса);
	
	HTTPСоединение = Новый HTTPСоединение(ПараметрыПодключения.Адрес, , , , , , Новый ЗащищенноеСоединениеOpenSSL());
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса); 
	
	Ответ = HTTPСоединение.Получить(HTTPЗапрос);   
	
	Если Не Ответ.КодСостояния = 200 Тогда
		РезультатЗапроса.Вставить("Отказ", Истина);
		Возврат РезультатЗапроса; 
	КонецЕсли; 
	
	Если ДвоичныеДанные Тогда
		
		ТелоОтвета = Ответ.ПолучитьТелоКакДвоичныеДанные();
		Результат = ПоместитьВоВременноеХранилище(ТелоОтвета, Новый УникальныйИдентификатор); 
		
		РезультатЗапроса.Вставить("АдресВоВременномХранилище", Результат);
		
	Иначе
		
		ТелоОтвета = РаскодироватьСтроку(Ответ.ПолучитьТелоКакСтроку(), СпособКодированияСтроки.КодировкаURL);
		
		ЧтениеJSON = Новый ЧтениеJSON;
	    ЧтениеJSON.УстановитьСтроку(ТелоОтвета);
		Результат = ПрочитатьJSON(ЧтениеJSON);
		РезультатЗапроса.Вставить("Ответ", Результат);
		
	КонецЕсли;	
	
	Возврат РезультатЗапроса;
	
КонецФункции

Процедура ДополнитьАдресРесурсаПараметрамиЗапроса(АдресРесурса, Знач ПараметрыЗапроса)
	
	ПараметрыЗапросаМассив = Новый Массив;
	
	Для каждого КлючИЗначение Из ПараметрыЗапроса Цикл
	
		СтрокаПараметра = СтрШаблон("%1=%2", КлючИЗначение.Ключ, КлючИЗначение.Значение);
		ПараметрыЗапросаМассив.Добавить(СтрокаПараметра);
	
	КонецЦикла; 
	
	ПараметрыЗапросаСтрока = СтрСоединить(ПараметрыЗапросаМассив, "&");
	АдресРесурса = СтрШаблон("%1?%2", АдресРесурса, ПараметрыЗапросаСтрока);

КонецПроцедуры

#КонецОбласти
