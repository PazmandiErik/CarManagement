unit Unit_Login;

interface

{$REGION 'Units'}
uses
  Unit_AuxiliaryFunctions, Unit_UserMethods,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.SqlExpr, Data.DBXMySQL, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Layouts, FMX.Objects, FMX.ScrollBox, FMX.Memo, FMX.Ani, FMX.Edit, System.Hash,
  Data.FMTBcd, FMX.ListBox;
{$ENDREGION}
{$REGION 'Type - Form'}
type
  TForm_Login = class(TForm)
    SQL_login: TSQLConnection;
    Lay_Index: TLayout;
    Lay_Header: TLayout;
    Btn_Login_Switch: TButton;
    Lay_Top: TLayout;
    Img_Top_Bg: TImage;
    Rect_Header: TRectangle;
    Rect_Index: TRectangle;
    Text_Pri_Top: TText;
    Lay_Index_Top: TLayout;
    Lay_Index_Client: TLayout;
    Text_Pri_1: TText;
    Text_Pri_2: TText;
    Text_Pri_3: TText;
    Lay_Login: TLayout;
    Rect_Login_User: TRectangle;
    Text_Login_User_Title: TText;
    Edt_Login_User_Name: TEdit;
    Edt_Login_User_Pass: TEdit;
    Btn_Login_User_Login: TButton;
    Btn_Login_User_Switch: TButton;
    Btn_Home: TButton;
    Lay_Content: TLayout;
    Rect_Content: TRectangle;
    Btn_Login_Register: TButton;
    Lay_Login_User_Bottom: TLayout;
    Rect_Login_Admin: TRectangle;
    Text_Login_Admin_Title: TText;
    Edt_Login_Admin_Name: TEdit;
    Btn_Login_Admin_Login: TButton;
    Lay_Login_Admin_Bottom: TLayout;
    Btn_Login_Admin_Switch: TButton;
    Edt_Login_Admin_Pass: TEdit;
    Lay_Register: TLayout;
    Rect_Register_Content: TRectangle;
    Text_Register_Title: TText;
    Edt_Register_Username: TEdit;
    Btn_Register: TButton;
    Edt_Register_Password: TEdit;
    Edt_Register_PasswordAgain: TEdit;
    Edt_Register_FullName: TEdit;
    Text_Pri_4: TText;
    Text_Pri_5: TText;
    procedure Btn_HomeClick(Sender: TObject);
    procedure Btn_Login_SwitchClick(Sender: TObject);
    procedure Btn_Login_User_LoginClick(Sender: TObject);
    procedure Btn_Login_Admin_SwitchClick(Sender: TObject);
    procedure Btn_Login_User_SwitchClick(Sender: TObject);
    procedure Btn_Login_RegisterClick(Sender: TObject);
    procedure Btn_RegisterClick(Sender: TObject);
    procedure Btn_Login_Admin_LoginClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  end;
{$ENDREGION}
{$REGION 'Global variables'}
var
  Form_Login: TForm_Login;
{$ENDREGION}

implementation

{$R *.fmx}

uses Unit_Main;

{$REGION 'Button Click - Header - Home'}
procedure TForm_Login.Btn_HomeClick(Sender: TObject);
begin
  Lay_Index.Visible := True;
  Lay_Login.Visible := False;
  Lay_Register.Visible := False;
end;
{$ENDREGION}
{$REGION 'Button Click - Header - Login'}
procedure TForm_Login.Btn_Login_SwitchClick(Sender: TObject);
begin
  Edt_Login_User_Name.Text := '';
  Edt_Login_User_Pass.Text := '';
  Edt_Login_Admin_Name.Text := '';
  Edt_Login_Admin_Pass.Text := '';
  Edt_Register_Username.Text := '';
  Edt_Register_Password.Text := '';
  Edt_Register_PasswordAgain.Text := '';
  Edt_Register_FullName.Text := '';
  Lay_Login.Visible := True;
  Rect_Login_User.Visible := True;
  Rect_Login_Admin.Visible := False;
  Lay_Register.Visible := False;
  Lay_Index.Visible := False;
  HandleAdminCreation();
end;
{$ENDREGION}
{$REGION 'Button Click - Admin Login - Switch'}
procedure TForm_Login.Btn_Login_Admin_SwitchClick(Sender: TObject);
begin
  Rect_Login_User.Visible := True;
  Rect_Login_Admin.Visible := False;
  Edt_Login_Admin_Name.Text := '';
  Edt_Login_Admin_Pass.Text := '';
end;
{$ENDREGION}
{$REGION 'Button Click - User Login - Switch'}
procedure TForm_Login.Btn_Login_User_SwitchClick(Sender: TObject);
begin
  Rect_Login_Admin.Visible := True;
  Rect_Login_User.Visible := False;
  Edt_Login_User_Name.Text := '';
  Edt_Login_User_Pass.Text := '';
end;
{$ENDREGION}
{$REGION 'Button Click - User Login - Register'}
procedure TForm_Login.Btn_Login_RegisterClick(Sender: TObject);
begin
  Lay_Register.Visible := True;
  Lay_Login.Visible := False;
  Edt_Login_User_Name.Text := '';
  Edt_Login_User_Pass.Text := '';
end;
{$ENDREGION}
{$REGION 'Button Click - Login - User'}
procedure TForm_Login.Btn_Login_User_LoginClick(Sender: TObject);
begin
  Login('user', Edt_Login_User_Name.Text, Edt_Login_User_Pass.Text);
  Edt_Login_User_Pass.Text := '';
end;
{$ENDREGION}
{$REGION 'Button Click - Login - Admin'}
procedure TForm_Login.Btn_Login_Admin_LoginClick(Sender: TObject);
begin
  Login('admin', Edt_Login_Admin_Name.Text, Edt_Login_Admin_Pass.Text);
  Edt_Login_Admin_Pass.Text := '';
end;
{$ENDREGION}
{$REGION 'Button Click - Register'}
procedure TForm_Login.Btn_RegisterClick(Sender: TObject);
begin
 if RegisterUser(Edt_Register_Username.Text, Edt_Register_FullName.Text, 'user', Edt_Register_Password.Text, Edt_Register_PasswordAgain.Text) = 0 then begin
  ShowMessage('User successfully registered!');
  Lay_Index.Visible := True;
  Lay_Register.Visible := False;
 end;
end;
{$ENDREGION}

{$REGION 'Form - OnClose'}
procedure TForm_Login.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form_Main.Close();
end;
{$ENDREGION}

end.
