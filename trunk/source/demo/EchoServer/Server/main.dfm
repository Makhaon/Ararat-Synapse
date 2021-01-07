object fmain: Tfmain
  Left = 0
  Top = 0
  Caption = 'Server'
  ClientHeight = 355
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 35
    Height = 13
    Caption = #1040#1076#1088#1077#1089':'
  end
  object lbAddress: TLabel
    Left = 53
    Top = 8
    Width = 56
    Height = 13
    Caption = 'lbAddress'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 178
    Top = 326
    Width = 75
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object memLog: TMemo
    Left = 8
    Top = 24
    Width = 417
    Height = 300
    Lines.Strings = (
      '')
    TabOrder = 1
  end
end
