object FrmFiado: TFrmFiado
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Fiado'
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
      Caption = 'Fiado'
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
      Caption = 'Quem est'#225' devendo, extrato de cada cliente e recebimento de pagamentos (inclusive parciais).'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlClientes: TPanel
    Left = 0
    Top = 64
    Width = 990
    Height = 300
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clWindow
    TabOrder = 1
    object pnlFiltroCli: TPanel
      Left = 0
      Top = 0
      Width = 990
      Height = 40
      Align = alTop
      BevelOuter = bvNone
      ParentBackground = False
      ShowCaption = False
      Color = clWindow
      TabOrder = 0
      object chkSoDevedores: TCheckBox
        Left = 16
        Top = 10
        Width = 260
        Height = 21
        Caption = 'Mostrar s'#243' quem est'#225' devendo'
        Checked = True
        State = cbChecked
        OnClick = chkSoDevedoresClick
        TabOrder = 0
      end
      object lblTotalAReceber: TLabel
        Left = 300
        Top = 11
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
    object pnlReceber: TPanel
      Left = 660
      Top = 40
      Width = 330
      Height = 260
      Align = alRight
      BevelOuter = bvNone
      ParentBackground = False
      ShowCaption = False
      Color = clBtnFace
      TabOrder = 1
      object lblClienteSel: TLabel
        Left = 16
        Top = 10
        Width = 300
        Height = 17
        Caption = 'Nenhuma cliente selecionada'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSaldoSel: TLabel
        Left = 16
        Top = 34
        Width = 300
        Height = 30
        Caption = ''
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblDesde: TLabel
        Left = 16
        Top = 68
        Width = 300
        Height = 17
        Caption = ''
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblValor: TLabel
        Left = 16
        Top = 96
        Width = 140
        Height = 17
        Caption = 'Valor recebido (R$)'
      end
      object edValor: TEdit
        Left = 16
        Top = 116
        Width = 140
        Height = 25
        TabOrder = 0
      end
      object lblFormaReceb: TLabel
        Left = 170
        Top = 96
        Width = 60
        Height = 17
        Caption = 'Forma'
      end
      object cbFormaReceb: TComboBox
        Left = 170
        Top = 116
        Width = 144
        Height = 25
        Style = csDropDownList
        Items.Strings = (
          'Dinheiro'
          'Pix'
          'Cart'#227'o')
        TabOrder = 1
      end
      object lblDataReceb: TLabel
        Left = 16
        Top = 148
        Width = 60
        Height = 17
        Caption = 'Data'
      end
      object dtpDataReceb: TDateTimePicker
        Left = 16
        Top = 168
        Width = 140
        Height = 25
        TabOrder = 2
      end
      object btnReceber: TButton
        Left = 170
        Top = 165
        Width = 144
        Height = 30
        Caption = 'Receber pagamento'
        OnClick = btnReceberClick
        TabOrder = 3
      end
      object btnCobranca: TButton
        Left = 16
        Top = 212
        Width = 298
        Height = 34
        Caption = 'Copiar mensagem de cobran'#231'a'
        OnClick = btnCobrancaClick
        TabOrder = 4
      end
    end
    object grdClientes: TDBGrid
      Left = 0
      Top = 40
      Width = 660
      Height = 260
      Align = alClient
      BorderStyle = bsNone
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      OnCellClick = grdClientesCellClick
      TabOrder = 2
    end
  end
  object pnlExtratoTopo: TPanel
    Left = 0
    Top = 364
    Width = 990
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clBtnFace
    TabOrder = 2
    object lblExtrato: TLabel
      Left = 16
      Top = 13
      Width = 500
      Height = 17
      Caption = 'Extrato'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnExcluirPagamento: TButton
      Left = 600
      Top = 7
      Width = 170
      Height = 30
      Caption = 'Excluir pagamento'
      OnClick = btnExcluirPagamentoClick
      TabOrder = 0
    end
  end
  object pnlCliente: TPanel
    Left = 0
    Top = 624
    Width = 990
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    ShowCaption = False
    Color = clBtnFace
    TabOrder = 3
    object lblNome: TLabel
      Left = 16
      Top = 18
      Width = 50
      Height = 17
      Caption = 'Cliente'
    end
    object edNome: TEdit
      Left = 70
      Top = 14
      Width = 230
      Height = 25
      TabOrder = 0
    end
    object lblTelefone: TLabel
      Left = 314
      Top = 18
      Width = 60
      Height = 17
      Caption = 'Telefone'
    end
    object edTelefone: TEdit
      Left = 380
      Top = 14
      Width = 150
      Height = 25
      TabOrder = 1
    end
    object btnNovoCliente: TButton
      Left = 546
      Top = 12
      Width = 90
      Height = 30
      Caption = 'Nova'
      OnClick = btnNovoClienteClick
      TabOrder = 2
    end
    object btnSalvarCliente: TButton
      Left = 644
      Top = 12
      Width = 90
      Height = 30
      Caption = 'Salvar'
      OnClick = btnSalvarClienteClick
      TabOrder = 3
    end
    object btnExcluirCliente: TButton
      Left = 742
      Top = 12
      Width = 90
      Height = 30
      Caption = 'Excluir'
      OnClick = btnExcluirClienteClick
      TabOrder = 4
    end
  end
  object sgExtrato: TStringGrid
    Left = 0
    Top = 408
    Width = 990
    Height = 216
    Align = alClient
    BorderStyle = bsNone
    ColCount = 5
    DefaultRowHeight = 24
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 4
  end
end
