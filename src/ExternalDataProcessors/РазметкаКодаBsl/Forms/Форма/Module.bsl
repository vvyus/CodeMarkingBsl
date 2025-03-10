#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)  
	//Текст="	Если Это пример разбора 
	//| Если к=1 Тогда строки на токены, Иначе и вывода полученного результата. КонецЕсли; !
	//|иначе// это комментарий 
	//|конецесли;";
	Текст = "";
	СтрокаТекст.УстановитьТекст(Текст);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
&НаКлиенте
Асинх Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)
	
	Режим = РежимДиалогаВыбораФайла.Открытие;
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(Режим);
	ДиалогОткрытияФайла.ПолноеИмяФайла = "";
	Фильтр = НСтр("ru = 'Текст'; en = 'Text'")
	+ "(*.txt)|*.txt";
	ДиалогОткрытияФайла.Фильтр = Фильтр;
	ДиалогОткрытияФайла.Заголовок = "Выберите файлы";
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		ИмяФайла = ДиалогОткрытияФайла.ПолноеИмяФайла; 
		ЗагрузитьИзФайлаНаСервере();
	КонецЕсли;
	
КонецПроцедуры
#КонецОбласти

#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура ЗагрузитьИзФайла(Команда)
	ЗагрузитьИзФайлаНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьКод(Команда)
	ВходящаяСтрока=СтрокаТекст.ПолучитьТекст();    
	СтрокаHtml=ВыполнитьКодНаСервере(ВходящаяСтрока);
	Элементы.СтрокаHtml.Документ.documentElement.innerHTML=СтрокаHtml;	

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
	
&НаСервере
Функция ВыполнитьКодНаСервере(ВходящаяСтрока)
	ОбработкаОбъект=РеквизитФормыВЗначение("Объект");
	СтрокаHtml=ОбработкаОбъект.ПолучитьHtmlСтроку(ВходящаяСтрока);
	Возврат СтрокаHtml;
	
КонецФункции

&НаСервере
Процедура ЗагрузитьИзФайлаНаСервере()
	
	СтрокаТекст.Очистить();
	СтрокаТекст.Прочитать(ИмяФайла);
	
КонецПроцедуры

#КонецОбласти



