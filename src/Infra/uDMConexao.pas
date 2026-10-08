unit uDMConexao;

{ Conexão com o banco SQLite.

  O motor do SQLite é compilado DENTRO do exe pela unit
  FireDAC.Phys.SQLiteWrapper.Stat: não é preciso sqlite3.dll nem instalar nada.
  O arquivo do banco (tortinhas.db) é criado automaticamente na primeira execução. }

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat, // SQLite estático (embutido no exe)
  FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

const
  NOME_BANCO = 'tortinhas.db';

type
  TDMConexao = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConn: TFDConnection;
    FCaminhoBanco: string;
    function DefinirCaminhoBanco: string;
  public
    /// Cria uma TFDQuery já ligada à conexão.
    function NovaQuery(AOwner: TComponent; const ASQL: string = ''): TFDQuery;
    /// Último id gerado por INSERT nesta conexão.
    function UltimoId: Integer;
    /// Copia o banco inteiro para ADestino (pode ser feito com o programa aberto).
    procedure FazerBackup(const ADestino: string);

    property Conn: TFDConnection read FConn;
    property CaminhoBanco: string read FCaminhoBanco;
  end;

var
  DMConexao: TDMConexao;

/// Atalho para DMConexao.Conn.
function Conn: TFDConnection;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uMigracoes;

{$R *.dfm}

function Conn: TFDConnection;
begin
  Result := DMConexao.Conn;
end;

function PastaGravavel(const APasta: string): Boolean;
var
  Teste: string;
begin
  Teste := TPath.Combine(APasta, '~teste_gravacao.tmp');
  try
    TFile.WriteAllText(Teste, 'ok');
    TFile.Delete(Teste);
    Result := True;
  except
    Result := False;
  end;
end;

function TDMConexao.DefinirCaminhoBanco: string;
var
  Pasta: string;
begin
  // 1) Modo portátil: banco ao lado do exe (backup = copiar a pasta).
  Pasta := ExtractFilePath(ParamStr(0));
  // 2) Se a pasta do exe não aceitar gravação (ex.: Arquivos de Programas),
  //    usa %APPDATA%\Tortinhas.
  if not PastaGravavel(Pasta) then
  begin
    Pasta := TPath.Combine(TPath.GetHomePath, 'Tortinhas');
    ForceDirectories(Pasta);
  end;
  Result := TPath.Combine(Pasta, NOME_BANCO);
end;

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
  FCaminhoBanco := DefinirCaminhoBanco;

  FConn := TFDConnection.Create(Self);
  FConn.LoginPrompt := False;
  FConn.Params.Clear;
  FConn.Params.Add('DriverID=SQLite');
  FConn.Params.Add('Database=' + FCaminhoBanco);
  FConn.Params.Add('OpenMode=CreateUTF8');  // cria o arquivo se não existir
  FConn.Params.Add('LockingMode=Normal');   // padrão do FireDAC é Exclusive
  FConn.Params.Add('JournalMode=WAL');      // mais resistente a quedas de energia
  FConn.Params.Add('Synchronous=Normal');
  FConn.Params.Add('ForeignKeys=On');       // SQLite vem com FK desligada
  FConn.Params.Add('StringFormat=Unicode');
  FConn.Connected := True;

  AtualizarBanco(FConn);
end;

procedure TDMConexao.DataModuleDestroy(Sender: TObject);
begin
  if Assigned(FConn) then
    FConn.Connected := False;
end;

function TDMConexao.NovaQuery(AOwner: TComponent; const ASQL: string): TFDQuery;
begin
  Result := TFDQuery.Create(AOwner);
  Result.Connection := FConn;
  Result.SQL.Text := ASQL;
end;

function TDMConexao.UltimoId: Integer;
begin
  Result := FConn.ExecSQLScalar('SELECT last_insert_rowid()');
end;

procedure TDMConexao.FazerBackup(const ADestino: string);
begin
  if TFile.Exists(ADestino) then
    TFile.Delete(ADestino);
  // VACUUM INTO gera uma cópia consistente e compactada do banco.
  FConn.ExecSQL('VACUUM INTO ' + QuotedStr(ADestino));
end;

end.
