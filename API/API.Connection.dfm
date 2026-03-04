object DMConnection: TDMConnection
  OnCreate = DataModuleCreate
  Height = 300
  Width = 450
  PixelsPerInch = 144
  object FDConnection: TFDConnection
    LoginPrompt = False
    Left = 180
    Top = 120
  end
end
