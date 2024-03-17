unit TreeSitter;

interface

uses
  SysUtils,
  TreeSitterLib;

type
  ETreeSitterException = Exception;

  //some aliases, so TreeSitterLib is not needed in uses clause
  PTSLanguage = TreeSitterLib.PTSLanguage;
  TTSLanguage = TSLanguage;

  TSFieldId = TreeSitterLib.TSFieldId;
  TSSymbol = TreeSitterLib.TSSymbol;
  TSSymbolType = TreeSitterLib.TSSymbolType;

  PTSGetLanguageFunc = ^TTSGetLanguageFunc;
  TTSGetLanguageFunc = function(): PTSLanguage; cdecl;

  TTSLanguageHelper = record helper for TTSLanguage
  private
    function GetFieldName(AFieldId: TSFieldId): string;
    function GetFieldId(const AFieldName: string): TSFieldId;
    function GetSymbolName(ASymbol: TSSymbol): string;
    function GetSymbolForName(const ASymbolName: string; AIsNamed: Boolean): TSSymbol;
    function GetSymbolType(ASymbol: TSSymbol): TSSymbolType;
  public
    function Version: UInt32;
    function FieldCount: UInt32;
    function SymbolCount: UInt32;

    function NextState(AState: TSStateId; ASymbol: TSSymbol): TSStateId;

    property FieldName[AFieldId: TSFieldId]: string read GetFieldName;
    property FieldId[const AFieldName: string]: TSFieldId read GetFieldId;
    property SymbolName[ASymbol: TSSymbol]: string read GetSymbolName;
    property SymbolForName[const ASymbolName: string; AIsNamed: Boolean]: TSSymbol read GetSymbolForName;
    property SymbolType[ASymbol: TSSymbol]: TSSymbolType read GetSymbolType;
  end;

  TTSTree = class;
  TTSNode = TSNode;
  TTSPoint = TSPoint;

  TTSParser = class
  strict private
    FParser: PTSParser;
    function GetLanguage: PTSLanguage;
    procedure SetLanguage(const Value: PTSLanguage);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Reset;

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

    function Language: PTSLanguage;
    function RootNode: TTSNode;
    function TreeNilSafe: PTSTree;
    function Clone: TTSTree;

    property Tree: PTSTree read FTree;
  end;

  TTSTreeCursor = class
  strict private
    FTreeCursor: TSTreeCursor;
    function GetTreeCursor: PTSTreeCursor;
    function GetCurrentNode: TTSNode;
    function GetCurrentFieldName: string;
    function GetCurrentFieldId: TSFieldId;
    function GetCurrentDepth: UInt32;
    function GetCurrentDescendantIndex: UInt32;
  public
    constructor Create(ANode: TTSNode); overload; virtual;
    constructor Create(ACursorToCopy: TTSTreeCursor); overload; virtual;
    destructor Destroy; override;

    procedure Reset(ANode: TTSNode); overload;
    procedure Reset(ACursor: TTSTreeCursor); overload;

    function GotoParent: Boolean;
    function GotoNextSibling: Boolean;
    function GotoPrevSibling: Boolean;
    function GotoFirstChild: Boolean;
    function GotoLastChild: Boolean;
    procedure GotoDescendant(AGoalDescendantIndex: UInt32);
    function GotoFirstChildForGoal(AGoalByte: UInt32): Int64; overload;
    function GotoFirstChildForGoal(AGoalPoint: TTSPoint): Int64; overload;

    property TreeCursor: PTSTreeCursor read GetTreeCursor;
    property CurrentNode: TTSNode read GetCurrentNode;
    property CurrentFieldName: string read GetCurrentFieldName;
    property CurrentFieldId: TSFieldId read GetCurrentFieldId;
    property CurrentDescendantIndex: UInt32 read GetCurrentDescendantIndex;
    property CurrentDepth: UInt32 read GetCurrentDepth;
  end;

  TTSNodeHelper = record helper for TTSNode
    function Language: PTSLanguage;

    function NodeType: string;
    function Symbol: TSSymbol;
    function GrammarType: string;
    function GrammarSymbol: TSSymbol;

    function IsNull: Boolean;
    function IsError: Boolean;
    function HasError: Boolean;
    function HasChanges: Boolean;
    function IsExtra: Boolean;
    function IsMissing: Boolean;
    function IsNamed: Boolean;
    function Parent: TTSNode;
    function ToString: string;

    function ChildCount: Integer;
    function Child(AIndex: Integer): TTSNode;
    function NextSibling: TTSNode;
    function PrevSibling: TTSNode;

    function NamedChildCount: Integer;
    function NamedChild(AIndex: Integer): TTSNode;
    function NextNamedSibling: TTSNode;
    function PrevNamedSibling: TTSNode;

    function StartByte: UInt32;
    function StartPoint: TTSPoint;
    function EndByte: UInt32;
    function EndPoint: TTSPoint;

    function ChildByField(const AFieldName: string): TTSNode; overload;
    function ChildByField(const AFieldId: UInt32): TTSNode; overload;

    function DescendantCount: UInt32;

    class operator Equal(A: TTSNode; B: TTSNode): Boolean;
  end;

  TTSPointHelper = record helper for TTSPoint
    function ToString: string;
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

procedure TTSParser.Reset;
begin
  ts_parser_reset(FParser);
end;

procedure TTSParser.SetLanguage(const Value: PTSLanguage);
begin
  if not ts_parser_set_language(FParser, Value) then
    raise ETreeSitterException.CreateFmt('Failed to set parser language to 0x%p', [Value]);
end;

{ TTSTree }

function TTSTree.Clone: TTSTree;
begin
  Result:= TTSTree.Create(ts_tree_copy(FTree));
end;

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

function TTSTree.Language: PTSLanguage;
begin
  Result:= ts_tree_language(FTree);
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

function TTSNodeHelper.ChildByField(const AFieldId: UInt32): TTSNode;
begin
  Result:= ts_node_child_by_field_id(Self, AFieldId);
end;

function TTSNodeHelper.ChildByField(const AFieldName: string): TTSNode;
var
  ansiFieldName: AnsiString;
begin
  ansiFieldName:= AnsiString(AFieldName);
  Result:= ts_node_child_by_field_name(Self, PAnsiChar(ansiFieldName), Length(ansiFieldName));
end;

function TTSNodeHelper.ChildCount: Integer;
begin
  Result:= ts_node_child_count(Self);
end;

function TTSNodeHelper.DescendantCount: UInt32;
begin
  Result:= ts_node_descendant_count(Self);
end;

function TTSNodeHelper.EndByte: UInt32;
begin
  Result:= ts_node_end_byte(Self);
end;

function TTSNodeHelper.EndPoint: TTSPoint;
begin
{$IFDEF WIN32}
  Result:= TTSPoint(ts_node_end_point(Self));
{$ELSE}
  Result:= ts_node_end_point(Self);
{$ENDIF}
end;

class operator TTSNodeHelper.Equal(A, B: TTSNode): Boolean;
begin
  Result:= ts_node_eq(A, B);
end;

function TTSNodeHelper.GrammarSymbol: TSSymbol;
begin
  Result:= ts_node_grammar_symbol(Self);
end;

function TTSNodeHelper.GrammarType: string;
begin
  Result:= string(AnsiString(ts_node_grammar_type(Self)));
end;

function TTSNodeHelper.HasChanges: Boolean;
begin
  Result:= ts_node_has_changes(Self);
end;

function TTSNodeHelper.HasError: Boolean;
begin
  Result:= ts_node_has_error(Self);
end;

function TTSNodeHelper.IsError: Boolean;
begin
  Result:= ts_node_is_error(Self);
end;

function TTSNodeHelper.IsExtra: Boolean;
begin
  Result:= ts_node_is_extra(Self);
end;

function TTSNodeHelper.IsMissing: Boolean;
begin
  Result:= ts_node_is_missing(Self);
end;

function TTSNodeHelper.IsNamed: Boolean;
begin
  Result:= ts_node_is_named(Self);
end;

function TTSNodeHelper.IsNull: Boolean;
begin
  Result:= ts_node_is_null(Self);
end;

function TTSNodeHelper.Language: PTSLanguage;
begin
  Result:= ts_node_language(Self);
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

function TTSNodeHelper.Parent: TTSNode;
begin
  Result:= ts_node_parent(Self);
end;

function TTSNodeHelper.PrevNamedSibling: TTSNode;
begin
  Result:= ts_node_prev_named_sibling(Self);
end;

function TTSNodeHelper.PrevSibling: TTSNode;
begin
  Result:= ts_node_prev_sibling(Self);
end;

function TTSNodeHelper.StartByte: UInt32;
begin
  Result:= ts_node_start_byte(Self);
end;

function TTSNodeHelper.StartPoint: TTSPoint;
begin
{$IFDEF WIN32}
  Result:= TTSPoint(ts_node_start_point(Self));
{$ELSE}
  Result:= ts_node_start_point(Self);
{$ENDIF}
end;

function TTSNodeHelper.Symbol: TSSymbol;
begin
  Result:= ts_node_symbol(Self);
end;

function TTSNodeHelper.ToString: string;
var
  pach: PAnsiChar;
begin
  pach:= ts_node_string(Self);
  Result:= string(AnsiString(pach));
  FreeMem(pach);
end;

{ TTSPointHelper }

function TTSPointHelper.ToString: string;
begin
  Result:= Format('(%d, %d)', [row, column]);
end;

{ TTSLanguageHelper }

function TTSLanguageHelper.FieldCount: UInt32;
begin
  Result:= ts_language_field_count(@Self);
end;

function TTSLanguageHelper.GetFieldId(const AFieldName: string): TSFieldId;
var
  ansiFieldName: AnsiString;
begin
  ansiFieldName:= AnsiString(AFieldName);
  Result:= ts_language_field_id_for_name(@Self, PAnsiChar(ansiFieldName), Length(ansiFieldName));
end;

function TTSLanguageHelper.GetFieldName(AFieldId: TSFieldId): string;
begin
  Result:= string(AnsiString(ts_language_field_name_for_id(@Self, AFieldId)));
end;

function TTSLanguageHelper.GetSymbolForName(const ASymbolName: string; AIsNamed: Boolean): TSSymbol;
var
  ansiSymbolName: AnsiString;
begin
  ansiSymbolName:= AnsiString(ASymbolName);
  Result:= ts_language_symbol_for_name(@Self, PAnsiChar(ansiSymbolName), Length(ansiSymbolName), AIsNamed);
end;

function TTSLanguageHelper.GetSymbolName(ASymbol: TSSymbol): string;
begin
  Result:= string(AnsiString(ts_language_symbol_name(@Self, ASymbol)));
end;

function TTSLanguageHelper.GetSymbolType(ASymbol: TSSymbol): TSSymbolType;
begin
  Result:= ts_language_symbol_type(@Self, ASymbol);
end;

function TTSLanguageHelper.NextState(AState: TSStateId;
  ASymbol: TSSymbol): TSStateId;
begin
  Result:= ts_language_next_state(@Self, AState, ASymbol);
end;

function TTSLanguageHelper.SymbolCount: UInt32;
begin
  Result:= ts_language_symbol_count(@Self);
end;

function TTSLanguageHelper.Version: UInt32;
begin
  Result:= ts_language_version(@Self);
end;

{ TTSTreeCursor }

constructor TTSTreeCursor.Create(ANode: TTSNode);
begin
  FTreeCursor:= ts_tree_cursor_new(ANode);
end;

constructor TTSTreeCursor.Create(ACursorToCopy: TTSTreeCursor);
begin
  FTreeCursor:= ts_tree_cursor_copy(ACursorToCopy.TreeCursor);
end;

destructor TTSTreeCursor.Destroy;
begin
  ts_tree_cursor_delete(@FTreeCursor);
  FillChar(FTreeCursor, SizeOf(FTreeCursor), 0);
  inherited;
end;

function TTSTreeCursor.GetCurrentDepth: UInt32;
begin
  Result:= ts_tree_cursor_current_depth(@FTreeCursor);
end;

function TTSTreeCursor.GetCurrentDescendantIndex: UInt32;
begin
  Result:= ts_tree_cursor_current_descendant_index(@FTreeCursor);
end;

function TTSTreeCursor.GetCurrentFieldId: TSFieldId;
begin
  Result:= ts_tree_cursor_current_field_id(@FTreeCursor);
end;

function TTSTreeCursor.GetCurrentFieldName: string;
begin
  Result:= string(AnsiString(ts_tree_cursor_current_field_name(@FTreeCursor)));
end;

function TTSTreeCursor.GetCurrentNode: TTSNode;
begin
  Result:= ts_tree_cursor_current_node(@FTreeCursor);
end;

function TTSTreeCursor.GetTreeCursor: PTSTreeCursor;
begin
  Result:= @FTreeCursor;
end;

procedure TTSTreeCursor.GotoDescendant(AGoalDescendantIndex: UInt32);
begin
  ts_tree_cursor_goto_descendant(@FTreeCursor, AGoalDescendantIndex);
end;

function TTSTreeCursor.GotoFirstChild: Boolean;
begin
  Result:= ts_tree_cursor_goto_first_child(@FTreeCursor);
end;

function TTSTreeCursor.GotoFirstChildForGoal(AGoalPoint: TTSPoint): Int64;
begin
  Result:= ts_tree_cursor_goto_first_child_for_point(@FTreeCursor, AGoalPoint);
end;

function TTSTreeCursor.GotoFirstChildForGoal(AGoalByte: UInt32): Int64;
begin
  Result:= ts_tree_cursor_goto_first_child_for_byte(@FTreeCursor, AGoalByte);
end;

function TTSTreeCursor.GotoLastChild: Boolean;
begin
  Result:= ts_tree_cursor_goto_last_child(@FTreeCursor);
end;

function TTSTreeCursor.GotoNextSibling: Boolean;
begin
  Result:= ts_tree_cursor_goto_next_sibling(@FTreeCursor);
end;

function TTSTreeCursor.GotoParent: Boolean;
begin
  Result:= ts_tree_cursor_goto_parent(@FTreeCursor);
end;

function TTSTreeCursor.GotoPrevSibling: Boolean;
begin
  Result:= ts_tree_cursor_goto_previous_sibling(@FTreeCursor);
end;

procedure TTSTreeCursor.Reset(ACursor: TTSTreeCursor);
begin
  ts_tree_cursor_reset_to(@FTreeCursor, ACursor.TreeCursor);
end;

procedure TTSTreeCursor.Reset(ANode: TTSNode);
begin
  ts_tree_cursor_reset(@FTreeCursor, ANode);
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
