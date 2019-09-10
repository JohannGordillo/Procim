unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, ExtCtrls,
  StdCtrls, LazFileUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnOpen: TBitBtn;
    btnBlue: TBitBtn;
    btnGreen: TBitBtn;
    btnRed: TBitBtn;
    btnReset: TBitBtn;
    btnMosaico: TBitBtn;
    Form1: TBitBtn;
    Image1: TImage;
    OpenDialog1: TOpenDialog;
    procedure btnOpenClick(Sender: TObject);
    procedure btnBlueClick(Sender: TObject);
    procedure btnGreenClick(Sender: TObject);
    procedure btnRedClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnMosaicoClick(Sender: TObject);
    procedure MosaicoSegmento(X0 : longint; Y0 : longint; X1: longint; Y1: longint);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

// Procedimiento que abre el una imagen desde un archivo
// Tambien se encarga de habilitar los botones de los filtros
procedure TForm1.btnOpenClick(Sender: TObject);
begin
  OpenDialog1.Execute;
  if (OpenDialog1.Files.Count = 1) and (FileExistsUTF8(OpenDialog1.FileName)) then
  begin
    Image1.Picture.LoadFromFile(OpenDialog1.FileName);
    btnRed.Enabled := true;
    btnGreen.Enabled := true;
    btnBlue.Enabled := true;
    btnMosaico.Enabled := true;
    btnReset.Enabled := true;
    Image1.Picture.Bitmap.Canvas
  end;
end;

// Procedimiento que describe el comportamiento del boton de filtro azul
procedure TForm1.btnBlueClick(Sender: TObject);
var
	i: longint;
        j: longint;
begin
  for i := 0 to (Image1.Picture.Bitmap.Canvas.Width - 1) do
  begin
    for j:=0 to (Image1.Picture.Bitmap.Canvas.Height - 1) do
    begin
      // Reemplaza el pixel con otro con la misma componente en azul, y cero en rojo y verde
      Image1.Picture.Bitmap.Canvas.Pixels[i,j] :=   RGBToColor(0, 0, Blue(Image1.Picture.Bitmap.Canvas.Pixels[i,j]));
    end;
  end;
end;

// Procedimiento que describe el comportamiento del boton de filtro verde
procedure TForm1.btnGreenClick(Sender: TObject);
var
	i: longint;
        j: longint;
begin
  for i := 0 to (Image1.Picture.Bitmap.Canvas.Width - 1) do
  begin
    for j:=0 to (Image1.Picture.Bitmap.Canvas.Height - 1) do
    begin
      // Reemplaza el pixel con otro con la misma componente en verde, y cero en rojo y azul
      Image1.Picture.Bitmap.Canvas.Pixels[i,j] :=   RGBToColor(0, Green(Image1.Picture.Bitmap.Canvas.Pixels[i,j]),0);
    end;
  end;
end;

// Procedimiento que describe el comportamiento del boton de filtro rojo
procedure TForm1.btnRedClick(Sender: TObject);
var
	i: longint;
        j: longint;
begin
  for i := 0 to (Image1.Picture.Bitmap.Canvas.Width - 1) do
  begin
    for j:=0 to (Image1.Picture.Bitmap.Canvas.Height - 1) do
    begin
      // Reemplaza el pixel con otro con la misma componente en rojo, y cero en verde y azul
      Image1.Picture.Bitmap.Canvas.Pixels[i,j] :=   RGBToColor(Red(Image1.Picture.Bitmap.Canvas.Pixels[i,j]),0,0);
    end;
  end;
end;

// Procedimiento que describe el comportamiento del boton Reset ("Restaurar")
// Solo vuelve a cargar la imagen abierta inicialmente
procedure TForm1.btnResetClick(Sender: TObject);
begin
  Image1.Picture.LoadFromFile(OpenDialog1.FileName);
  Image1.Picture.Bitmap.Canvas
end;

// Procedimiento que recibe el rango de un segmento (submatriz) de la imagen cargada
// obtiene el color promedio del segmento y se lo asigna a todos los pixeles en el
procedure TForm1.MosaicoSegmento(X0 : longint; Y0 : longint; X1: longint; Y1: longint);
var
        promR: Integer;
        promG: Integer;
        promB: Integer;
        i: longint;
        j: longint;
begin
  promR := 0;
  promG := 0;
  promB := 0;
  for i := X0 to X1 do
  begin
    for j:= Y0 to Y1 do
    begin
      promR := promR + Red(Image1.Picture.Bitmap.Canvas.Pixels[i,j]);
      promG := promG + Green(Image1.Picture.Bitmap.Canvas.Pixels[i,j]);
      promB := promB + Blue(Image1.Picture.Bitmap.Canvas.Pixels[i,j]);
    end;
  end;
  promR := Round(promR/((X1-X0)*(Y1-Y0)));
  promG := Round(promG/((X1-X0)*(Y1-Y0)));
  promB := Round(promB/((X1-X0)*(Y1-Y0)));
  for i := X0 to X1 do
  begin
    for j:= Y0 to Y1 do
    begin
      Image1.Picture.Bitmap.Canvas.Pixels[i,j] :=   RGBToColor(promR,promG,promB);
    end;
  end;
end;

// Procedimiento que describe el comportamiento del boton de filtro Mosaico
procedure TForm1.btnMosaicoClick(Sender: TObject);
var
        n: Integer;
        i: Integer;
        j: Integer;
        blockHeight: longint;
        blockWidth: longint;
begin
  Try
    // Pide al usuario introducen un numero n, que sera la dimension del mosaico (n x n)
    // y valida la entrada
    n := (StrToInt(InputBox('Introduce n',
    'El mosaico tendra forma de n x n', '3')));
    if n <= 0 then
    begin
       ShowMessage ('Numero invalido');
       exit;
    end;
    // Divide la imagen en segmentos y manda llamara MosaicoSegmento para cada uno
    blockHeight := round(Image1.Picture.Bitmap.Canvas.Height/n);
    blockWidth := round(Image1.Picture.Bitmap.Canvas.Width/n);
    for i := 0 to n - 1 do
    begin
      for j:= 0 to n - 1 do
      begin
        MosaicoSegmento(i*blockWidth,j*blockHeight,(i + 1)*blockWidth,(j + 1)*blockHeight);
      end;
    end;
  except
    On E : EConvertError do
      ShowMessage ('Numero invalido');
  end;
end;



end.

