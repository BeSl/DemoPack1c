#Использовать cmdline
#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать v8runner
#Использовать strings

Перем Лог;
Перем КодВозврата;
Перем мВозможныеКоманды;
Перем ЭтоWindows;

Функция Версия() Экспорт

	Версия = "1.1.0";

	Возврат "v" + Версия;

КонецФункции

Процедура ПроверитьНастройкиРепозитарияГит() Экспорт
	Перем КодВозврата;

	КомандаПроверкаСостояния = "git config core.quotepath";
	Лог.Отладка("Выполняю команду "+КомандаПроверкаСостояния);

	Вывод = ПолучитьВыводПроцесса(КомандаПроверкаСостояния, КодВозврата);
	Вывод = СокрЛП(Вывод);
	Лог.Отладка("	Код возврата " + КодВозврата);
	Лог.Отладка("	Вывод команды <" + Вывод + ">");
	Если КодВозврата = 0 И Вывод = "false" Тогда
		Сообщить("Ошибое настройки не обнаружено.");
		Возврат;
	КонецЕсли;

	ВызватьИсключение "У текущего репозитария не заданы необходимые настройки!
	|Выполните команду git config --local core.quotepath false
	|
	|А еще лучше сделать глобальную настройку git config --global core.quotepath false";

КонецПроцедуры

Функция ПолучитьЖурналИзмененийГит()

	Перем КодВозврата;

	Вывод = "";//ВыполнитьКомандуГит("git diff-index --name-status --cached HEAD", КодВозврата, Ложь);
	Если КодВозврата <> 0 Тогда
		Вывод = "";//ВыполнитьКомандуГит("git status --porcelain", КодВозврата, Ложь);

		Если КодВозврата <> 0 Тогда
			ВызватьИсключение "Не удалось собрать журнал изменений git";
		КонецЕсли;

	КонецЕсли;

	Возврат Вывод;

КонецФункции

Функция ПолучитьВыводПроцесса(Знач КоманднаяСтрока, КодВозврата)

	Возврат 0;//Выв0од;

КонецФункции

Функция ПолучитьИменаИзЖурналаИзмененийГит(Знач ЖурналИзмененийГит) Экспорт
	Лог.Отладка("ЖурналИзмененийГит:");
	МассивИмен = Новый Массив;
	// Если Найти(ЖурналИзмененийГит, Символы.ПС) > 0 Тогда
		МассивСтрокЖурнала = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(ЖурналИзмененийГит, Символы.ПС);
	// Иначе
		// ЖурналИзмененийГит = СтрЗаменить(ЖурналИзмененийГит, "A"+Символ(0), "A"+" ");
		// ЖурналИзмененийГит = СтрЗаменить(ЖурналИзмененийГит, "M"+Символ(0), "M"+" ");
		// ЖурналИзмененийГит = СтрЗаменить(ЖурналИзмененийГит, Символ(0), Символы.ПС);
		// МассивСтрокЖурнала = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(ЖурналИзмененийГит, Символы.ПС); //Символ(0));
	// КонецЕсли;

	Для Каждого СтрокаЖурнала Из МассивСтрокЖурнала Цикл
		Лог.Отладка("	<%1>", СтрокаЖурнала);
		СтрокаЖурнала = СокрЛ(СтрокаЖурнала);
		СимволИзменений = Лев(СтрокаЖурнала, 1);
		Если СимволИзменений = "A" или СимволИзменений = "M" Тогда
			ИмяФайла = СокрЛП(Сред(СтрокаЖурнала, 2));
			// ИмяФайла = СтрЗаменить(ИмяФайла, Символ(0), "");
			МассивИмен.Добавить(ИмяФайла);
			Лог.Отладка("		В журнале git найдено имя файла <%1>", ИмяФайла);
		КонецЕсли;
	КонецЦикла;
	Возврат МассивИмен;
КонецФункции

Процедура ВывестиСправку()
	Сообщить("Утилита сборки/разборки внешних файлов 1С");
	Сообщить(Версия());
	Сообщить(" ");
	Сообщить("Параметры командной строки:");
	Сообщить("	--decompile inputPath ");
	Сообщить("		Разбор файлов на исходники");

	Сообщить("	--help");
	Сообщить("		Показ этого экрана");

	Сообщить("	--compile inputPath");
	Сообщить("		Собрать файл обработку из исходников");

	Сообщить("	--getSet");
	Сообщить("		проверить настройку репозитария");
	Сообщить("__________________________________________");
	Сообщить("		");
	Сообщить("		");
КонецПроцедуры


Функция ВозможныеКоманды()

	Если мВозможныеКоманды = Неопределено Тогда
		мВозможныеКоманды = Новый Структура;
		мВозможныеКоманды.Вставить("Декомпилировать", "--decompile");
		мВозможныеКоманды.Вставить("Компилировать", "--compile");
		мВозможныеКоманды.Вставить("НастройкиГит", "--getSet");
		мВозможныеКоманды.Вставить("Помощь", "--help");

	КонецЕсли;

	Возврат мВозможныеКоманды;

КонецФункции

Процедура Декомпилировать(ПутьВходящихДанных,ВыходнойКаталог)
КонецПроцедуры
 
Процедура Компилировать(ПутьВходящихДанных,ВыходнойКаталог)
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыДекомпилировать(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Декомпилировать);
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьВходящихДанных");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ВыходнойКаталог");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыПомощь(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Помощь);
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыКомпилировать(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().Компилировать);
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьВходящихДанных");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ВыходнойКаталог");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--recursive");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Процедура ДобавитьОписаниеКомандыОбработатьИзмененияИзГит(Знач Парсер)
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ВозможныеКоманды().ОбработатьИзмененияИзГит);
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--git-precommit");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
КонецПроцедуры

Функция ЗапускВКоманднойСтроке(АргументыКоманднойСтроки)
	
	КодВозврата = 0;

	Если ТекущийСценарий().Источник <> СтартовыйСценарий().Источник Тогда
		Возврат Ложь;
	КонецЕсли;

	Лог.Информация("bsl " + Версия() + Символы.ПС);

	Попытка

		Парсер = Новый ПарсерАргументовКоманднойСтроки();

		ДобавитьОписаниеКомандыДекомпилировать(Парсер);
		ДобавитьОписаниеКомандыПомощь(Парсер);
		ДобавитьОписаниеКомандыКомпилировать(Парсер);


		Аргументы = Парсер.РазобратьКоманду(АргументыКоманднойСтроки);
		Лог.Отладка("ТипЗнч(Аргументы)= "+ТипЗнч(Аргументы));

		Если Аргументы = Неопределено Тогда
			ВывестиСправку();
			Возврат Истина;
		КонецЕсли;

		Команда = Аргументы.Команда;
		Сообщить("ком "+ Команда);
		Лог.Отладка("Передана команда: "+Команда);
		Для Каждого Параметр Из Аргументы.ЗначенияПараметров Цикл
			Лог.Отладка("%1 = %2", Параметр.Ключ, Параметр.Значение);
		КонецЦикла;

		Если Команда = ВозможныеКоманды().Декомпилировать Тогда
			внСкрипт = ЗагрузитьСценарий("tools\Decompile.os");
			внСкрипт.Декомпилировать(Аргументы.ЗначенияПараметров["ПутьВходящихДанных"]);
			//Декомпилировать(Аргументы.ЗначенияПараметров["ПутьВходящихДанных"], Аргументы.ЗначенияПараметров["ВыходнойКаталог"]);
		ИначеЕсли Команда = ВозможныеКоманды().Помощь Тогда
			ВывестиСправку();
		//ИначеЕсли Команда = ВозможныеКоманды().ОбработатьИзмененияИзГит Тогда
		//	ОбработатьИзмененияИзГит(Аргументы.ЗначенияПараметров["ВыходнойКаталог"], Аргументы.ЗначенияПараметров["--remove-orig-bin-files"]);
		ИначеЕсли Команда = ВозможныеКоманды().Компилировать Тогда
			внСкрипт = ЗагрузитьСценарий("tools\Decompile.os");
			внСкрипт.СобратьОбработкуИзФайлов(
				Аргументы.ЗначенияПараметров["ПутьВходящихДанных"]);
		ИначеЕсли Команда = ВозможныеКоманды().НастройкиГит Тогда
			ПроверитьНастройкиРепозитарияГит();
		КонецЕсли;

	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		КодВозврата = 1;
	КонецПопытки;

	Лог.Отладка("Очищаем каталог временной ИБ");
	Попытка
		ВременныеФайлы.Удалить();
	Исключение
	КонецПопытки;

	Возврат Истина;

КонецФункции

Лог = Логирование.ПолучитьЛог("bsl.decompile.log");
Лог.УстановитьУровень(УровниЛога.Отладка);

Если АргументыКоманднойСтроки.Количество() = 0 Тогда
	Лог.Ошибка("Не переданы параметры!");
Иначе
	РезультатФ = ЗапускВКоманднойСтроке(АргументыКоманднойСтроки);
КонецЕсли;