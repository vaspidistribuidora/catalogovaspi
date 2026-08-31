# Catálogo Digital Vaspi — estado do projeto

Documento de referência pra retomar o trabalho em qualquer computador.
Última atualização: 31/08/2026.

## O que é este projeto

Catálogo digital da Vaspi Distribuidora — um site estático (HTML puro,
sem servidor/backend) publicado no GitHub Pages, que os vendedores usam
pra mostrar produtos aos clientes e os clientes usam pra montar pedidos
(carrinho + envio por WhatsApp).

- **Site público:** https://vaspidistribuidora.github.io/catalogovaspi/catalogo-digital.html
- **Repositório:** github.com/vaspidistribuidora/catalogovaspi
- **Pasta local:** esta pasta (`Catalogo-v12`) é a única fonte de verdade — o
  que está aqui e commitado no git é exatamente o que está no ar.

## Arquivos principais

| Arquivo | Pra que serve |
|---|---|
| `produtos.json` / `produtos.js` | Os dados do catálogo (mesma informação nos dois formatos — `produtos.js` é só `window.PRODUTOS = [...]`, existe pra funcionar em `file://` sem servidor). **Este é o arquivo que muda a cada correção.** |
| `catalogo-digital.html` | O site público que os clientes veem. |
| `admin.html` | Painel interno de gestão — cadastro de produtos, e a aba **Vitrine** (organização visual dos cards, trocar fotos, arrastar pra reordenar). |
| `removidos.json` | Histórico de produtos desativados (com o motivo). Nada é apagado de verdade, só sai de `produtos.json` e entra aqui. |
| `Cadastros-Pendentes.md` | Lista de produtos que o usuário pediu pra organizar mas ainda não têm código/PN definitivo — fica registrado aqui até virar item de verdade. |
| `Scripts/auditar_catalogo.ps1` | Script de auditoria — ver seção abaixo. |
| `Backups/Backup NN/` | Uma cópia de segurança de `produtos.json`/`produtos.js`/`removidos.json` antes de cada mudança estrutural, com um `o-que-mudou.txt` explicando o que foi feito. |

## Como o catálogo é organizado (hierarquia dos dados)

Cada produto em `produtos.json` tem:

```
categoria → linha (subcategoria) → produto_base → modelo → variação
```

- **categoria + linha** definem em que seção da página o produto aparece
  (ex.: "Material Elétrico > Instalação Residencial").
- **produto_base** é o nome do card/grid que o cliente vê.
- **modelo** separa o card em abas internas (ex.: "1 Tecla" / "2 Teclas").
  Também pode fazer o card virar **vários cards separados** quando o
  campo `split: true` está marcado no item.
- **variação** é a linha clicável dentro de cada aba (cor, amperagem,
  tamanho etc.), ligada a um código de produto (`codigo_principal`) e um
  PN (`pn`, formato `base.sufixo`, ex. `1063.02`).
- **selo** é a "tag" colorida do card (Slim, Ideale, Lisse, Safira, Jeri,
  SX CJ) — mostra a linha/marca do produto.

**Regra de ouro "cada grid um PN":** todo item com o mesmo
produto_base + modelo tem que usar a mesma *base* de PN (a parte antes
do ponto). Modelos diferentes podem (e devem) usar bases diferentes.

## O script de auditoria — rodar sempre antes de publicar

```bash
powershell -File Scripts/auditar_catalogo.ps1 "<caminho da pasta>"
```

Verifica 4 coisas que já causaram bugs visuais reais no catálogo (cards
duplicados, produto sozinho no lugar errado):

1. Uma `linha` não pode ter mais de uma `categoria`.
2. Um `produto_base` não pode ter mais de uma combinação categoria+linha.
3. Um mesmo produto_base+modelo não pode usar mais de uma base de PN.
4. Nenhum PN pode se repetir no catálogo inteiro.

Sai com erro (exit 1) se achar problema. **Hoje ele sempre acusa 2
problemas que já são conhecidos e aceitos** (não são bugs novos):

- `Interruptor Simples` existe em duas linhas (Caixas e Canaletas / SX,
  e Instalação Residencial) — são produtos genuinamente diferentes com
  nome igual, não duplicata.
- 10 produto_base antigos com a base de PN dividida entre modelos
  (backlog de antes desta limpeza, listados na seção de pendências).

Se o audit acusar **qualquer outra coisa**, é bug de verdade — não
publicar antes de corrigir.

## Fluxo de trabalho pra qualquer mudança estrutural

1. Testar o script de alteração numa cópia em pasta temporária primeiro.
2. Criar `Backups/Backup NN/` com a cópia de produtos.json/js/removidos.json
   ANTES de aplicar, e escrever o `o-que-mudou.txt` explicando a mudança.
3. Aplicar na pasta real.
4. Rodar `auditar_catalogo.ps1` — só publicar se o resultado bater com o
   esperado (2 problemas conhecidos, nada novo).
5. `git add` + `git commit` + `git push origin main` — o GitHub Pages
   publica sozinho em seguida (pode levar até ~10 min pra propagar pra
   quem já tinha o site aberto, é cache do próprio GitHub Pages, não dá
   pra configurar diferente).

**Cuidado ao mover um produto de linha:** sempre trocar `categoria` E
`linha` juntos (olhando qual categoria aquela linha de destino já usa),
e reposicionar o item fisicamente no array pra perto de produtos
parecidos — nunca só mudar os campos e deixar o item "solto" onde
estava antes. Os dois erros já causaram bug visual (card duplicado /
item sozinho) várias vezes nesta limpeza.

## Fluxo de fotos e reorganização visual (admin ↔ Claude)

O admin (`admin.html`, aba Vitrine) é onde se troca foto de produto e se
arrasta os cards pra mudar a ordem. Isso é feito **direto no navegador**
e fica salvo só ali (no `localStorage` do navegador) até ser exportado.

Passo a passo:
1. Na Vitrine, clicar em **"↻ Carregar do arquivo"** primeiro se houver
   dúvida se os dados estão atualizados.
2. Trocar fotos / arrastar cards pra reordenar à vontade.
3. Clicar em **"↓ Baixar produtos.js"** (aba Exportar/Backup).
4. Mandar o arquivo baixado pro Claude, com um "atualiza aí".

O Claude então:
- Compara o arquivo enviado com o `produtos.json` atual, item por item.
- Aplica **somente** fotos (`card_img`, `img_data`) e a nova ordem dos
  cards.
- **Ignora** `codigos_secundarios` e `split` quando vêm vazios/diferentes
  no export — são artefatos do processo do admin, aplicá-los cegamente
  apagaria dado real ou não muda nada visualmente.
- Se o export foi feito a partir de uma versão antiga (antes de alguma
  correção de categoria/linha já publicada), o Claude detecta e ignora
  essas partes revertidas, avisando qual.

**Não existe hoje uma forma 100% automática** (sem baixar/enviar
arquivo) — o Firebase do projyecto existe mas está desatualizado (não é
usado como fonte real) e não tem permissão de escrita aberta pra eu
usar como ponte. Foi avaliado e descartado por enquanto.

## O que foi feito nesta limpeza (resumo, não exaustivo)

- Reorganização completa de dezenas de produto_base para eliminar
  nomes redundantes, modelos sem nome, e a regra "cada grid um PN"
  (Interruptores Slim/Ideale/Lisse/Safira por tecla, Rele Fotoelétrico,
  Sensores, Lâmpada Vapor, Pendente Retro Metal, Cabo para Pendente
  Colorido, Emenda para Trilho, Placas SX CJ, etc.)
- Correção de vários casos de "produto cadastrado na categoria/linha
  errada" (Jeri, Barra Rígida, Chave Fusível, Conector P4, Keystone
  RJ45, Nipel, Extensão Cordão, Pino 3 Saídas, etc.)
- Remoção de vários duplicados reais (mesmo produto com 2 códigos).
- Eliminada a linha "Conexão de Áudio" (não tinha nenhum produto de
  áudio de verdade).
- Botão "voltar ao topo" no catálogo público.
- Correção de cache: o catálogo agora sempre busca `produtos.json`
  fresco (sem cache do navegador) — resolve o problema de cliente/
  vendedor ver versão desatualizada, inclusive no ícone salvo na tela
  de início do iPhone.
- `touch-action: manipulation` no catálogo público — evita zoom
  acidental por clique duplo sem desativar o zoom por pinça (importante
  pra clientes com dificuldade de leitura de texto pequeno).
- Criado o script permanente de auditoria e o hábito de rodar antes de
  cada publicação.

Histórico completo, com todos os detalhes de cada mudança, está em
`Backups/Backup 31/` até `Backup 67/` (o mais recente) — cada pasta tem
um `o-que-mudou.txt`.

## Pendências

### 1. Cadastro de produtos novos (sem código/PN ainda)
Ver `Cadastros-Pendentes.md` — hoje contém:
- **Pendente Retro Metal — Bronze**: falta cadastrar 2 itens (1 Metro
  e 2 Metros), mesmo padrão dos outros 6 grids de cor já organizados.

### 2. Backlog de PN dividido (10 produto_base antigos)
Grupos onde o mesmo modelo usa 2 bases de PN diferentes — erro antigo,
de antes desta limpeza, aceito como backlog até o usuário pedir a
renumeração completa:
Caixa de Passagem Plástica (Embutir e Sobrepor), Caixa com Tomada 20A
(Sobrepor), Bloco de Contato, Refletor Led com Placa Solar, Luminária
Pública (Sem Relé), Luminária Galpão (UFO), Luminária de Emergência
(Farol), Acabamento de Perfil Sobrepor, Controle para Fita de Led.

### 3. Cards com modelo sem nome — aguardando decisão do usuário
Levantamento feito, mas o usuário ainda não respondeu quais nomes dar
pra estes (a primeira leva de nomes óbvios nunca chegou a ser aplicada
porque a conversa seguiu pra outros pedidos):
- Módulo Interruptor Slim: item "25A 250V" sem modelo
- Emenda para Trilho: nome "Modular" (mantido nesta limpeza, ok)
- Filtro de Linha: modelo existente chamado literalmente **"Modelo Novo
  Preto"** (parece erro de digitação/placeholder — vale revisar)
- Borne SAK: 5 itens sem modelo (tamanhos A–E)
- Poste de Jardim: 4 itens sem modelo, parecem produtos diferentes entre
  si (não um "modelo" só)
- Canivete: "Boker" e "Tático" sem modelo — parecem marcas/linhas
  diferentes
- Vídeo Porteiro Eletrônico: item "Extensão Tela 4.3"" — é acessório,
  não modelo de posto

### 4. Firebase desatualizado
O Firebase do projeto (`catalogotestevaspi`, coleção `catalogo/produtos`)
está com 3366 itens salvos — bem desatualizado em relação aos 3317 reais
de hoje. Não é usado como fonte de dados no fluxo atual (o catálogo
público prioriza o arquivo, não o Firebase), então não é urgente, mas
seria bom resolver antes de contar com ele pra qualquer coisa.

## Referências úteis

- Selos/tags de linha: Slim, Ideale, Lisse, Safira, Jeri, SX CJ.
- Convenção de posicionamento no PowerShell: ao mover produto_base entre
  linhas, sempre reposicionar fisicamente perto de um produto
  relacionado (nunca deixar "solto" na ordem antiga).
- Ao escrever scripts PowerShell com acento (á, é, ç, ã etc.) rodados via
  `-File`, nunca usar o caractere acentuado direto no texto do script —
  construir a string via `[char]0x00XX` (codepoint), senão o acento pode
  corromper ao salvar. Isso já causou bug de dado salvo errado mais de
  uma vez nesta limpeza.
