
return


!sc21:: ; alt+F - найти задачу по RFC
AutoTrim On ; Не Сохраняет любой межстрочный интервал и пробел в конце текстовой строки в буфере обмена.
ClipboardOld = %ClipboardAll%
Clipboard = ; Чтобы обнаружение заработало, нужно начать с пустого значения.
Send ^{sc2E}
ClipWait 1
if ErrorLevel ; Время ожидания ClipWait вышло.
	return
;
IfInString, Clipboard, rfc
{
StringReplace, Clipboard, Clipboard, rfc, RFC, All
}
StringGetPos, pos, Clipboard, RFC
;
StringTrimLeft, Clipboard, Clipboard, pos
;
Result := StrLen(Clipboard)
;
ResultTr := Result - 10
;

StringTrimRight, RFC, Clipboard, ResultTr
;

RunWait, wscript.exe JSrfc.js %RFC%
;
FileRead, newText, tmp\result.tmp
ClipWait, 1
Clipboard := newText
ClipWait, 1

if (Clipboard = "http://tfs_server/NOT_FOUND") {
MsgBox, Ошибка: ЗНИ не найдена!
}
else {
try {
    Run, %Clipboard%, , max
} catch e {
}
}
return
;
