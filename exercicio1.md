# Aula 2 - MercadoÁgil

As queries tão no exercicios.sql. Rodei tudo no https://pglite.dev/repl e bateu com o resultado esperado.

## B1 - comparativo

| | Relacional (SQL) | Documentos (NoSQL) |
|---|---|---|
| Como guarda | tabelas ligadas por id | um JSON com tudo dentro |
| Esquema | fixo, tem que definir as colunas antes | livre, cada documento pode ter campos diferentes |
| Como liga as coisas | JOIN pela FK | coloca dentro do documento ou guarda o id e busca de novo |
| Como evita repetir dado | normalizando, cada dado fica num lugar so | referenciando o que muda em vez de copiar |
| Pergunta boa pra ele | quanto cada vendedor faturou | me mostra o pedido 3 inteiro |
| Maior risco | muito JOIN e esquema dificil de mudar | a copia ficar diferente (tipo a Ana com duas regioes) |

## B2 - qual banco usar

1. Pedidos e pagamentos: relacional. Dinheiro nao pode ficar diferente em dois lugares.
2. Catalogo de produtos: documentos. Notebook e camiseta tem campos nada a ver, numa tabela ia ficar cheio de coluna vazia.
3. Busca "presente pra quem gosta de corrida": busca semantica. Os produtos nao tem essas palavras no nome, entao so buscando pelo significado.
4. Perfil do usuario: documentos. O app le ele inteiro toda vez, entao e melhor ter tudo junto.
5. Relatorio mensal por categoria: relacional. E SUM com GROUP BY, o SQL faz isso facil.

Por que usar os tres juntos?
- Pro time: cada parte do sistema pergunta uma coisa diferente, entao cada uma usa o banco que responde melhor.
- Pro cliente: o pedido sai certo, a pagina abre rapido e a busca acha o que ele quis dizer.

## Exercicio 3

```js
{
  _id: 3,
  cliente: { nome: 'Ana Souza', regiao: 'Nordeste' },
  status: 'entregue',
  criadoEm: '2026-10-12',
  itens: [
    { produto: 'Livro de JavaScript', quantidade: 1, precoUnitario: 80 },
    { produto: 'Livro de SQL', quantidade: 1, precoUnitario: 90 }
  ]
}
```

- Vantagem: pega o pedido todo de uma vez, sem JOIN.
- Custo: se a Ana mudar de regiao tem que atualizar todos os pedidos dela, e se esquecer algum fica errado.
- Embutir ou referenciar o nome dela? Eu embutiria. O pedido e tipo uma nota fiscal, tem que mostrar os dados da epoca da compra, igual o preco_unitario. O cadastro atual dela fica no perfil.

## Exercicio 4

- Busca por "presente pra quem gosta de cafe": busca semantica, porque muito produto nao tem "cafe" no nome e a busca por palavra nao ia achar nada.
- "Bora guardar tudo em documento que e mais facil": discordo. Pedido e pagamento tem que bater sempre, e copiando dado em varios lugares uma hora fica diferente. Documento serve pro catalogo e pro perfil, nao pro dinheiro.
