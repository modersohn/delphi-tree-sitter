object DTSLanguageForm: TDTSLanguageForm
  Left = 0
  Top = 0
  Caption = 'Language Info'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 220
    Top = 28
    Height = 413
    ExplicitLeft = 621
    ExplicitTop = 0
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 28
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      624
      28)
    object lblFieldCount: TLabel
      Left = 8
      Top = 8
      Width = 71
      Height = 15
      Caption = 'lblFieldCount'
    end
    object lblSymbolCount: TLabel
      Left = 229
      Top = 7
      Width = 51
      Height = 15
      Caption = 'lblVersion'
    end
    object lblVersion: TLabel
      Left = 560
      Top = 7
      Width = 51
      Height = 15
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'lblVersion'
    end
  end
  object sgSymbols: TStringGrid
    Left = 223
    Top = 28
    Width = 401
    Height = 413
    Align = alClient
    ColCount = 3
    DefaultColWidth = 130
    DefaultRowHeight = 18
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign]
    TabOrder = 2
  end
  object sgFields: TStringGrid
    Left = 0
    Top = 28
    Width = 220
    Height = 413
    Align = alLeft
    ColCount = 2
    DefaultColWidth = 120
    DefaultRowHeight = 18
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goFixedRowDefAlign]
    TabOrder = 0
  end
end
