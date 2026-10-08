unit uFiadoService;

{ Fiado: clientes, vendas a prazo e recebimentos (pagamento parcial).

  Saldo da cliente = soma das vendas com forma de pagamento "Fiado"
                     - soma dos pagamentos recebidos dela.
  Os pagamentos abatem primeiro as compras mais antigas, por isso
  "em aberto desde" é a data da compra mais antiga ainda não quitada
  (ver views vw_fiado_compra e vw_fiado_cliente em uMigracoes.pas). }

interface

uses
  System.SysUtils, uUtils;

const
  FORMA_FIADO = 'Fiado';

type
  TSaldoFiado = record
    Nome: string;
    Telefone: string;
    Saldo: Double;
    EmAbertoDesde: TDateTime; // 0 = nada em aberto
  end;

// Clientes
function ObterOuCriarCliente(const ANome: string): Integer;
procedure SalvarCliente(var AId: Integer; const ANome, ATelefone: string);
procedure ExcluirCliente(AId: Integer);

// Recebimentos
function RegistrarRecebimento(AData: TDateTime; AClienteId: Integer; AValor: Currency;
  const AForma, AObs: string): Integer;
procedure ExcluirRecebimento(ARecebimentoId: Integer);

// Consultas
function SaldoFiado(AClienteId: Integer): TSaldoFiado;
function TotalAReceber: Double;
function RecebidoNoPeriodo(AInicio, AFim: TDateTime): Double;
function MensagemCobranca(AClienteId: Integer): string;

implementation

uses
  System.Variants, Data.DB, FireDAC.Comp.Client, uDMConexao;

function ObterOuCriarCliente(const ANome: string): Integer;
var
  V: Variant;
begin
  if Trim(ANome) = '' then
    Exit(0);
  V := Conn.ExecSQLScalar('SELECT id FROM cliente WHERE nome = :nome', [Trim(ANome)]);
  if not VarIsNull(V) and not VarIsEmpty(V) then
    Exit(V);
  Conn.ExecSQL('INSERT INTO cliente (nome) VALUES (:nome)', [Trim(ANome)]);
  Result := DMConexao.UltimoId;
end;

procedure SalvarCliente(var AId: Integer; const ANome, ATelefone: string);
begin
  if Trim(ANome) = '' then
    raise EValidacao.Create('Informe o nome da cliente.');
  if AId = 0 then
  begin
    Conn.ExecSQL('INSERT INTO cliente (nome, telefone) VALUES (:nome, :tel)',
      [Trim(ANome), Trim(ATelefone)]);
    AId := DMConexao.UltimoId;
  end
  else
    Conn.ExecSQL('UPDATE cliente SET nome = :nome, telefone = :tel WHERE id = :id',
      [Trim(ANome), Trim(ATelefone), AId]);
end;

procedure ExcluirCliente(AId: Integer);
begin
  // Se a cliente tiver vendas ou pagamentos, o banco impede a exclusão.
  Conn.ExecSQL('DELETE FROM cliente WHERE id = :id', [AId]);
end;

function RegistrarRecebimento(AData: TDateTime; AClienteId: Integer; AValor: Currency;
  const AForma, AObs: string): Integer;
begin
  if AClienteId <= 0 then
    raise EValidacao.Create('Selecione a cliente.');
  if AValor <= 0 then
    raise EValidacao.Create('O valor recebido deve ser maior que zero.');
  Conn.ExecSQL(
    'INSERT INTO recebimento (data, cliente_id, valor, forma, obs) ' +
    'VALUES (:data, :cliente, :valor, :forma, :obs)',
    [DataSQL(AData), AClienteId, AValor, Trim(AForma), Trim(AObs)]);
  Result := DMConexao.UltimoId;
end;

procedure ExcluirRecebimento(ARecebimentoId: Integer);
begin
  Conn.ExecSQL('DELETE FROM recebimento WHERE id = :id', [ARecebimentoId]);
end;

function SaldoFiado(AClienteId: Integer): TSaldoFiado;
var
  Q: TFDQuery;
begin
  Result := Default(TSaldoFiado);
  Q := DMConexao.NovaQuery(nil,
    'SELECT nome, telefone, saldo AS "saldo::FLOAT", em_aberto_desde AS "desde::DATE" ' +
    'FROM vw_fiado_cliente WHERE cliente_id = :id');
  try
    Q.ParamByName('id').AsInteger := AClienteId;
    Q.Open;
    if Q.IsEmpty then
      Exit;
    Result.Nome := Q.Fields[0].AsString;
    Result.Telefone := Q.Fields[1].AsString;
    Result.Saldo := NumCampo(Q.Fields[2]);
    if not Q.Fields[3].IsNull then
    begin
      if Q.Fields[3] is TDateTimeField then
        Result.EmAbertoDesde := Q.Fields[3].AsDateTime
      else // texto 'yyyy-mm-dd'
        Result.EmAbertoDesde := EncodeDate(StrToInt(Copy(Q.Fields[3].AsString, 1, 4)),
          StrToInt(Copy(Q.Fields[3].AsString, 6, 2)), StrToInt(Copy(Q.Fields[3].AsString, 9, 2)));
    end;
  finally
    Q.Free;
  end;
end;

function TotalAReceber: Double;
begin
  Result := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(saldo), 0.0) AS "total::FLOAT" FROM vw_fiado_cliente WHERE saldo > 0.005'));
end;

function RecebidoNoPeriodo(AInicio, AFim: TDateTime): Double;
begin
  Result := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(valor), 0.0) AS "total::FLOAT" FROM recebimento ' +
    'WHERE data BETWEEN :ini AND :fim', [DataSQL(AInicio), DataSQL(AFim)]));
end;

function MensagemCobranca(AClienteId: Integer): string;
var
  S: TSaldoFiado;
  PrimeiroNome: string;
begin
  S := SaldoFiado(AClienteId);
  if S.Saldo <= 0.005 then
    raise EValidacao.Create('Esta cliente não tem saldo em aberto.');
  PrimeiroNome := Trim(S.Nome);
  if Pos(' ', PrimeiroNome) > 0 then
    PrimeiroNome := Copy(PrimeiroNome, 1, Pos(' ', PrimeiroNome) - 1);
  Result := Format('Oi, %s! Tudo bem? Passando para lembrar das tortinhas que ficaram ' +
    'anotadas: o valor em aberto é de %s', [PrimeiroNome, FmtMoeda(S.Saldo)]);
  if S.EmAbertoDesde > 0 then
    Result := Result + Format(', desde %s', [FormatDateTime('dd/mm', S.EmAbertoDesde)]);
  Result := Result + '. Pode pagar por Pix ou em dinheiro, como for melhor para você. Obrigada!';
end;

end.
