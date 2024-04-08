unit Unit_AuxiliaryFunctions;

interface

{$WARN SYMBOL_DEPRECATED OFF}

uses System.Character, SysUtils, FMX.Dialogs, System.Hash, Data.SqlExpr ;

function IsSpecialCharacter(c: char): boolean;
function ValidateStringAsPassword(str: string): string;
function RegisterUser(userName, fullName, rights, password, passwordAgain: string): integer;

procedure Car_DeleteFavourite(id: integer);
procedure Car_AddFavourite(user,brand,model: string; year: integer; color,fuel:string);

procedure Brand_AddNew(newBrand: string);

procedure Request_Brand(user, brand: string);
procedure Request_Delete(user: string);

procedure User_Delete(user:string);

implementation

uses Unit_Login;

{$REGION 'Is Special Character'}
function IsSpecialCharacter(c: char): boolean;
begin
  if (IsSymbol(c)) or (not IsLetterOrDigit(c)) then
    Result := True
  else
    Result := False;
end;
{$ENDREGION}
{$REGION 'Validate string as password'}
function ValidateStringAsPassword(str: string): string;
const
  MIN_LENGTH = 8;
var
  hasSymbol, hasUpper, hasLower, hasNumber: boolean;
  charCount: integer;
  c: char;
begin
  // Initialize variables
  charCount := 0;
  hasSymbol := False;
  hasUpper := False;
  hasLower := False;
  hasNumber := False;

  // Iterate over characters in string
  for c in str do begin
    if not hasNumber then
      hasNumber := IsNumber(c);
    if not hasSymbol then
      hasSymbol := IsSpecialCharacter(c);
    if not hasUpper then
      hasUpper := IsUpper(c);
    if not hasLower then
      hasLower := IsLower(c);
    charCount := charCount + 1;
  end;

  // Return string based on missing flags
  if charCount < MIN_LENGTH then
    Result := 'Password must be at least 8 characters long.'
  else if not hasLower then
    Result := 'Password must contain at least 1 lower case character.'
  else if not HasUpper then
    Result := 'Password must contain at least 1 upper case character.'
  else if not HasNumber then
    Result := 'Password must contain at least 1 number.'
  else if not HasSymbol then
    Result := 'Password must contain at least 1 special character.'
  else
    Result := 'Valid';

end;
{$ENDREGION}
{$REGION 'Register user'}
function RegisterUser(userName: string; fullName: string; rights: string; password: string; passwordAgain:string): integer;
var
  fooString: string;
  sqlQuery_register: TSQLQuery;
begin
  // Validate field - username
  if userName.Length < 8 then begin
    ShowMessage('Username must be at least 8 characters long!');
    Exit(1);
  end;
  // Validate field - full name
  if fullName.Length < 4 then begin
    ShowMessage('Full Name must be at least 8 characters long!');
    Exit(2);
  end;
  // Validate field - password
  fooString := ValidateStringAsPassword(password);
  if fooString <> 'Valid' then begin
    ShowMessage(fooString);
    Exit(3);
  end;
  // Validate field - password again
  if password <> passwordAgain then begin
    ShowMessage('The passwords do not match!');
    Exit(4);
  end;

  // Connect to database
  if Form_Login.SQL_Login.Connected then
    Form_Login.SQL_Login.Close;
  try
    Form_Login.SQL_Login.Open;
  except
    on E: Exception do begin
      ShowMessage('Could not connect to database: ' + E.Message);
      Exit(5);
    end;
  end;
  // Get Hash
  userName := THashMD5.GetHashString(LowerCase(userName));
  password := THashMD5.GetHashString(password);

  // Initialize query & check if user exists
  sqlQuery_register := TSQLQuery.Create(Form_Login);
  sqlQuery_register.SQLConnection := Form_Login.SQL_login;
  sqlQuery_register.SQL.Text :=
    'SELECT COUNT(*) AS recCount FROM users WHERE username = :prmUser';
  sqlQuery_register.ParamCheck := True;
  sqlQuery_register.ParamByName('prmUser').AsString := userName;
  sqlQuery_register.Open();
  if sqlQuery_register.FieldByName('recCount').Value <> 0 then begin
    ShowMessage('User already exists!');
    Exit(6);
  end;

  // Create user
  sqlQuery_register.Close;
  sqlQuery_register.SQL.Text :=
    'INSERT INTO users (username, password, rights, name, active) VALUES (:prmUserName, :prmPass, :prmRights, :prmName, 1)';
  sqlQuery_register.ParamCheck := True;
  sqlQuery_register.ParamByName('prmUserName').AsString := userName;
  sqlQuery_register.ParamByName('prmPass').AsString := password;
  sqlQuery_register.ParamByName('prmRights').AsString := rights;
  sqlQuery_register.ParamByName('prmName').AsString := fullName;
  sqlQuery_register.ExecSQL();

  Result := 0;
end;
{$ENDREGION}
{$REGION 'Delete favourite'}
procedure Car_DeleteFavourite(id: Integer);
var
  sqlQuery_cars: TSQLQuery;
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
  // Delete
  sqlQuery_cars := TSQLQuery.Create(Form_Login);
  sqlQuery_cars.SQLConnection := Form_Login.SQL_login;
  sqlQuery_cars.SQL.Text :=
    'DELETE FROM car_favourites WHERE id=''' + IntToStr(id) + '''';
  sqlQuery_cars.ExecSQL();
end;
{$ENDREGION}
{$REGION 'Add favourite'}
procedure Car_AddFavourite(user,brand,model: string; year: integer; color,fuel:string);
var
  sqlQuery_cars: TSQLQuery;
  modelID: integer;
  brandID: integer;
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

  // Check if model exists. // If not create it
  sqlQuery_cars := TSQLQuery.Create(Form_Login);
  sqlQuery_cars.SQLConnection := Form_Login.SQL_login;
  sqlQuery_cars.SQL.Text :=
    'SELECT COUNT(car_models.id) AS carCount, car_models.id AS modelID FROM car_models INNER JOIN car_brands ON car_models.brandid = car_brands.id '+
    'AND car_models.name=''' + model + ''' AND car_brands.name=''' + brand + '''';
  sqlQuery_cars.Open();

  if sqlQuery_cars.FieldByName('carCount').AsInteger <> 0 then
    // Model exists. Retrieve ID
    modelID := sqlQuery_cars.FieldByName('modelID').Value
  else begin
    // Model doesn't exist. Get brand ID
    sqlQuery_cars.Close();
    sqlQuery_cars.SQL.Text :=
      'SELECT id from car_brands WHERE name=''' + brand + '''';
    sqlQuery_cars.Open();
    try
      brandID := sqlQuery_cars.FieldByName('id').Value
    except
      ShowMessage('Could not add favourite! The brand does not exist.');
      Exit();
    end;
    // Create model
    sqlQuery_cars.Close();
    sqlQuery_cars.SQL.Text :=
      'INSERT INTO car_models (brandid, name) VALUES (:prmBrandId, :prmName)';
    sqlQuery_cars.ParamCheck := True;
    sqlQuery_cars.ParamByName('prmBrandId').AsInteger := brandID;
    sqlQuery_cars.ParamByName('prmName').AsString := model;
    sqlQuery_cars.ExecSQL(False);

    //Fetch ID of the newly created model
    sqlQuery_cars.SQL.Text :=
      'SELECT id FROM car_models WHERE brandid = :prmBrandId AND name = :prmName';
    sqlQuery_cars.ParamByName('prmBrandId').AsInteger := brandID;
    sqlQuery_cars.ParamByName('prmName').AsString := model;
    sqlQuery_cars.Open;
    modelID := sqlQuery_cars.FieldByName('id').Value;
  end;

  //Create favourite
  sqlQuery_cars.Close();
  sqlQuery_cars.SQL.Text :=
    'INSERT INTO car_favourites (car_model_id, username, car_year, car_color, car_fuel) VALUES (:prmModelId, :prmUser, :prmYear, :prmColor, :prmFuel)';
  sqlQuery_cars.ParamCheck := True;
  sqlQuery_cars.ParamByName('prmModelId').AsInteger := modelID;
  sqlQuery_cars.ParamByName('prmUser').AsString := user;
  sqlQuery_cars.ParamByName('prmYear').AsInteger := year;
  sqlQuery_cars.ParamByName('prmColor').AsString := color;
  sqlQuery_cars.ParamByName('prmFuel').AsString := fuel;
  sqlQuery_cars.ExecSQL(False);
end;
{$ENDREGION}
{$REGION 'Add new brand'}
procedure Brand_AddNew(newBrand: string);
var
  sqlQuery_brand: TSQLQuery;
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

  // Initialize query & check if brand exists
  sqlQuery_Brand := TSQLQuery.Create(Form_Login);
  sqlQuery_Brand.SQLConnection := Form_Login.SQL_login;
  sqlQuery_Brand.SQL.Text :=
    'SELECT COUNT(*) AS recCount FROM car_brands WHERE name = :prmName';
  sqlQuery_Brand.ParamCheck := True;
  sqlQuery_Brand.ParamByName('prmName').AsString := newBrand;
  sqlQuery_Brand.Open();
  if sqlQuery_Brand.FieldByName('recCount').Value <> 0 then begin
    ShowMessage('Brand already exists!');
    Exit();
  end;

  // Create brand
  sqlQuery_Brand.Close;
  sqlQuery_Brand.SQL.Text :=
    'INSERT INTO car_brands (name) VALUES (:prmName)';
  sqlQuery_Brand.ParamCheck := True;
  sqlQuery_Brand.ParamByName('prmName').AsString := newBrand;
  sqlQuery_Brand.ExecSQL();
end;
{$ENDREGION}
{$REGION 'Request - New brand'}
procedure Request_Brand(user, brand: string);
var
  sqlQuery_request: TSQLQuery;
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

  // Initialize & execute query
  sqlQuery_request := TSQLQuery.Create(Form_Login);
  sqlQuery_request.SQLConnection := Form_Login.SQL_login;
  sqlQuery_request.SQL.Text :=
    'INSERT INTO requests (username, message, isread) VALUES (:prmName, :prmMessage, 0)';
  sqlQuery_request.ParamCheck := True;
  sqlQuery_request.ParamByName('prmName').AsString := user;
  sqlQuery_request.ParamByName('prmMessage').AsString := 'Request for a new brand to be added: "' + brand + '"';
  sqlQuery_request.ExecSQL();
end;
{$ENDREGION}

{$REGION 'Request - Account deletion'}
procedure Request_Delete(user: string);
var
  sqlQuery_delete: TSQLQuery;
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

  // Initialize & execute query
  sqlQuery_delete := TSQLQuery.Create(Form_Login);
  sqlQuery_delete.SQLConnection := Form_Login.SQL_login;
  sqlQuery_delete.SQL.Text :=
    'UPDATE users SET `upfordelete` = 1 WHERE `username`=''' + user + '''';
  sqlQuery_delete.ExecSQL();

  // Insert into requests table
  sqlQuery_delete.SQL.Text :=
    'INSERT INTO requests (username, message, isread) VALUES (:prmName, :prmMessage, 0)';
  sqlQuery_delete.ParamCheck := True;
  sqlQuery_delete.ParamByName('prmName').AsString := user;
  sqlQuery_delete.ParamByName('prmMessage').AsString := 'The user has requested account deletion.';
  sqlQuery_delete.ExecSQL();
end;
{$ENDREGION}
{$REGION 'Delete User'}
procedure User_Delete(user: string);
var
  sqlQuery_delete: TSQLQuery;
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

  // Initialize & execute query
  sqlQuery_delete := TSQLQuery.Create(Form_Login);
  sqlQuery_delete.SQLConnection := Form_Login.SQL_login;
  sqlQuery_delete.SQL.Text :=
    'DELETE FROM users WHERE `username`=''' + user + '''';
  sqlQuery_delete.ExecSQL();

  // Remove requests for user
  sqlQuery_delete.SQL.Text :=
    'DELETE FROM requests WHERE `username`=''' + user + '''';
  sqlQuery_delete.ExecSQL();
end;
{$ENDREGION}


end.
