unit uEstoqueService;

{ Estoque de ingredientes por movimentação (tabela mov_estoque):
    (as perdas de tortinhas prontas ficam na tabela perda)
    Compra   -> entrada (E, quantidade positiva)
    Produção -> saída   (S, quantidade negativa, conforme a receita)
    Ajuste   -> inventário (A, diferença entre o contado e o saldo do sistema)
  Saldo atual = soma das quantidades (view vw_estoque_ingrediente). }

interface

uses
  System.SysUtils, System.Classes;

/// Registra a compra de AEmbalagens embalagens do ingrediente e dá entrada no estoque.
/// Se AAtualizarPreco, o preço da embalagem no cadastro passa a ser AValorTotal / AEmbalagens.
function RegistrarCompra(AData: TDateTime; AIngredienteId: Integer;
  AEmbalagens: Double; AValorTotal: Currency; AAtualizarPreco: Boolean): Integer;
procedure ExcluirCompra(ACompraId: Integer);

/// Registra a produção de AReceitas receitas do sabor e baixa os ingredientes.
function RegistrarProducao(AData: TDateTime; ASaborId: Integer; AReceitas: Double): Integer;
procedure ExcluirProducao(AProducaoId: Integer);

/// Lista os ingredientes que faltam para produzir (vazia = tem tudo).
function FaltasParaProducao(ASaborId: Integer; AReceitas: Double): TStringList;

/// Saldo atual do ingrediente.
function SaldoIngrediente(AIngredienteId: Integer): Double;

/// Ajusta o saldo para AQtdContada (lança a diferença como ajuste).
procedure AjustarEstoque(AIngredienteId: Integer; AQtdContada: Double; AData: TDateTime);

/// Registra tortinhas prontas que estragaram, venceram ou foram descartadas.
/// O custo unitário do momento fica gravado, como na venda.
function RegistrarPerda(AData: TDateTime; ASaborId, AQtd: Integer; const AMotivo: string): Integer;
procedure ExcluirPerda(APerdaId: Integer);

/// Tortinhas prontas do sabor: produzidas - vendidas - perdidas.
function TortinhasDisponiveis(ASaborId: Integer): Integer;

implementation

uses
  FireDAC.Comp.Client, uDMConexao, uUtils, uCustoService;

function RegistrarCompra(AData: TDateTime; AIngredienteId: Integer;
  AEmbalagens: Double; AValorTotal: Currency; AAtualizarPreco: Boolean): Integer;
var
  QtdEmbalagem, Quantidade: Double;
  PrecoEmbalagem: Currency;
begin
  if AIngredienteId <= 0 then
    raise EValidacao.Create('Selecione o ingrediente.');
  if AEmbalagens <= 0 then
    raise EValidacao.Create('Informe quantas embalagens foram compradas.');
  if AValorTotal < 0 then
    raise EValidacao.Create('O valor não pode ser negativo.');

  QtdEmbalagem := NumVar(Conn.ExecSQLScalar(
    'SELECT qtd_embalagem FROM ingrediente WHERE id = :id', [AIngredienteId]));
  Quantidade := AEmbalagens * QtdEmbalagem;

  Conn.StartTransaction;
  try
    Conn.ExecSQL(
      'INSERT INTO compra (data, ingrediente_id, qtd_embalagens, quantidade, valor_total) ' +
      'VALUES (:data, :ingrediente, :embalagens, :quantidade, :valor)',
      [DataSQL(AData), AIngredienteId, AEmbalagens, Quantidade, AValorTotal]);
    Result := DMConexao.UltimoId;

    Conn.ExecSQL(
      'INSERT INTO mov_estoque (data, ingrediente_id, tipo, quantidade, origem, origem_id) ' +
      'VALUES (:data, :ingrediente, ''E'', :quantidade, ''COMPRA'', :origem)',
      [DataSQL(AData), AIngredienteId, Quantidade, Result]);

    if AAtualizarPreco and (AValorTotal > 0) then
    begin
      PrecoEmbalagem := AValorTotal / AEmbalagens;
      Conn.ExecSQL(
        'UPDATE ingrediente SET preco_embalagem = :preco WHERE id = :id',
        [PrecoEmbalagem, AIngredienteId]);
    end;

    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

procedure ExcluirCompra(ACompraId: Integer);
begin
  Conn.StartTransaction;
  try
    Conn.ExecSQL(
      'DELETE FROM mov_estoque WHERE origem = ''COMPRA'' AND origem_id = :id', [ACompraId]);
    Conn.ExecSQL('DELETE FROM compra WHERE id = :id', [ACompraId]);
    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

function RegistrarProducao(AData: TDateTime; ASaborId: Integer; AReceitas: Double): Integer;
var
  Tortinhas: Integer;
begin
  if ASaborId <= 0 then
    raise EValidacao.Create('Selecione o sabor.');
  if AReceitas <= 0 then
    raise EValidacao.Create('Informe quantas receitas (fornadas) foram feitas.');

  Tortinhas := Round(AReceitas * RendimentoSabor(ASaborId));

  Conn.StartTransaction;
  try
    Conn.ExecSQL(
      'INSERT INTO producao (data, sabor_id, qtd_receitas, qtd_tortinhas) ' +
      'VALUES (:data, :sabor, :receitas, :tortinhas)',
      [DataSQL(AData), ASaborId, AReceitas, Tortinhas]);
    Result := DMConexao.UltimoId;

    // Uma saída por ingrediente da receita, proporcional ao nº de receitas.
    Conn.ExecSQL(
      'INSERT INTO mov_estoque (data, ingrediente_id, tipo, quantidade, origem, origem_id) ' +
      'SELECT :data, ri.ingrediente_id, ''S'', -1.0 * ri.qtd_por_receita * :receitas, ' +
      '''PRODUCAO'', :origem ' +
      'FROM receita_item ri WHERE ri.sabor_id = :sabor AND ri.qtd_por_receita > 0',
      [DataSQL(AData), AReceitas, Result, ASaborId]);

    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

procedure ExcluirProducao(AProducaoId: Integer);
begin
  Conn.StartTransaction;
  try
    Conn.ExecSQL(
      'DELETE FROM mov_estoque WHERE origem = ''PRODUCAO'' AND origem_id = :id', [AProducaoId]);
    Conn.ExecSQL('DELETE FROM producao WHERE id = :id', [AProducaoId]);
    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

function FaltasParaProducao(ASaborId: Integer; AReceitas: Double): TStringList;
var
  Q: TFDQuery;
  Necessario, Saldo: Double;
begin
  Result := TStringList.Create;
  Q := DMConexao.NovaQuery(nil,
    'SELECT i.nome, i.unidade, ri.qtd_por_receita AS qtd, e.saldo AS "saldo::FLOAT" ' +
    'FROM receita_item ri ' +
    'JOIN ingrediente i ON i.id = ri.ingrediente_id ' +
    'JOIN vw_estoque_ingrediente e ON e.ingrediente_id = ri.ingrediente_id ' +
    'WHERE ri.sabor_id = :sabor AND ri.qtd_por_receita > 0 ' +
    'ORDER BY i.nome');
  try
    Q.ParamByName('sabor').AsInteger := ASaborId;
    Q.Open;
    while not Q.Eof do
    begin
      Necessario := NumCampo(Q.Fields[2]) * AReceitas;
      Saldo := NumCampo(Q.Fields[3]);
      if Necessario > Saldo + 0.0001 then
        Result.Add(Format('%s: precisa %s %s, tem %s %s',
          [Q.Fields[0].AsString, FmtQtd(Necessario), Q.Fields[1].AsString,
           FmtQtd(Saldo), Q.Fields[1].AsString]));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function SaldoIngrediente(AIngredienteId: Integer): Double;
begin
  Result := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(quantidade), 0.0) AS "saldo::FLOAT" FROM mov_estoque ' +
    'WHERE ingrediente_id = :id', [AIngredienteId]));
end;

procedure AjustarEstoque(AIngredienteId: Integer; AQtdContada: Double; AData: TDateTime);
var
  Diferenca: Double;
begin
  if AQtdContada < 0 then
    raise EValidacao.Create('A quantidade contada não pode ser negativa.');
  Diferenca := AQtdContada - SaldoIngrediente(AIngredienteId);
  if Abs(Diferenca) < 0.0001 then
    Exit;
  Conn.ExecSQL(
    'INSERT INTO mov_estoque (data, ingrediente_id, tipo, quantidade, origem, origem_id) ' +
    'VALUES (:data, :ingrediente, ''A'', :quantidade, ''AJUSTE'', NULL)',
    [DataSQL(AData), AIngredienteId, Diferenca]);
end;

function RegistrarPerda(AData: TDateTime; ASaborId, AQtd: Integer; const AMotivo: string): Integer;
begin
  if ASaborId <= 0 then
    raise EValidacao.Create('Selecione o sabor.');
  if AQtd <= 0 then
    raise EValidacao.Create('Informe quantas tortinhas foram perdidas.');

  Conn.ExecSQL(
    'INSERT INTO perda (data, sabor_id, qtd, motivo, custo_unit) ' +
    'VALUES (:data, :sabor, :qtd, :motivo, :custo)',
    [DataSQL(AData), ASaborId, AQtd, Trim(AMotivo), CustoPorTortinha(ASaborId)]);
  Result := DMConexao.UltimoId;
end;

procedure ExcluirPerda(APerdaId: Integer);
begin
  Conn.ExecSQL('DELETE FROM perda WHERE id = :id', [APerdaId]);
end;

function TortinhasDisponiveis(ASaborId: Integer): Integer;
begin
  Result := Round(NumVar(Conn.ExecSQLScalar(
    'SELECT disponiveis AS "disp::FLOAT" FROM vw_estoque_tortinha WHERE sabor_id = :id',
    [ASaborId])));
end;

end.
