unit uController.Cliente;

interface

uses
  DB,
  DBClient,
  Classes,
  System.JSON,
  uDM,
  uController.Base,
  DataSet.Serialize,
  Horse;

type
  TControllerCliente = class(TControllerBase)
  public
    procedure Index(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure Store(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

var
  ControllerCliente: TControllerCliente;

implementation

uses
  System.SysUtils;



{ TControllerCliente }

procedure TControllerCliente.Index(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send<TJSONArray>(DM.cdsCliente.ToJSONArray());
end;

procedure TControllerCliente.Store(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Body: TJSONObject;

begin
  Body := Req.Body<TJSONObject>;

  //------------------------------------------------------------------------------
  // Valida parâmetros obrigatórios
  //------------------------------------------------------------------------------
  if not Assigned(Body.Values['name']) then
    raise EHorseException.Create('O parâmetro "name" é obrigatório.');
  if not Assigned(Body.Values['user_id']) then
    raise EHorseException.Create('O parâmetro "user_id" é obrigatório.');

  //------------------------------------------------------------------------------
  // Valida chave estrangeira
  //------------------------------------------------------------------------------
  if not DM.cdsUsuario.Locate('ID', Body.Values['user_id'].Value.ToInteger, []) then
    raise EHorseException.Create('Usuário não encontrado.');

  DM.cdsCliente.Append;
  DM.cdsCliente.FieldByName('NOME').AsString := Body.Values['name'].Value;
  DM.cdsCliente.FieldByName('USUARIO_ID').AsInteger := Body.Values['user_id'].Value.ToInteger;
  DM.cdsCliente.FieldByName('ENDERECO').AsString := Body.Values['address'].Value;
  DM.cdsCliente.FieldByName('DATE_CAD').AsDateTime := Now;
  DM.cdsCliente.Post;

  Salvar;

  Res.Status(200);
end;

procedure TControllerCliente.Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Id: Integer;
  Body: TJSONObject;
begin
  Id := Req.Params.Items['id'].ToInteger;
  Body := Req.Body<TJSONObject>;

  //------------------------------------------------------------------------------
  // Valida
  //------------------------------------------------------------------------------
  if not DM.cdsCliente.Locate('ID', Id, []) then
    raise EHorseException.Create('Cliente não encontrado.');

  //------------------------------------------------------------------------------
  // Salva
  //------------------------------------------------------------------------------
  DM.cdsCliente.Edit;
  if Assigned(Body.Values['name']) then
    DM.cdsCliente.FieldByName('NOME').AsString := Body.Values['name'].Value;

  if Assigned(Body.Values['user_id']) then
  begin
    if not DM.cdsUsuario.Locate('ID', Body.Values['user_id'].Value.ToInteger, []) then
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Usuário não encontrado'))).Status(400);
      Exit;
    end;
    DM.cdsCliente.FieldByName('USUARIO_ID').AsInteger := Body.Values['user_id'].Value.ToInteger;
  end;

  if Assigned(Body.Values['address']) then
    DM.cdsCliente.FieldByName('ENDERECO').AsString := Body.Values['address'].Value;

  DM.cdsCliente.FieldByName('DATE_UPDATE').AsDateTime := Now;
  DM.cdsCliente.Post;

  Salvar;

  Res.Status(200);
end;

procedure TControllerCliente.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Id: Integer;
begin
  Id := Req.Params.Items['id'].ToInteger;

  //------------------------------------------------------------------------------
  // Valida
  //------------------------------------------------------------------------------
  if not DM.cdsCliente.Locate('ID', Id, []) then
    raise EHorseException.Create('Cliente não encontrado.');

  //------------------------------------------------------------------------------
  // Salva
  //------------------------------------------------------------------------------
  DM.cdsCliente.Delete;
  Salvar;

  Res.Status(200);
end;

end.
