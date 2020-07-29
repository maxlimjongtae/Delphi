object ScriptView: TScriptView
  Left = 0
  Top = 0
  Caption = 'ScriptView'
  ClientHeight = 849
  ClientWidth = 925
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button: TButton
    Left = 842
    Top = 782
    Width = 75
    Height = 58
    Caption = 'Run'
    TabOrder = 0
    OnClick = ButtonClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 925
    Height = 777
    Align = alTop
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 224
      Height = 775
      Align = alLeft
      Lines.Strings = (
        'var a: Integer;'
        'var b: Integer = 10;')
      TabOrder = 0
      OnChange = Memo1Change
    end
    object Memo2: TMemo
      Left = 231
      Top = 1
      Width = 693
      Height = 775
      Align = alRight
      TabOrder = 1
    end
  end
end
