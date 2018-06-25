﻿#Использовать v8runner
#Использовать logos
#Использовать cmdline
#Использовать tempfiles
#Использовать asserts
#Использовать strings
Перем Лог;
Перем УправлениеКонфигуратором;

// Проверяет наличия каталога и в случае его отсутствия создает новый.
//
// Параметры:
//  Каталог - Строка - Путь к каталогу, существование которого нужно проверить.
//
// Возвращаемое значение:
//  Булево - признак существования каталога.
//
// Взято из https://infostart.ru/public/537028/
Функция ОбеспечитьКаталог(Знач Каталог)
	
	Файл = Новый Файл(Каталог);
	Если Не Файл.Существует() Тогда
		Попытка 
			СоздатьКаталог(Каталог);
		Исключение
			Лог.Ошибка(СтрШаблон(НСтр("ru = 'Не удалось создать каталог %1.
				|%2'"), Каталог, ИнформацияОбОшибке()));
			Возврат Ложь;
		КонецПопытки;
	ИначеЕсли Не Файл.ЭтоКаталог() Тогда 
		Лог.Ошибка(СтрШаблон(НСтр("ru = 'Каталог %1 не является каталогом.'"), Каталог));
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Процедура СобратьОбработкуИлиОтчетВКаталогеИПодКаталогах(Путь)
	Файл = Новый Файл(Путь);
	Если НЕ Файл.Существует() Тогда
		ВызватьИсключение "Каталог <" + Путь + "> не существует.";
	КонецЕсли;	 
	

	v8Extractor = ЗагрузитьСценарий("tools\v8files-extractor.os");
	КаталогВыгрузки = ОбъединитьПути(ТекущийКаталог(),"bin");
	Если ОбеспечитьКаталог(КаталогВыгрузки) Тогда
		v8Extractor.Компилировать(Путь,КаталогВыгрузки);
	КонецЕсли;

КонецПроцедуры 

Лог = Логирование.ПолучитьЛог("vb.compile.log");
Лог.УстановитьУровень(УровниЛога.Отладка);

Если АргументыКоманднойСтроки.Количество() = 0 Тогда
	Лог.Ошибка("Не переданы параметры!");
ИначеЕсли АргументыКоманднойСтроки.Количество() > 1 Тогда
	Лог.Ошибка("Скрипт принимает только один параметр!");
Иначе
	СобратьОбработкуИлиОтчетВКаталогеИПодКаталогах(АргументыКоманднойСтроки[0]);
КонецЕсли;

Сообщить("Обработка завершена.");



