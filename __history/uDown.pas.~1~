unit uDown;

interface
uses
  windows,sysutils,strutils,classes,urlmon,Messages,uLog;

Const
  WM_DOWN_FILE = WM_USER+1002;
var
  idx:integer;//下载序号
  bDownFiles,bPause:boolean;//下载工作线程变量；
  mDowns:tstrings;
  mForm:HWND;
  //mPage,mPageIdx,mSite,mProtocol,mPort,mWorkDir:string;//主页URL ，站点URL, 协议(http://,https://),工作目录
  mWorkDir:string;//主页URL ，站点URL, 协议(http://,https://),工作目录

function DownloadToFile(Source, Dest: string): Boolean; //uses urlmon;
//procedure downloadfile(url:string);overload; //下载指定链接的文件
function downloadfile(url:string):string;
function url2file(url:string):string;//链接转换为本地文件路径
function getSite(url:string):string;//获取主站地址；
procedure downloadFilesThread();//下载子线程；
//--------------------------------------------------------------------------------------------
procedure stop();
procedure pause();
procedure start();overload;
procedure start(workdir:string;hForm:HWND);overload;
procedure addUrl(url:string);
procedure setWorkDir(workDir:string);
function getPort(url:string):string;
procedure clear;
implementation
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
  idx:=0;
  mDowns.Clear;
end;
procedure addUrl(url:string);
begin
  if(pos(url,mdowns.Text)<=0)then
    mDowns.Add(url);
end;
procedure setWorkDir(workDir:string);
begin
  mWorkDir:=workDir;
end;

//------------------------------------------下载线程区------------------------------------------
function ThreadProc(param: LPVOID): DWORD; stdcall;
var
  url:string;
begin
  idx:=0;
  while bDownFiles do begin
    if(idx>=mDowns.Count)then begin sleep(1000);continue;end;
    if(bPause)then begin sleep(1000);continue;end;
    url:=mDowns[idx];
    PostMessage(mForm, WM_DOWN_FILE,0,idx);
    downloadfile(url);
    idx:=idx+1;
  end;
  PostMessage(mForm, WM_DOWN_FILE,1,idx);
  Result := 0;
end;

procedure downloadFilesThread();
var
  threadId: TThreadID;
begin

  if(bDownFiles)then exit;
  bDownFiles:=true;
  CreateThread(nil, 0, @ThreadProc, nil, 0, threadId);
end;
//------------------------------------------公共函数区----------------------------------------------
//uses urlmon;
function DownloadToFile(Source, Dest: string): Boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(source), PChar(Dest), 0, nil) = 0;
  except
    Result := False;
  end;
end;
//下载指定链接的文件
function downloadfile(url:string):string;
var
  localpath,remotepath:string;
begin
  remotepath:=url;
  if(rightstr(remotepath,1)='/')then remotepath:=remotepath+'index.htm';
  localpath:=url2file(remotepath);
  result:=localpath;
  if(fileexists(localpath))then exit;
  if(DownloadToFile(remotepath,localpath))then begin
    //Log('suc:'+remotepath+#13#10+localpath);
    result:=localpath;
  end else begin
    //Log('fal:'+remotepath+#13#10+localpath);
    result:='';
  end;
end;

//链接转换为本地文件路径
function url2file(url:string):string;
var
  p,i:integer;
  s,dir,fullDir:string; //forcedirectories(mWorkDir);
begin
  s:=url;
  fullDir:=mworkdir;  //程序工作目录；
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
//获取主站地址；
function getSite(url:string):string;
var
  dir,s:string;
  p:integer;
begin
  s:=url;
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);
  if(dir='https:')then s:=rightstr(s,length(s)-8);
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  s:=leftstr(s,p-1);
  result:=s;
end;
//获取主站地址；
function getPort(url:string):string;
var
  dir,s:string;
  p:integer;
begin
  s:=url;
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);
  if(dir='https:')then s:=rightstr(s,length(s)-8);
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  s:=leftstr(s,p-1);
  p:=pos(':',s);
  if(p>0)then s:=rightstr(s,length(s)-p) else s:='';
  result:=s;
end;
initialization
  if not assigned(mDowns) then mDowns:=tstringlist.Create;
finalization
  if assigned(mDowns) then  begin
    mDowns.Clear;
    mDowns.Free;
  end;

{
 //下载指定链接的文件
procedure downloadfile(url:string);
var
  localpath,remotepath:string;
begin
  remotepath:=url;
  if(rightstr(remotepath,1)='/')then remotepath:=remotepath+'index.htm';
  localpath:=url2file(remotepath);
  if(fileexists(localpath))then exit;
  if(DownloadToFile(remotepath,localpath))then
    Log('suc:'+remotepath+#13#10+localpath)
  else
    Log('fal:'+remotepath+#13#10+localpath);
end;

}
end.
