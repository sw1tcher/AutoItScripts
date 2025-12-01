#include <GUIConstantsEx.au3>

#Region ;**** КОНСТАНТЫ И WMI ФУНКЦИИ ****

Global $idCmbPrinter
Global $idBtnSet
Global $idLblCurrent

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

Func _GetCurrentDefaultPrinter()
    Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
    If @error Then Return "Ошибка WMI"
    
    Local $oPrinter = $oWMIService.ExecQuery("Select * from Win32_Printer Where Default = TRUE")
    
    For $p In $oPrinter
        Return $p.Name
    Next
    Return "Не определён"
EndFunc

Func _GetPrinterList()
    Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
    If @error Then Return SetError(1, 0, 0)
    
    Local $colPrinters = $oWMIService.ExecQuery("Select Name from Win32_Printer")
    Local $aPrinterNames[1] = [""]

    If IsObj($colPrinters) Then
        For $oPrinter In $colPrinters
            _ArrayAdd($aPrinterNames, $oPrinter.Name)
        Next
    EndIf

    If UBound($aPrinterNames) > 1 Then
        _ArrayDelete($aPrinterNames, 0)
        Return $aPrinterNames
    EndIf

    Return SetError(2, 0, 0)
EndFunc

Func _ArrayAdd(ByRef $aArray, $vValue)
    Local $iUBound = UBound($aArray)
    ReDim $aArray[$iUBound + 1]
    $aArray[$iUBound] = $vValue
EndFunc

Func _ArrayDelete(ByRef $aArray, $iIndex)
    Local $iUBound = UBound($aArray)
    If $iIndex < 0 Or $iIndex >= $iUBound Then Return SetError(1, 0, 0)
    
    Local $aNewArray[$iUBound - 1]
    Local $j = 0
    For $i = 0 To $iUBound - 1
        If $i <> $iIndex Then
            $aNewArray[$j] = $aArray[$i]
            $j += 1
        EndIf
    Next
    $aArray = $aNewArray
    Return 1
EndFunc

#EndRegion

#Region ;**** GUI И ЛОГИКА ****

Local $hGUI = GUICreate("Временное переключение принтера", 430, 210)

GUICtrlCreateLabel("Текущий принтер по умолчанию:", 20, 20, 380, 20)
$idLblCurrent = GUICtrlCreateLabel(_GetCurrentDefaultPrinter(), 20, 40, 380, 20)
GUICtrlSetFont($idLblCurrent, 10, 800)

GUICtrlCreateLabel("Выберите временный принтер:", 20, 75, 380, 20)
$idCmbPrinter = GUICtrlCreateCombo("", 20, 95, 380, 25)

$idBtnSet = GUICtrlCreateButton("ИСПОЛЬЗОВАТЬ ВРЕМЕННО И ВЕРНУТЬ НАЗАД", 20, 135, 380, 40)

; --- Заполнение списка ---
Local $aPrinters = _GetPrinterList()
If IsArray($aPrinters) Then
    Local $sList = ""
    For $i = 0 To UBound($aPrinters) - 1
        If $i > 0 Then $sList &= "|"
        $sList &= $aPrinters[$i]
    Next

    Local $sCurrent = _GetCurrentDefaultPrinter()
    GUICtrlSetData($idCmbPrinter, $sList, $sCurrent)
Else
    GUICtrlSetData($idCmbPrinter, "Принтеры не найдены.", "")
EndIf

GUISetState(@SW_SHOW, $hGUI)

While 1
    Local $iMsg = GUIGetMsg()

    Select
        Case $iMsg = $GUI_EVENT_CLOSE
            ExitLoop

        Case $iMsg = $idBtnSet
            Local $sSelectedPrinter = GUICtrlRead($idCmbPrinter)

            If StringLen($sSelectedPrinter) = 0 Or $sSelectedPrinter = "Принтеры не найдены." Then
                MsgBox(48, "Внимание", "Пожалуйста, выберите принтер из списка.")
                ContinueLoop
            EndIf

            ; --- Сохраняем предыдущий ---
            Local $sOldPrinter = _GetCurrentDefaultPrinter()
            If $sOldPrinter = "Ошибка WMI" Or $sOldPrinter = "Не определён" Then
                MsgBox(16, "Ошибка", "Не удалось определить текущий принтер по умолчанию.")
                ContinueLoop
            EndIf

            ; --- Переключаемся на временный ---
            If Not _SetDefaultPrinter($sSelectedPrinter) Then
                MsgBox(16, "Ошибка", "Не удалось установить временный принтер: " & $sSelectedPrinter)
                ContinueLoop
            EndIf

            GUICtrlSetData($idLblCurrent, $sSelectedPrinter)

            ; >>> ЛЮБОЕ ПРОСТОЕ ДЕЙСТВИЕ <<<
            MsgBox(64, "Временный принтер установлен", _
                "Временный принтер: " & $sSelectedPrinter & @CRLF & _
                "Предыдущий принтер: " & $sOldPrinter & @CRLF & @CRLF & _
                "Нажмите OK, чтобы вернуть старый принтер.")
            ; <<< КОНЕЦ ДЕЙСТВИЯ >>>

            ; --- Возвращаем назад ---
            If _SetDefaultPrinter($sOldPrinter) Then
                GUICtrlSetData($idLblCurrent, $sOldPrinter)
                MsgBox(64, "Восстановлено", "Принтер по умолчанию восстановлен: " & $sOldPrinter)
            Else
                MsgBox(16, "Ошибка", "Временный принтер был установлен, но не удалось восстановить предыдущий: " & $sOldPrinter)
            EndIf
    EndSelect
WEnd

#EndRegion
