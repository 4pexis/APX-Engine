# Limpeza segura do disco C: - gerado a partir da analise do PC
# Rode como ADMINISTRADOR. Feche CapCut, Brave e o overlay/app da NVIDIA antes.

$ErrorActionPreference = 'SilentlyContinue'
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Host "Abra o PowerShell como Administrador e rode de novo." -ForegroundColor Red; Read-Host "Enter para sair"; exit }

function Livre { [math]::Round((Get-PSDrive C).Free/1GB,2) }
function Limpar($caminho, $desc) {
    if (Test-Path -LiteralPath $caminho) {
        Write-Host "Limpando: $desc" -ForegroundColor Cyan
        Get-ChildItem -LiteralPath $caminho -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$inicio = Livre
Write-Host "Espaco livre antes: $inicio GB`n" -ForegroundColor Yellow

$L = $env:LOCALAPPDATA

# 1. Caches da NVIDIA (recriados automaticamente)
Limpar "$L\NVIDIA\DXCache"                                   "Cache de shaders NVIDIA (~9,5 GB)"
Limpar "$L\NVIDIA\GLCache"                                   "Cache OpenGL NVIDIA"
Limpar "$L\NVIDIA Corporation\NVIDIA Overlay\CefCache"       "Cache do overlay NVIDIA (~3,8 GB)"
Limpar "C:\ProgramData\NVIDIA Corporation\NVIDIA App\UpdateFramework" "Instaladores de driver ja baixados (~4,5 GB)"

# 2. CapCut: remove TODAS as versoes 9.x, mantem so a 1.5.0.230
$capApps = "$L\CapCut\Apps"
if (Test-Path "$capApps\1.5.0.230\CapCut.exe") {
    Get-ChildItem $capApps -Directory | Where-Object { $_.Name -match '^9\.' } | ForEach-Object {
        Write-Host "Removendo CapCut antigo $($_.Name)" -ForegroundColor Cyan
        Remove-Item $_.FullName -Recurse -Force
    }
}
Remove-Item "$L\CapCut\User Data\Download\update.exe" -Force

# 3. Temporarios e caches de ferramentas
Limpar $env:TEMP                       "Temp do usuario"
Limpar "C:\Windows\Temp"               "Temp do Windows"
Limpar "$L\npm-cache"                  "Cache do npm"
Limpar "$L\Microsoft\WinGet\Packages"  "Instaladores baixados pelo WinGet"
Limpar "C:\Windows\SoftwareDistribution\Download" "Downloads antigos do Windows Update"

Write-Host "`nLiberado ate aqui: $([math]::Round((Livre) - $inicio,2)) GB`n" -ForegroundColor Green

# 4. Opcional: hibernacao (~6,4 GB)
$r = Read-Host "Desativar hibernacao e liberar ~6,4 GB? (perde a 'inicializacao rapida', irrelevante em SSD) [s/N]"
if ($r -eq 's') { powercfg /h off; Write-Host "Hibernacao desativada." -ForegroundColor Green }

# 5. Opcional: limpeza de componentes antigos do Windows (demora 5-15 min)
$r = Read-Host "Limpar componentes antigos de atualizacoes do Windows (WinSxS)? [s/N]"
if ($r -eq 's') { Dism.exe /Online /Cleanup-Image /StartComponentCleanup }

Write-Host "`nEspaco livre agora: $(Livre) GB (antes: $inicio GB)" -ForegroundColor Yellow
Read-Host "Enter para sair"
