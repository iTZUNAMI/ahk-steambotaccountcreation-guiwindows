
#Persistent  ; Keep the script running until the user exits it.
#SingleInstance force  ;he word FORCE skips the dialog box and replaces the old instance automatically



;carico file su array
ArrayAccount := Object()
ArrayAccount[j] := A_LoopField
ArrayAccount[j, k] := A_LoopReadLine
ArrayCount := 0                        
Loop, Read, %A_ScriptDir%/account.txt
{
  ArrayCount += 1
  ArrayAccount[ArrayCount] := A_LoopReadLine
}

FileAppend, Start:Ci sono %ArrayCount% account da creare...`n, %A_ScriptDir%/log.txt
  
;main  

;var globali
InstallDirSteam:=""
okPrimoStep:=0
okSecondoStep:=0
okTerzoStep:=0
fineCreazione:=0

sospendi:=0

;reset 
vuoto:=""
RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\Valve\Steam, AutoLoginUser, %vuoto%
RegWrite, REG_DWORD, HKEY_CURRENT_USER, SOFTWARE\Valve\Steam, RememberPassword, 0

auser:=""
apass:=""
aemail:=""
crezionePos:=1

;match perfetto
SetTitleMatchMode, 3

;controllo path e killo processo  
ControllaSteam()
  




;avvio Steam e lo metto in primo piano





;eseguo tante volte quante le righe trovate
Loop %ArrayCount%
{
		
		
		
		;uso come globale per sotto
		crezionePos:=A_Index
		
		element := ArrayAccount[crezionePos]
		;MsgBox %element%
		AvviaSteam()

		;5 secondi
		sleep 5000
		PrimoStep() 
		sleep 5000
		KillSteam()
		TrayTip, OK,Account creato. Premere ALTGR+B per farlo terminare altrimenti va avanti da solo, 800, 17
		sleep 15000
		
		if (fineCreazione=1){
		;MsgBox %auser% Creato
		fineCreazione:=0
		;reset
		okPrimoStep:=0
		okSecondoStep:=0
		okTerzoStep:=0
		
		
		FileAppend, %auser% creato correttamente `n, %A_ScriptDir%/log.txt
		
		}
		else
		{
		MsgBox Interrotto ad %auser% 
		FileAppend, %auser% NON CREATO ERRORE `n, %A_ScriptDir%/log.txt
		ExitApp
		}
		
		;se sospeso mostra ultimo fatto e interrompo
		if (sospendi=1){
			MsgBox SOSPESO MANUALMENTE FINO A %auser% (appena creato). Ricordarsi di aggiornare la lista 
			FileAppend, %auser% ultimo creato. Lista sospesa manualmente `n, %A_ScriptDir%/log.txt
			break
		}
		
		
	;re-inizia il cilco
		sleep 5000
		
		
		
		
}

MsgBox FINE LISTA o SOSPESO






;ALT GR + b
;interrompi fino all'ultimo creato e mostra ultimo creato
<^>!b:: 
staccastacca()
MsgBox STOP OK
return



ExitApp

return 




PrimoStep(){
	
	;metto in primo piano

	global okPrimoStep

	

	;loop continuo finche non trovo questa schermata
	;se non la trova entro 30 secondi allora esci
	;avvia NoPrimoStep tra 30 secondi se non lo stoppo prima
	SetTimer,NoPrimoStep,-30000
	
	while (okPrimoStep=0) {
		IfWinExist, Accesso a Steam
		{
				;se trovato
				BlockInput, on
				
				WinActivate
				
				okPrimoStep:=1
				SetTimer,NoPrimoStep, Off
			    
				sleep 2000
				
				; use the window found above
				;premo 4 tab e invio
				Send {Tab} 
				sleep 100
				Send {Tab} 
				sleep 100
				Send {Tab} 
				sleep 100
				Send {Tab}	
				sleep 100 			
				Send {Enter} 
				sleep 100
				
				
				BlockInput, off
				
				;crezione account
				SecondoStep()


		}
	
	}
    

}
return


SecondoStep()
{
	global okSecondoStep
	SetTimer,NoSecondoStep,-40000
	
	while (okSecondoStep=0) {
		IfWinExist, Steam
			{
				;se trovato
				BlockInput, on
				
				WinActivate
				
				okSecondoStep:=1
				SetTimer,NoSecondoStep, Off
				
				sleep 2000
				
				Send {Enter}
				sleep 1000
				Send {Enter}
				sleep 1000
				Send {Enter}
				sleep 1000
				Send {Enter}
				
				BlockInput, off
				
				;se siamo qua abbiamo i 3 campi vuoti
				
				TerzoStep()

			}
}
}
return	


TerzoStep(){
	global okTerzoStep
	global ArrayAccount
	global crezionePos
	
	global auser
	global apass
	global aemail
	
	
	SetTimer,NoTerzoStep,-50000
	
	while (okTerzoStep=0) {
	IfWinExist, Crea un account di Steam...
				{
				BlockInput, on	
				WinActivate
				
				okTerzoStep:=1
				SetTimer,NoTerzoStep, Off
				
				sleep 2000
				
				
				riga:=ArrayAccount[crezionePos]
				;trovo la prima posizione del -
				divisore = -
				StringGetPos, posfineUser, riga, %divisore%, L1 ;L1 la prima occorrenza L2 la seconda ecc
				auser:=SubStr(riga, 1, posfineUser) ; riga, posIniziale, lunghezza

				StringGetPos, posfinePass, riga, %divisore%, L2
				apass:=SubStr(riga, posfineUser+2, posfinePass-posfineUser-1) ; riga, posIniziale, lunghezza

				aemail:=SubStr(riga, posfinePass+2, StrLen(riga)-posfinePass-1) ; riga, posIniziale, lunghezza totale meno pos trovata

				
				;user
				Send %auser%
				Send {Tab}
				Sleep 1000
				;pass
				Send %apass%
				Send {Tab}
				Sleep 1000
				;conferma pass
				Send %apass%
				Sleep 1000
				
				
				
				;ora qua devo controllare che la password non sia debole o errata
				;quindi se compare il pulnsate avanti premo Invio altrimenti non va nella pagina dopo
				
				
				
				CoordMode,pixel
				IfWinExist, Crea un account di Steam...
					WinActivate
				sleep 6000
				ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, avanti.png ;solo png ok
				
				BlockInput, off
				
					If(ErrorLevel == 0)
					{
												
						BlockInput, on
						
						;avanti
						Send {Enter}
						
						
						;schermata email
						
						sleep 1000
						;email e conferma
						SendRaw  %aemail% ;SendRaw  per caratteri speciali tipo +
						Send {Tab}
						Sleep 1000
						SendRaw  %aemail%
						
						IfWinExist, Crea un account di Steam...
						WinActivate
						;controllo email ok e pulsante avanti di nuovo
						Sleep 2000
						ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, avanti.png ;solo png ok
						If(ErrorLevel == 0)
							{
							Send {Enter}
							
							sleep 16000
							;schermata gialla fine crezione
							; non vanno enter da qua quindi killo tutto tanto e gia creato
							IfWinExist, Steam - Crea account
							WinActivate
							ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, creato.png ;solo png ok
								If(ErrorLevel == 0)
									{
									;MsgBox CI SIAMO
									okCreato()
									}
									else
									{
									MsgBox NON TROVATO
									}
							
							}
						
						
						
						BlockInput, off
						
					}
				

				
				
				}
}
}
return

;se sono qua ho creato e devo sloggarmi
okCreato()
{
	
	        global fineCreazione
	
			;cancello atuologinuser da regedit cosi riavvio e non si rilogga
			;RegDelete, HKEY_CURRENT_USER, SOFTWARE\Valve\Steam , AutoLoginUser
			;no sovrascrivo con vuoto
			vuoto:=""
			RegWrite, REG_SZ, HKEY_CURRENT_USER, SOFTWARE\Valve\Steam, AutoLoginUser, %vuoto%
			RegWrite, REG_DWORD, HKEY_CURRENT_USER, SOFTWARE\Valve\Steam, RememberPassword, 0
			fineCreazione:=1


}
return

staccastacca()
{
	
	global sospendi
	
	sospendi:=1
	
	
}
return

;Timer
NoPrimoStep:
{
	global auser
	MsgBox NOPRIMO interrotto %auser%
	FileAppend, Interrotto primo Step `n, %A_ScriptDir%/log.txt
	ExitApp
}
return

NoSecondoStep:
{
	global auser
	MsgBox NOSECONDO interrotto %auser%
	FileAppend, Interrotto secondo Step `n, %A_ScriptDir%/log.txt
	ExitApp
}
return

NoTerzoStep:
{
	global auser
	MsgBox NOTERZO interrotto %auser%
	FileAppend, Interrotto terzo Step `n, %A_ScriptDir%/log.txt
	ExitApp
}
return


;funzioni

AvviaSteam()
{
	global InstallDirSteam
	mycmd := InstallDirSteam . "/Steam.exe"	
	Run, %mycmd%,,show
}
return
  
  ControllaSteam()
{
	global InstallDirSteam
	;test********
	; InstallDirSteam:="E:\Steam"
	; return
	;test********
	
	;path Steam
	RegRead, InstallDirSteam,HKEY_CURRENT_USER,Software\Valve\Steam,SteamPath	
	If ( InstallDirSteam = "" ) 
		{
			Quit_Steam_non_presente()
		}
		
	;kill Steam se gia in esecuzione
	KillSteam()
}
return


KillSteam()
{
	process=Steam.exe 
	Process, Exist, %process%
	if	pid :=	ErrorLevel
	{
		Loop 
		{
			WinClose, ahk_pid %pid%, , 5	; will wait 5 sec for window to close
			if	ErrorLevel	; if it doesn't close
				Process, Close, %pid%	; force it 
			Process, Exist, %process%
		}	Until	!pid :=	ErrorLevel

	}
	return
}
return


Quit_Steam_non_presente()
{
    MsgBox Steam non installato. Premi Ok per chiudere
    ExitApp
}
return
