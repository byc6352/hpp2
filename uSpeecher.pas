unit uSpeecher;

interface
uses
  Windows, Messages, SysUtils, Classes,IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL,bass,strutils;
const
  MY_CUID='F0B5F42DAA724497B7D531228EA6392D';
  WM_SPEECHER = WM_USER+1004;               //语音消息
  PERSON_1=1;                               //度小宇=1
  PERSON_0=0;                               //度小美=0
  PERSON_3=3;                               //度逍遥=3
  PERSON_4=4;                               //度丫丫=4

  PERSON_5=5;                               //度小娇=5
  PERSON_103=103;                               //度米朵=103
  PERSON_106=106;                               //度博文=106
  PERSON_110=110;                               //度小童=110
  PERSON_111=111;                               //度小萌=111

  AUE_MP3=3;                                   //mp3
  AUE_PCM_16=4;                                   //4为pcm-16k
  AUE_PCM_8=5;                                   //5为pcm-8k；
  AUE_WAV=6;                                   //6为wav（内容同pcm-16k）;

  HTTP_TTS='http://tsn.baidu.com/text2audio';
  HTTPS_TTS='https://tsn.baidu.com/text2audio';

  MAX_LEN_TEXT=2048;                          //一次合成的最大字符数；
  MAX_LEN_TEXT_NET=95;                          //网络合成的最大字符数；
  MAX_PLAY_VOLUM=1;                             //播放音量最大值；

type
  TSpeecher = class(TThread)
  private

    mBusy:boolean;
    Fdatadir:string;                      //工作目录（保存mp3）；

    FhForm:HWND;
    FText:String;                         //朗读的文本；
    FToken:string;
    Fcuid:string;                         //GUID,token;
    FSpeed:integer;                        //语速，取值0-15，默认为5中语速
    FPitch:integer;                        //音调，取值0-15，默认为5中语调
    FVolum:integer;                        //音量，取值0-15，默认为5中音量
    Fperson:integer;                       //发音人；
    Faue:integer;                          //语音格式；
    FPlayVolum:Single;                    //播放音量；
    function LinkHttpParameters(text:string):utf8string;             //连接参数 ；
    function saveAudioToFile(text:string):string;                //保存语音到文件
    function playAudio(hAudio: HSTREAM):boolean;
    procedure cutText(text:string;var ss:tstrings);//将长文本切割；

    procedure SetFormHandle(hForm:HWND);
    procedure SetToken(token:string);
    procedure Setcuid(cuid:string);
    procedure SetSpeed(Speed:integer);
    procedure SetPitch(Pitch:integer);
    procedure SetVolum(Volum:integer);
    procedure SetPlayVolum(PlayVolum:Single);
    procedure SetPerson(person:integer);
    procedure SetAue(aue:integer);
    //procedure SetFormHandle(hForm:HWND);
  protected
    procedure Execute; override;

  public
    constructor Create(hForm:HWND);
    destructor Destroy;
    procedure say(text:string);

    property hForm:HWND read FhForm write SetFormHandle;
    property Token:string read FToken write SetToken;
    property cuid:string read Fcuid write Setcuid;
    property Speed:integer read FSpeed write SetSpeed;
    property Pitch:integer read FPitch write SetPitch;
    property Volum:integer read FVolum write SetVolum;
    property Person:integer read FPerson write SetPerson;
    property Aue:integer read FAue write SetAue;
    property PlayVolum:single read FPlayVolum write SetPlayVolum;
    //property hForm:HWND read FhForm write SetFormHandle;
  end;
var
  Speecher:TSpeecher;
  //function ToUTF8Encode(str: string): string;
  function getFilename(workdir:string;cap:string;ext:string):string;
  function GetGUID: string;
implementation
{ TSpeecher }
uses
  uConfig,uLog,HttpApp;

constructor TSpeecher.Create(hForm:HWND);  //
begin
  FreeOnTerminate := True;
  inherited Create(True);
  FhForm:=hForm;
  FSpeed:=5;
  FPitch:=5;
  FVolum:=15;
  Faue:=AUE_MP3;
  Fcuid:=MY_CUID;
  Fdatadir:=uConfig.datadir;
  FPlayVolum:=0.01;
end;
destructor TSpeecher.Destroy;
begin
  //Terminated:=false;
end;

procedure TSpeecher.say(text:string);
begin
  FText:=text;
  Resume;
end;

procedure TSpeecher.cutText(text:string;var ss:tstrings);//将长文本切割；
var
  len,i,j:integer;
  s:string;
begin
  len:=length(text);
  ss.Clear;
  if(len<MAX_LEN_TEXT)then
  begin
   ss.Add(text);
   exit;
  end;
  i:=1;
  while(i<len)do
  begin
    j:=len-i+1;
    if(j>=MAX_LEN_TEXT)then j:=MAX_LEN_TEXT;
    s:=midstr(text,i,j);
    ss.Add(s);
    i:=i+j;
  end;
end;
procedure TSpeecher.Execute;
var
  fileName:ansistring;
  hAudio: HSTREAM;
  ss:tstrings;
  s:string;
  i:integer;
begin
  if not BASS_Init(-1, 44100, 0, FhForm, nil) then exit;
  ss:=tstringlist.Create;
  repeat
    mBusy:= true;
    if length(Ftext)=0 then Ftext:='ufo';
    cutText(Ftext,ss);
    for I := 0 to ss.Count-1 do
    begin
      s:=ss[i];
      if length(s)>MAX_LEN_TEXT_NET then  //下载
      begin
        fileName:=SaveAudioToFile(s);
        hAudio:= BASS_StreamCreateFile(false, pansichar(fileName), 0, 0, 0);
      end else begin
        hAudio:= BASS_StreamCreateURL(pchar(LinkHttpParameters(s)), 0,BASS_SAMPLE_MONO,nil,0);
      end;
      playAudio(hAudio);
      BASS_StreamFree(hAudio);
    end;
    mBusy:= false;
    Suspend; //线程挂起
  until Terminated;
  BASS_Free(); //释放bass 库
  ss.Free;
end;
//连接参数 ；
function TSpeecher.LinkHttpParameters(text:string):utf8string;
begin
  result:=HTTP_TTS+
          //'?tex='+ToUTF8Encode(FText) +
          '?tex='+HttpEncode(UTF8Encode(Text))+
          '&tok='+Ftoken+
          '&cuid='+Fcuid+
          '&ctp=1'+
          '&lan=zh'+
          '&spd='+inttostr(Fspeed)+
          '&pit='+inttostr(Fpitch)+
          '&vol='+inttostr(Fvolum)+
          '&per='+inttostr(Fperson)+
          '&aue='+inttostr(Faue);
  Log(result);
end;
//播放语音
function TSpeecher.playAudio(hAudio: HSTREAM):boolean;
var
  parameters:TStrings;
  idhttp: Tidhttp;
  AResponseContent: TMemoryStream;
  fileName,httpRes:string;
  active:DWORD;
begin
  result:=false;
  if(hAudio=0)then
  begin
    Log('playAudio:hAudio=0;BASS_ErrorGetCode='+inttostr(BASS_ErrorGetCode()));
    exit;
  end;
  try
    //BASS_SetConfig(BASS_CONFIG_GVOL_STREAM,game_bg_music_rc_g.bg_yl * 100); //设定音量
    BASS_SetVolume(FPlayVolum);
    BASS_ChannelPlay(hAudio, False);
    active := BASS_ChannelIsActive(hAudio);
    if active= 0 then
    begin
      Log('playAudio:active=0;BASS_ErrorGetCode='+inttostr(BASS_ErrorGetCode));
      exit;
    end;
    while active > 0 do
    begin
      sleep(50);
      active := BASS_ChannelIsActive(hAudio);
    end; //end while
    BASS_ChannelStop(hAudio);

  finally

  end;
end;
//保存语音到文件    application/x-www-form-urlencoded
function TSpeecher.saveAudioToFile(text:string):string;
var
  parameters:TStrings;
  idhttp: Tidhttp;
  AResponseContent: TMemoryStream;
  fileName,httpRes,urltext:string;
begin
try
  parameters:=TStringlist.Create;
  idhttp:= TIdhttp.Create(nil);
  AResponseContent:=TMemoryStream.Create;
  urltext:=HttpEncode(UTF8Encode(text));
  log(text);
  log(urltext);
  parameters.Add('tex='+urltext);
  parameters.Add('tok='+Ftoken);
  parameters.Add('cuid='+Fcuid);
  parameters.Add('ctp=1');
  parameters.Add('lan=zh');
  parameters.Add('spd='+inttostr(Fspeed));
  parameters.Add('pit='+inttostr(Fpitch));
  parameters.Add('vol='+inttostr(Fvolum));
  parameters.Add('per='+inttostr(Fperson));
  parameters.Add('aue='+inttostr(Faue));
  IdHTTP.Post(HTTP_TTS, parameters,AResponseContent);
  //Log(httpRes);   httpRes:=
  AResponseContent.Position:=0;
  fileName:=getFilename(Fdatadir,'audio','.mp3');
  AResponseContent.SaveToFile(fileName);
  result:=fileName;
finally
  parameters.Free;
  idhttp.Free;
  AResponseContent.Free;
end;
end;

//------------------------------------------属性方法-------------------------------------
 procedure TSpeecher.SetFormHandle(hForm:HWND);
 begin
   FhForm:=hForm;
 end;
procedure TSpeecher.SetToken(token:string);
begin
  Ftoken:=token;
end;
procedure TSpeecher.Setcuid(cuid:string);
begin
  Fcuid:=cuid;
end;
procedure TSpeecher.SetSpeed(Speed:integer);
begin
  Fspeed:=Speed;
  if(Speed<=1)then Fspeed:=1;
  if(Speed>=15)then Fspeed:=15;
end;
procedure TSpeecher.SetPitch(Pitch:integer);
begin
  FPitch:=Pitch;
  if(Pitch<=1)then FPitch:=1;
  if(Pitch>=15)then FPitch:=15;
end;
procedure TSpeecher.SetVolum(Volum:integer);
begin
  FVolum:=Volum;
  if(Volum<=1)then FVolum:=1;
  if(Volum>=15)then FVolum:=15;
end;
procedure TSpeecher.SetPlayVolum(PlayVolum:Single);
begin
  FPlayVolum:=PlayVolum;
  if(PlayVolum<=0)then FPlayVolum:=0;
  if(PlayVolum>=1)then FPlayVolum:=1;
end;
procedure TSpeecher.SetPerson(person:integer);
begin
  Fperson:=person;
end;
procedure TSpeecher.SetAue(aue:integer);
begin
  Faue:=aue;
end;

//------------------------------------------内部调用--------------------------------------


function getDateTimeString(dt:tdatetime;formatType:integer):string;
const
  TIME_STR='yyyy-mm-dd hh:nn:ss';
  FILE_STR='yyyymmddhhnnsszzz';
  TIME_FORMAT=0;
  FILE_FORMAT=1;
var
  s:string;
begin
  s:='';
try
  if formatType=TIME_FORMAT then
    s:=FormatDateTime(TIME_STR,dt);
  if formatType=FILE_FORMAT then
    s:=FormatDateTime(FILE_STR,dt);
finally
  result:=s;
end;
end;

function getFilename(workdir:string;cap:string;ext:string):string;
var
  i:integer;
begin
  randomize();
  i:=random(10);
  //result:=workdir+'\'+cap+FormatDateTime('yyyymmddhhnnsszzz',now())+inttostr(i)+ext;
  result:=workdir+'\'+cap+getDatetimeString(now(),1)+inttostr(i)+ext;
end;

function GetGUID: string;
var
LTep: TGUID;
sGUID: string;
begin
CreateGUID(LTep);
sGUID := GUIDToString(LTep);
sGUID := StringReplace(sGUID, '-', '', [rfReplaceAll]);
sGUID := Copy(sGUID, 2, Length(sGUID) - 2);
Result := sGUID;
end;

//___________________________________________________________________________________
{

function AnsiToWide(const S: AnsiString): WideString;
var
len: integer;
ws: WideString;
begin
Result:='';
if (Length(S) = 0) then
exit;
len:=MultiByteToWideChar(CP_ACP, 0, PansiChar(s), -1, nil, 0);
SetLength(ws, len);
MultiByteToWideChar(CP_ACP, 0, PansiChar(s), -1, PWideChar(ws), len);
Result:=ws;
end;


function WideToUTF8(const WS: WideString): UTF8String;
var
len: integer;
us: UTF8String;
begin
Result:='';
if (Length(WS) = 0) then
exit;
len:=WideCharToMultiByte(CP_UTF8, 0, PWideChar(WS), -1, nil, 0, nil, nil);
SetLength(us, len);
WideCharToMultiByte(CP_UTF8, 0, PWideChar(WS), -1, PansiChar(us), len, nil, nil);
Result:=us;
end;

function URLEncode(const S: string; const InQueryString: Boolean): string;
var
  Idx: Integer; // loops thru characters in string
begin
  Result := '';
  for Idx := 1 to Length(S) do
  begin
    case S[Idx] of
      'A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.':
        Result := Result + S[Idx];
      ' ':
        if InQueryString then
          Result := Result + '+'
        else
          Result := Result + '%20';
      else
        Result := Result + '%' + SysUtils.IntToHex(Ord(S[Idx]), 2);
    end;
  end;
end;

function ToUTF8Encode(str: string): string;
var
b: Byte;
begin
result:= '';
for b in BytesOf(UTF8Encode(str)) do
Result := Format('%s%%%.2x', [Result, b]);
end;
}
end.
