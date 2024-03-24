program ConsoleReadPasFile;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Classes,
  System.SysUtils,
  IOUtils,
  TreeSitter in 'TreeSitter.pas',
  TreeSitterLib in 'TreeSitterLib.pas';

function tree_sitter_pascal(): PTSLanguage; cdecl; external 'tree-sitter-pascal';

procedure ReadAndParsePasFile(const AFileName: string);
var
  parser: TTSParser;
  fs: TFileStream;
  tree: TTSTree;
begin
  tree:= nil;
  parser:= nil;
  fs:= TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    parser:= TTSParser.Create;
    parser.Language:= tree_sitter_pascal;
    tree:= parser.parse(
      function (AByteIndex: UInt32; APosition: TTSPoint; var ABytesRead: UInt32): TBytes
      const
        BufSize = 10 * 1024;
      begin
        if fs.Seek(AByteIndex, soFromBeginning) < 0 then
        begin
          ABytesRead:= 0;
          Exit;
        end;
        SetLength(Result, BufSize);
        try
          ABytesRead:= fs.Read(Result, BufSize);
        except
          ABytesRead:= 0;
        end;
        SetLength(Result, ABytesRead);
      end, TTSInputEncoding.TSInputEncodingUTF8);

    WriteLn(tree.RootNode.ToString);
  finally
    tree.Free;
    parser.Free;
    fs.Free;
  end;
end;

var
  fn: string;
begin
  try
    fn:= TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), '..\..\TreeSitter.pas');
    if TFile.Exists(fn) then
      ReadAndParsePasFile(fn) else
      raise Exception.CreateFmt('Failed to find file to parse: "%s"', [fn]);
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
