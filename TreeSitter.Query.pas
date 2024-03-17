unit TreeSitter.Query;

interface

uses
  TreeSitterLib, TreeSitter;

type
  TTSQueryError = TreeSitterLib.TSQueryError;
  TTSQueryPredicateStep = TreeSitterLib.TSQueryPredicateStep;
  TTSQueryPredicateStepType = TreeSitterLib.TSQueryPredicateStepType;

  TTSQueryPredicateStepArray = array of TTSQueryPredicateStep;
  TTSQuantifier = TreeSitterLib.TSQuantifier;

  TTSQuery = class
  strict private
    FQuery: PTSQuery;
  public
    constructor Create(ALanguage: PTSLanguage; const ASource: string;
      var AErrorOffset: UInt32; var AErrorType: TTSQueryError); virtual;
    destructor Destroy; override;

    function PatternCount: UInt32;
    function CaptureCount: UInt32;
    function StringCount: UInt32;

    function StartByteForPattern(APatternIndex: UInt32): UInt32;
    function PredicatesForPattern(APatternIndex: UInt32): TTSQueryPredicateStepArray;

    function CaptureNameForID(ACaptureIndex: UInt32): string;
    function StringValueForID(AStringIndex: UInt32): string;

    function QuantifierForCapture(APatternIndex, ACaptureIndex: UInt32): TTSQuantifier;

    property Query: PTSQuery read FQuery;
  end;

  TTSQueryMatch = TreeSitterLib.TSQueryMatch;

  TTSQueryCursor = class
  strict private
    FQueryCursor: PTSQueryCursor;

    function GetMatchLimit: UInt32;
    procedure SetMatchLimit(const Value: UInt32);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Execute(AQuery: TTSQuery; ANode: TTSNode);
    function DidExceedMatchLimit: Boolean;
    procedure SetMaxStartDepth(AMaxStartDepth: UInt32);

    function NextMatch(var AMatch: TTSQueryMatch): Boolean;
    function NextCapture(var AMatch: TTSQueryMatch; var ACaptureIndex: UInt32): Boolean;

    property QueryCursor: PTSQueryCursor read FQueryCursor;
    property MatchLimit: UInt32 read GetMatchLimit write SetMatchLimit;
  end;


implementation

{ TTSQuery }

function TTSQuery.CaptureCount: UInt32;
begin
  Result:= ts_query_capture_count(FQuery);
end;

function TTSQuery.CaptureNameForID(ACaptureIndex: UInt32): string;
var
  pac: PAnsiChar;
  len: UInt32;
  res: AnsiString;
begin
  pac:= ts_query_capture_name_for_id(FQuery, ACaptureIndex, len);
  SetLength(res, len);
  if len > 0 then
    Move(pac[0], res[1], len * SizeOf(pac[0]));
  Result:= string(res);
end;

constructor TTSQuery.Create(ALanguage: PTSLanguage; const ASource: string;
  var AErrorOffset: UInt32; var AErrorType: TTSQueryError);
var
  ansiSource: AnsiString;
begin
  ansiSource:= AnsiString(ASource);
  FQuery:= ts_query_new(ALanguage, PAnsiChar(ansiSource), Length(ansiSource),
    AErrorOffset, AErrorType);
end;

destructor TTSQuery.Destroy;
begin
  ts_query_delete(FQuery);
  inherited;
end;

function TTSQuery.PatternCount: UInt32;
begin
  Result:= ts_query_pattern_count(FQuery);
end;

function TTSQuery.PredicatesForPattern(
  APatternIndex: UInt32): TTSQueryPredicateStepArray;
var
  count: UInt32;
  parr: PTSQueryPredicateStepArray;
begin
  count:= 0;
  parr:= ts_query_predicates_for_pattern(FQuery, APatternIndex, count);
  if (parr <> nil) and (count > 0) then
  begin
    SetLength(Result, count);
    Move(parr[0], Result[0], count * SizeOf(Result[0]));
  end;
end;

function TTSQuery.QuantifierForCapture(APatternIndex,
  ACaptureIndex: UInt32): TTSQuantifier;
begin
  Result:= ts_query_capture_quantifier_for_id(FQuery, APatternIndex, ACaptureIndex);
end;

function TTSQuery.StartByteForPattern(APatternIndex: UInt32): UInt32;
begin
  Result:= ts_query_start_byte_for_pattern(FQuery, APatternIndex);
end;

function TTSQuery.StringCount: UInt32;
begin
  Result:= ts_query_string_count(FQuery);
end;

function TTSQuery.StringValueForID(AStringIndex: UInt32): string;
var
  pac: PAnsiChar;
  len: UInt32;
  res: AnsiString;
begin
  pac:= ts_query_string_value_for_id(FQuery, AStringIndex, len);
  SetLength(res, len);
  if len > 0 then
    Move(pac[0], res[1], len * SizeOf(pac[0]));
  Result:= string(res);
end;

{ TTSQueryCursor }

constructor TTSQueryCursor.Create;
begin
  FQueryCursor:= ts_query_cursor_new;
end;

destructor TTSQueryCursor.Destroy;
begin
  ts_query_cursor_delete(FQueryCursor);
  inherited;
end;

function TTSQueryCursor.DidExceedMatchLimit: Boolean;
begin
  Result:= ts_query_cursor_did_exceed_match_limit(FQueryCursor);
end;

procedure TTSQueryCursor.Execute(AQuery: TTSQuery; ANode: TTSNode);
begin
  ts_query_cursor_exec(FQueryCursor, AQuery.Query, ANode);
end;

function TTSQueryCursor.GetMatchLimit: UInt32;
begin
  Result:= ts_query_cursor_match_limit(FQueryCursor);
end;

function TTSQueryCursor.NextCapture(var AMatch: TTSQueryMatch;
  var ACaptureIndex: UInt32): Boolean;
begin
  Result:= ts_query_cursor_next_capture(FQueryCursor, AMatch, ACaptureIndex);
end;

function TTSQueryCursor.NextMatch(var AMatch: TTSQueryMatch): Boolean;
begin
  Result:= ts_query_cursor_next_match(FQueryCursor, AMatch);
end;

procedure TTSQueryCursor.SetMatchLimit(const Value: UInt32);
begin
  ts_query_cursor_set_match_limit(FQueryCursor, Value);
end;

procedure TTSQueryCursor.SetMaxStartDepth(AMaxStartDepth: UInt32);
begin
  ts_query_cursor_set_max_start_depth(FQueryCursor, AMaxStartDepth);
end;

end.
