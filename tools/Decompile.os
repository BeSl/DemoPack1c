﻿#Использовать v8runner
#Использовать logos
#Использовать cmdline
#Использовать tempfiles
#Использовать asserts
#Использовать strings

Перем Лог;
Перем УправлениеКонфигуратором;

Функция ВерсииВсехФайлов(Файлы)
	Версии = Новый Соответствие;
	
	Для Каждого Файл Из Файлы Цикл
		Текст = Новый ЧтениеТекста;
		Текст.Открыть(Файл.ПолноеИмя,"UTF-8");
		
		
		Массив = Новый Массив;
		
		Пока Истина Цикл
			Стр = Текст.ПрочитатьСтроку();
			Если Стр = Неопределено Тогда
				Прервать;
			КонецЕсли;	 
			
			Массив.Добавить(Стр);
		КонецЦикла;	
		
		Текст.Закрыть();
		
		Если Массив.Количество() < 1 Тогда
			ВызватьИсключение "Не смог прочитать файл версии: " + Файл.ПолноеИм;
		КонецЕсли;	 
		
		Поз                  = Найти(Массив[0],"|");
		ВерсияСтрокой        = Лев(Массив[0],Поз-1);
		ИмяИзСтроки          = Сред(Массив[0],Поз+1);
		
		ПутьКОбработкеИлиОтчету = Новый Файл(Файл.Путь);
		
		ИмяОбработкиИлиОтчета = НРег(ПутьКОбработкеИлиОтчету.Путь + ИмяИзСтроки);
		
		Версии.Вставить(ИмяОбработкиИлиОтчета,ВерсияСтрокой);
	КонецЦикла;	
	
	Возврат Версии; 
КонецФункции	 

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

Процедура РаспаковатьФайлыПоМаске(Путь,Маска,ИскатьВПодкаталогах)
	Файлы = НайтиФайлы(Путь,Маска,ИскатьВПодкаталогах);
	//Файлыfileversion = НайтиФайлы(Путь,"fileversion",ИскатьВПодкаталогах);
	//ВерсииВсехФайлов = ВерсииВсехФайлов(Файлыfileversion);

	КоличествоФайлов = Файлы.Количество();
	НомерФайла = 0;
	Для Каждого Файл Из Файлы Цикл
		Если Найти(Файл.ПолноеИмя,"V8Reader") > 0 Тогда
			Продолжить;
		КонецЕсли;

		НомерФайла = НомерФайла + 1;
		Лог.Информация("Файл " + НомерФайла + " из " + КоличествоФайлов + ": " + Файл.ПолноеИмя);
		
		//ЗапуститьПриложение("oscript v8files-extractor.os --decompile "+Файл.ПолноеИмя);
		v8Extractor = ЗагрузитьСценарий("tools\v8files-extractor.os");
		Если ОбеспечитьКаталог(Файл.ИмяБезРасширения) Тогда
			v8Extractor.Декомпилировать(Файл.ПолноеИмя, Файл.ИмяБезРасширения);	
		Иначе
			Лог.Информация("не разобран файл : " + Файл.ПолноеИмя);
		КонецЕсли;

	КонецЦикла;	
	
КонецПроцедуры 

Процедура РазобратьОбработкуИлиОтчетВКаталогеИПодКаталогах(Путь)
	Файл = Новый Файл(Путь);
	Если НЕ Файл.Существует() Тогда
		ВызватьИсключение "Каталог <" + Путь + "> не существует.";
	КонецЕсли;	 
	
	РаспаковатьФайлыПоМаске(Путь,"*.erf",Истина);
	РаспаковатьФайлыПоМаске(Путь,"*.epf",Истина);
КонецПроцедуры 

Процедура Декомпилировать(КаталогОбработки) Экспорт
	РазобратьОбработкуИлиОтчетВКаталогеИПодКаталогах(КаталогОбработки);
КонецПроцедуры

Лог = Логирование.ПолучитьЛог("vb.decompile.log");
Лог.УстановитьУровень(УровниЛога.Отладка);

Если АргументыКоманднойСтроки.Количество() = 0 Тогда
	Лог.Ошибка("Не переданы параметры!");
ИначеЕсли АргументыКоманднойСтроки.Количество() > 1 Тогда
	Лог.Ошибка("Скрипт принимает только один параметр!");
Иначе
	РазобратьОбработкуИлиОтчетВКаталогеИПодКаталогах(АргументыКоманднойСтроки[0]);
КонецЕсли;

Сообщить("Обработка завершена.");



