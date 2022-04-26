object frmSecond: TfrmSecond
  Left = 0
  Top = 0
  Caption = 'frmSecond'
  ClientHeight = 128
  ClientWidth = 190
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object btnExecuteSuccess: TButton
    Left = 24
    Top = 24
    Width = 137
    Height = 25
    Caption = 'btnExecuteSuccess'
    TabOrder = 0
    OnClick = btnExecuteSuccessClick
  end
  object btnExecuteError: TButton
    Left = 24
    Top = 55
    Width = 137
    Height = 25
    Caption = 'btnExecuteError'
    TabOrder = 1
    OnClick = btnExecuteErrorClick
  end
end
