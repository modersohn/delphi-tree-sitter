object DTSQueryForm: TDTSQueryForm
  Left = 0
  Top = 0
  Caption = 'Query'
  ClientHeight = 441
  ClientWidth = 764
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 0
    Top = 250
    Width = 764
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 120
    ExplicitWidth = 321
  end
  object Splitter2: TSplitter
    Left = 350
    Top = 253
    Height = 188
    ExplicitLeft = 376
    ExplicitTop = 165
    ExplicitHeight = 268
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 764
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblQueryState: TLabel
      Left = 83
      Top = 17
      Width = 3
      Height = 15
    end
    object btnExecute: TButton
      Left = 8
      Top = 13
      Width = 66
      Height = 25
      Caption = 'Execute'
      TabOrder = 0
      OnClick = btnExecuteClick
    end
  end
  object memQuery: TMemo
    Left = 0
    Top = 50
    Width = 764
    Height = 200
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object pnlPredicates: TPanel
    Left = 0
    Top = 253
    Width = 350
    Height = 188
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
    object pnlPredicatesToolbar: TPanel
      Left = 0
      Top = 0
      Width = 350
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 11
        Width = 41
        Height = 15
        Caption = 'Pattern:'
      end
      object cbPatternIdx: TComboBox
        Left = 56
        Top = 8
        Width = 57
        Height = 23
        Style = csDropDownList
        TabOrder = 0
        OnClick = cbPatternIdxClick
      end
    end
    object sgPredicateSteps: TStringGrid
      Left = 0
      Top = 41
      Width = 350
      Height = 147
      Align = alClient
      DefaultRowHeight = 18
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign]
      TabOrder = 1
    end
  end
  object pnlMatches: TPanel
    Left = 353
    Top = 253
    Width = 411
    Height = 188
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object pnlMatchesTop: TPanel
      Left = 0
      Top = 0
      Width = 411
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object lblMatch: TLabel
        Left = 219
        Top = 13
        Width = 3
        Height = 15
      end
      object btnMatchStart: TButton
        Left = 9
        Top = 9
        Width = 120
        Height = 25
        Caption = 'Start query cursor'
        Enabled = False
        TabOrder = 0
        OnClick = btnMatchStartClick
      end
      object btnMatchNext: TButton
        Left = 132
        Top = 9
        Width = 75
        Height = 25
        Caption = 'Next match'
        Enabled = False
        TabOrder = 1
        OnClick = btnMatchNextClick
      end
    end
    object sgMatchCaptures: TStringGrid
      Left = 0
      Top = 41
      Width = 411
      Height = 147
      Align = alClient
      ColCount = 2
      DefaultColWidth = 120
      DefaultRowHeight = 18
      RowCount = 1
      FixedRows = 0
      TabOrder = 1
      OnSelectCell = sgMatchCapturesSelectCell
    end
  end
end
