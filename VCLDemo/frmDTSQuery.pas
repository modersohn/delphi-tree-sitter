unit frmDTSQuery;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, TreeSitter.Query, TreeSitter, Vcl.Grids;

type
  TDTSQueryForm = class(TForm)
    memQuery: TMemo;
    Splitter1: TSplitter;
    pnlTop: TPanel;
    btnExecute: TButton;
    lblQueryState: TLabel;
    pnlPredicates: TPanel;
    pnlPredicatesToolbar: TPanel;
    Label1: TLabel;
    cbPatternIdx: TComboBox;
    sgPredicateSteps: TStringGrid;
    Splitter2: TSplitter;
    procedure btnExecuteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbPatternIdxClick(Sender: TObject);
  private
    FTree: TTSTree;
    FQuery: TTSQuery;
    FQueryCursor: TTSQueryCursor;
  public
    { Public declarations }
  end;

var
  DTSQueryForm: TDTSQueryForm;

procedure ShowQueryForm(ATree: TTSTree);

implementation

{$R *.dfm}

procedure ShowQueryForm(ATree: TTSTree);
begin
  if DTSQueryForm = nil then
  begin
    Application.Createform(TDTSQueryForm, DTSQueryForm);
  end;
  DTSQueryForm.FTree:= ATree.Clone;
  DTSQueryForm.cbPatternIdxClick(nil);
  DTSQueryForm.Show;
  DTSQueryForm.BringToFront;
end;

{ TDTSQuery }

procedure TDTSQueryForm.btnExecuteClick(Sender: TObject);
const
  errorStrings: array[TTSQueryError] of string = (
    'None', 'Syntax', 'NodeType', 'Field', 'Capture', 'Structure', 'Language');
var
  errorOffset: UInt32;
  errorType: TTSQueryError;
  i: Integer;
begin
  cbPatternIdx.Items.Clear;
  FreeAndNil(FQuery);
  FQuery:= TTSQuery.Create(FTree.Language, memQuery.Lines.Text, errorOffset, errorType);
  if errorType <> TTSQueryError.TSQueryErrorNone then
  begin
    lblQueryState.Caption:= Format('Error at %d, type = %s', [errorOffset, errorStrings[errorType]]);

    memQuery.SetFocus;
    SendMessage(memQuery.Handle, EM_SETSEL, errorOffset, errorOffset);
    SendMessage(memQuery.Handle, EM_SCROLLCARET, 0, 0);
  end else
  begin
    lblQueryState.Caption:= Format('Patterns: %d, Captures: %d, Strings: %d',
      [FQuery.PatternCount, FQuery.CaptureCount, FQuery.StringCount]);
    for i:= 0 to FQuery.PatternCount - 1 do
      cbPatternIdx.Items.Add(IntToStr(i));
  end;
  if cbPatternIdx.Items.Count > 0 then
    cbPatternIdx.ItemIndex:= 0;
  cbPatternIdxClick(nil);
end;

procedure TDTSQueryForm.cbPatternIdxClick(Sender: TObject);
const
  stepTypeStrings: array[TTSQueryPredicateStepType] of string = (
    'Done', 'Capture', 'String');
  quantifierStrings: array[TTSQuantifier] of string = (
    'Zero', 'ZeroOrOne', 'ZeroOrMore', 'One', 'OneOrMore');
var
  steps: TTSQueryPredicateStepArray;
  step: TTSQueryPredicateStep;
  i: Integer;
begin
  if cbPatternIdx.ItemIndex >= 0 then
    steps:= FQuery.PredicatesForPattern(cbPatternIdx.ItemIndex);
  sgPredicateSteps.RowCount:= Length(steps) + 1;
  if sgPredicateSteps.RowCount > 1 then
    sgPredicateSteps.FixedRows:= 1;
  sgPredicateSteps.Cells[0, 0]:= 'Predicate';
  sgPredicateSteps.Cells[1, 0]:= 'Type';
  sgPredicateSteps.Cells[2, 0]:= 'ValueID';
  sgPredicateSteps.Cells[3, 0]:= 'Name';
  sgPredicateSteps.Cells[4, 0]:= 'Quantifier';
  for i:= 1 to Length(steps) do
  begin
    step:= steps[i - 1];
    sgPredicateSteps.Cells[0, i]:= IntToStr(i - 1);
    sgPredicateSteps.Cells[1, i]:= stepTypeStrings[step.&type];
    sgPredicateSteps.Cells[2, i]:= IntToStr(step.value_id);
    case step.&type of
      TTSQueryPredicateStepType.TSQueryPredicateStepTypeCapture:
        begin
          sgPredicateSteps.Cells[3, i]:= FQuery.CaptureNameForID(step.value_id);
          sgPredicateSteps.Cells[4, i]:= quantifierStrings[FQuery.QuantifierForCapture(cbPatternIdx.ItemIndex, step.value_id)];
        end;
      TTSQueryPredicateStepType.TSQueryPredicateStepTypeString:
        begin
          sgPredicateSteps.Cells[3, i]:= FQuery.StringValueForID(step.value_id);
          sgPredicateSteps.Cells[4, i]:= 'N/A';
        end
    else
      sgPredicateSteps.Cells[3, i]:= 'N/A';
      sgPredicateSteps.Cells[4, i]:= 'N/A';
    end;
  end;
end;

procedure TDTSQueryForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TDTSQueryForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FQueryCursor);
  FreeAndNil(FQuery);
  FreeAndNil(FTree);
  if Self = DTSQueryForm then
    DTSQueryForm:= nil;
end;

end.
