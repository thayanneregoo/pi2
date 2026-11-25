/*
 DeliveryFácil | SQL Server
 Executar em uma base vazia. Script organizado para SQL Server 2019+.
 Observação: pagamento real exige gateway e webhook; este banco guarda somente referências.
*/
IF DB_ID(N'DeliveryFacil') IS NULL CREATE DATABASE DeliveryFacil;
GO
USE DeliveryFacil;
GO

CREATE TABLE dbo.CLIENTE (
    id_cliente INT IDENTITY(1000,10) NOT NULL CONSTRAINT PK_CLIENTE PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(150) NULL,
    telefone_verificado BIT NOT NULL CONSTRAINT DF_CLIENTE_TELEFONE_VERIFICADO DEFAULT (0),
    anonimizado BIT NOT NULL CONSTRAINT DF_CLIENTE_ANONIMIZADO DEFAULT (0),
    criado_em DATETIME2(0) NOT NULL CONSTRAINT DF_CLIENTE_CRIADO DEFAULT (SYSDATETIME()),
    CONSTRAINT UQ_CLIENTE_TELEFONE UNIQUE (telefone),
    CONSTRAINT CK_CLIENTE_TELEFONE CHECK (telefone NOT LIKE '%[^0-9]%')
);
GO

CREATE TABLE dbo.AREA_ENTREGA (
    id_area INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AREA_ENTREGA PRIMARY KEY,
    bairro VARCHAR(100) NOT NULL,
    taxa_entrega DECIMAL(10,2) NOT NULL,
    pedido_minimo DECIMAL(10,2) NOT NULL CONSTRAINT DF_AREA_MINIMO DEFAULT (0),
    ativo BIT NOT NULL CONSTRAINT DF_AREA_ATIVO DEFAULT (1),
    CONSTRAINT UQ_AREA_BAIRRO UNIQUE (bairro),
    CONSTRAINT CK_AREA_TAXA CHECK (taxa_entrega >= 0),
    CONSTRAINT CK_AREA_MINIMO CHECK (pedido_minimo >= 0)
);
GO

CREATE TABLE dbo.ENDERECO (
    id_endereco INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ENDERECO PRIMARY KEY,
    id_cliente INT NOT NULL,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(100) NULL,
    bairro VARCHAR(100) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    referencia VARCHAR(150) NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    disponivel_entrega BIT NOT NULL CONSTRAINT DF_ENDERECO_DISPONIVEL DEFAULT (0),
    CONSTRAINT FK_ENDERECO_CLIENTE FOREIGN KEY (id_cliente)
        REFERENCES dbo.CLIENTE(id_cliente) ON DELETE CASCADE,
    CONSTRAINT CK_ENDERECO_CEP CHECK (cep LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]'),
    CONSTRAINT CK_ENDERECO_LAT CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT CK_ENDERECO_LON CHECK (longitude BETWEEN -180 AND 180)
);
GO

CREATE TABLE dbo.FUNCIONARIO (
    id_funcionario INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_FUNCIONARIO PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    papel VARCHAR(20) NOT NULL,
    ativo BIT NOT NULL CONSTRAINT DF_FUNCIONARIO_ATIVO DEFAULT (1),
    CONSTRAINT CK_FUNCIONARIO_PAPEL CHECK (papel IN ('OPERADOR','GESTOR'))
);
GO

CREATE TABLE dbo.PRODUTO (
    id_produto INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PRODUTO PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(500) NULL,
    preco DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    foto_url VARCHAR(255) NULL,
    status VARCHAR(10) NOT NULL CONSTRAINT DF_PRODUTO_STATUS DEFAULT ('ATIVO'),
    alterado_por INT NULL,
    atualizado_em DATETIME2(0) NOT NULL CONSTRAINT DF_PRODUTO_ATUALIZADO DEFAULT (SYSDATETIME()),
    CONSTRAINT CK_PRODUTO_PRECO CHECK (preco > 0),
    CONSTRAINT CK_PRODUTO_STATUS CHECK (status IN ('ATIVO','PAUSADO')),
    CONSTRAINT FK_PRODUTO_FUNCIONARIO FOREIGN KEY (alterado_por) REFERENCES dbo.FUNCIONARIO(id_funcionario)
);
GO

CREATE TABLE dbo.GRUPO_OPCAO (
    id_grupo_opcao INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_GRUPO_OPCAO PRIMARY KEY,
    id_produto INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    obrigatorio BIT NOT NULL CONSTRAINT DF_GRUPO_OBRIGATORIO DEFAULT (0),
    min_selecoes INT NOT NULL CONSTRAINT DF_GRUPO_MIN DEFAULT (0),
    max_selecoes INT NOT NULL,
    CONSTRAINT FK_GRUPO_PRODUTO FOREIGN KEY (id_produto) REFERENCES dbo.PRODUTO(id_produto) ON DELETE CASCADE,
    CONSTRAINT CK_GRUPO_SELECOES CHECK (min_selecoes >= 0 AND max_selecoes >= min_selecoes),
    CONSTRAINT CK_GRUPO_OBRIGATORIO CHECK (obrigatorio = 0 OR min_selecoes >= 1)
);
GO

CREATE TABLE dbo.OPCAO (
    id_opcao INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_OPCAO PRIMARY KEY,
    id_grupo_opcao INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    preco_adicional DECIMAL(10,2) NOT NULL CONSTRAINT DF_OPCAO_PRECO DEFAULT (0),
    CONSTRAINT FK_OPCAO_GRUPO FOREIGN KEY (id_grupo_opcao) REFERENCES dbo.GRUPO_OPCAO(id_grupo_opcao) ON DELETE CASCADE,
    CONSTRAINT CK_OPCAO_PRECO CHECK (preco_adicional >= 0)
);
GO

CREATE TABLE dbo.PEDIDO (
    id_pedido INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PEDIDO PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_endereco INT NULL,
    tipo_entrega VARCHAR(10) NOT NULL,
    data_pedido DATETIME2(0) NOT NULL CONSTRAINT DF_PEDIDO_DATA DEFAULT (SYSDATETIME()),
    status VARCHAR(30) NOT NULL CONSTRAINT DF_PEDIDO_STATUS DEFAULT ('PENDENTE'),
    subtotal_produtos DECIMAL(10,2) NOT NULL CONSTRAINT DF_PEDIDO_SUBTOTAL DEFAULT (0),
    taxa_entrega DECIMAL(10,2) NOT NULL CONSTRAINT DF_PEDIDO_TAXA DEFAULT (0),
    desconto_cupom DECIMAL(10,2) NOT NULL CONSTRAINT DF_PEDIDO_DESCONTO DEFAULT (0),
    valor_total DECIMAL(10,2) NOT NULL CONSTRAINT DF_PEDIDO_TOTAL DEFAULT (0),
    motivo_cancelamento VARCHAR(250) NULL,
    CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (id_cliente) REFERENCES dbo.CLIENTE(id_cliente),
    CONSTRAINT FK_PEDIDO_ENDERECO FOREIGN KEY (id_endereco) REFERENCES dbo.ENDERECO(id_endereco),
    CONSTRAINT CK_PEDIDO_TIPO CHECK (tipo_entrega IN ('ENTREGA','RETIRADA')),
    CONSTRAINT CK_PEDIDO_STATUS CHECK (status IN ('PENDENTE','PAGAMENTO_APROVADO','ACEITO','EM_PREPARO','PRONTO','SAIU_PARA_ENTREGA','ENTREGUE','CANCELADO')),
    CONSTRAINT CK_PEDIDO_VALORES CHECK (subtotal_produtos >= 0 AND taxa_entrega >= 0 AND desconto_cupom >= 0 AND valor_total >= 0),
    CONSTRAINT CK_PEDIDO_ENDERECO CHECK ((tipo_entrega = 'RETIRADA' AND id_endereco IS NULL AND taxa_entrega = 0) OR (tipo_entrega = 'ENTREGA' AND id_endereco IS NOT NULL))
);
GO

CREATE TABLE dbo.ITEM_PEDIDO (
    id_item INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ITEM_PEDIDO PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    observacao VARCHAR(200) NULL,
    CONSTRAINT FK_ITEM_PEDIDO_PEDIDO FOREIGN KEY (id_pedido) REFERENCES dbo.PEDIDO(id_pedido) ON DELETE CASCADE,
    CONSTRAINT FK_ITEM_PEDIDO_PRODUTO FOREIGN KEY (id_produto) REFERENCES dbo.PRODUTO(id_produto),
    CONSTRAINT CK_ITEM_QUANTIDADE CHECK (quantidade > 0),
    CONSTRAINT CK_ITEM_PRECO CHECK (preco_unitario > 0)
);
GO

CREATE TABLE dbo.ITEM_OPCAO (
    id_item INT NOT NULL,
    id_opcao INT NOT NULL,
    preco_adicional_congelado DECIMAL(10,2) NOT NULL CONSTRAINT DF_ITEM_OPCAO_PRECO DEFAULT (0),
    CONSTRAINT PK_ITEM_OPCAO PRIMARY KEY (id_item, id_opcao),
    CONSTRAINT FK_ITEM_OPCAO_ITEM FOREIGN KEY (id_item) REFERENCES dbo.ITEM_PEDIDO(id_item) ON DELETE CASCADE,
    CONSTRAINT FK_ITEM_OPCAO_OPCAO FOREIGN KEY (id_opcao) REFERENCES dbo.OPCAO(id_opcao),
    CONSTRAINT CK_ITEM_OPCAO_PRECO CHECK (preco_adicional_congelado >= 0)
);
GO

CREATE TABLE dbo.PAGAMENTO (
    id_pagamento INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PAGAMENTO PRIMARY KEY,
    id_pedido INT NOT NULL,
    forma_pagamento VARCHAR(10) NOT NULL,
    status_pagamento VARCHAR(12) NOT NULL CONSTRAINT DF_PAGAMENTO_STATUS DEFAULT ('AGUARDANDO'),
    valor DECIMAL(10,2) NOT NULL,
    id_transacao_gateway VARCHAR(100) NULL,
    criado_em DATETIME2(0) NOT NULL CONSTRAINT DF_PAGAMENTO_DATA DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_PAGAMENTO_PEDIDO FOREIGN KEY (id_pedido) REFERENCES dbo.PEDIDO(id_pedido) ON DELETE CASCADE,
    CONSTRAINT CK_PAGAMENTO_FORMA CHECK (forma_pagamento IN ('PIX','CARTAO')),
    CONSTRAINT CK_PAGAMENTO_STATUS CHECK (status_pagamento IN ('AGUARDANDO','APROVADO','RECUSADO','ESTORNADO')),
    CONSTRAINT CK_PAGAMENTO_VALOR CHECK (valor > 0),
    CONSTRAINT UQ_PAGAMENTO_GATEWAY UNIQUE (id_transacao_gateway)
);
GO

CREATE TABLE dbo.AVALIACAO (
    id_avaliacao INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AVALIACAO PRIMARY KEY,
    id_pedido INT NOT NULL,
    nota TINYINT NOT NULL,
    comentario VARCHAR(1000) NULL,
    resposta_restaurante VARCHAR(1000) NULL,
    criada_em DATETIME2(0) NOT NULL CONSTRAINT DF_AVALIACAO_DATA DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_AVALIACAO_PEDIDO FOREIGN KEY (id_pedido) REFERENCES dbo.PEDIDO(id_pedido),
    CONSTRAINT UQ_AVALIACAO_PEDIDO UNIQUE (id_pedido),
    CONSTRAINT CK_AVALIACAO_NOTA CHECK (nota BETWEEN 1 AND 5)
);
GO

CREATE TABLE dbo.HISTORICO_STATUS_PEDIDO (
    id_historico INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_HISTORICO_STATUS PRIMARY KEY,
    id_pedido INT NOT NULL,
    status_anterior VARCHAR(30) NULL,
    status_novo VARCHAR(30) NOT NULL,
    data_alteracao DATETIME2(0) NOT NULL CONSTRAINT DF_HISTORICO_DATA DEFAULT (SYSDATETIME()),
    id_funcionario INT NULL,
    observacao VARCHAR(250) NULL,
    CONSTRAINT FK_HISTORICO_PEDIDO FOREIGN KEY (id_pedido) REFERENCES dbo.PEDIDO(id_pedido) ON DELETE CASCADE,
    CONSTRAINT FK_HISTORICO_FUNCIONARIO FOREIGN KEY (id_funcionario) REFERENCES dbo.FUNCIONARIO(id_funcionario)
);
GO

/* Índices para consultas frequentes do painel operacional. */
CREATE INDEX IX_PEDIDO_STATUS_DATA ON dbo.PEDIDO(status, data_pedido DESC) INCLUDE (id_cliente, valor_total);
CREATE INDEX IX_ITEM_PEDIDO_PEDIDO ON dbo.ITEM_PEDIDO(id_pedido);
CREATE INDEX IX_ENDERECO_CLIENTE ON dbo.ENDERECO(id_cliente);
GO

/* FUNCTION: calcula a taxa a partir do bairro; retirada não paga frete. */
CREATE OR ALTER FUNCTION dbo.fn_calcular_taxa_entrega
(@tipo_entrega VARCHAR(10), @bairro VARCHAR(100))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @taxa DECIMAL(10,2) = 0;
    IF @tipo_entrega = 'ENTREGA'
        SELECT @taxa = taxa_entrega FROM dbo.AREA_ENTREGA WHERE bairro = @bairro AND ativo = 1;
    RETURN ISNULL(@taxa, -1); -- -1 sinaliza bairro sem cobertura
END;
GO

/* TRIGGER: mantém subtotal e total consistentes após inclusão/alteração/remoção de item. */
CREATE OR ALTER TRIGGER dbo.trg_item_pedido_recalcular_total
ON dbo.ITEM_PEDIDO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH pedidos_afetados AS (
        SELECT id_pedido FROM inserted
        UNION
        SELECT id_pedido FROM deleted
    ),
    totais AS (
        SELECT ip.id_pedido,
               SUM(ip.quantidade * (ip.preco_unitario + ISNULL(op.total_adicionais,0))) AS subtotal
        FROM dbo.ITEM_PEDIDO ip
        OUTER APPLY (
            SELECT SUM(io.preco_adicional_congelado) AS total_adicionais
            FROM dbo.ITEM_OPCAO io WHERE io.id_item = ip.id_item
        ) op
        WHERE ip.id_pedido IN (SELECT id_pedido FROM pedidos_afetados)
        GROUP BY ip.id_pedido
    )
    UPDATE p
       SET subtotal_produtos = ISNULL(t.subtotal,0),
           valor_total = ISNULL(t.subtotal,0) + p.taxa_entrega - p.desconto_cupom
    FROM dbo.PEDIDO p
    LEFT JOIN totais t ON t.id_pedido = p.id_pedido
    WHERE p.id_pedido IN (SELECT id_pedido FROM pedidos_afetados);
END;
GO


/* TRIGGER complementar: opções possuem preço adicional congelado e também alteram o total. */
CREATE OR ALTER TRIGGER dbo.trg_item_opcao_recalcular_total
ON dbo.ITEM_OPCAO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH itens_afetados AS (
        SELECT id_item FROM inserted
        UNION
        SELECT id_item FROM deleted
    ),
    pedidos_afetados AS (
        SELECT DISTINCT ip.id_pedido
        FROM dbo.ITEM_PEDIDO ip
        WHERE ip.id_item IN (SELECT id_item FROM itens_afetados)
    ),
    totais AS (
        SELECT ip.id_pedido,
               SUM(ip.quantidade * (ip.preco_unitario + ISNULL(op.total_adicionais,0))) AS subtotal
        FROM dbo.ITEM_PEDIDO ip
        OUTER APPLY (
            SELECT SUM(io.preco_adicional_congelado) AS total_adicionais
            FROM dbo.ITEM_OPCAO io WHERE io.id_item = ip.id_item
        ) op
        WHERE ip.id_pedido IN (SELECT id_pedido FROM pedidos_afetados)
        GROUP BY ip.id_pedido
    )
    UPDATE p
       SET subtotal_produtos = ISNULL(t.subtotal,0),
           valor_total = ISNULL(t.subtotal,0) + p.taxa_entrega - p.desconto_cupom
    FROM dbo.PEDIDO p
    LEFT JOIN totais t ON t.id_pedido = p.id_pedido
    WHERE p.id_pedido IN (SELECT id_pedido FROM pedidos_afetados);
END;
GO

/* PROCEDURE: altera status respeitando transições básicas e registrando auditoria. */
CREATE OR ALTER PROCEDURE dbo.sp_atualizar_status_pedido
    @id_pedido INT,
    @novo_status VARCHAR(30),
    @id_funcionario INT = NULL,
    @motivo VARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @atual VARCHAR(30);
    SELECT @atual = status FROM dbo.PEDIDO WITH (UPDLOCK, ROWLOCK) WHERE id_pedido = @id_pedido;
    IF @atual IS NULL THROW 50001, 'Pedido não encontrado.', 1;
    IF @atual = 'ENTREGUE' OR @atual = 'CANCELADO' THROW 50002, 'Pedido encerrado não pode mudar de status.', 1;
    IF @novo_status = 'CANCELADO' AND NULLIF(LTRIM(RTRIM(@motivo)), '') IS NULL
        THROW 50003, 'Motivo obrigatório para cancelamento.', 1;

    IF NOT (
        (@atual = 'PENDENTE' AND @novo_status IN ('PAGAMENTO_APROVADO','CANCELADO')) OR
        (@atual = 'PAGAMENTO_APROVADO' AND @novo_status IN ('ACEITO','CANCELADO')) OR
        (@atual = 'ACEITO' AND @novo_status IN ('EM_PREPARO','CANCELADO')) OR
        (@atual = 'EM_PREPARO' AND @novo_status IN ('PRONTO','CANCELADO')) OR
        (@atual = 'PRONTO' AND @novo_status IN ('SAIU_PARA_ENTREGA','ENTREGUE','CANCELADO')) OR
        (@atual = 'SAIU_PARA_ENTREGA' AND @novo_status IN ('ENTREGUE','CANCELADO'))
    ) THROW 50004, 'Transição de status não permitida.', 1;

    BEGIN TRANSACTION;
      UPDATE dbo.PEDIDO
         SET status = @novo_status,
             motivo_cancelamento = CASE WHEN @novo_status = 'CANCELADO' THEN @motivo ELSE motivo_cancelamento END
       WHERE id_pedido = @id_pedido;
      INSERT INTO dbo.HISTORICO_STATUS_PEDIDO(id_pedido,status_anterior,status_novo,id_funcionario,observacao)
      VALUES(@id_pedido,@atual,@novo_status,@id_funcionario,@motivo);
    COMMIT;
END;
GO

/* CARGA INICIAL: mínimo de três registros por tabela. */
INSERT dbo.CLIENTE(nome,telefone,email,telefone_verificado) VALUES
('Ana Souza','81999990001','ana@email.com',1),
('Bruno Lima','81999990002','bruno@email.com',1),
('Carla Reis','81999990003',NULL,1);

INSERT dbo.AREA_ENTREGA(bairro,taxa_entrega,pedido_minimo) VALUES
('Boa Viagem',5.00,20),('Pina',7.00,25),('Imbiribeira',8.00,25);

INSERT dbo.FUNCIONARIO(nome,papel) VALUES
('Marina Gestora','GESTOR'),('Paulo Operador','OPERADOR'),('João Operador','OPERADOR');

INSERT dbo.PRODUTO(nome,descricao,preco,categoria,status,alterado_por) VALUES
('Hambúrguer Clássico','Pão, carne e queijo',22.90,'HAMBURGUER','ATIVO',1),
('Pizza Mussarela','Molho, queijo e orégano',39.90,'PIZZA','ATIVO',1),
('Brownie','Brownie de chocolate',9.90,'SOBREMESA','ATIVO',1);

INSERT dbo.GRUPO_OPCAO(id_produto,nome,obrigatorio,min_selecoes,max_selecoes) VALUES
(1,'Ponto da carne',1,1,1),(1,'Adicionais',0,0,3),(2,'Borda',0,0,1);

INSERT dbo.OPCAO(id_grupo_opcao,nome,preco_adicional) VALUES
(1,'Ao ponto',0),(2,'Bacon',4.00),(2,'Cheddar',3.00);

INSERT dbo.PEDIDO(id_cliente,id_endereco,tipo_entrega,status,subtotal_produtos,taxa_entrega,valor_total) VALUES
(1000,NULL,'RETIRADA','ENTREGUE',0,0,0),
(1010,NULL,'RETIRADA','ENTREGUE',0,0,0),
(1020,NULL,'RETIRADA','ENTREGUE',0,0,0);

INSERT dbo.ITEM_PEDIDO(id_pedido,id_produto,quantidade,preco_unitario,observacao) VALUES
(1,1,1,22.90,'Sem cebola'),(2,2,1,39.90,NULL),(3,3,2,9.90,NULL);

INSERT dbo.ITEM_OPCAO(id_item,id_opcao,preco_adicional_congelado) VALUES
(1,1,0),(1,2,4.00),(2,3,3.00);

INSERT dbo.PAGAMENTO(id_pedido,forma_pagamento,status_pagamento,valor,id_transacao_gateway) VALUES
(1,'PIX','APROVADO',26.90,'TX-DEMO-001'),
(2,'CARTAO','APROVADO',42.90,'TX-DEMO-002'),
(3,'PIX','APROVADO',19.80,'TX-DEMO-003');

INSERT dbo.HISTORICO_STATUS_PEDIDO(id_pedido,status_anterior,status_novo,id_funcionario,observacao) VALUES
(1,'EM_PREPARO','ENTREGUE',2,'Carga demonstrativa'),
(2,'PRONTO','ENTREGUE',3,'Carga demonstrativa'),
(3,'SAIU_PARA_ENTREGA','ENTREGUE',2,'Carga demonstrativa');

INSERT dbo.AVALIACAO(id_pedido,nota,comentario) VALUES
(1,5,'Muito bom'),(2,4,'Chegou bem'),(3,5,'Excelente');

INSERT dbo.ENDERECO(id_cliente,rua,numero,bairro,cep,latitude,longitude,disponivel_entrega) VALUES
(1000,'Rua das Flores','10','Boa Viagem','51020-000',-8.119000,-34.900000,1),
(1010,'Rua do Sol','20','Pina','51110-000',-8.087000,-34.900000,1),
(1020,'Av. Recife','300','Imbiribeira','51190-000',-8.120000,-34.930000,1);
GO

/* Consultas demonstrativas: aliases, múltiplos JOINs e agregações. */
-- 1. Pedidos com cliente, endereço e itens (três JOINs).
SELECT p.id_pedido, c.nome AS cliente, p.status, p.tipo_entrega,
       e.bairro, ip.quantidade, pr.nome AS produto, ip.preco_unitario
FROM dbo.PEDIDO AS p
JOIN dbo.CLIENTE AS c ON c.id_cliente = p.id_cliente
LEFT JOIN dbo.ENDERECO AS e ON e.id_endereco = p.id_endereco
JOIN dbo.ITEM_PEDIDO AS ip ON ip.id_pedido = p.id_pedido
JOIN dbo.PRODUTO AS pr ON pr.id_produto = ip.id_produto
ORDER BY p.data_pedido DESC;

-- 2. Agregações exigidas: SUM, COUNT, AVG, MAX e MIN.
SELECT COUNT(*) AS quantidade_pedidos,
       SUM(valor_total) AS faturamento_total,
       AVG(valor_total) AS ticket_medio,
       MAX(valor_total) AS maior_pedido,
       MIN(valor_total) AS menor_pedido
FROM dbo.PEDIDO;

-- 3. Faturamento e quantidade por produto.
SELECT pr.nome AS produto, COUNT(DISTINCT ip.id_pedido) AS pedidos,
       SUM(ip.quantidade) AS unidades,
       SUM(ip.quantidade * ip.preco_unitario) AS faturamento_itens
FROM dbo.PRODUTO pr
JOIN dbo.ITEM_PEDIDO ip ON ip.id_produto = pr.id_produto
GROUP BY pr.nome
ORDER BY faturamento_itens DESC;

-- 4. Uso da FUNCTION.
SELECT dbo.fn_calcular_taxa_entrega('ENTREGA','Boa Viagem') AS taxa_boa_viagem;

-- 5. Histórico de status.
SELECT h.id_pedido, h.status_anterior, h.status_novo, h.data_alteracao, f.nome AS responsavel
FROM dbo.HISTORICO_STATUS_PEDIDO h
LEFT JOIN dbo.FUNCIONARIO f ON f.id_funcionario = h.id_funcionario;
GO
