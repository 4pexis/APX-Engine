# O que cada etapa limpa

Todos os caminhos usam `%LOCALAPPDATA%` (normalmente `C:\Users\<você>\AppData\Local`).
Os scripts apagam o **conteúdo** das pastas, não as pastas em si.

## NVIDIA

| Caminho | O que é | Efeito de apagar |
|---|---|---|
| `%LOCALAPPDATA%\NVIDIA\DXCache` | Shaders compilados (DirectX) | Jogos recompilam no próximo início; pode haver travadinhas na primeira partida |
| `%LOCALAPPDATA%\NVIDIA\GLCache` | Shaders compilados (OpenGL) | Igual ao anterior |
| `%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Overlay\CefCache` | Cache do navegador embutido do overlay | Nenhum visível |
| `C:\ProgramData\NVIDIA Corporation\NVIDIA App\UpdateFramework` | Instaladores de driver já usados | Nenhum; o app baixa de novo na próxima atualização |

Costuma ser o maior ganho: o `DXCache` cresce sem limite e chega a vários GB.

## CapCut

O CapCut guarda cada versão em `%LOCALAPPDATA%\CapCut\Apps\<versão>`.

A limpeza remove as pastas cujo nome começa com `9.` **somente se** existir
`Apps\1.5.0.230\CapCut.exe`. Sem essa versão instalada, nada do CapCut é tocado,
exceto o instalador de atualização `User Data\Download\update.exe`.

> Essa regra reflete uma escolha pessoal (manter a 1.5.0.230). Adapte a versão
> no script se o seu caso for outro.

## Temporários e caches de ferramentas

| Caminho | O que é |
|---|---|
| `%TEMP%` | Temporários do usuário |
| `C:\Windows\Temp` | Temporários do sistema (precisa de administrador) |
| `%LOCALAPPDATA%\npm-cache` | Pacotes baixados pelo npm |
| `%LOCALAPPDATA%\Microsoft\WinGet\Packages` | Instaladores baixados pelo WinGet |
| `C:\Windows\SoftwareDistribution\Download` | Arquivos de atualizações do Windows já instaladas |

Arquivos abertos por algum programa são pulados silenciosamente.

## Etapas opcionais (`limpeza-ssd.ps1`)

### Hibernação

`powercfg /h off` remove o arquivo `C:\hiberfil.sys`, cujo tamanho é uma fração da memória RAM.

- Perde: o modo hibernar e a inicialização rápida do Windows.
- Para voltar atrás: `powercfg /h on` em um PowerShell de administrador.

### Componentes antigos do Windows

`Dism.exe /Online /Cleanup-Image /StartComponentCleanup` remove versões substituídas
de componentes guardadas em `C:\Windows\WinSxS`.

- Demora de 5 a 15 minutos.
- Depois disso, atualizações já instaladas não podem mais ser desinstaladas.

## O que os scripts **não** fazem

- Não apagam documentos, downloads, fotos nem nada das pastas pessoais.
- Não desinstalam programas (apenas versões antigas do CapCut, na regra acima).
- Não mexem no registro nem em outros discos além do C:.
