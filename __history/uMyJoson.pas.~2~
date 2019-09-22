unit uMyJoson;

interface
uses
  sysutils,strutils,classes;
type
  TMyJson=class
    constructor Create(txt:ansiString);
    destructor Destroy;
  private
    mTxt:tStrings;
  public
    function getValue(key:ansiString):ansiString;overload;
    function getValue(i:integer):ansiString;overload;
  end;
implementation
constructor TMyJson.Create(txt:ansiString);
begin
  mTxt:=tStringlist.Create;
  mTxt.Delimiter:=',';
  mTxt.DelimitedText:=txt;
end;
destructor TMyJson.Destroy;
begin
  mTxt.Free;
end;
function TMyJson.getValue(i:integer):ansiString;
begin
  result:='';
  if i>=mTxt.Count then exit;
  result:=mtxt[i];
end;
function TMyJson.getValue(key:ansiString):ansiString;
var
  i,j:integer;
  s:ansiString;
begin
  result:='';
  for I := 0 to mTxt.Count-1 do
  begin
    s:=mtxt[i];
    if(pos(key,s)>0)then
    begin
      j:=pos('=',s);
      if(j<=0)then continue;
      result:=rightstr(s,length(s)-j);
      result:=replacestr(result,'"','');
    end;
  end;
end;
end.
