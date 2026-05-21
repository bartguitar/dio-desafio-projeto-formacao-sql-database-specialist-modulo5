-- =========================================================================
-- PARTE 1 – TRANSAÇÕES (Sem Procedure)
-- Objetivo: Inserir um produto e seu estoque inicial usando transação manual
-- =========================================================================

-- Desabilitando o autocommit para controlar as transações manualmente
SET autocommit = 0;

-- Inicia a transação de forma explícita
START TRANSACTION;

-- 1. Insere o novo produto na tabela Produto
INSERT INTO Produto (Categoria, Descricao, Valor) 
VALUES ('Eletrônicos', 'Smartphone X Pro 128GB', 2499.90);

-- Recupera o ID gerado para o produto acima e guarda em uma variável de sessão
SET @novo_produto_id = LAST_INSERT_ID();

-- 2. Insere a quantidade inicial no estoque (Assumindo que o idEstoque = 1 já exista)
INSERT INTO Produto_Estoque (Produto_idProduto, Estoque_idEstoque, Quantidade) 
VALUES (@novo_produto_id, 1, 50);

-- Se ambas as instruções funcionarem sem erros, confirma as alterações permanentemente
COMMIT;

-- Reabilita o autocommit para voltar ao padrão do banco
SET autocommit = 1;


-- =========================================================================
-- PARTE 2 - TRANSAÇÃO COM PROCEDURE
-- Objetivo: Procedure para cadastrar Cliente PF com tratamento de erro e Rollback
-- =========================================================================

DELIMITER $$

CREATE PROCEDURE sp_InserirClientePF(
    IN p_Pnome VARCHAR(50),
    IN p_NomeDoMeio VARCHAR(50),
    IN p_Sobrenome VARCHAR(50),
    IN p_Endereco VARCHAR(100),
    IN p_DataNascimento DATE,
    IN p_CPF CHAR(11)
)
BEGIN
    -- Variável para monitorar a ocorrência de erros
    DECLARE erro_sql TINYINT DEFAULT FALSE;
    
    -- Handler: Se ocorrer qualquer exceção SQL (como CPF duplicado), desfaz tudo
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET erro_sql = TRUE;
        ROLLBACK;
        SELECT 'Erro detectado! A transação foi revertida (ROLLBACK).' AS Resultado;
    END;

    -- Inicia a transação controlada pela procedure
    START TRANSACTION;

    -- 1. Insere os dados na tabela base do Cliente
    INSERT INTO Cliente (Pnome, NomeDoMeio, Sobrenome, Endereco, DataNascimento)
    VALUES (p_Pnome, p_NomeDoMeio, p_Sobrenome, p_Endereco, p_DataNascimento);

    -- 2. Captura o ID auto-incremental gerado para este cliente
    SET @id_cliente_gerado = LAST_INSERT_ID();

    -- 3. Insere o CPF na tabela especializada Cliente_PF
    INSERT INTO Cliente_PF (idCliente, CPF)
    VALUES (@id_cliente_gerado, p_CPF);

    -- Se o fluxo chegar aqui sem disparar o Handler, confirma a inserção nas duas tabelas
    COMMIT;
    SELECT 'Cliente PF cadastrado com sucesso!' AS Resultado;

END $$

DELIMITER ;
