; =========================================
; Скрипт 2: ВОССТАНОВЛЕНИЕ ПРИНТЕРА
; =========================================

Local Const $sConfigFile = @ScriptDir & "\default_printer.ini"

; --- Функция WMI для установки принтера по умолчанию ---
Func _SetDefaultPrinter($sPrinterName)
    Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
    If @error Then Return False
    
    Local $colPrinters = $oWMIService.ExecQuery("Select * from Win32_Printer Where Name = '" & $sPrinterName & "'")
    
    If IsObj($colPrinters) Then
        For $oPrinter In $colPrinters
            If $oPrinter.SetDefaultPrinter() = 0 Then
                Return True
            EndIf
            ExitLoop
        Next
    EndIf
    Return False
EndFunc

; --- Основная логика ---

; 1. Читаем имя оригинального принтера из INI-файла
Local $sOriginalPrinter = IniRead($sConfigFile, "Printer", "Original", "")

If $sOriginalPrinter = "" Then
    MsgBox(16, "Ошибка", "Не найден сохраненный принтер в файле: " & $sConfigFile & @CRLF & "Возможно, Скрипт 1 не был запущен.")
    Exit
EndIf

; 2. Восстанавливаем оригинальный принтер
If _SetDefaultPrinter($sOriginalPrinter) Then
    MsgBox(64, "Успех", "Принтер по умолчанию восстановлен на: " & $sOriginalPrinter)
    
    ; 3. Удаляем INI-файл для очистки
    FileDelete($sConfigFile)
Else
    MsgBox(16, "Ошибка", "Не удалось восстановить оригинальный принтер: " & $sOriginalPrinter & @CRLF & "Попробуйте восстановить его вручную.")
EndIf