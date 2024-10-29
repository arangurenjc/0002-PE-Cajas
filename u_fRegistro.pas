unit u_fRegistro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfRegistro = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fRegistro: TfRegistro;

implementation

{$R *.dfm}

procedure TfRegistro.FormCreate(Sender: TObject);
begin
  Self.Position := poScreenCenter;
end;

end.
