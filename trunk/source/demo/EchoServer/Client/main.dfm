object fmain: Tfmain
  Left = 0
  Top = 0
  Caption = 'Client'
  ClientHeight = 99
  ClientWidth = 424
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
    Top = 12
    Width = 44
    Height = 13
    Caption = 'IP-'#1072#1076#1088#1077#1089
  end
  object Label2: TLabel
    Left = 185
    Top = 12
    Width = 25
    Height = 13
    Caption = #1055#1086#1088#1090
  end
  object Label3: TLabel
    Left = 8
    Top = 45
    Width = 109
    Height = 13
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100' '#1085#1072' '#1089#1077#1088#1074#1077#1088
  end
  object Label4: TLabel
    Left = 8
    Top = 72
    Width = 76
    Height = 13
    Caption = #1054#1090#1074#1077#1090' '#1089#1077#1088#1074#1077#1088#1072
  end
  object lbResponseStr: TLabel
    Left = 123
    Top = 72
    Width = 82
    Height = 13
    Caption = 'lbResponseStr'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edAddress: TEdit
    Left = 58
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object edPort: TEdit
    Left = 214
    Top = 8
    Width = 39
    Height = 21
    NumbersOnly = True
    TabOrder = 1
    Text = '104'
  end
  object btnConnect: TButton
    Left = 257
    Top = 6
    Width = 75
    Height = 25
    Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100
    TabOrder = 2
    OnClick = btnConnectClick
  end
  object edRequestString: TEdit
    Left = 123
    Top = 41
    Width = 130
    Height = 21
    TabOrder = 3
    Text = 'edRequestString'
  end
  object dtnSend: TButton
    Left = 257
    Top = 39
    Width = 75
    Height = 25
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = dtnSendClick
  end
  object Button1: TButton
    Left = 338
    Top = 8
    Width = 75
    Height = 25
    Caption = #1054#1090#1082#1083#1102#1095#1080#1090#1100
    TabOrder = 5
    OnClick = Button1Click
  end
end
