unit uFrmProducao;

{ Produção: registra quantas receitas (fornadas) de cada sabor foram feitas
  e baixa do estoque os ingredientes conforme a receita. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client;

type
  TFrmProducao = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlEdicao: TPanel;
    lblData: TLabel;
    dtpData: TDateTimePicker;
    lblSabor: TLabel;
    cbSabor: TComboBox;
    lblReceitas: TLabel;
    edReceitas: TEdit;
    lblInfo: TLabel;
    btnLancar: TButton;
    pnlFiltro: TPanel;
    lblDe: TLabel;
    dtpIni: TDateTimePicker;
    lblAte: TLabel;
    dtpFim: TDateTimePicker;
    btnFiltrar: TButton;
    btnExcluir: TButton;
    lblTotal: TLabel;
    grdLista: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnLancarClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure CamposChange(Sender: TObject);
  private
    FQry: TFDQuery;
    FDS: TDataSource;
    procedure Filtrar;
  end;

implementation

{$R *.dfm}

uses
  System.DateUtils, uDMConexao, uUtils, uUIHelpers, uEstoqueService, uCustoService;

const
  SQL_LISTA =
    'SELECT p.id, p.data, s.nome AS sabor, p.qtd_receitas AS qt_receitas, ' +
    '  p.qtd_tortinhas AS qt_tortinhas ' +
    'FROM producao p ' +
    'JOIN sabor s ON s.id = p.sabor_id ' +
    'WHERE p.data BETWEEN :ini AND :fim ' +
    'ORDER BY p.data DESC, p.id DESC';

  ROTULOS: array[0..7] of string = (
    'data', 'Data',
    'sabor', 'Sabor',
    'qt_receitas', 'Receitas',
    'qt_tortinhas', 'Tortinhas');

procedure TFrmProducao.FormCreate(Sender: TObject);
begin
  dtpData.Date := Date;
  dtpIni.Date := StartOfTheMonth(Date);
  dtpFim.Date := EndOfTheMonth(Date);
  edReceitas.Text := '1';
  CarregarCombo(cbSabor, 'SELECT id, nome FROM sabor ORDER BY nome');

  FQry := DMConexao.NovaQuery(Self, SQL_LISTA);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQry;
  grdLista.DataSource := FDS;
  Filtrar;
  CamposChange(nil);
end;

procedure TFrmProducao.CamposChange(Sender: TObject);
var
  Id: Integer;
  Receitas: Double;
begin
  Id := IdDoCombo(cbSabor);
  if Id = 0 then
  begin
    lblInfo.Caption := 'Selecione o sabor.';
    Exit;
  end;
  if not TextoParaNumero(edReceitas.Text, Receitas) then
    Receitas := 0;
  lblInfo.Caption := Format('Rende %d tortinhas  |  custo estimado de %s',
    [Round(Receitas * RendimentoSabor(Id)),
     FmtMoeda(Receitas * RendimentoSabor(Id) * CustoPorTortinha(Id))]);
end;

procedure TFrmProducao.Filtrar;
var
  Total: Double;
begin
  FQry.ParamByName('ini').AsString := DataSQL(dtpIni.Date);
  FQry.ParamByName('fim').AsString := DataSQL(dtpFim.Date);
  Reabrir(FQry, ROTULOS);
  Total := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(qtd_tortinhas), 0) AS "total::FLOAT" FROM producao ' +
    'WHERE data BETWEEN :ini AND :fim',
    [DataSQL(dtpIni.Date), DataSQL(dtpFim.Date)]));
  lblTotal.Caption := 'Tortinhas produzidas no período: ' + FmtQtd(Total);
end;

procedure TFrmProducao.btnLancarClick(Sender: TObject);
var
  SaborId: Integer;
  Receitas: Double;
  Faltas: TStringList;
begin
  SaborId := IdDoCombo(cbSabor);
  Receitas := LerNumero(edReceitas, 'Receitas');

  Faltas := FaltasParaProducao(SaborId, Receitas);
  try
    if (Faltas.Count > 0) and not Confirmar(
      'O estoque não tem o suficiente de:' + sLineBreak + sLineBreak +
      Faltas.Text + sLineBreak +
      'Registrar a produção mesmo assim? (o estoque ficará negativo)') then
      Exit;
  finally
    Faltas.Free;
  end;

  RegistrarProducao(dtpData.Date, SaborId, Receitas);
  edReceitas.Text := '1';
  Filtrar;
end;

procedure TFrmProducao.btnFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmProducao.btnExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := IdAtual(FQry);
  if Id = 0 then
    Exit;
  if not Confirmar('Excluir esta produção? Os ingredientes voltam para o estoque.') then
    Exit;
  ExcluirProducao(Id);
  Filtrar;
end;

end.
