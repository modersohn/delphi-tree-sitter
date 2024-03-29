﻿unit frmDTSLanguage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.StdCtrls, TreeSitter;

type
  TDTSLanguageForm = class(TForm)
    lblFieldCount: TLabel;
    pnlTop: TPanel;
    sgSymbols: TStringGrid;
    sgFields: TStringGrid;
    Splitter1: TSplitter;
    lblSymbolCount: TLabel;
    lblVersion: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FLanguage: PTSLanguage;
    procedure UpdateLanguage;
  public
    { Public declarations }
  end;

var
  DTSLanguageForm: TDTSLanguageForm;

  procedure ShowLanguageInfo(ALanguage: PTSLanguage);

implementation

{$R *.dfm}

procedure ShowLanguageInfo(ALanguage: PTSLanguage);
begin
  if DTSLanguageForm = nil then
  begin
    Application.Createform(TDTSLanguageForm, DTSLanguageForm);
    DTSLanguageForm.sgFields.ColWidths[1]:= 50;
    DTSLanguageForm.sgSymbols.ColWidths[0]:= 200;
    DTSLanguageForm.sgSymbols.ColWidths[1]:= 50;
  end;
  DTSLanguageForm.FLanguage:= ALanguage;
  DTSLanguageForm.UpdateLanguage;
  DTSLanguageForm.Show;
  DTSLanguageForm.BringToFront;
end;

procedure TDTSLanguageForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
  if Self = DTSLanguageForm then
    DTSLanguageForm:= nil;
end;

procedure TDTSLanguageForm.UpdateLanguage;
const
  SymbolTypes: array[TSSymbolType] of string = ('Regular', 'Anonymous',
    'Auxiliary');
var
  i: Integer;
begin
  lblFieldCount.Caption:= Format('Fields: %d', [FLanguage^.FieldCount]);
  lblSymbolCount.Caption:= Format('Symbols: %d', [FLanguage^.SymbolCount]);
  lblVersion.Caption:= Format('Version: %d', [FLanguage^.Version]);

  sgFields.RowCount:= FLanguage^.FieldCount + 1;
  sgFields.Cells[0, 0]:= 'Field name';
  sgFields.Cells[1, 0]:= 'Field Id';
  for i:= 1 to sgFields.RowCount - 1 do
  begin
    sgFields.Cells[0, i]:= FLanguage^.FieldName[TSFieldId(i)];
    sgFields.Cells[1, i]:= IntToStr(i);
  end;

  sgSymbols.RowCount:= FLanguage^.SymbolCount + 1;
  sgSymbols.Cells[0, 0]:= 'Symbol name';
  sgSymbols.Cells[1, 0]:= 'Symbol';
  sgSymbols.Cells[2, 0]:= 'Type';
  for i:= 1 to sgSymbols.RowCount - 1 do
  begin
    sgSymbols.Cells[0, i]:= FLanguage^.SymbolName[TSSymbol(i)];
    sgSymbols.Cells[1, i]:= IntToStr(i);
    sgSymbols.Cells[2, i]:= SymbolTypes[FLanguage^.SymbolType[TSSymbol(i)]];
  end;
end;

end.
