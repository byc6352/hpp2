unit uDataPakageParser;

interface
uses
  windows,classes,winsock2,sysutils,strutils,uFlash,messages;

const
  WM_PACKAGE_PARSER = WM_USER+1004;               //数据包解析消息
  PACKAGE_DATA_MAX_SIZE=2048;                    //定义包内数据大小 ；
  PACKAGE_LINK_MAX_COUNT=16;                    //定义粘包最大数量 ；
type
  TDataFlag=(fHostInfo,fOnlineRequest,fOnlineOK,fTimePrice);    //数据标识：fTimePrice:实时价格数据
  TMergeFlag=(fbuzy,fNone,fHeader,fComplete);               //组合包处理标志：忙，无包，包头，整包；
  //--------------------------------------业务逻辑 包头----------------------------------------
  PPackageHeader=^stPackageHeader;
  stPackageHeader=packed record
    dwSize:DWORD;
    header:array[0..11] of byte;
    ordHigh:byte;
    ordLow:byte;
    dwDataSize:DWORD;
  end;
  stDataPackage=packed record                              //包
    header:stPackageHeader;
    data:array[0..PACKAGE_DATA_MAX_SIZE-1] of byte;
  end;
  stHostInfo=record                       //服务器连接信息；
    s:TSocket;                            //保存旧连接信息
    ip:ansiString;
    port:WORD;
  end;
  //-------------------------------------------------------------------------------------------
  TDataPackageParser = class(TThread)                      //包解析类
  private
    bProcess:BOOLEAN;                                   //线程运行控制
    mCount,mProcess:integer;                                       //数据包的数量；处理的数量
    mDataPackageArr:array[0..PACKAGE_LINK_MAX_COUNT-1] of  stDataPackage;    //数据包；
    mHeaderSize:DWORD;                                     //包头大小 ；
    mMergeFlag:TMergeFlag;                                     //组合包处理结果；
    mhForm:HWND;
    mFlash:tFlash;
    mfData:TDataFlag;                                     //数据类型
    cryptedData:ansiString;                               //加密的数据；
    jsonData:ansiString;                                //json数据；
    pByteData:pointer;                                  //二进制数据；
    mHostInfo:stHostInfo;                           //host连接信息；
    function convertInt(i:integer):integer;
    function VerifyPackageHeader(pHeader:PPackageHeader):boolean;           //数据包校验；

    procedure CopyData(pHeader:PPackageHeader;pdata:pointer;dataSize:DWORD);
  protected
    procedure Execute; override;
  public
    constructor Create(hForm:HWND); overload;
    destructor Destroy;
    procedure MergePackage(dataDirection,dataSize: DWORD;pData:pointer);
    procedure inputData(s: TSocket;dataDirection,dataSize: DWORD;pData:pointer);
    procedure CaptrueHostInfo(ip:ansiString;port:word); //捕获服务器地址，端口；
    function isMyHost(ip:ansiString;port:word):boolean; //判断是否是pp服务器数据包
    property Host:stHostInfo read mHostInfo;
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
  //zeromemory(@mDataPackageArr[0].header,sizeof(stDataPackage)*length(mDataPackageArr));
end;
destructor TDataPackageParser.Destroy;
begin
  bProcess:=false;
  mFlash.free;
end;

procedure TDataPackageParser.Execute;
var
  s:TSocket;
begin
  while bProcess do
  begin
    if(mProcess<mCount)then
    begin
      mProcess:=mProcess+1;
    end else
    begin
      if(mMergeFlag<>fBuzy)and(mCount>0)then
      begin
        mCount:=0;
        mProcess:=0;
      end;
      sleep(1000);
    end;
  end;
end;
procedure TDataPackageParser.CopyData(pHeader:PPackageHeader;pdata:pointer;dataSize:DWORD);
var
  pHeader2:PPackageHeader;
  pdata2:pointer;
  dataSize2:DWORD;
begin
  if(pHeader=nil)then //第一块数据为包头；
  begin
    pHeader2:=PPackageHeader(pdata);
    if not VerifyPackageHeader(PPackageHeader(pData)) then exit;
    copymemory(@mDataPackageArr[mCount].header,pData,mHeaderSize);
    CopyData(@mDataPackageArr[mCount].header,pData,dataSize);
  end
  else begin         //第一块数据为数据；
    copymemory(@mDataPackageArr[mCount].data[0],pData,pHeader^.dwDataSize);
    mCount:=mCount+1;
    if(mCount>PACKAGE_LINK_MAX_COUNT)then  mCount:=0;
    if(dataSize-pHeader^.dwDataSize-mHeaderSize>0)then
    begin
      pdata2:=pointer(DWORD(pdata)+pHeader^.dwDataSize);
      dataSize2:=dataSize-pHeader^.dwDataSize;
      CopyData(nil,pdata2,dataSize2);
    end;
  end;
end;
procedure TDataPackageParser.MergePackage(dataDirection,dataSize: DWORD;pData:pointer);
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
//数据入口；
procedure TDataPackageParser.inputData(s: TSocket;dataDirection,dataSize: DWORD;pData:pointer);
begin

end;
procedure TDataPackageParser.CaptrueHostInfo(ip:ansiString;port:word); //捕获服务器地址，端口；
begin
  if(port=443)then
  begin
    mHostInfo.ip:=ip;
    mHostInfo.Port:=0;
    exit;
  end;
  if(mHostInfo.Port=0)and(port<>443)and(ip=mHostInfo.ip)then
  begin
    mHostInfo.port:=port;
    mfData:=TDataFlag.fHostInfo;
    postMessage(mhform, WM_PACKAGE_PARSER,cardinal(TDataFlag.fHostInfo),0);
  end;
end;
function TDataPackageParser.isMyHost(ip:ansiString;port:word):boolean;
begin
  result:=false;
  if(ip<>mHostInfo.ip)then exit;
  if(port<>mHostInfo.port)then exit;
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
