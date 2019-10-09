unit uHookSocketProcessor;

interface
uses
  windows,classes,winsock2,sysutils,strutils,uFlash,messages,uDataPakageParser;
const
  WM_SOCKET_PROCESS = WM_USER+1003;               //socket 数据接收发送消息
  SOCKET_DATA_MAX_SIZE=2048;                    //定义数据块大小 ；
  DATA_ARRAY_MAX_SIZE=128;                      //数据队列大小；
  DATA_DIRECTION_SEND=1;                             //数据方向：发送的数据；
  DATA_DIRECTION_RECV=0;                             //数据方向：接收到的数据；


type
  stSocketData=record                        //socket数据块；
    s:TSocket;
    dwDirection:DWORD;                         //数据方向：接收0，发送1；
    pBigData:pointer;                         //指向大数据块的指针；
    dwDataSize:DWORD;
    data:array[0..SOCKET_DATA_MAX_SIZE-1] of byte; //数据块；
  end;
  stSocketConnectInfo=record               //socket连接信息；
    s:TSocket;                            //保存旧连接信息
    remoteAddr:ansiString;
    localAddr:ansiString;
    remotePort:WORD;
    localPort:WORD;
  end;

  //-------------------------------------------------------------------------------------------
  THookSocketProcessor = class(TThread)  //socket数据处理类
  private
    bProcess:BOOLEAN;                                            //控制线程执行
    mSocketDataArr:array[0..DATA_ARRAY_MAX_SIZE-1] of  stSocketData;  //数据队列
    iData:DWORD;                                                    //当前数据队列最大值；
    iProcess:DWORD;                                                 //当前已处理的数据队列最大值；
    mSocketConnectInfo:stSocketConnectInfo;                          //socket连接信息；
    mhFile:HWND;
    mDataPackage:TDataPackageParser;                                            //解析包；
    procedure getSocketConnectInfo(s:TSocket;var socketConnectInfo:stSocketConnectInfo);
    procedure SaveSocketDataToFile(s:TSocket;dataDirection, dataSize: DWORD;pData:pointer);
    procedure myCloseHandle(var hFile:HWND);
    //procedure ParseData(dataDirection,dataSize: DWORD;pData:pointer);
    //procedure SetFormHandle(hForm:HWND);
    //function convertInt(i:integer):integer;
  protected
    procedure Execute; override;
  public
    constructor Create(hForm:HWND); overload;
    destructor Destroy;
    class function getInstance():THookSocketProcessor; overload;
    class function getInstance(hForm:HWND):THookSocketProcessor; overload;
    procedure addSocketData(s: TSocket; var Buf; len, dataDirection: Integer); //添加socket数据进来；
    property DataPackage:TDataPackageParser read mDataPackage;
    //property hForm:HWND read mhForm write SetFormHandle;
end;


implementation
{ THookSocketProcessor }
uses
  uConfig,uFuncs;
var
  HookSocketProcessor: THookSocketProcessor;

constructor THookSocketProcessor.Create(hForm:HWND);
begin
  inherited Create(false);
  bProcess:=true;                                              //程序开始时启动线程，直到程序结束；
  mDataPackage:=TDataPackageParser.Create(hForm);
end;
destructor THookSocketProcessor.Destroy;
begin
  bProcess:=false;
  myCloseHandle(mhFile);
end;
class function THookSocketProcessor.getInstance(hForm:HWND):THookSocketProcessor;
begin
  if not assigned(HookSocketProcessor) then
     HookSocketProcessor:=THookSocketProcessor.Create(hForm);
  result:=HookSocketProcessor;
end;
class function THookSocketProcessor.getInstance():THookSocketProcessor;
begin
  result:=getInstance(0);
end;

//将数据放入队列；
procedure THookSocketProcessor.addSocketData(s: TSocket; var Buf; len, dataDirection: Integer); //添加socket数据进来；
begin
  mSocketDataArr[iData].s:=s;
  mSocketDataArr[iData].dwDataSize:=len;
  mSocketDataArr[iData].dwDirection:=dataDirection;
  getSocketConnectInfo(s,mSocketConnectInfo);
  if(len>SOCKET_DATA_MAX_SIZE)then     //超过内存块大小 ；
  begin
    getmem(mSocketDataArr[iData].pBigData,len);
    copymemory(mSocketDataArr[iData].pBigData,@Buf,len);
  end
  else begin
    mSocketDataArr[iData].pBigData:=nil;
    copymemory(@mSocketDataArr[iData].data[0],@Buf,len);
  end;
  iData:=iData+1;
  if(iData>=DATA_ARRAY_MAX_SIZE)then iData:=0;
end;
procedure THookSocketProcessor.Execute;
var
  bHost:boolean;
begin
  while bProcess do
  begin
    if(iProcess<iData)then
    begin
      mDataPackage.CaptrueHostInfo(mSocketConnectInfo.remoteAddr,mSocketConnectInfo.remotePort);
      bHost:=mDataPackage.isMyHost(mSocketConnectInfo.remoteAddr,mSocketConnectInfo.remotePort);
      if(mSocketDataArr[iProcess].pBigData<>nil)then
      begin
        with mSocketDataArr[iProcess] do
        begin
          SaveSocketDataToFile(s,dwDirection,dwDataSize,pBigData);
          //ParseData(dwDirection,dwDataSize,pBigData);
        end;
        FreeAndNil(mSocketDataArr[iProcess].pBigData);
      end
      else begin
        with mSocketDataArr[iProcess] do
        begin
          SaveSocketDataToFile(s,dwDirection,dwDataSize,@data[0]);
          //ParseData(dwDirection,dwDataSize,@data[0]);
        end;
      end;
      iProcess:=iProcess+1;
      if(iProcess>=DATA_ARRAY_MAX_SIZE)then iProcess:=0;
    end
    else begin
      sleep(1000);
    end;
  end;
end;

//-----------------------------------------保存通讯数据 --------------------------------------------
procedure THookSocketProcessor.SaveSocketDataToFile(s:TSocket;dataDirection, dataSize: DWORD;pData:pointer);
var
  header,dataId:ansistring;
  NumberOfBytesWritten,NumberOfBytesWrittenSum:DWORD;
  ret:BOOL;
begin
  if(dataSize<=0)then exit;
  try
    if (mhFile=0) then
    begin
      mhFile:=CreateFile(pchar(uConfig.socketFile),GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,nil,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
      if(mhFile = INVALID_HANDLE_VALUE)then exit;
      //Log('hFile:'+dataId);
      //dwFileSize:=getFileSize(hFile,@dwFileSize);
      setFilePointer(mhFile,0,nil,FILE_END);
    end;
    //getSocketConnectInfo(s,mSocketConnectInfo);
    if(dataDirection=DATA_DIRECTION_RECV)then dataId:='recv';
    if(dataDirection=DATA_DIRECTION_SEND)then dataId:='send';
    header:=#13#10#13#10+getDateTimeString(now(),0)+'--------'+dataId+'--------local:('+mSocketConnectInfo.localAddr
      +'  port:'+inttostr(mSocketConnectInfo.localPort)+')remote:(' +mSocketConnectInfo.remoteAddr+'  port:'+inttostr(mSocketConnectInfo.remotePort)+')'+#13#10#13#10;
    ret:=writeFile(mhFile,header[1],length(header),NumberOfBytesWritten,0);
    if(ret=false)then begin CloseHandle(mhFile);mhFile:=0;exit;end;

    NumberOfBytesWritten:=0;
    NumberOfBytesWrittenSum:=0;
    while(NumberOfBytesWrittenSum<dataSize)do
    begin
      ret:=writeFile(mhFile,pData^,dataSize-NumberOfBytesWrittenSum,NumberOfBytesWritten,0);
      if(ret=false)then begin CloseHandle(mhFile);mhFile:=0;exit;end;
      NumberOfBytesWrittenSum:=NumberOfBytesWrittenSum+NumberOfBytesWritten;

    end;
    FlushFileBuffers(mhFile);
  finally

  end;
end;
procedure THookSocketProcessor.myCloseHandle(var hFile:HWND);
begin
  if(hFile<>0)then
  begin
    closeHandle(hFile);
    hFile:=0;
  end;
end;


procedure THookSocketProcessor.getSocketConnectInfo(s:TSocket;var socketConnectInfo:stSocketConnectInfo);
var
  addr:sockaddr;
  addr_v4:sockaddr_in;
  ret,addr_len:integer;
begin
  if(integer(s)=integer(socketConnectInfo.s))then exit;  //还是同一个连接就退出
  socketConnectInfo.s:=s;
  ZeroMemory(@addr, sizeof(addr));
  addr_len:=sizeof(addr);
  ret:=getsockname(s, addr, addr_len);
  if(ret=0)then
  begin
    if (addr.sa_family = AF_INET)then
    begin
      addr_v4 := sockaddr_in(addr);
      socketConnectInfo.localAddr:=inet_ntoa(addr_v4.sin_addr);
      socketConnectInfo.localPort:= ntohs(addr_v4.sin_port);
    end;
  end;
  ZeroMemory(@addr, sizeof(addr));
  addr_len:=sizeof(addr);
  ret:=getpeername(s,  addr, addr_len);
  if(ret=0)then
  begin
    if (addr.sa_family = AF_INET)then
    begin
      addr_v4:= sockaddr_in(addr);
      socketConnectInfo.remoteAddr := inet_ntoa(addr_v4.sin_addr);
      socketConnectInfo.remotePort:= ntohs(addr_v4.sin_port);
    end;
  end;
end;

initialization

finalization

end.


{
 // 调用
var
  t: TThread;
begin
  t := TMyThread.Create(True);  // True表示挂起线程，暂不启动。默认为False
  t.FreeOnTerminate := True; // 表示线程执行完毕后自动Free
  t.Start;  // 启动线程
end;









//-----------------------------------------业务数据处理 --------------------------------------------
procedure THookSocketProcessor.ParseData(dataDirection,dataSize: DWORD;pData:pointer);
var
  pHeader:PPackageHeader;
  cryptedData:ansiString;
  pcryptedData:Pointer;
begin
  if(dataSize<sizeof(stPackageHeader))then exit;                     //数据校验1
try
  pHeader:=PPackageHeader(pData);
  pHeader^.dwSize:=convertInt(pHeader^.dwSize);
  pHeader^.dwDataSize:=convertInt(pHeader^.dwDataSize);
  if(pHeader^.dwSize<>dataSize)then exit;                           //数据校验2
  if(pHeader^.ordHigh=1) and (pHeader^.ordLow=1)then                //上线1-1
  begin
    if(dataDirection=DATA_DIRECTION_SEND)then mOutData.fDataType:=fOnlineRequest;
    if(dataDirection=DATA_DIRECTION_RECV)then mOutData.fDataType:=fOnlineOK;
    pcryptedData:=pointer(DWORD(pData)+sizeof(stPackageHeader));
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pcryptedData,pHeader^.dwDataSize);
    mOutData.jsonData:=flash.decryptData(cryptedData);
    mOutData.cryptedData:=cryptedData;
    postMessage(hform, WM_SOCKET_PROCESS,0,0);
  end;
  if(pHeader^.ordHigh=3) and (pHeader^.ordLow=1)then                //上线1-1
  begin
    mOutData.fDataType:=fTimePrice;
    pcryptedData:=pointer(DWORD(pData)+sizeof(stPackageHeader));
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pcryptedData,pHeader^.dwDataSize);
    mOutData.jsonData:=flash.decryptTimeData(cryptedData);
    mOutData.cryptedData:=cryptedData;
    postMessage(hform, WM_SOCKET_PROCESS,0,0);
  end;
finally

end;
end;
}
