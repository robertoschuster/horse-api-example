unit uController.Base;

interface

uses
  DB,
  DBClient,
  Classes,
  uDM;

type
  TControllerBase = class
  public
    procedure Salvar;
  end;

implementation

{ TControllerBase }

procedure TControllerBase.Salvar;
begin
  DM.cdsUsuario.SaveToFile('cdsUsuario.xml', dfXML);
  DM.cdsCliente.SaveToFile('cdsCliente.xml', dfXML);
end;


end.
