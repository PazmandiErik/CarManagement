program CarManagement;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit_Login in 'src\Unit_Login.pas' {Form_Login},
  Unit_AuxiliaryFunctions in 'src\Unit_AuxiliaryFunctions.pas',
  Unit_Main in 'src\Unit_Main.pas' {Form_Main},
  Unit_UserMethods in 'src\Unit_UserMethods.pas',
  Unit_CarMethods in 'src\Unit_CarMethods.pas',
  Unit_RequestMethods in 'src\Unit_RequestMethods.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm_Login, Form_Login);
  Application.CreateForm(TForm_Main, Form_Main);
  Application.Run;
end.
