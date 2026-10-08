unit uFrmIngredientes;

{ Cadastro de ingredientes: nome, unidade, tamanho e preço da embalagem.
  O custo por unidade (g, ml, un) é calculado: preço / qtd. na embalagem. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client;

type
  TFrmIngredientes = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlEdicao: TPanel;
    lblModo: TLabel;
    lblNome: TLabel;
    edNome: TEdit;
    lblUnidade: TLabel;
    cbUnidade: TComboBox;
    lblQtdEmbalagem: TLabel;
    edQtdEmbalagem: TEdit;
    lblPreco: TLabel;
    edPreco: TEdit;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    grdLista: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure grdListaCellClick(Column: TColumn);
  private
    FQry: TFDQuery;
    FDS: TDataSource;
    FId: Integer;
    procedure DSDataChange(Sender: TObject; Field: TField);
    procedure CarregarEdicao;
    procedure Limpar;
  end;

implementation

{$R *.dfm}

uses
  uDMConexao, uUtils, uUIHelpers, uCadastroService;

const
  SQL_LISTA =
    'SELECT i.id, i.nome, i.unidade, i.qtd_embalagem AS qt_embalagem, ' +
    '  i.preco_embalagem AS vl_embalagem, ' +
    '  e.custo_unit AS "vu_custo_unit::FLOAT", ' +
    '  e.saldo AS "qt_estoque::FLOAT" ' +
    'FROM ingrediente i ' +
    'JOIN vw_estoque_ingrediente e ON e.ingrediente_id = i.id ' +
    'ORDER BY i.nome';

  ROTULOS: array[0..11] of string = (
    'nome', 'Ingrediente',
    'unidade', 'Unid.',
    'qt_embalagem', 'Qtd. na embalagem',
    'vl_embalagem', 'Preço da embalagem',
    'vu_custo_unit', 'Custo por unidade',
    'qt_estoque', 'Estoque atual');

procedure TFrmIngredientes.FormCreate(Sender: TObject);
begin
  FQry := DMConexao.NovaQuery(Self, SQL_LISTA);
  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQry;
  FDS.OnDataChange := DSDataChange;
  grdLista.DataSource := FDS;
  Reabrir(FQry, ROTULOS);
  if FQry.IsEmpty then
    Limpar;
end;

procedure TFrmIngredientes.DSDataChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
    CarregarEdicao;
end;

procedure TFrmIngredientes.grdListaCellClick(Column: TColumn);
begin
  CarregarEdicao;
end;

procedure TFrmIngredientes.CarregarEdicao;
begin
  if FQry.IsEmpty then
  begin
    Limpar;
    Exit;
  end;
  FId := FQry.FieldByName('id').AsInteger;
  edNome.Text := FQry.FieldByName('nome').AsString;
  cbUnidade.Text := FQry.FieldByName('unidade').AsString;
  edQtdEmbalagem.Text := FormatFloat('0.###', NumCampo(FQry.FieldByName('qt_embalagem')));
  edPreco.Text := FormatFloat('0.00', NumCampo(FQry.FieldByName('vl_embalagem')));
  lblModo.Caption := 'Editando: ' + edNome.Text;
end;

procedure TFrmIngredientes.Limpar;
begin
  FId := 0;
  edNome.Clear;
  cbUnidade.Text := 'g';
  edQtdEmbalagem.Clear;
  edPreco.Clear;
  lblModo.Caption := 'Novo ingrediente';
end;

procedure TFrmIngredientes.btnNovoClick(Sender: TObject);
begin
  Limpar;
  edNome.SetFocus;
end;

procedure TFrmIngredientes.btnSalvarClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := FId;
  SalvarIngrediente(Id, edNome.Text, cbUnidade.Text,
    LerNumero(edQtdEmbalagem, 'Qtd. na embalagem'),
    LerNumero(edPreco, 'Preço da embalagem'));
  Reabrir(FQry, ROTULOS, Id);
end;

procedure TFrmIngredientes.btnExcluirClick(Sender: TObject);
begin
  if FId = 0 then
    Exit;
  if not Confirmar('Excluir o ingrediente "' + edNome.Text + '"?') then
    Exit;
  ExcluirIngrediente(FId);
  Reabrir(FQry, ROTULOS);
end;

end.
