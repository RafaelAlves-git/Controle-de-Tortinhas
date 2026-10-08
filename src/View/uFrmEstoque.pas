unit uFrmEstoque;

{ Estoque de ingredientes (entradas, saídas, ajustes, saldo e valor) e
  tortinhas prontas por sabor (produzidas - vendidas - perdidas). }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client;

type
  TFrmEstoque = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlBotoes: TPanel;
    btnAjustar: TButton;
    btnAtualizar: TButton;
    lblValorTotal: TLabel;
    grdIngredientes: TDBGrid;
    pnlTortinhas: TPanel;
    pnlTortinhasTitulo: TPanel;
    lblTortinhas: TLabel;
    grdTortinhas: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnAjustarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
  private
    FQryIng: TFDQuery;
    FDSIng: TDataSource;
    FQryTort: TFDQuery;
    FDSTort: TDataSource;
    procedure Atualizar;
  end;

implementation

{$R *.dfm}

uses
  uDMConexao, uUtils, uUIHelpers, uEstoqueService;

const
  SQL_INGREDIENTES =
    'SELECT ingrediente_id AS id, nome, unidade, ' +
    '  entradas AS "qt_entradas::FLOAT", saidas AS "qt_saidas::FLOAT", ' +
    '  ajustes AS "qt_ajustes::FLOAT", saldo AS "qt_saldo::FLOAT", ' +
    '  custo_unit AS "vu_custo::FLOAT", ' +
    '  saldo * custo_unit AS "vl_estoque::FLOAT" ' +
    'FROM vw_estoque_ingrediente ' +
    'ORDER BY nome';

  ROT_INGREDIENTES: array[0..15] of string = (
    'nome', 'Ingrediente',
    'unidade', 'Unid.',
    'qt_entradas', 'Entradas',
    'qt_saidas', 'Saídas',
    'qt_ajustes', 'Ajustes',
    'qt_saldo', 'Estoque atual',
    'vu_custo', 'Custo por unidade',
    'vl_estoque', 'Valor em estoque');

  SQL_TORTINHAS =
    'SELECT sabor_id AS id, nome, ' +
    '  produzidas AS "qt_produzidas::FLOAT", vendidas AS "qt_vendidas::FLOAT", ' +
    '  perdidas AS "qt_perdidas::FLOAT", ' +
    '  disponiveis AS "qt_disponiveis::FLOAT" ' +
    'FROM vw_estoque_tortinha ' +
    'ORDER BY nome';

  ROT_TORTINHAS: array[0..9] of string = (
    'nome', 'Sabor',
    'qt_produzidas', 'Produzidas',
    'qt_vendidas', 'Vendidas',
    'qt_perdidas', 'Perdidas',
    'qt_disponiveis', 'Disponíveis');

procedure TFrmEstoque.FormCreate(Sender: TObject);
begin
  FQryIng := DMConexao.NovaQuery(Self, SQL_INGREDIENTES);
  FDSIng := TDataSource.Create(Self);
  FDSIng.DataSet := FQryIng;
  grdIngredientes.DataSource := FDSIng;

  FQryTort := DMConexao.NovaQuery(Self, SQL_TORTINHAS);
  FDSTort := TDataSource.Create(Self);
  FDSTort.DataSet := FQryTort;
  grdTortinhas.DataSource := FDSTort;

  Atualizar;
end;

procedure TFrmEstoque.Atualizar;
var
  Total: Double;
begin
  Reabrir(FQryIng, ROT_INGREDIENTES, IdAtual(FQryIng));
  Reabrir(FQryTort, ROT_TORTINHAS);
  Total := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(saldo * custo_unit), 0.0) AS "total::FLOAT" ' +
    'FROM vw_estoque_ingrediente WHERE saldo > 0'));
  lblValorTotal.Caption := 'Valor total em estoque: ' + FmtMoeda(Total);
end;

procedure TFrmEstoque.btnAjustarClick(Sender: TObject);
var
  Id: Integer;
  Texto: string;
  Contado: Double;
begin
  Id := IdAtual(FQryIng);
  if Id = 0 then
    Exit;
  Texto := FormatFloat('0.###', NumCampo(FQryIng.Fields[6]));
  if not InputQuery('Ajuste de estoque',
    Format('Quantidade contada de %s (%s):',
      [FQryIng.FieldByName('nome').AsString, FQryIng.FieldByName('unidade').AsString]),
    Texto) then
    Exit;
  if not TextoParaNumero(Texto, Contado) then
    raise EValidacao.Create('Quantidade inválida.');
  AjustarEstoque(Id, Contado, Date);
  Atualizar;
end;

procedure TFrmEstoque.btnAtualizarClick(Sender: TObject);
begin
  Atualizar;
end;

end.
