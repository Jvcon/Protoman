Import-Module Microsoft.PowerShell.Utility

$cwd = (Get-Location).Path
Write-Debug "processing env file"
$envfiles="$cwd\.env"
if (-not $envfiles) { return }
$loadEnv = @{}
foreach ($line in Get-Content($envfiles)) {
    $line = $line.Trim()

    if ($line -eq '' -or $line -like '#*') {
        continue
    }

    $key, $value = ($line -split '=', 2).Trim()

    if ($value -like '"*"') {
        # expand \n to `n for double quoted values
        $value = $value -replace '^"|"$', '' -replace '(?<!\\)(\\n)', "`n"
    }
    elseif ($value -like "'*'") {
        $value = $value -replace "^'|'$", ''
    }

    $loadEnv[$key] = $value
}
$ahk2exe = $loadEnv["ahkpath"] + '\Compiler\Ahk2Exe.exe'
$ahk64base = $loadEnv["ahkpath"] + '\v2\AutoHotkey64.exe'
$command = $ahk2exe + ' /silent verbose ' + ' /base ' + $ahk64base + " /out  $cwd\build\"
$testcommand = $ahk2exe + ' /base ' + $ahk64base + " /out  $cwd\test\"
$version = $args[0]
$env = $args[1]
$appname = $args[2]
$setversion = ';@Ahk2Exe-SetVersion ' + $version
Write-Host 'App:' $appname
Write-Host 'Version:' $version

if ($env -eq 'version') {
    Get-ChildItem “$cwd\*.ahk” | ForEach-Object {
        (Get-Content $_) | ForEach-Object { $_ -Replace (';@Ahk2Exe-SetVersion ' + '[0-9]+.[0-9]+.[0-9]+') , $setversion } | Set-Content $_
    }   
}

elseif ($env -eq 'prod') {
    if (!(Test-Path -Path "$cwd\build")) {
        mkdir $cwd\build
    }
    Get-ChildItem “$cwd\*.ahk” | ForEach-Object {
        (Get-Content $_) | ForEach-Object { $_ -Replace (';@Ahk2Exe-SetVersion ' + '[0-9]+.[0-9]+.[0-9]+') , $setversion } | Set-Content $_
    }

    if ((Test-Path -Path "$cwd\build\checksums_v$version.txt")) {
        Remove-Item -Path $cwd\build\checksums_v$version.txt
    }
    foreach ($file in (Get-ChildItem -Path $cwd\*.ahk)) {
        Write-Host $file.BaseName
        Invoke-Expression($command + " /in $file")
        while ( !(Test-Path -Path "$cwd\build\$($file.BaseName).exe" )) {
            Start-Sleep 1
        }
        $value = (Get-FileHash -Path "$cwd\build\$($file.BaseName).exe" -Algorithm SHA256).Hash + "  $($file.BaseName).exe"
        Tee-Object -Append -InputObject $value -FilePath $cwd\build\checksums_v$version.txt
    }   
}

else {
    if (!(Test-Path -Path "$cwd\test")) {
        mkdir $cwd\test
    }
    foreach ($file in (Get-ChildItem -Path $cwd\*.ahk)) {
        Write-Host $file.BaseName
        Invoke-Expression($testcommand + " /in $file")
        while ( !(Test-Path -Path "$cwd\test\$($file.BaseName).exe" )) {
            Start-Sleep 1
        }
    }
}
