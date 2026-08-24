# auditar_catalogo.ps1
#
# RODAR ISSO SEMPRE, DEPOIS DE QUALQUER SCRIPT QUE MEXA EM produto_base,
# modelo, categoria ou linha -- E ANTES DE PUBLICAR (git push).
#
# Detecta os 2 tipos de bug que ja se repetiram varias vezes nesse projeto:
#
# 1) MESMA LINHA COM CATEGORIA DIFERENTE
#    Toda vez que um item muda de "linha" (subgrupo) mas o campo
#    "categoria" nao e atualizado junto pra bater com a categoria real
#    daquele subgrupo, o card vira 2 blocos separados na tela (um
#    cabecalho "Categoria Errada > Subgrupo" com o item sozinho, e o
#    resto do subgrupo aparecendo em outro lugar sob a categoria certa).
#
# 2) MESMO PRODUTO_BASE COM CATEGORIA+LINHA DIFERENTE
#    Quando um grid e dividido/criado e algum item fica com
#    categoria+linha diferente dos irmaos dele no mesmo produto_base,
#    vira 2 cards separados em vez de 1 (mesmo bug, outro angulo).
#
# 3) PN BASE COMPARTILHADA ENTRE MODELOS DIFERENTES DO MESMO PRODUTO_BASE
#    Regra "cada grid um PN": mesmo produto_base + mesmo modelo deve
#    usar 1 unica base de PN. Modelos diferentes podem (e devem) ter
#    bases diferentes -- o problema e quando o MESMO modelo fica
#    dividido em mais de uma base.
#
# Uso:
#   powershell -File auditar_catalogo.ps1 "caminho\para\Catalogo-v12"
#
# Sai com exit code 1 se achar qualquer problema (pra travar automacao
# se algum dia isso virar um pipeline). Sempre le direto do
# produtos.json, nao de cache nenhum.

$ErrorActionPreference = "Stop"
$dir = $args[0]
if (-not $dir) { $dir = "." }
$jsonPath = Join-Path $dir "produtos.json"
$json = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

$problemas = 0

Write-Host "=== Auditoria do catalogo ($($json.Count) itens) ==="
Write-Host ""

# ---- 1) linha com mais de uma categoria ----
Write-Host "--- 1) LINHA com categoria inconsistente ---"
$linhaBug = $false
$json | Group-Object linha | ForEach-Object {
  $cats = $_.Group | Select-Object -ExpandProperty categoria -Unique
  if ($cats.Count -gt 1) {
    $linhaBug = $true
    Write-Host "  PROBLEMA: linha=[$($_.Name)] tem $($cats.Count) categorias:"
    foreach ($c in $cats) {
      $n = ($_.Group | Where-Object { $_.categoria -eq $c }).Count
      $exemplo = ($_.Group | Where-Object { $_.categoria -eq $c } | Select-Object -First 1).codigo_principal
      Write-Host "    categoria=[$c] => $n itens (ex: $exemplo)"
    }
  }
}
if (-not $linhaBug) { Write-Host "  OK - nenhuma linha com categoria dividida" } else { $problemas++ }
Write-Host ""

# ---- 2) produto_base com mais de uma combinacao categoria+linha ----
Write-Host "--- 2) PRODUTO_BASE com categoria+linha inconsistente ---"
$pbBug = $false
$json | Group-Object produto_base | ForEach-Object {
  $combos = $_.Group | ForEach-Object { "$($_.categoria)||$($_.linha)" } | Select-Object -Unique
  if ($combos.Count -gt 1) {
    $pbBug = $true
    Write-Host "  PROBLEMA: produto_base=[$($_.Name)] tem $($combos.Count) combinacoes categoria+linha:"
    foreach ($combo in $combos) {
      $n = ($_.Group | Where-Object { "$($_.categoria)||$($_.linha)" -eq $combo }).Count
      Write-Host "    $combo => $n itens"
    }
  }
}
if (-not $pbBug) { Write-Host "  OK - nenhum produto_base dividido por categoria/linha" } else { $problemas++ }
Write-Host ""

# ---- 3) mesmo produto_base + modelo com mais de uma base de PN ----
Write-Host "--- 3) MODELO com PN base dividida (viola 'cada grid um PN') ---"
$pnBug = $false
$json | Group-Object produto_base, modelo | ForEach-Object {
  $bases = $_.Group | ForEach-Object {
    if ($_.pn) { ($_.pn -split '\.')[0] } else { $null }
  } | Where-Object { $_ } | Select-Object -Unique
  if ($bases.Count -gt 1) {
    $pnBug = $true
    Write-Host "  PROBLEMA: $($_.Name) => bases: $($bases -join ', ')"
  }
}
if (-not $pnBug) { Write-Host "  OK - todo modelo usa 1 base de PN so" } else { $problemas++ }
Write-Host ""

# ---- 4) PN duplicado no catalogo inteiro ----
Write-Host "--- 4) PN duplicado ---"
$dupPn = $json | Group-Object pn | Where-Object { $_.Count -gt 1 }
if ($dupPn.Count -eq 0) {
  Write-Host "  OK - nenhum PN duplicado"
} else {
  $problemas++
  $dupPn | ForEach-Object { Write-Host "  PROBLEMA: PN=[$($_.Name)] usado por $($_.Count) itens" }
}
Write-Host ""

if ($problemas -eq 0) {
  Write-Host "=== TUDO OK - seguro publicar ==="
  exit 0
} else {
  Write-Host "=== $problemas TIPO(S) DE PROBLEMA ENCONTRADO(S) - corrigir antes de publicar ==="
  exit 1
}
