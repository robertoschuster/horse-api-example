unit uDM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient;

type
  TDM = class(TDataModule)
    cdsUsuario: TClientDataSet;
    cdsCliente: TClientDataSet;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  // Usuários
  cdsUsuario.FieldDefs.Add('ID', ftAutoInc);
  cdsUsuario.FieldDefs.Add('NOME', ftString, 100);
  cdsUsuario.FieldDefs.Add('EMAIL', ftString, 100);
  cdsUsuario.FieldDefs.Add('DATE_CAD', ftDateTime);
  cdsUsuario.FieldDefs.Add('DATE_UPDATE', ftDateTime);
  cdsUsuario.CreateDataSet;

  // Clientes
  cdsCliente.FieldDefs.Add('ID', ftAutoInc);
  cdsCliente.FieldDefs.Add('USUARIO_ID', ftInteger);
  cdsCliente.FieldDefs.Add('NOME', ftString, 100);
  cdsCliente.FieldDefs.Add('ENDERECO', ftString, 500);
  cdsCliente.FieldDefs.Add('DATE_CAD', ftDateTime);
  cdsCliente.FieldDefs.Add('DATE_UPDATE', ftDateTime);
  cdsCliente.CreateDataSet;

  if FileExists('cdsUsuario.xml') then
    cdsUsuario.LoadFromFile('cdsUsuario.xml');

  if FileExists('cdsCliente.xml') then
    cdsUsuario.LoadFromFile('cdsCliente.xml');
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(cdsCliente);
  FreeAndNil(cdsUsuario);
end;

end.
