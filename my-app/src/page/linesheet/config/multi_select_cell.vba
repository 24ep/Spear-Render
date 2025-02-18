Private Sub Worksheet_Change(ByVal Target As Range)
    Dim wb As Workbook
    Dim ws_linesheet As Worksheet
        Set wb = ActiveWorkbook
        Set ws_linesheet = ActiveWorkbook.Worksheets("IM_FORM")
        Dim Oldvalue As String
        Dim Newvalue As String
        Dim arr_sh() As Boolean
        Dim strArray() As String
        Dim multi_att_se() As String
        Dim select_att As String
        Dim category_label As Integer
        Dim category_label_loop As Integer
        Dim category_label_loop_down As Integer
        Dim logic_first As Integer
        Dim department_column As Integer
        Dim pr_department_column As Integer
Exitsub:
        Application.EnableEvents = True
    '----------end multi select storestock
    '------------old function
        ' Developed by Contextures Inc.
    ' www.contextures.com
        Dim rngDV As Range
        Dim oldVal As String
        Dim newVal As String
        Dim bu As String
        Dim i As Integer
        Dim lUsed  As Integer
        If Target.Count > 1 Then GoTo exitHandler
        On Error Resume Next
        Set rngDV = Cells.SpecialCells(xlCellTypeAllValidation)
        On Error GoTo exitHandler
        If rngDV Is Nothing Then GoTo exitHandler
        If Intersect(Target, rngDV) Is Nothing Then
           'do nothing
        Else
            If Target.Validation.Type = 3 Then 'Is list validation
              Application.EnableEvents = False
              newVal = Target.value
              Application.Undo
              oldVal = Target.value
              Target.value = newVal
              Target.Locked = True
              Dim chkCol As Boolean
              For i = 1 To 100
                  If InStr(1, Target.EntireColumn.Cells(i), "Multiple Select") > 0 Then
                      chkCol = True
                      Exit For
                  Else
                      chkCol = False
                  End If
              Next
              If chkCol = True Then
                  If oldVal = "" Then
                    'do nothing
                  Else
                      If newVal = "" Then
                      'do nothing
                      Else
                          lUsed = InStr(1, oldVal, newVal)
                          If lUsed > 0 Then
                              If Right(oldVal, Len(newVal)) = newVal Then
                                  Target.value = Left(oldVal, Len(oldVal) - Len(newVal) - 2)
                              Else
                                  Target.value = Replace(oldVal, newVal & ", ", "")
                              End If
                          Else
                              Target.value = oldVal _
                                  & ", " & newVal
                              '      NOTE: you can use a line break,
                              '      instead of a comma
                              '      Target.Value = oldVal _
                              '        & Chr(10) & newVal
                          End If
                      End If
                  End If
              End If
            End If
        End If
exitHandler:
      Application.EnableEvents = True
    '-----------------end old function
  Dim familyTemplateSheet As Worksheet
    Dim imFormSheet As Worksheet
    Dim imFormCategoriesRange As Range
    Dim imFormRange As Range
    Dim categoryColIndex As Long
    Dim categoryCell As Range
    Dim attributeRange As Range
    Dim category As String
    Dim attributesInFamily As String
    Dim attributesInIM As String
    Dim mismatch As Boolean
    Dim lastColumn As Long

    On Error Resume Next
    Set familyTemplateSheet = ThisWorkbook.Sheets("FAMILY_TEMPLATE")
    Set imFormSheet = ThisWorkbook.Sheets("IM_FORM")
    On Error GoTo 0

    If familyTemplateSheet Is Nothing Or imFormSheet Is Nothing Then Exit Sub ' Exit if sheets don't exist

    ' Find the column index of the "online_categories" header
    On Error Resume Next
    categoryColIndex = Application.WorksheetFunction.Match("online_categories", imFormSheet.Rows(1), 0)
    categoryColIndexSet = Application.WorksheetFunction.Match("categories", familyTemplateSheet.Rows(1), 0)
    On Error GoTo 0

    If categoryColIndex = 0 Then
        Debug.Print "Column 'online_categories' not found in IM_FORM sheet."
        Exit Sub ' Exit if "online_categories" header not found
    End If

    Debug.Print "Column 'online_categories' found at index: " & categoryColIndex
    Dim selectedRow As Long
    selectedRow = ActiveCell.Row

    Set imFormCategoriesRange = imFormSheet.Range(imFormSheet.Cells(selectedRow, categoryColIndex), imFormSheet.Cells(selectedRow, categoryColIndex))
    Set familyCategoriesRange = familyTemplateSheet.Range(familyTemplateSheet.Cells(2, categoryColIndexSet), familyTemplateSheet.Cells(familyTemplateSheet.Cells(familyTemplateSheet.Rows.Count, categoryColIndexSet).End(xlUp).Row, categoryColIndexSet))
    Set imFormRange = imFormSheet.Range("A2", imFormSheet.Cells(imFormSheet.Cells(imFormSheet.Rows.Count, imFormSheet.Columns.Count).End(xlUp).Row, imFormSheet.Columns.Count))

    Debug.Print "imFormCategoriesRange: " & imFormCategoriesRange.Address
    Debug.Print "imFormRange: " & imFormRange.Address

    Application.EnableEvents = False ' Prevent triggering events while making changes

    For Each categoryCell In imFormCategoriesRange.Cells
        category = categoryCell.value

        attributesInFamily = ""
        attributesInIM = ""
        mismatch = False
        If category <> "" Then

            Debug.Print "Processing category: " & category

            ' Find the attributes associated with the category in FAMILY_TEMPLATE
            Dim attributeColumnIndex As Long
            attributeColumnIndex = 0
            For i = 1 To familyTemplateSheet.Cells(1, familyTemplateSheet.Columns.Count).End(xlToLeft).Column

                If familyTemplateSheet.Cells(1, i).value = "categories" Then
                    attributeColumnIndex = i
                    Exit For
                End If
            Next i
            Debug.Print "attributeColumnIndex: " & attributeColumnIndex

            ' Find the attributes associated with the category in FAMILY_TEMPLATE
            Dim categoryRow As Range
            Set categoryRow = familyCategoriesRange.Find(category, LookIn:=xlValues, LookAt:=xlWhole)

            For j = 2 To 5
                If categoryRow Is Nothing Then
                   Debug.Print "skip: " & category
                Else
                    If attributeColumnIndex > 0 Then
                        attributesInFamily = familyTemplateSheet.Cells(familyCategoriesRange.Find(category).Row, j).value
                    End If

                    Debug.Print "attributesInFamily: " & attributesInFamily

                    ' Highlight cells in the current row based on attributesInFamily
                    If attributesInFamily <> "" Then
                        Dim attributesArray As Variant
                        attributesArray = Split(attributesInFamily, ",")

                        For Each att In attributesArray
                            Dim attributeColumn As Range
                            On Error Resume Next
                            Set attributeColumn = imFormRange.Rows(1).Find(att, LookIn:=xlValues, LookAt:=xlWhole)
                            On Error GoTo 0

                            If Not attributeColumn Is Nothing Then
                                If j = 3 Then
                                    If imFormSheet.Cells(categoryCell.Row, attributeColumn.Column) = "" Then
                                        imFormSheet.Cells(categoryCell.Row, attributeColumn.Column).Interior.Color = RGB(255, 143, 143) ' Highlight in r
                                    Else
                                        imFormSheet.Cells(categoryCell.Row, attributeColumn.Column).Interior.Color = RGB(255, 255, 255) ' Highlight in r
                                    End If
                                ElseIf j = 4 Then
                                    imFormSheet.Cells(categoryCell.Row, attributeColumn.Column).Interior.Color = RGB(255, 255, 255) ' Highlight in 0
                                ElseIf j = 5 Then
                                    imFormSheet.Cells(categoryCell.Row, attributeColumn.Column).Interior.Color = RGB(231, 231, 231) ' Highlight in AO
                                ElseIf j = 6 Then
                                    imFormSheet.Cells(categoryCell.Row, attributeColumn.Column).Interior.Color = RGB(231, 231, 231) ' Highlight in AR
                                ElseIf j = 7 Then
                                    imFormSheet.Cells(categoryCell.Row, attributeColumn.Column).Interior.Color = RGB(231, 231, 231) ' Highlight in AR
                                End If
                            End If
                        Next att
                    End If
                End If
            Next j
        End If
Skiptonextcategories:
    Next categoryCell

Application.EnableEvents = True ' Re-enable events

    End Sub
    Public Function FindColbo(rng As Range, srchVal As Variant) As Long
        Dim Found As Range
        With rng
            Set Found = .Find(What:=srchVal, _
                                LookIn:=xlValues, _
                                LookAt:=xlWhole, _
                                SearchOrder:=xlByRows, _
                                SearchDirection:=xlNext, _
                                MatchCase:=True)
        End With
        If Not Found Is Nothing Then
            FindColbo = Found.Column
        Else
            FindColbo = 0
        End If
    End Function
    Function IsInArray(stringToBeFound As String, arr As Variant) As Boolean
        IsInArray = Not IsError(Application.Match(stringToBeFound, arr, 0))
    End Function
    Public Function FindRow(rng As Range, srchVal As String) As Long
        Dim Found As Range
        With rng
            Set Found = .Find(What:=srchVal, _
                                LookIn:=xlValues, _
                                LookAt:=xlPart, _
                                SearchOrder:=xlByColumns, _
                                SearchDirection:=xlNext, _
                                MatchCase:=True)
        End With
        If Not Found Is Nothing Then
            FindRow = Found.Row
        Else
            FindRow = 0
        End If
    End Function
    Public Function FindCol(rng As Range, srchVal As String) As Long
        Dim Found As Range
        With rng
            Set Found = .Find(What:=srchVal, _
                                LookIn:=xlValues, _
                                LookAt:=xlPart, _
                                SearchOrder:=xlByRows, _
                                SearchDirection:=xlNext, _
                                MatchCase:=True)
        End With
        If Not Found Is Nothing Then
            FindCol = Found.Column
        Else
            FindCol = 0
        End If
    End Function
    Function lookupAtb(lookupSheet As Worksheet, value)
        Dim lookupRange As Range
        Dim valCol As Integer
        Set lookupRange = lookupSheet.Range("color_table")
        valCol = 2
        On Error Resume Next
        lookupAtb = Application.WorksheetFunction.VLookup(value, lookupRange, valCol, False)
        If Err.Number <> 0 Then
            lookupAtb = "N/A"
        End If
    End Function





