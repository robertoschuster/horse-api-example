unit uController.Usuario;

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
  TControllerUsuario = class(TControllerBase)
  public
    procedure Index(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure Store(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

var
  ControllerUsuario: TControllerUsuario;

implementation

uses
  System.SysUtils;



{ TControllerUsuario }

procedure TControllerUsuario.Index(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send<TJSONArray>(DM.cdsUsuario.ToJSONArray());
end;

procedure TControllerUsuario.Store(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Body: TJSONObject;

begin
  Body := Req.Body<TJSONObject>;

  //------------------------------------------------------------------------------
  // Valida parâmetros obrigatórios
  //------------------------------------------------------------------------------
  if not Assigned(Body.Values['name']) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'O parâmetro "name" é obrigatório.'))).Status(400);
    Exit;
  end;
  if not Assigned(Body.Values['email']) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'O parâmetro "email" é obrigatório.'))).Status(400);
    Exit;
  end;

  //------------------------------------------------------------------------------
  // Valida duplicidades
  //------------------------------------------------------------------------------
  if DM.cdsUsuario.Locate('NOME', Body.Values['name'].Value, []) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Já existe um usuário com este nome.'))).Status(400);
    Exit;
  end;
  if DM.cdsUsuario.Locate('EMAIL', Body.Values['email'].Value, []) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Já existe um usuário com este e-mail.'))).Status(400);
    Exit;
  end;

  //------------------------------------------------------------------------------
  // Salva
  //------------------------------------------------------------------------------
  DM.cdsUsuario.Append;
  DM.cdsUsuario.FieldByName('NOME').AsString := Body.Values['name'].Value;
  DM.cdsUsuario.FieldByName('EMAIL').AsString := Body.Values['email'].Value;
  DM.cdsUsuario.FieldByName('DATE_CAD').AsDateTime := Now;
  DM.cdsUsuario.Post;
  Salvar;

  Res.Status(200);
end;

procedure TControllerUsuario.Update(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Integer;
  lUser: TJSONObject;
begin
  lId := Req.Params.Items['id'].ToInteger;

  if not DM.cdsUsuario.Locate('ID', lId, []) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Usuário não encontrado'))).Status(400);
    Exit;
  end;

  lUser := Req.Body<TJSONObject>;

  DM.cdsUsuario.Edit;

  if Assigned(lUser.Values['name']) then
    DM.cdsUsuario.FieldByName('NOME').AsString := lUser.Values['name'].Value;

  if Assigned(lUser.Values['email']) then
    DM.cdsUsuario.FieldByName('EMAIL').AsString := lUser.Values['email'].Value;

  DM.cdsUsuario.FieldByName('DATE_UPDATE').AsDateTime := Now;
  DM.cdsUsuario.Post;

  Salvar;

  Res.Status(200);
end;

procedure TControllerUsuario.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  lId: Integer;
begin
  lId := Req.Params.Items['id'].ToInteger;

  if not DM.cdsUsuario.Locate('ID', lId, []) then
  begin
    Res.Send(TJSONObject.Create(TJSONPair.Create('error', 'Usuário não encontrado'))).Status(400);
    Exit;
  end;

  DM.cdsUsuario.Delete;
  Salvar;

  Res.Status(200);
end;

end.
