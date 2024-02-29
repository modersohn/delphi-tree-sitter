unit frmDTSMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, TreeSitter;

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure memCodeExit(Sender: TObject);
    procedure treeViewCreateNodeClass(Sender: TCustomTreeView;
      var NodeClass: TTreeNodeClass);
    procedure treeViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure btnLoadClick(Sender: TObject);
    procedure cbCodeChange(Sender: TObject);
  private
    FParser: TTSParser;
    FTree: TTSTree;
    procedure ParseContent;
    procedure LoadLanguageParser(const ALangBaseName: string);
  public
    { Public declarations }
  end;

  TTSTreeViewNode = class(TTreeNode)
  public
    TSNode: TTSNode;
    procedure SetupTSNode(ATSNode: TTSNode);
  end;

var
  DTSMain: TDTSMain;

implementation

{$R *.dfm}

procedure TDTSMain.btnLoadClick(Sender: TObject);
begin
  if not OD.Execute(Handle) then
    Exit;
  memCode.Lines.LoadFromFile(OD.FileName);
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
  FParser.Language:= pAPI;
end;

procedure TDTSMain.cbCodeChange(Sender: TObject);
begin
  LoadLanguageParser(cbCode.Items[cbCode.ItemIndex]);
end;

procedure TDTSMain.FormCreate(Sender: TObject);
begin
  FParser:= TTSParser.Create;
  cbCode.ItemIndex:= 0;
  cbCodeChange(nil);
end;

procedure TDTSMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTree);
  FreeAndNil(FParser);
end;

procedure TDTSMain.ParseContent;
var
  oldTree: TTSTree;
begin
  oldTree:= FTree;
  FTree:= FParser.ParseString(memCode.Lines.Text, oldTree);
  oldTree.Free;
  treeView.Items.Clear;
  var root:= FTree.RootNode;
  var rootNode:= TTSTreeViewNode(treeView.Items.AddChild(nil, root.NodeType));
  rootNode.SetupTSNode(root);
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

procedure TDTSMain.memCodeExit(Sender: TObject);
begin
  ParseContent;
end;

{ TTSTreeViewNode }

procedure TTSTreeViewNode.SetupTSNode(ATSNode: TTSNode);
begin
  TSNode:= ATSNode;
  HasChildren:= TSNode.NamedChildCount > 0;
end;

end.
