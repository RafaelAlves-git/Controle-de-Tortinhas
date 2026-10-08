object FrmEstoque: TFrmEstoque
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Estoque'
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
      Caption = 'Estoque'
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
      Caption = 'Saldo = compras - produ'#231#227'o +/- ajustes. Use "Ajustar" depois de contar o que tem de verdade.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 64
    Width = 990
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clBtnFace
    TabOrder = 1
    object btnAjustar: TButton
      Left = 16
      Top = 9
      Width = 200
      Height = 30
      Caption = 'Ajustar (invent'#225'rio)...'
      OnClick = btnAjustarClick
      TabOrder = 0
    end
    object btnAtualizar: TButton
      Left = 224
      Top = 9
      Width = 100
      Height = 30
      Caption = 'Atualizar'
      OnClick = btnAtualizarClick
      TabOrder = 1
    end
    object lblValorTotal: TLabel
      Left = 344
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
  object pnlTortinhas: TPanel
    Left = 0
    Top = 450
    Width = 990
    Height = 230
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clWindow
    TabOrder = 2
    object pnlTortinhasTitulo: TPanel
      Left = 0
      Top = 0
      Width = 990
      Height = 36
      Align = alTop
      BevelOuter = bvNone
      ParentBackground = False
      ShowCaption = False
      Color = clBtnFace
      TabOrder = 0
      object lblTortinhas: TLabel
        Left = 16
        Top = 10
        Width = 800
        Height = 17
        Caption = 'Tortinhas prontas (produzidas - vendidas - perdidas). Negativo = venda ou perda sem produ'#231#227'o registrada.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object grdTortinhas: TDBGrid
      Left = 0
      Top = 36
      Width = 990
      Height = 194
      Align = alClient
      BorderStyle = bsNone
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 1
    end
  end
  object grdIngredientes: TDBGrid
    Left = 0
    Top = 112
    Width = 990
    Height = 338
    Align = alClient
    BorderStyle = bsNone
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 3
  end
end
