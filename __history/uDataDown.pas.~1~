unit uDataDown;

interface
uses
  winapi.windows,sysutils,strutils,messages;
Const
  WM_DOWN_FILE = WM_USER+1002;
var
  iDown:integer;//下载序号
  bDownFiles,bPause:boolean;//下载工作线程变量；
  hLocalFile:HWND;
  mForm:HWND;
procedure SaveFile(wFile: DWORD; lpBuffer: Pointer;lpdwNumberOfBytesRead: DWORD);

procedure myCloseHandle(wInet:DWORD);
procedure myCloseFileHandle(var hFile:HWND);
function GetLocalFileNameFromIECache(url:string;var CacheFileName:string):DWORD;
function ThreadProc(param: LPVOID): DWORD; stdcall;
function downloadfile(idx:integer):string;
procedure downloadFilesThread();
//--------------------------------------------------------------------------------------------
procedure stop();
procedure pause();
procedure start();overload;
procedure start(workdir:string;hForm:HWND);overload;
procedure clear;
implementation
uses
  uData,uConfig,uFuncs,winInet;
var
  mWorkDir:string;
procedure myCloseFileHandle(var hFile:HWND);
begin
  if(hFile=0)then exit;
  try
    closeHandle(hFile);
  finally
    hFile:=0;
  end;

end;
procedure myCloseHandle(wInet:DWORD);
begin
  if(wInet<>uData.datas[idata-1].wRequest)then exit;
  if(hLocalFile<>0)then begin
    closeHandle(hLocalFile);
    hLocalFile:=0;
  end;
end;
procedure SaveFile(wFile: DWORD; lpBuffer: Pointer;lpdwNumberOfBytesRead: DWORD);
var
  localFileName,ServerName,ObjectName:string;
  ServerPort:DWORD;
  lpNumberOfBytesWritten:DWORD;
  ret:BOOL;
begin
  if(wFile<>uData.datas[idata-1].wRequest)then exit;
  try
  if(uData.datas[idata-1].dataLen=0)then begin
    ServerName:=uData.datas[idata-1].ServerName;
    ObjectName:=uData.datas[idata-1].ObjectName;
    ServerPort:=uData.datas[idata-1].ServerPort;
    localFileName:=url2file(ServerName,ObjectName,ServerPort);
    if(localFileName='')then exit;
    if(fileexists(localFileName))then exit;
    if(hLocalFile<>0)then myCloseFileHandle(hLocalFile);
    uData.datas[idata-1].rData:=localFilename;
    hLocalFile:=CreateFile(pchar(localFileName),GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
    if(hLocalFile = INVALID_HANDLE_VALUE)then exit;
  end else begin
    if(hLocalFile=0)then exit;
  end;
  lpNumberOfBytesWritten:=0;
  while(lpNumberOfBytesWritten<lpdwNumberOfBytesRead)do
  begin
    ret:=writeFile(hLocalFile,lpBuffer^,lpdwNumberOfBytesRead,lpNumberOfBytesWritten,0);
    if(ret=false)then begin CloseHandle(hLocalFile);hLocalFile:=0;exit;end;
  end;
  finally
    uData.datas[idata-1].dataLen:=uData.datas[idata-1].dataLen+lpdwNumberOfBytesRead;
  end;

end;

//------------------------------------------启动，暂停，停止区---------------------------------
procedure stop();
begin
  bDownFiles:=false;
end;
procedure pause();
begin
  bPause:=true;
end;
procedure start(workdir:string;hForm:HWND);
begin
  mworkdir:=workdir;
  mForm:=hForm;
  start();
end;
procedure start();
begin
  bPause:=false;
  downloadFilesThread();
end;
procedure clear();
begin
  iDown:=0;
end;
//------------------------------------------下载线程区------------------------------------------
procedure downloadFilesThread();
var
  threadId: TThreadID;
begin
  if(bDownFiles)then exit;
  bDownFiles:=true;
  CreateThread(nil, 0, @ThreadProc, nil, 0, threadId);
end;
function ThreadProc(param: LPVOID): DWORD; stdcall;
begin
  iDown:=0;
  while bDownFiles do begin
    if(iDown>uData.iData-1)then begin sleep(1000);continue;end;
    if(bPause)then begin sleep(1000);continue;end;
    if(iDown=uData.iData-1)then begin sleep(1000);end;

    downloadfile(iDown);
    PostMessage(mForm, WM_DOWN_FILE,0,iDown);

    iDown:=iDown+1;
  end;
  PostMessage(mForm, WM_DOWN_FILE,1,iDown);
  Result := 0;
end;
//下载指定链接的文件
function downloadfile(idx:integer):string;
var
  CacheFileName,localFileName:string;
  url,ServerName,ObjectName:string;
  ServerPort,ret:DWORD;
begin
  result:='';
  ServerName:=uData.datas[idx].ServerName;
  ObjectName:=uData.datas[idx].ObjectName;
  ServerPort:=uData.datas[idx].ServerPort;
  localFileName:=url2file(ServerName,ObjectName,ServerPort,url);
  if(localFileName='')then exit;

  if(fileExists(localFileName))then begin
    result:=localFileName;
    uData.datas[idx].rData:=localFileName;
    exit;
  end;

  ret:=GetLocalFileNameFromIECache(url,CacheFileName);
  if(ret=S_OK)then begin
    if(CopyFile(pchar(CacheFileName),pchar(localFileName),false))then begin
      result:=localFileName;
      uData.datas[idx].rData:=localFileName;
    end else begin
      //result:='';
    end;
  end else begin //remote file

  end;
end;

function GetLocalFileNameFromIECache(url:string;var CacheFileName:string):DWORD;
var
D: Cardinal;
T: PInternetCacheEntryInfo;
begin
  result := S_OK;
  D := 0;
  T:=nil;
  GetUrlCacheEntryInfo(PChar(Url), T^, D);
  Getmem(T, D);
  try
    if (GetUrlCacheEntryInfo(PChar(Url), T^, D)) then
    begin
      CacheFileName:=T^.lpszLocalFileName;
    end else
      Result := GetLastError;
  finally
    Freemem(T, D);
  end;
end;

initialization
  if not uConfig.isInit then uConfig.init();
  mWorkDir:=uConfig.webCache;
finalization

end.
