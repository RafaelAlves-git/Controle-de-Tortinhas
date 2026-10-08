unit uFrmVendas;

{ Lançamento de vendas (estilo caixa) e consulta das vendas do período. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Comp.Client, uVendaService;

type
  TFrmVendas = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlLancamento: TPanel;
    lblData: TLabel;
    dtpData: TDateTimePicker;
    lblSabor: TLabel;
    cbSabor: TComboBox;
    lblQtd: TLabel;
    edQtd: TEdit;
    lblPreco: TLabel;
    edPreco: TEdit;
    btnAdicionar: TButton;
    sgCarrinho: TStringGrid;
    btnRemoverItem: TButton;
    lblCliente: TLabel;
    cbCliente: TComboBox;
    lblForma: TLabel;
    cbForma: TComboBox;
    lblTotal: TLabel;
    btnFinalizar: TButton;
    lblMensagem: TLabel;
    pnlFiltro: TPanel;
    lblDe: TLabel;
    dtpIni: TDateTimePicker;
    lblAte: TLabel;
    dtpFim: TDateTimePicker;
    btnFiltrar: TButton;
    btnExcluirVenda: TButton;
    lblTotais: TLabel;
    grdVendas: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbSaborChange(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
    procedure btnFinalizarClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnExcluirVendaClick(Sender: TObject);
    procedure cbFormaChange(Sender: TObject);
    procedure cbClienteChange(Sender: TObject);
  private
    FItens: TList<TItemVenda>;
    FQry: TFDQuery;
    FDS: TDataSource;
    procedure AtualizarCarrinho;
    procedure Filtrar;
    procedure CarregarClientes;
  end;

implementation

{$R *.dfm}

uses
  System.DateUtils, System.Math, uDMConexao, uUtils, uUIHelpers,
  uCustoService, uResumoService, uFiadoService;

const
  SQL_LISTA =
    'SELECT v.id AS nr_venda, v.data, s.nome AS sabor, vi.qtd AS qt_qtd, ' +
    '  vi.preco_unit AS vl_preco, ' +
    '  1.0 * vi.qtd * vi.preco_unit AS "vl_total::FLOAT", ' +
    '  1.0 * vi.qtd * vi.custo_unit AS "vl_custo::FLOAT", ' +
    '  1.0 * vi.qtd * (vi.preco_unit - vi.custo_unit) AS "vl_lucro::FLOAT", ' +
    '  v.forma_pagto, v.cliente ' +
    'FROM venda v ' +
    'JOIN venda_item vi ON vi.venda_id = v.id ' +
    'JOIN sabor s ON s.id = vi.sabor_id ' +
    'WHERE v.data BETWEEN :ini AND :fim ' +
    'ORDER BY v.data DESC, v.id DESC, s.nome';

  ROTULOS: array[0..19] of string = (
    'nr_venda', 'Venda',
    'data', 'Data',
    'sabor', 'Sabor',
    'qt_qtd', 'Qtd.',
    'vl_preco', 'Preço unit.',
    'vl_total', 'Total',
    'vl_custo', 'Custo',
    'vl_lucro', 'Lucro',
    'forma_pagto', 'Pagamento',
    'cliente', 'Cliente');

procedure TFrmVendas.FormCreate(Sender: TObject);
begin
  FItens := TList<TItemVenda>.Create;

  dtpData.Date := Date;
  dtpIni.Date := StartOfTheMonth(Date);
  dtpFim.Date := Date;
  edQtd.Text := '1';
  cbForma.ItemIndex := 0;
  CarregarCombo(cbSabor, 'SELECT id, nome FROM sabor ORDER BY nome');
  CarregarClientes;

  sgCarrinho.ColCount := 4;
  sgCarrinho.FixedRows := 1;
  sgCarrinho.ColWidths[0] := 250;
  sgCarrinho.ColWidths[1] := 70;
  sgCarrinho.ColWidths[2] := 100;
  sgCarrinho.ColWidths[3] := 110;
  AtualizarCarrinho;

  FQry := DMConexao.NovaQuery(Self, SQL_LISTA);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQry;
  grdVendas.DataSource := FDS;
  Filtrar;
end;

procedure TFrmVendas.FormDestroy(Sender: TObject);
begin
  FItens.Free;
end;

procedure TFrmVendas.AtualizarCarrinho;
var
  I: Integer;
  Total: Currency;
begin
  sgCarrinho.RowCount := Max(2, FItens.Count + 1);
  sgCarrinho.Rows[0].CommaText := 'Sabor,Qtd.,"Preço unit.",Total';
  for I := 1 to sgCarrinho.RowCount - 1 do
    sgCarrinho.Rows[I].Clear;

  Total := 0;
  for I := 0 to FItens.Count - 1 do
  begin
    sgCarrinho.Cells[0, I + 1] := FItens[I].Sabor;
    sgCarrinho.Cells[1, I + 1] := IntToStr(FItens[I].Qtd);
    sgCarrinho.Cells[2, I + 1] := FmtMoeda(FItens[I].PrecoUnit);
    sgCarrinho.Cells[3, I + 1] := FmtMoeda(FItens[I].Total);
    Total := Total + FItens[I].Total;
  end;
  lblTotal.Caption := 'Total: ' + FmtMoeda(Total);
end;

procedure TFrmVendas.cbSaborChange(Sender: TObject);
var
  Id: Integer;
begin
  Id := IdDoCombo(cbSabor);
  if Id > 0 then
    edPreco.Text := FormatFloat('0.00', PrecoVendaSabor(Id));
end;

procedure TFrmVendas.btnAdicionarClick(Sender: TObject);
var
  Item: TItemVenda;
  I, Qtd: Integer;
  Preco: Currency;
begin
  if IdDoCombo(cbSabor) = 0 then
    raise EValidacao.Create('Selecione o sabor.');
  Qtd := LerInteiro(edQtd, 'Quantidade');
  if Qtd <= 0 then
    raise EValidacao.Create('A quantidade deve ser maior que zero.');
  Preco := LerNumero(edPreco, 'Preço');

  // Mesmo sabor e mesmo preço: soma na linha que já existe.
  for I := 0 to FItens.Count - 1 do
    if (FItens[I].SaborId = IdDoCombo(cbSabor)) and (FItens[I].PrecoUnit = Preco) then
    begin
      Item := FItens[I];
      Item.Qtd := Item.Qtd + Qtd;
      FItens[I] := Item;
      AtualizarCarrinho;
      edQtd.Text := '1';
      Exit;
    end;

  Item.SaborId := IdDoCombo(cbSabor);
  Item.Sabor := cbSabor.Text;
  Item.Qtd := Qtd;
  Item.PrecoUnit := Preco;
  FItens.Add(Item);
  AtualizarCarrinho;
  edQtd.Text := '1';
  lblMensagem.Caption := '';
end;

procedure TFrmVendas.btnRemoverItemClick(Sender: TObject);
var
  Linha: Integer;
begin
  Linha := sgCarrinho.Row;
  if (Linha >= 1) and (Linha <= FItens.Count) then
  begin
    FItens.Delete(Linha - 1);
    AtualizarCarrinho;
  end;
end;

procedure TFrmVendas.btnFinalizarClick(Sender: TObject);
var
  VendaId: Integer;
begin
  VendaId := RegistrarVenda(dtpData.Date, cbCliente.Text, cbForma.Text, FItens.ToArray);
  FItens.Clear;
  AtualizarCarrinho;
  if SameText(cbForma.Text, FORMA_FIADO) then
    lblMensagem.Caption := Format('Venda nº %d no fiado. Saldo de %s: %s',
      [VendaId, Trim(cbCliente.Text),
       FmtMoeda(SaldoFiado(ObterOuCriarCliente(cbCliente.Text)).Saldo)])
  else
    lblMensagem.Caption := Format('Venda nº %d registrada.', [VendaId]);
  cbCliente.Text := '';
  CarregarClientes;
  Filtrar;
end;

procedure TFrmVendas.CarregarClientes;
begin
  CarregarCombo(cbCliente, 'SELECT id, nome FROM cliente ORDER BY nome');
end;

procedure TFrmVendas.cbFormaChange(Sender: TObject);
begin
  if SameText(cbForma.Text, FORMA_FIADO) then
  begin
    lblMensagem.Caption := 'Fiado: informe a cliente; o valor entra no saldo dela.';
    if cbCliente.CanFocus then
      cbCliente.SetFocus;
  end
  else
    lblMensagem.Caption := '';
end;

procedure TFrmVendas.cbClienteChange(Sender: TObject);
var
  S: TSaldoFiado;
begin
  if IdDoCombo(cbCliente) = 0 then
    Exit;
  S := SaldoFiado(IdDoCombo(cbCliente));
  if S.Saldo > 0.005 then
    lblMensagem.Caption := Format('%s já deve %s no fiado.', [S.Nome, FmtMoeda(S.Saldo)])
  else
    lblMensagem.Caption := '';
end;

procedure TFrmVendas.Filtrar;
var
  R: TResumo;
begin
  FQry.ParamByName('ini').AsString := DataSQL(dtpIni.Date);
  FQry.ParamByName('fim').AsString := DataSQL(dtpFim.Date);
  Reabrir(FQry, ROTULOS);

  R := CalcularResumo(dtpIni.Date, dtpFim.Date);
  lblTotais.Caption := Format('Vendas: %d   |   Tortinhas: %s   |   Faturamento: %s   |   Lucro bruto: %s',
    [R.NumVendas, FmtQtd(R.QtdVendida), FmtMoeda(R.Faturamento), FmtMoeda(R.LucroBruto)]);
end;

procedure TFrmVendas.btnFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmVendas.btnExcluirVendaClick(Sender: TObject);
var
  VendaId: Integer;
begin
  VendaId := IdAtual(FQry, 'nr_venda');
  if VendaId = 0 then
    Exit;
  if not Confirmar(Format('Excluir a venda nº %d inteira (todos os itens)?', [VendaId])) then
    Exit;
  ExcluirVenda(VendaId);
  Filtrar;
end;

end.
