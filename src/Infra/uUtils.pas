unit uUtils;

{ Funções gerais, sem dependência de VCL (podem ser usadas pelos services). }

interface

uses
  System.SysUtils, System.Variants, Data.DB;

type
  /// Erro de validação de regra de negócio: a mensagem é mostrada ao usuário como está.
  EValidacao = class(Exception);

/// Data no formato gravado no SQLite ('yyyy-mm-dd').
function DataSQL(const AData: TDateTime): string;

/// Converte texto digitado pelo usuário (aceita "1,5", "1.5", "R$ 10,00").
function TextoParaNumero(const ATexto: string; out AValor: Double): Boolean;

/// Converte um Variant vindo do banco em número (trata Null e texto).
function NumVar(const AValor: Variant): Double;

/// Lê o valor numérico de um campo, qualquer que seja o tipo dele.
function NumCampo(AField: TField): Double;

function FmtMoeda(const AValor: Double): string;
function FmtQtd(const AValor: Double): string;
function FmtPercentual(const AValor: Double): string;

/// Traduz erros comuns do banco para mensagens amigáveis.
function MensagemAmigavel(E: Exception): string;

implementation

function DataSQL(const AData: TDateTime): string;
begin
  Result := FormatDateTime('yyyy"-"mm"-"dd', AData);
end;

function TextoParaNumero(const ATexto: string; out AValor: Double): Boolean;
var
  T: string;
begin
  T := Trim(ATexto);
  T := T.Replace('R$', '').Replace(' ', '');
  if T = '' then
  begin
    AValor := 0;
    Exit(False);
  end;
  // Com vírgula: padrão brasileiro (ponto = milhar). Sem vírgula: ponto = decimal.
  if T.Contains(',') then
    T := T.Replace('.', '').Replace(',', '.');
  Result := TryStrToFloat(T, AValor, TFormatSettings.Invariant);
end;

function NumVar(const AValor: Variant): Double;
begin
  if VarIsNull(AValor) or VarIsEmpty(AValor) then
    Exit(0);
  if VarIsStr(AValor) then
  begin
    if not TextoParaNumero(VarToStr(AValor), Result) then
      Result := 0;
  end
  else
    Result := AValor;
end;

function NumCampo(AField: TField): Double;
begin
  if (AField = nil) or AField.IsNull then
    Exit(0);
  if AField is TNumericField then
    Result := AField.AsFloat
  else if not TextoParaNumero(AField.AsString, Result) then
    Result := 0;
end;

function FmtMoeda(const AValor: Double): string;
begin
  Result := FormatFloat('"R$ "#,##0.00', AValor);
end;

function FmtQtd(const AValor: Double): string;
begin
  Result := FormatFloat('#,##0.###', AValor);
end;

function FmtPercentual(const AValor: Double): string;
begin
  Result := FormatFloat('0.0"%"', AValor);
end;

function MensagemAmigavel(E: Exception): string;
var
  Msg: string;
begin
  if E is EValidacao then
    Exit(E.Message);
  Msg := UpperCase(E.Message);
  if Msg.Contains('FOREIGN KEY') then
    Result := 'Este registro está sendo usado em outro lugar (receitas, vendas, ' +
      'compras ou produção) e não pode ser excluído.'
  else if Msg.Contains('UNIQUE') then
    Result := 'Já existe um cadastro com esse nome.'
  else if Msg.Contains('CHECK CONSTRAINT') then
    Result := 'Valor inválido: verifique se as quantidades são maiores que zero.'
  else
    Result := E.Message;
end;

end.
