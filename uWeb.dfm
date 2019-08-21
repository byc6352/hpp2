object fWeb: TfWeb
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'fWeb'
  ClientHeight = 338
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object wb1: TWebBrowser
    Left = 0
    Top = 0
    Width = 651
    Height = 338
    Align = alClient
    TabOrder = 0
    OnNewWindow2 = wb1NewWindow2
    OnDocumentComplete = wb1DocumentComplete
    ExplicitLeft = 232
    ExplicitTop = 96
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C00000048430000EF2200000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel2: TPanel
    Left = 50
    Top = 296
    Width = 23
    Height = 17
    Caption = 'Panel2'
    TabOrder = 1
    Visible = False
    object wb2: TWebBrowser
      Left = 40
      Top = 21
      Width = 784
      Height = 351
      TabOrder = 0
      OnBeforeNavigate2 = wb2BeforeNavigate2
      ControlData = {
        4C00000007510000472400000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 176
    Top = 65520
  end
end
