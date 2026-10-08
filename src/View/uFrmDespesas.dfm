object FrmDespesas: TFrmDespesas
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Despesas'
  ClientHeight = 680
  ClientWidth = 990
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 990
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clWindow
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 8
      Width = 600
      Height = 30
      Caption = 'Despesas extras'
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
      Width = 900
      Height = 17
      Caption = 'Gastos que n'#227'o s'#227'o ingredientes: g'#225's, energia, transporte, divulga'#231#227'o, taxas...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlEdicao: TPanel
    Left = 0
    Top = 64
    Width = 990
    Height = 124
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clWindow
    TabOrder = 1
    object lblModo: TLabel
      Left = 16
      Top = 8
      Width = 400
      Height = 17
      Caption = 'Nova despesa'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblData: TLabel
      Left = 16
      Top = 34
      Width = 30
      Height = 17
      Caption = 'Data'
    end
    object dtpData: TDateTimePicker
      Left = 16
      Top = 54
      Width = 130
      Height = 25
      TabOrder = 0
    end
    object lblDescricao: TLabel
      Left = 160
      Top = 34
      Width = 80
      Height = 17
      Caption = 'Descri'#231#227'o'
    end
    object edDescricao: TEdit
      Left = 160
      Top = 54
      Width = 300
      Height = 25
      TabOrder = 1
    end
    object lblCategoria: TLabel
      Left = 474
      Top = 34
      Width = 80
      Height = 17
      Caption = 'Categoria'
    end
    object cbCategoria: TComboBox
      Left = 474
      Top = 54
      Width = 180
      Height = 25
      TabOrder = 2
    end
    object lblValor: TLabel
      Left = 668
      Top = 34
      Width = 80
      Height = 17
      Caption = 'Valor (R$)'
    end
    object edValor: TEdit
      Left = 668
      Top = 54
      Width = 120
      Height = 25
      TabOrder = 3
    end
    object btnNovo: TButton
      Left = 16
      Top = 88
      Width = 100
      Height = 30
      Caption = 'Novo'
      OnClick = btnNovoClick
      TabOrder = 4
    end
    object btnSalvar: TButton
      Left = 124
      Top = 88
      Width = 100
      Height = 30
      Caption = 'Salvar'
      OnClick = btnSalvarClick
      TabOrder = 5
    end
    object btnExcluir: TButton
      Left = 232
      Top = 88
      Width = 100
      Height = 30
      Caption = 'Excluir'
      OnClick = btnExcluirClick
      TabOrder = 6
    end
  end
  object pnlFiltro: TPanel
    Left = 0
    Top = 188
    Width = 990
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clBtnFace
    TabOrder = 2
    object lblDe: TLabel
      Left = 16
      Top = 15
      Width = 20
      Height = 17
      Caption = 'De'
    end
    object dtpIni: TDateTimePicker
      Left = 40
      Top = 11
      Width = 120
      Height = 25
      TabOrder = 0
    end
    object lblAte: TLabel
      Left = 170
      Top = 15
      Width = 24
      Height = 17
      Caption = 'at'#233
    end
    object dtpFim: TDateTimePicker
      Left = 198
      Top = 11
      Width = 120
      Height = 25
      TabOrder = 1
    end
    object btnFiltrar: TButton
      Left = 330
      Top = 9
      Width = 90
      Height = 30
      Caption = 'Filtrar'
      OnClick = btnFiltrarClick
      TabOrder = 2
    end
    object lblTotal: TLabel
      Left = 440
      Top = 15
      Width = 400
      Height = 17
      Caption = ''
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object grdLista: TDBGrid
    Left = 0
    Top = 236
    Width = 990
    Height = 444
    Align = alClient
    BorderStyle = bsNone
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    OnCellClick = grdListaCellClick
    TabOrder = 3
  end
end
