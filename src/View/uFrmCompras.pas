unit uFrmCompras;

{ Compras de ingredientes: dão entrada no estoque e (opcionalmente)
  atualizam o preço da embalagem no cadastro. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client;

type
  TFrmCompras = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlEdicao: TPanel;
    lblData: TLabel;
    dtpData: TDateTimePicker;
    lblIngrediente: TLabel;
    cbIngrediente: TComboBox;
    lblEmbalagens: TLabel;
    edEmbalagens: TEdit;
    lblValor: TLabel;
    edValor: TEdit;
    chkAtualizarPreco: TCheckBox;
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
  System.DateUtils, uDMConexao, uUtils, uUIHelpers, uEstoqueService;

const
  SQL_LISTA =
    'SELECT c.id, c.data, i.nome AS ingrediente, ' +
    '  c.qtd_embalagens AS qt_embalagens, c.quantidade AS qt_quantidade, i.unidade, ' +
    '  c.valor_total AS vl_total ' +
    'FROM compra c ' +
    'JOIN ingrediente i ON i.id = c.ingrediente_id ' +
    'WHERE c.data BETWEEN :ini AND :fim ' +
    'ORDER BY c.data DESC, c.id DESC';

  ROTULOS: array[0..11] of string = (
    'data', 'Data',
    'ingrediente', 'Ingrediente',
    'qt_embalagens', 'Embalagens',
    'qt_quantidade', 'Quantidade',
    'unidade', 'Unid.',
    'vl_total', 'Valor pago');

procedure TFrmCompras.FormCreate(Sender: TObject);
begin
  dtpData.Date := Date;
  dtpIni.Date := StartOfTheMonth(Date);
  dtpFim.Date := EndOfTheMonth(Date);
  edEmbalagens.Text := '1';
  CarregarCombo(cbIngrediente, 'SELECT id, nome FROM ingrediente ORDER BY nome');

  FQry := DMConexao.NovaQuery(Self, SQL_LISTA);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQry;
  grdLista.DataSource := FDS;
  Filtrar;
  CamposChange(nil);
end;

procedure TFrmCompras.CamposChange(Sender: TObject);
var
  Id: Integer;
  Embalagens, QtdEmbalagem: Double;
  Unidade: string;
begin
  Id := IdDoCombo(cbIngrediente);
  if Id = 0 then
  begin
    lblInfo.Caption := 'Selecione o ingrediente.';
    Exit;
  end;
  QtdEmbalagem := NumVar(Conn.ExecSQLScalar(
    'SELECT qtd_embalagem FROM ingrediente WHERE id = :id', [Id]));
  Unidade := Conn.ExecSQLScalar('SELECT unidade FROM ingrediente WHERE id = :id', [Id]);
  if not TextoParaNumero(edEmbalagens.Text, Embalagens) then
    Embalagens := 0;
  lblInfo.Caption := Format('Embalagem de %s %s  ->  entrada de %s %s no estoque',
    [FmtQtd(QtdEmbalagem), Unidade, FmtQtd(Embalagens * QtdEmbalagem), Unidade]);
end;

procedure TFrmCompras.Filtrar;
var
  Total: Double;
begin
  FQry.ParamByName('ini').AsString := DataSQL(dtpIni.Date);
  FQry.ParamByName('fim').AsString := DataSQL(dtpFim.Date);
  Reabrir(FQry, ROTULOS);
  Total := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(valor_total), 0.0) AS "total::FLOAT" FROM compra ' +
    'WHERE data BETWEEN :ini AND :fim',
    [DataSQL(dtpIni.Date), DataSQL(dtpFim.Date)]));
  lblTotal.Caption := 'Total comprado no período: ' + FmtMoeda(Total);
end;

procedure TFrmCompras.btnLancarClick(Sender: TObject);
begin
  RegistrarCompra(dtpData.Date, IdDoCombo(cbIngrediente),
    LerNumero(edEmbalagens, 'Embalagens'), LerNumero(edValor, 'Valor pago'),
    chkAtualizarPreco.Checked);
  edEmbalagens.Text := '1';
  edValor.Clear;
  Filtrar;
end;

procedure TFrmCompras.btnFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmCompras.btnExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := IdAtual(FQry);
  if Id = 0 then
    Exit;
  if not Confirmar('Excluir esta compra? A entrada no estoque também será removida.') then
    Exit;
  ExcluirCompra(Id);
  Filtrar;
end;

end.
