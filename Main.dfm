object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Kullan'#305'lan Portlar'#305' Listele'
  ClientHeight = 335
  ClientWidth = 402
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 224
    Top = 0
    Height = 335
    Align = alRight
    ExplicitLeft = 232
    ExplicitTop = 8
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 224
    Height = 335
    Align = alClient
    TabOrder = 0
    object btnRefresh: TButton
      Left = 1
      Top = 309
      Width = 222
      Height = 25
      Align = alBottom
      Caption = 'Yenile'
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object lvProcesses: TListView
      Left = 1
      Top = 1
      Width = 222
      Height = 308
      Align = alClient
      Columns = <
        item
          Caption = 'Ad'
          Width = 150
        end
        item
          Caption = 'PID'
          MaxWidth = 50
          MinWidth = 50
        end>
      ColumnClick = False
      ReadOnly = True
      RowSelect = True
      SortType = stText
      TabOrder = 1
      ViewStyle = vsReport
      OnChange = lvProcessesChange
    end
  end
  object pnlRight: TPanel
    Left = 227
    Top = 0
    Width = 175
    Height = 335
    Align = alRight
    TabOrder = 1
    object pnlCount: TPanel
      Left = 1
      Top = 309
      Width = 173
      Height = 25
      Align = alBottom
      BevelInner = bvLowered
      Caption = 'TCP: 0     UDP: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object lvPorts: TListView
      Left = 1
      Top = 1
      Width = 173
      Height = 308
      Align = alClient
      Columns = <
        item
          Caption = 'Kaynak'
        end
        item
          Caption = 'Hedef'
        end
        item
          Caption = 'Protokol'
          Width = 60
        end>
      ColumnClick = False
      ReadOnly = True
      RowSelect = True
      SortType = stData
      TabOrder = 1
      ViewStyle = vsReport
      OnCompare = lvPortsCompare
    end
  end
end
