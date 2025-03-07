#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс 
  
// Получить html строку.
// 
// Параметры:
//  ВходящаяСтрока-Строка- Входящая строка
// 
// Возвращаемое значение:
//  Строка - Получить html строку
Функция ПолучитьHtmlСтроку(ВходящаяСтрока) Экспорт
	Токены = РазобратьСтрокуНаТокены(ВходящаяСтрока);
	СтрокаШаблона="	
	|<head>
	|<style>      
	|.tabbed {
	|    white-space: pre;
	|  }	
	|html, body {
	|	margin: 0;
	|	padding: 0;
	|	margin-left: %3;	
	|	font-family: 'Consolas', monospace;
//	|	font-family: 'Courier New', monospace;
//	|	font-size: 11pt;
	|	font-size: 14px;
	|	line-height: 1.15;
	|	background-color: #e9e9e9;
	|	width: %2;	
	|}  
	|</style>
	|</head>
	|<html><body>	
	|<pre><code>%1</code></pre>	
	|</body></html>
	|";
	
	СтрокаHtml="";
	Для Каждого Токен Из Токены Цикл
		Тип=Токен.Тип;
		ТекущийТокен=Токен.Токен;
		Если Тип=1 Тогда                                      
			ТекущийТокен=ОформитьИдентификатор(ТекущийТокен);
		ИначеЕсли Тип=2 Тогда	
			//комментарий
			ТекущийТокен=ОформитьКомментарий(ТекущийТокен);
		ИначеЕсли Тип=4 Тогда		
			ТекущийТокен=ОформитьКлючевоеСлово(ТекущийТокен);
		ИначеЕсли Тип=3 Тогда	
			//разделитель
			//ничего не делаем пустая строка
		ИначеЕсли Тип=5 Тогда		
			ТекущийТокен=ОформитьЗначениеПоУмолчанию(ТекущийТокен);
		ИначеЕсли Тип=6 Тогда		
	        ТекущийТокен=ОформитьСлужебныйТекст(ТекущийТокен);
		КонецЕсли;	
		СтрокаHtml=СтрокаHtml+ТекущийТокен;
	КонецЦикла;        
	СтрокаHtml=СтрШаблон(СтрокаШаблона,СтрокаHtml,"100%","1%");
	
	Возврат СтрокаHtml;
КонецФункции

// Разобрать строку на токены.
// 
// Параметры:
//  ВходящаяСтрока - Строка - Входящая строка
// 
// Возвращаемое значение:
//  Массив из Строка - Разобрать строку на токены
Функция РазобратьСтрокуНаТокены(ВходящаяСтрока) Экспорт
	КлючевыеСимволы=ПолучитьКлючевыеСимволы();
	КлючевыеСлова=ПолучитьКлючевыеСлова();
	ПоУмолчаниюСимволы=ПолучитьПоУмолчаниюСимволы();
    Токены = Новый Массив;
    ТекущийТокен = ""; 
    Разделители = " "+Символы.Таб+Символы.ПС; // Добавляем несколько разделителей
	
	Индекс = 1;
	СимволПред="";      
	Тип=0;
	ЭтоКомментарий=Ложь; 
	ЭтоСтрока=Ложь;
	ЭтоСлужебный=Ложь;
    Пока Индекс <= СтрДлина(ВходящаяСтрока) Цикл
        Символ = Сред(ВходящаяСтрока, Индекс, 1);
		//определяем типы 
		//1-идентификатор,
		//2-комментарий,
		//3-разделитель
		//4-ключевой символ
		//5-строка
		//6-служебный
		Если Символ="/" И СимволПред="/" И не ЭтоКомментарий И не ЭтоСтрока Тогда 
			//Сброс токена в кэш перед комментом
			//начало комментария
			ТипПред=Тип;                                             
			ТекущийТокен=Лев(ТекущийТокен,СтрДлина(ТекущийТокен)-1); //убираем из токена который перед комментарием "/"
			ПеренестиТекущийТокенВМассивТокенов(Токены,ТекущийТокен,ТипПред,КлючевыеСлова);			
			ТекущийТокен = "/";			// добавляем в коммент "/"                			
			Тип=2;
			ЭтоКомментарий=Истина;            
			
		ИначеЕсли Символ=Символы.ПС И ЭтоКомментарий Тогда 
			//сброс комментария в кэш
			//конец комментария
			ТипПред=2;
			Тип=3;
			ЭтоКомментарий=Ложь; 
		ИначеЕсли Символ="""" И Не ЭтоСтрока И не ЭтоКомментарий И не ЭтоСлужебный Тогда 			
			//сброс предыдущего токена в кэш			
			//начало строки
			ПеренестиТекущийТокенВМассивТокенов(Токены,ТекущийТокен,ТипПред,КлючевыеСлова);
			Тип=5;	
			ЭтоСтрока=Истина; 
			
		ИначеЕсли Символ="""" И ЭтоСтрока И не ЭтоКомментарий И не ЭтоСлужебный Тогда
			//сброс строки в кэш
			//конец строки 
			ТипПред=5;
			Тип=5;  
			// разбор строки с "|" для запроса
			ТекущийТокен=РазборМногострочнойСтроки(ТекущийТокен);
			
			//ТекущийТокен=СтрЗаменить(ТекущийТокен," ","&nbsp;");
			//ТекущийТокен=СтрЗаменить(ТекущийТокен,Символы.Таб,"&emsp;");

			Токены.Добавить( Новый Структура("Токен,Тип",ТекущийТокен,ТипПред));
			ТекущийТокен="";
			
			ЭтоСтрока=Ложь;
		ИначеЕсли (Символ="#" ИЛИ Символ="&") И (Не ЭтоСтрока И не ЭтоКомментарий И не ЭтоСлужебный) Тогда 			
			//сброс предыдущего токена в кэш			
			//начало директивы
			ПеренестиТекущийТокенВМассивТокенов(Токены,ТекущийТокен,ТипПред,КлючевыеСлова);
			Тип=6;	
			ЭтоСлужебный=Истина; 
		ИначеЕсли Символ=Символы.ПС И ЭтоСлужебный Тогда 
			//сброс служебного в кэш
			//конец служебного
			ТипПред=6;
			Тип=3; //разделитель
			ЭтоСлужебный=Ложь; 
		//ИначеЕсли Символ=Символы.ВК И Не ЭтоСтрока И не ЭтоКомментарий И не ЭтоСлужебный И КлючевыеСлова.Найти(Нрег(ТекущийТокен))<>Неопределено Тогда 
		//	//оказалось что ключевое слово перед переводом строки
		//	ТипПред=4;
		//	Тип=3; //разделитель
		ИначеЕсли Символ=Символы.ВК Тогда
			//пропускаем символы ВК
			Индекс=Индекс+1;
			Продолжить;
		ИначеЕсли ПоУмолчаниюСимволы.Найти(Символ)<>Неопределено Тогда
			Тип=5;
		ИначеЕсли КлючевыеСимволы.Найти(Символ)<>Неопределено И не ЭтоСтрока Тогда 
			//это не ключевой символ в строке , напимер "/" 
			Тип=4;
		ИначеЕсли Найти(Разделители, Символ) = 0 Тогда
			Тип=1;
		ИначеЕсли Найти(Разделители, Символ) >0  Тогда	
			Тип=3;
		Иначе    
			//?
			Тип=0;
		КонецЕсли;	
		
		Если Индекс=1 Тогда
			ТипПред=Тип;
		КонецЕсли;	
		//сменился тип, определяем токен
		Если ТипПред<>Тип И не ЭтоКомментарий И не ЭтоСтрока И не ЭтоСлужебный Тогда
			// сброс токена
			ПеренестиТекущийТокенВМассивТокенов(Токены,ТекущийТокен,ТипПред,КлючевыеСлова);
		КонецЕсли;	      
		
        ТекущийТокен = ТекущийТокен + Символ;
		
		СимволПред=Символ;
		ТипПред=Тип;
		Индекс=Индекс+1;
	КонецЦикла;              
	
	//
	
	Если ТекущийТокен <> "" Тогда                     
		//сброс токена
		Если ЭтоКомментарий Тогда
			//фиксируем конец комментари
			ТипПред=2;
		ИначеЕсли ЭтоСлужебный Тогда	
			// фиксируем конец служебного слова
			ТипПред=6;
		КонецЕсли;	
		ПеренестиТекущийТокенВМассивТокенов(Токены,ТекущийТокен,ТипПред,КлючевыеСлова);
    КонецЕсли;
    
    Возврат Токены;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции  

Функция УточнитьТипТокена(Токен,Тип,КлючевыеСлова) 
	//лишний символ ВК в токене, появляется при переносе из редактора 
	//Токен=СтрЗаменить(Токен,Символы.ВК,""); 
	ТокенНрег=нрег(Токен);
	Если КлючевыеСлова.Найти(ТокенНрег)<>Неопределено И Тип<>4 Тогда	
		//меняем тип токена
		//4-ключевой токен
		Тип=4;
	КонецЕсли;	
	Возврат Тип;
КонецФункции

Функция КоректировкаТокена(КорректируеиыйТокен)
	КорректируеиыйТокен=СтрЗаменить(КорректируеиыйТокен,Символы.ПС,"<br>");
	//КорректируеиыйТокен=СтрЗаменить(КорректируеиыйТокен," ","&nbsp;");     
	КорректируеиыйТокен=СтрЗаменить(КорректируеиыйТокен,Символы.Таб,"&nbsp;&nbsp;&nbsp;&nbsp;"); 
	//КорректируеиыйТокен=СтрЗаменить(КорректируеиыйТокен,Символы.Таб,"&#9;"); 
	Возврат КорректируеиыйТокен;
КонецФункции

Процедура ПеренестиТекущийТокенВМассивТокенов(Токены,ТекущийТокен,ТипПред,КлючевыеСлова)
	ТипПред=УточнитьТипТокена(ТекущийТокен,ТипПред,КлючевыеСлова);
	ТекущийТокен=КоректировкаТокена(ТекущийТокен);
	Токены.Добавить( Новый Структура("Токен,Тип",ТекущийТокен,ТипПред));
	ТекущийТокен = "";
КонецПроцедуры

Функция РазборМногострочнойСтроки(ТекущийТокен) 
	// если есть символ многострочной строки
	Если СтрНайти(ТекущийТокен,Символы.ПС)>0 Тогда 
		//ТекущийТокен=СтрЗаменить(ТекущийТокен,Символы.ВК,""); 
		МассивТокенов=СтрРазделить(ТекущийТокен,Символы.ПС,Истина);
		РазмерМассиваТокенов=МассивТокенов.ВГраница();
		Буффер="";
		Для Счетчик=0 По РазмерМассиваТокенов Цикл
			Токен=МассивТокенов[Счетчик];
			Буффер=Буффер+Токен+?(Счетчик<РазмерМассиваТокенов,"<br>","");
		КонецЦикла;
	Иначе 
		Буффер=ТекущийТокен;
	КонецЕсли;	
	Возврат Буффер;
	
КонецФункции

Функция ОформитьКлючевоеСлово(Текст)
	Возврат "<span style='color: red'>" + Текст + "</span>";
КонецФункции

Функция ОформитьИдентификатор(Текст)
	Возврат "<span style='color: blue'>" + Текст + "</span>";
КонецФункции

Функция ОформитьСлужебныйТекст(Текст)
	Возврат "<span style='color: rgb(150, 50, 0)'>" + Текст + "</span>";
КонецФункции

Функция ОформитьЗначениеПоУмолчанию(Текст)
	Возврат "<span style='color: black'>" + Текст + "</span>";
КонецФункции

Функция ОформитьКомментарий(Текст)
	Возврат "<span style='color: green'>" + Текст + "</span>";
КонецФункции


Функция ПолучитьПоУмолчаниюСимволы()
	ПоУмолчаниюСимволы=Новый Массив;
	ПоУмолчаниюСимволы.Добавить("""");
	ПоУмолчаниюСимволы.Добавить("'");
	ПоУмолчаниюСимволы.Добавить("0");
	ПоУмолчаниюСимволы.Добавить("1");
	ПоУмолчаниюСимволы.Добавить("2");
	ПоУмолчаниюСимволы.Добавить("3");
	ПоУмолчаниюСимволы.Добавить("4");
	ПоУмолчаниюСимволы.Добавить("5");
	ПоУмолчаниюСимволы.Добавить("6");
	ПоУмолчаниюСимволы.Добавить("7");
	ПоУмолчаниюСимволы.Добавить("8");
	ПоУмолчаниюСимволы.Добавить("9");

	Возврат ПоУмолчаниюСимволы;
КонецФункции

Функция ПолучитьКлючевыеСимволы()
	КлючевыеСимволы=Новый Массив;
	КлючевыеСимволы.Добавить("=");
	КлючевыеСимволы.Добавить("+");
	КлючевыеСимволы.Добавить("-");
	КлючевыеСимволы.Добавить(";");
	КлючевыеСимволы.Добавить(".");
	КлючевыеСимволы.Добавить(",");
	КлючевыеСимволы.Добавить("/");
	КлючевыеСимволы.Добавить(">");
	КлючевыеСимволы.Добавить("<");
	КлючевыеСимволы.Добавить("(");
	КлючевыеСимволы.Добавить(")");
	КлючевыеСимволы.Добавить("[");
	КлючевыеСимволы.Добавить("]");
	Возврат КлючевыеСимволы;
КонецФункции

Функция ПолучитьКлючевыеСлова()
	КлючевыеСлова=Новый Массив;    
	КлючевыеСлова.Добавить("и");
	КлючевыеСлова.Добавить("или");
	КлючевыеСлова.Добавить("если");
	КлючевыеСлова.Добавить("тогда");
	КлючевыеСлова.Добавить("иначе");
	КлючевыеСлова.Добавить("иначеесли");
	КлючевыеСлова.Добавить("конецесли"); 
	КлючевыеСлова.Добавить("пока"); 
	КлючевыеСлова.Добавить("цикл"); 
	КлючевыеСлова.Добавить("конеццикла"); 
	КлючевыеСлова.Добавить("для"); 
	КлючевыеСлова.Добавить("каждого"); 
	КлючевыеСлова.Добавить("из"); 
	КлючевыеСлова.Добавить("новый"); 
	КлючевыеСлова.Добавить("неопределено"); 
	КлючевыеСлова.Добавить("истина"); 
	КлючевыеСлова.Добавить("ложь"); 
	КлючевыеСлова.Добавить("процедура"); 
	КлючевыеСлова.Добавить("конецпроцедуры"); 
	КлючевыеСлова.Добавить("функция"); 
	КлючевыеСлова.Добавить("возврат"); 
	КлючевыеСлова.Добавить("конецфункции"); 
	КлючевыеСлова.Добавить("экспорт"); 
	КлючевыеСлова.Добавить("попытка"); 
	КлючевыеСлова.Добавить("исключение"); 
	КлючевыеСлова.Добавить("конецпопытки");
	КлючевыеСлова.Добавить("вызватьисключение");
	КлючевыеСлова.Добавить("перем"); 
	Возврат КлючевыеСлова;
КонецФункции


#КонецОбласти
	
#КонецЕсли
	
	