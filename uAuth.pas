unit uAuth;

interface
uses
  windows,comobj,sysutils,registry,dialogs,forms,strutils,winsock;
const
  APP_ID='pp';
  USER_ID='0001';
  ROOT_KEY=HKEY_LOCAL_MACHINE;
  APP_KEY='Software\'+APP_ID;
  SERVER_PORT=8888;
  //SERVER_IP='127.0.0.1';
  SERVER_IP='154.221.19.215';

  function getGUID():string;
  function authorize():boolean;
  function RemoteAuth(txt:string):string;
  //-----------------------------------------------------------------
  function getRegString(key:string;value:string):string;
  function SetRegString(key:string;value:string;data:string):boolean;
  function SetRegTime(key:string;value:string;data:tDateTime):boolean;
  function SetRegInt(key:string;value:string;data:integer):boolean;
implementation
//comobj
function RemoteAuth(txt:string):string;
var
  wd:TWSAData;
  res,sock:integer;
  addr:TSockAddrIn;
  buf:array[0..31] of ansichar;
  tmp:ansistring;
begin
  result:='';
  res:=WSAStartup(MakeWord(2,2),wd);
  if(res<>0)then begin
    showmessage('网络错误！');
     //application.Terminate;
     exit;
  end;
  sock:=socket(PF_INET,SOCK_STREAM,0);
  if INVALID_SOCKET = sock then begin
    showmessage('网络错误！');
     //application.Terminate;
     exit;
  end;
  addr.sin_family:=PF_INET;
  addr.sin_port:=htons(SERVER_PORT);
  addr.sin_addr.S_addr:=inet_addr(PansiChar(SERVER_IP));
  res:=connect(sock,addr,SizeOf(addr));
  if res = SOCKET_ERROR then begin
    closesocket(sock);
    showmessage('连接服务器失败！');
    //application.Terminate;
    exit;
  end;
  tmp:=ansistring(txt);
  copymemory(@buf[0],@tmp[1],32);
  res:=send(sock,buf,32,0);
  if res <> length(txt) then begin
    closesocket(sock);
    showmessage('发送数据失败！');
    //application.Terminate;
    exit;
  end;
  zeromemory(@buf[0],sizeof(buf));
  res:=recv(sock,buf,SizeOf(buf),0);
  if (SOCKET_ERROR=res) then begin
    closesocket(sock);
    showmessage('接收数据失败！');
    //application.Terminate;
    exit;
  end;
  result:=buf;
  closesocket(sock);
  WSACleanup();
end;
function getGUID():string;
 var
  sGUID: string;
begin
  sGUID := CreateClassID;
  //ShowMessage(sGUID); // 两边带大括号的Guid
  Delete(sGUID, 1, 1);
  Delete(sGUID, Length(sGUID), 1);
  //ShowMessage(sGUID); // 去掉大括号的Guid，占36位中间有减号
  sGUID:= StringReplace(sGUID, '-', '', [rfReplaceAll]);
  //ShowMessage(sGUID); // 去掉减号的Guid，占32位
  result:=sGUID;
end;
function authorize():boolean;
var
  deviceID,authCode,txt,op:string;
begin
  result:=false;
  deviceID:=getRegString(app_key,'deviceID');
  authCode:=getRegString(app_key,'authCode');
  if(length(deviceID)<>12) or (length(authCode)<>12)then begin //1.弹出输入对话框：
     authCode:= InputBox('请输入授权码：','授权码：','');//参数分别为标题，提示，默认值
     authCode:=trim(authCode);
     if(length(authCode)<>12)then begin  //授权码输入错误
       showmessage('授权码输入错误！');
       //application.Terminate;
       exit;
     end;
     deviceID:=leftstr(getGUID(),12);
     txt:='01'+APP_ID+authCode+USER_ID+deviceID;
     txt:=RemoteAuth(txt);
     if(txt='')then begin
        //application.Terminate;
       exit;
     end;
     op:=leftstr(txt,2);
     if(op='00')then begin //授权失败
        showmessage('授权失败！');
        //application.Terminate;
        exit;
     end;
     if(op='01')then begin //授权成功
        showmessage('授权成功！');
        SetRegString(APP_KEY,'deviceID',deviceID);
        SetRegString(APP_KEY,'UserID',USER_ID);
        SetRegString(APP_KEY,'authCode',authCode);
        SetRegTime(APP_KEY,'authTime',now());
        SetRegString(APP_KEY,'authLength',rightstr(txt,4));
        result:=true;
        exit;
     end;
  end;
  txt:='00'+APP_ID+authCode+USER_ID+deviceID;
  txt:=RemoteAuth(txt);
  if(txt='')then begin
    //application.Terminate;
    exit;
  end;
  op:=leftstr(txt,2);
  if(op='00')then begin //认证失败
    if(txt='000001')then
      showmessage('授权码已过期！')
    else
      showmessage('认证失败！');
    SetRegString(APP_KEY,'deviceID','');
    SetRegString(APP_KEY,'authCode','');
    //application.Terminate;
    exit;
  end;
  if(op='01')then begin //认证成功
    //showmessage('剩余使用时间：'+rightstr(txt,4));
    result:=true;
  end;
end;
//-----------------------------------------------------------------------
function SetRegInt(key:string;value:string;data:integer):boolean;
var
  reg:TRegistry;
begin
  result:=false;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,true))then begin
    reg.WriteInteger(value,data);
    reg.CloseKey;
    result:=true;
  end;
  reg.Destroy;
end;
function SetRegTime(key:string;value:string;data:tDateTime):boolean;
var
  reg:TRegistry;
begin
  result:=false;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,true))then begin
    reg.WriteDateTime(value,data);
    reg.CloseKey;
    result:=true;
  end;
  reg.Destroy;
end;
function SetRegString(key:string;value:string;data:string):boolean;
var
  reg:TRegistry;
begin
  result:=false;
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,true))then begin
    reg.WriteString(value,data);
    reg.CloseKey;
    result:=true;
  end;
  reg.Destroy;
end;
function getRegString(key:string;value:string):string;
var
  reg:TRegistry;
begin
  result:='';
  reg:=tRegistry.Create;
  reg.RootKey:=ROOT_KEY;
  if(reg.OpenKey(key,false))then begin
    result:=reg.ReadString(value);
    //reg.wr
    reg.CloseKey;
  end;
  reg.Destroy;
end;
end.
