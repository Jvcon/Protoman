; --------------------- COMPILER DIRECTIVES --------------------------

;@Ahk2Exe-SetDescription Protocol Manager
;@Ahk2Exe-SetVersion 0.0.1
;@Ahk2Exe-SetCopyright Jacques Yip
;@Ahk2Exe-SetMainIcon Protoman.ico
;@Ahk2Exe-SetOrigFilename Protoman.exe

; --------------------- PROGRAM --------------------------

CONF_Path := A_ScriptDir . "\Protoman.ini"
if(!FileExist(CONF_Path)){
    FileAppend("[Path]`n`n  [Mode]`n",CONF_Path)
}
if (A_Args.Length = 0) {
	HasKey := RegRead("HKEY_CLASSES_ROOT\expm", , 0)
	if HasKey {
		Result := MsgBox("expm://协议已注册，尝试修复？", "协议注册", "Icon? Y/N/C T5 Default3")
	}
	else {
		Result := MsgBox("expm://协议尚未注册，现在注册？", "协议注册", "Icon? Y/N T5 Default1")
	}
	switch Result {
		case "Yes":
			if !A_IsAdmin {
				try {
					if A_IsCompiled {
						Run '*RunAs "' A_AhkPath '" /restart'
					}
					else {
						Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
					}
				}
			}
			else {
				if A_IsCompiled {
					registerUrlProtocol("expm", A_AhkPath,)
				}
				else {
					registerUrlProtocol("expm", A_AhkPath . " /script " . A_ScriptFullPath,)
				}
				Traytip "注册协议成功", "Protoman", "Iconi Mute"
				Sleep 3000
				HideTrayTip
				ExitApp
			}
		case "Cancel", "No", "Timeout":
			ExitApp
		default:
			ExitApp
	}
}
else {
	url := A_Args[1]
	processProtocol(url)
}

ExitApp
; expm://obsidian.open?path=ab

processProtocol(url) {
	parts := StrSplit(url, "://")
	if (parts[1] != "expm") {
		MsgBox ("The protocol is not correct.")
		return
	}
	commandParams := StrSplit(parts[2], "?")
	hostname := StrSplit(commandParams[1], ".")
	command := hostname[1]
	operation := hostname[2]
	baseCommand := IniRead(CONF_Path, "Path", command, command . ".exe")
	paramsMode := IniRead(CONF_Path, "Mode", command, 1)
	params := paramsParse(commandParams[2],paramsMode)
    exeCommand := baseCommand . " " . params
	switch operation {
		case "open":
            RunWait exeCommand
        case "test":
            MsgBox exeCommand
        default:
	}
	return
}

paramsParse(query, mode := 1) {
	params := Map()
	pairs := StrSplit(query, "&")
	for index, pair in pairs {
		keyValue := StrSplit(pair, "=")
		params[keyValue[1]] := keyValue[2]
	}
	paramsString := ""
	i := 1
	for key, value in params {
		switch mode {
			case 2:
				paramsString .= "/" . key . " " . value
			case 3:
				paramsString .= "-" . key . " " . value
			case 1:
				; linux mode
				paramsString .= "--" . key . "=" . value
			default:
		}

		if (i < params.Count) {
			paramsString .= " "
			i += 1
		}
	}
	return paramsString
}

registerUrlProtocol(Protocol, Command, Description := "") {
	keyPath := "HKEY_CLASSES_ROOT\" . Protocol
	RegWrite("URL:" . Protocol, "REG_SZ", keyPath)
	RegWrite("", "REG_SZ", keyPath, "URL Protocol")
	if A_IsCompiled {
		RegWrite(Command, "REG_SZ", keyPath . "\DefaultIcon")
	}
	else {
		RegWrite(A_ScriptDir .
			"\Protoman.ico", "REG_SZ", keyPath . "\DefaultIcon")
	}
	RegCreateKey keyPath . "\shell\open"
	RegWrite(Command . " %1", "REG_SZ", keyPath . "\shell\open\command")
}

HideTrayTip() {
	TrayTip
	if SubStr(A_OSVersion, 1, 3) = "10." {
		A_IconHidden := true
		Sleep 5000
		A_IconHidden := false
	}
}
