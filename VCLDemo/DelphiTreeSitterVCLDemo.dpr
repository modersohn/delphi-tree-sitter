﻿program DelphiTreeSitterVCLDemo;

uses
  Vcl.Forms,
  frmDTSMain in 'frmDTSMain.pas' {DTSMainForm},
  TreeSitter in '..\TreeSitter.pas',
  TreeSitterLib in '..\TreeSitterLib.pas',
  frmDTSLanguage in 'frmDTSLanguage.pas' {DTSLanguageForm},
  TreeSitter.Query in '..\TreeSitter.Query.pas',
  frmDTSQuery in 'frmDTSQuery.pas' {DTSQueryForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown:= True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDTSMainForm, DTSMainForm);
  Application.Run;
end.
