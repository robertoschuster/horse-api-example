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
  lUser: TJSONObject;

begin
  lUser := Req.Body<TJSONObject>;

  if not DM.cdsUsuario.Locate('ID', lUser.Values['user_id'].Value.ToInteger, []) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Usuário não encontrado'))).Status(400);
    Exit;
  end;

  DM.cdsCliente.Append;
  DM.cdsCliente.FieldByName('NOME').AsString := lUser.Values['name'].Value;
  DM.cdsCliente.FieldByName('USUARIO_ID').AsInteger := lUser.Values['user_id'].Value.ToInteger;
  DM.cdsCliente.FieldByName('ENDERECO').AsString := lUser.Values['address'].Value;
  DM.cdsCliente.FieldByName('DATE_CAD').AsDateTime := Now;
  DM.cdsCliente.Post;

  Salvar;

  Res.Status(200);
end;

procedure TControllerCliente.Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Integer;
  lUser: TJSONObject;
begin
  lId := Req.Params.Items['id'].ToInteger;

  if not DM.cdsCliente.Locate('ID', lId, []) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Cliente não encontrado'))).Status(400);
    Exit;
  end;

  lUser := Req.Body<TJSONObject>;

  DM.cdsCliente.Edit;

  if Assigned(lUser.Values['name']) then
    DM.cdsCliente.FieldByName('NOME').AsString := lUser.Values['name'].Value;

  if Assigned(lUser.Values['user_id']) then
  begin
    if not DM.cdsUsuario.Locate('ID', lUser.Values['user_id'].Value.ToInteger, []) then
    begin
      Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Usuário não encontrado'))).Status(400);
      Exit;
    end;

    DM.cdsCliente.FieldByName('USUARIO_ID').AsInteger := lUser.Values['user_id'].Value.ToInteger;
  end;

  if Assigned(lUser.Values['address']) then
    DM.cdsCliente.FieldByName('ENDERECO').AsString := lUser.Values['address'].Value;

  DM.cdsCliente.FieldByName('DATE_UPDATE').AsDateTime := Now;
  DM.cdsCliente.Post;

  Salvar;

  Res.Status(200);
end;

procedure TControllerCliente.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Integer;
begin
  lId := Req.Params.Items['id'].ToInteger;

  if not DM.cdsCliente.Locate('ID', lId, []) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Cliente não encontrado'))).Status(400);
    Exit;
  end;

  DM.cdsCliente.Delete;
  Salvar;

  Res.Status(200);
end;

end.
