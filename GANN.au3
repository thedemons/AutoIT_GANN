#include-once
#include "neuralNetwork.au3"

;~ Local $data[5] = [3.4, 1, 3, 2, 6]
;~ Local $target[3] = [1, 0.5 , 0.3]
;~ $GANN = GANN_Open(5, 3)
;~ GANN_SetMutationRate($GANN, 0.1)
;~ $console = consolestart()
;~ ConsoleOpenThread($console)

;~ For $izxc = 0 To 10000
;~ 	consoleupdate($console)
;~ 	$error = GANN_Train($GANN, $data,$target)
;~ 	$a = GANN_Guess($GANN, $data)
;~ Next


Func GANN_Open($nInputs, $nOutputs, $nAgents = 10)

	$iMutationRate = 0.1
	$BestAgent = 0
	Local $GANN[5]
	Local $Info[4] = [$nInputs, $nOutputs, $nAgents, $iMutationRate]

	Local $Agent[$nAgents], $Score[$nAgents], $LastScore[$nAgents]

	; install agent neural network
	For $iAgent = 0 To $nAgents - 1
		$Agent[ $iAgent ] = NN_Open($nInputs, $nOutputs)
	Next

	; install agent score
	For $iAgent = 0 To $nAgents - 1
		$Score[ $iAgent ] = 0
		$LastScore[ $iAgent ] = -100000
	Next

	$GANN[0] = $Info
	$GANN[1] = $Agent
	$GANN[2] = $Score
	$GANN[3] = $LastScore
	$GANN[4] = $BestAgent

	Return $GANN
EndFunc

Func GANN_GuessAll($GANN, $aInputs)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	Local $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent
	_GANN_Info2Var($GANN, $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent)

	If UBound($aInputs) <> $nInputs Then Return SetError( -2, 0, -2 )

	Local $Guess[$nAgents][$nOutputs]
	For $iAgent = 0 To $nAgents - 1

		$Output = NN_Guess( $Agent[$iAgent], $aInputs)
		For $iOutput = 0 To $nOutputs - 1

			$Guess[$iAgent][$iOutput] = $Output[$iOutput]
		Next
	Next

	Return $Guess
EndFunc

Func GANN_Guess($GANN, $aInputs)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	; Return guess best agents
	Return GANN_AgentGuess($GANN, $aInputs, $GANN[4])
EndFunc

Func GANN_AgentGuess($GANN, $aInputs, $iAgent, $returnTop = False)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	Local $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent
	_GANN_Info2Var($GANN, $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent)

	If UBound($aInputs) <> $nInputs Then Return SetError( -2, 0, -2 )

	$Guess = NN_Guess( $Agent[$iAgent], $aInputs)

	If $returnTop Then
		$top = $Guess[0]
		$index = 0
		For $iOutput = 0 To $nOutputs - 1
			If $top < $Guess[$iOutput] Then

				$top = $Guess[$iOutput]
				$index = $iOutput
			EndIf
		Next

		Return $index
	EndIf

	Return $Guess
EndFunc

Func GANN_Train(ByRef $GANN, $aInputs, $aTargets)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	Local $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent
	_GANN_Info2Var($GANN, $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent)

	If UBound($aInputs) <> $nInputs Or UBound($aTargets) <> $nOutputs Then Return SetError( -2, 0, -2 )

	Local $Output[$nAgents], $Score[$nAgents], $IndexPop[$nAgents], $TotalError = 0

	; Get output from robot then calculate the score
	For $iAgent = 0 To $nAgents - 1
		$Output = NN_Guess( $Agent[$iAgent], $aInputs ) ; im a fucking computer and you telling me to make a guess? about some shitty thing youre doing?

		$sum = 0 ; sum score
		For $iOutput = 0 To $nOutputs - 1

			; Error = Target - Output
			; Score = 1 / Error^2 - 1
			$error = ( $aTargets[$iOutput] - $Output[$iOutput] ) ^ 2
			$sum += 1 / $error - 1
			$TotalError += $error
		Next
		$Score[$iAgent] = $sum
		$IndexPop[$iAgent] = $iAgent
	Next

	__Sorting($Score, $IndexPop)

	$BestAgent = $IndexPop[0] ; Best Agent

	$KillFrom = Round( ($nAgents - 1) / 2 )
	For $iAgent = $KillFrom To $nAgents - 1

		; Kill them all theyre fucking retarded
		$Kill = $IndexPop[$iAgent]
		$Player = $IndexPop[0];$IndexPop[$iAgent - $KillFrom]	 ; copy brain from this player

;~ 		If $iAgent - $KillFrom = $KillFrom Then $Player = $IndexPop[0]

		$Agent[ $Kill ] = NN_Mutate( $Agent[ $Player ], $iMutationRate) ; to this killed player and mutate that brain
	Next

	_GANN_Var2Info($GANN, $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent)

	Return $TotalError
EndFunc

Func GANN_Evolve(ByRef $GANN)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	Local $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent
	_GANN_Info2Var($GANN, $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent)

	Local $IndexPop[$nAgents]
	; put index of agent into an array, for sorting score
	For $iAgent = 0 To $nAgents - 1
		$IndexPop[$iAgent] = $iAgent
	Next

	; if score < last score, mean the mutation sucks, then back it up
	For $iAgent = 0 To $nAgents - 1

		If $Score[$iAgent] < $LastScore[$iAgent] Then

			$Score[$iAgent] = $LastScore[$iAgent]
			NN_BackUp( $Agent[$iAgent] )
		EndIf
	Next


	__Sorting($Score, $IndexPop)

	$BestAgent = $IndexPop[0] ; Best Agent

	$KillFrom = Round( ($nAgents - 1) / 2 ) ; from the middle
	For $iAgent = $KillFrom To $nAgents - 1

		; Kill them all theyre fucking retarded
		$Kill = $IndexPop[$iAgent]
		$Player = $IndexPop[$iAgent - $KillFrom]	 ; copy brain from this player

;~ 		If $iAgent - $KillFrom = $KillFrom Then $Player = $IndexPop[0]

		$Agent[ $Kill ] = NN_Mutate( $Agent[ $Player ], $iMutationRate) ; to this killed player and mutate that brain
	Next
	For $iAgent = 0 To $KillFrom - 1

		If $Score[$iAgent] = $LastScore[$iAgent] Then

			$index = $IndexPop[$iAgent]
			$Agent[$index] = NN_Mutate( $Agent[$index] , $iMutationRate)
		EndIf
	Next
;~ 	MsgBox(0,"",UBound($Score))
;~ 	_ArrayDisplay($Score)
	; reset the score
	For $iScore = 0 To $nAgents - 1
		$LastScore[$iScore] = $Score[$iScore]
	Next

	_GANN_Var2Info($GANN, $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent)
EndFunc

Func GANN_GetBestAgent($GANN)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	Return $GANN[4]
EndFunc

Func GANN_AgentSetScore(ByRef $GANN, $iAgent, $_score)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	; GANN[2] = score
	$Score = $GANN[2]
	$Score[$iAgent] = $_score
	$GANN[2] = $Score
EndFunc

Func GANN_SetMutationRate(ByRef $GANN, $iMutationRate)

	If __CheckGANN($GANN) = False Then Return SetError(-1, 0, -1)

	$Info = $GANN[0]
	$Info[3] = $iMutationRate
	$GANN[0] = $Info

EndFunc

Func _GANN_Info2Var($GANN, ByRef $nInputs, ByRef $nOutputs, ByRef $nAgents, ByRef $iMutationRate, ByRef $Agent, ByRef $Score, ByRef $LastScore, ByRef $BestAgent)
	$Info = $GANN[0]

	$nInputs = $Info[0]
	$nOutputs = $Info[1]
	$nAgents = $Info[2]
	$iMutationRate = $Info[3]
	$Agent = $GANN[1]
	$Score = $GANN[2]
	$LastScore = $GANN[3]
	$BestAgent = $GANN[4]
EndFunc

Func _GANN_Var2Info(ByRef $GANN, $nInputs, $nOutputs, $nAgents, $iMutationRate, $Agent, $Score, $LastScore, $BestAgent)
	Local $Info[4] = [$nInputs, $nOutputs, $nAgents, $iMutationRate]
	$GANN[0] = $Info
	$GANN[1] = $Agent
	$GANN[2] = $Score
	$GANN[3] = $LastScore
	$GANN[4] = $BestAgent
EndFunc

Func __CheckGANN($GANN)
	If IsArray($GANN) = False Or UBound($GANN) <> 5 Or UBound($GANN[0]) <> 4 Then Return False
	Return True
EndFunc

Func __Sorting($vScore, ByRef $IndexPop)
	$Score = $vScore
	For $i = 0 To UBound($Score) - 2

		If $Score[$i] < $Score[$i + 1] Then

			$tmp0 = $Score[$i]
			$tmp1 = $Score[$i + 1]
			$Score[$i] = $tmp1
			$Score[$i + 1] = $tmp0

			$index0 = $IndexPop[$i]
			$index1 = $IndexPop[$i + 1]
			$IndexPop[$i] = $index1
			$IndexPop[$i + 1] = $index0

			For $i2 = $i To 1 Step - 1

				If $Score[$i2] <= $Score[$i2 - 1] Then ExitLoop
				$tmp0 = $Score[$i2]
				$tmp1 = $Score[$i2 - 1]
				$Score[$i2] = $tmp1
				$Score[$i2 - 1] = $tmp0

				$index0 = $IndexPop[$i2]
				$index1 = $IndexPop[$i2 - 1]
				$IndexPop[$i2] = $index1
				$IndexPop[$i2 - 1] = $index0
			Next

		EndIf
	Next

EndFunc