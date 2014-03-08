program Generator;

uses
  Forms,
  GeneratorMainForm in 'GeneratorMainForm.pas' {frmGeneratorMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGeneratorMainForm, frmGeneratorMainForm);
  Application.Run;
end.
