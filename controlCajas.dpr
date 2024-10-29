program controlCajas;

uses
  Vcl.Forms,
  u_fMainCaja in 'u_fMainCaja.pas' {fMainCajas},
  Vcl.Themes,
  Vcl.Styles,
  u_fRegistro in 'u_fRegistro.pas' {fRegistro},
  u_DMControl in 'u_DMControl.pas' {dataModulo: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Sky');
  Application.CreateForm(TdataModulo, dataModulo);
  Application.CreateForm(TfMainCajas, fMainCajas);
  Application.Run;
end.
