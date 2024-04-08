unit Unit_UserMethods;

interface

uses
  FMX.Layouts, FMX.Types, System.Classes, FMX.Objects, FMX.Controls, FMX.StdCtrls, FMX.ListBox, SysUtils,
  FMX.Dialogs, Data.SqlExpr, System.Hash;

procedure UpdateLoginAttempts(username: string);
procedure HandleAdminCreation();
procedure Login(userType, userName, userPass: string);

type
  TUserRecord = class(TGridLayout)
    constructor Create(AParent: TFMXObject; _username,_name,_rights,_status,_attempts,_delete: string); reintroduce;
    procedure Combo_RightsOnChange(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure UpdateUserRights(username, newRights: string);
    procedure UnlockUser(username: string);
    procedure UnlockButtonClick(Sender: TObject);
  private
    username: string;
  protected
    text_name: TText;
    combo_rights: TComboBox;
    text_status: TText;
    text_loginAttempts: TText;
    text_upForDelete: TText;
    button_unlock: TButton;
    button_delete: TButton;
  end;

var
  userArray: array of TUserRecord;

implementation

uses Unit_Main, Unit_Login, Unit_AuxiliaryFunctions;

{$REGION 'UserRecord - Constructor'}
constructor TUserRecord.Create(AParent: TFMXObject; _username,_name,_rights,_status,_attempts,_delete: string);
begin
  // Create grid
  inherited Create(AParent);
  with Self do begin
    Align := TAlignLayout.Top;
    Height := 32;
    ItemHeight := 32;
    ItemWidth := 165;
    Parent := AParent;
    Orientation := TOrientation.Horizontal;
    Margins.Top := 5;
    Margins.Bottom := 5;
    HitTest := False;
    username := _username;
  end;

  // Name
  text_name := TText.Create(Self);
  text_name.Parent := Self;
  text_name.Text := _name;

  // Rights: admin / user
  combo_rights := TComboBox.Create(Self);
  combo_rights.Parent := Self;
  combo_rights.Items.Add('user');
  combo_rights.Items.Add('admin');
  if _rights = 'admin' then
    combo_rights.ItemIndex := 1
  else
    combo_rights.ItemIndex := 0;
  combo_rights.Margins.Left := 40;
  combo_rights.Margins.Right := 40;
  combo_rights.OnChange := Combo_RightsOnChange;

  // Status: active / inactive
  text_status := TText.Create(Self);
  text_status.Parent := Self;
  text_status.Text := _status;

  // Number of login attempts
  text_loginAttempts := TText.Create(Self);
  text_loginAttempts.Parent := Self;
  text_loginAttempts.Text := _attempts;

  // Delete requested
  text_upForDelete := TText.Create(Self);
  text_upForDelete.Parent := Self;
  text_upForDelete.Text := _delete;

  // Button - unlock
  button_unlock := TButton.Create(Self);
  button_unlock.Parent := Self;
  button_unlock.Text := 'Unlock';
  if _attempts = '5' then
    button_unlock.Enabled := True
  else
    button_unlock.Enabled := False;
  button_unlock.Margins.Left := 40;
  button_unlock.Margins.Right := 40;
  button_unlock.OnClick := UnlockButtonClick;

  // Button - delete
  button_delete := TButton.Create(Self);
  button_delete.Parent := Self;
  button_delete.Text := 'Delete';
  if _delete = 'True' then
    button_delete.Enabled := True
  else
    button_delete.Enabled := False;
  button_delete.Margins.Left := 40;
  button_delete.Margins.Right := 40;
  button_delete.OnClick := DeleteButtonClick;
  button_delete.Hint := _username;

  SetLength(userArray, Length(userArray)+1);
  userArray[Length(userArray)-1] := Self;

end;
{$ENDREGION}
{$REGION 'UserRecord - Combo_Rights - OnChange'}
procedure TUserRecord.Combo_RightsOnChange(Sender: TObject);
begin
  UpdateUserRights(TUserRecord(TComboBox(Sender).Parent).username, TComboBox(Sender).Items.Strings[TComboBox(Sender).ItemIndex]);
end;
{$ENDREGION}
{$REGION 'UserRecord - Button Click - Delete'}
procedure TUserRecord.DeleteButtonClick(Sender: TObject);
begin
  User_Delete(TButton(Sender).Hint);
  Form_Main.ListUsers();
end;
{$ENDREGION}
{$REGION 'UserRecord - Button Click - Unlock'}
procedure TUserRecord.UnlockButtonClick(Sender: TObject);
begin
  UnlockUser(TUserRecord(TComboBox(Sender).Parent).username);
  ShowMessage('User unlocked.');
  Form_Main.ListUsers();
end;
{$ENDREGION}

{$REGION 'Update User Rights'}
procedure TUserRecord.UpdateUserRights(username, newRights: string);
var
  sql_query: TSQLQuery;
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
  sql_query := TSQLQuery.Create(Form_Main);
  sql_query.SQLConnection := Form_Login.SQL_login;
  sql_query.SQL.Text :=
    'UPDATE users SET rights=''' + newRights + ''' WHERE username=''' + username + '''';
  sql_query.ExecSQL();

end;
{$ENDREGION}
{$REGION 'Update login attempts'}
procedure UpdateLoginAttempts(username: string);
var
  sqlQuery_user: TSQLQuery;
  loginAttempts: integer;
begin
  // Connect to database
  if Form_Login.SQL_login.Connected then
    Form_Login.SQL_login.Close;
  try
    Form_Login.SQL_login.Open;
  except
    on E: Exception do begin
      ShowMessage('Could not connect to database: ' + E.Message);
      Exit();
    end;
  end;

  // Create and execute query
  sqlQuery_user := TSQLQuery.Create(Form_Login);
  sqlQuery_user.SQLConnection := Form_Login.SQL_login;
  sqlQuery_user.SQL.Text :=
    'SELECT * FROM users WHERE username = ''' + username + '''';
  sqlQuery_user.Open();

  loginAttempts := sqlQuery_user.FieldByName('loginattempts').AsInteger + 1;
  sqlQuery_user.Close();
  if loginAttempts < 5 then
    sqlQuery_user.SQL.Text := 'UPDATE users SET loginattempts=' + IntToStr(loginAttempts) + ' WHERE username=''' + username + ''''
  else
    sqlQuery_user.SQL.Text := 'UPDATE users SET loginattempts=' + IntToStr(loginAttempts) + ', active=0 WHERE username=''' + username + '''';
  sqlQuery_user.ExecSQL();

end;
{$ENDREGION}
{$REGION 'Login'}
procedure Login(userType, userName, userPass: string);
var
  hash_user, hash_pass: string;
  sqlQuery_login: TSQLQuery;
begin
  // Validate fields
  if userName.Length < 3 then begin
    ShowMessage('Please enter a valid username.');
    Exit();
  end;
  if userPass.Length < 1 then begin
    ShowMessage('Please enter your password.');
    Exit();
  end;

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
  // Hash data
  hash_user := THashMD5.GetHashString(LowerCase(userName));
  hash_pass := THashMD5.GetHashString(userPass);

  // Create and execute query
  sqlQuery_login := TSQLQuery.Create(Form_Login);
  sqlQuery_login.SQLConnection := Form_Login.SQL_login;
  sqlQuery_login.SQL.Text :=
    'SELECT * FROM users WHERE ' +
    'username = ''' + hash_user + ''' AND ' +
    'rights = ''' + userType + '''';
  sqlQuery_login.Open();

  // Validate active user
  if sqlQuery_login.FieldByName('active').Value = 0 then begin
    ShowMessage('Access for this account is currently disabled. Please contact your system admin to unlock it.');
    Exit();
  end;

  // Validate password
  if sqlQuery_login.FieldByName('password').AsString <> hash_pass then begin
    ShowMessage('Invalid credentials!');
    UpdateLoginAttempts(hash_user);
    Exit();
  end;

  // Validate user data
  if sqlQuery_login.RecordCount = 0 then begin
    // Update login attempt in DB
    UpdateLoginAttempts(hash_user);
    ShowMessage('Invalid credentials!');
    Exit();

  end else if sqlQuery_login.RecordCount > 1 then begin
    ShowMessage('Fatal database error detected. Preventing login.');
    Exit();
  end;

  // Resest number of login attempts
  sqlQuery_login.Close();
  sqlQuery_login.SQL.Text := 'UPDATE users SET loginattempts=0 WHERE username=''' + hash_user + '''';
  sqlQuery_login.ExecSQL();

  // Reset Main UI then login
  if userType = 'admin' then
    Form_Main.Lay_AdminMenu.Visible := True
  else
    Form_Main.Lay_AdminMenu.Visible := False;

  Form_Main.Lay_Users.Visible := False;
  Form_Main.Lay_Brands.Visible := False;
  Form_Main.Lay_Requests.Visible := False;
  Form_Main.Lay_NewRequest.Visible := False;
  Form_Main.Lay_Cars.Visible := False;

  Form_Main.activeUser := hash_user;
  Form_Main.Show();
  Form_Login.Hide();
end;
{$ENDREGION}
{$REGION 'Handle admin creation'}
procedure HandleAdminCreation();
var
  sqlQuery_admin: TSQLQuery;
  hash_user, hash_pass: string;
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

  // Initialize query & check if user exists
  sqlQuery_admin := TSQLQuery.Create(Form_Login);
  sqlQuery_admin.SQLConnection := Form_Login.SQL_login;
  sqlQuery_admin.SQL.Text :=
    'SELECT COUNT(*) AS recCount FROM users WHERE rights = ''admin''';
  sqlQuery_admin.Open();
  if sqlQuery_admin.FieldByName('recCount').Value = 0 then begin
    // Create user
    sqlQuery_admin.Close;

    hash_user := THashMD5.GetHashString('admin87324');
    hash_pass := THashMD5.GetHashString('admin');

    sqlQuery_admin.SQL.Text :=
      'INSERT INTO users (username, password, rights, name, active) VALUES (''' + hash_user + ''', ''' + hash_pass + ''', ''admin'', ''Admin User'', 1)';
    sqlQuery_admin.ExecSQL();

    ShowMessage(
      'The system has detected that there are no admins in the database.' + sLineBreak +
      'A new account has been created with the following credentials: ' + sLineBreak + sLineBreak +
      'Username: admin87324' + sLineBreak +
      'Password: admin' + sLineBreak + sLineBreak +
      'Make sure to remember these as this is the only time this information is displayed!'
    );
  end;
end;
{$ENDREGION}
{$REGION 'Unlock user'}
procedure TUserRecord.UnlockUser(username: string);
var
  sqlQuery_user: TSQLQuery;
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
  sqlQuery_user := TSQLQuery.Create(Form_Login);
  sqlQuery_user.SQLConnection := Form_Login.SQL_login;
  sqlQuery_user.SQL.Text :=
    'UPDATE users SET active=1, loginattempts=0 WHERE username=''' + username + '''';
  sqlQuery_user.ExecSQL();
end;
{$ENDREGION}

end.
