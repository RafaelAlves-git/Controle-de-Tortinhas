object FrmProducao: TFrmProducao
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Produ'#231#227'o'
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
      Caption = 'Produ'#231#227'o'
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
      Caption = 'Registre as receitas (fornadas) feitas. Os ingredientes saem do estoque conforme a receita do sabor.'
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
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clWindow
    TabOrder = 1
    object lblData: TLabel
      Left = 16
      Top = 8
      Width = 30
      Height = 17
      Caption = 'Data'
    end
    object dtpData: TDateTimePicker
      Left = 16
      Top = 28
      Width = 130
      Height = 25
      TabOrder = 0
    end
    object lblSabor: TLabel
      Left = 160
      Top = 8
      Width = 35
      Height = 17
      Caption = 'Sabor'
    end
    object cbSabor: TComboBox
      Left = 160
      Top = 28
      Width = 240
      Height = 25
      Style = csDropDownList
      OnChange = CamposChange
      TabOrder = 1
    end
    object lblReceitas: TLabel
      Left = 414
      Top = 8
      Width = 90
      Height = 17
      Caption = 'Receitas'
    end
    object edReceitas: TEdit
      Left = 414
      Top = 28
      Width = 100
      Height = 25
      OnChange = CamposChange
      TabOrder = 2
    end
    object btnLancar: TButton
      Left = 530
      Top = 25
      Width = 150
      Height = 30
      Caption = 'Lan'#231'ar produ'#231#227'o'
      OnClick = btnLancarClick
      TabOrder = 3
    end
    object lblInfo: TLabel
      Left = 16
      Top = 66
      Width = 800
      Height = 17
      Caption = ''
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlFiltro: TPanel
    Left = 0
    Top = 164
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
    object btnExcluir: TButton
      Left = 430
      Top = 9
      Width = 140
      Height = 30
      Caption = 'Excluir produ'#231#227'o'
      OnClick = btnExcluirClick
      TabOrder = 3
    end
    object lblTotal: TLabel
      Left = 586
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
    Top = 212
    Width = 990
    Height = 468
    Align = alClient
    BorderStyle = bsNone
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 3
  end
end
