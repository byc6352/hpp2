unit uDataSocket;

interface
uses
   System.SysUtils,windows,WinSock2;
type
  stSocketConnectInfo=record
    s:TSocket;           //保存旧连接信息
    remoteAddr:ansiString;
    localAddr:ansiString;
    remotePort:WORD;
    localPort:WORD;
  end;

procedure SaveSocketDataToFile(dataId:ansiString;s:TSocket; var Buf;len: Integer);
//procedure myCloseHandle(var hFile:HWND);
procedure getSocketConnectInfo(s:TSocket;var socketConnectInfo:stSocketConnectInfo);
implementation
uses
  uConfig,uFuncs,uLog;
var
  hFile:HWND;
  gSocketConnectInfo:stSocketConnectInfo;
procedure getSocketConnectInfo(s:TSocket;var socketConnectInfo:stSocketConnectInfo);
var
  addr:sockaddr;
  addr_v4:sockaddr_in;
  ret,addr_len:integer;
begin
  if(integer(s)=integer(socketConnectInfo.s))then exit;  //还是同一个连接就退出
  socketConnectInfo.s:=s;
  ZeroMemory(@addr, sizeof(addr));
  ret:=getsockname(s, addr, addr_len);
  if(ret<>0)then exit;
  if (addr.sa_family = AF_INET)then
  begin
    addr_v4 := sockaddr_in(addr);
    socketConnectInfo.localAddr:=inet_ntoa(addr_v4.sin_addr);
    socketConnectInfo.localPort:= ntohs(addr_v4.sin_port);
  end;
  ZeroMemory(@addr, sizeof(addr));
  ret:=getpeername(s,  addr, addr_len);
  if(ret<>0)then exit;
  if (addr.sa_family = AF_INET)then
  begin
    addr_v4:= sockaddr_in(addr);
    socketConnectInfo.remoteAddr := inet_ntoa(addr_v4.sin_addr);
    socketConnectInfo.remotePort:= ntohs(addr_v4.sin_port);
  end;
end;
procedure SaveSocketDataToFile(dataId:ansiString;s:TSocket; var Buf;len: Integer);
var
  header:ansistring;
  lpNumberOfBytesWritten,lpNumberOfBytesWrittenSum:DWORD;
  ret:BOOL;
begin
  if(len<=0)then exit;
  try
    if (hFile=0) then
    begin
      hFile:=CreateFile(pchar(uConfig.socketFile),GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,nil,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
      if(hFile = INVALID_HANDLE_VALUE)then exit;
      //Log('hFile:'+dataId);
      //dwFileSize:=getFileSize(hFile,@dwFileSize);
      setFilePointer(hFile,0,nil,FILE_END);
    end;
    getSocketConnectInfo(s,gSocketConnectInfo);
    header:=#13#10#13#10+getDateTimeString(now(),0)+'--------'+dataId+'--------local:('+gSocketConnectInfo.localAddr
      +'  port:'+inttostr(gSocketConnectInfo.localPort)+')remote:(' +gSocketConnectInfo.remoteAddr+'  port:'+inttostr(gSocketConnectInfo.remotePort)+')'+#13#10#13#10;
    ret:=writeFile(hFile,header[1],length(header),lpNumberOfBytesWritten,0);
    if(ret=false)then begin CloseHandle(hFile);hFile:=0;exit;end;

    lpNumberOfBytesWritten:=0;
    lpNumberOfBytesWrittenSum:=0;
    while(lpNumberOfBytesWrittenSum<len)do
    begin
      ret:=writeFile(hFile,Buf,len,lpNumberOfBytesWritten,0);
      if(ret=false)then begin CloseHandle(hFile);hFile:=0;exit;end;
      lpNumberOfBytesWrittenSum:=lpNumberOfBytesWrittenSum+lpNumberOfBytesWritten;
    end;
    FlushFileBuffers(hFile);
  finally

  end;
end;
procedure myCloseHandle(var hFile:HWND);
begin
  if(hFile<>0)then
  begin
    closeHandle(hFile);
    hFile:=0;
  end;
end;


initialization

finalization
   myCloseHandle(hFile);
end.
