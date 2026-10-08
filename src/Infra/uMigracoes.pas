unit uMigracoes;

{ Cria e atualiza a estrutura do banco.

  A versão do banco fica gravada no próprio arquivo (PRAGMA user_version).
  Para mudar o banco numa versão nova do programa:
    1. crie um array SCRIPT_Vn com os comandos (ALTER TABLE, CREATE INDEX...);
    2. acrescente um bloco "if Versao < n then Executar(AConn, SCRIPT_Vn, n);".
  Nunca altere um script que já foi distribuído: crie sempre o próximo.

  ATENÇÃO: SCRIPT_V1 é gerado a partir de db/schema.sql. }

interface

uses
  FireDAC.Comp.Client;

procedure AtualizarBanco(AConn: TFDConnection);

implementation

uses
  System.SysUtils;

const
  SCRIPT_V1: array[0..26] of string = (
    'CREATE TABLE ingrediente ( ' +
      '  id              INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  nome            VARCHAR(60) NOT NULL UNIQUE COLLATE NOCASE, ' +
      '  unidade         VARCHAR(5)  NOT NULL DEFAULT ''g'', ' +
      '  qtd_embalagem   REAL        NOT NULL DEFAULT 1 CHECK (qtd_embalagem > 0), ' +
      '  preco_embalagem CURRENCY    NOT NULL DEFAULT 0 ' +
      ') ',
    'CREATE TABLE sabor ( ' +
      '  id          INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  nome        VARCHAR(60) NOT NULL UNIQUE COLLATE NOCASE, ' +
      '  preco_venda CURRENCY    NOT NULL DEFAULT 0, ' +
      '  rendimento  INTEGER     NOT NULL DEFAULT 16 CHECK (rendimento > 0) ' +
      ') ',
    'CREATE TABLE receita_item ( ' +
      '  id              INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  sabor_id        INTEGER NOT NULL REFERENCES sabor(id) ON DELETE CASCADE, ' +
      '  ingrediente_id  INTEGER NOT NULL REFERENCES ingrediente(id), ' +
      '  qtd_por_receita REAL    NOT NULL DEFAULT 0, ' +
      '  UNIQUE (sabor_id, ingrediente_id) ' +
      ') ',
    'CREATE TABLE compra ( ' +
      '  id             INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  data           DATE     NOT NULL, ' +
      '  ingrediente_id INTEGER  NOT NULL REFERENCES ingrediente(id), ' +
      '  qtd_embalagens REAL     NOT NULL, ' +
      '  quantidade     REAL     NOT NULL, ' +
      '  valor_total    CURRENCY NOT NULL ' +
      ') ',
    'CREATE INDEX ix_compra_data ON compra(data) ',
    'CREATE TABLE producao ( ' +
      '  id            INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  data          DATE    NOT NULL, ' +
      '  sabor_id      INTEGER NOT NULL REFERENCES sabor(id), ' +
      '  qtd_receitas  REAL    NOT NULL, ' +
      '  qtd_tortinhas INTEGER NOT NULL ' +
      ') ',
    'CREATE INDEX ix_producao_data ON producao(data) ',
    'CREATE TABLE mov_estoque ( ' +
      '  id             INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  data           DATE        NOT NULL, ' +
      '  ingrediente_id INTEGER     NOT NULL REFERENCES ingrediente(id), ' +
      '  tipo           CHAR(1)     NOT NULL CHECK (tipo IN (''E'', ''S'', ''A'')), ' +
      '  quantidade     REAL        NOT NULL, ' +
      '  origem         VARCHAR(10) NOT NULL, ' +
      '  origem_id      INTEGER ' +
      ') ',
    'CREATE INDEX ix_mov_ingrediente ON mov_estoque(ingrediente_id) ',
    'CREATE INDEX ix_mov_origem ON mov_estoque(origem, origem_id) ',
    'CREATE TABLE venda ( ' +
      '  id          INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  data        DATE        NOT NULL, ' +
      '  cliente     VARCHAR(60), ' +
      '  forma_pagto VARCHAR(20) ' +
      ') ',
    'CREATE INDEX ix_venda_data ON venda(data) ',
    'CREATE TABLE venda_item ( ' +
      '  id         INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  venda_id   INTEGER  NOT NULL REFERENCES venda(id) ON DELETE CASCADE, ' +
      '  sabor_id   INTEGER  NOT NULL REFERENCES sabor(id), ' +
      '  qtd        INTEGER  NOT NULL CHECK (qtd > 0), ' +
      '  preco_unit CURRENCY NOT NULL, ' +
      '  custo_unit CURRENCY NOT NULL ' +
      ') ',
    'CREATE INDEX ix_venda_item_venda ON venda_item(venda_id) ',
    'CREATE TABLE despesa ( ' +
      '  id        INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  data      DATE         NOT NULL, ' +
      '  descricao VARCHAR(100) NOT NULL, ' +
      '  categoria VARCHAR(40), ' +
      '  valor     CURRENCY     NOT NULL ' +
      ') ',
    'CREATE INDEX ix_despesa_data ON despesa(data) ',
    'CREATE VIEW vw_custo_sabor AS ' +
      'SELECT s.id AS sabor_id, s.nome, s.preco_venda, s.rendimento, ' +
      '       COALESCE(c.custo_receita, 0.0) AS custo_receita, ' +
      '       COALESCE(c.custo_receita, 0.0) / s.rendimento AS custo_unit ' +
      'FROM sabor s ' +
      'LEFT JOIN (SELECT ri.sabor_id, ' +
      '                  SUM(1.0 * ri.qtd_por_receita * i.preco_embalagem / i.qtd_embalagem) AS custo_receita ' +
      '           FROM receita_item ri ' +
      '           JOIN ingrediente i ON i.id = ri.ingrediente_id ' +
      '           GROUP BY ri.sabor_id) c ON c.sabor_id = s.id ',
    'CREATE VIEW vw_estoque_ingrediente AS ' +
      'SELECT i.id AS ingrediente_id, i.nome, i.unidade, ' +
      '       1.0 * i.preco_embalagem / i.qtd_embalagem AS custo_unit, ' +
      '       COALESCE(SUM(CASE WHEN m.tipo = ''E'' THEN m.quantidade END), 0.0) AS entradas, ' +
      '       COALESCE(-SUM(CASE WHEN m.tipo = ''S'' THEN m.quantidade END), 0.0) AS saidas, ' +
      '       COALESCE(SUM(CASE WHEN m.tipo = ''A'' THEN m.quantidade END), 0.0) AS ajustes, ' +
      '       COALESCE(SUM(m.quantidade), 0.0) AS saldo ' +
      'FROM ingrediente i ' +
      'LEFT JOIN mov_estoque m ON m.ingrediente_id = i.id ' +
      'GROUP BY i.id, i.nome, i.unidade, i.preco_embalagem, i.qtd_embalagem ',
    'CREATE VIEW vw_estoque_tortinha AS ' +
      'SELECT t.sabor_id, t.nome, t.produzidas, t.vendidas, ' +
      '       t.produzidas - t.vendidas AS disponiveis ' +
      'FROM (SELECT s.id AS sabor_id, s.nome, ' +
      '             COALESCE((SELECT SUM(p.qtd_tortinhas) FROM producao p WHERE p.sabor_id = s.id), 0) AS produzidas, ' +
      '             COALESCE((SELECT SUM(vi.qtd) FROM venda_item vi WHERE vi.sabor_id = s.id), 0) AS vendidas ' +
      '      FROM sabor s) t ',
    'INSERT INTO ingrediente (nome, unidade, qtd_embalagem, preco_embalagem) VALUES ' +
      '  (''Bolacha'', ''g'', 300, 0), ' +
      '  (''Leite condensado'', ''g'', 395, 0), ' +
      '  (''Creme de leite'', ''g'', 200, 0), ' +
      '  (''Chocolate'', ''g'', 1000, 0), ' +
      '  (''Chantilly'', ''g'', 1000, 0), ' +
      '  (''Açúcar'', ''g'', 1000, 0), ' +
      '  (''Limão'', ''un'', 1, 0), ' +
      '  (''Embalagem'', ''un'', 100, 30), ' +
      '  (''Colherzinha'', ''un'', 50, 5.5), ' +
      '  (''Coco ralado'', ''g'', 100, 0), ' +
      '  (''Maracujá'', ''un'', 1, 0), ' +
      '  (''Leite em pó'', ''g'', 400, 0), ' +
      '  (''Nutella'', ''g'', 350, 0) ',
    'INSERT INTO sabor (nome, preco_venda, rendimento) VALUES ' +
      '  (''Brigadeiro'', 10, 16), ' +
      '  (''Prestígio'', 10, 16), ' +
      '  (''Limão'', 10, 16), ' +
      '  (''Maracujá'', 10, 16), ' +
      '  (''Ninho com Nutella'', 10, 16) ',
    'INSERT INTO receita_item (sabor_id, ingrediente_id, qtd_por_receita) ' +
      'SELECT s.id, i.id, 0 FROM sabor s, ingrediente i ' +
      'WHERE s.nome = ''Brigadeiro'' ' +
      '  AND i.nome IN (''Bolacha'', ''Leite condensado'', ''Creme de leite'', ''Chocolate'') ',
    'INSERT INTO receita_item (sabor_id, ingrediente_id, qtd_por_receita) ' +
      'SELECT s.id, i.id, 0 FROM sabor s, ingrediente i ' +
      'WHERE s.nome = ''Prestígio'' ' +
      '  AND i.nome IN (''Bolacha'', ''Leite condensado'', ''Creme de leite'', ''Chocolate'', ''Coco ralado'') ',
    'INSERT INTO receita_item (sabor_id, ingrediente_id, qtd_por_receita) ' +
      'SELECT s.id, i.id, 0 FROM sabor s, ingrediente i ' +
      'WHERE s.nome = ''Limão'' ' +
      '  AND i.nome IN (''Bolacha'', ''Leite condensado'', ''Creme de leite'', ''Limão'') ',
    'INSERT INTO receita_item (sabor_id, ingrediente_id, qtd_por_receita) ' +
      'SELECT s.id, i.id, 0 FROM sabor s, ingrediente i ' +
      'WHERE s.nome = ''Maracujá'' ' +
      '  AND i.nome IN (''Bolacha'', ''Leite condensado'', ''Creme de leite'', ''Maracujá'') ',
    'INSERT INTO receita_item (sabor_id, ingrediente_id, qtd_por_receita) ' +
      'SELECT s.id, i.id, 0 FROM sabor s, ingrediente i ' +
      'WHERE s.nome = ''Ninho com Nutella'' ' +
      '  AND i.nome IN (''Bolacha'', ''Leite condensado'', ''Creme de leite'', ''Leite em pó'', ''Nutella'') ',
    'INSERT INTO receita_item (sabor_id, ingrediente_id, qtd_por_receita) ' +
      'SELECT s.id, i.id, s.rendimento FROM sabor s, ingrediente i ' +
      'WHERE i.nome IN (''Embalagem'', ''Colherzinha'') '
  );

  // Versão 2: registro de perdas (tortinhas que estragaram ou foram descartadas)
  SCRIPT_V2: array[0..3] of string = (
    'CREATE TABLE perda ( ' +
      '  id         INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  data       DATE        NOT NULL, ' +
      '  sabor_id   INTEGER     NOT NULL REFERENCES sabor(id), ' +
      '  qtd        INTEGER     NOT NULL CHECK (qtd > 0), ' +
      '  motivo     VARCHAR(60), ' +
      '  custo_unit CURRENCY    NOT NULL ' +
      ') ',
    'CREATE INDEX ix_perda_data ON perda(data) ',
    'DROP VIEW vw_estoque_tortinha ',
    'CREATE VIEW vw_estoque_tortinha AS ' +
      'SELECT t.sabor_id, t.nome, t.produzidas, t.vendidas, t.perdidas, ' +
      '       t.produzidas - t.vendidas - t.perdidas AS disponiveis ' +
      'FROM (SELECT s.id AS sabor_id, s.nome, ' +
      '             COALESCE((SELECT SUM(p.qtd_tortinhas) FROM producao p WHERE p.sabor_id = s.id), 0) AS produzidas, ' +
      '             COALESCE((SELECT SUM(vi.qtd) FROM venda_item vi WHERE vi.sabor_id = s.id), 0) AS vendidas, ' +
      '             COALESCE((SELECT SUM(pe.qtd) FROM perda pe WHERE pe.sabor_id = s.id), 0) AS perdidas ' +
      '      FROM sabor s) t '
  );

  // Versão 3: fiado (clientes, vendas a prazo e recebimentos com pagamento parcial)
  SCRIPT_V3: array[0..9] of string = (
    'CREATE TABLE cliente ( ' +
      '  id       INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  nome     VARCHAR(60) NOT NULL UNIQUE COLLATE NOCASE, ' +
      '  telefone VARCHAR(20) ' +
      ') ',
    'ALTER TABLE venda ADD COLUMN cliente_id INTEGER REFERENCES cliente(id) ',
    'CREATE INDEX ix_venda_cliente ON venda(cliente_id) ',
    'CREATE TABLE recebimento ( ' +
      '  id         INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      '  data       DATE         NOT NULL, ' +
      '  cliente_id INTEGER      NOT NULL REFERENCES cliente(id), ' +
      '  valor      CURRENCY     NOT NULL CHECK (valor > 0), ' +
      '  forma      VARCHAR(20), ' +
      '  obs        VARCHAR(100) ' +
      ') ',
    'CREATE INDEX ix_recebimento_cliente ON recebimento(cliente_id) ',
    'CREATE INDEX ix_recebimento_data ON recebimento(data) ',
    // clientes que já estavam digitados nas vendas viram cadastro
    'INSERT OR IGNORE INTO cliente (nome) ' +
      'SELECT DISTINCT TRIM(cliente) FROM venda WHERE TRIM(COALESCE(cliente, '''')) <> '''' ',
    'UPDATE venda SET cliente_id = (SELECT c.id FROM cliente c WHERE c.nome = TRIM(venda.cliente)) ' +
      'WHERE TRIM(COALESCE(cliente, '''')) <> '''' ',
    // saldo do fiado por cliente; "em_aberto_desde" = compra mais antiga ainda não quitada
    // (os pagamentos abatem as compras mais antigas primeiro)
    'CREATE VIEW vw_fiado_compra AS ' +
      'SELECT v.cliente_id, v.id AS venda_id, v.data, ' +
      '       SUM(1.0 * vi.qtd * vi.preco_unit) AS valor, ' +
      '       SUM(SUM(1.0 * vi.qtd * vi.preco_unit)) OVER ' +
      '         (PARTITION BY v.cliente_id ORDER BY v.data, v.id) AS acumulado ' +
      'FROM venda v JOIN venda_item vi ON vi.venda_id = v.id ' +
      'WHERE v.forma_pagto = ''Fiado'' AND v.cliente_id IS NOT NULL ' +
      'GROUP BY v.cliente_id, v.id, v.data ',
    'CREATE VIEW vw_fiado_cliente AS ' +
      'SELECT c.id AS cliente_id, c.nome, c.telefone, ' +
      '       COALESCE(f.total_fiado, 0.0) AS total_fiado, ' +
      '       COALESCE(r.total_pago, 0.0) AS total_pago, ' +
      '       COALESCE(f.total_fiado, 0.0) - COALESCE(r.total_pago, 0.0) AS saldo, ' +
      '       (SELECT MIN(fc.data) FROM vw_fiado_compra fc ' +
      '         WHERE fc.cliente_id = c.id ' +
      '           AND fc.acumulado > COALESCE(r.total_pago, 0.0) + 0.005) AS em_aberto_desde, ' +
      '       r.ultimo_pagamento ' +
      'FROM cliente c ' +
      'LEFT JOIN (SELECT cliente_id, SUM(valor) AS total_fiado ' +
      '           FROM vw_fiado_compra GROUP BY cliente_id) f ON f.cliente_id = c.id ' +
      'LEFT JOIN (SELECT cliente_id, SUM(1.0 * valor) AS total_pago, MAX(data) AS ultimo_pagamento ' +
      '           FROM recebimento GROUP BY cliente_id) r ON r.cliente_id = c.id '
  );

procedure Executar(AConn: TFDConnection; const AScript: array of string;
  ANovaVersao: Integer);
var
  I: Integer;
begin
  AConn.StartTransaction;
  try
    for I := Low(AScript) to High(AScript) do
      AConn.ExecSQL(AScript[I]);
    AConn.ExecSQL('PRAGMA user_version = ' + IntToStr(ANovaVersao));
    AConn.Commit;
  except
    AConn.Rollback;
    raise;
  end;
end;

procedure AtualizarBanco(AConn: TFDConnection);
var
  Versao: Integer;
begin
  Versao := AConn.ExecSQLScalar('PRAGMA user_version');

  if Versao < 1 then
    Executar(AConn, SCRIPT_V1, 1);

  if Versao < 2 then
    Executar(AConn, SCRIPT_V2, 2);

  if Versao < 3 then
    Executar(AConn, SCRIPT_V3, 3);

  // if Versao < 4 then
  //   Executar(AConn, SCRIPT_V4, 4);
end;

end.
