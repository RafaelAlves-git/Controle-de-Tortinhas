unit uCadastroService;

{ Gravação dos cadastros: ingredientes, sabores, receitas e despesas.
  As telas só montam os dados e chamam estas rotinas. }

interface

uses
  System.SysUtils, uUtils;

// Ingredientes
procedure SalvarIngrediente(var AId: Integer; const ANome, AUnidade: string;
  AQtdEmbalagem: Double; APrecoEmbalagem: Currency);
procedure ExcluirIngrediente(AId: Integer);

// Sabores
procedure SalvarSabor(var AId: Integer; const ANome: string;
  APrecoVenda: Currency; ARendimento: Integer);
procedure ExcluirSabor(AId: Integer);

// Itens da receita (inclui ou atualiza a quantidade do ingrediente)
procedure SalvarItemReceita(ASaborId, AIngredienteId: Integer; AQtdPorReceita: Double);
procedure ExcluirItemReceita(AItemId: Integer);

// Despesas
procedure SalvarDespesa(var AId: Integer; AData: TDateTime;
  const ADescricao, ACategoria: string; AValor: Currency);
procedure ExcluirDespesa(AId: Integer);

implementation

uses
  uDMConexao;

{ Ingredientes }

procedure SalvarIngrediente(var AId: Integer; const ANome, AUnidade: string;
  AQtdEmbalagem: Double; APrecoEmbalagem: Currency);
begin
  if Trim(ANome) = '' then
    raise EValidacao.Create('Informe o nome do ingrediente.');
  if Trim(AUnidade) = '' then
    raise EValidacao.Create('Informe a unidade (g, ml, un...).');
  if AQtdEmbalagem <= 0 then
    raise EValidacao.Create('A quantidade da embalagem deve ser maior que zero.');
  if APrecoEmbalagem < 0 then
    raise EValidacao.Create('O preço não pode ser negativo.');

  if AId = 0 then
  begin
    Conn.ExecSQL(
      'INSERT INTO ingrediente (nome, unidade, qtd_embalagem, preco_embalagem) ' +
      'VALUES (:nome, :unidade, :qtd, :preco)',
      [Trim(ANome), Trim(AUnidade), AQtdEmbalagem, APrecoEmbalagem]);
    AId := DMConexao.UltimoId;
  end
  else
    Conn.ExecSQL(
      'UPDATE ingrediente SET nome = :nome, unidade = :unidade, ' +
      'qtd_embalagem = :qtd, preco_embalagem = :preco WHERE id = :id',
      [Trim(ANome), Trim(AUnidade), AQtdEmbalagem, APrecoEmbalagem, AId]);
end;

procedure ExcluirIngrediente(AId: Integer);
begin
  Conn.ExecSQL('DELETE FROM ingrediente WHERE id = :id', [AId]);
end;

{ Sabores }

procedure SalvarSabor(var AId: Integer; const ANome: string;
  APrecoVenda: Currency; ARendimento: Integer);
begin
  if Trim(ANome) = '' then
    raise EValidacao.Create('Informe o nome do sabor.');
  if APrecoVenda < 0 then
    raise EValidacao.Create('O preço de venda não pode ser negativo.');
  if ARendimento <= 0 then
    raise EValidacao.Create('O rendimento (tortinhas por receita) deve ser maior que zero.');

  if AId = 0 then
  begin
    Conn.ExecSQL(
      'INSERT INTO sabor (nome, preco_venda, rendimento) VALUES (:nome, :preco, :rend)',
      [Trim(ANome), APrecoVenda, ARendimento]);
    AId := DMConexao.UltimoId;
  end
  else
    Conn.ExecSQL(
      'UPDATE sabor SET nome = :nome, preco_venda = :preco, rendimento = :rend ' +
      'WHERE id = :id',
      [Trim(ANome), APrecoVenda, ARendimento, AId]);
end;

procedure ExcluirSabor(AId: Integer);
begin
  // Os itens da receita saem junto (ON DELETE CASCADE).
  // Se houver vendas ou produção do sabor, o banco impede a exclusão.
  Conn.ExecSQL('DELETE FROM sabor WHERE id = :id', [AId]);
end;

{ Receita }

procedure SalvarItemReceita(ASaborId, AIngredienteId: Integer; AQtdPorReceita: Double);
begin
  if ASaborId <= 0 then
    raise EValidacao.Create('Selecione um sabor.');
  if AIngredienteId <= 0 then
    raise EValidacao.Create('Selecione o ingrediente.');
  if AQtdPorReceita < 0 then
    raise EValidacao.Create('A quantidade não pode ser negativa.');

  Conn.ExecSQL(
    'INSERT INTO receita_item (sabor_id, ingrediente_id, qtd_por_receita) ' +
    'VALUES (:sabor, :ingrediente, :qtd) ' +
    'ON CONFLICT (sabor_id, ingrediente_id) ' +
    'DO UPDATE SET qtd_por_receita = excluded.qtd_por_receita',
    [ASaborId, AIngredienteId, AQtdPorReceita]);
end;

procedure ExcluirItemReceita(AItemId: Integer);
begin
  Conn.ExecSQL('DELETE FROM receita_item WHERE id = :id', [AItemId]);
end;

{ Despesas }

procedure SalvarDespesa(var AId: Integer; AData: TDateTime;
  const ADescricao, ACategoria: string; AValor: Currency);
begin
  if Trim(ADescricao) = '' then
    raise EValidacao.Create('Informe a descrição da despesa.');
  if AValor <= 0 then
    raise EValidacao.Create('O valor da despesa deve ser maior que zero.');

  if AId = 0 then
  begin
    Conn.ExecSQL(
      'INSERT INTO despesa (data, descricao, categoria, valor) ' +
      'VALUES (:data, :descricao, :categoria, :valor)',
      [DataSQL(AData), Trim(ADescricao), Trim(ACategoria), AValor]);
    AId := DMConexao.UltimoId;
  end
  else
    Conn.ExecSQL(
      'UPDATE despesa SET data = :data, descricao = :descricao, ' +
      'categoria = :categoria, valor = :valor WHERE id = :id',
      [DataSQL(AData), Trim(ADescricao), Trim(ACategoria), AValor, AId]);
end;

procedure ExcluirDespesa(AId: Integer);
begin
  Conn.ExecSQL('DELETE FROM despesa WHERE id = :id', [AId]);
end;

end.
