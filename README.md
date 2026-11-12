# APX Engine

Scripts em PowerShell para liberar espaço no disco **C:** do Windows, removendo apenas
caches e arquivos temporários que o sistema e os programas recriam sozinhos.

Feito para um SSD pequeno (≈111 GB) que vivia cheio por causa dos caches da NVIDIA,
versões antigas do CapCut e instaladores esquecidos.

## Scripts

| Script | O que faz | Apaga algo? |
|---|---|---|
| [`scripts/analisar-espaco.ps1`](scripts/analisar-espaco.ps1) | Mostra quanto cada alvo ocupa e o total que pode ser liberado | **Não** |
| [`scripts/limpeza-ssd.ps1`](scripts/limpeza-ssd.ps1) | Limpeza completa, com progresso e duas etapas opcionais (pergunta antes) | Sim |
| [`scripts/limpeza-rapida.ps1`](scripts/limpeza-rapida.ps1) | Mesma limpeza em poucas linhas, sem perguntas | Sim |

## Como usar

**1. Veja antes o que será liberado** (não precisa de administrador):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\analisar-espaco.ps1
```

Exemplo de saída:

```
Alvo                                GB   Caminho
----                                --   -------
CapCut: 1 versao(oes) 9.x           1,77 C:\Users\...\AppData\Local\CapCut\Apps
Temp do usuario                     0,81 C:\Users\...\AppData\Local\Temp
Instaladores baixados pelo WinGet   0,65 C:\Users\...\AppData\Local\Microsoft\WinGet\Packages
...
Total que pode ser liberado: ~4,16 GB
```

**2. Feche** o CapCut, o navegador e o app/overlay da NVIDIA.

**3. Rode a limpeza** em um PowerShell aberto **como Administrador**:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\limpeza-ssd.ps1
```

O script mostra o espaço livre antes e depois. Arquivos em uso são pulados sem erro.

## O que é limpo

| Alvo | Por que é seguro |
|---|---|
| Caches de shader da NVIDIA (`DXCache`, `GLCache`) | Recriados ao abrir os jogos; o primeiro carregamento fica um pouco mais lento |
| Cache do overlay da NVIDIA | Cache de navegador embutido |
| Instaladores de driver já baixados | Sobras de atualizações já instaladas |
| Temp do usuário e do Windows | Arquivos temporários |
| Cache do npm e instaladores do WinGet | Baixados de novo quando necessário |
| Downloads antigos do Windows Update | Atualizações já aplicadas |
| CapCut: versões `9.x` | Só se a versão `1.5.0.230` estiver instalada (veja abaixo) |

Etapas opcionais do `limpeza-ssd.ps1` (ele pergunta antes de cada uma):

- **Desativar a hibernação** — libera o `hiberfil.sys` (vários GB), mas desliga a hibernação e a inicialização rápida.
- **Limpar componentes antigos do Windows (WinSxS)** — demora de 5 a 15 minutos e impede desinstalar atualizações já aplicadas.

Detalhes de cada item em [`docs/o-que-e-limpo.md`](docs/o-que-e-limpo.md).

## Atenção

- **Nada vai para a Lixeira.** O que é apagado não pode ser recuperado.
- **A regra do CapCut é específica deste PC:** ela mantém a versão `1.5.0.230` e apaga as `9.x`.
  Se você usa outra versão, edite ou remova esse trecho antes de rodar.
- **Salve seu trabalho antes:** a pasta Temp pode conter arquivos de programas abertos.
- Testado no Windows 10 com Windows PowerShell 5.1.

## Licença

[MIT](LICENSE)
