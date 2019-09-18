unit uDown;

interface
uses
  windows,sysutils,strutils,classes,urlmon,Messages,uLog;

Const
  WM_DOWN_FILE = WM_USER+1002;

  DOWN_STAT_STOP=0;
  DOWN_STAT_PAUSE=1;
  DOWN_STAT_IDLE=2;
  DOWN_STAT_WORKING=3;
var
  idx,mState:integer;//�������
  bDownFiles,bPause:boolean;//���ع����̱߳�����
  mDowns:tstrings;
  mForm:HWND;
  //mPage,mPageIdx,mSite,mProtocol,mPort,mWorkDir:string;//��ҳURL ��վ��URL, Э��(http://,https://),����Ŀ¼
  mWorkDir:string;//��ҳURL ��վ��URL, Э��(http://,https://),����Ŀ¼

function DownloadToFile(Source, Dest: string): Boolean; //uses urlmon;
//procedure downloadfile(url:string);overload; //����ָ�����ӵ��ļ�
function downloadfile(url:string):string;
function url2file(url:string):string;//����ת��Ϊ�����ļ�·��
function getSite(url:string):string;//��ȡ��վ��ַ��
procedure downloadFilesThread();//�������̣߳�
procedure setWorkDir(workDir:string);
function getPort(url:string):string;
//--------------------------------------------------------------------------------------------
procedure stop();
procedure pause();
procedure start();overload;
procedure start(workdir:string;hForm:HWND);overload;
procedure addUrl(url:string);
procedure clear;
function getState():integer;
implementation

//------------------------------------------��������ͣ��ֹͣ��---------------------------------
function getState():integer;
begin
  result:=mState;
end;
procedure stop();
begin
  bDownFiles:=false;
  mState:=DOWN_STAT_STOP;
end;
procedure pause();
begin
  bPause:=true;
  mState:=DOWN_STAT_PAUSE;
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

//------------------------------------------�����߳���------------------------------------------
function ThreadProc(param: LPVOID): DWORD; stdcall;
var
  url:string;
begin
  idx:=0;
  while bDownFiles do begin
    if(idx>=mDowns.Count)then begin sleep(1000); mState:=DOWN_STAT_IDLE;continue;end;
    if(bPause)then begin sleep(1000);mState:=DOWN_STAT_PAUSE;continue;end;
    url:=mDowns[idx];
    if(url='')then continue;
    mState:=DOWN_STAT_WORKING;
    if(downloadfile(url)='')then
      PostMessage(mForm, WM_DOWN_FILE,0,idx)
    else
      PostMessage(mForm, WM_DOWN_FILE,1,idx);
    idx:=idx+1;
  end;
  //PostMessage(mForm, WM_DOWN_FILE,1,idx);
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
//------------------------------------------����������----------------------------------------------

//uses urlmon;
function DownloadToFile(Source, Dest: string): Boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(source), PChar(Dest), 0, nil) = 0;
  except
    Result := False;
  end;
end;

//����ָ�����ӵ��ļ�
function downloadfile(url:string):string;
var
  localpath:string;
begin
  localpath:=url2file(url);
  result:=localpath;
  if(fileexists(localpath))then exit;
  if(DownloadToFile(url,localpath))then begin
    //Log('suc:'+remotepath+#13#10+localpath);
    result:=localpath;
  end else begin
    //Log('fal:'+remotepath+#13#10+localpath);
    result:='';
  end;
end;

//����ת��Ϊ�����ļ�·��
function url2file(url:string):string;
var
  p,i:integer;
  s,dir,fullDir:string; //forcedirectories(mWorkDir);
begin
  s:=url;
  fullDir:=mworkdir;  //������Ŀ¼��
  if(rightstr(s,1)='/')then s:=s+'index.htm';
  p:=pos('/',s);
  if(p>0)then
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);  //ȥ��httpͷ��
  if(dir='https:')then s:=rightstr(s,length(s)-8);  //ȥ��httpsͷ��
  if pos(':',s)>0 then s:=replacestr(s,':','/');

  p:=pos('/',s);
  while p>0 do begin
    dir:=leftstr(s,p-1);
    fullDir:=fullDir+'\'+dir;
    if(not directoryexists(fullDir))then forcedirectories(fullDir);  //���������ļ�Ŀ¼
    s:=rightstr(s,length(s)-length(dir)-1);
    p:=pos('/',s);
  end;
  p:=pos('?',s);  //�ų���������?��������ݣ�
  if(p>0)then s:=replacestr(s,'?','$');
  //if(p>0)then s:=leftstr(s,p-1);
  //p:=pos('&',s);  //�ų���������?��������ݣ�
  //if(p>0)then s:=replacestr(s,'&','-');
  //p:=pos('=',s);  //�ų���������?��������ݣ�
  //if(p>0)then s:=replacestr(s,'=','-');
  //if(p>0)then s:=leftstr(s,p-1);
  //p:=pos('#',s);  //�ų���������?��������ݣ�
  //if(p>0)then s:=leftstr(s,p-1);
  result:=fullDir+'\'+s;
end;
//��ȡ��վ��ַ��
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
//��ȡ��վ��ַ��
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
 //����ָ�����ӵ��ļ�
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