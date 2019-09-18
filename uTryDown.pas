unit uTryDown;

interface
uses
  windows,sysutils,strutils,ufuncs,udataDown;
var
  gRemotePath,gLocalPath,gExtFileName:string;
  bDownFiles:boolean=true;
procedure tryDownloadFiles(remotePath,localPath,extFileName:string);overload;
procedure tryDownloadFiles(remotePath,extFileName:string);overload;
procedure tryDownloadFiles(remoteFilename:string);overload;
implementation
uses
  uHookWeb;
//------------------------------------------�����߳���------------------------------------------
function ThreadProc(param: LPVOID): DWORD; stdcall;
var
  i:integer;//��ǰ�������
  remotefile,localfile,filename,remotePath,localpath,extFilename:string;
begin
  remotePath:=gRemotepath;
  localpath:=gLocalPath;
  extFilename:=gExtfilename;
  if(remotePath[length(remotepath)]<>'/')then remotePath:=remotePath+'/';
  if(localpath[length(localpath)]<>'\')then localpath:=localpath+'\';
  uHookWeb.bHook:=false;
  for i := 1 to 10000 do begin
    if(not bDownFiles)then break;
    filename:=inttostr(i)+extFilename;
    remotefile:=remotePath+filename;
    localfile:=localpath+filename;
    if(DownloadToFile(remotefile,localfile))then begin
      PostMessage(mForm, WM_DOWN_FILE,2,i);
    end;
  end;
  uHookWeb.bHook:=true;
  PostMessage(mForm, WM_DOWN_FILE,3,i);
  Result := 0;
end;
procedure tryDownloadFiles(remoteFilename:string);
var
  localpath,remotePath,localFileName,extFileName:string;
  i:integer;
begin
  localFileName:=uFuncs.url2file(remoteFilename);
  i:=uFuncs.ReversePos('/',remoteFileName);
  remotePath:=leftstr(remoteFilename,i);
  localpath:=extractfilePath(localFileName);
  extFileName:=extractFileExt(localFileName);
  tryDownloadFiles(remotePath,localpath,extFileName);
end;
procedure tryDownloadFiles(remotePath,extFileName:string);
var
  localpath,localFileName:string;
begin
  localFileName:=uFuncs.url2file(remotePath);
  localpath:=extractfilePath(localFileName);
  tryDownloadFiles(remotePath,localpath,extFileName);
end;
procedure tryDownloadFiles(remotePath,localPath,extFileName:string);
var
  threadId: TThreadID;
begin
  bDownFiles:=true;
  gRemotePath:=RemotePath;
  gLocalPath:=localPath;
  gExtFileName:=extFileName;
  CreateThread(nil, 0, @ThreadProc, nil, 0, threadId);
end;
end.