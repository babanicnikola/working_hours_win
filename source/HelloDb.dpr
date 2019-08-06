program HelloDb;

uses
  Forms,
  Form_Main in 'Form_Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
