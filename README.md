# 1CtoTFSScript
plugin for AutoHotkey for opening links by identifier from the 1C configurator

Идея публикации - расширяем конфигуратор для произвольной задачи. Показать, что это несложно, доступно и широко применимо
Предисловие: стандарт документирования кода в нашей организации обязывает вставлять метки-идентификаторы задачи непосредственно в код 1С, а также в поле "Комментарий" к новым объектам. Удобство такого подхода никому доказывать не нужно. Что делает разработчик, когда видит такую метку? Выделяет идентификатор, ctrl+c, открывает учетную систему, поиск, ctrl+v, открывается веб-страничка... И так для каждой метки. При обновлении конфы можно запариться. А что если делать всё это хоткеем?

Но ведь API конфигуратора 1с закрыт, скажете вы (неслышавшие про опенконф и снегопат). Пользующиеся снегопатом пойдут писать скрипт для снегопата. Знающие про удобство и простоту AutoHotkey пойдут писать скрипт под него.

И отправят коллегу писать веб-сервис в системе учета задач =)

Всё ниженаписанное предназначено в основном для тех, кто не писал раньше подобный скрипт для конфигуратора (я начинал с нуля).

Инструментарий: AutoHotkey (free), блокнот для написания JavaScript, браузер для его тестирования. JavaScript тут нужен для расширения возможностей AutoHotkey в плане вызова веб-сервиса.

Забегая вперед скажу, что AHK нужен только для написания и отладки, потом его можно смело удалять, и скрипт продолжит работать без него.

Итак, ознакомьтесь с документацией AHK на русском тут.

Скачали AHK, запускаем скрипт KeyCodes.ahk (есть во вложении) для определения скан-кода горячей клавиши. Ну и пишем код соответственно задаче. Язык AHK похож на основные языки программирования.

Далее просто приведу мой скрипт с комментариями:

return


!sc21:: ; alt+F - сканкод (!-alt <span>и sc21-f)</span>
AutoTrim On ; Не Сохраняет любой межстрочный интервал и пробел в конце текстовой строки в буфере обмена.
ClipboardOld = %ClipboardAll%; переменная буфера обмена
Clipboard = ; Чтобы обнаружение заработало, нужно начать с пустого значения.
Send ^{sc2E} ; имитация нажатия CTRL+C
ClipWait 1 ; обработчик ожидания
if ErrorLevel ; Время ожидания ClipWait вышло.
    return
;
IfInString, Clipboard, rfc - ищем в строке кодовую метку "rfc"
{
StringReplace, Clipboard, Clipboard, rfc, RFC, All - если есть "rfc", то заменяем на "RFC" (разработчик может ошибиться и написать как ему удобно, но стандарт предписывает писать в верхнем регистре)
}
StringGetPos, pos, Clipboard, RFC - определяем позицию начала метки
;
StringTrimLeft, Clipboard, Clipboard, pos - образаем всё, что слева от нее
;
Result := StrLen(Clipboard) - вычисляем длину оставшейся строки
;
ResultTr := Result - 10 - вычисляем сколько нужно отрезать справа (метка всегда состоит из 10 символов)
;

StringTrimRight, RFC, Clipboard, ResultTr - образаем всё справа
;

RunWait, wscript.exe JSrfc.js %RFC% - запускаем JavaScript, передаем ему параметр (метку вида RFC-000001)
;
FileRead, newText, tmp\result.tmp - ответ от веб-сервиса JS пишет в промежуточный файл, читаем его
ClipWait, 1
Clipboard := newText - помещаем прочитанное в буфер обмена
ClipWait, 1

if (Clipboard = "http://tfs_server/NOT_FOUND") {
MsgBox, Ошибка: задача не найдена! - выводим окно с ошибкой
}
else {
try {
    Run, %Clipboard%, , max - открываем http-ссылку на задачу (запустится веб-браузер, назначенный по умолчанию)
} catch e {
}
}
return
;
Теперь раскажу, что мне понадобилось для написания вызова веб-сервиса из JS.

Вначале мы протестируем веб-сервис и заодно получим структуру Soap-запроса. Очень удобно это делать с помощью SoapUI.

Тестирование и отладку JS в основном делал в IE11, тк FireBug в мозилле неверно интерпретировал ошибку, из-за чего было убито много времени на решение несуществующей проблемы.

Ниже код JS с комментариями:

function Run() //главная функция
{
arg=WScript.Arguments; //тут как раз содержатся передаваемые параметры

            var xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); //создается объект XMLHTTP
           
            var sr = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v="http://адрес/omniintegration/v1"><soapenv:Header/><soapenv:Body><v:GetLinksToWIOneS><v:RfcId>'
+arg(0)+ 
'</v:RfcId></v:GetLinksToWIOneS></soapenv:Body></soapenv:Envelope>'; //формируется заголовок SOAP

            // Send the POST request

            xmlhttp.open('POST', 'http://адрес/TfsIntegrationService.svc', false); //тут обязательно указываем False - запрос должен быть синхронный
            xmlhttp.setRequestHeader('Content-Type', 'text/xml; charset=utf-8');
xmlhttp.setRequestHeader('SOAPAction', 'http://адрес/ITfsIntegrationService/GetLinksToWIOneS'); //устанавливаем заголовок SOAPAction
            xmlhttp.send(sr); //отсылаем запрос
      
  
     if(xmlhttp.status == 200) { //если сервер вернул ОК
       elements = xmlhttp.responseXML.getElementsByTagName('GetLinksToWIOneSResult'); //разбираем XML по тегам

wtiteToResultFile("tmp/result.tmp",elements[0].text); //результат пишем в файл
         }
  }

var fso = new ActiveXObject("Scripting.FileSystemObject");

function wtiteToResultFile(file_name, file_data) {//тут всё примитивно
    f = fso.CreateTextFile(file_name, true);
    f.Write(file_data);
    f.Close();
}

Run();//запускает главную функцию при открытии скрипта
Итак, что мы получаем: 3 файла, из файла *.ahk можно скомпилировать exe-шник и поместить его в автозапуск. Работает исправно, ОЗУ съедает около 3 Мб.

Никакие файлы не заменяли, никакие DLL не регистрировали. Обновим платформу - всё продолжит работать.
