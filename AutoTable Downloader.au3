#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.1
 Author:         Igromanru

 Script Function:
	Download and save latest CE tables from the forum if something has changed.
	http://forum.cheatengine.org/viewtopic.php?t=589191

	Phokz's Table: http://forum.cheatengine.org/download.php?id=116832
	Zanzer's Table: http://forum.cheatengine.org/download.php?id=116816

#ce ----------------------------------------------------------------------------

#include <AutoItConstants.au3>
#include <InetConstants.au3>
#include <Array.au3>

Global Const $LATEST_GAME_VERSION = "1.04.1"
Global Const $LATEST_VERSION_PATH = @ScriptDir & "\Tables\"
Global Const $POSTFIX = ".CT"

Global Const $aTables[2][2] = [ _
							["Phokz", "http://forum.cheatengine.org/download.php?id=116832"], _
							["Zanzer", "http://forum.cheatengine.org/download.php?id=116816"] _
						]

checkAndDownloadLatestVersion()
AdlibRegister("checkAndDownloadLatestVersion", 60*1000*30)

While 1
	Sleep(100)
WEnd

Func createFolderIfNotExist($sPath)
	Local $bResult = False
	If FileExists($sPath) = 0 Then
		DirCreate($sPath)
		MsgBox(0,"",$sPath)
		$bResult = True
	EndIf
	Return $bResult
EndFunc

Func compareTable($sRemote, $sLocal)
	Local $nRemoteSize = InetGetSize($sRemote, $INET_FORCERELOAD)
	Local $nLocalSize = FileGetSize($sLocal)
	Return $nRemoteSize = $nLocalSize
EndFunc

Func downloadFile($sUrl, $sLocation)
	Local $sStamp = @MDAY&"."&@MON&"."&@YEAR&" "&@HOUR&"-"&@MIN&"-"&@SEC
	Local $sFile = $sLocation & $sStamp & $POSTFIX
	If InetGet($sUrl, $sFile, $INET_FORCERELOAD) > 0 Then
		TrayTip("Download complete", $sFile, 3)
		Run(@ScriptDir&"\AutoCommit.bat", @ScriptDir)
	EndIf
EndFunc

Func checkAndDownloadLatestVersion()
	For $i = 0 To UBound($aTables)-1
		Local $bFound = False
		Local $sPath = $LATEST_VERSION_PATH & $aTables[$i][0] & "\"
		Local $hSearch = FileFindFirstFile($sPath & "*" & $POSTFIX)
		Local $bSkip = createFolderIfNotExist($sPath)
		While Not $bSkip
			$sFileName = FileFindNextFile($hSearch)
			If @error Then
				ExitLoop
			ElseIf compareTable($aTables[$i][1], $sPath & $sFileName) Then
				$bFound = True
				ExitLoop
			EndIf
			Sleep(100)
		WEnd
		FileClose($hSearch)
		If Not $bFound Then
			downloadFile($aTables[$i][1], $sPath & $LATEST_GAME_VERSION & " ")
		EndIf
	Next
EndFunc