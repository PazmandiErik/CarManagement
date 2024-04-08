unit Unit_RequestMethods;
interface

uses
  FMX.Layouts, FMX.Types, System.Classes, FMX.Objects, FMX.Controls, FMX.StdCtrls, FMX.ListBox, SysUtils,
  FMX.Dialogs, Data.SqlExpr, System.UITypes;

type
  TRequestRecord = class(TGridLayout)
    constructor Create(AParent: TFMXObject; _id: integer; _username, _name, _content, _isread: string); reintroduce;
    procedure MarkAsRead(id: integer);
    procedure ButtonClickMarkAsRead(Sender: TObject);
  private
    username: string;
  protected
    text_name: TText;
    text_content: TText;
    button_isread: TButton;
  public
    isread: boolean;
  end;

var
  requestArray: array of TRequestRecord;

implementation

uses Unit_Main, Unit_Login, Unit_AuxiliaryFunctions;

{$REGION 'RequestRecord - Constructor'}
constructor TRequestRecord.Create(AParent: TFMXObject; _id: integer; _username, _name, _content, _isread: string);
begin
  // Create grid
  inherited Create(AParent);
  with Self do begin
    Align := TAlignLayout.Top;
    Height := 32;
    ItemHeight := 32;
    ItemWidth := 386;
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

  // Content
  text_content := TText.Create(Self);
  text_content.Parent := Self;
  text_content.Text := _content;

  // Create button and format based on read status
  if _isread = 'False' then begin
    isread := False;
    button_isread := TButton.Create(Self);
    button_isread.Parent := Self;
    button_isread.Text := 'Mark as read';
    button_isread.Margins.Left := 100;
    button_isread.Margins.Right := 100;
    button_isread.OnClick := ButtonClickMarkAsRead;
    button_isread.Tag := _id;
    text_content.TextSettings.Font.Style := [TFontStyle.fsBold];
    text_name.TextSettings.Font.Style := [TFontStyle.fsBold];
  end else
    isread := True;

  SetLength(requestArray, Length(requestArray)+1);
  requestArray[Length(requestArray)-1] := Self;
end;
{$ENDREGION}
{$REGION 'Mark as read'}
procedure TRequestRecord.MarkAsRead(id: integer);
var
  sqlQuery_isread: TSQLQuery;
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
  sqlQuery_isread := TSQLQuery.Create(Form_Login);
  sqlQuery_isread.SQLConnection := Form_Login.SQL_login;
  sqlQuery_isread.SQL.Text :=
    'UPDATE requests SET `isread` = 1 WHERE `id`=''' + IntToStr(id) + '''';
  sqlQuery_isread.ExecSQL();

  text_content.TextSettings.Font.Style := [];
  text_name.TextSettings.Font.Style := [];

end;
{$ENDREGION}
{$REGION 'Button click - mark as read'}
procedure TRequestRecord.ButtonClickMarkAsRead(Sender: TObject);
begin
  MarkAsRead(TButton(Sender).Tag);
  TButton(Sender).Enabled := False;
  TRequestRecord(TButton(Sender).Parent).isread := True;
  Form_Main.UpdateRequestsMenuButton();
end;
{$ENDREGION}
end.
