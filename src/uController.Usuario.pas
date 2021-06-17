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
    raise EHorseException.Create('O parâmetro "name" é obrigatório.');
  if not Assigned(Body.Values['email']) then
    raise EHorseException.Create('O parâmetro "email" é obrigatório.');

  //------------------------------------------------------------------------------
  // Valida duplicidades
  //------------------------------------------------------------------------------
  if DM.cdsUsuario.Locate('NOME', Body.Values['name'].Value, []) then
    raise EHorseException.Create('Já existe um usuário com este nome.');

  if DM.cdsUsuario.Locate('EMAIL', Body.Values['email'].Value, []) then
    raise EHorseException.Create('Já existe um usuário com este e-mail.');

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
  Id: Integer;
  Body: TJSONObject;
begin
  Id := Req.Params.Items['id'].ToInteger;
  Body := Req.Body<TJSONObject>;

  //------------------------------------------------------------------------------
  // Valida
  //------------------------------------------------------------------------------
  if not DM.cdsUsuario.Locate('ID', Id, []) then
    raise EHorseException.Create('Usuário não encontrado.');

  //------------------------------------------------------------------------------
  // Salva
  //------------------------------------------------------------------------------
  DM.cdsUsuario.Edit;
  if Assigned(Body.Values['name']) then
    DM.cdsUsuario.FieldByName('NOME').AsString := Body.Values['name'].Value;
  if Assigned(Body.Values['email']) then
    DM.cdsUsuario.FieldByName('EMAIL').AsString := Body.Values['email'].Value;
  DM.cdsUsuario.FieldByName('DATE_UPDATE').AsDateTime := Now;
  DM.cdsUsuario.Post;

  Salvar;

  Res.Status(200);
end;

procedure TControllerUsuario.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Id: Integer;
begin
  Id := Req.Params.Items['id'].ToInteger;

  //------------------------------------------------------------------------------
  // Valida
  //------------------------------------------------------------------------------
  if not DM.cdsUsuario.Locate('ID', Id, []) then
    raise EHorseException.Create('Usuário não encontrado.');

  //------------------------------------------------------------------------------
  // Salva
  //------------------------------------------------------------------------------
  DM.cdsUsuario.Delete;
  Salvar;

  Res.Status(200);
end;

end.
