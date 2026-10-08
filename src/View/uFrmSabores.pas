unit uFrmSabores;

{ Sabores e suas receitas (ficha técnica).
  Em cima: sabores com preço, rendimento, custo por tortinha, lucro e margem.
  Embaixo: ingredientes da receita do sabor selecionado. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client;

type
  TFrmSabores = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlSabores: TPanel;
    grdSabores: TDBGrid;
    pnlEdSabor: TPanel;
    lblModo: TLabel;
    lblNome: TLabel;
    edNome: TEdit;
    lblPreco: TLabel;
    edPreco: TEdit;
    lblRendimento: TLabel;
    edRendimento: TEdit;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    pnlReceitaTopo: TPanel;
    lblReceita: TLabel;
    lblCustoTortinha: TLabel;
    pnlEdReceita: TPanel;
    lblIngrediente: TLabel;
    cbIngrediente: TComboBox;
    lblQtdReceita: TLabel;
    edQtdReceita: TEdit;
    lblUnidade: TLabel;
    btnAdicionarItem: TButton;
    btnRemoverItem: TButton;
    grdReceita: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
    procedure cbIngredienteChange(Sender: TObject);
    procedure grdSaboresCellClick(Column: TColumn);
    procedure grdReceitaCellClick(Column: TColumn);
  private
    FQrySabores: TFDQuery;
    FDSSabores: TDataSource;
    FQryReceita: TFDQuery;
    FDSReceita: TDataSource;
    FId: Integer;
    procedure DSSaboresDataChange(Sender: TObject; Field: TField);
    procedure DSReceitaDataChange(Sender: TObject; Field: TField);
    procedure CarregarEdicao;
    procedure CarregarItemReceita;
    procedure CarregarReceita;
    procedure AtualizarTudo;
    procedure Limpar;
  end;

implementation

{$R *.dfm}

uses
  System.Variants, uDMConexao, uUtils, uUIHelpers, uCadastroService, uCustoService;

const
  SQL_SABORES =
    'SELECT c.sabor_id AS id, c.nome, c.preco_venda AS vl_preco, ' +
    '  c.rendimento AS nr_rendimento, ' +
    '  c.custo_unit AS "vl_custo::FLOAT", ' +
    '  c.preco_venda - c.custo_unit AS "vl_lucro::FLOAT", ' +
    '  CASE WHEN c.preco_venda > 0 ' +
    '       THEN 100.0 * (c.preco_venda - c.custo_unit) / c.preco_venda ' +
    '       ELSE 0.0 END AS "pc_margem::FLOAT" ' +
    'FROM vw_custo_sabor c ' +
    'ORDER BY c.nome';

  ROT_SABORES: array[0..11] of string = (
    'nome', 'Sabor',
    'vl_preco', 'Preço venda',
    'nr_rendimento', 'Rendimento',
    'vl_custo', 'Custo/tortinha',
    'vl_lucro', 'Lucro/tortinha',
    'pc_margem', 'Margem');

  SQL_RECEITA =
    'SELECT ri.id, ri.ingrediente_id, i.nome AS ingrediente, i.unidade, ' +
    '  ri.qtd_por_receita AS qt_receita, ' +
    '  1.0 * ri.qtd_por_receita / s.rendimento AS "qt_por_tortinha::FLOAT", ' +
    '  1.0 * ri.qtd_por_receita * i.preco_embalagem / i.qtd_embalagem ' +
    '    AS "vl_custo_receita::FLOAT", ' +
    '  1.0 * ri.qtd_por_receita * i.preco_embalagem / i.qtd_embalagem / s.rendimento ' +
    '    AS "vu_custo_tortinha::FLOAT" ' +
    'FROM receita_item ri ' +
    'JOIN ingrediente i ON i.id = ri.ingrediente_id ' +
    'JOIN sabor s ON s.id = ri.sabor_id ' +
    'WHERE ri.sabor_id = :sabor ' +
    'ORDER BY i.nome';

  ROT_RECEITA: array[0..11] of string = (
    'ingrediente', 'Ingrediente',
    'unidade', 'Unid.',
    'qt_receita', 'Qtd. na receita',
    'qt_por_tortinha', 'Qtd. por tortinha',
    'vl_custo_receita', 'Custo na receita',
    'vu_custo_tortinha', 'Custo por tortinha');

procedure TFrmSabores.FormCreate(Sender: TObject);
begin
  FQrySabores := DMConexao.NovaQuery(Self, SQL_SABORES);
  FDSSabores := TDataSource.Create(Self);
  FDSSabores.DataSet := FQrySabores;
  FDSSabores.OnDataChange := DSSaboresDataChange;
  grdSabores.DataSource := FDSSabores;

  FQryReceita := DMConexao.NovaQuery(Self, SQL_RECEITA);
  FDSReceita := TDataSource.Create(Self);
  FDSReceita.DataSet := FQryReceita;
  FDSReceita.OnDataChange := DSReceitaDataChange;
  grdReceita.DataSource := FDSReceita;

  CarregarCombo(cbIngrediente, 'SELECT id, nome FROM ingrediente ORDER BY nome');
  Reabrir(FQrySabores, ROT_SABORES);
  if FQrySabores.IsEmpty then
    Limpar;
end;

procedure TFrmSabores.DSSaboresDataChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
  begin
    CarregarEdicao;
    CarregarReceita;
  end;
end;

procedure TFrmSabores.grdSaboresCellClick(Column: TColumn);
begin
  if IdAtual(FQrySabores) <> FId then
  begin
    CarregarEdicao;
    CarregarReceita;
  end
  else
    CarregarEdicao;
end;

procedure TFrmSabores.grdReceitaCellClick(Column: TColumn);
begin
  CarregarItemReceita;
end;

procedure TFrmSabores.DSReceitaDataChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
    CarregarItemReceita;
end;

procedure TFrmSabores.CarregarItemReceita;
begin
  if FQryReceita.IsEmpty then
    Exit;
  SelecionarIdNoCombo(cbIngrediente, FQryReceita.FieldByName('ingrediente_id').AsInteger);
  edQtdReceita.Text := FormatFloat('0.###', NumCampo(FQryReceita.FieldByName('qt_receita')));
  lblUnidade.Caption := FQryReceita.FieldByName('unidade').AsString;
end;

procedure TFrmSabores.CarregarEdicao;
begin
  if FQrySabores.IsEmpty then
  begin
    Limpar;
    Exit;
  end;
  FId := FQrySabores.FieldByName('id').AsInteger;
  edNome.Text := FQrySabores.FieldByName('nome').AsString;
  edPreco.Text := FormatFloat('0.00', NumCampo(FQrySabores.FieldByName('vl_preco')));
  edRendimento.Text := IntToStr(FQrySabores.FieldByName('nr_rendimento').AsInteger);
  lblModo.Caption := 'Editando: ' + edNome.Text;
end;

procedure TFrmSabores.CarregarReceita;
begin
  FQryReceita.ParamByName('sabor').AsInteger := FId;
  Reabrir(FQryReceita, ROT_RECEITA);
  if FId = 0 then
  begin
    lblReceita.Caption := 'Receita: salve o sabor para incluir ingredientes';
    lblCustoTortinha.Caption := '';
  end
  else
  begin
    lblReceita.Caption := Format('Receita de %s (rende %s tortinhas)',
      [edNome.Text, edRendimento.Text]);
    lblCustoTortinha.Caption := 'Custo por tortinha: ' + FmtMoeda(CustoPorTortinha(FId));
  end;
end;

procedure TFrmSabores.AtualizarTudo;
begin
  // Reabrir os sabores dispara DSSaboresDataChange, que recarrega a receita.
  Reabrir(FQrySabores, ROT_SABORES, FId);
end;

procedure TFrmSabores.Limpar;
begin
  FId := 0;
  edNome.Clear;
  edPreco.Clear;
  edRendimento.Text := '16';
  lblModo.Caption := 'Novo sabor';
end;

procedure TFrmSabores.btnNovoClick(Sender: TObject);
begin
  Limpar;
  CarregarReceita;
  edNome.SetFocus;
end;

procedure TFrmSabores.btnSalvarClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := FId;
  SalvarSabor(Id, edNome.Text, LerNumero(edPreco, 'Preço de venda'),
    LerInteiro(edRendimento, 'Rendimento'));
  FId := Id;
  AtualizarTudo;
end;

procedure TFrmSabores.btnExcluirClick(Sender: TObject);
begin
  if FId = 0 then
    Exit;
  if not Confirmar('Excluir o sabor "' + edNome.Text + '" e a receita dele?') then
    Exit;
  ExcluirSabor(FId);
  FId := 0;
  AtualizarTudo;
end;

procedure TFrmSabores.btnAdicionarItemClick(Sender: TObject);
begin
  if FId = 0 then
    raise EValidacao.Create('Salve o sabor antes de montar a receita.');
  SalvarItemReceita(FId, IdDoCombo(cbIngrediente),
    LerNumero(edQtdReceita, 'Quantidade na receita'));
  AtualizarTudo;
end;

procedure TFrmSabores.btnRemoverItemClick(Sender: TObject);
var
  ItemId: Integer;
begin
  ItemId := IdAtual(FQryReceita);
  if ItemId = 0 then
    Exit;
  if not Confirmar('Remover "' + FQryReceita.FieldByName('ingrediente').AsString +
    '" da receita?') then
    Exit;
  ExcluirItemReceita(ItemId);
  AtualizarTudo;
end;

procedure TFrmSabores.cbIngredienteChange(Sender: TObject);
var
  Id: Integer;
begin
  Id := IdDoCombo(cbIngrediente);
  if Id > 0 then
    lblUnidade.Caption := VarToStr(Conn.ExecSQLScalar(
      'SELECT unidade FROM ingrediente WHERE id = :id', [Id]))
  else
    lblUnidade.Caption := '';
end;

end.
