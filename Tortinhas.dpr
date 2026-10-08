program Tortinhas;

uses
  Vcl.Forms,
  uUtils in 'src\Infra\uUtils.pas',
  uMigracoes in 'src\Infra\uMigracoes.pas',
  uDMConexao in 'src\Infra\uDMConexao.pas' {DMConexao: TDataModule},
  uCadastroService in 'src\Service\uCadastroService.pas',
  uCustoService in 'src\Service\uCustoService.pas',
  uEstoqueService in 'src\Service\uEstoqueService.pas',
  uVendaService in 'src\Service\uVendaService.pas',
  uResumoService in 'src\Service\uResumoService.pas',
  uFiadoService in 'src\Service\uFiadoService.pas',
  uUIHelpers in 'src\View\uUIHelpers.pas',
  uFrmPrincipal in 'src\View\uFrmPrincipal.pas' {FrmPrincipal},
  uFrmResumo in 'src\View\uFrmResumo.pas' {FrmResumo},
  uFrmVendas in 'src\View\uFrmVendas.pas' {FrmVendas},
  uFrmProducao in 'src\View\uFrmProducao.pas' {FrmProducao},
  uFrmCompras in 'src\View\uFrmCompras.pas' {FrmCompras},
  uFrmEstoque in 'src\View\uFrmEstoque.pas' {FrmEstoque},
  uFrmDespesas in 'src\View\uFrmDespesas.pas' {FrmDespesas},
  uFrmSabores in 'src\View\uFrmSabores.pas' {FrmSabores},
  uFrmIngredientes in 'src\View\uFrmIngredientes.pas' {FrmIngredientes},
  uFrmPerdas in 'src\View\uFrmPerdas.pas' {FrmPerdas},
  uFrmFiado in 'src\View\uFrmFiado.pas' {FrmFiado};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Controle de Tortinhas';
  Application.CreateForm(TDMConexao, DMConexao);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
