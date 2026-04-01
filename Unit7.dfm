object FormIterative: TFormIterative
  Left = 19
  Top = 582
  Width = 380
  Height = 145
  BorderIcons = [biSystemMenu]
  Caption = 'Iterative'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 0
    Top = 0
    Width = 372
    Height = 111
    Align = alClient
    ColCount = 4
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentFont = False
    PopupMenu = PopupMenu1
    TabOrder = 0
    ColWidths = (
      23
      67
      32
      433)
  end
  object PopupMenu1: TPopupMenu
    Left = 288
    Top = 16
    object Savetofile1: TMenuItem
      Caption = 'Save to file'
      OnClick = Savetofile1Click
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.txt'
    Filter = 'Text File|*.txt'
    InitialDir = '.'
    Left = 200
    Top = 48
  end
end
