#include-once
#include <WinAPI.au3>


Func Matrix($nRow, $nCol)

	Local $Matrix[$nRow][$nCol]

	Return $Matrix
EndFunc

Func MatrixFromArray($mArray)
	If UBound($mArray) = 0  Then Return SetError(-1, 0, -1)

	$Matrix = Matrix(UBound($mArray), 1)

	For $iRow = 0 To UBound($mArray) - 1
		$Matrix[$iRow][0] = $mArray[$iRow]
	Next

	Return $Matrix
EndFunc

Func MatrixToArray($Matrix)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	Local $aResult[$nRow * $nCol]

	$i = 0
	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$aResult[$i] = $Matrix[$iRow][$iCol]
			$i += 1
		Next
	Next

	Return $aResult
EndFunc

Func _MatrixRandomize(ByRef $Matrix, $min = 0, $max = 10, $type = 1)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)

	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$Matrix[$iRow][$iCol] = Random($min, $max, $type)
		Next
	Next
EndFunc

Func _MatrixRandomRate(ByRef $Matrix, $iRate)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	$result = Matrix($nRow, $nCol)
	For $iRow = 0 To $nRow - 1

		For $iCol = 0 To $nCol - 1

			$result[$iRow][$iCol] = $Matrix[$iRow][$iCol]

			If Random(0, 1) <= $iRate Then
				; crucial
				If Random(0, 1) <= $iRate Then
					$Matrix[$iRow][$iCol] = Random(-1, 1)
				Else
					$delta = Random(- $Matrix[$iRow][$iCol] * 0.1, $Matrix[$iRow][$iCol] * 0.1)
					$Matrix[$iRow][$iCol] += $delta
				EndIf
			EndIf
		Next
	Next
	Return $result
EndFunc

Func MatrixTranspose($Matrix)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)

	Local $rMatrix = Matrix($nCol, $nRow)

	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$rMatrix[$iCol][$iRow] = $Matrix[$iRow][$iCol]
		Next
	Next

	Return $rMatrix

EndFunc

Func _MatrixTranspose(ByRef $Matrix)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)

	Local $rMatrix = Matrix($nCol, $nRow)

	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$rMatrix[$iCol][$iRow] = $Matrix[$iRow][$iCol]
		Next
	Next

	$Matrix =  $rMatrix

EndFunc


Func _MatrixAdd(ByRef $Matrix, $Add)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	If __CheckMatrix($Add) Then

		For $iRow = 0 To $nRow - 1
			For $iCol = 0 To $nCol - 1
				$Matrix[$iRow][$iCol] += $Add[$iRow][$iCol]
			Next
		Next
	Else

		For $iRow = 0 To $nRow - 1
			For $iCol = 0 To $nCol - 1
				$Matrix[$iRow][$iCol] += $Add
			Next
		Next
	EndIf
EndFunc

Func _MatrixMultiply(ByRef $Matrix, $Add)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	If __CheckMatrix($Add) Then

		For $iRow = 0 To $nRow - 1
			For $iCol = 0 To $nCol - 1
				$Matrix[$iRow][$iCol] *= $Add[$iRow][$iCol]
			Next
		Next
	Else

		For $iRow = 0 To $nRow - 1
			For $iCol = 0 To $nCol - 1
				$Matrix[$iRow][$iCol] *= $Add
			Next
		Next
	EndIf
EndFunc


Func _MatrixMultiplyW(ByRef $Matrix, $Add)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	If __CheckMatrix($Add) Then

		For $iRow = 0 To $nRow - 1
			For $iCol = 0 To $nCol - 1
				$Matrix[$iRow][$iCol] *= $Add[$iRow][0]
			Next
		Next

	EndIf
EndFunc

Func MatrixMultiplyW($Matrix, $Add)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	$result = Matrix($nRow, 1)
	If __CheckMatrix($Add) Then

		For $iRow = 0 To $nRow - 1

			$sum = 0
			For $iCol = 0 To $nCol - 1
				$sum += $Matrix[$iRow][$iCol] * $Add[$iCol][0]
			Next
			$result[$iRow][0] = $sum
		Next
	EndIf

	Return $result
EndFunc

Func MatrixMultiply($Matrix, $Add)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)
	If UBound($Matrix, 2) <> UBound($Add) Then Return SetError (-1, 0, -2)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	$nColAdd = UBound($Add, 2)
	Local $result = Matrix($nRow, $nColAdd)

	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nColAdd - 1

			$sum = 0
			For $i = 0 To $nCol - 1
				$sum += $Matrix[$iRow][$i] * $Add[$i][$iCol]
			Next
			$result[$iRow][$iCol] = $sum
		Next
	Next

	Return $result
EndFunc

Func _MatrixColSum(ByRef $Matrix)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	Local $result[1][$nCol]
	For $iCol = 0 To $nCol - 1
		$sum = 0
		For $iRow = 0 To $nRow - 1
			$sum += $Matrix[$iRow][$iCol]
		Next
		$result[0][$iCol] = $sum
	Next
	$Matrix = $result
EndFunc

Func MatrixDivideSumW($Matrix)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	Local $result = Matrix($nRow, $nCol)

	For $iRow = 0 To $nRow - 1
		$sum = 0
		For $iCol = 0 To $nCol - 1
			$sum += $Matrix[$iRow][$iCol]
		Next
		For $iCol = 0 To $nCol - 1
			$result[$iRow][$iCol] = $Matrix[$iRow][$iCol] / $sum
		Next
	Next

	Return $result
EndFunc

Func MatrixSubtract($Matrix, $Add)
	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	$result = Matrix($nRow, $nCol)

	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$result[$iRow][$iCol] = $Matrix[$iRow][$iCol] - $Add[$iRow][$iCol]
		Next
	Next

	Return $result
EndFunc

Func _MatrixSub(ByRef $Matrix, $Sub)

	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)

	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$Matrix[$iRow][$iCol] -= $Sub[$iRow][$iCol]
		Next
	Next

EndFunc

Func _MatrixMap(ByRef $Matrix, $Func)

	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$Matrix[$iRow][$iCol] = Call($Func, $Matrix[$iRow][$iCol])
		Next
	Next

EndFunc

Func MatrixMap($Matrix, $Func)

	If __CheckMatrix($Matrix) = False Then Return SetError (-1, 0, -1)

	$nRow = UBound($Matrix)
	$nCol = UBound($Matrix, 2)
	Local $result = Matrix($nRow, $nCol)

	For $iRow = 0 To $nRow - 1
		For $iCol = 0 To $nCol - 1
			$result[$iRow][$iCol] = Call($Func, $Matrix[$iRow][$iCol])
		Next
	Next

	Return $result
EndFunc

Func __CheckMatrix($Matrix)
	If IsArray($Matrix) = False Or UBound($Matrix) = 0 Or UBound($Matrix, 2) = 0  Then Return False
	Return True
EndFunc
