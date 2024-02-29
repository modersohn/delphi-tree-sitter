program DelphiTreeSitterVCLDemo;

uses
  Vcl.Forms,
  frmDTSMain in 'frmDTSMain.pas' {DTSMain},
  TreeSitter in '..\TreeSitter.pas',
  TreeSitterLib in '..\TreeSitterLib.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown:= True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDTSMain, DTSMain);
  Application.Run;
end.
