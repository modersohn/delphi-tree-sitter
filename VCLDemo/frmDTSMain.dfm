object DTSMain: TDTSMain
  Left = 0
  Top = 0
  Caption = 'Tree-Sitter for Delphi demo'
  ClientHeight = 478
  ClientWidth = 765
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 462
    Top = 50
    Height = 428
    Align = alRight
    ExplicitLeft = 320
    ExplicitTop = 192
    ExplicitHeight = 100
  end
  object memCode: TMemo
    Left = 0
    Top = 50
    Width = 462
    Height = 428
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Consolas'
    Font.Style = []
    HideSelection = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    OnChange = memCodeChange
    OnExit = memCodeExit
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 765
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblCode: TLabel
      Left = 104
      Top = 17
      Width = 31
      Height = 15
      Caption = 'Code:'
    end
    object btnLoad: TButton
      Left = 8
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Load...'
      TabOrder = 0
      OnClick = btnLoadClick
    end
    object cbCode: TComboBox
      Left = 141
      Top = 14
      Width = 145
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      OnChange = cbCodeChange
      Items.Strings = (
        'c'
        'cpp'
        'proto')
    end
  end
  object treeView: TTreeView
    Left = 465
    Top = 50
    Width = 300
    Height = 428
    Align = alRight
    Indent = 19
    ReadOnly = True
    TabOrder = 2
    OnChange = treeViewChange
    OnCreateNodeClass = treeViewCreateNodeClass
    OnExpanding = treeViewExpanding
  end
  object OD: TFileOpenDialog
    ClientGuid = '{58D00BB6-8E09-48B3-B19E-7E86D8D6B167}'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'All files'
        FileMask = '*.*'
      end>
    Options = []
    Left = 376
    Top = 248
  end
end
