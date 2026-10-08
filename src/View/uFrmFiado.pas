unit uFrmFiado;

{ Fiado: quem está devendo, extrato de cada cliente, recebimento de pagamentos
  (inclusive parciais) e mensagem de cobrança para colar no WhatsApp. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client;

type
  TFrmFiado = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlClientes: TPanel;
    pnlFiltroCli: TPanel;
    chkSoDevedores: TCheckBox;
    lblTotalAReceber: TLabel;
    pnlReceber: TPanel;
    lblClienteSel: TLabel;
    lblSaldoSel: TLabel;
    lblDesde: TLabel;
    lblValor: TLabel;
    edValor: TEdit;
    lblFormaReceb: TLabel;
    cbFormaReceb: TComboBox;
    lblDataReceb: TLabel;
    dtpDataReceb: TDateTimePicker;
    btnReceber: TButton;
    btnCobranca: TButton;
    grdClientes: TDBGrid;
    pnlExtratoTopo: TPanel;
    lblExtrato: TLabel;
    btnExcluirPagamento: TButton;
    pnlCliente: TPanel;
    lblNome: TLabel;
    edNome: TEdit;
    lblTelefone: TLabel;
    edTelefone: TEdit;
    btnNovoCliente: TButton;
    btnSalvarCliente: TButton;
    btnExcluirCliente: TButton;
    sgExtrato: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure chkSoDevedoresClick(Sender: TObject);
    procedure btnReceberClick(Sender: TObject);
    procedure btnCobrancaClick(Sender: TObject);
    procedure btnExcluirPagamentoClick(Sender: TObject);
    procedure btnNovoClienteClick(Sender: TObject);
    procedure btnSalvarClienteClick(Sender: TObject);
    procedure btnExcluirClienteClick(Sender: TObject);
    procedure grdClientesCellClick(Column: TColumn);
  private
    FQry: TFDQuery;
    FDS: TDataSource;
    FClienteId: Integer;
    FTipos: TArray<Integer>;   // por linha do extrato: 1 = venda, 2 = pagamento
    FRefIds: TArray<Integer>;  // id da venda ou do recebimento
    procedure DSDataChange(Sender: TObject; Field: TField);
    procedure Atualizar(AClienteId: Integer = 0);
    procedure CarregarCliente;
    procedure CarregarExtrato;
  end;

implementation

{$R *.dfm}

uses
  System.Math, Vcl.Clipbrd, uDMConexao, uUtils, uUIHelpers, uFiadoService;

const
  SQL_CLIENTES =
    'SELECT cliente_id AS id, nome, telefone, ' +
    '  saldo AS "vl_saldo::FLOAT", ' +
    '  em_aberto_desde AS "dt_desde::DATE", ' +
    '  CAST(julianday(date(''now'', ''localtime'')) - julianday(em_aberto_desde) AS INTEGER) ' +
    '    AS "nr_dias::INTEGER", ' +
    '  total_fiado AS "vl_comprado::FLOAT", ' +
    '  total_pago AS "vl_pago::FLOAT", ' +
    '  ultimo_pagamento AS "dt_ultimo::DATE" ' +
    'FROM vw_fiado_cliente ' +
    'WHERE (:so_devedores = 0 OR saldo > 0.005) ' +
    'ORDER BY saldo DESC, nome';

  ROTULOS: array[0..15] of string = (
    'nome', 'Cliente',
    'telefone', 'Telefone',
    'vl_saldo', 'Saldo devedor',
    'dt_desde', 'Em aberto desde',
    'nr_dias', 'Dias',
    'vl_comprado', 'Comprou fiado',
    'vl_pago', 'Já pagou',
    'dt_ultimo', 'Último pagamento');

  SQL_EXTRATO =
    'SELECT e.tipo, e.ref_id, e.data, e.qtd, e.forma, e.debito, e.credito FROM (' +
    '  SELECT 1 AS tipo, v.id AS ref_id, v.data, SUM(vi.qtd) AS qtd, v.forma_pagto AS forma, ' +
    '         SUM(1.0 * vi.qtd * vi.preco_unit) AS debito, 0.0 AS credito ' +
    '  FROM venda v JOIN venda_item vi ON vi.venda_id = v.id ' +
    '  WHERE v.cliente_id = :cli1 AND v.forma_pagto = :forma ' +
    '  GROUP BY v.id, v.data, v.forma_pagto ' +
    '  UNION ALL ' +
    '  SELECT 2, r.id, r.data, 0, r.forma, 0.0, 1.0 * r.valor ' +
    '  FROM recebimento r WHERE r.cliente_id = :cli2 ' +
    ') e ' +
    'ORDER BY e.data, e.tipo, e.ref_id';

function DataDoCampo(F: TField): TDateTime;
var
  S: string;
begin
  if F.IsNull then
    Exit(0);
  if F is TDateTimeField then
    Exit(F.AsDateTime);
  S := F.AsString; // 'yyyy-mm-dd'
  Result := EncodeDate(StrToInt(Copy(S, 1, 4)), StrToInt(Copy(S, 6, 2)), StrToInt(Copy(S, 9, 2)));
end;

procedure TFrmFiado.FormCreate(Sender: TObject);
begin
  dtpDataReceb.Date := Date;
  cbFormaReceb.ItemIndex := 0;

  sgExtrato.ColCount := 5;
  sgExtrato.FixedCols := 0;
  sgExtrato.FixedRows := 1;
  sgExtrato.ColWidths[0] := 100;
  sgExtrato.ColWidths[1] := 330;
  sgExtrato.ColWidths[2] := 120;
  sgExtrato.ColWidths[3] := 120;
  sgExtrato.ColWidths[4] := 120;

  FQry := DMConexao.NovaQuery(Self, SQL_CLIENTES);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQry;
  FDS.OnDataChange := DSDataChange;
  grdClientes.DataSource := FDS;
  Atualizar;
end;

procedure TFrmFiado.Atualizar(AClienteId: Integer);
begin
  FQry.ParamByName('so_devedores').AsInteger := Ord(chkSoDevedores.Checked);
  Reabrir(FQry, ROTULOS, AClienteId);
  lblTotalAReceber.Caption := 'Total a receber: ' + FmtMoeda(TotalAReceber);
  if FQry.IsEmpty then
  begin
    FClienteId := 0;
    CarregarCliente;
  end;
end;

procedure TFrmFiado.DSDataChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
  begin
    FClienteId := IdAtual(FQry);
    CarregarCliente;
  end;
end;

procedure TFrmFiado.grdClientesCellClick(Column: TColumn);
begin
  FClienteId := IdAtual(FQry);
  CarregarCliente;
end;

procedure TFrmFiado.CarregarCliente;
var
  S: TSaldoFiado;
begin
  if FClienteId = 0 then
  begin
    lblClienteSel.Caption := 'Nenhuma cliente selecionada';
    lblSaldoSel.Caption := '';
    lblDesde.Caption := '';
    edValor.Clear;
    edNome.Clear;
    edTelefone.Clear;
    CarregarExtrato;
    Exit;
  end;

  S := SaldoFiado(FClienteId);
  lblClienteSel.Caption := S.Nome;
  edNome.Text := S.Nome;
  edTelefone.Text := S.Telefone;
  if S.Saldo > 0.005 then
  begin
    lblSaldoSel.Caption := 'Deve ' + FmtMoeda(S.Saldo);
    lblSaldoSel.Font.Color := $000080FF; // laranja
    edValor.Text := FormatFloat('0.00', S.Saldo);
  end
  else if S.Saldo < -0.005 then
  begin
    lblSaldoSel.Caption := 'Crédito de ' + FmtMoeda(-S.Saldo);
    lblSaldoSel.Font.Color := clGreen;
    edValor.Clear;
  end
  else
  begin
    lblSaldoSel.Caption := 'Em dia';
    lblSaldoSel.Font.Color := clGreen;
    edValor.Clear;
  end;
  if S.EmAbertoDesde > 0 then
    lblDesde.Caption := Format('Em aberto desde %s (%d dias)',
      [FormatDateTime('dd/mm/yyyy', S.EmAbertoDesde), Trunc(Date - S.EmAbertoDesde)])
  else
    lblDesde.Caption := '';
  CarregarExtrato;
end;

procedure TFrmFiado.CarregarExtrato;
var
  Q: TFDQuery;
  Linha, Tipo, N: Integer;
  Saldo, Debito, Credito: Double;
begin
  sgExtrato.RowCount := 2;
  sgExtrato.Rows[0].CommaText := 'Data,"Descrição",Compra,Pagamento,Saldo';
  sgExtrato.Rows[1].Clear;
  SetLength(FTipos, 0);
  SetLength(FRefIds, 0);
  if FClienteId = 0 then
  begin
    lblExtrato.Caption := 'Extrato';
    Exit;
  end;
  lblExtrato.Caption := 'Extrato de ' + lblClienteSel.Caption;

  Q := DMConexao.NovaQuery(nil, SQL_EXTRATO);
  try
    Q.ParamByName('cli1').AsInteger := FClienteId;
    Q.ParamByName('cli2').AsInteger := FClienteId;
    Q.ParamByName('forma').AsString := FORMA_FIADO;
    Q.Open;
    Saldo := 0;
    Linha := 0;
    while not Q.Eof do
    begin
      Inc(Linha);
      sgExtrato.RowCount := Max(2, Linha + 1);
      Tipo := Round(NumCampo(Q.Fields[0]));
      Debito := NumCampo(Q.Fields[5]);
      Credito := NumCampo(Q.Fields[6]);
      Saldo := Saldo + Debito - Credito;
      N := Length(FTipos);
      SetLength(FTipos, N + 1);
      SetLength(FRefIds, N + 1);
      FTipos[N] := Tipo;
      FRefIds[N] := Round(NumCampo(Q.Fields[1]));

      sgExtrato.Cells[0, Linha] := FormatDateTime('dd/mm/yyyy', DataDoCampo(Q.Fields[2]));
      if Tipo = 1 then
      begin
        sgExtrato.Cells[1, Linha] := Format('Venda nº %d (%s tortinha(s))',
          [FRefIds[N], FmtQtd(NumCampo(Q.Fields[3]))]);
        sgExtrato.Cells[2, Linha] := FmtMoeda(Debito);
        sgExtrato.Cells[3, Linha] := '';
      end
      else
      begin
        if Trim(Q.Fields[4].AsString) <> '' then
          sgExtrato.Cells[1, Linha] := 'Pagamento - ' + Q.Fields[4].AsString
        else
          sgExtrato.Cells[1, Linha] := 'Pagamento';
        sgExtrato.Cells[2, Linha] := '';
        sgExtrato.Cells[3, Linha] := FmtMoeda(Credito);
      end;
      sgExtrato.Cells[4, Linha] := FmtMoeda(Saldo);
      Q.Next;
    end;
    if Linha > 0 then
      sgExtrato.Row := Linha; // mostra o lançamento mais recente
  finally
    Q.Free;
  end;
end;

procedure TFrmFiado.chkSoDevedoresClick(Sender: TObject);
begin
  Atualizar(FClienteId);
end;

procedure TFrmFiado.btnReceberClick(Sender: TObject);
var
  Valor, Devendo: Double;
  S: TSaldoFiado;
begin
  if FClienteId = 0 then
    raise EValidacao.Create('Selecione a cliente na lista.');
  Valor := LerNumero(edValor, 'Valor recebido');
  S := SaldoFiado(FClienteId);
  Devendo := S.Saldo;
  if Devendo < 0 then
    Devendo := 0;
  if (Valor > Devendo + 0.005) and not Confirmar(Format(
    'O valor (%s) é maior que o saldo devedor (%s).' + sLineBreak +
    'A diferença ficará como crédito para %s. Continuar?',
    [FmtMoeda(Valor), FmtMoeda(Devendo), S.Nome])) then
    Exit;
  RegistrarRecebimento(dtpDataReceb.Date, FClienteId, Valor, cbFormaReceb.Text, '');
  Atualizar(FClienteId);
  CarregarCliente;
end;

procedure TFrmFiado.btnCobrancaClick(Sender: TObject);
var
  Msg: string;
begin
  if FClienteId = 0 then
    raise EValidacao.Create('Selecione a cliente na lista.');
  Msg := MensagemCobranca(FClienteId);
  Clipboard.AsText := Msg;
  Informar('Mensagem copiada. É só colar no WhatsApp:' + sLineBreak + sLineBreak + Msg);
end;

procedure TFrmFiado.btnExcluirPagamentoClick(Sender: TObject);
var
  I: Integer;
begin
  I := sgExtrato.Row - 1;
  if (I < 0) or (I > High(FTipos)) then
    Exit;
  if FTipos[I] <> 2 then
    raise EValidacao.Create('Selecione um pagamento no extrato. Vendas são excluídas na tela de Vendas.');
  if not Confirmar(Format('Excluir o pagamento de %s em %s?',
    [sgExtrato.Cells[3, I + 1], sgExtrato.Cells[0, I + 1]])) then
    Exit;
  ExcluirRecebimento(FRefIds[I]);
  Atualizar(FClienteId);
  CarregarCliente;
end;

procedure TFrmFiado.btnNovoClienteClick(Sender: TObject);
begin
  FClienteId := 0;
  CarregarCliente;
  lblClienteSel.Caption := 'Nova cliente';
  edNome.SetFocus;
end;

procedure TFrmFiado.btnSalvarClienteClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := FClienteId;
  SalvarCliente(Id, edNome.Text, edTelefone.Text);
  FClienteId := Id;
  // a cliente nova não tem saldo; mostra todas para ela aparecer na lista
  if chkSoDevedores.Checked and (SaldoFiado(Id).Saldo <= 0.005) then
    chkSoDevedores.Checked := False; // dispara chkSoDevedoresClick
  Atualizar(Id);
  CarregarCliente;
end;

procedure TFrmFiado.btnExcluirClienteClick(Sender: TObject);
begin
  if FClienteId = 0 then
    Exit;
  if not Confirmar('Excluir a cliente "' + edNome.Text + '" do cadastro?') then
    Exit;
  ExcluirCliente(FClienteId);
  FClienteId := 0;
  Atualizar;
end;

end.
