unit uDataPakageParser;

interface
uses
  windows,classes,winsock2,sysutils,strutils,uFlash,messages;

const
  WM_PACKAGE_PARSER = WM_USER+1004;               //数据包解析消息
  PACKAGE_DATA_MAX_SIZE=2048;                    //定义包内数据大小 ；
  PACKAGE_LINK_MAX_COUNT=16;                    //定义粘包最大数量 ；
type
  TDataFlag=(fHostInfo,fOnlineRequest,fOnlineOK,fTimePrice,fYzCodeRequest,fImageMsgOK,fImageDownRequest,fImageDownOK,fSubmitYzCode);    //数据标识：fTimePrice:实时价格数据
  TMergeWorkingFlag=(fbuzy,fIdle);               //组合包处理标志：忙，空闲
  TMergeStateFlag=(fCopyNone,fCopyHeaderComplete,fCopyDataComplete,fCopyDataHalf);               //组合包处理标志：无复制，复制了包头，复制了数据体，复制了一半数据体；
  //--------------------------------------业务逻辑 包头----------------------------------------
  PPackageHeader=^stPackageHeader;
  stPackageHeader=packed record
    dwSize:DWORD;
    header:array[0..11] of byte;
    ordHigh:byte;
    ordLow:byte;
    dwDataSize:DWORD;
  end;
  stDataPackage=record                              //包
    header:stPackageHeader;
    data:array[0..PACKAGE_DATA_MAX_SIZE-1] of byte;
    dataDirection:DWORD;
  end;
  stHostInfo=record                       //服务器连接信息；
    s:TSocket;                            //保存旧连接信息
    ip:ansiString;
    port:WORD;
  end;
  //-------------------------------------------------------------------------------------------
  stSocketHeader=record               //socket连接信息；
    id:DWORD;                         //编号
    s:TSocket;                            //保存旧连接信息
    dwDirection:DWORD;                         //数据方向：接收0，发送1；
    localPort:WORD;
    remotePort:WORD;
    localAddr:array[0..15] of ansichar;
    remoteAddr:array[0..15] of ansichar;
    dwDataSize:DWORD;
  end;
  TDataPackageParser = class(TThread)                      //包解析类
  private
    bProcess:BOOLEAN;                                   //线程运行控制
    mCount,mProcess:integer;                                       //数据包的数量；处理的数量
    mDataPackageArr:array[0..PACKAGE_LINK_MAX_COUNT-1] of  stDataPackage;    //数据包；
    mHeaderSize:DWORD;                                     //包头大小 ；
    mMergeWorkingFlag:TMergeWorkingFlag;                                     //组合包处理结果；
    mMergeStateFlag:TMergeStateFlag;                                  //组合包状态；
    mhForm:HWND;
    mFlash:tFlash;
    mDataFlag:TDataFlag;                                     //数据类型
    mCryptedData:ansiString;                               //加密的数据；
    mJsonData:ansiString;                                //json数据；
    mStream:tMemoryStream;                                  //二进制数据；
    mHostInfo:stHostInfo;                           //host连接信息；
    mDataDirection:DWORD;                            //数据传输方向
    function convertInt(i:integer):integer;
    function VerifyPackageHeader(pHeader:PPackageHeader):boolean;           //数据包校验；

    procedure copyData(pData:pointer;dataSize: DWORD);
    procedure ParsePackage(i:integer);                            //解析数据包
    procedure CaptrueHostInfo(ip:ansiString;port:word); //捕获服务器地址，端口；
    function isMyHost(ip:ansiString;port:word):boolean; //判断是否是pp服务器数据包
  protected
    procedure Execute; override;
  public
    constructor Create(hForm:HWND); overload;
    destructor Destroy;

    procedure MergePackage(socketHeader:stSocketHeader;pData:pointer);        //组合包
    property Host:stHostInfo read mHostInfo;
    property DataFalg:TDataFlag read mDataFlag;
    property CryptedData:ansiString read mCryptedData;
    property JsonData:ansiString read mJsonData;
    property Stream:tMemoryStream read mStream;
  end;

implementation
uses
  uHookSocketProcessor,uConfig,uFuncs,uLog;

constructor TDataPackageParser.Create(hForm:HWND);
begin
  inherited Create(false);
  bProcess:=true;                                              //程序开始时启动线程，直到程序结束；
  mFlash:=tFlash.Create(uConfig.flashfile);
  mhForm:=hForm;
  mHeaderSize:=sizeof(stPackageHeader);
  mStream:=tMemoryStream.Create;
  //zeromemory(@mDataPackageArr[0].header,sizeof(stDataPackage)*length(mDataPackageArr));
end;
destructor TDataPackageParser.Destroy;
begin
  bProcess:=false;
  mFlash.free;
  mStream.Free;
end;

procedure TDataPackageParser.Execute;
var
  s:TSocket;
begin
  while bProcess do
  begin
    Log('mProcess<mCount:'+inttostr(mProcess)+'    '+inttostr(mCount));
    if(mProcess<mCount)then
    begin
      Parsepackage(mProcess);
      postMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
      mProcess:=mProcess+1;
    end else
    begin
      if(mMergeWorkingFlag<>fBuzy)and(mCount>0)then
      begin
        mCount:=0;
        mProcess:=0;
      end;
      sleep(1000);
    end;
  end;
end;
procedure TDataPackageParser.MergePackage(socketHeader:stSocketHeader;pData:pointer);        //组合包
begin
  CaptrueHostInfo(socketHeader.remoteAddr,socketHeader.remotePort);
  if not isMyHost(socketHeader.remoteAddr,socketHeader.remotePort) then exit;
  mDataDirection:=socketHeader.dwDirection;
  mMergeWorkingFlag:=fbuzy;
  copyData(pData,socketHeader.dwdataSize);
  mMergeWorkingFlag:=fIdle;
end;
procedure TDataPackageParser.copyData(pData:pointer;dataSize: DWORD);
var
  dataSize2:DWORD;
  pdata2:pointer;
begin
  if(mMergeStateFlag=fCopyNone)or(mMergeStateFlag=fCopyDataComplete)then
  begin
    if(dataSize<mHeaderSize)then exit;
    if not VerifyPackageHeader(PPackageHeader(pData)) then exit;
    copymemory(@mDataPackageArr[mCount].header,pData,mHeaderSize);
    mMergeStateFlag:=fCopyHeaderComplete;
    dataSize2:=dataSize-mHeaderSize;
    if(dataSize2=0)then exit;
    pdata2:=pointer(DWORD(pData)+mHeaderSize);
    copyData(pData2,dataSize2);
  end
  else if (mMergeStateFlag=fCopyHeaderComplete) then
  begin
    if(dataSize<mDataPackageArr[mCount].header.dwDataSize)then   //数据未接收完全；
    begin
      Log('MergePackage:fCopyDataHalf');
      mMergeStateFlag:=fCopyHeaderComplete;
      exit;
    end;
    copymemory(@mDataPackageArr[mCount].data[0],pdata,mDataPackageArr[mCount].header.dwDataSize);
    mDataPackageArr[mCount].dataDirection:=mdataDirection;
    mMergeStateFlag:=fCopyDataComplete;
    dataSize2:=dataSize-mDataPackageArr[mCount].header.dwDataSize;
    pdata2:=pointer(DWORD(pData)+mDataPackageArr[mCount].header.dwDataSize);
    mCount:=mCount+1;
    if(mCount>=PACKAGE_LINK_MAX_COUNT)then  mCount:=0;
    if(dataSize2=0)then exit;
    if(dataSize2-mHeaderSize<0)then
    begin
      Log('MergePackage:fCopyHeadHalf');
      exit;
    end;

    copyData(pdata2,dataSize2);
  end;

end;

procedure TDataPackageParser.CaptrueHostInfo(ip:ansiString;port:word); //捕获服务器地址，端口；
begin
  if(port=843)then
  begin
    mHostInfo.ip:=ip;
    mHostInfo.Port:=0;
    exit;
  end;

  if(mHostInfo.Port=0)and(port<>843)and(ip=mHostInfo.ip)then
  begin
    mHostInfo.port:=port;
    mDataFlag:=TDataFlag.fHostInfo;
    postMessage(mhform, WM_PACKAGE_PARSER,cardinal(TDataFlag.fHostInfo),0);
  end;
end;
function TDataPackageParser.isMyHost(ip:ansiString;port:word):boolean;
begin
  result:=false;
  if(ip<>mHostInfo.ip)then exit;
  if(port<>mHostInfo.port)then exit;
  result:=true;
end;

function TDataPackageParser.VerifyPackageHeader(pHeader:PPackageHeader):boolean;           //数据包校验；
var
  dwSize,dwDataSize:DWORD;
begin
  result:=false;
  dwSize:=pHeader^.dwSize;
  dwDataSize:=pHeader^.dwDataSize;
  dwSize:=convertInt(dwSize);
  dwDataSize:=convertInt(dwDataSize);
  if(dwSize>PACKAGE_DATA_MAX_SIZE)then
  begin
    uLog.Log('VerifyPackageHeader false:dwSize='+inttostr(dwSize));
    exit;
  end;
  if(dwDataSize>PACKAGE_DATA_MAX_SIZE)then
  begin
    uLog.Log('VerifyPackageHeader false:dwDataSize='+inttostr(dwDataSize));
    exit;
  end;
  if(pHeader^.ordHigh>10)then
  begin
    uLog.Log('VerifyPackageHeader false:ordHigh='+inttostr(pHeader^.ordHigh));
    exit;
  end;
  if(pHeader^.ordLow>10)then
  begin
    uLog.Log('VerifyPackageHeader false:ordLow='+inttostr(pHeader^.ordLow));
    exit;
  end;
  if(pHeader^.header[0]<>$ff)then
  begin
    uLog.Log('VerifyPackageHeader false:ff='+inttostr(pHeader^.header[0]));
    exit;
  end;
  pHeader^.dwSize:=dwSize;
  pHeader^.dwDataSize:=dwDataSize;
  result:=true;
end;
procedure TDataPackageParser.ParsePackage(i:integer);
var
  pHeader:PPackageHeader;
  cryptedData:ansiString;
  pData:pointer;
begin
try
  pHeader:=PPackageHeader(@mDataPackageArr[i].header);
  pData:=pointer(@mDataPackageArr[i].data[0]);
  if(pHeader^.ordHigh=1) and (pHeader^.ordLow=1)then                //上线1-1
  begin
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_SEND)then mDataFlag:=fOnlineRequest;
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_RECV)then mDataFlag:=fOnlineOK;
    //pcryptedData:=pointer(DWORD(pData)+sizeof(stPackageHeader));
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pData,pHeader^.dwDataSize);
    Log('1-1cryptedData:'+cryptedData);
    mjsonData:=mflash.decryptData(cryptedData);
    mcryptedData:=cryptedData;
    sendMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
  end;
  if(pHeader^.ordHigh=3) and (pHeader^.ordLow=1)then                //实时价格
  begin
    mDataFlag:=fTimePrice;
    //pcryptedData:=pointer(DWORD(pData)+sizeof(stPackageHeader));
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pData,pHeader^.dwDataSize);
    //Log('3-1cryptedData:'+cryptedData);
    mjsonData:=mflash.decryptTimeData(cryptedData);
    mcryptedData:=cryptedData;
    sendMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
  end;
  if(pHeader^.ordHigh=2) and (pHeader^.ordLow=1)then                //请求验证码
  begin
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_SEND)then mDataFlag:=fYzCodeRequest;
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_RECV)then mDataFlag:=fImageMsgOK;
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pData,pHeader^.dwDataSize);
    //Log('3-1cryptedData:'+cryptedData);
    mjsonData:=mflash.decryptData(cryptedData);
    mcryptedData:=cryptedData;
    sendMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
  end;
  if(pHeader^.ordHigh=2) and (pHeader^.ordLow=4)then                //请求验证码 下载
  begin
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_SEND)then mDataFlag:=fImageDownRequest;
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pData,pHeader^.dwDataSize);
    //Log('3-1cryptedData:'+cryptedData);
    mjsonData:=mflash.decryptData(cryptedData);
    mcryptedData:=cryptedData;
    sendMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
  end;
  if(pHeader^.ordHigh=4) and (pHeader^.ordLow=1)then                //下载 验证码
  begin
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_RECV)then mDataFlag:=fImageDownOK;
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pData,pHeader^.dwDataSize);
    //Log('3-1cryptedData:'+cryptedData);
    mjsonData:=mflash.decryptData(cryptedData);
    mcryptedData:=cryptedData;
    if(pHeader^.dwSize-pHeader^.dwDataSize-mHeaderSize>0)then
    begin
      pData:=pointer(DWORD(pdata)+pHeader^.dwDataSize);
      mStream.Position:=0;
      mStream.write(pData^,pHeader^.dwSize-pHeader^.dwDataSize-mHeaderSize);
      mStream.Position:=0;
    end;
    sendMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
  end;
  if(pHeader^.ordHigh=2) and (pHeader^.ordLow=2)then                //下载 验证码
  begin
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_SEND)then mDataFlag:=fSubmitYzCode;
    setLength(cryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pData,pHeader^.dwDataSize);
    //Log('3-1cryptedData:'+cryptedData);
    mjsonData:=mflash.decryptData(cryptedData);
    mcryptedData:=cryptedData;
    sendMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
  end;
finally

end;
end;
//-----------------------------------------内部功能---------------------------------------------
function TDataPackageParser.convertInt(i:integer):integer;
var
  b1,b2:array[0..3] of byte;
begin
  move(i,b1,4);
  b2[0]:=b1[3];
  b2[1]:=b1[2];
  b2[2]:=b1[1];
  b2[3]:=b1[0];
  move(b2,result,4);
end;
initialization

finalization
end.


{
 procedure TDataPackageParser.CopyData(pHeader:PPackageHeader;pdata:pointer;dataSize:DWORD);
var
  pHeader2:PPackageHeader;
  pdata2:pointer;
  dataSize2:DWORD;
begin
  if(pHeader=nil)then //第一块数据为包头；
  begin
    if(dataSize<mHeaderSize)then exit;
    if not VerifyPackageHeader(PPackageHeader(pData)) then exit;
    copymemory(@mDataPackageArr[mCount].header,pData,mHeaderSize);
    CopyData(@mDataPackageArr[mCount].header,pData,dataSize-mHeaderSize);
  end
  else begin         //第一块数据为数据；
    if(dataSize<pHeader^.dwDataSize)then exit;
    copymemory(@mDataPackageArr[mCount].data[0],pData,pHeader^.dwDataSize);
    mDataPackageArr[mCount].dataDirection:=mDataDirection;
    mCount:=mCount+1;
    if(mCount>=PACKAGE_LINK_MAX_COUNT)then  mCount:=0;
    if(dataSize-pHeader^.dwDataSize-mHeaderSize>0)then
    begin
      pdata2:=pointer(DWORD(pdata)+pHeader^.dwDataSize);
      dataSize2:=dataSize-pHeader^.dwDataSize;
      CopyData(nil,pdata2,dataSize2);
    end;
  end;
end;


procedure TDataPackageParser.MergePackage(dataSize: DWORD;pData:pointer);
var
  PHeader:PPackageHeader;
begin
try
  mMergeFlag:=fBuzy;
  if mMergeFlag=fHeader then                 //可能接收到包体
  begin
    CopyData(@mDataPackageArr[mCount].header,pData,dataSize);
  end
  else begin //有包头存在
    if(dataSize<mHeaderSize)then exit else
    if(dataSize=mHeaderSize)then                 //接收到包头
    begin
      if not VerifyPackageHeader(PPackageHeader(pData)) then exit;          //校验包头；
      copymemory(@mDataPackageArr[mCount].header,pData,mHeaderSize);
      mMergeFlag:=fHeader;
      exit;
    end else
    if(dataSize>mHeaderSize)then                  //整包；
    begin
      if not VerifyPackageHeader(PPackageHeader(pData),dataSize) then exit;
      CopyData(nil,pdata,dataSize);
      mMergeFlag:=fComplete;
    end else exit;
  end;
finally
  if(mMergeFlag=fBuzy)then
    mMergeFlag:=fNone;
end;
end;
}
