
return


!sc21:: ; alt+F - ����� ������ �� RFC
AutoTrim On ; �� ��������� ����� ����������� �������� � ������ � ����� ��������� ������ � ������ ������.
ClipboardOld = %ClipboardAll%
Clipboard = ; ����� ����������� ����������, ����� ������ � ������� ��������.
Send ^{sc2E}
ClipWait 1
if ErrorLevel ; ����� �������� ClipWait �����.
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
MsgBox, ������: ��� �� �������!
}
else {
try {
    Run, %Clipboard%, , max
} catch e {
}
}
return
;
