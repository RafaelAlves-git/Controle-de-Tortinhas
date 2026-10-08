unit uFrmResumo;

{ Painel de resumo do período: indicadores, vendas por sabor (com gráfico)
  e resultado mês a mês. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client;

type
  TFrmResumo = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlFiltro: TPanel;
    lblDe: TLabel;
    dtpIni: TDateTimePicker;
    lblAte: TLabel;
    dtpFim: TDateTimePicker;
    btnAtualizar: TButton;
    btnMesAtual: TButton;
    btnMesAnterior: TButton;
    btnAno: TButton;
    pnlKpis: TPanel;
    pnlSabores: TPanel;
    lblSabores: TLabel;
    grdSabores: TDBGrid;
    pbGrafico: TPaintBox;
    lblMeses: TLabel;
    grdMeses: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnMesAtualClick(Sender: TObject);
    procedure btnMesAnteriorClick(Sender: TObject);
    procedure btnAnoClick(Sender: TObject);
    procedure pbGraficoPaint(Sender: TObject);
  private
    FQrySabores: TFDQuery;
    FDSSabores: TDataSource;
    FQryMeses: TFDQuery;
    FDSMeses: TDataSource;
    // Valores dos cartões
    FFaturamento, FCPV, FLucroBruto, FDespesas, FPerdas, FLucroLiquido: TLabel;
    FQtdVendida, FQtdPerdida, FPrecoMedio, FMargem: TLabel;
    FAReceber, FRecebido, FVendidoFiado: TLabel;
    // Dados do gráfico
    FNomes: TArray<string>;
    FValores: TArray<Double>;
    function CriarCard(ACol, ALinha: Integer; const ATitulo: string): TLabel;
    procedure Atualizar;
    procedure CarregarGrafico;
  end;

implementation

{$R *.dfm}

uses
  System.DateUtils, System.Math, uDMConexao, uUtils, uUIHelpers, uResumoService;

const
  ROT_SABORES: array[0..11] of string = (
    'sabor', 'Sabor',
    'qt_vendidas', 'Qtd. vendida',
    'pc_vendas', '% vendas',
    'vl_faturamento', 'Faturamento',
    'vl_custo', 'Custo',
    'vl_lucro', 'Lucro bruto');

  ROT_MESES: array[0..13] of string = (
    'nr_ano', 'Ano',
    'nr_mes', 'Mês',
    'vl_faturamento', 'Faturamento',
    'vl_cpv', 'Custo produtos',
    'vl_despesas', 'Despesas',
    'vl_perdas', 'Perdas',
    'vl_lucro', 'Lucro líquido');

  COR_CARD = $00F7F0EA;
  COR_BARRA = $00C87834;

procedure TFrmResumo.FormCreate(Sender: TObject);
begin
  FFaturamento := CriarCard(0, 0, 'Faturamento');
  FCPV := CriarCard(1, 0, 'Custo dos vendidos (CPV)');
  FLucroBruto := CriarCard(2, 0, 'Lucro bruto');
  FDespesas := CriarCard(3, 0, 'Despesas extras');
  FPerdas := CriarCard(4, 0, 'Perdas (custo)');
  FLucroLiquido := CriarCard(0, 1, 'Lucro líquido');
  FMargem := CriarCard(1, 1, 'Margem líquida');
  FQtdVendida := CriarCard(2, 1, 'Tortinhas vendidas');
  FQtdPerdida := CriarCard(3, 1, 'Tortinhas perdidas');
  FPrecoMedio := CriarCard(4, 1, 'Preço médio por tortinha');
  FVendidoFiado := CriarCard(0, 2, 'Vendido fiado');
  FRecebido := CriarCard(1, 2, 'Fiado recebido');
  FAReceber := CriarCard(2, 2, 'A receber (fiado, hoje)');

  FQrySabores := DMConexao.NovaQuery(Self, SQL_RESUMO_POR_SABOR);
  FDSSabores := TDataSource.Create(Self);
  FDSSabores.DataSet := FQrySabores;
  grdSabores.DataSource := FDSSabores;

  FQryMeses := DMConexao.NovaQuery(Self, SQL_RESUMO_POR_MES);
  FDSMeses := TDataSource.Create(Self);
  FDSMeses.DataSet := FQryMeses;
  grdMeses.DataSource := FDSMeses;

  btnMesAtualClick(nil);
end;

function TFrmResumo.CriarCard(ACol, ALinha: Integer; const ATitulo: string): TLabel;
var
  P: TPanel;
  L: TLabel;
begin
  P := TPanel.Create(Self);
  P.Parent := pnlKpis;
  P.SetBounds(16 + ACol * 190, 8 + ALinha * 66, 180, 58);
  P.BevelOuter := bvNone;
  P.ParentBackground := False;
  P.Color := COR_CARD;

  L := TLabel.Create(Self);
  L.Parent := P;
  L.SetBounds(10, 6, 165, 17);
  L.Caption := ATitulo;
  L.Font.Color := clGrayText;

  Result := TLabel.Create(Self);
  Result.Parent := P;
  Result.SetBounds(10, 24, 165, 28);
  Result.Font.Size := 14;
  Result.Font.Style := [fsBold];
  Result.Caption := '-';
end;

procedure TFrmResumo.Atualizar;
var
  R: TResumo;
  Ini, Fim: string;
begin
  R := CalcularResumo(dtpIni.Date, dtpFim.Date);
  FFaturamento.Caption := FmtMoeda(R.Faturamento);
  FCPV.Caption := FmtMoeda(R.CPV);
  FLucroBruto.Caption := FmtMoeda(R.LucroBruto);
  FDespesas.Caption := FmtMoeda(R.Despesas);
  FPerdas.Caption := FmtMoeda(R.Perdas);
  if R.Perdas > 0 then
    FPerdas.Font.Color := clRed
  else
    FPerdas.Font.Color := clWindowText;
  FLucroLiquido.Caption := FmtMoeda(R.LucroLiquido);
  if R.LucroLiquido < 0 then
    FLucroLiquido.Font.Color := clRed
  else
    FLucroLiquido.Font.Color := clGreen;
  FMargem.Caption := FmtPercentual(R.MargemLiquida);
  FQtdVendida.Caption := FmtQtd(R.QtdVendida) + Format('  (%d vendas)', [R.NumVendas]);
  FQtdPerdida.Caption := FmtQtd(R.QtdPerdida);
  if R.QtdVendida + R.QtdPerdida > 0 then
    FQtdPerdida.Caption := FQtdPerdida.Caption + Format('  (%s)',
      [FmtPercentual(100 * R.QtdPerdida / (R.QtdVendida + R.QtdPerdida))]);
  FPrecoMedio.Caption := FmtMoeda(R.PrecoMedio);
  FVendidoFiado.Caption := FmtMoeda(R.VendidoFiado);
  FRecebido.Caption := FmtMoeda(R.Recebido);
  FAReceber.Caption := FmtMoeda(R.AReceber);
  if R.AReceber > 0.005 then
    FAReceber.Font.Color := $000080FF // laranja
  else
    FAReceber.Font.Color := clWindowText;

  Ini := DataSQL(dtpIni.Date);
  Fim := DataSQL(dtpFim.Date);

  FQrySabores.ParamByName('ini').AsString := Ini;
  FQrySabores.ParamByName('fim').AsString := Fim;
  FQrySabores.ParamByName('ini2').AsString := Ini;
  FQrySabores.ParamByName('fim2').AsString := Fim;
  Reabrir(FQrySabores, ROT_SABORES);

  FQryMeses.ParamByName('ini').AsString := Ini;
  FQryMeses.ParamByName('fim').AsString := Fim;
  FQryMeses.ParamByName('ini2').AsString := Ini;
  FQryMeses.ParamByName('fim2').AsString := Fim;
  FQryMeses.ParamByName('ini3').AsString := Ini;
  FQryMeses.ParamByName('fim3').AsString := Fim;
  Reabrir(FQryMeses, ROT_MESES);

  CarregarGrafico;
end;

procedure TFrmResumo.CarregarGrafico;
var
  N: Integer;
begin
  SetLength(FNomes, 0);
  SetLength(FValores, 0);
  FQrySabores.DisableControls;
  try
    FQrySabores.First;
    while not FQrySabores.Eof do
    begin
      N := Length(FNomes);
      SetLength(FNomes, N + 1);
      SetLength(FValores, N + 1);
      FNomes[N] := FQrySabores.FieldByName('sabor').AsString;
      FValores[N] := NumCampo(FQrySabores.Fields[4]); // faturamento
      FQrySabores.Next;
    end;
    FQrySabores.First;
  finally
    FQrySabores.EnableControls;
  end;
  pbGrafico.Invalidate;
end;

procedure TFrmResumo.pbGraficoPaint(Sender: TObject);
const
  MARGEM = 12;
  LARG_NOME = 130;
  LARG_VALOR = 100;
var
  C: TCanvas;
  I, Y, AlturaBarra, LargMax, LargBarra: Integer;
  Maior: Double;
begin
  C := pbGrafico.Canvas;
  C.Brush.Color := clWindow;
  C.FillRect(pbGrafico.ClientRect);
  C.Font.Assign(Font);

  C.Font.Style := [fsBold];
  C.TextOut(MARGEM, 4, 'Faturamento por sabor');
  C.Font.Style := [];

  if Length(FValores) = 0 then
  begin
    C.Font.Color := clGrayText;
    C.TextOut(MARGEM, 32, 'Sem vendas no período.');
    Exit;
  end;

  Maior := MaxValue(FValores);
  if Maior <= 0 then
    Maior := 1;
  AlturaBarra := Min(28, (pbGrafico.Height - 40) div Length(FValores) - 6);
  if AlturaBarra < 8 then
    AlturaBarra := 8;
  LargMax := pbGrafico.Width - LARG_NOME - LARG_VALOR - MARGEM * 2;

  for I := 0 to High(FValores) do
  begin
    Y := 32 + I * (AlturaBarra + 6);
    C.Brush.Style := bsClear;
    C.Font.Color := clWindowText;
    C.TextOut(MARGEM, Y + (AlturaBarra - C.TextHeight('A')) div 2, FNomes[I]);

    LargBarra := Round(LargMax * FValores[I] / Maior);
    C.Brush.Style := bsSolid;
    C.Brush.Color := COR_BARRA;
    C.FillRect(Rect(MARGEM + LARG_NOME, Y, MARGEM + LARG_NOME + Max(LargBarra, 2),
      Y + AlturaBarra));

    C.Brush.Style := bsClear;
    C.TextOut(MARGEM + LARG_NOME + Max(LargBarra, 2) + 6,
      Y + (AlturaBarra - C.TextHeight('A')) div 2, FmtMoeda(FValores[I]));
  end;
end;

procedure TFrmResumo.btnAtualizarClick(Sender: TObject);
begin
  Atualizar;
end;

procedure TFrmResumo.btnMesAtualClick(Sender: TObject);
begin
  dtpIni.Date := StartOfTheMonth(Date);
  dtpFim.Date := EndOfTheMonth(Date);
  Atualizar;
end;

procedure TFrmResumo.btnMesAnteriorClick(Sender: TObject);
var
  D: TDateTime;
begin
  D := IncMonth(StartOfTheMonth(Date), -1);
  dtpIni.Date := D;
  dtpFim.Date := EndOfTheMonth(D);
  Atualizar;
end;

procedure TFrmResumo.btnAnoClick(Sender: TObject);
begin
  dtpIni.Date := StartOfTheYear(Date);
  dtpFim.Date := EndOfTheYear(Date);
  Atualizar;
end;

end.
