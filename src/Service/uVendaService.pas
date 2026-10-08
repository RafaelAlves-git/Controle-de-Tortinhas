unit uVendaService;

{ Registro de vendas.
  Na gravação, o custo unitário de cada tortinha é "congelado" no item da venda:
  se o preço de um ingrediente mudar depois, o lucro das vendas antigas não muda
  (na planilha, o PROCV recalculava tudo com o custo atual). }

interface

uses
  System.SysUtils;

type
  TItemVenda = record
    SaborId: Integer;
    Sabor: string;
    Qtd: Integer;
    PrecoUnit: Currency;
    function Total: Currency;
  end;

function RegistrarVenda(AData: TDateTime; const ACliente, AFormaPagto: string;
  const AItens: TArray<TItemVenda>): Integer;
procedure ExcluirVenda(AVendaId: Integer);

implementation

uses
  uDMConexao, uUtils, uCustoService, uFiadoService;

function TItemVenda.Total: Currency;
begin
  Result := Qtd * PrecoUnit;
end;

function RegistrarVenda(AData: TDateTime; const ACliente, AFormaPagto: string;
  const AItens: TArray<TItemVenda>): Integer;
var
  Item: TItemVenda;
  ClienteId: Integer;
begin
  if Length(AItens) = 0 then
    raise EValidacao.Create('Adicione pelo menos um item à venda.');
  for Item in AItens do
    if Item.Qtd <= 0 then
      raise EValidacao.Create('Há item com quantidade inválida.');
  if SameText(AFormaPagto, FORMA_FIADO) and (Trim(ACliente) = '') then
    raise EValidacao.Create('Para vender fiado, informe quem é a cliente.');

  Conn.StartTransaction;
  try
    // Cliente digitada pela primeira vez entra no cadastro automaticamente.
    ClienteId := ObterOuCriarCliente(ACliente);
    // (sem cliente, cliente_id fica NULL: o FireDAC não aceita parâmetro Null sem tipo)
    if ClienteId > 0 then
      Conn.ExecSQL(
        'INSERT INTO venda (data, cliente, cliente_id, forma_pagto) ' +
        'VALUES (:data, :cliente, :cliente_id, :forma)',
        [DataSQL(AData), Trim(ACliente), ClienteId, AFormaPagto])
    else
      Conn.ExecSQL(
        'INSERT INTO venda (data, cliente, forma_pagto) VALUES (:data, :cliente, :forma)',
        [DataSQL(AData), '', AFormaPagto]);
    Result := DMConexao.UltimoId;

    for Item in AItens do
      Conn.ExecSQL(
        'INSERT INTO venda_item (venda_id, sabor_id, qtd, preco_unit, custo_unit) ' +
        'VALUES (:venda, :sabor, :qtd, :preco, :custo)',
        [Result, Item.SaborId, Item.Qtd, Item.PrecoUnit,
         CustoPorTortinha(Item.SaborId)]);

    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

procedure ExcluirVenda(AVendaId: Integer);
begin
  Conn.StartTransaction;
  try
    Conn.ExecSQL('DELETE FROM venda_item WHERE venda_id = :id', [AVendaId]);
    Conn.ExecSQL('DELETE FROM venda WHERE id = :id', [AVendaId]);
    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

end.
