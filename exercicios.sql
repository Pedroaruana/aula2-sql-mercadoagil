-- MercadoÁgil | Módulo 2, Aula 2
-- Rodar em https://pglite.dev/repl (PostgreSQL no navegador)
-- Uma consulta de cada vez: selecione o trecho e execute.

-- =========================================================
-- ESTRUTURA (rode só se ainda não colou o setup.sql)
-- =========================================================

CREATE TABLE regiao (
  id INTEGER PRIMARY KEY,
  nome TEXT NOT NULL
);

CREATE TABLE cliente (
  id INTEGER PRIMARY KEY,
  nome TEXT NOT NULL,
  regiao_id INTEGER NOT NULL REFERENCES regiao (id)
);

CREATE TABLE vendedor (
  id INTEGER PRIMARY KEY,
  nome_loja TEXT NOT NULL
);

CREATE TABLE categoria (
  id INTEGER PRIMARY KEY,
  nome TEXT NOT NULL,
  comissao NUMERIC NOT NULL
);

CREATE TABLE produto (
  id INTEGER PRIMARY KEY,
  nome TEXT NOT NULL,
  preco NUMERIC NOT NULL,
  vendedor_id INTEGER NOT NULL REFERENCES vendedor (id),
  categoria_id INTEGER NOT NULL REFERENCES categoria (id)
);

CREATE TABLE pedido (
  id INTEGER PRIMARY KEY,
  cliente_id INTEGER NOT NULL REFERENCES cliente (id),
  status TEXT NOT NULL,
  criado_em DATE NOT NULL
);

CREATE TABLE item_pedido (
  pedido_id INTEGER NOT NULL REFERENCES pedido (id),
  produto_id INTEGER NOT NULL REFERENCES produto (id),
  quantidade INTEGER NOT NULL,
  preco_unitario NUMERIC NOT NULL,
  PRIMARY KEY (pedido_id, produto_id)
);

INSERT INTO regiao (id, nome) VALUES
  (1, 'Nordeste'), (2, 'Sudeste'), (3, 'Sul');

INSERT INTO cliente (id, nome, regiao_id) VALUES
  (1, 'Ana Souza', 1), (2, 'Bruno Lima', 2), (3, 'Carla Dias', 3),
  (4, 'Davi Nunes', 1), (5, 'Eva Rocha', 2);

INSERT INTO vendedor (id, nome_loja) VALUES
  (1, 'TechBahia'), (2, 'Livraria Sol'), (3, 'CasaViva');

INSERT INTO categoria (id, nome, comissao) VALUES
  (1, 'eletronicos', 8), (2, 'livros', 15), (3, 'casa', 10);

INSERT INTO produto (id, nome, preco, vendedor_id, categoria_id) VALUES
  (1, 'Mouse', 120, 1, 1),
  (2, 'Teclado', 350, 1, 1),
  (3, 'Livro de JavaScript', 80, 2, 2),
  (4, 'Livro de SQL', 90, 2, 2),
  (5, 'Luminária', 60, 3, 3),
  (6, 'Caneca', 25, 3, 3);

INSERT INTO pedido (id, cliente_id, status, criado_em) VALUES
  (1, 1, 'entregue', '2026-10-02'),
  (2, 2, 'entregue', '2026-10-05'),
  (3, 1, 'entregue', '2026-10-12'),
  (4, 3, 'cancelado', '2026-10-14'),
  (5, 4, 'entregue', '2026-10-20'),
  (6, 2, 'pendente', '2026-10-25'),
  (7, 1, 'entregue', '2026-10-28');

INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
  (1, 1, 1, 120), (1, 3, 1, 80),
  (2, 1, 2, 110),
  (3, 3, 1, 80), (3, 4, 1, 90),
  (4, 2, 1, 350),
  (5, 5, 2, 60), (5, 3, 1, 80),
  (6, 2, 1, 350),
  (7, 4, 2, 90);

-- Conferência: tem que dar 6
SELECT COUNT(*) FROM produto;

-- =========================================================
-- EXERCÍCIO DA AULA: PARTE A
-- =========================================================

-- Query 1: o catálogo
SELECT produto.nome, vendedor.nome_loja, categoria.comissao
FROM produto
JOIN vendedor ON vendedor.id = produto.vendedor_id
JOIN categoria ON categoria.id = produto.categoria_id
ORDER BY produto.nome;

-- Query 2: os baratos
SELECT nome, preco
FROM produto
WHERE preco < 100
ORDER BY preco;

-- Query 3: o que foi entregue
SELECT pedido.id, cliente.nome, pedido.criado_em
FROM pedido
JOIN cliente ON cliente.id = pedido.cliente_id
WHERE pedido.status = 'entregue'
ORDER BY pedido.criado_em;

-- Query 4: quem nunca comprou
SELECT cliente.nome
FROM cliente
LEFT JOIN pedido ON pedido.cliente_id = cliente.id
WHERE pedido.id IS NULL;

-- Query 5: pedidos por status
SELECT status, COUNT(*) AS pedidos
FROM pedido
GROUP BY status
ORDER BY status;

-- Query 6: o valor de cada pedido
SELECT pedido_id, SUM(quantidade * preco_unitario) AS total
FROM item_pedido
GROUP BY pedido_id
ORDER BY total DESC, pedido_id;

-- Query 7: o faturamento por vendedor (só entregues)
SELECT vendedor.nome_loja, SUM(item_pedido.quantidade * item_pedido.preco_unitario) AS faturamento
FROM item_pedido
JOIN pedido ON pedido.id = item_pedido.pedido_id
JOIN produto ON produto.id = item_pedido.produto_id
JOIN vendedor ON vendedor.id = produto.vendedor_id
WHERE pedido.status = 'entregue'
GROUP BY vendedor.nome_loja
ORDER BY faturamento DESC;

-- Query 8: a comissão da plataforma por categoria (só entregues)
SELECT categoria.nome,
  ROUND(SUM(item_pedido.quantidade * item_pedido.preco_unitario * categoria.comissao / 100.0), 2) AS comissao_da_plataforma
FROM item_pedido
JOIN pedido ON pedido.id = item_pedido.pedido_id
JOIN produto ON produto.id = item_pedido.produto_id
JOIN categoria ON categoria.id = produto.categoria_id
WHERE pedido.status = 'entregue'
GROUP BY categoria.nome
ORDER BY categoria.nome;

-- Desafio extra: o produto que não vende
SELECT produto.nome
FROM produto
LEFT JOIN item_pedido ON item_pedido.produto_id = produto.id
WHERE item_pedido.produto_id IS NULL;

-- =========================================================
-- LISTA PARA CASA
-- =========================================================

-- Exercício 1.1: os 3 mais baratos
SELECT nome, preco
FROM produto
ORDER BY preco
LIMIT 3;

-- Exercício 1.2: os livros (categoria 2), em ordem alfabética
SELECT nome, preco
FROM produto
WHERE categoria_id = 2
ORDER BY nome;

-- Exercício 1.3: quantos produtos existem
SELECT COUNT(*) AS produtos
FROM produto;

-- Exercício 2.1: quantos produtos cada vendedor anuncia
SELECT vendedor.nome_loja, COUNT(produto.id) AS produtos
FROM vendedor
LEFT JOIN produto ON produto.vendedor_id = vendedor.id
GROUP BY vendedor.nome_loja
ORDER BY vendedor.nome_loja;

-- Exercício 2.2: unidades vendidas por produto (incluindo os que não venderam)
SELECT produto.nome, COALESCE(SUM(item_pedido.quantidade), 0) AS unidades_vendidas
FROM produto
LEFT JOIN item_pedido ON item_pedido.produto_id = produto.id
GROUP BY produto.nome
ORDER BY unidades_vendidas DESC, produto.nome;

-- Exercício 2.3: clientes que gastaram mais de R$ 200 (só entregues)
SELECT cliente.nome, SUM(item_pedido.quantidade * item_pedido.preco_unitario) AS gasto
FROM cliente
JOIN pedido ON pedido.cliente_id = cliente.id
JOIN item_pedido ON item_pedido.pedido_id = pedido.id
WHERE pedido.status = 'entregue'
GROUP BY cliente.nome
HAVING SUM(item_pedido.quantidade * item_pedido.preco_unitario) > 200
ORDER BY gasto DESC;

-- Exercício 4.1: faturamento por região (só entregues)
SELECT regiao.nome, SUM(item_pedido.quantidade * item_pedido.preco_unitario) AS faturamento
FROM item_pedido
JOIN pedido ON pedido.id = item_pedido.pedido_id
JOIN cliente ON cliente.id = pedido.cliente_id
JOIN regiao ON regiao.id = cliente.regiao_id
WHERE pedido.status = 'entregue'
GROUP BY regiao.nome
ORDER BY faturamento DESC;

-- Exercício 4.2: comissão da plataforma por vendedor (só entregues)
SELECT vendedor.nome_loja,
  ROUND(SUM(item_pedido.quantidade * item_pedido.preco_unitario * categoria.comissao / 100.0), 2) AS comissao
FROM item_pedido
JOIN pedido ON pedido.id = item_pedido.pedido_id
JOIN produto ON produto.id = item_pedido.produto_id
JOIN vendedor ON vendedor.id = produto.vendedor_id
JOIN categoria ON categoria.id = produto.categoria_id
WHERE pedido.status = 'entregue'
GROUP BY vendedor.nome_loja
ORDER BY vendedor.nome_loja;

-- Exercício 4.3: o cliente que mais gastou (só entregues)
SELECT cliente.nome, SUM(item_pedido.quantidade * item_pedido.preco_unitario) AS gasto
FROM cliente
JOIN pedido ON pedido.cliente_id = cliente.id
JOIN item_pedido ON item_pedido.pedido_id = pedido.id
WHERE pedido.status = 'entregue'
GROUP BY cliente.nome
ORDER BY gasto DESC
LIMIT 1;
