unit uHookWeb;

interface
uses windows,WinSock2,Messages,WININET,uFuncs,uConfig,uCoding,uData;
const
  WM_CAP_WORK = WM_USER+1001;
  STAT_BROWSING=0;
  STAT_IDLE=1;

var
  state:integer; //浏览器状态：STAT_BROWSING正在加载页面；STAT_IDLE空闲；

  original_InternetSetCookieEx : function(lpszUrl, lpszCookieName,lpszCookieData: LPCWSTR; dwFlags: DWORD; lpReserved: Pointer): DWORD; stdcall;

  original_Send: function(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;

  original_Recv:function (s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;

  original_InternetOpenUrlW:function (hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpOpenRequestW
  original_HttpOpenRequestW:function (hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpSendRequestA
  original_HttpSendRequestA:function(hRequest: HINTERNET; lpszHeaders: LPSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestW
  original_HttpSendRequestW:function(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestEx
  original_HttpSendRequestExW:function(hRequest: HINTERNET; lpBuffersIn: PInternetBuffersW;
    lpBuffersOut: PInternetBuffersW;
    dwFlags: DWORD; dwContext: DWORD_PTR): BOOL; stdcall;
  //HttpAddRequestHeadersW
  original_HttpAddRequestHeadersW:function(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall;
  //InternetReadFile
  original_InternetReadFile:function(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
  //HttpQueryInfoW
  original_HttpQueryInfoW:function(hRequest: HINTERNET; dwInfoLevel: DWORD;
  lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  var lpdwReserved: DWORD): BOOL; stdcall;
  //InternetWriteFile
  original_InternetWriteFile:function(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToWrite: DWORD;
  var lpdwNumberOfBytesWritten: DWORD): BOOL; stdcall;
  //InternetConnectW
  original_InternetConnectW:function(hInet: HINTERNET; lpszServerName: LPWSTR;
  nServerPort: INTERNET_PORT; lpszUsername: LPWSTR; lpszPassword: LPWSTR;
  dwService: DWORD; dwFlags: DWORD; dwContext: DWORD_PTR): HINTERNET; stdcall;


  function replaced_InternetOpenUrlW(hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpOpenRequestW
  function replaced_HttpOpenRequestW(hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpSendRequestA
  function replaced_HttpSendRequestA(hRequest: HINTERNET; lpszHeaders: LPSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestW
  function replaced_HttpSendRequestW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestEx
  function replaced_HttpSendRequestExW(hRequest: HINTERNET; lpBuffersIn: PInternetBuffersW;
    lpBuffersOut: PInternetBuffersW;
    dwFlags: DWORD; dwContext: DWORD_PTR): BOOL; stdcall;
  //HttpAddRequestHeadersW
  function replaced_HttpAddRequestHeadersW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall;
  //InternetReadFile
  function replaced_InternetReadFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
  //HttpQueryInfoW
  function replaced_HttpQueryInfoW(hRequest: HINTERNET; dwInfoLevel: DWORD;
  lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  var lpdwReserved: DWORD): BOOL; stdcall;
  //InternetWriteFile
  function replaced_InternetWriteFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToWrite: DWORD;
  var lpdwNumberOfBytesWritten: DWORD): BOOL; stdcall;
  //InternetConnectW
  function replaced_InternetConnectW(hInet: HINTERNET; lpszServerName: LPWSTR;
  nServerPort: INTERNET_PORT; lpszUsername: LPWSTR; lpszPassword: LPWSTR;
  dwService: DWORD; dwFlags: DWORD; dwContext: DWORD_PTR): HINTERNET; stdcall;

  procedure UnHookWebAPI;
  procedure HookWebAPI;
implementation
uses
  HookUtils;
  //InternetConnectW
function replaced_InternetConnectW(hInet: HINTERNET; lpszServerName: LPWSTR;
  nServerPort: INTERNET_PORT; lpszUsername: LPWSTR; lpszPassword: LPWSTR;
  dwService: DWORD; dwFlags: DWORD; dwContext: DWORD_PTR): HINTERNET; stdcall;
begin
  result:=original_InternetConnectW(hInet,lpszServerName,nServerPort,lpszUsername,lpszPassword,dwService,dwFlags,dwContext);
  //udata.addUrl(DWORD(result),lpszObjectName,lpszVerb);
  server.wConnect:=DWORD(result);
  server.ServerPort:=nServerPort;
  server.ServerName:=lpszServerName;
end;
//HttpQueryInfoW
function replaced_HttpQueryInfoW(hRequest: HINTERNET; dwInfoLevel: DWORD;
  lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  var lpdwReserved: DWORD): BOOL; stdcall;
var
  tmp:DWORD;
  buf:array[0..10*1023] of char;
  qHeader,rHeader,datalen:string;
begin
  //MessageBeep(2000); //简单的响一声
  if(dwInfoLevel=HTTP_QUERY_RAW_HEADERS_CRLF)then begin
    tmp:=1024*10;
    zeromemory(@buf[0],10*1024);
    if(original_HttpQueryInfoW(hRequest,HTTP_QUERY_FLAG_REQUEST_HEADERS or HTTP_QUERY_RAW_HEADERS_CRLF,@buf[0],tmp,lpdwReserved))then begin
      qHeader:=buf;
      //sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,1);
    end else qHeader:='';
    tmp:=1024*10;
    zeromemory(@buf[0],10*1024);
    if(original_HttpQueryInfoW(hRequest,HTTP_QUERY_CONTENT_LENGTH,@buf[0],tmp,lpdwReserved))then begin
      datalen:=buf;
      //sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,2);
    end else datalen:='';
  end;

  result:=original_HttpQueryInfoW(hRequest,dwInfoLevel,lpvBuffer,lpdwBufferLength,lpdwReserved);
  //这儿进行接收的数据处理
  if(dwInfoLevel=HTTP_QUERY_RAW_HEADERS_CRLF)and (result=true)then begin
    rHeader:=pchar(lpvBuffer);
    udata.addHeader(DWORD(hRequest),qHeader,rHeader,datalen);
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    //if not debug then sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,0);
  end;
  {
  if(dwInfoLevel=HTTP_QUERY_CONTENT_LENGTH)then begin
    gLength:=pchar(lpvBuffer);
    MessageBeep(2000); //简单的响一声
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,2);
  end;
  if(dwInfoLevel=HTTP_QUERY_FLAG_REQUEST_HEADERS or HTTP_QUERY_RAW_HEADERS_CRLF)then begin
    gQHeaders:=pchar(lpvBuffer);
    MessageBeep(2000); //简单的响一声
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,1);
  end;

  if(dwInfoLevel=HTTP_QUERY_RAW_HEADERS)then begin
    gRHeaders:=pchar(lpvBuffer);
    MessageBeep(2000); //简单的响一声
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,0);
  end;
  }
end;
//HttpOpenRequestW
function replaced_HttpOpenRequestW(hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;

begin
  result:=original_HttpOpenRequestW(hConnect,lpszVerb,lpszObjectName,lpszVersion,lpszReferrer,lplpszAcceptTypes,dwFlags,dwContext);
  udata.addUrl(DWORD(hConnect),DWORD(result),lpszObjectName,lpszVerb);
end;

//HttpSendRequestA
function replaced_HttpSendRequestA(hRequest: HINTERNET; lpszHeaders: LPSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
begin
  //这儿进行接收的数据处理
  if(dwHeadersLength>0)then begin
    //sendMessage(hform, WM_CAP_WORK,IDX_HttpSendRequestW,0);
    //MessageBeep(2000); //简单的响一声
  end;
  result:=original_HttpSendRequestA(hRequest,lpszHeaders,dwHeadersLength,lpOptional,dwOptionalLength);
end;

 //HttpSendRequestW
function replaced_HttpSendRequestW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
var
  s:string;
begin

  result:=original_HttpSendRequestW(hRequest,lpszHeaders,dwHeadersLength,lpOptional,dwOptionalLength);
  //这儿进行接收的数据处理
  if(dwHeadersLength>0)then begin
    //gqHeaders:=lpszHeaders;
    //if not debug then sendMessage(hform, WM_CAP_WORK,IDX_HttpSendRequestW,0);
    s:=lpszHeaders;
    MessageBeep(2000); //简单的响一声
  end;
  if(dwOptionalLength>0)then begin
    //gQData:=pchar(lpOptional);
    //if not debug then sendMessage(hform, WM_CAP_WORK,IDX_HttpSendRequestW,0);
    s:=pchar(lpOptional);
    MessageBeep(2000); //简单的响一声
  end;
end;

  //HttpSendRequestEx
function replaced_HttpSendRequestExW(hRequest: HINTERNET; lpBuffersIn: PInternetBuffersW;
    lpBuffersOut: PInternetBuffersW;
    dwFlags: DWORD; dwContext: DWORD_PTR): BOOL; stdcall;
begin
  //这儿进行接收的数据处理
  //MessageBeep(10); //简单的响一声
  result:=original_HttpSendRequestExW(hRequest,lpBuffersIn,lpBuffersOut,dwFlags,dwContext);
end;

  //HttpAddRequestHeadersW
function replaced_HttpAddRequestHeadersW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall;
var
  gQHeaders:string;
begin
  //这儿进行接收的数据处理
  if(dwHeadersLength>0)then begin
    gQHeaders:=lpszHeaders;
    //if not debug then SendMessage(hform, WM_CAP_WORK,IDX_HttpAddRequestHeadersW,0);
    //MessageBeep(2000); //简单的响一声
  end;
  result:=original_HttpAddRequestHeadersW(hRequest,lpszHeaders,dwHeadersLength,dwModifiers);
end;

  //InternetReadFile
function replaced_InternetReadFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
begin
  result:=original_InternetReadFile(hFile,lpBuffer,dwNumberOfBytesToRead,lpdwNumberOfBytesRead);
  if not result then exit;
  //这儿进行接收的数据处理
  if((lpdwNumberOfBytesRead>0) and (lpdwNumberOfBytesRead<100))or(state=STAT_IDLE)or(uData.datas[iData-1].verb='POST')then begin
    MessageBeep(100); //简单的响一声
    uData.addData(DWORD(hFile),uData.DATA_TYPE_REPONSE,lpBuffer,lpdwNumberOfBytesRead);
  end;

end;
  //InternetWriteFile
function replaced_InternetWriteFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToWrite: DWORD;
  var lpdwNumberOfBytesWritten: DWORD): BOOL; stdcall;
begin
  //这儿进行接收的数据处理
  MessageBeep(100); //简单的响一声
  uData.addData(DWORD(hFile),uData.DATA_TYPE_REQUEST,lpBuffer,dwNumberOfBytesToWrite);
  result:=original_InternetWriteFile(hFile,lpBuffer,dwNumberOfBytesToWrite,lpdwNumberOfBytesWritten);
end;

function replaced_InternetOpenUrlW(hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;
begin
  //这儿进行接收的数据处理
  //MessageBeep(2000); //简单的响一声
  result:=original_InternetOpenUrlW(hInet,lpszUrl,lpszHeaders,dwHeadersLength,dwFlags,dwContext);
end;

{------------------------------------}
{过程功能:HookAPI
{过程参数:无
{------------------------------------}
procedure HookWebAPI;
begin
  if not(Assigned(original_InternetOpenUrlW)) then
  begin
    //@original_InternetOpenUrlW := HookProcInModule('WININET.dll', 'InternetOpenUrlW', @replaced_InternetOpenUrlW);
  end;

  if not(Assigned(original_HttpOpenRequestW)) then
  begin
    @original_HttpOpenRequestW := HookProcInModule('wininet.dll', 'HttpOpenRequestW', @replaced_HttpOpenRequestW);
  end;

  if not(Assigned(original_HttpSendRequestA)) then
  begin
    //@original_HttpSendRequestA := HookProcInModule('wininet.dll', 'HttpSendRequestA', @replaced_HttpSendRequestA);

  end;

  if not(Assigned(original_HttpSendRequestW)) then
  begin
    @original_HttpSendRequestW := HookProcInModule('wininet.dll', 'HttpSendRequestW', @replaced_HttpSendRequestW);
  end;

  if not(Assigned(original_HttpSendRequestExW)) then
  begin
    @original_HttpSendRequestExW:= HookProcInModule('wininet.dll', 'HttpSendRequestExW', @replaced_HttpSendRequestExW);
  end;

  if not(Assigned(original_HttpAddRequestHeadersW)) then
  begin
    @original_HttpAddRequestHeadersW := HookProcInModule('wininet.dll', 'HttpAddRequestHeadersW', @replaced_HttpAddRequestHeadersW);
  end;

  if not(Assigned(original_InternetReadFile)) then
  begin
    @original_InternetReadFile := HookProcInModule('wininet.dll', 'InternetReadFile', @replaced_InternetReadFile);
  end;

  if not(Assigned(original_HttpQueryInfoW)) then
  begin
    @original_HttpQueryInfoW := HookProcInModule('wininet.dll', 'HttpQueryInfoW', @replaced_HttpQueryInfoW);
  end;
  //InternetWriteFile
  if not(Assigned(original_InternetWriteFile)) then
  begin
    @original_InternetWriteFile := HookProcInModule('wininet.dll', 'InternetWriteFile', @replaced_InternetWriteFile);
  end;
  //InternetConnectW
  if not(Assigned(original_InternetConnectW)) then
  begin
    @original_InternetConnectW := HookProcInModule('wininet.dll', 'InternetConnectW', @replaced_InternetConnectW);
  end;
end;
{------------------------------------}
{过程功能:取消HOOKAPI
{过程参数:无
{------------------------------------}
procedure UnHookWebAPI;
begin
  if Assigned(original_HttpOpenRequestW) then
    UnHook(@original_HttpOpenRequestW);

  if Assigned(original_HttpSendRequestA) then
    UnHook(@original_HttpSendRequestA);

  if Assigned(original_HttpSendRequestW) then
    UnHook(@original_HttpSendRequestW);

  if Assigned(original_HttpAddRequestHeadersW) then
    UnHook(@original_HttpAddRequestHeadersW);

  if Assigned(original_HttpSendRequestExW) then
    UnHook(@original_HttpSendRequestExW);

  if Assigned(original_InternetReadFile) then
    UnHook(@original_InternetReadFile);

  if Assigned(original_HttpQueryInfoW) then
    UnHook(@original_HttpQueryInfoW);
  //InternetWriteFile
  if Assigned(original_InternetWriteFile) then
    UnHook(@original_InternetWriteFile);
  //InternetConnectW
  if Assigned(original_InternetConnectW) then
    UnHook(@original_InternetConnectW);
end;


initialization
  HookWebAPI;
finalization
  UnHookWebAPI;
end.

