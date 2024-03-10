unit frmDTSMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, TreeSitter, Vcl.Grids,
  System.Actions, Vcl.ActnList, Vcl.Menus;

type
  TDTSMain = class(TForm)
    memCode: TMemo;
    pnlTop: TPanel;
    treeView: TTreeView;
    Splitter1: TSplitter;
    OD: TFileOpenDialog;
    btnLoad: TButton;
    lblCode: TLabel;
    cbCode: TComboBox;
    Splitter2: TSplitter;
    Panel1: TPanel;
    sgNodeProps: TStringGrid;
    AL: TActionList;
    actGoto: TAction;
    actGotoParent: TAction;
    pmTree: TPopupMenu;
    mnuactGoto: TMenuItem;
    mnuactGotoParent: TMenuItem;
    cbFields: TComboBox;
    Label1: TLabel;
    btnGetChildByField: TButton;
    actGetChildByField: TAction;
    actShowNodeAsString: TAction;
    mnuactShowNodeAsString: TMenuItem;
    N1: TMenuItem;
    actGotoFirstChild: TAction;
    actGotoNextSibling: TAction;
    actGotoPrevSibling: TAction;
    mnuactGotoFirstChild: TMenuItem;
    mnuactGotoNextSibling: TMenuItem;
    mnuactGotoPrevSibling: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure memCodeExit(Sender: TObject);
    procedure treeViewCreateNodeClass(Sender: TCustomTreeView;
      var NodeClass: TTreeNodeClass);
    procedure treeViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure btnLoadClick(Sender: TObject);
    procedure cbCodeChange(Sender: TObject);
    procedure treeViewChange(Sender: TObject; Node: TTreeNode);
    procedure memCodeChange(Sender: TObject);
    procedure actGotoUpdate(Sender: TObject);
    procedure actGotoParentExecute(Sender: TObject);
    procedure actGotoParentUpdate(Sender: TObject);
    procedure actGotoExecute(Sender: TObject);
    procedure actGetChildByFieldExecute(Sender: TObject);
    procedure actGetChildByFieldUpdate(Sender: TObject);
    procedure actShowNodeAsStringUpdate(Sender: TObject);
    procedure actShowNodeAsStringExecute(Sender: TObject);
    procedure actGotoFirstChildExecute(Sender: TObject);
    procedure actGotoFirstChildUpdate(Sender: TObject);
    procedure actGotoNextSiblingExecute(Sender: TObject);
    procedure actGotoNextSiblingUpdate(Sender: TObject);
    procedure actGotoPrevSiblingExecute(Sender: TObject);
    procedure actGotoPrevSiblingUpdate(Sender: TObject);
  private
    FParser: TTSParser;
    FTree: TTSTree;
    FEditChanged: Boolean;
    procedure ParseContent;
    procedure LoadLanguageParser(const ALangBaseName: string);
    procedure LoadLanguageFields;
    procedure FillNodeProps(const ANode: TTSNode);
    procedure ClearNodeProps;
    function GetSelectedTSNode: TTSNode;
    procedure SetSelectedTSNode(const Value: TTSNode);
  public
    property SelectedTSNode: TTSNode read GetSelectedTSNode write SetSelectedTSNode;
  end;

  TTSTreeViewNode = class(TTreeNode)
  public
    TSNode: TTSNode;
    procedure SetupTSNode(ATSNode: TTSNode);
  end;

var
  DTSMain: TDTSMain;

implementation

uses
  UITypes;

{$R *.dfm}

type
  TSGNodePropRow = (rowSymbol, rowGrammarType, rowGrammarSymbol, rowIsError,
    rowHasError, rowIsExtra, rowIsMissing, rowIsNamed, rowChildCount,
    rowNamedChildCount, rowStartByte, rowStartPoint, rowEndByte, rowEndPoint,
    rowDescendantCount);

const
  sgNodePropCaptions: array[TSGNodePropRow] of string = (
    'Symbol', 'GrammarType', 'GrammarSymbol', 'IsError',
    'HasError', 'IsExtra', 'IsMissing', 'IsNamed', 'ChildCount',
    'NamedChildCount', 'StartByte', 'StartPoint', 'EndByte', 'EndPoint',
    'DescendantCount');

procedure TDTSMain.actGetChildByFieldExecute(Sender: TObject);
var
  foundNode: TTSNode;
begin
  foundNode:= SelectedTSNode.ChildByField(cbFields.ItemIndex + 1);
  //foundNode:= SelectedTSNode.ChildByField(cbFields.Text);
  if foundNode.IsNull then
    MessageDlg(Format('No child for field "%s" (%d) found', [cbFields.Text, cbFields.ItemIndex]),
      TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0) else
    SelectedTSNode:= foundNode;
end;

procedure TDTSMain.actGetChildByFieldUpdate(Sender: TObject);
begin
  actGetChildByField.Enabled:= (not SelectedTSNode.IsNull) and
    (cbFields.ItemIndex >= 0);
end;

procedure TDTSMain.actGotoExecute(Sender: TObject);
begin
  //to keep it enabled
end;

procedure TDTSMain.actGotoFirstChildExecute(Sender: TObject);
begin
  SelectedTSNode:= SelectedTSNode.NamedChild(0);
end;

procedure TDTSMain.actGotoFirstChildUpdate(Sender: TObject);
begin
  actGotoFirstChild.Enabled:= SelectedTSNode.NamedChildCount > 0;
end;

procedure TDTSMain.actGotoNextSiblingExecute(Sender: TObject);
begin
  SelectedTSNode:= SelectedTSNode.NextNamedSibling;
end;

procedure TDTSMain.actGotoNextSiblingUpdate(Sender: TObject);
begin
  actGotoNextSibling.Enabled:= not SelectedTSNode.NextNamedSibling.IsNull;
end;

procedure TDTSMain.actGotoParentExecute(Sender: TObject);
begin
  SelectedTSNode:= SelectedTSNode.Parent;
end;

procedure TDTSMain.actGotoParentUpdate(Sender: TObject);
begin
  actGotoParent.Enabled:= not SelectedTSNode.Parent.IsNull;
end;

procedure TDTSMain.actGotoPrevSiblingExecute(Sender: TObject);
begin
  SelectedTSNode:= SelectedTSNode.PrevNamedSibling;
end;

procedure TDTSMain.actGotoPrevSiblingUpdate(Sender: TObject);
begin
  actGotoPrevSibling.Enabled:= not SelectedTSNode.PrevNamedSibling.IsNull;
end;

procedure TDTSMain.actGotoUpdate(Sender: TObject);
begin
  actGoto.Enabled:= not SelectedTSNode.IsNull;
end;

procedure TDTSMain.actShowNodeAsStringExecute(Sender: TObject);
begin
  ShowMessage(SelectedTSNode.ToString);
end;

procedure TDTSMain.actShowNodeAsStringUpdate(Sender: TObject);
begin
  actShowNodeAsString.Enabled:= not SelectedTSNode.IsNull;
end;

procedure TDTSMain.btnLoadClick(Sender: TObject);
begin
  if not OD.Execute(Handle) then
    Exit;
  memCode.Lines.LoadFromFile(OD.FileName);
  FEditChanged:= True;
  ParseContent;
end;

procedure TDTSMain.LoadLanguageParser(const ALangBaseName: string);
//hard coded naming scheme
//  DLL name: tree-sitter-<lang>
//  method name returning TSLanguage: tree_sitter_<lang>
//this could also be fed from e.g. an INI file or could be
//hardcoded depending on the use-case
var
  tsLibName, tsAPIName: string;
  libHandle: THandle;
  pAPI: TTSGetLanguageFunc;
begin
  tsLibName:= Format('tree-sitter-%s', [ALangBaseName]);
  libHandle:= LoadLibrary(PChar(tsLibName));
  if libHandle = 0 then
    raise Exception.CreateFmt('Could not load library "%s"', [tsLibName]);
  tsAPIName:= Format('tree_sitter_%s', [ALangBaseName]);
  pAPI:= GetProcAddress(libHandle, PChar(tsAPIName));
  if pAPI = nil then
    raise Exception.CreateFmt('The library "%s" does not provide a method "%s"',
      [tsLibName, tsAPIName]);
  FParser.Reset;
  FreeAndNil(FTree);
  FParser.Language:= pAPI;
  LoadLanguageFields;
end;

procedure TDTSMain.LoadLanguageFields;
var
  i: UInt32;
begin
  cbFields.Items.BeginUpdate;
  try
    cbFields.Items.Clear;
    if FParser.Language = nil then
      Exit;
    for i:= 1 to FParser.Language^.FieldCount do
      cbFields.Items.AddObject(FParser.Language^.FieldName[i], TObject(i));
  finally
    cbFields.Items.EndUpdate;
  end;
end;

procedure TDTSMain.cbCodeChange(Sender: TObject);
begin
  LoadLanguageParser(cbCode.Items[cbCode.ItemIndex]);
  ParseContent;
end;

procedure TDTSMain.ClearNodeProps;
var
  row: TSGNodePropRow;
begin
  for row:= Low(TSGNodePropRow) to High(TSGNodePropRow) do
    sgNodeProps.Cells[1, Ord(row)]:= '';
end;

procedure TDTSMain.FillNodeProps(const ANode: TTSNode);
begin
  sgNodeProps.Cells[1, Ord(rowSymbol)]:= IntToStr(ANode.Symbol);
  sgNodeProps.Cells[1, Ord(rowGrammarType)]:= ANode.GrammarType;
  sgNodeProps.Cells[1, Ord(rowGrammarSymbol)]:= IntToStr(ANode.GrammarSymbol);
  sgNodeProps.Cells[1, Ord(rowIsError)]:= BoolToStr(ANode.IsError, True);
  sgNodeProps.Cells[1, Ord(rowHasError)]:= BoolToStr(ANode.HasError, True);
  sgNodeProps.Cells[1, Ord(rowIsExtra)]:= BoolToStr(ANode.IsExtra, True);
  sgNodeProps.Cells[1, Ord(rowIsMissing)]:= BoolToStr(ANode.IsMissing, True);
  sgNodeProps.Cells[1, Ord(rowIsNamed)]:= BoolToStr(ANode.IsNamed, True);
  sgNodeProps.Cells[1, Ord(rowChildCount)]:= IntToStr(ANode.ChildCount);
  sgNodeProps.Cells[1, Ord(rowNamedChildCount)]:= IntToStr(ANode.NamedChildCount);
  sgNodeProps.Cells[1, Ord(rowStartByte)]:= IntToStr(ANode.StartByte);
  sgNodeProps.Cells[1, Ord(rowStartPoint)]:= ANode.StartPoint.ToString;
  sgNodeProps.Cells[1, Ord(rowEndByte)]:= IntToStr(ANode.EndByte);
  sgNodeProps.Cells[1, Ord(rowEndPoint)]:= ANode.EndPoint.ToString;
  sgNodeProps.Cells[1, Ord(rowDescendantCount)]:= IntToStr(ANode.DescendantCount);
end;

procedure TDTSMain.FormCreate(Sender: TObject);
var
  row: TSGNodePropRow;
begin
  //initialize property grid captions
  sgNodeProps.RowCount:= Ord(High(TSGNodePropRow)) - Ord(Low(TSGNodePropRow)) + 1;
  for row:= Low(TSGNodePropRow) to High(TSGNodePropRow) do
    sgNodeProps.Cells[0, Ord(row)]:= sgNodePropCaptions[row];

  FParser:= TTSParser.Create;
  cbCode.ItemIndex:= 0;
  cbCodeChange(nil);
end;

procedure TDTSMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTree);
  FreeAndNil(FParser);
end;

function TDTSMain.GetSelectedTSNode: TTSNode;
begin
  if treeView.Selected is TTSTreeViewNode then
    Result:= TTSTreeViewNode(treeView.Selected).TSNode else
    Result:= FTree.RootNode.Parent; //easy way to create a NULL node
end;

procedure TDTSMain.ParseContent;
var
  root: TTSNode;
  rootNode: TTSTreeViewNode;
  sCode: string;
begin
  treeView.Items.Clear;
  sCode:= memCode.Lines.Text;
  if Length(sCode) = 0 then
    Exit; //avoid our own exception that empty string cannot be parsed
  //we no longer pass OldTree as we would need to track editing and call
  //ts_tree_edit
  FreeAndNil(FTree);
  FTree:= FParser.ParseString(sCode);
  root:= FTree.RootNode;
  rootNode:= TTSTreeViewNode(treeView.Items.AddChild(nil, root.NodeType));
  rootNode.SetupTSNode(root);
  FEditChanged:= False;
end;

procedure TDTSMain.SetSelectedTSNode(const Value: TTSNode);

  function FindViaParent(const ATSNode: TTSNode): TTreeNode;
  var
    tsParent: TTSNode;
  begin
    tsParent:= ATSNode.Parent;
    if tsParent.IsNull then
      Result:= treeView.Items.GetFirstNode else
    begin
      Result:= FindViaParent(tsParent);
      if Result <> nil then
      begin
        Result.Expand(False);
        Result:= Result.getFirstChild;
      end;
    end;
    if Result = nil then
      Exit;
    while Result is TTSTreeViewNode do
    begin
      if TTSTreeViewNode(Result).TSNode = ATSNode then
        Exit;
      Result:= Result.getNextSibling as TTSTreeViewNode;
    end;
  end;

begin
  treeView.Selected:= FindViaParent(Value);
end;

procedure TDTSMain.treeViewChange(Sender: TObject; Node: TTreeNode);
var
  tsSelected: TTSNode;
  ptStart, ptEnd: TTSPoint;
  memSel: TSelection;
  line: LRESULT;
begin
  if Node = nil then
  begin
    ClearNodeProps;
    Exit;
  end;
  tsSelected:= TTSTreeViewNode(Node).TSNode;
  FillNodeProps(tsSelected);

  //select the corresponding code in the memo
  ptStart:= tsSelected.StartPoint;
  ptEnd:= tsSelected.EndPoint;

  line:= memcode.Perform(EM_LineIndex, ptStart.row, 0);
  if line < 0 then
    Exit; //something's not right

  //TSPoint.Column is in bytes, we use UTF16, so divide by 2 to get character,
  //which is a simplification not necessarily true
  memSel.StartPos:= line + Integer(ptStart.column) div 2;

  line:= memcode.Perform(EM_LineIndex, ptEnd.row, 0);
  if line < 0 then
    Exit; //something's not right
  memSel.EndPos:= line + Integer(ptEnd.column) div 2;

  SendMessage(memCode.Handle, EM_SETSEL, memSel.StartPos, memSel.EndPos);
  SendMessage(memCode.Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TDTSMain.treeViewCreateNodeClass(Sender: TCustomTreeView;
  var NodeClass: TTreeNodeClass);
begin
  NodeClass:= TTSTreeViewNode;
end;

procedure TDTSMain.treeViewExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  AllowExpansion:= True;
  if Node.getFirstChild = nil then
    if TTSTreeViewNode(Node).TSNode.NamedChildCount > 0 then
    begin
      var child:= TTSTreeViewNode(Node).TSNode.NamedChild(0);
      while not child.IsNull do
      begin
        var newNode:= treeView.Items.AddChild(Node, child.NodeType);
        TTSTreeViewNode(newNode).SetupTSNode(child);
        child:= child.NextNamedSibling;
      end;
    end;
end;

procedure TDTSMain.memCodeChange(Sender: TObject);
begin
  FEditChanged:= True;
end;

procedure TDTSMain.memCodeExit(Sender: TObject);
begin
  if FEditChanged then
    ParseContent;
end;

{ TTSTreeViewNode }

procedure TTSTreeViewNode.SetupTSNode(ATSNode: TTSNode);
begin
  TSNode:= ATSNode;
  HasChildren:= TSNode.NamedChildCount > 0;
end;

end.
