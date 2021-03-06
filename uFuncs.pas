unit uFuncs;

interface
uses
   System.SysUtils,messages,windows, Vcl.Graphics,system.classes,strutils,uconfig,registry,urlmon,
   ShlObj,jpeg;

function getDateFilename():string;
function captureScreen(x1:integer;y1:integer;x2:integer;y2:integer):tbitmap;
function GetDateFormatSep():string;

function saveTofile(filename:string;p:pointer;dwSize:DWORD):boolean;

function getFilename(workdir:string;cap:string;ext:string):string;
function ReversePos(SubStr, S: String): Integer;

function getDateTimeString(dt:tdatetime;formatType:integer):string;
function my_strtodatetime(str_datetime:string):tdatetime;
procedure IEEmulator(VerCode: Integer);

function IsWin64: Boolean;
function IsValidFileName(FileName: string): Boolean;
function forceValidFileName(var FileName: string): Boolean;
procedure SetGlobalEnvironment(const Name, Value: string);
function IsSetGlobalEnvironment(const Name,Value: string):boolean;
procedure SetMyGlobalEnvironment();
  //链接转换为本地文件路径
function url2file(ServerName,ObjectName:string;ServerPort:DWORD):string;overload;
function url2file(ServerName,ObjectName:string;ServerPort:DWORD;var url:string):string;overload;
function url2file(url:string):string;overload;
function DownloadToFile(Source, Dest: string): Boolean;
function GetSystemPath(FID: Integer): string;
function ConvertPICintoJPG(cPic: TPicture; pWidth: Integer = 0; pHeight: Integer = 0): TJpegImage; stdcall;
implementation

function ConvertPICintoJPG(cPic: TPicture; pWidth: Integer = 0; pHeight: Integer = 0): TJpegImage; stdcall;
var
  tBMP: TBitmap;
begin
  Result := TJpegImage.Create;
  if (pWidth > 0) or (pHeight > 0) then
  begin
    try

      tBMP := TBitmap.Create; //创建一个过渡性BMP图片,用于更改图片尺寸
      if pWidth <= 0 then pWidth := cPic.Width; //若pWidth为有效值则改变tBMP宽度,否则不变
      if pHeight <= 0 then pHeight := cPic.Height; //若pHeight为有效值则改变tBMP高度,否则不变
      tBMP.Width := pWidth;
      tBMP.Height := pHeight;
      tBMP.Canvas.StretchDraw(tBMP.Canvas.ClipRect, cPic.Graphic); //按照新尺寸重画图形
      Result.Assign(tBMP);
    finally
      tBMP.Free;
    end;
  end
  else Result.Assign(cPic);
end;
//uses ShlObj
function GetSystemPath(FID: Integer): string;
var
  pidl: PItemIDList;
  path: array[0..MAX_PATH] of Char;
begin
  SHGetSpecialFolderLocation(0, FID, pidl);
  SHGetPathFromIDList(pidl, path);
  Result := path;
end;
function DownloadToFile(Source, Dest: string): Boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(source), PChar(Dest), 0, nil) = 0;
  except
    Result := False;
  end;
end;
//链接转换为本地文件路径
function url2file(url:string):string;
var
  p,i:integer;
  s,dir,fullDir:string; //forcedirectories(mWorkDir);
begin
  s:=url;
  fullDir:=uConfig.webCache;  //程序工作目录；
  if(rightstr(s,1)='/')then s:=s+'index.htm';
  p:=pos('/',s);
  if(p>0)then
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);  //去除http头部
  if(dir='https:')then s:=rightstr(s,length(s)-8);  //去除https头部
  if pos(':',s)>0 then s:=replacestr(s,':','/');

  p:=pos('/',s);
  while p>0 do begin
    dir:=leftstr(s,p-1);
    fullDir:=fullDir+'\'+dir;
    if(not directoryexists(fullDir))then forcedirectories(fullDir);  //创建本地文件目录
    s:=rightstr(s,length(s)-length(dir)-1);
    p:=pos('/',s);
  end;
  p:=pos('?',s);  //排除链接里面?后面的内容；
  if(p>0)then s:=replacestr(s,'?','$');
  //if(p>0)then s:=leftstr(s,p-1);
  //p:=pos('&',s);  //排除链接里面?后面的内容；
  //if(p>0)then s:=replacestr(s,'&','-');
  //p:=pos('=',s);  //排除链接里面?后面的内容；
  //if(p>0)then s:=replacestr(s,'=','-');
  //if(p>0)then s:=leftstr(s,p-1);
  //p:=pos('#',s);  //排除链接里面?后面的内容；
  //if(p>0)then s:=leftstr(s,p-1);
  result:=fullDir+'\'+s;
end;
//链接转换为本地文件路径
function url2file(ServerName,ObjectName:string;ServerPort:DWORD;var url:string):string;
var
  temp,fullFilePath,fileName,filePath,fileServer:string; //forcedirectories(mWorkDir);
begin
  temp:=ObjectName;
  result:='';
  if(leftstr(temp,1)<>'/')then exit;
  if(rightstr(temp,1)='/')then temp:=temp+'index.htm';
  temp:=replacestr(temp,'/','\');
  filename:=extractfilename(temp);
  filePath:=extractfilepath(temp);
  forceValidFileName(filename);
  case ServerPort of
  80:begin
    fileServer:=ServerName;
    url:='http://'+ServerName+ObjectName;
  end;
  443:begin
    fileServer:=ServerName;
    url:='https://'+ServerName+ObjectName;
  end;
  else begin
    fileServer:=ServerName+'\'+inttostr(ServerPort);
    url:='http://'+ServerName+':'+inttostr(ServerPort)+ObjectName;
  end;
  end;

  fullFilePath:=uConfig.webCache+'\'+fileServer+filePath;
  if not directoryexists(fullFilePath) then  forcedirectories(fullFilePath);

  result:=fullFilePath+filename;
end;
//链接转换为本地文件路径
function url2file(ServerName,ObjectName:string;ServerPort:DWORD):string;
var
  temp,fullFilePath,fileName,filePath,fileServer:string; //forcedirectories(mWorkDir);
begin
  temp:=ObjectName;
  result:='';
  if(leftstr(temp,1)<>'/')then exit;
  if(rightstr(temp,1)='/')then temp:=temp+'index.htm';
  temp:=replacestr(temp,'/','\');
  filename:=extractfilename(temp);
  filePath:=extractfilepath(temp);
  forceValidFileName(filename);
  if(ServerPort<>80)and(ServerPort<>443)then
    fileServer:=ServerName+'\'+inttostr(ServerPort)
  else
    fileServer:=ServerName;
  fullFilePath:=uConfig.webCache+'\'+fileServer+filePath;
  if not directoryexists(fullFilePath) then  forcedirectories(fullFilePath);

  result:=fullFilePath+filename;
end;

function forceValidFileName(var FileName: string): Boolean;
begin
  result:=false;
  if(pos('<',FileName)>0)then FileName:=replacestr(FileName,'<','-');
  if(pos('>',FileName)>0)then FileName:=replacestr(FileName,'>','-');
  if(pos('?',FileName)>0)then FileName:=replacestr(FileName,'?','-');
  if(pos('/',FileName)>0)then FileName:=replacestr(FileName,'/','-');
  if(pos('\',FileName)>0)then FileName:=replacestr(FileName,'\','-');
  if(pos(':',FileName)>0)then FileName:=replacestr(FileName,':','-');
  if(pos('*',FileName)>0)then FileName:=replacestr(FileName,'*','-');
  if(pos('|',FileName)>0)then FileName:=replacestr(FileName,'|','-');
  if(pos('"',FileName)>0)then FileName:=replacestr(FileName,'"','-');
  result:=true;
end;
function IsValidFileName(FileName: string): Boolean;
{
  判断FileName是否是合法的文件名，是，返回True,否则，返回False;
}
var
  i: integer;
begin
  result := True;
  for i := 1 to Length(FileName) do
    if FileName[i] in ['<', '>', '?', '/', '\', ':', '*', '|', '"'] then
    begin
      result := False;
      Exit;
    end;
end;
procedure IEEmulator(VerCode: Integer);
const
  IE_SET_PATH_32='SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
  IE_SET_PATH_64='SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
var
  RegObj: TRegistry;
  sPath:string;
begin
  RegObj := TRegistry.Create;
  try
    //RegObj.RootKey := HKEY_CURRENT_USER;
    RegObj.RootKey := HKEY_LOCAL_MACHINE;
    RegObj.Access := KEY_ALL_ACCESS;
    if isWin64 then sPath := IE_SET_PATH_64 else sPath:=IE_SET_PATH_32;
    if not RegObj.OpenKey(sPath, False) then exit;
    try
      RegObj.WriteInteger(ExtractFileName(ParamStr(0)), VerCode);
      //regobj.READ
    finally
      RegObj.CloseKey;
    end;
  finally
    RegObj.Free;
  end;
end;
function IsWin64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: Bool;
  SystemInfo: TSystemInfo;
const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
begin
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');
  if Kernel32Handle <> 0 then
  begin
    IsWOW64Process := GetProcAddress(Kernel32Handle,'IsWow64Process');
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,'GetNativeSystemInfo');
    if Assigned(IsWow64Process) then
    begin
      IsWow64Process(GetCurrentProcess,isWoW64);
      Result := isWoW64 and Assigned(GetNativeSystemInfo);
      if Result then
      begin
        GetNativeSystemInfo(SystemInfo);
        Result := (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);
      end;
    end
    else Result := False;
  end
  else Result := False;
end;
function my_strtodatetime(str_datetime:string):tdatetime;
var
  fmt: TFormatSettings;
  str_sep,sys_sep,tmp_str:string;
begin
  GetLocaleFormatSettings(GetThreadLocale, fmt);
  str_sep:=midstr(str_datetime,5,1);
  sys_sep:=fmt.DateSeparator;
  tmp_str:=replacestr(str_datetime,str_sep,sys_sep);
  result:=strtodatetime(tmp_str);
end;
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
function saveTofile(filename:string;p:pointer;dwSize:DWORD):boolean;
var
  hFile:cardinal;
  num:DWORD;
begin
  result:=false;
   hFile := CreateFile(pchar(filename), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, 0, 0);
    if (hFile = INVALID_HANDLE_VALUE)then  exit;
  result:=WriteFile(hFile,p^,dwSize,num,nil);
  closehandle(hFile);
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
function ReversePos(SubStr, S: String): Integer;
var
  i : Integer;
begin
  i := Pos(ReverseString(SubStr), ReverseString(S));
  if i > 0 then i := Length(S) - i - Length(SubStr) + 2;
  Result := i;
end;




  function getDateFilename():string;
  var
    s:string;
  begin
    DateTimeToString(s,'yyyymmddhhnnsss',now());
    result:=s;
  end;

function captureScreen(x1:integer;y1:integer;x2:integer;y2:integer):tbitmap;
var
  dc:HDC;
  bmp:tbitmap;
  fullCanvas:TCanvas;
begin
  dc:=GetDC(0);
  fullCanvas:=TCanvas.Create;
  fullCanvas.Handle:=dc;
  bmp:=TBitmap.Create;
  try
    bmp.Width:=abs(x2-x1);
    bmp.Height:=abs(y2-y1);
    bmp.Canvas.CopyRect(Rect(0,0,bmp.Width,bmp.Height),fullCanvas,Rect(x1,y1,x2,y2));
    //bmp.SaveToFile('c:\tmp\1.bmp');
  finally
  end;
  result:=bmp;
end;
function GetDateFormatSep():string;
var
  SysFrset: TFormatSettings;
begin
  Result:='';
  GetLocaleFormatSettings(GetUserDefaultLCID, SysFrset);
  Result:=SysFrset.DateSeparator;  //DateSeparator当前系统日期分隔符
end;
//---------------------------------------------------------------------------------------------------------
procedure SetMyGlobalEnvironment();
const
  KEY_PP_HOME='PP_HOME';//%MYSQL_HOME%
  KEY_PATH='Path';
var
  path:string;
begin
 with TRegistry.Create do
 try
  RootKey:=HKEY_LOCAL_MACHINE;
  if OpenKey('System\CurrentControlSet\Control\Session Manager\Environment',True) then
  begin
    if(ValueExists(KEY_PP_HOME))then begin
      path:=ReadString(KEY_PP_HOME);
      if(path=uConfig.workdir)then exit;
    end;
    WriteString(KEY_PP_HOME,uConfig.workdir);
    path:=ReadString(KEY_PATH); //WriteExpandString
    if(pos(KEY_PP_HOME,path)<=0)then begin
      path:=path+';%'+KEY_PP_HOME+'%';
      WriteExpandString(KEY_PATH,path);
    end;
   SendMessage(HWND_BROADCAST,WM_SETTINGCHANGE,0,Integer(Pchar('Environment')));
  end;
 finally
  Free;
 end;
end;
function ReadPathGlobalEnvironment():string;
const
  KEY_PATH='Path';
begin
 with TRegistry.Create do
 try
  RootKey:=HKEY_LOCAL_MACHINE;
  if OpenKey('System\CurrentControlSet\Control\Session Manager\Environment',True) then
  begin
   result:=ReadString(KEY_PATH); //WriteExpandString
   SendMessage(HWND_BROADCAST,WM_SETTINGCHANGE,0,Integer(Pchar('Environment')));
  end;
 finally
  Free;
 end;
end;
function IsSetGlobalEnvironment(const Name,Value: string):boolean;
var
  path:string;
begin
  result:=false;
 with TRegistry.Create do
 try
  RootKey:=HKEY_LOCAL_MACHINE;
  if OpenKey('System\CurrentControlSet\Control\Session Manager\Environment',True) then
  begin
   if(KeyExists(Name))then begin
     path:=ReadString(Name);
     if(path=Value)then result:=true;
   end;
  end;
 finally
  Free;
 end;
end;
procedure SetGlobalEnvironment(const Name, Value: string);
begin
 with TRegistry.Create do
 try
  RootKey:=HKEY_LOCAL_MACHINE;
  if OpenKey('System\CurrentControlSet\Control\Session Manager\Environment',True) then
  begin
   WriteString(Name,Value);
   SendMessage(HWND_BROADCAST,WM_SETTINGCHANGE,0,Integer(Pchar('Environment')));
  end;
 finally
  Free;
 end;
end;
//---------------------------------------------------------------------------------------------------------
{
 C:\Program Files (x86)\Common Files\Oracle\Java\javapath;C:\ProgramData\Oracle\Java\javapath;d:\Program Files (x86)\Embarcadero\Studio\20.0\bin;C:\Users\Public\Documents\Embarcadero\Studio\20.0\Bpl;d:\Program Files (x86)\Embarcadero\Studio\20.0\bin64;C:\Users\Public\Documents\Embarcadero\Studio\20.0\Bpl\Win64;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\NVIDIA Corporation\PhysX\Common;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;D:\Program Files\Tesseract-OCR;%JAVA_HOME%\bin;%android%;%CATALINA_HOME%\lib;%CATALINA_HOME%\bin;%MYSQL_HOME%\bin;C:\Program Files\dotnet\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\
}
end.
