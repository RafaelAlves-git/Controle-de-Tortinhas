object FrmResumo: TFrmResumo
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Resumo'
  ClientHeight = 680
  ClientWidth = 990
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 17
  object lblMeses: TLabel
    AlignWithMargins = True
    Left = 16
    Top = 586
    Width = 971
    Height = 17
    Margins.Left = 16
    Margins.Top = 10
    Align = alTop
    Caption = 'Resultado m'#234's a m'#234's'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitWidth = 130
  end
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 990
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 8
      Width = 102
      Height = 28
      Caption = 'Dashboard'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 16
      Top = 40
      Width = 318
      Height = 15
      Caption = 'Faturamento, custos, despesas e lucro do per'#237'odo escolhido.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlFiltro: TPanel
    Left = 0
    Top = 64
    Width = 990
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    object lblDe: TLabel
      Left = 16
      Top = 15
      Width = 16
      Height = 17
      Caption = 'De'
    end
    object lblAte: TLabel
      Left = 170
      Top = 15
      Width = 18
      Height = 17
      Caption = 'at'#233
    end
    object dtpIni: TDateTimePicker
      Left = 40
      Top = 11
      Width = 120
      Height = 25
      Date = 46300.000000000000000000
      Time = 0.970155532406352000
      TabOrder = 0
    end
    object dtpFim: TDateTimePicker
      Left = 198
      Top = 11
      Width = 120
      Height = 25
      Date = 46300.000000000000000000
      Time = 0.970155543982400600
      TabOrder = 1
    end
    object btnAtualizar: TButton
      Left = 330
      Top = 9
      Width = 90
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 2
      OnClick = btnAtualizarClick
    end
    object btnMesAtual: TButton
      Left = 440
      Top = 9
      Width = 100
      Height = 30
      Caption = 'Este m'#234's'
      TabOrder = 3
      OnClick = btnMesAtualClick
    end
    object btnMesAnterior: TButton
      Left = 548
      Top = 9
      Width = 110
      Height = 30
      Caption = 'M'#234's anterior'
      TabOrder = 4
      OnClick = btnMesAnteriorClick
    end
    object btnAno: TButton
      Left = 666
      Top = 9
      Width = 90
      Height = 30
      Caption = 'Este ano'
      TabOrder = 5
      OnClick = btnAnoClick
    end
  end
  object pnlKpis: TPanel
    Left = 0
    Top = 112
    Width = 990
    Height = 214
    Align = alTop
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    ShowCaption = False
    TabOrder = 2
  end
  object pnlSabores: TPanel
    Left = 0
    Top = 326
    Width = 990
    Height = 250
    Align = alTop
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    ShowCaption = False
    TabOrder = 3
    object lblSabores: TLabel
      AlignWithMargins = True
      Left = 16
      Top = 6
      Width = 971
      Height = 17
      Margins.Left = 16
      Margins.Top = 6
      Align = alTop
      Caption = 'Vendas por sabor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 107
    end
    object pbGrafico: TPaintBox
      Left = 570
      Top = 26
      Width = 420
      Height = 224
      Align = alRight
      OnPaint = pbGraficoPaint
      ExplicitTop = 27
      ExplicitHeight = 223
    end
    object grdSabores: TDBGrid
      Left = 0
      Top = 26
      Width = 570
      Height = 224
      Align = alClient
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object grdMeses: TDBGrid
    Left = 0
    Top = 606
    Width = 990
    Height = 140
    Align = alClient
    BorderStyle = bsNone
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
end
