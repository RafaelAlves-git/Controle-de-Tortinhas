unit uFrmPerdas;

{ Perdas: tortinhas prontas que estragaram, venceram ou foram descartadas.
  Elas saem do estoque de tortinhas prontas e o custo delas entra no resumo
  como perda, reduzindo o lucro líquido do período. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client;

type
  TFrmPerdas = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlEdicao: TPanel;
    lblData: TLabel;
    dtpData: TDateTimePicker;
    lblSabor: TLabel;
    cbSabor: TComboBox;
    lblQtd: TLabel;
    edQtd: TEdit;
    lblMotivo: TLabel;
    cbMotivo: TComboBox;
    btnLancar: TButton;
    lblInfo: TLabel;
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
  System.DateUtils, uDMConexao, uUtils, uUIHelpers, uEstoqueService,
  uCustoService, uResumoService;

const
  SQL_LISTA =
    'SELECT pe.id, pe.data, s.nome AS sabor, pe.qtd AS qt_qtd, pe.motivo, ' +
    '  pe.custo_unit AS vl_custo_unit, ' +
    '  1.0 * pe.qtd * pe.custo_unit AS "vl_total::FLOAT" ' +
    'FROM perda pe ' +
    'JOIN sabor s ON s.id = pe.sabor_id ' +
    'WHERE pe.data BETWEEN :ini AND :fim ' +
    'ORDER BY pe.data DESC, pe.id DESC';

  ROTULOS: array[0..11] of string = (
    'data', 'Data',
    'sabor', 'Sabor',
    'qt_qtd', 'Tortinhas',
    'motivo', 'Motivo',
    'vl_custo_unit', 'Custo unit.',
    'vl_total', 'Custo total');

procedure TFrmPerdas.FormCreate(Sender: TObject);
begin
  dtpData.Date := Date;
  dtpIni.Date := StartOfTheMonth(Date);
  dtpFim.Date := EndOfTheMonth(Date);
  edQtd.Text := '1';
  cbMotivo.ItemIndex := 0;
  CarregarCombo(cbSabor, 'SELECT id, nome FROM sabor ORDER BY nome');

  FQry := DMConexao.NovaQuery(Self, SQL_LISTA);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQry;
  grdLista.DataSource := FDS;
  Filtrar;
  CamposChange(nil);
end;

procedure TFrmPerdas.CamposChange(Sender: TObject);
var
  Id: Integer;
  Qtd: Double;
begin
  Id := IdDoCombo(cbSabor);
  if Id = 0 then
  begin
    lblInfo.Caption := 'Selecione o sabor.';
    Exit;
  end;
  if not TextoParaNumero(edQtd.Text, Qtd) then
    Qtd := 0;
  lblInfo.Caption := Format('Tortinhas prontas deste sabor: %d  |  custo desta perda: %s',
    [TortinhasDisponiveis(Id), FmtMoeda(Qtd * CustoPorTortinha(Id))]);
end;

procedure TFrmPerdas.Filtrar;
var
  R: TResumo;
begin
  FQry.ParamByName('ini').AsString := DataSQL(dtpIni.Date);
  FQry.ParamByName('fim').AsString := DataSQL(dtpFim.Date);
  Reabrir(FQry, ROTULOS);

  R := CalcularResumo(dtpIni.Date, dtpFim.Date);
  lblTotal.Caption := Format('Perdidas no período: %s tortinhas  |  custo: %s',
    [FmtQtd(R.QtdPerdida), FmtMoeda(R.Perdas)]);
end;

procedure TFrmPerdas.btnLancarClick(Sender: TObject);
var
  SaborId, Qtd, Disponiveis: Integer;
begin
  SaborId := IdDoCombo(cbSabor);
  if SaborId = 0 then
    raise EValidacao.Create('Selecione o sabor.');
  Qtd := LerInteiro(edQtd, 'Quantidade');

  Disponiveis := TortinhasDisponiveis(SaborId);
  if (Qtd > Disponiveis) and not Confirmar(Format(
    'Pelo sistema há apenas %d tortinha(s) pronta(s) de %s.' + sLineBreak +
    'Registrar a perda de %d mesmo assim?', [Disponiveis, cbSabor.Text, Qtd])) then
    Exit;

  RegistrarPerda(dtpData.Date, SaborId, Qtd, cbMotivo.Text);
  edQtd.Text := '1';
  Filtrar;
  CamposChange(nil);
end;

procedure TFrmPerdas.btnFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmPerdas.btnExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := IdAtual(FQry);
  if Id = 0 then
    Exit;
  if not Confirmar('Excluir este registro de perda? As tortinhas voltam para o estoque.') then
    Exit;
  ExcluirPerda(Id);
  Filtrar;
  CamposChange(nil);
end;

end.
