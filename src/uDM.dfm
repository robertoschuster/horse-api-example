object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 173
  Width = 251
  object cdsUsuario: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 56
    Top = 16
  end
  object cdsCliente: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 144
    Top = 48
  end
end
