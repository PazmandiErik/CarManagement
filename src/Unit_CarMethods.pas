unit Unit_CarMethods;

interface

uses
  FMX.Layouts, FMX.Types, System.Classes, FMX.Objects, FMX.Controls, FMX.StdCtrls, FMX.ListBox, SysUtils,
  FMX.Dialogs, Data.SqlExpr;

procedure SwitchToImages(favid: integer);

type
  TCarRecord = class(TGridLayout)
    constructor Create(AParent: TFMXObject;_id,_brand,_model,_year,_colour,_fuel: string); reintroduce;
    procedure ButtonClickDelete(Sender: TObject);
    procedure ButtonClickImages(Sender: TObject);
    procedure ExitImages();
  protected
    text_id: TText;
    text_brand: TText;
    text_model: TText;
    text_year: TText;
    text_colour: TText;
    text_fuel: TText;
    button_delete: TButton;
    button_images: TButton;
  end;

  TBrandRecord = class(TGridLayout)
    constructor Create(AParent: TFMXObject; _name: string); reintroduce;
  protected
    text_name: TText;
  end;

var
  carArray: array of TCarRecord;
  brandArray: array of TBrandRecord;
  imageArray: array of TImage;

implementation

uses Unit_Login, Unit_Main, Unit_AuxiliaryFunctions;

{$REGION 'CarRecord - Constructor'}
constructor TCarRecord.Create(AParent: TFMXObject;_id,_brand,_model,_year,_colour,_fuel: string);
begin
  // Create grid
  inherited Create(AParent);
  with Self do begin
    Align := TAlignLayout.Top;
    Height := 32;
    ItemHeight := 32;
    ItemWidth := 146;
    Parent := AParent;
    Orientation := TOrientation.Horizontal;
    Margins.Top := 5;
    Margins.Bottom := 5;
    HitTest := False;
  end;

  // ID
  text_id := TText.Create(Self);
  text_id.Parent := Self;
  text_id.Text := _id;

  // Brand
  text_brand := TText.Create(Self);
  text_brand.Parent := Self;
  text_brand.Text := _brand;

  // Model
  text_model := TText.Create(Self);
  text_model.Parent := Self;
  text_model.Text := _model;

  // Year
  text_year := TText.Create(Self);
  text_year.Parent := Self;
  text_year.Text := _year;

  // Colour
  text_colour := TText.Create(Self);
  text_colour.Parent := Self;
  text_colour.Text := _colour;

  // Fuel
  text_fuel := TText.Create(Self);
  text_fuel.Parent := Self;
  text_fuel.Text := _fuel;

  // Button - delete
  button_delete := TButton.Create(Self);
  button_delete.Parent := Self;
  button_delete.Text := 'Delete';
  button_delete.Margins.Left := 40;
  button_delete.Margins.Right := 40;
  button_delete.Tag := StrToInt(_id);
  button_delete.OnClick := ButtonClickDelete;

  // Button - images
  button_images := TButton.Create(Self);
  button_images.Parent := Self;
  button_images.Text := 'Images';
  button_images.Margins.Left := 40;
  button_images.Margins.Right := 40;
  button_images.Tag := StrToInt(_id);
  button_images.OnClick := ButtonClickImages;

  SetLength(carArray, Length(carArray)+1);
  carArray[Length(carArray)-1] := Self;

end;
{$ENDREGION}
{$REGION 'CarRecord - Delete button click'}
procedure TCarRecord.ButtonClickDelete(Sender: TObject);
begin
  Car_DeleteFavourite(TButton(Sender).Tag);
  Form_Main.ListFavouriteCars();
end;
{$ENDREGION}
{$REGION 'CarRecord - Images button click'}
procedure TCarRecord.ButtonClickImages(Sender: TObject);
begin
  SwitchToImages(TButton(Sender).Tag);
end;
{$ENDREGION}
{$REGION 'Switch to Images'}
procedure SwitchToImages(favid: integer);
var
  sqlQuery_images: TSQLQuery;
  i: integer;
  fooImage: TImage;
begin
  Form_Main.Lay_Cars_Images.Visible := True;
  Form_Main.Lay_Cars_Content.Visible := False;
  Form_Main.Lay_Cars_Add.Visible := False;

  Form_Main.Lay_Cars_Images.Tag := favid;

  // Connect to database
  if Form_Login.SQL_Login.Connected then
    Form_Login.SQL_Login.Close;
  try
    Form_Login.SQL_Login.Open;
  except
    on E: Exception do begin
      ShowMessage('Could not connect to database: ' + E.Message);
      Exit();
    end;
  end;

  // Free previous images
  for fooImage in imageArray do
    fooImage.Free;
  SetLength(imageArray, 0);

  // Retrieve images
  sqlQuery_images := TSQLQuery.Create(Form_Main);
  sqlQuery_images.SQLConnection := Form_Login.SQL_login;
  sqlQuery_images.SQL.Text :=
    'SELECT image_path FROM car_images WHERE favourite_id = ' + IntToStr(favid);
  sqlQuery_images.Open();
  for i := 1 to sqlQuery_images.RecordCount do begin
    fooImage := TImage.Create(Form_Main.SB_Cars_Images);
    SetLength(imageArray, Length(imageArray)+1);
    imageArray[Length(imageArray)-1] := fooImage;
    with fooImage do begin
      Parent := Form_Main.SB_Cars_Images;
      Align := TAlignLayout.Top;
      Width := 600;
      Height := 600;
      Bitmap.LoadFromFile(sqlQuery_images.FieldByName('image_path').Value);
    end;

  end;

end;
{$ENDREGION}
{$REGION 'CarRecord - Exit Images'}
procedure TCarRecord.ExitImages;
begin
  Form_Main.Lay_Cars_Content.Visible := True;
  Form_Main.Lay_Cars_Add.Visible := True;
  Form_Main.Lay_Cars_Images.Visible := False;
end;
{$ENDREGION}

{$REGION 'BrandRecord - Constructor'}
constructor TBrandRecord.Create(AParent: TFMXObject; _name: string);
begin
  // Create grid
  inherited Create(AParent);
  with Self do begin
    Align := TAlignLayout.Top;
    Height := 32;
    ItemHeight := 32;
    ItemWidth := 540;
    Parent := AParent;
    Orientation := TOrientation.Vertical;
    Margins.Top := 5;
    Margins.Bottom := 5;
    HitTest := False;
  end;

  // Text
  text_name := TText.Create(Self);
  text_name.Parent := Self;
  text_name.Text := _name;

  // Store reference
  SetLength(brandArray, Length(brandArray)+1);
  brandArray[Length(brandArray)-1] := Self;

end;
{$ENDREGION}



end.
