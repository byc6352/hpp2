unit uFlash;

interface
uses
  windows, ShockwaveFlashObjects_TLB,SysUtils,strutils;
type
  TFlash = class
  private
    swf: TShockwaveFlash;
    class function EncodeData(Func: String;args: array of const): WideString;overload;
    class function EncodeData(args: TVarRec): WideString;overload;
  public
    constructor Create(swfFileName : ansiString);
    destructor Destroy;   //override;
    function getNewData(const priceData,oldData,clientId,priceCode:ansistring):ansistring;
    function decryptData(const data:ansistring):ansistring;
    function cryptData(const data:ansistring):ansistring;
    function CryptTimeData(const data:ansistring):ansistring;
    function deCryptTimeData(const data:ansistring):ansistring;
  end;

implementation
{ TFlash }
constructor TFlash.Create(swfFileName : ansiString);
begin
  if not assigned(swf) then begin
    swf:=TShockwaveFlash.Create(nil);
    swf.Movie:=swfFileName;
  end;
end;
destructor TFlash.Destroy;
begin
  //inherited;
  if assigned(swf) then begin
    swf.Free;
    swf:=nil;
  end;
end;
function TFlash.getNewData(const priceData,oldData,clientId,priceCode:ansistring):ansistring;
var
  tmp: WideString;
  Response:ansiString;
begin
  //tmp := TXMLParase.EncodeData('decrptData', [ansistring(trim(edtInput.Text))]);
  tmp := EncodeData('getNewData', [priceData,oldData,clientId,priceCode]);
  tmp:=swf.CallFunction(tmp);
  Response:=tmp;  //<string></string>
  Response:=midstr(Response,9,length(Response)-17);
  Response:=replaceStr(Response,'&quot;','"');
  result:=Response;
end;
function TFlash.deCryptTimeData(const data:ansistring):ansistring;
var
  tmp: WideString;
  Response:ansiString;
begin
  tmp := EncodeData('decryptTimeData', [data]);
  tmp:=swf.CallFunction(tmp);
  Response:=tmp;  //<string></string>
  Response:=midstr(Response,9,length(Response)-17);
  Response:=replaceStr(Response,'&quot;','"');
  result:=Response;
end;
function TFlash.cryptTimeData(const data:ansistring):ansistring;
var
  tmp: WideString;
  Response:ansiString;
begin
  tmp := EncodeData('cryptTimeData', [data]);
  tmp:=swf.CallFunction(tmp);
  Response:=tmp;  //<string></string>
  Response:=midstr(Response,9,length(Response)-17);
  Response:=replaceStr(Response,'&quot;','"');
  result:=Response;
end;
function TFlash.cryptData(const data:ansistring):ansistring;
var
  tmp: WideString;
  Response:ansiString;
begin
  tmp := EncodeData('cryptData', [data]);
  tmp:=swf.CallFunction(tmp);
  Response:=tmp;  //<string></string>
  Response:=midstr(Response,9,length(Response)-17);
  Response:=replaceStr(Response,'&quot;','"');
  result:=Response;
end;
function TFlash.decryptData(const data:ansistring):ansistring;
var
  tmp: WideString;
  Response:ansiString;
begin
  tmp := EncodeData('decryptData', [data]);
  tmp:=swf.CallFunction(tmp);
  Response:=tmp;  //<string></string>
  Response:=midstr(Response,9,length(Response)-17);
  Response:=replaceStr(Response,'&quot;','"');
  result:=Response;
end;
//------------------------------------------------------------------------------------
class function TFlash.EncodeData(Func: String;args: array of const): WideString;
var
  i:Integer;
  tempstr:String;
begin
  tempstr:='<arguments>';
  i:=args[0].VType;
  for i:=Low(args) to High(args) do
  begin
    if (args[i].VType=vtInteger) or (args[i].VType=VtExtended) or
         (args[i].VType=VtBoolean) or (args[i].VType=vtAnsiString) or
         (args[i].VType=vtWideString) or (args[i].VType=vtUnicodeString) then
    begin
      tempstr:=tempstr+EncodeData(args[i]);
    end
    else
    begin
    //  tempstr:=tempstr+EncodeData(TVarRec(^args[i]));
    end;
  end;
  tempstr:=tempstr+'</arguments>';
  Result:='<invoke name="'+Func+'" returntype="xml">'+tempstr+'</invoke>';
end;
class function TFlash.EncodeData(args: TVarRec): WideString;
var
  temp:string;
  arrtemp:array of Integer;
begin
  if (args.VType=vtInteger) then
  begin
    Result:=Format('<number>%d</number>',[args.VInteger]);
  end
  else if args.VType=VtExtended then
  begin
    Result:=Format('<number>%f</number>',[args.VExtended]);
  end
  else if args.VType=VtBoolean then
  begin
    Result:=Format('<%s/>',[BoolToStr(args.VBoolean,True)]);
  end
  else if args.VType=vtAnsiString then
  begin
    temp:=args.VPChar;
    Result:=Format('<string>%s</string>',[temp]);
  end
  else if args.VType=vtWideString then
  begin
    temp:=pchar(args.VWideString);
    Result:=Format('<string>%s</string>',[temp]);
  end
  else if args.VType=vtUnicodeString then
  begin
    temp:=pchar(args.VUnicodeString);
    Result:=Format('<string>%s</string>',[temp]);
  end
  else
  begin
    Result:='';
  end;
end;
end.
