unit APIHook;

interface

uses
SysUtils,Messages,
Windows, WinSock;

Const
  WM_CAP_WORK = WM_USER+1000;
type
//要HOOK的API函数定义
TSockProc = function (s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;

PJmpCode = ^TJmpCode;
TJmpCode = packed record
JmpCode: BYTE;
Address: TSockProc;
MovEAX: Array [0..2] of BYTE;
end;

//--------------------函数声明---------------------------
procedure HookAPI;
procedure UnHookAPI;

var
OldSend, OldRecv: TSockProc; //原来的API地址
JmpCode: TJmpCode;
OldProc: array [0..1] of TJmpCode;
AddSend, AddRecv: pointer; //API地址
TmpJmp: TJmpCode;
ProcessHandle: THandle;
  hForm:HWND;
  gRecv,gSend:ansistring;
implementation

{---------------------------------------}
{函数功能:Send函数的HOOK
{函数参数:同Send
{函数返回值:integer
{---------------------------------------}
function MySend(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
var
  //dwSize: cardinal;
  dwSize:NativeUInt;
begin
  //这儿进行发送的数据处理
  setlength(gSend,len);
  move(buf,gSend[1],len);
  postMessage(hform, WM_CAP_WORK,len,0);

  MessageBeep(10000); //简单的响一声
  //调用直正的Send函数
  WriteProcessMemory(ProcessHandle, AddSend, @OldProc[0], 8, dwSize);
  Result := OldSend(S, Buf, len, flags);
  JmpCode.Address := @MySend;
  WriteProcessMemory(ProcessHandle, AddSend, @JmpCode, 8, dwSize);
end;

{---------------------------------------}
{函数功能:Recv函数的HOOK
{函数参数:同Recv
{函数返回值:integer
{---------------------------------------}
function MyRecv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
var
  //dwSize: cardinal;
  dwSize:NativeUInt;
begin
//这儿进行接收的数据处理
  setlength(gRecv,len);
  move(buf,gRecv[1],len);
  postMessage(hform, WM_CAP_WORK,len,1);
  MessageBeep(1000); //简单的响一声
//调用直正的Recv函数
WriteProcessMemory(ProcessHandle, AddRecv, @OldProc[1], 8, dwSize);
Result := OldRecv(S, Buf, len, flags);
JmpCode.Address := @MyRecv;
WriteProcessMemory(ProcessHandle, AddRecv, @JmpCode, 8, dwSize);
end;

{------------------------------------}
{过程功能:HookAPI
{过程参数:无
{------------------------------------}
procedure HookAPI;
var
DLLModule: THandle;
  //dwSize: cardinal;
  dwSize:NativeUInt;
begin
ProcessHandle := GetCurrentProcess;
DLLModule := LoadLibrary('ws2_32.dll');
AddSend := GetProcAddress(DLLModule, 'send'); //取得API地址
AddRecv := GetProcAddress(DLLModule, 'recv');
JmpCode.JmpCode := $B8;
JmpCode.MovEAX[0] := $FF;
JmpCode.MovEAX[1] := $E0;
JmpCode.MovEAX[2] := 0;
ReadProcessMemory(ProcessHandle, AddSend, @OldProc[0], 8, dwSize);
JmpCode.Address := @MySend;
WriteProcessMemory(ProcessHandle, AddSend, @JmpCode, 8, dwSize); //修改Send入口
ReadProcessMemory(ProcessHandle, AddRecv, @OldProc[1], 8, dwSize);
JmpCode.Address := @MyRecv;
WriteProcessMemory(ProcessHandle, AddRecv, @JmpCode, 8, dwSize); //修改Recv入口
OldSend := AddSend;
OldRecv := AddRecv;
end;

{------------------------------------}
{过程功能:取消HOOKAPI
{过程参数:无
{------------------------------------}
procedure UnHookAPI;
var
  //dwSize: cardinal;
  dwSize:NativeUInt;
begin
WriteProcessMemory(ProcessHandle, AddSend, @OldProc[0], 8, dwSize);
WriteProcessMemory(ProcessHandle, AddRecv, @OldProc[1], 8, dwSize);
end;

end.
