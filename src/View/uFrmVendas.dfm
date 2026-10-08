object FrmVendas: TFrmVendas
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Vendas'
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
      Caption = 'Vendas'
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
      Caption = 'Monte a venda com um ou mais sabores e finalize. O custo de cada tortinha '#233' gravado no momento da venda.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlLancamento: TPanel
    Left = 0
    Top = 64
    Width = 990
    Height = 262
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clWindow
    TabOrder = 1
    object lblData: TLabel
      Left = 16
      Top = 6
      Width = 30
      Height = 17
      Caption = 'Data'
    end
    object dtpData: TDateTimePicker
      Left = 16
      Top = 26
      Width = 130
      Height = 25
      TabOrder = 0
    end
    object lblSabor: TLabel
      Left = 160
      Top = 6
      Width = 35
      Height = 17
      Caption = 'Sabor'
    end
    object cbSabor: TComboBox
      Left = 160
      Top = 26
      Width = 220
      Height = 25
      Style = csDropDownList
      OnChange = cbSaborChange
      TabOrder = 1
    end
    object lblQtd: TLabel
      Left = 394
      Top = 6
      Width = 30
      Height = 17
      Caption = 'Qtd.'
    end
    object edQtd: TEdit
      Left = 394
      Top = 26
      Width = 70
      Height = 25
      TabOrder = 2
    end
    object lblPreco: TLabel
      Left = 478
      Top = 6
      Width = 80
      Height = 17
      Caption = 'Pre'#231'o (R$)'
    end
    object edPreco: TEdit
      Left = 478
      Top = 26
      Width = 98
      Height = 25
      TabOrder = 3
    end
    object btnAdicionar: TButton
      Left = 590
      Top = 23
      Width = 120
      Height = 30
      Caption = 'Adicionar'
      OnClick = btnAdicionarClick
      TabOrder = 4
    end
    object sgCarrinho: TStringGrid
      Left = 16
      Top = 64
      Width = 560
      Height = 186
      ColCount = 4
      DefaultRowHeight = 24
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      TabOrder = 5
    end
    object btnRemoverItem: TButton
      Left = 590
      Top = 64
      Width = 120
      Height = 30
      Caption = 'Remover item'
      OnClick = btnRemoverItemClick
      TabOrder = 6
    end
    object lblCliente: TLabel
      Left = 740
      Top = 6
      Width = 200
      Height = 17
      Caption = 'Cliente (obrigat'#243'ria no fiado)'
    end
    object cbCliente: TComboBox
      Left = 740
      Top = 26
      Width = 230
      Height = 25
      OnChange = cbClienteChange
      TabOrder = 7
    end
    object lblForma: TLabel
      Left = 740
      Top = 60
      Width = 140
      Height = 17
      Caption = 'Forma de pagamento'
    end
    object cbForma: TComboBox
      Left = 740
      Top = 80
      Width = 230
      Height = 25
      Style = csDropDownList
      Items.Strings = (
        'Dinheiro'
        'Pix'
        'Cart'#227'o de d'#233'bito'
        'Cart'#227'o de cr'#233'dito'
        'Fiado')
      OnChange = cbFormaChange
      TabOrder = 8
    end
    object lblTotal: TLabel
      Left = 740
      Top = 120
      Width = 230
      Height = 30
      Caption = 'Total: R$ 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnFinalizar: TButton
      Left = 740
      Top = 160
      Width = 230
      Height = 44
      Caption = 'Finalizar venda'
      OnClick = btnFinalizarClick
      TabOrder = 9
    end
    object lblMensagem: TLabel
      Left = 740
      Top = 212
      Width = 235
      Height = 44
      Caption = ''
      AutoSize = False
      WordWrap = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlFiltro: TPanel
    Left = 0
    Top = 326
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
    object btnExcluirVenda: TButton
      Left = 430
      Top = 9
      Width = 130
      Height = 30
      Caption = 'Excluir venda'
      OnClick = btnExcluirVendaClick
      TabOrder = 3
    end
    object lblTotais: TLabel
      Left = 576
      Top = 15
      Width = 600
      Height = 17
      Caption = ''
    end
  end
  object grdVendas: TDBGrid
    Left = 0
    Top = 374
    Width = 990
    Height = 306
    Align = alClient
    BorderStyle = bsNone
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 3
  end
end
