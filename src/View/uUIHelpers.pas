unit uUIHelpers;

{ Rotinas de apoio às telas (VCL).

  Convenção de nomes nas colunas das consultas, usada para formatar a grade:
    id / *_id -> coluna escondida
    vl_*      -> dinheiro, 2 casas    ("R$ 1.234,56")
    vu_*      -> dinheiro, 4 casas    (custo unitário de ingrediente)
    qt_*      -> quantidade           ("1.234,5")
    pc_*      -> percentual já x100   ("12,5%")
    nr_*      -> número inteiro sem formatação especial
  Colunas calculadas usam o sufixo "::TIPO" no alias (ex.: AS "vl_total::FLOAT")
  para o FireDAC saber o tipo da expressão no SQLite. }

interface

uses
  System.SysUtils, System.Classes, Data.DB, Vcl.StdCtrls, Vcl.Controls,
  Vcl.Dialogs, FireDAC.Comp.Client;

/// Ajusta rótulos, formatos e colunas visíveis. ARotulos = ['campo', 'Título', ...].
procedure FormatarCampos(ADataSet: TDataSet; const ARotulos: array of string);

/// Fecha, reabre a consulta, formata e tenta voltar ao registro de id AIdAtual.
procedure Reabrir(AQuery: TFDQuery; const ARotulos: array of string;
  AIdAtual: Integer = 0; const ACampoId: string = 'id');

/// Id do registro atual (0 se vazio).
function IdAtual(ADataSet: TDataSet; const ACampoId: string = 'id'): Integer;

/// Preenche o combo com (id, nome) vindos do SQL; o id fica em Items.Objects.
procedure CarregarCombo(ACombo: TComboBox; const ASQL: string);
function IdDoCombo(ACombo: TComboBox): Integer;
procedure SelecionarIdNoCombo(ACombo: TComboBox; AId: Integer);

/// Lê um número digitado; mostra aviso e foca o campo se for inválido.
function LerNumero(AEdit: TEdit; const ANomeCampo: string): Double;
function LerInteiro(AEdit: TEdit; const ANomeCampo: string): Integer;

function Confirmar(const AMensagem: string): Boolean;
procedure Aviso(const AMensagem: string);
procedure Informar(const AMensagem: string);

implementation

uses
  System.UITypes, System.Math, uUtils, uDMConexao;

function NomeBase(const ANomeCampo: string): string;
var
  P: Integer;
begin
  Result := LowerCase(ANomeCampo);
  P := Pos('::', Result);
  if P > 0 then
    Result := Copy(Result, 1, P - 1);
end;

function RotuloPadrao(const ANome: string): string;
begin
  Result := ANome;
  if (Length(Result) > 3) and (Result[3] = '_') then
    Delete(Result, 1, 3); // tira vl_, qt_, pc_, vu_, nr_
  Result := Result.Replace('_', ' ');
  if Result <> '' then
    Result[1] := UpCase(Result[1]);
end;

procedure FormatarCampos(ADataSet: TDataSet; const ARotulos: array of string);
var
  F: TField;
  Nome: string;
  I: Integer;
begin
  for F in ADataSet.Fields do
  begin
    Nome := NomeBase(F.FieldName);

    if (Nome = 'id') or Nome.EndsWith('_id') then
      F.Visible := False;

    if F is TNumericField then
    begin
      if Nome.StartsWith('vl_') then
        TNumericField(F).DisplayFormat := '"R$ "#,##0.00'
      else if Nome.StartsWith('vu_') then
        TNumericField(F).DisplayFormat := '"R$ "#,##0.0000'
      else if Nome.StartsWith('qt_') then
        TNumericField(F).DisplayFormat := '#,##0.###'
      else if Nome.StartsWith('pc_') then
        TNumericField(F).DisplayFormat := '0.0"%"';
      F.Alignment := taRightJustify;
    end
    else if F is TDateTimeField then
      TDateTimeField(F).DisplayFormat := 'dd/mm/yyyy'
    else if F is TStringField then
    begin
      if F.DisplayWidth > 28 then
        F.DisplayWidth := 28;
    end;

    F.DisplayLabel := RotuloPadrao(Nome);
    for I := 0 to (Length(ARotulos) div 2) - 1 do
      if SameText(ARotulos[I * 2], Nome) then
      begin
        F.DisplayLabel := ARotulos[I * 2 + 1];
        Break;
      end;

    // Largura da coluna na grade: cabe o título e o conteúdo.
    if F is TStringField then
      F.DisplayWidth := Max(F.DisplayWidth, Length(F.DisplayLabel) + 1)
    else
      F.DisplayWidth := Max(12, Length(F.DisplayLabel) + 2);
  end;
end;

function IdAtual(ADataSet: TDataSet; const ACampoId: string): Integer;
begin
  if (ADataSet = nil) or (not ADataSet.Active) or ADataSet.IsEmpty then
    Exit(0);
  Result := ADataSet.FieldByName(ACampoId).AsInteger;
end;

procedure Reabrir(AQuery: TFDQuery; const ARotulos: array of string;
  AIdAtual: Integer; const ACampoId: string);
begin
  AQuery.DisableControls;
  try
    AQuery.Close;
    AQuery.Open;
    FormatarCampos(AQuery, ARotulos);
    if AIdAtual > 0 then
      AQuery.Locate(ACampoId, AIdAtual, []);
  finally
    AQuery.EnableControls;
  end;
end;

procedure CarregarCombo(ACombo: TComboBox; const ASQL: string);
var
  Q: TFDQuery;
begin
  ACombo.Items.BeginUpdate;
  try
    ACombo.Items.Clear;
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := DMConexao.Conn;
      Q.SQL.Text := ASQL;
      Q.Open;
      while not Q.Eof do
      begin
        ACombo.Items.AddObject(Q.Fields[1].AsString,
          TObject(NativeInt(Q.Fields[0].AsInteger)));
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  finally
    ACombo.Items.EndUpdate;
  end;
end;

function IdDoCombo(ACombo: TComboBox): Integer;
begin
  if ACombo.ItemIndex < 0 then
    Exit(0);
  Result := Integer(NativeInt(ACombo.Items.Objects[ACombo.ItemIndex]));
end;

procedure SelecionarIdNoCombo(ACombo: TComboBox; AId: Integer);
var
  I: Integer;
begin
  for I := 0 to ACombo.Items.Count - 1 do
    if Integer(NativeInt(ACombo.Items.Objects[I])) = AId then
    begin
      ACombo.ItemIndex := I;
      Exit;
    end;
  ACombo.ItemIndex := -1;
end;

function LerNumero(AEdit: TEdit; const ANomeCampo: string): Double;
begin
  if not TextoParaNumero(AEdit.Text, Result) then
  begin
    if AEdit.CanFocus then
      AEdit.SetFocus;
    raise EValidacao.CreateFmt('Valor inválido em "%s".', [ANomeCampo]);
  end;
end;

function LerInteiro(AEdit: TEdit; const ANomeCampo: string): Integer;
var
  V: Double;
begin
  V := LerNumero(AEdit, ANomeCampo);
  if Frac(V) <> 0 then
  begin
    if AEdit.CanFocus then
      AEdit.SetFocus;
    raise EValidacao.CreateFmt('"%s" deve ser um número inteiro.', [ANomeCampo]);
  end;
  Result := Trunc(V);
end;

function Confirmar(const AMensagem: string): Boolean;
begin
  Result := MessageDlg(AMensagem, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure Aviso(const AMensagem: string);
begin
  MessageDlg(AMensagem, mtWarning, [mbOK], 0);
end;

procedure Informar(const AMensagem: string);
begin
  MessageDlg(AMensagem, mtInformation, [mbOK], 0);
end;

end.
