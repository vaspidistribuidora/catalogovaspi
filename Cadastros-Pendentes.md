# Cadastros pendentes

Códigos que o usuário já reservou/relacionou a um produto, mas que ainda não
existem no catálogo (sem foto, preço ou PN definitivo). Quando for feito o
cadastro completo desses itens, usar esta relação para saber onde cada
código se encaixa.

## Lâmpada Haloppen G9 Led

| Código | Modelo (W) | Variação      |
|--------|-----------|----------------|
| 13354  | 12W       | Branca Fria    |
| 13352  | 10W       | Branca Fria    |
| 13417  | 10W       | Branca Fria    |
| 4222   | 7W        | Branca Fria    |
| 13394  | 7W        | Branca Fria    |
| 4220   | 5W        | Branca Quente  |

Origem: pedido do usuário em 24/08/2026, ao lado dos códigos já existentes
(12W BQ=13481, 10W BQ=4213, 7W BQ=4223, 5W BF=4219, 3W BF=4215, 3W BQ=4216 —
esses já estavam corretos no catálogo e não precisaram de alteração).

## Lâmpada Vapor Ovoide — RESOLVIDO em 25/08/2026

Não eram itens novos: existiam desativados em removidos.json desde
antes desta sessão ("Produto descontinuado"), sob os nomes "Lâmpada
Vapor Sódio Ovoide" e "Lâmpada Vapor Mercúrio Ovoide" (não "Metálico",
como eu tinha suposto por engano na primeira análise). Usuário deu os
códigos, reativei e organizei como "Lâmpada Vapor Ovoide", modelo
Sódio/Mercúrio: 0004301 (Sódio 70W), 0004300 (Sódio 250W), 0004288
(Mercúrio 80W), 0004287 (Mercúrio 125W).

## Pendente Retro Metal — Bronze

Produto_base novo, ainda sem nenhum item cadastrado (nem ativo nem em
removidos.json) — procurei em todo o catálogo e não achei nenhum
código com esse nome. Precisa de 2 itens (1 Metro e 2 Metros), iguais
aos outros 6 grids de cor já organizados (Cobre, Cobre Envelhecido,
Cromado, Dourado, Latonado, Niquelado).

Origem: pedido do usuário em 25/08/2026 ("O que temos é: Niquelado,
Cromado, latonado, cobre envelhecido, cobre, Dourado, Bronze").
Quando tiver os códigos, produto_base = "Pendente Retro Metal
Bronze", modelo = "1 Metro" / "2 Metros", variação vazia (mesmo
padrão dos outros).

## Quadro de Distribuição com Kit Barramento — Sobrepor 70A/225A

Código **0008131** ("QUADRO DIST SOBREPOR 570 DISJ 225A C/KIT
BARRAMENTO TRIF", print da tela do ERP em 02/09/2026) — o "570"
provavelmente é erro de digitação/leitura (o Embutido tem exatamente
"70 DISJ 225A" na mesma faixa), mas o usuário pediu pra checar no
sistema deles antes de decidir. Não cadastrado ainda.

Os outros 9 códigos da mesma leva já foram cadastrados em 02/09/2026
como produto_base "Quadro de Distribuição com Kit Barramento",
modelo "Trifásico - Embutido" (base PN 1182, 6 itens) e "Trifásico -
Sobrepor" (base PN 1192, 3 itens: 0008711 44A/100A, 0008726 44A/150A,
0008727 56A/225A).

Quando o usuário confirmar o código 0008131: se for realmente "70"
(duplicata do Embutido 70/225A só que versão Sobrepor), vira
`1192.04`, variação "70 Disjuntores 225A". Se for outra coisa (570
disjuntores de verdade), perguntar como classificar antes de
cadastrar.
