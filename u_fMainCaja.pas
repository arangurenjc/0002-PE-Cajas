unit u_fMainCaja;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls, Data.DB, Vcl.DBGrids,
  Vcl.StdCtrls, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.Buttons, Vcl.VirtualImage, Vcl.ComCtrls, System.IniFiles;
type
  TfMainCajas = class(TForm)
    pnlCabecera: TPanel;
    strGridDetalles: TStringGrid;
    Panel1: TPanel;
    lblFechaActual: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cmbCajas: TComboBox;
    Panel2: TPanel;
    sbFiltrar: TSpeedButton;
    sbIngresar: TSpeedButton;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
    Shape1: TShape;
    sbEgresar: TSpeedButton;
    sbEliminar: TSpeedButton;
    sbEditar: TSpeedButton;
    SpeedButton6: TSpeedButton;
    sbImprimir: TSpeedButton;
    SpeedButton8: TSpeedButton;
    Shape2: TShape;
    Panel3: TPanel;
    Panel4: TPanel;
    vimMonedas: TVirtualImage;
    imcMonedas: TImageCollection;
    ProgressBar1: TProgressBar;
    Panel5: TPanel;
    Panel6: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cmbCajasChange(Sender: TObject);
    procedure sbIngresarClick(Sender: TObject);
    procedure sbEgresarClick(Sender: TObject);
  private
    procedure strGridDetalles_IniciarColumnas;
    procedure strGridDetalles_AjustarColumnas;
    procedure strGridDetallesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure iniciaComboCajas;
    function FormatearValor(ACol: Integer; const Valor: string): string;
    procedure obtenerPath;
  public
    { Public declarations }
  end;

var
  fMainCajas        : TfMainCajas;
  formularioActivo  : Boolean;
  RutaHAC,
  RutaNomina,
  RutaApp,
  RutaTmp           : string;


implementation

uses
  u_fRegistro;
{$R *.dfm}

procedure TfMainCajas.cmbCajasChange(Sender: TObject);
begin
  vimMonedas.ImageIndex := cmbCajas.ItemIndex ;

end;


function TfMainCajas.FormatearValor(ACol: Integer; const Valor: string): string;
begin
  // Formateo de valores según la columna
  case ACol of
    1: Result       := FormatDateTime('dd/mm/yyyy', StrToDateDef(Valor, 0)); // Columna FECHA
    6, 7, 8: Result := FormatFloat('#,##0.00', StrToFloatDef(Valor, 0)); // DEBITOS y CREDITOS
  else
    Result := Valor; // Sin formato
  end;
end;


procedure TfMainCajas.sbEgresarClick(Sender: TObject);
begin
   try
    fRegistro := TfRegistro.Create(Self);
    // Mostrar el formulario como modal o no modal
    fRegistro.Caption := 'Registro de Egresos';
    fRegistro.ShowModal;  // Si lo deseas modal (bloquea el formulario actual)
    // Form2.Show;     // Si lo deseas no modal (no bloquea el formulario actual)
  finally
    // Liberar el formulario de la memoria una vez cerrado
    fRegistro.Free;
  end;
end;

procedure TfMainCajas.sbIngresarClick(Sender: TObject);
begin

  try
    fRegistro := TfRegistro.Create(Self);
    // Mostrar el formulario como modal o no modal
    fRegistro.Caption := 'Registro de Ingresos';
    fRegistro.ShowModal;  // Si lo deseas modal (bloquea el formulario actual)
    // Form2.Show;     // Si lo deseas no modal (no bloquea el formulario actual)
  finally
    // Liberar el formulario de la memoria una vez cerrado
    fRegistro.Free;
  end;
end;


procedure TfMainCajas.strGridDetallesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  DisplayRect: TRect;
  s: string;
begin
  with strGridDetalles.Canvas do
  begin
    // Obtener el rectángulo de la celda a dibujar
    DisplayRect := Rect;
    InflateRect(DisplayRect, -2, -2);
    // Colorear la primera fila de verde
    if ARow = 0 then
    begin
      Brush.Color := RGB(52, 73, 94 );
      Font.Color  := clWhite;
      Font.Style  := [fsBold];
      Font.Size   := 8;
    end
    else
    begin
      // Alternar colores entre filas
      if Odd(ARow) then
        Brush.Color := clSilver  // Fila impar en gris claro
      else
        Brush.Color := clWhite;   // Fila par en blanco
    end;
    // Llenar la celda con el color de fondo
    FillRect(Rect);
    // Obtener el texto de la celda
    s := strGridDetalles.Cells[ACol, ARow];
    // Aplicar formato solo a las filas de datos (a partir de fila 1)
    if ARow > 0 then
    begin
      // Formato numérico para las columnas DEBITOS y CREDITOS
      if (ACol = 6) or (ACol = 7) or (ACol = 8) then
      begin
        s := FormatFloat('#,##0.00', StrToFloatDef(s, 0));
      end
      // Formato de fecha para la columna FECHA
      else if (ACol = 1) then
      begin
        s := FormatDateTime('dd/mm/yyyy', StrToDateDef(s, 0));
      end;
    end;
    // Alineación del texto
    if ARow = 0 then
    begin
      // Encabezado: centrado horizontal y vertical
      TextOut(DisplayRect.Left + (Rect.Width div 2) - (TextWidth(s) div 2),
              DisplayRect.Top + (Rect.Height div 2) - (TextHeight(s) div 2), s);
    end
    else
    begin
      // Alineación de columnas
      case ACol of
        1: // FECHA: centrado horizontal y vertical
        begin
          TextOut(DisplayRect.Left + (Rect.Width div 2) - (TextWidth(s) div 2),
                  DisplayRect.Top + (Rect.Height div 2) - (TextHeight(s) div 2), s);
        end;
        6, 7, 8: // DEBITOS y CREDITOS: alineados a la derecha
        begin
          TextOut(DisplayRect.Right - TextWidth(s) - 2,
                  DisplayRect.Top + (Rect.Height div 2) - (TextHeight(s) div 2), s);
        end;
        else // Otras columnas: alineadas a la izquierda
        begin
          TextOut(DisplayRect.Left + 2,
                  DisplayRect.Top + (Rect.Height div 2) - (TextHeight(s) div 2), s);
        end;
      end;
    end;
  end;
end;


procedure TfMainCajas.strGridDetalles_AjustarColumnas;
var
  anchoTotal: Integer;
begin
  anchoTotal := strGridDetalles.ClientWidth;
  with strGridDetalles do
  begin
    // Configurar columnas del TStringGrid
    ColWidths[0] := (anchoTotal * 2)  div 100;   // STATUS 5%
    ColWidths[1] := (anchoTotal * 9)  div 100;  // FECHA 10%
    ColWidths[2] := (anchoTotal * 9)  div 100;  // DOCUMENTO 10%
    ColWidths[3] := (anchoTotal * 4)  div 100;   // TIPO 5%
    ColWidths[4] := (anchoTotal * 18) div 100;  // BENEFICIARIO 15%
    ColWidths[5] := (anchoTotal * 28) div 100;  // CONCEPTO 25%
    ColWidths[6] := (anchoTotal * 10) div 100;  // DEBITOS 15%
    ColWidths[7] := (anchoTotal * 10) div 100;  // CREDITOS 15%
    ColWidths[8] := (anchoTotal * 10) div 100;  // CREDITOS 15%
  end;
end;


procedure TfMainCajas.strGridDetalles_IniciarColumnas;
begin
  with strGridDetalles do
  begin
    DefaultDrawing  := False;
    ColCount        := 9;
    RowCount        := 2;
    FixedRows       := 1;
    RowHeights[0]   := 25;  // Alto del encabezado
    RowHeights[1]   := 15;  // Alto de las filas de datos

    Cells[0, 0]     := 'ST';
    Cells[1, 0]     := 'FECHA';
    Cells[2, 0]     := 'DOCUMENTO';
    Cells[3, 0]     := 'TIPO';
    Cells[4, 0]     := 'BENEFICIARIO';
    Cells[5, 0]     := 'CONCEPTO';
    Cells[6, 0]     := 'DEBITOS';
    Cells[7, 0]     := 'CREDITOS';
    Cells[8, 0]     := 'SALDO';
  end;
end;


procedure TfMainCajas.FormCreate(Sender: TObject);
begin
  Self.Constraints.MinHeight  :=  Round(Screen.Height * 0.75);
  Self.Constraints.MinWidth   :=  Round(Screen.Width * 0.90);

  Self.Position               := poScreenCenter;
  Self.OnResize               := FormResize;
  lblFechaActual.Caption      := FormatDateTime('dd/mm/yyyy', now);

  strGridDetalles_IniciarColumnas;
  strGridDetalles_AjustarColumnas;
  strGridDetalles.OnDrawCell  := strGridDetallesDrawCell;
  formularioActivo            := True;
  iniciaComboCajas;
  obtenerPath;

end;


procedure TfMainCajas.FormResize(Sender: TObject);
begin
  if formularioActivo = True then
    strGridDetalles_AjustarColumnas;

  if Self.WindowState = wsNormal then
  begin
    // Si se restaura, volver a 75% de ancho y 90% de alto
    Self.Width  := Round(Screen.Width * 0.80);
    Self.Height := Round(Screen.Height * 0.75);
  end;

end;


procedure TfMainCajas.iniciaComboCajas;
begin
  cmbCajas.Items.Clear;

  // Agregar los elementos al ComboBox
  cmbCajas.Items.Add('Caja USD Dólares');
  cmbCajas.Items.Add('Caja VES Bolívares');
  // Seleccionar el primer elemento por defecto (opcional)
  cmbCajas.ItemIndex := -1;
end;

procedure TfMainCajas.obtenerPath;
var
  IniFile: TIniFile;
  ExecutablePath: string;
begin
  // Obtener la ruta del ejecutable
  ExecutablePath := ExtractFilePath(ParamStr(0));
  // Crear el objeto TIniFile para leer el archivo INI
  IniFile := TIniFile.Create(ExecutablePath + 'config.ini');
  try
    // Leer las rutas de la sección [RUTAS]
    RutaHAC     := IniFile.ReadString('RUTAS', 'HAC', '');
    RutaNomina  := IniFile.ReadString('RUTAS', 'NOMINA', '');
    RutaApp     := IniFile.ReadString('RUTAS', 'APP', '');
    RutaTmp     := IniFile.ReadString('RUTAS', 'TMP', '');
  finally
    // Liberar el objeto IniFile
    IniFile.Free;
  end;

end;

end.
