# Desafio de Projeto - Módulo 5 - Transações & Gerenciamento de Banco de Dados com MySQL
Desafio de Projeto - Formação SQL Database Specialist - Digital Innovation One - Módulo 5 - Criando Transações, Executando Backup e Recovery de Banco de Dados

Este repositório contém a resolução do desafio prático focado em garantir a integridade, automação e segurança de dados em um sistema de **E-commerce**. O projeto aborda o controle manual de transações, a criação de procedimentos armazenados (Procedures) com tratamento de erros robusto (`ROLLBACK`) e estratégias de backup completo.

---

## 📂 Estrutura do Repositório

O repositório é composto pelos seguintes arquivos principais:

*   **`desafio_transacoes_procedures.sql`**: Script contendo toda a lógica de programação de banco de dados (Transações manuais da Parte 1 e a Stored Procedure com tratamento de exceção da Parte 2).
*   **`ecommerce_backup.sql`**: Arquivo de dump lógico contendo a estrutura completa do banco de dados (tabelas, chaves estrangeiras, a procedure criada e metadados).
*   **`esquema_ecommerce_base.sql`**: Banco de dados referência.

---

## 📝 Passo a Passo do Que Foi Feito

### Parte 1: Transações Manuais (Sem Procedure)
O objetivo desta etapa foi executar modificações atômicas no banco de dados (onde ou tudo dá certo, ou nada é salvo), sem o uso de sub-rotinas.
*   **Desativação do Autocommit:** O comportamento padrão do MySQL foi alterado usando `SET autocommit = 0;` para evitar que cada comando fosse salvo imediatamente.
*   **Cenário de Negócio:** Implementação da inserção de um novo produto (`Produto`) e a definição automática de seu estoque inicial (`Produto_Estoque`).
*   **Integridade dos Dados:** Utilizou-se `START TRANSACTION` e `LAST_INSERT_ID()` para vincular o estoque ao ID correto do produto recém-criado. Caso a inserção no estoque falhasse por qualquer motivo (como um ID de estoque inválido), os dados não ficariam órfãos no banco de dados. Ao final do sucesso, o `COMMIT` consolida os dados.

### Parte 2: Transações Automatizadas com Procedure e Erro
Nesta etapa, o processo de transação foi encapsulado dentro de uma `PROCEDURE` chamada `sp_InserirClientePF`, adicionando uma camada essencial de tratamento de erros.
*   **Cenário de Negócio:** Cadastro unificado de um Cliente Pessoa Física, que exige inserções simultâneas na tabela genérica `Cliente` e na tabela especializada `Cliente_PF`.
*   **Tratamento de Exceções (`HANDLER`):** Foi declarado um `DECLARE EXIT HANDLER FOR SQLEXCEPTION`. 
*   **Mecanismo de Rollback:** Como o campo `CPF` possui a restrição `UNIQUE`, se o usuário tentar cadastrar um CPF que já existe no sistema, o MySQL disparará um erro. O `HANDLER` captura essa falha, aborta a operação e executa um `ROLLBACK` total, garantindo que nenhum registro incompleto seja inserido apenas na tabela pai (`Cliente`).

### Parte 3: Estratégia de Backup e Recovery
Garantia de segurança dos dados e continuidade do negócio através de cópias de segurança estruturadas.
*   **Backup Completo:** Foi utilizado o utilitário de terminal `mysqldump` para exportar o banco de dados `ecommerce`.
*   **Inclusão de Objetos Avançados:** Foram utilizadas as flags `--routines` e `--events` para garantir que a procedure criada na Parte 2 e quaisquer eventos do banco fossem salvos no arquivo final `ecommerce_backup.sql`.

---

## 🛠️ Como Testar e Executar o Projeto

### Pré-requisitos
*   MySQL Server instalado (versão 8.0 ou superior recomendada).
*   Um cliente SQL (como MySQL Workbench, DBeaver ou VS Code).

### 1. Restaurando o Banco de Dados (Recovery)
Antes de testar os scripts, você pode restaurar a estrutura completa do banco utilizando o arquivo de backup fornecido. Abra o seu terminal (Prompt de Comando ou Bash) e execute:

```bash
mysql -u seu_usuario -p < ecommerce_backup.sql

(Substitua seu_usuario pelo seu usuário do MySQL, ex: root).
```

### 2. Executando as Transações Manuais
Abra o arquivo desafio_transacoes_procedures.sql no seu editor SQL e execute o bloco da Parte 1.

Para ver o efeito do controle transacional, altere temporariamente o Estoque_idEstoque no segundo INSERT para um ID que não existe (ex: 999). Você verá que o MySQL acusará erro de chave estrangeira. Ao rodar um SELECT * FROM Produto;, o smartphone tentado não estará lá, provando que o banco barrou a operação incompleta.

### 3. Testando o Rollback da Procedure
Ainda no arquivo de scripts, execute o bloco da Parte 2 para criar a procedure no seu banco. Depois, execute os seguintes testes:

```
-- Teste 1: Inserção com Sucesso
CALL sp_InserirClientePF('Carlos', 'A.', 'Silva', 'Rua das Flores, 123', '1990-05-15', '12345678901');

-- Teste 2: Inserção com CPF Duplicado (Força o Rollback)
-- Note que o nome é diferente, mas o CPF é o mesmo do teste anterior.
CALL sp_InserirClientePF('Mariana', 'R.', 'Costa', 'Av. Central, 456', '1995-10-20', '12345678901');
```

O sistema retornará a mensagem customizada: "Erro detectado! A transação foi revertida (ROLLBACK)." e a tabela Cliente permanecerá limpa de dados falsos.

### 4. Gerando um Novo Backup
Se você fizer alterações e quiser gerar um novo arquivo de backup atualizado, use o comando abaixo no terminal do seu sistema operacional:

```
mysqldump -u seu_usuario -p --routines --events --databases ecommerce > ecommerce_backup.sql
```

## 🎯 Conclusão

A execução deste desafio permitiu consolidar na prática os pilares fundamentais de consistência, resiliência e segurança necessários no gerenciamento de um banco de dados relacional:

*   **Garantia de Integridade (Propriedades ACID):** O controle manual de transações via `START TRANSACTION` e `COMMIT` provou ser indispensável para cenários onde operações dependentes (como Produto e Estoque) precisam acontecer de forma atômica, evitando dados órfãos ou inconsistentes no sistema.
*   **Tratamento de Erros e Resiliência:** A automação do fluxo com a Stored Procedure e o uso do `DECLARE EXIT HANDLER FOR SQLEXCEPTION` demonstraram como blindar o banco de dados contra falhas de inserção e violações de chaves únicas (como CPF duplicado). O acionamento automático do `ROLLBACK` garante que nenhuma operação parcial corrompa a integridade das tabelas.
*   **Segurança e Recuperação (Disaster Recovery):** A utilização do `mysqldump` com o salvamento explícito de rotinas e eventos garante que as políticas de backup cubram não apenas os dados armazenados, mas toda a inteligência e programabilidade embutidas no servidor (Procedures), permitindo uma restauração rápida e idêntica em caso de incidentes.

Em suma, as técnicas aplicadas elevam o nível do banco de dados de um mero repositório para uma camada ativa, inteligente e segura, preparada para sustentar as regras de negócio de um ecossistema de E-commerce real.
