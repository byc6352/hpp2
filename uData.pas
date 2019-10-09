unit uData;

interface
uses
  windows,sysutils,uFuncs,uConfig,classes;
const
  MAX_RECORD=10000;//最大记录数；
  DATA_TYPE_REQUEST=0;//请求的数据；
  DATA_TYPE_REPONSE=1;//返回的数据；
type
  stData=record
    wRequest:DWORD;
    ServerPort:DWORD;
    dataLen:DWORD;
    dt:tdatetime; //时间
    ServerName:string;//服务器名称；
    ObjectName:string;   //请求对象
    verb:string;  //请求方法
    len:string;   //数据长度
    qHeader:string; //讲求头
    rHeader:string; //返回头
    qData:string; //发送数据
    rData:string; //返回数据
  end;
stServer=record  //服务器信息；
  wConnect:DWORD;
  ServerPort:DWORD;
  ServerName:string;//服务器名称；
end;

var
  server:stServer;
  datas:array[0..MAX_RECORD] of stData;
  iData:integer;//当前记录指针；
  //hLocalFile:HWND;

function addUrl(wConnect,wRequest:DWORD;ObjectName:string;verb:string):integer;
  //添加qHeader,rHeader,len;
function addHeader(wRequest:DWORD;qHeader:string;rHeader:string;len:string):integer;
//添加addData;
function addData(wRequest:DWORD;dType:DWORD;p:pointer;len:DWORD):integer;
//
procedure clear;
//
function saveData():string;

function saveHeader():string;

implementation

//添加URL,verb;
function addUrl(wConnect,wRequest:DWORD;ObjectName:string;verb:string):integer;
begin
  if(wConnect=server.wConnect)then begin
    datas[iData].ServerName:=server.ServerName;
    datas[iData].ServerPort:=server.ServerPort;
  end;
  datas[iData].wRequest:=wRequest;
  datas[iData].dt:=now();
  datas[iData].ObjectName:=ObjectName;
  datas[iData].verb:=verb;
  iData:=iData+1;
  if(iData>=MAX_RECORD)then iData:=0;
  result:=iData;
end;
//添加qHeader,rHeader,len;
function addHeader(wRequest:DWORD;qHeader:string;rHeader:string;len:string):integer;
begin
  result:=-1;
  if(wRequest<>datas[iData-1].wRequest)then exit;
  datas[iData-1].qHeader:=qHeader;
  datas[iData-1].rHeader:=rHeader;
  datas[iData-1].len:=len;
  result:=iData-1;
end;
//添加addData;
function addData(wRequest:DWORD;dType:DWORD;p:pointer;len:DWORD):integer;
var
  filename:string;
begin
  //result:=-1;
  //if(wRequest<>datas[iData].wRequest)then exit;
  if(dType=DATA_TYPE_REQUEST)then begin
    filename:=uFuncs.getFilename(uConfig.webCache,'request','.txt');
    datas[iData-1].qData:=filename;
  end else begin
    filename:=uFuncs.getFilename(uConfig.webCache,'reponse','.txt');
    datas[iData-1].rData:=filename;
  end;
  uFuncs.saveTofile(filename,p,len);
  result:=iData-1;
end;
//
procedure clear;
begin
  iData:=0;
end;
function saveHeader():string;
var
  ss:tstrings;
  stime:string;
  i:integer;
begin
  result:='';
  if idata=0 then exit;
  ss:=tstringList.Create;
  for I := 0 to iData-1 do
  begin
    stime:=ufuncs.getDateTimeString(datas[i].dt,0); //
    ss.Add(stime+'--------------------Request Object--------------------');
    ss.Add(datas[i].ObjectName);
    ss.Add('');
    ss.Add('');
    ss.Add(stime+'--------------------Request Header--------------------');
    ss.Add(datas[i].qHeader);
    ss.Add(stime+'--------------------Response Header--------------------');
    ss.Add(datas[i].rHeader);
    ss.Add(stime+'--------------------Response file----------------------');
    ss.Add(datas[i].rData);
    ss.Add('');
    ss.Add('');
    ss.Add('=================================================================================================');
    ss.Add('');
    ss.Add('');
  end;
  result:=getFileName(uConfig.datadir,'header','.txt');
  ss.SaveToFile(result);
  ss.Free;
end;
function saveData():string;
var
  s,stime,ServerName,sPort,ObjectName,verb,len,dataLen,qData,rData:string;
  ss:tstrings;
  i:integer;
begin
  if(idata=0)then exit;
  ss:=tstringlist.Create;
  stime:='datetime'; //2019-09-18 14:48:33
  stime:=stime+Stringofchar(' ',32-length(stime));

  verb:='verb';
  verb:=verb+Stringofchar(' ',8-length(verb));

  ServerName:='ServerName';
  ServerName:=ServerName+Stringofchar(' ',32-length(ServerName));

  sPort:='ServerPort';
  sPort:=sPort+Stringofchar(' ',16-length(sPort));

  ObjectName:='ObjectName';
  ObjectName:=ObjectName+Stringofchar(' ',128-length(ObjectName));

  len:='len';
  len:=len+Stringofchar(' ',12-length(len));

  dataLen:='dataLen';
  dataLen:=dataLen+Stringofchar(' ',12-length(dataLen));

  qData:='request data';
  qData:=qData+Stringofchar(' ',64-length(qData));

  rData:='response data';
  rData:=rData+Stringofchar(' ',64-length(rData));
  s:=stime+verb+Servername+sPort+ObjectName+len+dataLen+qData+rData;
  ss.Add(s);
  for I := 0 to iData-1 do
  begin
    stime:=ufuncs.getDateTimeString(datas[i].dt,0); //
    stime:=stime+Stringofchar(' ',32-length(stime));

    verb:=datas[i].verb;
    verb:=verb+Stringofchar(' ',8-length(verb));

    ServerName:=datas[i].ServerName;
    ServerName:=ServerName+Stringofchar(' ',32-length(ServerName));

    sPort:=inttostr(datas[i].ServerPort);
    sPort:=sPort+Stringofchar(' ',16-length(sPort));

    ObjectName:=datas[i].ObjectName;
    ObjectName:=ObjectName+Stringofchar(' ',128-length(ObjectName));

    len:=datas[i].len;
    len:=len+Stringofchar(' ',12-length(len));

    dataLen:=inttostr(datas[i].dataLen);
    dataLen:=dataLen+Stringofchar(' ',12-length(dataLen));

    qData:=datas[i].qData;
    qData:=qData+Stringofchar(' ',64-length(qData));

    rData:=datas[i].rData;
    rData:=rData+Stringofchar(' ',64-length(rData));
    s:=stime+verb+Servername+sPort+ObjectName+len+dataLen+qData+rData;
    ss.Add(s);
  end;
  result:=getFileName(uConfig.datadir,'all','.txt');
  ss.SaveToFile(result);
  ss.Free;
end;



{
//
procedure myCloseHandle(wInet:DWORD);

procedure SaveFile(wFile: DWORD; lpBuffer: Pointer;lpdwNumberOfBytesRead: DWORD);

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
    if(hLocalFile<>0)then exit;
    uData.datas[idata-1].qData:=localFilename;
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

}
end.
