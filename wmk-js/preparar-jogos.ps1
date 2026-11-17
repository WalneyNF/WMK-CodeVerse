param([Parameter(Mandatory=$true)][string]$Distribution)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path -Parent $PSScriptRoot
Copy-Item (Join-Path $root 'wmk-js/jogos-iniciais/WMK-Jogo-JavaScript') (Join-Path $Distribution 'WMK-Jogo-JavaScript') -Recurse -Force
Copy-Item (Join-Path $root 'wmk-js/jogos-iniciais/WMK-Jogo-Portugol') (Join-Path $Distribution 'WMK-Jogo-Portugol') -Recurse -Force
Copy-Item (Join-Path $root 'wmk-js/jogos-iniciais/README.md') (Join-Path $Distribution 'COMO-CRIAR-JOGOS.md') -Force
Copy-Item (Join-Path $root 'wmk-language-kit') (Join-Path $Distribution 'WMK-Language-Kit') -Recurse -Force
Copy-Item (Join-Path $root 'wmk-portugol') (Join-Path $Distribution 'WMK-Portugol') -Recurse -Force
$compiler=Join-Path $root 'wmk-portugol/compilador.py'
$source=Join-Path $Distribution 'WMK-Jogo-Portugol/jogador.por'
$target=Join-Path $Distribution 'WMK-Jogo-Portugol/jogador.gd'
python $compiler $source -o $target
if ($LASTEXITCODE -ne 0 -or !(Test-Path $target)) { throw 'Falha ao compilar jogo Portugol' }
Write-Host 'Projetos de jogos JS e Portugol preparados.'
