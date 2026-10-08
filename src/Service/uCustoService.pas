unit uCustoService;

{ Cálculo de custos (substitui as abas "Ingredientes", "Receitas" e
  "Custos por Tortinha" da planilha).

  Custo por unidade do ingrediente = preço da embalagem / qtd. na embalagem
  Custo da receita                 = soma (qtd. usada x custo por unidade)
  Custo por tortinha               = custo da receita / rendimento do sabor

  As fórmulas ficam na view vw_custo_sabor (ver db/schema.sql). }

interface

/// Custo direto de UMA tortinha do sabor, com os preços atuais dos ingredientes.
function CustoPorTortinha(ASaborId: Integer): Currency;

/// Preço de venda cadastrado para o sabor.
function PrecoVendaSabor(ASaborId: Integer): Currency;

/// Rendimento (tortinhas por receita) do sabor.
function RendimentoSabor(ASaborId: Integer): Integer;

implementation

uses
  uDMConexao, uUtils;

function CustoPorTortinha(ASaborId: Integer): Currency;
begin
  Result := NumVar(Conn.ExecSQLScalar(
    'SELECT custo_unit AS "custo::FLOAT" FROM vw_custo_sabor WHERE sabor_id = :id',
    [ASaborId]));
end;

function PrecoVendaSabor(ASaborId: Integer): Currency;
begin
  Result := NumVar(Conn.ExecSQLScalar(
    'SELECT preco_venda FROM sabor WHERE id = :id', [ASaborId]));
end;

function RendimentoSabor(ASaborId: Integer): Integer;
begin
  Result := Round(NumVar(Conn.ExecSQLScalar(
    'SELECT rendimento FROM sabor WHERE id = :id', [ASaborId])));
end;

end.
