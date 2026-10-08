unit uFrmDespesas;

{ Despesas extras (gás, energia, transporte, divulgação...). }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client;

type
  TFrmDespesas = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlEdicao: TPanel;
    lblModo: TLabel;
    lblData: TLabel;
    dtpData: TDateTimePicker;
    lblDescricao: TLabel;
    edDescricao: TEdit;
    lblCategoria: TLabel;
    cbCategoria: TComboBox;
    lblValor: TLabel;
    edValor: TEdit;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    pnlFiltro: TPanel;
    lblDe: TLabel;
    dtpIni: TDateTimePicker;
    lblAte: TLabel;
    dtpFim: TDateTimePicker;
    btnFiltrar: TButton;
    lblTotal: TLabel;
    grdLista: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure grdListaCellClick(Column: TColumn);
  private
    FQry: TFDQuery;
    FDS: TDataSource;
    FId: Integer;
    procedure DSDataChange(Sender: TObject; Field: TField);
    procedure CarregarAtual;
    procedure CarregarCategorias;
    procedure Filtrar(AIdAtual: Integer = 0);
    procedure Limpar;
  end;

implementation

{$R *.dfm}

uses
  System.DateUtils, uDMConexao, uUtils, uUIHelpers, uCadastroService;

const
  SQL_LISTA =
    'SELECT id, data, descricao, categoria, valor AS vl_valor ' +
    'FROM despesa ' +
    'WHERE data BETWEEN :ini AND :fim ' +
    'ORDER BY data DESC, id DESC';

  ROTULOS: array[0..7] of string = (
    'data', 'Data',
    'descricao', 'Descrição',
    'categoria', 'Categoria',
    'vl_valor', 'Valor');

  CATEGORIAS_PADRAO: array[0..6] of string = (
    'Gás', 'Energia', 'Transporte', 'Divulgação', 'Embalagens', 'Taxas', 'Outros');

procedure TFrmDespesas.FormCreate(Sender: TObject);
begin
  dtpIni.Date := StartOfTheMonth(Date);
  dtpFim.Date := EndOfTheMonth(Date);
  CarregarCategorias;

  FQry := DMConexao.NovaQuery(Self, SQL_LISTA);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQry;
  FDS.OnDataChange := DSDataChange;
  grdLista.DataSource := FDS;
  Filtrar;
  Limpar;
end;

procedure TFrmDespesas.CarregarCategorias;
var
  Q: TFDQuery;
  C: string;
begin
  cbCategoria.Items.Clear;
  for C in CATEGORIAS_PADRAO do
    cbCategoria.Items.Add(C);
  Q := DMConexao.NovaQuery(nil,
    'SELECT DISTINCT categoria FROM despesa WHERE categoria <> '''' ORDER BY categoria');
  try
    Q.Open;
    while not Q.Eof do
    begin
      if cbCategoria.Items.IndexOf(Q.Fields[0].AsString) < 0 then
        cbCategoria.Items.Add(Q.Fields[0].AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TFrmDespesas.DSDataChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
    CarregarAtual;
end;

procedure TFrmDespesas.grdListaCellClick(Column: TColumn);
begin
  CarregarAtual;
end;

procedure TFrmDespesas.CarregarAtual;
begin
  if FQry.IsEmpty then
    Exit;
  FId := FQry.FieldByName('id').AsInteger;
  dtpData.Date := FQry.FieldByName('data').AsDateTime;
  edDescricao.Text := FQry.FieldByName('descricao').AsString;
  cbCategoria.Text := FQry.FieldByName('categoria').AsString;
  edValor.Text := FormatFloat('0.00', NumCampo(FQry.FieldByName('vl_valor')));
  lblModo.Caption := 'Editando despesa';
end;

procedure TFrmDespesas.Filtrar(AIdAtual: Integer);
var
  Total: Double;
begin
  FQry.ParamByName('ini').AsString := DataSQL(dtpIni.Date);
  FQry.ParamByName('fim').AsString := DataSQL(dtpFim.Date);
  Reabrir(FQry, ROTULOS, AIdAtual);
  Total := NumVar(Conn.ExecSQLScalar(
    'SELECT COALESCE(SUM(valor), 0.0) AS "total::FLOAT" FROM despesa ' +
    'WHERE data BETWEEN :ini AND :fim',
    [DataSQL(dtpIni.Date), DataSQL(dtpFim.Date)]));
  lblTotal.Caption := 'Total no período: ' + FmtMoeda(Total);
end;

procedure TFrmDespesas.Limpar;
begin
  FId := 0;
  dtpData.Date := Date;
  edDescricao.Clear;
  cbCategoria.Text := '';
  edValor.Clear;
  lblModo.Caption := 'Nova despesa';
end;

procedure TFrmDespesas.btnNovoClick(Sender: TObject);
begin
  Limpar;
  edDescricao.SetFocus;
end;

procedure TFrmDespesas.btnSalvarClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := FId;
  SalvarDespesa(Id, dtpData.Date, edDescricao.Text, cbCategoria.Text,
    LerNumero(edValor, 'Valor'));
  CarregarCategorias;
  Filtrar(Id);
  Limpar;
end;

procedure TFrmDespesas.btnExcluirClick(Sender: TObject);
begin
  if FId = 0 then
    Exit;
  if not Confirmar('Excluir a despesa "' + edDescricao.Text + '"?') then
    Exit;
  ExcluirDespesa(FId);
  Filtrar;
  Limpar;
end;

procedure TFrmDespesas.btnFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

end.
