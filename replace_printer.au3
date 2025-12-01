; =========================================
; Скрипт 1: УСТАНОВКА ЦЕЛЕВОГО ПРИНТЕРА
; =========================================

Local Const $sConfigFile = @ScriptDir & "\default_printer.ini"
; *** ИМЯ ВАШЕГО ЦЕЛЕВОГО ВИРТУАЛЬНОГО ПРИНТЕРА ***
Local Const $sTargetPrinter = "Microsoft Print to PDF" 

; --- Функция WMI для установки принтера по умолчанию ---
Func _SetDefaultPrinter($sPrinterName)
    Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
    If @error Then Return False
    
    Local $colPrinters = $oWMIService.ExecQuery("Select * from Win32_Printer Where Name = '" & $sPrinterName & "'")
    
    If IsObj($colPrinters) Then
        For $oPrinter In $colPrinters
            ; SetDefaultPrinter возвращает 0 при успехе
            If $oPrinter.SetDefaultPrinter() = 0 Then 
                Return True
            EndIf
            ExitLoop
        Next
    EndIf
    Return False
EndFunc

; --- Основная логика ---

; 1. Получаем текущий принтер по умолчанию
Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
Local $oPrinter = $oWMIService.ExecQuery("Select * from Win32_Printer Where Default = TRUE")

Local $sOldDefaultPrinter = ""
For $p In $oPrinter
    $sOldDefaultPrinter = $p.Name
    ExitLoop
Next

If $sOldDefaultPrinter = "" Then
    MsgBox(16, "Ошибка", "Текущий принтер не определен. Выход.")
    Exit
EndIf

; 2. Сохраняем имя старого принтера в INI-файл
IniWrite($sConfigFile, "Printer", "Original", $sOldDefaultPrinter)
ConsoleWrite("Старый принтер сохранен: " & $sOldDefaultPrinter & @CRLF)

; 3. Устанавливаем новый принтер
If _SetDefaultPrinter($sTargetPrinter) Then
    MsgBox(64, "Успех", "Принтер успешно изменен на: " & $sTargetPrinter & @CRLF & "Теперь можно запускать печать.")
Else
    MsgBox(16, "Ошибка", "Не удалось установить целевой принтер: " & $sTargetPrinter & @CRLF & "Проверьте его имя.")
EndIf

; *** ЗДЕСЬ МОЖНО ДОБАВИТЬ КОД, КОТОРЫЙ ТРИГГЕРИТ ПЕЧАТЬ В ВАШЕЙ СТАРОЙ ПРОГРАММЕ *** ; (WinActivate, Send("^p"), и автоматизация диалога "Сохранить как")