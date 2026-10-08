object FrmIngredientes: TFrmIngredientes
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Ingredientes'
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
      Caption = 'Ingredientes'
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
      Caption = 'Cadastre o tamanho e o pre'#231'o de cada embalagem. O custo por unidade (g, ml, un) '#233' calculado automaticamente.'
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
    Top = 556
    Width = 990
    Height = 124
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clBtnFace
    TabOrder = 1
    object lblModo: TLabel
      Left = 16
      Top = 8
      Width = 400
      Height = 17
      Caption = 'Novo ingrediente'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNome: TLabel
      Left = 16
      Top = 34
      Width = 30
      Height = 17
      Caption = 'Nome'
    end
    object edNome: TEdit
      Left = 16
      Top = 54
      Width = 260
      Height = 25
      TabOrder = 0
    end
    object lblUnidade: TLabel
      Left = 290
      Top = 34
      Width = 49
      Height = 17
      Caption = 'Unidade'
    end
    object cbUnidade: TComboBox
      Left = 290
      Top = 54
      Width = 80
      Height = 25
      Items.Strings = (
        'g'
        'ml'
        'un'
        'kg'
        'L')
      TabOrder = 1
    end
    object lblQtdEmbalagem: TLabel
      Left = 384
      Top = 34
      Width = 130
      Height = 17
      Caption = 'Qtd. na embalagem'
    end
    object edQtdEmbalagem: TEdit
      Left = 384
      Top = 54
      Width = 130
      Height = 25
      TabOrder = 2
    end
    object lblPreco: TLabel
      Left = 528
      Top = 34
      Width = 160
      Height = 17
      Caption = 'Pre'#231'o da embalagem (R$)'
    end
    object edPreco: TEdit
      Left = 528
      Top = 54
      Width = 150
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
  object grdLista: TDBGrid
    Left = 0
    Top = 64
    Width = 990
    Height = 492
    Align = alClient
    BorderStyle = bsNone
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    OnCellClick = grdListaCellClick
    TabOrder = 2
  end
end
