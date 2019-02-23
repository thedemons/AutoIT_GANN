#include <WinAPI.au3>
#include "Matrix.au3"

Func NN_Open($nInputs, $nOutputs, $nNodes = Default, $nHiddens = Default)

	$nNodes = $nNodes = Default ? Round( ($nInputs + $nOutputs) * (2 / 3) ) : $nNodes
	$nHiddens = $nHiddens = Default ? 1 : $nHiddens

	Local $NN[9]
	Local $Info[4] = [$nInputs, $nOutputs, $nNodes, $nHiddens]

	; install input and output neural
	$neuInput = Matrix($nInputs, 1)
	$neuOutput = Matrix($nOutputs, 1)

	; install input weights
	$wInput = Matrix($nNodes, $nInputs)
	$wInputBk = Matrix($nNodes, $nInputs)
	_MatrixRandomize($wInput, -1, 1, 0) ; set w at random

	Local $neuHidden[$nHiddens], $wHidden[$nHiddens], $wHiddenBk[$nHiddens]

	; install hidden weights
	For $iLayer = 0 To $nHiddens - 1

		$neuHidden[$iLayer] = Matrix($nNodes, 1)
		$wHidden[$iLayer] = Matrix( ($iLayer = $nHiddens - 1 ? $nOutputs : $nNodes), $nNodes)
		$wHiddenBk[$iLayer] = Matrix( ($iLayer = $nHiddens - 1 ? $nOutputs : $nNodes), $nNodes)
		_MatrixRandomize($wHidden[$iLayer], -1, 1, 0) ; set w at random

	Next

	;bias
	$bias = 1

	$NN[0] = $Info
	$NN[1] = $neuInput
	$NN[2] = $neuOutput
	$NN[3] = $neuHidden
	$NN[4] = $bias
	$NN[5] = $wInput
	$NN[6] = $wHidden
	$NN[7] = $wInputBk
	$NN[8] = $wHiddenBk
	Return $NN
EndFunc

Func NN_Close(ByRef $NN)
	$NN = Null
EndFunc

Func NN_Guess(ByRef $NN, $aInputs)

	If __CheckNN($NN) = False Then Return __SetError(-1)

	Local $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $nInputs, $wHiddenBk, $wInputBk, $nOutputs, $nNodes, $nHiddens
	NN_Info2Var($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

	If UBound($aInputs) <> $nInputs Then Return __SetError(-2)

	$neuInput = MatrixFromArray($aInputs)


	For $iLayer = 0 To $nHiddens - 1

		If $iLayer = 0 Then
			; input layer
			$neuHidden[ $iLayer ] = MatrixMultiplyW($wInput, $neuInput)
		Else
			; previous hidden layer
			$neuHidden[ $iLayer ] = MatrixMultiplyW( $wHidden[$iLayer - 1], $neuHidden[ $iLayer - 1 ])
		EndIf
		_MatrixAdd( $neuHidden[ $iLayer ], $bias)
		_MatrixMap( $neuHidden[ $iLayer ], __sigmoid)

	Next

	$neuOutput = MatrixMultiplyW($wHidden[$nHiddens - 1], $neuHidden[$nHiddens - 1])
	_MatrixAdd($neuOutput, $bias)
	_MatrixMap($neuOutput, __sigmoid)

	NN_Var2Info($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

	Return  MatrixToArray($neuOutput)

EndFunc

Func NN_AddNode(ByRef $NN, $number)

	If __CheckNN($NN) = False Then Return __SetError(-1)

	Local $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $nInputs, $wHiddenBk, $wInputBk, $nOutputs, $nNodes, $nHiddens
	NN_Info2Var($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

	$nNodes += $number

	ReDim $wInput[$nNodes][$nInputs]

	For $iRow = $nNodes - $number To $nNodes - 1 ; row

		For $iCol = 0 To $nInputs - 1

			$wInput[$iRow][$iCol] = Random(-1, 1)
		Next
	Next

	; add new node to hidden layer
	For $iLayer = 0 To $nHiddens - 1

		; new hidden value
		$tempArray = $neuHidden[$iLayer]
		ReDim $tempArray[$nNodes][1]
		$neuHidden[$iLayer] = $tempArray

		; new weights
		$tempArray = $wHidden[$iLayer]
		ReDim $tempArray[ ($iLayer = $nHiddens - 1 ? $nOutputs : $nNodes) ][$nNodes]

		; install new weights
		For $iRow = 0 To ($iLayer = $nHiddens - 1 ? $nOutputs : $nNodes) - 1 ; row

			For $iCol = $nNodes - $number To $nNodes - 1 ; col

				$tempArray[$iRow][$iCol] = Random(-1, 1)
			Next
		Next

		$wHidden[$iLayer] = $tempArray
	Next

	NN_Var2Info($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)
EndFunc

Func NN_DeleteNode(ByRef $NN, $number)

	If __CheckNN($NN) = False Then Return __SetError(-1)

	Local $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens
	NN_Info2Var($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

	If $nNodes <= 1 Then Return __SetError(-2)
	$nNodes -= $number
	ReDim $wInput[$nNodes][$nInputs]
	For $iLayer = 0 To $nHiddens - 1

		; new hidden value
		$tempArray = $neuHidden[$iLayer]
		ReDim $tempArray[$nNodes][1]
		$neuHidden[$iLayer] = $tempArray

		; new weights
		$tempArray = $wHidden[$iLayer]
		ReDim $tempArray[ ($iLayer = $nHiddens - 1 ? $nOutputs : $nNodes) ][$nNodes]

		$wHidden[$iLayer] = $tempArray
	Next

	NN_Var2Info($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)
EndFunc

Func NN_Mutate($NN, $iMutationRate)

	If __CheckNN($NN) = False Then Return __SetError(-1)

	Local $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens
	NN_Info2Var($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

	$wInputBk = _MatrixRandomRate($wInput, $iMutationRate)
	For $iLayer = 0 To $nHiddens - 1
		$wHiddenBk[$iLayer] = _MatrixRandomRate($wHidden[$iLayer], $iMutationRate)
	Next

	If Random(0, 1) <= $iMutationRate Then

		If Random(0, 1, 1) = 1 Then
			NN_AddNode($NN, 1)
		Else
			NN_DeleteNode($NN, 1)
		EndIf
	EndIf

	NN_Var2Info($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

	Return $NN
EndFunc

Func NN_BackUp(ByRef $NN)

	If __CheckNN($NN) = False Then Return __SetError(-1)

	Local $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens
	NN_Info2Var($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

	$wInput = $wInputBk
	For $iLayer = 0 To $nHiddens - 1
		$wHidden[$iLayer] = $wHiddenBk[$iLayer]
	Next

	NN_Var2Info($NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)

EndFunc

Func NN_Info2Var($NN, ByRef $neuInput, ByRef $neuOutput, ByRef $neuHidden, ByRef $bias, ByRef $wHidden, ByRef $wInput, ByRef $wHiddenBk, ByRef $wInputBk, ByRef $nInputs, ByRef $nOutputs, ByRef $nNodes, ByRef $nHiddens)
	$Info 		= $NN[0]
	$neuInput 	= $NN[1]
	$neuOutput 	= $NN[2]
	$neuHidden 	= $NN[3]
	$bias 		= $NN[4]
	$wInput 	= $NN[5]
	$wHidden 	= $NN[6]
	$wInputBk 	= $NN[7] ; backup
	$wHiddenBk 	= $NN[8] ; backup

	$nInputs 	= $Info[0]
	$nOutputs 	= $Info[1]
	$nNodes 	= $Info[2]
	$nHiddens 	= $Info[3]
EndFunc

Func NN_Var2Info(ByRef $NN, $neuInput, $neuOutput, $neuHidden, $bias, $wHidden, $wInput, $wHiddenBk, $wInputBk, $nInputs, $nOutputs, $nNodes, $nHiddens)
	Local $Info[4] = [$nInputs, $nOutputs, $nNodes, $nHiddens]
	$NN[0] = $Info
	$NN[1] = $neuInput
	$NN[2] = $neuOutput
	$NN[3] = $neuHidden
	$NN[4] = $bias
	$NN[5] = $wInput
	$NN[6] = $wHidden
	$NN[7] = $wInputBk
	$NN[8] = $wHiddenBk
EndFunc

Func __CheckNN($NN)
	If IsArray($NN) = False Or UBound($NN) <> 9 Or UBound($NN[0]) <> 4 Then Return False
	Return True
EndFunc

Func __SetError($codE)
	Return $codE
EndFunc

Func __minmax($x, $min, $max)
	Return ($x - $min) / ($max - $min)
EndFunc

Func __activate($x)
	Return $x < 0 ? 0 : $x
EndFunc

Func __sigmoid($x)
	Return 1 / (1 + Exp($x))
EndFunc

Func __dsigmoid($x)
	Return $x * (1 - $x)
EndFunc
