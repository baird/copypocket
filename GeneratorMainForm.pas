unit GeneratorMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Encryption;

type
  TfrmGeneratorMainForm = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGeneratorMainForm: TfrmGeneratorMainForm;

implementation

{$R *.dfm}

procedure TfrmGeneratorMainForm.Button1Click(Sender: TObject);
begin
  Edit2.Text := Encrypt(Edit1.Text, 45674);
end;

procedure TfrmGeneratorMainForm.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

end.
