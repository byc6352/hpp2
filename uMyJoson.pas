unit uMyJoson;

interface
uses
  sysutils,strutils,classes,System.json;
type
  TMyJson=class
    constructor Create(txt:ansiString);overload;
    constructor Create(txt:ansiString;bJson:boolean);overload;
    destructor Destroy;
  private
    mTxt:tStrings;
    mJSONObject: TJSONObject;
  public
    function getValue(key:ansiString):ansiString;overload;
    function getValue(key:ansiString;bJson:boolean):ansiString;overload;
    function getValue(i:integer):ansiString;overload;
  end;
implementation
constructor TMyJson.Create(txt:ansiString);
begin
  mTxt:=tStringlist.Create;
  mTxt.Delimiter:=',';
  mTxt.DelimitedText:=txt;
end;
constructor TMyJson.Create(txt:ansiString;bJson:boolean);
begin
  if(bJson)then
  begin
    mJSONObject:= TJSONObject.ParseJSONValue(txt) as TJSONObject;
  end
  else begin
    Create(txt);
  end;
end;
destructor TMyJson.Destroy;
begin
  if(assigned(mTxt))then
    mTxt.Free;
  if(assigned(mJSONObject))then
    mJSONObject.Free;
end;
function TMyJson.getValue(i:integer):ansiString;
begin
  result:='';
  if i>=mTxt.Count then exit;
  result:=mtxt[i];
end;
function TMyJson.getValue(key:ansiString;bJson:boolean):ansiString;
begin
  if(bJson)then
  begin
    result:=mJSONObject.Values[key].ToString;
  end
  else begin
    result:=getValue(key);
  end;
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
