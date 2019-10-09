unit uHookSocketProcessor;

interface
uses
  windows,classes,winsock2,sysutils,strutils,uFlash,messages,uDataPakageParser;
const
  WM_SOCKET_PROCESS = WM_USER+1003;               //socket ���ݽ��շ�����Ϣ
  SOCKET_DATA_MAX_SIZE=2048;                    //�������ݿ��С ��
  DATA_ARRAY_MAX_SIZE=128;                      //���ݶ��д�С��
  DATA_DIRECTION_SEND=1;                             //���ݷ��򣺷��͵����ݣ�
  DATA_DIRECTION_RECV=0;                             //���ݷ��򣺽��յ������ݣ�


type
  stSocketData=record                        //socket���ݿ飻
    s:TSocket;
    dwDirection:DWORD;                         //���ݷ��򣺽���0������1��
    pBigData:pointer;                         //ָ������ݿ��ָ�룻
    dwDataSize:DWORD;
    data:array[0..SOCKET_DATA_MAX_SIZE-1] of byte; //���ݿ飻
  end;
  stSocketConnectInfo=record               //socket������Ϣ��
    s:TSocket;                            //�����������Ϣ
    remoteAddr:ansiString;
    localAddr:ansiString;
    remotePort:WORD;
    localPort:WORD;
  end;

  //-------------------------------------------------------------------------------------------
  THookSocketProcessor = class(TThread)  //socket���ݴ�����
  private
    bProcess:BOOLEAN;                                            //�����߳�ִ��
    mSocketDataArr:array[0..DATA_ARRAY_MAX_SIZE-1] of  stSocketData;  //���ݶ���
    iData:DWORD;                                                    //��ǰ���ݶ������ֵ��
    iProcess:DWORD;                                                 //��ǰ�Ѵ��������ݶ������ֵ��
    mSocketConnectInfo:stSocketConnectInfo;                          //socket������Ϣ��
    mhFile:HWND;
    mDataPackage:TDataPackageParser;                                            //��������
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
    procedure addSocketData(s: TSocket; var Buf; len, dataDirection: Integer); //����socket���ݽ�����
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
  bProcess:=true;                                              //����ʼʱ�����̣߳�ֱ�����������
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

//�����ݷ�����У�
procedure THookSocketProcessor.addSocketData(s: TSocket; var Buf; len, dataDirection: Integer); //����socket���ݽ�����
begin
  mSocketDataArr[iData].s:=s;
  mSocketDataArr[iData].dwDataSize:=len;
  mSocketDataArr[iData].dwDirection:=dataDirection;
  getSocketConnectInfo(s,mSocketConnectInfo);
  if(len>SOCKET_DATA_MAX_SIZE)then     //�����ڴ���С ��
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

//-----------------------------------------����ͨѶ���� --------------------------------------------
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
  if(integer(s)=integer(socketConnectInfo.s))then exit;  //����ͬһ�����Ӿ��˳�
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
 // ����
var
  t: TThread;
begin
  t := TMyThread.Create(True);  // True��ʾ�����̣߳��ݲ�������Ĭ��ΪFalse
  t.FreeOnTerminate := True; // ��ʾ�߳�ִ����Ϻ��Զ�Free
  t.Start;  // �����߳�
end;









//-----------------------------------------ҵ�����ݴ��� --------------------------------------------
procedure THookSocketProcessor.ParseData(dataDirection,dataSize: DWORD;pData:pointer);
var
  pHeader:PPackageHeader;
  cryptedData:ansiString;
  pcryptedData:Pointer;
begin
  if(dataSize<sizeof(stPackageHeader))then exit;                     //����У��1
try
  pHeader:=PPackageHeader(pData);
  pHeader^.dwSize:=convertInt(pHeader^.dwSize);
  pHeader^.dwDataSize:=convertInt(pHeader^.dwDataSize);
  if(pHeader^.dwSize<>dataSize)then exit;                           //����У��2
  if(pHeader^.ordHigh=1) and (pHeader^.ordLow=1)then                //����1-1
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
  if(pHeader^.ordHigh=3) and (pHeader^.ordLow=1)then                //����1-1
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