;//////////////////////////////////////
;// Những dòng quan trọng cần xem 	 //
;// .	50							 //
;// .	65							 //
;// .	104							 //
;// .	254							 //
;//////////////////////////////////////


#include <GDIPlus.au3>
#include <Array.au3>
#include "GANN.au3"
OnAutoItExitRegister("GDI_CleanUp")

Global $ObjectsHeight = 155
Global $ObjectsSpace = 180
Global $ObjectsLimit = 585
Global $ObjectsW = 72
Global $ObjectsSpeed = 3
Global $Objects[3][2]

Global $BirdW = 57
Global $BirdH = 40
Global $BirdDropSpeed = 8
Global $Birds[100][2], $BirdNumber = 10
Global $BirdsState[$BirdNumber + 1][2]
Global $BirdsFitness[$BirdNumber]

Global $Gen = 1

Global $hGraphic, $hBrushObject, $hBrushBird, $hBrushBirdRed, $hPenBlack, $hPenRed, $g_hBitmap, $g_hGfxCtxt

Const $cBlack			= 0xFF000000
Const $cRed				= 0x44FF0000
Const $cObject			= 0x5500BB00
Const $cBird			= 0x55000055
Const $cBirdRed			= 0x55FF0000
Const $cBackground		= 0xFFFFFFFF

Global $Gui
Global $GuiW = 470, $GuiH = 700

$Gui = GUICreate("FlappyBird - AutoIT Machine Learning GANN", $GuiW, $GuiH)
GUISetState()

GDI_StartUp()

; GANN_Open( số input, số output, số agent)
; agent có nghĩa là AI, ở đây ta tạo nhiều con AI (agent) cùng 1 lúc
Global $GANN = GANN_Open(3, 2, $BirdNumber)

CreateFirstObjects()
CreateBird()

AdlibRegister("MoveObjects", 1)
AdlibRegister("MoveBirds", 1)
AdlibRegister("DrawObjects", 1)
AdlibRegister("AIMoveBird", 1)
AdlibRegister("CheckAlive", 250)

while True

	Switch GUIGetMsg()
		Case -3
			Exit
	EndSwitch
WEnd

; ==================================================  XỬ LÝ INPUT THÀNH OUTPUT  ==========================================================
Func AIMoveBird()
	Local $DesX = - 1, $DesY = - 1
	Local $inputs[3]

	;xác định vị trí của Ống tiếp theo
	For $o = 0 to 2
		If ($GuiW - $BirdW)/2 > $Objects[$o][0] + $ObjectsW Then ContinueLoop
		If $DesX = - 1 Or $Objects[$o][0] < $DesX Then
			$DesX = $Objects[$o][0]
			$DesY = $Objects[$o][1]
		EndIf
	Next

	; Đưa input vào để xử lý thành output
	For $i = 1 to $Birds[0][0]
		If $BirdsState[$i][0] = -1 then ContinueLoop
		$inputs[0] = $DesX - $Birds[$i][0]
		$inputs[1] = $DesY - $Birds[$i][1]
		$inputs[2] = ($DesY + $ObjectsHeight) - $Birds[$i][1]
		If GANN_AgentGuess($GANN, $inputs, $i - 1, True) = 1 Then $BirdsState[$i][0] = 1 ;nếu output cao nhất là 1 thì nhảy
	Next
EndFunc
; ============================================================================================================


Func MoveBirds()
	Local $isNext = False
	For $i = 1 to $Birds[0][0]
		If $Birds[$i][0] < -3 - $BirdW Then ContinueLoop
		If $BirdsState[$i][0] = - 1 Then ContinueLoop
		For $o = 0 to 2
			If $Birds[$i][0] + $BirdW >= $Objects[$o][0] And $Birds[$i][0] <= $Objects[$o][0] + $ObjectsW And ($Birds[$i][1] < $Objects[$o][1] Or ($Birds[$i][1] + $BirdH) > ($Objects[$o][1] + $ObjectsHeight)) Then
				$BirdsState[$i][0] = -1

				; ====================================================  TÍNH FITNESS  ========================================================
				If $Birds[$i][1] < $Objects[$o][1] Then
					$BirdsFitness[$i - 1] += ($Objects[$o][1] - $Birds[$i][1]) / $Objects[$o][1]
				ElseIf $birds[$i][1] > $Objects[$o][1] + $ObjectsHeight Then
					$BirdsFitness[$i - 1] += ($Birds[$i][1] - ($Objects[$o][1] + $ObjectsHeight)) / ($ObjectsLimit - $Objects[$o][1] + $ObjectsHeight)
				Else
					$BirdsFitness += 100
				EndIf

				; Set score
				; GANN_AgentSetScore( $GANN, agent, score)
				GANN_AgentSetScore($GANN, $i - 1, $BirdsFitness[$i - 1])
				; ============================================================================================================

				$isNext = True
				ExitLoop
			EndIf
		Next
		If $isNext = True then
			$isNext = False
			ContinueLoop
		EndIf
		If $BirdsState[$i][0] > 0 Then
			Switch $BirdsState[$i][0]
				Case 1
					$Birds[$i][1] -= $BirdDropSpeed*1.5
					$BirdsState[$i][1] += 1
					if $BirdsState[$i][1] >= 4 Then
						$BirdsState[$i][1] = 0
						$BirdsState[$i][0] += 1
					EndIf
					If $Birds[$i][1] <= 0 Then $Birds[$i][1] = 0
				Case 2
					$Birds[$i][1] -= $BirdDropSpeed
					$BirdsState[$i][1] += 1
					if $BirdsState[$i][1] >= 3 Then
						$BirdsState[$i][1] = 0
						$BirdsState[$i][0] += 1
					EndIf
					If $Birds[$i][1] <= 0 Then $Birds[$i][1] = 0
				Case 3
					$Birds[$i][1] -= $BirdDropSpeed / 2
					$BirdsState[$i][1] += 1
					if $BirdsState[$i][1] >= 3 Then
						$BirdsState[$i][1] = 0
						$BirdsState[$i][0] += 1
					EndIf
					If $Birds[$i][1] <= 0 Then $Birds[$i][1] = 0
				Case 4
					$BirdsState[$i][1] += 1
					if $BirdsState[$i][1] >= 2 Then
						$BirdsState[$i][1] = 0
						$BirdsState[$i][0] += 1
					EndIf
				Case 5
					$Birds[$i][1] += $BirdDropSpeed/2
					$BirdsState[$i][1] += 1
					if $BirdsState[$i][1] >= 3 Then
						$BirdsState[$i][1] = 0
						$BirdsState[$i][0] += 1
					EndIf
				Case 6
					$Birds[$i][1] += $BirdDropSpeed
					$BirdsState[$i][1] += 1
					if $BirdsState[$i][1] >= 6 Then
						$BirdsState[$i][1] = 0
						$BirdsState[$i][0] = 0
					EndIf
			EndSwitch
		Else
			If $Birds[$i][1] + $BirdH + $BirdDropSpeed >= $ObjectsLimit Then
				$Birds[$i][1] = $ObjectsLimit - $BirdH
			Else
				$Birds[$i][1] += $BirdDropSpeed * 1.5
			EndIf
		EndIf
	Next
EndFunc

Func MoveObjects()
	For $i = 0 to 2
		$Objects[$i][0] -= $ObjectsSpeed
		If $Objects[$i][0] <= - $ObjectsW Then
			$Objects[$i][0] = $Objects[(($i - 1 < 0) ? 2 : $i - 1)][0] + $ObjectsSpace + $ObjectsW
			$Objects[$i][1] = Random(100, $ObjectsLimit - $ObjectsHeight - 100, 1)
		EndIf
	Next
	For $i = 1 to $Birds[0][0]
		If $BirdsState[$i][0] = -1 Then
			$Birds[$i][0] -= $ObjectsSpeed
		Else
			$BirdsFitness[$i - 1] += $ObjectsSpeed
		EndIf
	Next

EndFunc

Func CreateFirstObjects()
	For $i = 0 to 2
		$Objects[$i][0] = 600 + $i * ($ObjectsSpace + $ObjectsW)
		$Objects[$i][1] = Random(100, $ObjectsLimit - $ObjectsHeight - 100, 1)
	Next
EndFunc

Func CreateBird()
	Local $centerX = ($GuiW - $BirdW)/2
	Local $centerY = ($ObjectsLimit - $BirdH)/2
	$Birds[0][0] = $BirdNumber
	For $i = 1 to $Birds[0][0]
		$Birds[$i][0] = $centerX
		$Birds[$i][1] = $centerY
		$BirdsState[$i][0] = 6
		$BirdsState[$i][1] = 0
		$BirdsFitness[$i - 1] = 0
	Next
EndFunc

Func DrawObjects()
	$BestAgent = GANN_GetBestAgent($GANN)
	_GDIPlus_GraphicsClear($g_hGfxCtxt, $cBackground)
	For $i = 0 to 2
		_GDIPlus_GraphicsFillRect($g_hGfxCtxt, $Objects[$i][0], 0, $ObjectsW, $Objects[$i][1], $hBrushObject)
		_GDIPlus_GraphicsFillRect($g_hGfxCtxt, $Objects[$i][0], $Objects[$i][1] + $ObjectsHeight, $ObjectsW, $ObjectsLimit - $Objects[$i][1] - $ObjectsHeight, $hBrushObject)

		_GDIPlus_GraphicsFillRect($g_hGfxCtxt, $Objects[$i][0] + 20, 0, $ObjectsW - 30, $Objects[$i][1], $hBrushObject)
		_GDIPlus_GraphicsFillRect($g_hGfxCtxt, $Objects[$i][0] + 20, $Objects[$i][1] + $ObjectsHeight, $ObjectsW - 30, $ObjectsLimit - $Objects[$i][1] - $ObjectsHeight, $hBrushObject)

		_GDIPlus_GraphicsFillRect($g_hGfxCtxt, $Objects[$i][0] - 5, $Objects[$i][1] - 15, $ObjectsW + 10, 15, $hBrushObject)
		_GDIPlus_GraphicsFillRect($g_hGfxCtxt, $Objects[$i][0] - 5, $Objects[$i][1] + $ObjectsHeight, $ObjectsW + 10, 15, $hBrushObject)

		_GDIPlus_GraphicsDrawRect($g_hGfxCtxt, $Objects[$i][0], -2, $ObjectsW, $Objects[$i][1] + 2 - 15, $hPenBlack)
		_GDIPlus_GraphicsDrawRect($g_hGfxCtxt, $Objects[$i][0], $Objects[$i][1] + $ObjectsHeight + 15, $ObjectsW, $ObjectsLimit - $Objects[$i][1] - $ObjectsHeight - 15, $hPenBlack)

		_GDIPlus_GraphicsDrawRect($g_hGfxCtxt, $Objects[$i][0] - 5, $Objects[$i][1] - 15, $ObjectsW + 10, 15, $hPenBlack)
		_GDIPlus_GraphicsDrawRect($g_hGfxCtxt, $Objects[$i][0] - 5, $Objects[$i][1] + $ObjectsHeight, $ObjectsW + 10, 15, $hPenBlack)
	Next


	For $i = 1 to $Birds[0][0]
		If $i - 1 = $BestAgent Then ContinueLoop
		_GDIPlus_GraphicsFillEllipse($g_hGfxCtxt, $Birds[$i][0], $Birds[$i][1], $BirdW, $BirdH, $hBrushBird)
		_GDIPlus_GraphicsDrawEllipse($g_hGfxCtxt, $Birds[$i][0], $Birds[$i][1], $BirdW, $BirdH, $hPenBlack)
	Next

	_GDIPlus_GraphicsFillEllipse($g_hGfxCtxt, $Birds[$BestAgent + 1][0], $Birds[$BestAgent + 1][1], $BirdW, $BirdH, $hBrushBirdRed)
	_GDIPlus_GraphicsDrawEllipse($g_hGfxCtxt, $Birds[$BestAgent + 1][0], $Birds[$BestAgent + 1][1], $BirdW, $BirdH, $hPenBlack)


	_GDIPlus_GraphicsDrawLine($g_hGfxCtxt, 0, $ObjectsLimit, $GuiW, $ObjectsLimit, $hPenBlack)

	_GDIPlus_GraphicsDrawString($g_hGfxCtxt, "GEN: " & $Gen, 30, $ObjectsLimit + 10)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $g_hBitmap, 0, 0, $GuiW, $GuiH)
EndFunc

Func CheckAlive()
	For $i = 1 to $Birds[0][0]
		If $BirdsState[$i][0] <> - 1 then Return
	Next

	; Nếu tất cả bird đã chết thì cho tiến hóa bằng cách _GANN_Evolve( $GANN )
	GANN_Evolve($GANN)
	; quá trình tiến hóa này giúp AI thông minh hơn


	CreateFirstObjects()
	CreateBird()
	$Gen += 1
EndFunc


Func GDI_StartUp()
	_GDIPlus_Startup()

	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
	$g_hBitmap = _GDIPlus_BitmapCreateFromGraphics($GuiW, $GuiH, $hGraphic)
	$g_hGfxCtxt = _GDIPlus_ImageGetGraphicsContext($g_hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($g_hGfxCtxt, 2) ;sets the graphics object rendering quality (antialiasing)

	$hBrushObject = _GDIPlus_BrushCreateSolid($cObject)
	$hBrushBird = _GDIPlus_BrushCreateSolid($cBird)
	$hBrushBirdRed = _GDIPlus_BrushCreateSolid($cBirdRed)
	$hPenBlack = _GDIPlus_PenCreate($cBlack)
	$hPenRed = _GDIPlus_PenCreate($cRed)
EndFunc
Func GDI_CleanUp()
    _GDIPlus_BrushDispose($hBrushObject)
    _GDIPlus_BrushDispose($hBrushBird)
    _GDIPlus_PenDispose($hPenBlack)
    _GDIPlus_PenDispose($hPenRed)
    _GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($g_hBitmap)
	_GDIPlus_ImageDispose($g_hGfxCtxt)
    _GDIPlus_Shutdown()
EndFunc
