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
    pnlMatches: TPanel;
    pnlMatchesTop: TPanel;
    sgMatchCaptures: TStringGrid;
    btnMatchStart: TButton;
    btnMatchNext: TButton;
    lblMatch: TLabel;
    procedure btnExecuteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbPatternIdxClick(Sender: TObject);
    procedure btnMatchStartClick(Sender: TObject);
    procedure btnMatchNextClick(Sender: TObject);
    procedure sgMatchCapturesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    FTree: TTSTree;
    FQuery: TTSQuery;
    FQueryCursor: TTSQueryCursor;
    FCurrentMatch: TTSQueryMatch;
    procedure ClearQuery;
    procedure ClearMatches;
    procedure ClearPredicates;
  public
    procedure TreeDeleted;
    procedure NewTreeGenerated(ATree: TTSTree);
  end;

var
  DTSQueryForm: TDTSQueryForm;

procedure ShowQueryForm(ATree: TTSTree);

implementation

uses
  Math, frmDTSMain;

{$R *.dfm}

procedure ShowQueryForm(ATree: TTSTree);
begin
  if DTSQueryForm = nil then
  begin
    Application.Createform(TDTSQueryForm, DTSQueryForm);
  end;
  DTSQueryForm.FTree:= ATree;
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
  ClearQuery;

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
    btnMatchStart.Enabled:= True;
  end;
  if cbPatternIdx.Items.Count > 0 then
    cbPatternIdx.ItemIndex:= 0;
  cbPatternIdxClick(nil);
end;

procedure TDTSQueryForm.btnMatchNextClick(Sender: TObject);
var
  i: Integer;
  captures: TTSQueryCaptureArray;
begin
  if not FQueryCursor.NextMatch(FCurrentMatch) then
  begin
    ClearMatches;
    lblMatch.Caption:= 'No more matches';
    Exit;
  end;
  lblMatch.Caption:= Format('Match id = %d, pattern idx = %d', [FCurrentMatch.id, FCurrentMatch.pattern_index]);

  captures:= FCurrentMatch.CapturesArray;
  sgMatchCaptures.RowCount:= Length(captures) + 1;
  sgMatchCaptures.FixedRows:= 1;
  for i:= 0 to FCurrentMatch.capture_count - 1 do
  begin
    sgMatchCaptures.Cells[0, i + 1]:= IntToStr(captures[i].index);
    sgMatchCaptures.Cells[1, i + 1]:= captures[i].node.NodeType;
  end;
  if InRange(sgMatchCaptures.Selection.Top, 1, Length(captures)) then
    DTSMainForm.SelectedTSNode:= captures[sgMatchCaptures.Selection.Top - 1].node;
end;

procedure TDTSQueryForm.btnMatchStartClick(Sender: TObject);
begin
  if FQueryCursor = nil then
    FQueryCursor:= TTSQueryCursor.Create;
  FQueryCursor.Execute(FQuery, FTree.RootNode);
  ClearMatches;
  sgMatchCaptures.Cells[0, 0]:= 'Capture index';
  sgMatchCaptures.Cells[1, 0]:= 'Node';
  btnMatchNext.Enabled:= True;
  btnMatchNextClick(nil);
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

procedure TDTSQueryForm.ClearMatches;
begin
  sgMatchCaptures.RowCount:= 1;
  lblMatch.Caption:= '';
  btnMatchNext.Enabled:= False;
end;

procedure TDTSQueryForm.ClearPredicates;
begin
  cbPatternIdx.Items.Clear;
  sgPredicateSteps.RowCount:= 1;
end;

procedure TDTSQueryForm.ClearQuery;
begin
  FreeAndNil(FQuery);
  btnMatchStart.Enabled:= False;
  lblQueryState.Caption:= '';
  ClearPredicates;
  ClearMatches;
end;

procedure TDTSQueryForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TDTSQueryForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FQueryCursor);
  FreeAndNil(FQuery);
  //FTree is no longer a clone/copy but identical to main form, otherwise
  //finding the node in the main forms tree would not work
  //(nodes belowing to different trees are not considered equal)
  FTree:= nil;
  if Self = DTSQueryForm then
    DTSQueryForm:= nil;
end;

procedure TDTSQueryForm.NewTreeGenerated(ATree: TTSTree);
begin
  ClearQuery;
  FTree:= ATree;
end;

procedure TDTSQueryForm.sgMatchCapturesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if not InRange(ARow, 1, FCurrentMatch.capture_count) then
    Exit;

  DTSMainForm.SelectedTSNode:= FCurrentMatch.captures[ARow - 1].node;
end;

procedure TDTSQueryForm.TreeDeleted;
begin
  ClearQuery;
end;

end.
