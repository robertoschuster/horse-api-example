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
  lUser: TJSONObject;

begin
  lUser := Req.Body<TJSONObject>;

  DM.cdsUsuario.Append;
  DM.cdsUsuario.FieldByName('NOME').AsString := lUser.Values['name'].Value;
  DM.cdsUsuario.FieldByName('EMAIL').AsString := lUser.Values['email'].Value;
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
