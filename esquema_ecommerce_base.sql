-- Criação do banco de dados para o cenário de E-commerce
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- ==========================
-- TABELA CLIENTE
-- ==========================
CREATE TABLE IF NOT EXISTS Cliente (
  idCliente INT AUTO_INCREMENT PRIMARY KEY,
  Pnome VARCHAR(50) NOT NULL,
  NomeDoMeio VARCHAR(50),
  Sobrenome VARCHAR(50),
  Endereco VARCHAR(100),
  DataNascimento DATE NOT NULL
) ENGINE = InnoDB;

-- ==========================
-- TABELA CLIENTE_PF
-- ==========================
CREATE TABLE IF NOT EXISTS Cliente_PF (
  idCliente INT PRIMARY KEY,
  CPF CHAR(11) NOT NULL UNIQUE,
  FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA CLIENTE_PJ
-- ==========================
CREATE TABLE IF NOT EXISTS Cliente_PJ (
  idCliente INT PRIMARY KEY,
  RazaoSocial VARCHAR(100) NOT NULL,
  CNPJ CHAR(14) NOT NULL UNIQUE,
  FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA PRODUTO
-- ==========================
CREATE TABLE IF NOT EXISTS Produto (
  idProduto INT AUTO_INCREMENT PRIMARY KEY,
  Categoria VARCHAR(45) NOT NULL,
  Descricao VARCHAR(255),
  Valor DECIMAL(10,2) NOT NULL
) ENGINE = InnoDB;

-- ==========================
-- TABELA PEDIDO
-- ==========================
CREATE TABLE IF NOT EXISTS Pedido (
  idPedido INT AUTO_INCREMENT PRIMARY KEY,
  StatusPedido ENUM('Em andamento', 'Processando', 'Enviado', 'Entregue') DEFAULT 'Processando',
  Descricao VARCHAR(255),
  Cliente_idCliente INT NOT NULL,
  Frete DECIMAL(10,2),
  FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA ENTREGA
-- ==========================
CREATE TABLE IF NOT EXISTS Entrega (
  idEntrega INT AUTO_INCREMENT PRIMARY KEY,
  idPedido INT NOT NULL,
  StatusEntrega ENUM('Pendente', 'Enviada', 'Em Transporte', 'Entregue', 'Cancelada') DEFAULT 'Pendente',
  CodigoRastreio VARCHAR(50),
  DataEnvio DATE,
  DataEntrega DATE,
  FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA FORNECEDOR
-- ==========================
CREATE TABLE IF NOT EXISTS Fornecedor (
  idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
  RazaoSocial VARCHAR(100) NOT NULL,
  CNPJ CHAR(14) NOT NULL UNIQUE
) ENGINE = InnoDB;

-- ==========================
-- TABELA DISPONIBILIZANDO_PRODUTO
-- ==========================
CREATE TABLE IF NOT EXISTS Disponibilizando_Produto (
  Fornecedor_idFornecedor INT NOT NULL,
  Produto_idProduto INT NOT NULL,
  PRIMARY KEY (Fornecedor_idFornecedor, Produto_idProduto),
  FOREIGN KEY (Fornecedor_idFornecedor) REFERENCES Fornecedor(idFornecedor)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (Produto_idProduto) REFERENCES Produto(idProduto)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA ESTOQUE
-- ==========================
CREATE TABLE IF NOT EXISTS Estoque (
  idEstoque INT AUTO_INCREMENT PRIMARY KEY,
  Localizacao VARCHAR(100)
) ENGINE = InnoDB;

-- ==========================
-- TABELA PRODUTO_ESTOQUE
-- ==========================
CREATE TABLE IF NOT EXISTS Produto_Estoque (
  Produto_idProduto INT NOT NULL,
  Estoque_idEstoque INT NOT NULL,
  Quantidade INT DEFAULT 0,
  PRIMARY KEY (Produto_idProduto, Estoque_idEstoque),
  FOREIGN KEY (Produto_idProduto) REFERENCES Produto(idProduto)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (Estoque_idEstoque) REFERENCES Estoque(idEstoque)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA RELACAO_PRODUTO_PEDIDO
-- ==========================
CREATE TABLE IF NOT EXISTS Produto_Pedido (
  Produto_idProduto INT NOT NULL,
  Pedido_idPedido INT NOT NULL,
  Quantidade INT NOT NULL,
  Status ENUM('disponível', 'sem estoque') DEFAULT 'disponível',
  PRIMARY KEY (Produto_idProduto, Pedido_idPedido),
  FOREIGN KEY (Produto_idProduto) REFERENCES Produto(idProduto)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (Pedido_idPedido) REFERENCES Pedido(idPedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA TERCEIRO_VENDEDOR
-- ==========================
CREATE TABLE IF NOT EXISTS Terceiro_Vendedor (
  idTerceiroVendedor INT AUTO_INCREMENT PRIMARY KEY,
  RazaoSocial VARCHAR(100) NOT NULL UNIQUE,
  NomeFantasia VARCHAR(100),
  Endereco VARCHAR(100) NOT NULL,
  Localizacao VARCHAR(100)
) ENGINE = InnoDB;

-- ==========================
-- TABELA PRODUTO_TERCEIRO
-- ==========================
CREATE TABLE IF NOT EXISTS Produto_Terceiro (
  TerceiroVendedor_id INT NOT NULL,
  Produto_idProduto INT NOT NULL,
  Quantidade INT DEFAULT 0,
  PRIMARY KEY (TerceiroVendedor_id, Produto_idProduto),
  FOREIGN KEY (TerceiroVendedor_id) REFERENCES Terceiro_Vendedor(idTerceiroVendedor)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (Produto_idProduto) REFERENCES Produto(idProduto)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ==========================
-- TABELA PAGAMENTO
-- ==========================
CREATE TABLE IF NOT EXISTS Pagamento (
  idPagamento INT AUTO_INCREMENT PRIMARY KEY,
  idPedido INT NOT NULL,
  TipoPagamento ENUM('Cartão de Crédito', 'Pix', 'Boleto', 'Transferência', 'Dinheiro') NOT NULL,
  ValorPago DECIMAL(10,2),
  DataPagamento DATE,
  FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;
