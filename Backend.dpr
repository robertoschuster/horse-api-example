program Backend;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  Horse.Logger,
  Horse.Logger.Provider.Console,
  System.JSON,
  Windows,
  SysUtils,
  uDM in 'src\uDM.pas' {DM: TDataModule},
  uController.Base in 'src\uController.Base.pas',
  uController.Usuario in 'src\uController.Usuario.pas',
  uController.Cliente in 'src\uController.Cliente.pas';

const
  LOG_FORMAT = '${time} | ${request_method} ${request_path_info} ${response_status} ${response_content_length}bytes ${request_clientip} ${request_user_agent} ${request_version}';

procedure OnCreate;
begin
  DM := TDM.Create(nil);
  ControllerUsuario := TControllerUsuario.Create;

  // Logger
  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderConsole.New(THorseLoggerConsoleConfig.New
      .SetLogFormat(LOG_FORMAT))
  );
end;

procedure OnDestroy;
begin
  FreeAndNil(ControllerUsuario);
  FreeAndNil(DM);
end;

function ConsoleEventProc(CtrlType: DWORD): BOOL; stdcall;
begin
  if (CtrlType = CTRL_CLOSE_EVENT) then
  begin
    OnDestroy;
  end;

  Result := True;
end;

procedure StartAPI;
begin
  // Middlewares
  THorse.Use(THorseLoggerManager.HorseCallback());
  THorse.Use(Jhonson());

  // Users
  THorse.Get('/users', ControllerUsuario.Index);
  THorse.Post('/users', ControllerUsuario.Store);
  THorse.Put('/users/:id', ControllerUsuario.Update);
  THorse.Delete('/users/:id', ControllerUsuario.Delete);

  // Cliente
  THorse.Get('/customers', ControllerCliente.Index);
  THorse.Post('/customers', ControllerCliente.Store);
  THorse.Put('/customers/:id', ControllerCliente.Update);
  THorse.Delete('/customers/:id', ControllerCliente.Delete);

  THorse.Listen(9000);
end;

begin
  SetConsoleCtrlHandler(@ConsoleEventProc, True);
  OnCreate;

  StartAPI;
end.

