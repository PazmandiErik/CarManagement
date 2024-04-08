unit Unit_Main;

interface

{$REGION 'Units'}
uses
  Unit_Login, Unit_UserMethods, Unit_AuxiliaryFunctions, Unit_CarMethods, Unit_RequestMethods,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, Data.SQLExpr,
  FMX.ListBox, FMX.Edit, FMX.ComboEdit, FMX.EditBox, FMX.SpinBox;
{$ENDREGION}
{$REGION 'Type - Form'}
type
  TForm_Main = class(TForm)
    Lay_SideMenu: TLayout;
    Lay_Content: TLayout;
    Rect_Content: TRectangle;
    Rect_SideMenu: TRectangle;
    Btn_Menu_Users: TButton;
    Lay_AdminMenu: TLayout;
    Lay_UserMenu: TLayout;
    Btn_Menu_Favourites: TButton;
    Btn_Menu_Logout: TButton;
    Btn_Menu_Brands: TButton;
    Btn_Menu_Requests: TButton;
    Lay_Users: TLayout;
    Lay_Brands: TLayout;
    Lay_Requests: TLayout;
    Lay_NewRequest: TLayout;
    Lay_Cars: TLayout;
    Text_Account_Title: TText;
    Text_Brands_Title: TText;
    Text_Cars_Title: TText;
    Text_Requests_Title: TText;
    Text_Users_Title: TText;
    Lay_Users_Content: TLayout;
    Lay_Users_ColumnTitles: TGridLayout;
    Text_Users_Title_Name: TText;
    Text_Users_Title_Rights: TText;
    SB_Users_Content: TScrollBox;
    Text_Users_Title_Active: TText;
    Text_Users_Title_LoginAttempts: TText;
    Text_Users_Title_UpForDelete: TText;
    Lay_Users_Interface: TLayout;
    Btn_Users_New: TButton;
    Text_Users_Title_Empty1: TText;
    Text_Users_Title_Empty2: TText;
    Lay_Users_Register: TLayout;
    Rect_Register_Content: TRectangle;
    Text_Register_Title: TText;
    Edt_Register_Username: TEdit;
    Btn_Register: TButton;
    Edt_Register_Password: TEdit;
    Edt_Register_PasswordAgain: TEdit;
    Edt_Register_FullName: TEdit;
    Combo_Register_Rights: TComboBox;
    Lay_Cars_Content: TLayout;
    SB_Cars_Content: TScrollBox;
    Lay_Cars_ColumnTitles: TGridLayout;
    Text_Cars_Title_Id: TText;
    Text_Cars_Title_Brand: TText;
    Text_Cars_Title_Model: TText;
    Text_Cars_Title_Year: TText;
    Text_Cars_Title_Colour: TText;
    Text_Cars_Title_Fuel: TText;
    Text_Cars_Title_Empty1: TText;
    Lay_Cars_Add: TLayout;
    Text_Cars_Add_Tittle: TText;
    Lay_Cars_Add_Content: TLayout;
    Combo_Cars_Add_Brand: TComboBox;
    ComboEdt_Cars_Add_Model: TComboEdit;
    Spin_Cars_Add_Year: TSpinBox;
    Edt_Cars_Add_Color: TEdit;
    Combo_Cars_Add_Fuel: TComboBox;
    Btn_Cars_AddNew: TButton;
    Lay_Brands_Content: TLayout;
    Text_Brands_Left_Title: TText;
    Lay_Brands_Content_Left: TLayout;
    Lay_Brands_Content_Right: TLayout;
    Edt_Brands_AddNew: TEdit;
    SB_Brands: TScrollBox;
    Btn_Brands_AddNew: TButton;
    Lay_Brands_Right_Item1: TLayout;
    Btn_Menu_NewRequest: TButton;
    Lay_NR_Content: TLayout;
    Lay_NR_RequestPanel: TLayout;
    Combo_NR_Type: TComboBox;
    Edt_NR_BrandName: TEdit;
    Btn_NR_Submit: TButton;
    CB_NR_Cons: TCheckBox;
    Lay_Requests_Content: TLayout;
    SB_Requests: TScrollBox;
    Lay_Requests_ColumnTitles: TGridLayout;
    Text_Request_Title_Name: TText;
    Text_Request_Title_Message: TText;
    Text_Request_Title_Empty1: TText;
    Text_Cars_Title_Empty2: TText;
    Lay_Cars_Images: TLayout;
    Lay_Cars_Images_Upload: TLayout;
    Btn_Cars_Images_Upload: TButton;
    SB_Cars_Images: TScrollBox;
    procedure Btn_Menu_LogoutClick(Sender: TObject);
    procedure Btn_Menu_BrandsClick(Sender: TObject);
    procedure Btn_Menu_UsersClick(Sender: TObject);
    procedure Btn_Menu_RequestsClick(Sender: TObject);
    procedure Btn_Menu_NewRequestClick(Sender: TObject);
    procedure Btn_Menu_FavouritesClick(Sender: TObject);
    procedure Btn_Users_NewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Btn_RegisterClick(Sender: TObject);
    procedure Combo_Cars_Add_BrandChange(Sender: TObject);
    procedure Btn_Cars_AddNewClick(Sender: TObject);
    procedure Btn_Brands_AddNewClick(Sender: TObject);
    procedure Combo_NR_TypeChange(Sender: TObject);
    procedure Btn_NR_SubmitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Btn_Cars_Images_UploadClick(Sender: TObject);
  private
    procedure SwitchToMenu(target: TLayout);
    procedure ListCarBrands(target: TComboBox); overload;
    procedure ListCarBrands(target: TScrollBox); overload;
    procedure ListModelsForBrand(target: TComboEdit; brand: string);
    procedure ListRequests();
  public
    activeUser: string;
    procedure ListUsers();
    procedure ListFavouriteCars();
    procedure UpdateRequestsMenuButton();
  end;
{$ENDREGION}
{$REGION 'Global variables'}
var
  Form_Main: TForm_Main;
{$ENDREGION}

implementation

{$R *.fmx}

{$REGION 'Form - OnClose'}
procedure TForm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form_Login.Close();
end;
{$ENDREGION}
{$REGION 'Form - OnCreate'}
procedure TForm_Main.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to Combo_Register_Rights.Count-1 do begin
    Combo_Register_Rights.ListItems[i].StyledSettings := [];
    Combo_Register_Rights.ListItems[i].Font.Size := 24;
  end;
end;
{$ENDREGION}

{$REGION 'UI - Button Click - Menu - Logout'}
procedure TForm_Main.Btn_Menu_LogoutClick(Sender: TObject);
begin
  Form_Login.Lay_Index.Visible := True;
  Form_Login.Lay_Login.Visible := False;
  Form_Login.Lay_Register.Visible := False;
  Form_Login.Show();
  Form_Main.Hide();
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Menu - Requests'}
procedure TForm_Main.Btn_Menu_RequestsClick(Sender: TObject);
begin
  SwitchToMenu(Lay_Requests);
  ListRequests;
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Menu - Users'}
procedure TForm_Main.Btn_Menu_UsersClick(Sender: TObject);
begin
  Lay_Users_Content.Visible := True;
  Lay_Users_Register.Visible := False;
  SwitchToMenu(Lay_Users);
  ListUsers();
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Menu - New Request'}
procedure TForm_Main.Btn_Menu_NewRequestClick(Sender: TObject);
begin
  Combo_NR_Type.ItemIndex := 0;
  CB_NR_Cons.IsChecked := False;
  Edt_NR_BrandName.Text := '';
  SwitchToMenu(Lay_NewRequest);
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Menu - Brands'}
procedure TForm_Main.Btn_Menu_BrandsClick(Sender: TObject);
begin
  SwitchToMenu(Lay_Brands);
  ListCarBrands(SB_Brands);
  Edt_Brands_AddNew.Text := '';
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Menu - Cars'}
procedure TForm_Main.Btn_Menu_FavouritesClick(Sender: TObject);
begin
  SwitchToMenu(Lay_Cars);
  ListFavouriteCars();
  ListCarBrands(Combo_Cars_Add_Brand);
  ComboEdt_Cars_Add_Model.Items.Clear;
  ComboEdt_Cars_Add_Model.Text := '';
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Users - Register'}
procedure TForm_Main.Btn_RegisterClick(Sender: TObject);
var
  rightsStr: string;
begin
  rightsStr := Combo_Register_Rights.Items.Strings[Combo_Register_Rights.ItemIndex];
  if RegisterUser(Edt_Register_Username.Text, Edt_Register_FullName.Text, rightsStr, Edt_Register_Password.Text, Edt_Register_PasswordAgain.Text) = 0 then begin
    ShowMessage('User successfully registered!');
    Lay_Users_Content.Visible := True;
    Lay_Users_Register.Visible := False;
    ListUsers();
  end;
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Users - New'}
procedure TForm_Main.Btn_Users_NewClick(Sender: TObject);
begin
  Lay_Users_Register.Visible := True;
  Lay_Users_Content.Visible := False;
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Brands - New'}
procedure TForm_Main.Btn_Brands_AddNewClick(Sender: TObject);
begin
  if Edt_Brands_AddNew.Text.Length < 2 then
    ShowMessage('Please enter a longer brand name.')
  else
    Brand_AddNew(Edt_Brands_AddNew.Text);
  ListCarBrands(SB_Brands);
  Edt_Brands_AddNew.Text := '';
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Cars - New'}
procedure TForm_Main.Btn_Cars_AddNewClick(Sender: TObject);
begin
  if (Combo_Cars_Add_Brand.ItemIndex <> -1) and (Combo_Cars_Add_Fuel.ItemIndex <> -1) and (ComboEdt_Cars_Add_Model.Text.Length > 2) then begin
    Car_AddFavourite(
      activeUser,
      Combo_Cars_Add_Brand.Items.Strings[Combo_Cars_Add_Brand.ItemIndex],
      ComboEdt_Cars_Add_Model.Text,
      trunc(Spin_Cars_Add_Year.Value),
      Edt_Cars_Add_Color.Text,
      Combo_Cars_Add_Fuel.Items.Strings[Combo_Cars_Add_Fuel.ItemIndex]
    );
    ListFavouriteCars();
    ListCarBrands(Combo_Cars_Add_Brand);
    ComboEdt_Cars_Add_Model.Items.Clear;
    ComboEdt_Cars_Add_Model.Text := '';
  end else
    ShowMessage('Please fill all options to add a new favourite.');
end;
{$ENDREGION}
{$REGION 'UI - Button Click - Cars - Upload Image'}
procedure TForm_Main.Btn_Cars_Images_UploadClick(Sender: TObject);
var
  fileDialog: TOpenDialog;
  sqlQuery_image: TSQLQuery;
begin
{$IFDEF MSWINDOWS}
  fileDialog := TOpenDialog.Create(Form_Main);
  fileDialog.Filter := 'All Picture Files|*.jpg; *.png; *.bmp; *.jpeg';

  fileDialog.Execute;

  if fileDialog.Files.Count > 0 then begin
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

    // Create and execute query
    sqlQuery_image := TSQLQuery.Create(Form_Main);
    sqlQuery_image.SQLConnection := Form_Login.SQL_login;
    sqlQuery_image.SQL.Text :=
      'INSERT INTO car_images (favourite_id, image_path) VALUES (' +
      IntToStr(Lay_Cars_Images.Tag) + ', :prmPath)';
    sqlQuery_image.ParamCheck := True;
    sqlQuery_image.ParamByName('prmPath').AsString := fileDialog.Files[0];
    sqlQuery_image.ExecSQL();

    SwitchToImages(Lay_Cars_Images.Tag);
  end;
{$ENDIF}
end;
{$ENDREGION}
{$REGION 'UI - Button Click - New Request - Submit'}
procedure TForm_Main.Btn_NR_SubmitClick(Sender: TObject);
begin
  case Combo_NR_Type.ItemIndex of
    0: begin
      // New Brand
      if Edt_NR_BrandName.Text.Length < 2 then
        ShowMessage('Please enter a longer brand name!')
      else begin
        Request_Brand(activeUser, Edt_NR_BrandName.Text);
        ShowMessage('Brand requested.');
        SwitchToMenu(Lay_Cars);
        ListFavouriteCars();
        ListCarBrands(Combo_Cars_Add_Brand);
        ComboEdt_Cars_Add_Model.Items.Clear;
        ComboEdt_Cars_Add_Model.Text := '';
      end;
    end;
    1: begin
      // Delete Account
      if not CB_NR_Cons.IsChecked then
        ShowMessage('Please check the box stating you understand the consequences of deleting your account.')
      else begin
        Request_Delete(activeUser);
        ShowMessage('Account deletion successfully requested.');
        SwitchToMenu(Lay_Cars);
        ListFavouriteCars();
        ListCarBrands(Combo_Cars_Add_Brand);
        ComboEdt_Cars_Add_Model.Items.Clear;
        ComboEdt_Cars_Add_Model.Text := '';
      end;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'UI - OnChange - ComboBox - Cars - Add - Brand'}
procedure TForm_Main.Combo_Cars_Add_BrandChange(Sender: TObject);
begin
  ListModelsForBrand(ComboEdt_Cars_Add_Model, TComboBox(Sender).Items.Strings[TComboBox(Sender).ItemIndex]);
end;
{$ENDREGION}
{$REGION 'UI - OnChange - ComboBox - New Request - Type'}
procedure TForm_Main.Combo_NR_TypeChange(Sender: TObject);
begin
  case Combo_NR_Type.ItemIndex of
    0: begin
      Edt_NR_BrandName.Visible := True;
      CB_NR_Cons.Visible := False;
    end;
    1: begin
      CB_NR_Cons.Visible := True;
      Edt_NR_BrandName.Visible := False;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'UI - Switch menu'}
procedure TForm_Main.SwitchToMenu(target: TLayout);
begin
  ListRequests();
  UpdateRequestsMenuButton();
  Lay_Users.Visible := False;
  Lay_Brands.Visible := False;
  Lay_Requests.Visible := False;
  Lay_NewRequest.Visible := False;
  Lay_Cars.Visible := False;
  Lay_Cars_Images.Visible := False;
  Lay_Cars_Content.Visible := True;
  Lay_Cars_Add.Visible := True;

  target.Visible := True;
end;
{$ENDREGION}

{$REGION 'List users'}
procedure TForm_Main.ListUsers();
var
  sqlQuery_users: TSQLQuery;
  i: integer;
  usr_active: string;
  usr_canDelete: string;
  fooUser: TUserRecord;
begin
  // Free previous objects
  for fooUser in userArray do
    fooUser.Free;
  SetLength(userArray, 0);

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

  // Create and execute query
  sqlQuery_users := TSQLQuery.Create(Form_Main);
  sqlQuery_users.SQLConnection := Form_Login.SQL_login;
  sqlQuery_users.SQL.Text :=
    'SELECT * FROM users';
  sqlQuery_users.Open();

  for i := 1 to sqlQuery_users.RecordCount do begin
    // Convert active value to be user friendly
    if sqlQuery_users.FieldByName('active').Value = 0 then
      usr_active := 'inactive'
    else
      usr_active := 'active';

    // Convert value to be user friendly
    if sqlQuery_users.FieldByName('upfordelete').Value = 0 then
      usr_canDelete := 'False'
    else
      usr_canDelete := 'True';

    // Create user record object
    TUserRecord.Create(SB_Users_Content,
      sqlQuery_users.FieldByName('username').Value,
      sqlQuery_users.FieldByName('name').Value,
      sqlQuery_users.FieldByName('rights').Value,
      usr_active,
      sqlQuery_users.FieldByName('loginattempts').Value,
      usr_canDelete);
    sqlQuery_users.Next;
  end;
  sqlQuery_users.Close();

end;
{$ENDREGION}
{$REGION 'List favourite cars'}
procedure TForm_Main.ListFavouriteCars;
var
  sqlQuery_cars: TSQLQuery;
  i: integer;
  fooCar: TCarRecord;
begin
  // Free previous objects
  for fooCar in carArray do
    fooCar.Free;
  SetLength(carArray, 0);

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

  // Create and execute query
  sqlQuery_cars := TSQLQuery.Create(Form_Main);
  sqlQuery_cars.SQLConnection := Form_Login.SQL_login;
  sqlQuery_cars.SQL.Text :=
    'SELECT '+
    'car_favourites.id AS carId, car_favourites.car_year AS carYear, car_favourites.car_color AS carColor, '+
    'car_favourites.car_fuel AS carFuel, car_brands.name AS carBrand, car_models.name AS carModel ' +
    'FROM car_favourites INNER JOIN car_models ON car_favourites.car_model_id = car_models.id ' +
    'INNER JOIN car_brands ON car_models.brandid = car_brands.id ' +
    'WHERE username=''' + activeUser + ''' ORDER BY car_favourites.id DESC';

  sqlQuery_cars.Open();

  for i := 1 to sqlQuery_cars.RecordCount do begin
    // Create car record object
    TCarRecord.Create(SB_Cars_Content,
      sqlQuery_cars.FieldByName('carId').Value,
      sqlQuery_cars.FieldByName('carBrand').Value,
      sqlQuery_cars.FieldByName('carModel').Value,
      sqlQuery_cars.FieldByName('carYear').Value,
      sqlQuery_cars.FieldByName('carColor').Value,
      sqlQuery_cars.FieldByName('carFuel').Value
    );
    sqlQuery_cars.Next;
  end;
  sqlQuery_cars.Close();
end;
{$ENDREGION}
{$REGION 'List car brands - ComboBox'}
procedure TForm_Main.ListCarBrands(target: TComboBox);
var
  sqlQuery_cars: TSQLQuery;
  i: integer;
begin
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

  // Create and execute query
  sqlQuery_cars := TSQLQuery.Create(Form_Main);
  sqlQuery_cars.SQLConnection := Form_Login.SQL_login;
  sqlQuery_cars.SQL.Text :=
    'SELECT * FROM car_brands ORDER BY name';
  sqlQuery_cars.Open();

  target.OnChange := nil;
  target.Items.Clear;
  target.OnChange := Combo_Cars_Add_BrandChange;
  for i := 1 to sqlQuery_cars.RecordCount do begin
    target.Items.Add(sqlQuery_cars.FieldByName('name').Value);
    sqlQuery_cars.Next;
  end;
  sqlQuery_cars.Close();

end;
{$ENDREGION}
{$REGION 'List car brands - ScrollBox'}
procedure TForm_Main.ListCarBrands(target: TScrollBox);
var
  sqlQuery_brands: TSQLQuery;
  i: integer;
  fooBrand: TBrandRecord;
begin
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

  // Create and execute query
  sqlQuery_brands := TSQLQuery.Create(Form_Main);
  sqlQuery_brands.SQLConnection := Form_Login.SQL_login;
  sqlQuery_brands.SQL.Text :=
    'SELECT * FROM car_brands ORDER BY name';
  sqlQuery_brands.Open();

  // Free previous objects
  for fooBrand in brandArray do
    fooBrand.Free;
  SetLength(brandArray, 0);

  for i := 1 to sqlQuery_brands.RecordCount do begin
    TBrandRecord.Create(target,
      sqlQuery_brands.FieldByName('name').Value
    );

    sqlQuery_brands.Next;
  end;
  sqlQuery_brands.Close();
end;
{$ENDREGION}
{$REGION 'List models for brand'}
procedure TForm_Main.ListModelsForBrand(target: TComboEdit; brand: string);
var
  sqlQuery_cars: TSQLQuery;
  i: integer;
begin
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

  // Create and execute query
  sqlQuery_cars := TSQLQuery.Create(Form_Main);
  sqlQuery_cars.SQLConnection := Form_Login.SQL_login;
  sqlQuery_cars.SQL.Text :=
    'SELECT car_models.name AS modelName '+
    'FROM car_models INNER JOIN car_brands ON car_models.brandid = car_brands.id ' +
    'AND car_brands.name=''' + brand + ''' ORDER BY modelName';
  sqlQuery_cars.Open();

  target.Items.Clear;
  for i := 1 to sqlQuery_cars.RecordCount do begin
    try
      target.Items.Add(sqlQuery_cars.FieldByName('modelName').AsString);
    finally
      sqlQuery_cars.Next;
    end;

  end;
  sqlQuery_cars.Close();
end;
{$ENDREGION}
{$REGION 'List requests'}
procedure TForm_Main.ListRequests;
var
  sqlQuery_requests: TSQLQuery;
  i: integer;
  fooRequest: TRequestRecord;
  req_isread: string;
begin
  // Free previous objects
  for fooRequest in requestArray do
    fooRequest.Free;
  SetLength(requestArray, 0);

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

  // Create and execute query
  sqlQuery_requests := TSQLQuery.Create(Form_Main);
  sqlQuery_requests.SQLConnection := Form_Login.SQL_login;
  sqlQuery_requests.SQL.Text :=
    'SELECT requests.id AS reqID, requests.username AS userName, requests.message AS content, requests.isread AS isRead, users.name AS fullName '+
    'FROM requests INNER JOIN users ON requests.username = users.username ORDER BY requests.id DESC';
  sqlQuery_requests.Open();

  for i := 1 to sqlQuery_requests.RecordCount do begin
    // Convert value to be user friendly
    if sqlQuery_requests.FieldByName('isRead').Value = 0 then
      req_isread := 'False'
    else
      req_isread := 'True';

    // Create user record object
    TRequestRecord.Create(SB_Requests,
      sqlQuery_requests.FieldByName('reqID').AsInteger,
      sqlQuery_requests.FieldByName('userName').AsString,
      sqlQuery_requests.FieldByName('fullName').AsString,
      sqlQuery_requests.FieldByName('content').AsString,
      req_isread
    );
    sqlQuery_requests.Next;

  end;
  sqlQuery_requests.Close();

  UpdateRequestsMenuButton();

end;
{$ENDREGION}
{$REGION 'Update requests menu button'}
procedure TForm_Main.UpdateRequestsMenuButton();
var
  fooRequestRecord: TRequestRecord;
begin
  Btn_Menu_Requests.Tag := 0;
  for fooRequestRecord in requestArray do
    if not fooRequestRecord.isread then
      Btn_Menu_Requests.Tag := Btn_Menu_Requests.Tag + 1;
  Btn_Menu_Requests.Text := 'Requests (' + IntToStr(Btn_Menu_Requests.Tag) + ')';

end;
{$ENDREGION}

end.
