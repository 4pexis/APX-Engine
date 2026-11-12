# APX Engine - analise de espaco
# Mostra quanto cada alvo da limpeza ocupa no disco C:. NAO apaga nada.
# Pode rodar sem administrador (algumas pastas do Windows podem aparecer menores).

$L = $env:LOCALAPPDATA

# Mesmos alvos do limpeza-ssd.ps1
$alvos = [ordered]@{
    'Cache de shaders NVIDIA (DXCache)'       = "$L\NVIDIA\DXCache"
    'Cache OpenGL NVIDIA (GLCache)'           = "$L\NVIDIA\GLCache"
    'Cache do overlay NVIDIA'                 = "$L\NVIDIA Corporation\NVIDIA Overlay\CefCache"
    'Instaladores de driver NVIDIA'           = 'C:\ProgramData\NVIDIA Corporation\NVIDIA App\UpdateFramework'
    'Temp do usuario'                         = $env:TEMP
    'Temp do Windows'                         = 'C:\Windows\Temp'
    'Cache do npm'                            = "$L\npm-cache"
    'Instaladores baixados pelo WinGet'       = "$L\Microsoft\WinGet\Packages"
    'Downloads antigos do Windows Update'     = 'C:\Windows\SoftwareDistribution\Download'
}

function Tamanho($caminho) {
    # Bytes ocupados pela pasta; $null se ela nao existe.
    if (-not (Test-Path -LiteralPath $caminho)) { return $null }
    $soma = (Get-ChildItem -LiteralPath $caminho -Recurse -Force -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    if ($null -eq $soma) { return 0 }
    return $soma
}

function Linha($nome, $bytes, $caminho) {
    [pscustomobject]@{
        Alvo    = $nome
        GB      = if ($null -eq $bytes) { 'nao existe' } else { '{0:N2}' -f ($bytes / 1GB) }
        Caminho = $caminho
        Bytes   = [double]$bytes
    }
}

Write-Host "Analisando o disco C: (nada sera apagado)...`n" -ForegroundColor Yellow

$linhas = @()
foreach ($alvo in $alvos.GetEnumerator()) {
    $linhas += Linha $alvo.Key (Tamanho $alvo.Value) $alvo.Value
}

# CapCut: versoes 9.x antigas (a limpeza so as remove se a 1.5.0.230 existir)
$capApps = "$L\CapCut\Apps"
if (Test-Path -LiteralPath $capApps) {
    $antigas = @(Get-ChildItem -LiteralPath $capApps -Directory | Where-Object { $_.Name -match '^9\.' })
    $bytes = 0
    foreach ($pasta in $antigas) { $bytes += Tamanho $pasta.FullName }
    $linhas += Linha "CapCut: $($antigas.Count) versao(oes) 9.x" $bytes $capApps
}

# Hibernacao (etapa opcional da limpeza)
$hiber = Get-Item -LiteralPath 'C:\hiberfil.sys' -Force -ErrorAction SilentlyContinue
if ($hiber) { $linhas += Linha 'Hibernacao (opcional)' $hiber.Length 'C:\hiberfil.sys' }

$linhas | Sort-Object Bytes -Descending | Format-Table Alvo, GB, Caminho -AutoSize

$total = ($linhas | Measure-Object -Property Bytes -Sum).Sum
$disco = Get-PSDrive C
Write-Host ("Total que pode ser liberado: ~{0:N2} GB" -f ($total / 1GB)) -ForegroundColor Green
Write-Host ("Espaco livre agora em C:     {0:N2} GB de {1:N2} GB" -f ($disco.Free / 1GB), (($disco.Free + $disco.Used) / 1GB))
Write-Host "`nArquivos em uso nao sao apagados, entao o valor real costuma ser um pouco menor."
