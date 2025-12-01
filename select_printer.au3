#include <GUIConstantsEx.au3>

#Region ;**** КОНСТАНТЫ И WMI ФУНКЦИИ ****

; --- Глобальные ID элементов ---
Global $idCmbPrinter
Global $idBtnSet
Global $idLblCurrent

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

; --- Функция WMI для получения текущего принтера по умолчанию ---
Func _GetCurrentDefaultPrinter()
    Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
    If @error Then Return "Ошибка WMI"
    
    Local $oPrinter = $oWMIService.ExecQuery("Select * from Win32_Printer Where Default = TRUE")
    
    For $p In $oPrinter
        Return $p.Name
    Next
    Return "Не определен"
EndFunc

; --- Функция WMI для получения списка всех принтеров ---
Func _GetPrinterList()
    Local $oWMIService = ObjGet("winmgmts:\\.\root\cimv2")
    If @error Then Return SetError(1, 0, 0)
    
    Local $colPrinters = $oWMIService.ExecQuery("Select Name from Win32_Printer")
    Local $aPrinterNames[1] = [""] ; временный первый элемент
    
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

; --- Массив: добавить элемент ---
Func _ArrayAdd(ByRef $aArray, $vValue)
    Local $iUBound = UBound($aArray)
    ReDim $aArray[$iUBound + 1]
    $aArray[$iUBound] = $vValue
EndFunc

; --- Массив: удалить элемент ---
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

; --- Создание окна ---
Local $hGUI = GUICreate("Выбор принтера по умолчанию", 400, 200)

; --- Элементы интерфейса ---
GUICtrlCreateLabel("Текущий принтер:", 20, 20, 360, 20)
$idLblCurrent = GUICtrlCreateLabel(_GetCurrentDefaultPrinter(), 20, 40, 360, 20)
GUICtrlSetFont($idLblCurrent, 10, 800)

GUICtrlCreateLabel("Выберите новый принтер:", 20, 75, 360, 20)
$idCmbPrinter = GUICtrlCreateCombo("", 20, 95, 360, 25)

$idBtnSet = GUICtrlCreateButton("УСТАНОВИТЬ ПО УМОЛЧАНИЮ", 20, 135, 360, 40)

; --- Заполнение списка принтеров ---
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

; --- Показ окна ---
GUISetState(@SW_SHOW, $hGUI)

; --- Цикл обработки событий ---
While 1
    Local $iMsg = GUIGetMsg()

    Select
        Case $iMsg = $GUI_EVENT_CLOSE
            ExitLoop

        Case $iMsg = $idBtnSet
            Local $sSelectedPrinter = GUICtrlRead($idCmbPrinter)

            If StringLen($sSelectedPrinter) > 0 And $sSelectedPrinter <> "Принтеры не найдены." Then
                If _SetDefaultPrinter($sSelectedPrinter) Then
                    MsgBox(64, "Успех", "Принтер по умолчанию изменён на: " & $sSelectedPrinter)
                    GUICtrlSetData($idLblCurrent, $sSelectedPrinter)
                Else
                    MsgBox(16, "Ошибка", "Не удалось установить принтер. Возможно, нужны права администратора.")
                EndIf
            Else
                MsgBox(48, "Внимание", "Сначала выбери принтер из списка.")
            EndIf
    EndSelect
WEnd

#EndRegion
