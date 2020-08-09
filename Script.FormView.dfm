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
  DesignSize = (
    925
    849)
  PixelsPerInch = 96
  TextHeight = 13
  object Button: TButton
    Left = 842
    Top = 783
    Width = 75
    Height = 58
    Anchors = [akRight, akBottom]
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
        'var b: Integer = 10;'
        'var c: string = '#39'asdfasdf'#39';'
        'var d: string;'
        'var e: Integer;'
        ''
        'a = 10;'
        'b = 5;'
        ''
        'd = c + '#39'asdf'#39';'
        'e = a + b;'
        ''
        'Write(c);'
        'Write('#39' = '#39');'
        'WriteLn('#39#39');')
      TabOrder = 0
      OnKeyDown = Memo1KeyDown
    end
    object Memo2: TMemo
      Left = 225
      Top = 1
      Width = 699
      Height = 775
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
end
