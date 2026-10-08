object FrmCompras: TFrmCompras
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Compras'
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
      Caption = 'Compras de ingredientes'
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
      Caption = 'Cada compra d'#225' entrada no estoque (embalagens x qtd. na embalagem).'
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
    object lblIngrediente: TLabel
      Left = 160
      Top = 8
      Width = 100
      Height = 17
      Caption = 'Ingrediente'
    end
    object cbIngrediente: TComboBox
      Left = 160
      Top = 28
      Width = 240
      Height = 25
      Style = csDropDownList
      OnChange = CamposChange
      TabOrder = 1
    end
    object lblEmbalagens: TLabel
      Left = 414
      Top = 8
      Width = 90
      Height = 17
      Caption = 'Embalagens'
    end
    object edEmbalagens: TEdit
      Left = 414
      Top = 28
      Width = 100
      Height = 25
      OnChange = CamposChange
      TabOrder = 2
    end
    object lblValor: TLabel
      Left = 528
      Top = 8
      Width = 150
      Height = 17
      Caption = 'Valor total pago (R$)'
    end
    object edValor: TEdit
      Left = 528
      Top = 28
      Width = 150
      Height = 25
      TabOrder = 3
    end
    object btnLancar: TButton
      Left = 694
      Top = 25
      Width = 140
      Height = 30
      Caption = 'Lan'#231'ar compra'
      OnClick = btnLancarClick
      TabOrder = 4
    end
    object chkAtualizarPreco: TCheckBox
      Left = 16
      Top = 64
      Width = 520
      Height = 21
      Caption = 'Atualizar o pre'#231'o da embalagem no cadastro com o valor desta compra'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object lblInfo: TLabel
      Left = 16
      Top = 94
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
    object btnExcluir: TButton
      Left = 430
      Top = 9
      Width = 130
      Height = 30
      Caption = 'Excluir compra'
      OnClick = btnExcluirClick
      TabOrder = 3
    end
    object lblTotal: TLabel
      Left = 576
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
    TabOrder = 3
  end
end
