unit TreeSitter;

interface

uses
  SysUtils,
  TreeSitterLib;

type
  PTSGetLanguageFunc = ^TTSGetLanguageFunc;
  TTSGetLanguageFunc = function(): PTSLanguage; cdecl;

  ETreeSitterException = Exception;

  TTSTree = class;
  TTSNode = TSNode;

  TTSParser = class
  strict private
    FParser: PTSParser;
    function GetLanguage: PTSLanguage;
    procedure SetLanguage(const Value: PTSLanguage);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ParseString(const AString: string; const OldTree: TTSTree = nil): TTSTree;

    property Parser: PTSParser read FParser;
    property Language: PTSLanguage read GetLanguage write SetLanguage;
  end;

  TTSTree = class
  strict private
    FTree: PTSTree;
  public
    constructor Create(ATree: PTSTree); virtual;
    destructor Destroy; override;

    function RootNode: TTSNode;
    function TreeNilSafe: PTSTree;

    property Tree: PTSTree read FTree;
  end;

  TTSNodeHelper = record helper for TTSNode
    function NodeType: string;
    function IsNull: Boolean;

    function ChildCount: Integer;
    function Child(AIndex: Integer): TTSNode;
    function NextSibling: TTSNode;
    function PrevSibling: TTSNode;

    function NamedChildCount: Integer;
    function NamedChild(AIndex: Integer): TTSNode;
    function NextNamedSibling: TTSNode;
    function PrevNamedSibling: TTSNode;
  end;

implementation

{ TTSParser }

constructor TTSParser.Create;
begin
  FParser:= ts_parser_new;
end;

destructor TTSParser.Destroy;
begin
  ts_parser_delete(FParser);
  inherited;
end;

function TTSParser.GetLanguage: PTSLanguage;
begin
  Result:= ts_parser_language(FParser);
end;

function TTSParser.ParseString(const AString: string;
  const OldTree: TTSTree): TTSTree;
var
  bytes: TBytes;
  tree: PTSTree;
  len: Integer;
begin
  bytes:= TEncoding.Unicode.GetBytes(AString);
  len:= Length(bytes);
  if len > 0 then
    tree:= ts_parser_parse_string_encoding(FParser, OldTree.TreeNilSafe,
      @bytes[0], len, TSInputEncodingUTF16) else
    raise ETreeSitterException.Create('Cannot parse empty string');
  if tree = nil then
    raise ETreeSitterException.Create('Faild to parse string');
  Result:= TTSTree.Create(tree);
end;

procedure TTSParser.SetLanguage(const Value: PTSLanguage);
begin
  if not ts_parser_set_language(FParser, Value) then
    raise ETreeSitterException.CreateFmt('Failed to set parser language to 0x%p', [Value]);
end;

{ TTSTree }

constructor TTSTree.Create(ATree: PTSTree);
begin
  FTree:= ATree;
end;

destructor TTSTree.Destroy;
begin
  if FTree <> nil then
    ts_tree_delete(FTree);
  inherited;
end;

function TTSTree.RootNode: TTSNode;
begin
  Result:= ts_tree_root_node(FTree);
end;

function TTSTree.TreeNilSafe: PTSTree;
begin
  if Self <> nil then
    Result:= FTree else
    Result:= nil;
end;

{ TTSNodeHelper }

function TTSNodeHelper.Child(AIndex: Integer): TTSNode;
begin
  Result:= ts_node_child(Self, AIndex);
end;

function TTSNodeHelper.ChildCount: Integer;
begin
  Result:= ts_node_child_count(Self);
end;

function TTSNodeHelper.IsNull: Boolean;
begin
  Result:= ts_node_is_null(Self);
end;

function TTSNodeHelper.NamedChild(AIndex: Integer): TTSNode;
begin
  Result:= ts_node_named_child(Self, AIndex);
end;

function TTSNodeHelper.NamedChildCount: Integer;
begin
  Result:= ts_node_named_child_count(Self);
end;

function TTSNodeHelper.NextNamedSibling: TTSNode;
begin
  Result:= ts_node_next_named_sibling(Self);
end;

function TTSNodeHelper.NextSibling: TTSNode;
begin
  Result:= ts_node_next_sibling(Self);
end;

function TTSNodeHelper.NodeType: string;
begin
  Result:= string(AnsiString(ts_node_type(Self)));
end;

function TTSNodeHelper.PrevNamedSibling: TTSNode;
begin
  Result:= ts_node_prev_named_sibling(Self);
end;

function TTSNodeHelper.PrevSibling: TTSNode;
begin
  Result:= ts_node_prev_sibling(Self);
end;

{ memory management functions }

function ts_malloc_func(sizeOf: NativeUInt): Pointer; cdecl;
begin
  GetMem(Result, sizeOf);
end;

function ts_calloc_func(nitems: NativeUInt; size: NativeUInt): Pointer; cdecl;
begin
  GetMem(Result, nitems * size);
  FillChar(Result^, nitems * size, 0);
end;

procedure ts_free_func(ptr: Pointer); cdecl;
begin
  FreeMem(ptr);
end;

function ts_realloc_func(ptr: Pointer; sizeOf: NativeUInt): Pointer; cdecl;
begin
  Result:= ptr;
  ReallocMem(Result, sizeOf);
end;

initialization
  //provide our own MM functions so we can free data allocated by TS with our FreeMem
  ts_set_allocator(@ts_malloc_func, @ts_calloc_func, @ts_realloc_func, @ts_free_func);
finalization
end.
