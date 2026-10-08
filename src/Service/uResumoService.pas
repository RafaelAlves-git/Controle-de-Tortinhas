unit uResumoService;

{ Indicadores do período (substitui a aba "Resumo" da planilha). }

interface

uses
  System.SysUtils;

type
  TResumo = record
    Faturamento: Double;     // soma de qtd x preço
    CPV: Double;             // custo dos produtos vendidos (custo congelado na venda)
    LucroBruto: Double;      // faturamento - CPV
    Despesas: Double;        // despesas extras
    Perdas: Double;          // custo das tortinhas perdidas (estragadas/descartadas)
    QtdPerdida: Double;      // tortinhas perdidas
    LucroLiquido: Double;    // lucro bruto - despesas - perdas
    QtdVendida: Double;      // tortinhas vendidas
    NumVendas: Integer;      // nº de vendas (pedidos)
    PrecoMedio: Double;      // faturamento / tortinhas  ("ticket médio" da planilha)
    TicketMedio: Double;     // faturamento / nº de vendas
    MargemLiquida: Double;   // lucro líquido / faturamento (%)
    Compras: Double;         // gasto com compra de ingredientes (informativo)
    VendidoFiado: Double;    // vendas fiado no período
    Recebido: Double;        // pagamentos de fiado recebidos no período
    AReceber: Double;        // saldo total de fiado em aberto (hoje, não depende do período)
  end;

function CalcularResumo(AInicio, AFim: TDateTime): TResumo;

const
  /// Vendas por sabor no período.
  SQL_RESUMO_POR_SABOR =
    'SELECT s.id, s.nome AS sabor, ' +
    '  SUM(vi.qtd) AS "qt_vendidas::FLOAT", ' +
    '  100.0 * SUM(vi.qtd) / (SELECT SUM(vi2.qtd) FROM venda_item vi2 ' +
    '    JOIN venda v2 ON v2.id = vi2.venda_id ' +
    '    WHERE v2.data BETWEEN :ini2 AND :fim2) AS "pc_vendas::FLOAT", ' +
    '  SUM(1.0 * vi.qtd * vi.preco_unit) AS "vl_faturamento::FLOAT", ' +
    '  SUM(1.0 * vi.qtd * vi.custo_unit) AS "vl_custo::FLOAT", ' +
    '  SUM(1.0 * vi.qtd * (vi.preco_unit - vi.custo_unit)) AS "vl_lucro::FLOAT" ' +
    'FROM venda_item vi ' +
    'JOIN venda v ON v.id = vi.venda_id ' +
    'JOIN sabor s ON s.id = vi.sabor_id ' +
    'WHERE v.data BETWEEN :ini AND :fim ' +
    'GROUP BY s.id, s.nome ' +
    'ORDER BY 5 DESC';

  /// Resultado mês a mês no período (substitui a tabela "Período 1..6").
  SQL_RESUMO_POR_MES =
    'SELECT CAST(substr(m.mes, 1, 4) AS INTEGER) AS "nr_ano::INTEGER", ' +
    '  CAST(substr(m.mes, 6, 2) AS INTEGER) AS "nr_mes::INTEGER", ' +
    '  SUM(m.fat) AS "vl_faturamento::FLOAT", ' +
    '  SUM(m.cpv) AS "vl_cpv::FLOAT", ' +
    '  SUM(m.desp) AS "vl_despesas::FLOAT", ' +
    '  SUM(m.perd) AS "vl_perdas::FLOAT", ' +
    '  SUM(m.fat - m.cpv - m.desp - m.perd) AS "vl_lucro::FLOAT" ' +
    'FROM (' +
    '  SELECT substr(v.data, 1, 7) AS mes, 1.0 * vi.qtd * vi.preco_unit AS fat, ' +
    '         1.0 * vi.qtd * vi.custo_unit AS cpv, 0.0 AS desp, 0.0 AS perd ' +
    '  FROM venda v JOIN venda_item vi ON vi.venda_id = v.id ' +
    '  WHERE v.data BETWEEN :ini AND :fim ' +
    '  UNION ALL ' +
    '  SELECT substr(d.data, 1, 7), 0.0, 0.0, 1.0 * d.valor, 0.0 ' +
    '  FROM despesa d WHERE d.data BETWEEN :ini2 AND :fim2 ' +
    '  UNION ALL ' +
    '  SELECT substr(pe.data, 1, 7), 0.0, 0.0, 0.0, 1.0 * pe.qtd * pe.custo_unit ' +
    '  FROM perda pe WHERE pe.data BETWEEN :ini3 AND :fim3 ' +
    ') m ' +
    'GROUP BY m.mes ' +
    'ORDER BY m.mes';

implementation

uses
  FireDAC.Comp.Client, uDMConexao, uUtils, uFiadoService;

const
  SQL_TOTAIS_VENDAS =
    'SELECT COALESCE(SUM(1.0 * vi.qtd * vi.preco_unit), 0.0) AS "fat::FLOAT", ' +
    '  COALESCE(SUM(1.0 * vi.qtd * vi.custo_unit), 0.0) AS "cpv::FLOAT", ' +
    '  COALESCE(SUM(vi.qtd), 0) AS "qtd::FLOAT", ' +
    '  COUNT(DISTINCT v.id) AS "nv::INTEGER" ' +
    'FROM venda v JOIN venda_item vi ON vi.venda_id = v.id ' +
    'WHERE v.data BETWEEN :ini AND :fim';

  SQL_TOTAL_DESPESAS =
    'SELECT COALESCE(SUM(valor), 0.0) AS "total::FLOAT" FROM despesa ' +
    'WHERE data BETWEEN :ini AND :fim';

  SQL_TOTAL_PERDAS =
    'SELECT COALESCE(SUM(1.0 * qtd * custo_unit), 0.0) AS "valor::FLOAT", ' +
    '  COALESCE(SUM(qtd), 0) AS "qtd::FLOAT" ' +
    'FROM perda WHERE data BETWEEN :ini AND :fim';

  SQL_TOTAL_COMPRAS =
    'SELECT COALESCE(SUM(valor_total), 0.0) AS "total::FLOAT" FROM compra ' +
    'WHERE data BETWEEN :ini AND :fim';

function CalcularResumo(AInicio, AFim: TDateTime): TResumo;
var
  Q: TFDQuery;
  Ini, Fim: string;
begin
  Result := Default(TResumo);
  Ini := DataSQL(AInicio);
  Fim := DataSQL(AFim);

  Q := DMConexao.NovaQuery(nil, SQL_TOTAIS_VENDAS);
  try
    Q.ParamByName('ini').AsString := Ini;
    Q.ParamByName('fim').AsString := Fim;
    Q.Open;
    Result.Faturamento := NumCampo(Q.Fields[0]);
    Result.CPV := NumCampo(Q.Fields[1]);
    Result.QtdVendida := NumCampo(Q.Fields[2]);
    Result.NumVendas := Round(NumCampo(Q.Fields[3]));
  finally
    Q.Free;
  end;

  Result.Despesas := NumVar(Conn.ExecSQLScalar(SQL_TOTAL_DESPESAS, [Ini, Fim]));
  Result.Compras := NumVar(Conn.ExecSQLScalar(SQL_TOTAL_COMPRAS, [Ini, Fim]));

  Q := DMConexao.NovaQuery(nil, SQL_TOTAL_PERDAS);
  try
    Q.ParamByName('ini').AsString := Ini;
    Q.ParamByName('fim').AsString := Fim;
    Q.Open;
    Result.Perdas := NumCampo(Q.Fields[0]);
    Result.QtdPerdida := NumCampo(Q.Fields[1]);
  finally
    Q.Free;
  end;

  Result.VendidoFiado := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(1.0 * vi.qtd * vi.preco_unit), 0.0) AS "v::FLOAT" ' +
    'FROM venda v JOIN venda_item vi ON vi.venda_id = v.id ' +
    'WHERE v.forma_pagto = :forma AND v.data BETWEEN :ini AND :fim', [FORMA_FIADO, Ini, Fim]));
  Result.Recebido := RecebidoNoPeriodo(AInicio, AFim);
  Result.AReceber := TotalAReceber;

  Result.LucroBruto := Result.Faturamento - Result.CPV;
  Result.LucroLiquido := Result.LucroBruto - Result.Despesas - Result.Perdas;
  if Result.QtdVendida > 0 then
    Result.PrecoMedio := Result.Faturamento / Result.QtdVendida;
  if Result.NumVendas > 0 then
    Result.TicketMedio := Result.Faturamento / Result.NumVendas;
  if Result.Faturamento > 0 then
    Result.MargemLiquida := 100 * Result.LucroLiquido / Result.Faturamento;
end;

end.
