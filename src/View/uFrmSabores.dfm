object FrmSabores: TFrmSabores
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Sabores e receitas'
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
      Caption = 'Sabores e receitas'
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
      Caption = 'Custo por tortinha = soma dos ingredientes da receita / rendimento. Inclua tamb'#233'm embalagem e colherzinha na receita.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlSabores: TPanel
    Left = 0
    Top = 64
    Width = 990
    Height = 250
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clWindow
    TabOrder = 1
    object pnlEdSabor: TPanel
      Left = 690
      Top = 0
      Width = 300
      Height = 250
      Align = alRight
      BevelOuter = bvNone
      ParentBackground = False
      ShowCaption = False
      Color = clBtnFace
      TabOrder = 0
      object lblModo: TLabel
        Left = 16
        Top = 8
        Width = 270
        Height = 17
        Caption = 'Novo sabor'
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
        Width = 120
        Height = 17
        Caption = 'Nome do sabor'
      end
      object edNome: TEdit
        Left = 16
        Top = 54
        Width = 268
        Height = 25
        TabOrder = 0
      end
      object lblPreco: TLabel
        Left = 16
        Top = 86
        Width = 130
        Height = 17
        Caption = 'Pre'#231'o de venda (R$)'
      end
      object edPreco: TEdit
        Left = 16
        Top = 106
        Width = 130
        Height = 25
        TabOrder = 1
      end
      object lblRendimento: TLabel
        Left = 160
        Top = 86
        Width = 130
        Height = 17
        Caption = 'Tortinhas por receita'
      end
      object edRendimento: TEdit
        Left = 160
        Top = 106
        Width = 124
        Height = 25
        TabOrder = 2
      end
      object btnNovo: TButton
        Left = 16
        Top = 148
        Width = 84
        Height = 30
        Caption = 'Novo'
        OnClick = btnNovoClick
        TabOrder = 3
      end
      object btnSalvar: TButton
        Left = 108
        Top = 148
        Width = 84
        Height = 30
        Caption = 'Salvar'
        OnClick = btnSalvarClick
        TabOrder = 4
      end
      object btnExcluir: TButton
        Left = 200
        Top = 148
        Width = 84
        Height = 30
        Caption = 'Excluir'
        OnClick = btnExcluirClick
        TabOrder = 5
      end
    end
    object grdSabores: TDBGrid
      Left = 0
      Top = 0
      Width = 690
      Height = 250
      Align = alClient
      BorderStyle = bsNone
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      OnCellClick = grdSaboresCellClick
      TabOrder = 1
    end
  end
  object pnlReceitaTopo: TPanel
    Left = 0
    Top = 314
    Width = 990
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clBtnFace
    TabOrder = 2
    object lblReceita: TLabel
      Left = 16
      Top = 12
      Width = 520
      Height = 17
      Caption = 'Receita'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblCustoTortinha: TLabel
      Left = 560
      Top = 12
      Width = 300
      Height = 17
      Caption = ''
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlEdReceita: TPanel
    Left = 0
    Top = 616
    Width = 990
    Height = 64
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clBtnFace
    TabOrder = 3
    object lblIngrediente: TLabel
      Left = 16
      Top = 6
      Width = 100
      Height = 17
      Caption = 'Ingrediente'
    end
    object cbIngrediente: TComboBox
      Left = 16
      Top = 26
      Width = 240
      Height = 25
      Style = csDropDownList
      OnChange = cbIngredienteChange
      TabOrder = 0
    end
    object lblQtdReceita: TLabel
      Left = 270
      Top = 6
      Width = 200
      Height = 17
      Caption = 'Qtd. usada na receita inteira'
    end
    object edQtdReceita: TEdit
      Left = 270
      Top = 26
      Width = 120
      Height = 25
      TabOrder = 1
    end
    object lblUnidade: TLabel
      Left = 398
      Top = 30
      Width = 40
      Height = 17
      Caption = ''
    end
    object btnAdicionarItem: TButton
      Left = 450
      Top = 23
      Width = 170
      Height = 30
      Caption = 'Adicionar / atualizar'
      OnClick = btnAdicionarItemClick
      TabOrder = 2
    end
    object btnRemoverItem: TButton
      Left = 628
      Top = 23
      Width = 150
      Height = 30
      Caption = 'Remover da receita'
      OnClick = btnRemoverItemClick
      TabOrder = 3
    end
  end
  object grdReceita: TDBGrid
    Left = 0
    Top = 354
    Width = 990
    Height = 262
    Align = alClient
    BorderStyle = bsNone
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    OnCellClick = grdReceitaCellClick
    TabOrder = 4
  end
end
