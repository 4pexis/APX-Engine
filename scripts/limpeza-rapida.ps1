# APX Engine - limpeza rapida (sem perguntas)
# Mesmos alvos do limpeza-ssd.ps1, sem as etapas opcionais (hibernacao e WinSxS).
# Rode como ADMINISTRADOR. Feche CapCut, o navegador e o overlay/app da NVIDIA antes.

$L=$env:LOCALAPPDATA; $antes=(Get-PSDrive C).Free
"$L\NVIDIA\DXCache","$L\NVIDIA\GLCache","$L\NVIDIA Corporation\NVIDIA Overlay\CefCache","C:\ProgramData\NVIDIA Corporation\NVIDIA App\UpdateFramework",$env:TEMP,"C:\Windows\Temp","$L\npm-cache","$L\Microsoft\WinGet\Packages","C:\Windows\SoftwareDistribution\Download" | ForEach-Object { Get-ChildItem -LiteralPath $_ -Force -EA 0 | Remove-Item -Recurse -Force -EA 0 }
if (Test-Path "$L\CapCut\Apps\1.5.0.230\CapCut.exe") { Get-ChildItem "$L\CapCut\Apps" -Directory | Where-Object Name -match '^9\.' | Remove-Item -Recurse -Force -EA 0 }
Remove-Item "$L\CapCut\User Data\Download\update.exe" -Force -EA 0
"Liberado: {0:N2} GB" -f (((Get-PSDrive C).Free-$antes)/1GB)