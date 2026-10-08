unit uFrmPrincipal;

{ Janela principal: menu à esquerda e as telas abertas dentro do painel central. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.Buttons;

type
  TFrmPrincipal = class(TForm)
    pnlMenu: TPanel;
    pnlConteudo: TPanel;
    sbStatus: TStatusBar;
    pnSair: TPanel;
    Panel2: TPanel;
    lbTortinhas: TLabel;
    Image1: TImage;
    Image2: TImage;
    Panel3: TPanel;
    Image3: TImage;
    Panel1: TPanel;
    Image4: TImage;
    btnSair: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    btnBackup: TButton;
    btnIngredientes: TButton;
    Panel4: TPanel;
    Image5: TImage;
    Label4: TLabel;
    SpeedButton3: TSpeedButton;
    btnSabores: TButton;
    btnDespesas: TButton;
    btnEstoque: TButton;
    Panel5: TPanel;
    Image6: TImage;
    Label5: TLabel;
    SpeedButton4: TSpeedButton;
    Panel6: TPanel;
    Image7: TImage;
    Label6: TLabel;
    SpeedButton5: TSpeedButton;
    Panel7: TPanel;
    Image8: TImage;
    Label7: TLabel;
    SpeedButton6: TSpeedButton;
    Panel8: TPanel;
    Image9: TImage;
    Label8: TLabel;
    SpeedButton7: TSpeedButton;
    Panel9: TPanel;
    Image10: TImage;
    Label9: TLabel;
    SpeedButton8: TSpeedButton;
    btnCompras: TButton;
    btnProducao: TButton;
    btnVendas: TButton;
    btnResumo: TButton;
    Panel11: TPanel;
    Image11: TImage;
    Label10: TLabel;
    SpeedButton9: TSpeedButton;
    Panel10: TPanel;
    Panel12: TPanel;
    Image12: TImage;
    Label11: TLabel;
    SpeedButton10: TSpeedButton;
    Panel13: TPanel;
    Image13: TImage;
    Label12: TLabel;
    SpeedButton11: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnResumoClick(Sender: TObject);
    procedure btnVendasClick(Sender: TObject);
    procedure btnProducaoClick(Sender: TObject);
    procedure btnComprasClick(Sender: TObject);
    procedure btnEstoqueClick(Sender: TObject);
    procedure btnDespesasClick(Sender: TObject);
    procedure btnSaboresClick(Sender: TObject);
    procedure btnIngredientesClick(Sender: TObject);
    procedure btnBackupClick(Sender: TObject);
    procedure pnSairClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure btnPerdasClick(Sender: TObject);
    procedure btnFiadoClick(Sender: TObject);
  private
    FTelaAtual: TForm;
    procedure AbrirTela(AClasse: TFormClass);
    procedure AppException(Sender: TObject; E: Exception);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses
  System.UITypes, uDMConexao, uUtils, uUIHelpers,
  uFrmResumo, uFrmVendas, uFrmProducao, uFrmCompras, uFrmEstoque,
  uFrmDespesas, uFrmSabores, uFrmIngredientes, uFrmPerdas, uFrmFiado;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  Application.OnException := AppException;
  sbStatus.SimpleText := '  Banco de dados: ' + DMConexao.CaminhoBanco;
  AbrirTela(TFrmResumo);
end;

procedure TFrmPrincipal.AppException(Sender: TObject; E: Exception);
begin
  if E is EValidacao then
    Aviso(E.Message)
  else
    MessageDlg(MensagemAmigavel(E), mtError, [mbOK], 0);
end;

procedure TFrmPrincipal.AbrirTela(AClasse: TFormClass);
begin
  if Assigned(FTelaAtual) then
  begin
    if FTelaAtual.ClassType = AClasse then
      Exit;
    FreeAndNil(FTelaAtual);
  end;
  FTelaAtual := AClasse.Create(Self);
  FTelaAtual.BorderStyle := bsNone;
  FTelaAtual.Parent := pnlConteudo;
  FTelaAtual.Align := alClient;
  FTelaAtual.Show;
end;

procedure TFrmPrincipal.btnResumoClick(Sender: TObject);
begin
  AbrirTela(TFrmResumo);
end;

procedure TFrmPrincipal.btnVendasClick(Sender: TObject);
begin
  AbrirTela(TFrmVendas);
end;

procedure TFrmPrincipal.btnProducaoClick(Sender: TObject);
begin
  AbrirTela(TFrmProducao);
end;

procedure TFrmPrincipal.btnComprasClick(Sender: TObject);
begin
  AbrirTela(TFrmCompras);
end;

procedure TFrmPrincipal.btnEstoqueClick(Sender: TObject);
begin
  AbrirTela(TFrmEstoque);
end;

procedure TFrmPrincipal.btnDespesasClick(Sender: TObject);
begin
  AbrirTela(TFrmDespesas);
end;

procedure TFrmPrincipal.btnSaboresClick(Sender: TObject);
begin
  AbrirTela(TFrmSabores);
end;

procedure TFrmPrincipal.btnFiadoClick(Sender: TObject);
begin
  AbrirTela(TFrmFiado);
end;

procedure TFrmPrincipal.btnPerdasClick(Sender: TObject);
begin
  AbrirTela(TFrmPerdas);
end;

procedure TFrmPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.pnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.btnIngredientesClick(Sender: TObject);
begin
  AbrirTela(TFrmIngredientes);
end;

procedure TFrmPrincipal.btnBackupClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Title := 'Salvar cópia de segurança do banco';
    Dlg.Filter := 'Banco SQLite (*.db)|*.db';
    Dlg.DefaultExt := 'db';
    Dlg.FileName := 'tortinhas_backup_' + FormatDateTime('yyyy-mm-dd_hhnn', Now) + '.db';
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if Dlg.Execute then
    begin
      DMConexao.FazerBackup(Dlg.FileName);
      Informar('Backup salvo em:' + sLineBreak + Dlg.FileName + sLineBreak + sLineBreak +
        'Para restaurar: feche o programa e copie o arquivo para o lugar de ' +
        NOME_BANCO + ' (renomeando).');
    end;
  finally
    Dlg.Free;
  end;
end;

end.
