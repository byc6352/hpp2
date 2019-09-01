unit webhook;

interface
uses windows,WinSock2,Messages,WININET;

Const
  WM_CAP_WORK = WM_USER+1001;

var
  original_InternetSetCookieEx : function(lpszUrl, lpszCookieName,lpszCookieData: LPCWSTR; dwFlags: DWORD; lpReserved: Pointer): DWORD; stdcall;

  original_Send: function(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;

  original_Recv:function (s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;

  original_InternetOpenUrlW:function (hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;

  original_HttpOpenRequestW:function (hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;

  hForm:HWND;
  gRecv,gSend:ansistring;
  gUrl:string;
  function replaced_Send(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
  function replaced_Recv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
  function replaced_InternetOpenUrlW(hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;

  function replaced_HttpOpenRequestW(hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;

  procedure UnHookWebAPI;
  procedure HookWebAPI;
implementation
uses
  HookUtils;
function replaced_HttpOpenRequestW(hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;
begin
  //������н��յ����ݴ���
  gUrl:=lpszObjectName;
  postMessage(hform, WM_CAP_WORK,0,2);
  MessageBeep(2000); //�򵥵���һ��
  result:=original_HttpOpenRequestW(hConnect,lpszVerb,lpszObjectName,lpszVersion,lpszReferrer,lplpszAcceptTypes,dwFlags,dwContext);
end;

function replaced_InternetOpenUrlW(hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;
begin
  //������н��յ����ݴ���
  gUrl:=lpszUrl;
  postMessage(hform, WM_CAP_WORK,0,2);
  MessageBeep(2000); //�򵥵���һ��
  result:=original_InternetOpenUrlW(hInet,lpszUrl,lpszHeaders,dwHeadersLength,dwFlags,dwContext);
end;
function replaced_Send(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
begin
  //������н��յ����ݴ���
  setlength(gSend,len);
  move(buf,gSend[1],len);
  postMessage(hform, WM_CAP_WORK,len,0);
  MessageBeep(1000); //�򵥵���һ��
  result:=original_Send(s,buf,len,flags);
end;

function replaced_Recv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
begin

  result:=original_Recv(s,buf,len,flags);
    //������н��յ����ݴ���
  setlength(gRecv,len);
  move(buf,gRecv[1],len);
  postMessage(hform, WM_CAP_WORK,len,1);
  MessageBeep(10000); //�򵥵���һ��
end;


{------------------------------------}
{���̹���:HookAPI
{���̲���:��
{------------------------------------}
procedure HookWebAPI;
const
  SendRealName = 'send';
  RecvRealName = 'recv';
begin
  if not(Assigned(original_Send)) then
  begin
    //@original_Send := HookProcInModule('ws2_32.dll', SendRealName, @replaced_Send); //ws2_32  wsock32
  end;
  if not(Assigned(original_Recv)) then
  begin
    //@original_Recv := HookProcInModule('ws2_32.dll', RecvRealName, @replaced_Recv);
  end;
  if not(Assigned(original_InternetOpenUrlW)) then
  begin
    //@original_InternetOpenUrlW := HookProcInModule('WININET.dll', 'InternetOpenUrlW', @replaced_InternetOpenUrlW);
  end;
  if not(Assigned(original_HttpOpenRequestW)) then
  begin
    @original_HttpOpenRequestW := HookProcInModule('wininet.dll', 'HttpOpenRequestW', @replaced_HttpOpenRequestW);
  end;
end;
{------------------------------------}
{���̹���:ȡ��HOOKAPI
{���̲���:��
{------------------------------------}
procedure UnHookWebAPI;
begin
  if Assigned(original_Send) then
    UnHook(@original_Send);
  if Assigned(original_Recv) then
    UnHook(@original_Recv);
  if Assigned(original_HttpOpenRequestW) then
    UnHook(@original_HttpOpenRequestW);
end;


{

InternetSetCookieEx : function(lpszUrl, lpszCookieName,
lpszCookieData: LPCWSTR; dwFlags: DWORD; lpReserved: Pointer): DWORD; stdcall;

replaced_
InternetGetCookieEx : function(lpszUrl, lpszCookieName,
lpszCookieData: LPCWSTR; var lpdwSize: DWORD; dwFlags: DWORD; lpReserved: Pointer): BOOL; stdcall;
}
end.