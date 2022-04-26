object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 143
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnExecuteSuccess: TButton
    Left = 8
    Top = 8
    Width = 129
    Height = 25
    Caption = 'btnExecuteSuccess'
    TabOrder = 0
    OnClick = btnExecuteSuccessClick
  end
  object btnShowForm: TButton
    Left = 520
    Top = 8
    Width = 107
    Height = 25
    Caption = 'btnShowForm'
    TabOrder = 1
    OnClick = btnShowFormClick
  end
  object btnExecuteError: TButton
    Left = 8
    Top = 39
    Width = 129
    Height = 25
    Caption = 'btnExecuteError'
    TabOrder = 2
    OnClick = btnExecuteErrorClick
  end
end
