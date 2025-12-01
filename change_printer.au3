#Region ;**** КОНСТАНТЫ И ФУНКЦИИ WMI ****

; --- Настройки ---
Global Const $sTargetPrinter = "Microsoft Print to PDF" ; *** ИМЯ ВАШЕГО ЦЕЛЕВОГО ПРИНТЕРА ***
Global Const $sConfigFile = @ScriptDir & "\default_printer.ini"

; --- ID элементов GUI ---
Global Const $idBtnSet = 1000 ; ID для кнопки "Виртуальный принтер"
Global Const $idBtnRestore = 1001 ; ID для кнопки "Восстановить принтер"

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

#EndRegion

#Region ;**** ОСНОВНАЯ ЛОГИКА (ФУНКЦИИ ОБРАБОТКИ) ****

; --- Логика установки целевого принтера (Скрипт 1) ---
Func PreparePrinterForCapture()
    ; 1. Получаем текущий принтер по умолчанию
    Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
    Local $oPrinter = $oWMIService.ExecQuery("Select * from Win32_Printer Where Default = TRUE")
    
    Local $sOldDefaultPrinter = ""
    For $p In $oPrinter
        $sOldDefaultPrinter = $p.Name
        ExitLoop
    Next

    If $sOldDefaultPrinter = "" Then
        MsgBox(16, "Ошибка", "Текущий принтер не определен.")
        Return
    EndIf

    ; 2. Сохраняем имя старого принтера в INI-файл
    IniWrite($sConfigFile, "Printer", "Original", $sOldDefaultPrinter)

    ; 3. Устанавливаем новый принтер
    If _SetDefaultPrinter($sTargetPrinter) Then
        MsgBox(64, "Успех", "Принтер изменен на: " & $sTargetPrinter & @CRLF & "Теперь можно запускать печать.")
    Else
        MsgBox(16, "Ошибка", "Не удалось установить целевой принтер: " & $sTargetPrinter & @CRLF & "Проверьте его имя.")
    EndIf
EndFunc

; --- Логика восстановления принтера (Скрипт 2) ---
Func RestorePrinterAfterCapture()
    ; 1. Читаем имя оригинального принтера из INI-файла
    Local $sOriginalPrinter = IniRead($sConfigFile, "Printer", "Original", "")

    If $sOriginalPrinter = "" Then
        MsgBox(16, "Ошибка", "Не найден сохраненный принтер. Восстановление невозможно.")
        Return
    EndIf

    ; 2. Восстанавливаем оригинальный принтер
    If _SetDefaultPrinter($sOriginalPrinter) Then
        MsgBox(64, "Успех", "Принтер по умолчанию восстановлен на: " & $sOriginalPrinter)
        ; 3. Удаляем INI-файл для очистки
        FileDelete($sConfigFile)
    Else
        MsgBox(16, "Ошибка", "Не удалось восстановить оригинальный принтер: " & $sOriginalPrinter & @CRLF & "Попробуйте восстановить его вручную.")
    EndIf
EndFunc

#EndRegion

#Region ;**** СОЗДАНИЕ GUI И ЦИКЛ ОБРАБОТКИ ****

; 1. Создание окна
Local $hGUI = GUICreate("Управление печатью: " & $sTargetPrinter, 350, 150)

; 2. Создание кнопок
GUICtrlCreateLabel("Текущий целевой принтер: " & $sTargetPrinter, 10, 10, 300, 20)
Local $idBtn1 = GUICtrlCreateButton("Виртуальный принтер (Подготовка)", 20, 40, 310, 35)
GUICtrlSetId($idBtn1, $idBtnSet)

Local $idBtn2 = GUICtrlCreateButton("Восстановить принтер (Очистка)", 20, 85, 310, 35)
GUICtrlSetId($idBtn2, $idBtnRestore)

; 3. Отображение окна
GUISetState(@SW_SHOW, $hGUI)

; 4. Цикл обработки событий
While 1
    Local $iMsg = GUIGetMsg()
    
    Select $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop
            
        Case $idBtnSet
            PreparePrinterForCapture()
            
        Case $idBtnRestore
            RestorePrinterAfterCapture()
            
    EndSelect
WEnd

#EndRegion