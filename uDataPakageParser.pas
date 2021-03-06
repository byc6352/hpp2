unit uDataPakageParser;

interface
uses
  windows,classes,winsock2,sysutils,strutils,uFlash,messages,uHookWeb;

const
  WM_PACKAGE_PARSER = WM_USER+1004;               //数据包解析消息
  PACKAGE_DATA_MAX_SIZE=2048;                    //定义包内数据大小 ；
  PACKAGE_LINK_MAX_COUNT=16;                    //定义粘包最大数量 ；
type
  TDataFlag=(fNone,fHostInfo,fOnlineRequest,fOnlineOK,fTimePrice,fYzCodeRequest,fImageMsgOK,fImageDownRequest,fImageDownOK,fSubmitYzCode);    //数据标识：fTimePrice:实时价格数据
  TMergeWorkingFlag=(fbuzy,fIdle);               //组合包处理标志：忙，空闲
  TMergeStateFlag=(fCopyNone,fCopyHeaderComplete,fCopyDataComplete,fCopyDataHalf);               //组合包处理标志：无复制，复制了包头，复制了数据体，复制了一半数据体；
  TReplacePriceFlag=(fReplaceNone,fReplaceOne,fReplaceDouble);                                   //价格替换标志
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
  PoutData=^stOutData;
  stOutData=record
    DataFlag:DWORD;
    cryptedData:array[0..1023] of ansichar;
    JsonData:array[0..1023] of ansichar;
    dwByteSize:DWORD;
    pByteData:pointer;
  end;
  TDataPackageParser = class(TThread)                      //包解析类
  private
    bProcess:BOOLEAN;                                   //线程运行控制
    mCount,mProcess:integer;                                       //数据包的数量；处理的数量
    mDataPackageArr:array[0..PACKAGE_LINK_MAX_COUNT-1] of  stDataPackage;    //数据包；
    mHeaderSize:DWORD;                                     //包头大小 ；
    mMergeWorkingFlag:TMergeWorkingFlag;                                     //组合包处理结果；
    mMergeStateFlag:TMergeStateFlag;                                 //组合包状态；
    mFlash:tFlash;
    mPriceData,mPriceCode,mbasePrice:ansiString;                                           //价格数据；
    mRequestData:ansiString;                                        //请求验证码数据
    mRequestHeader:stPackageHeader;                                 //请求验证码数据头
    //-------------------------------------属性--------------------------------------------
    mDataFlag:TDataFlag;                                     //数据类型
    mCryptedData:ansiString;                               //加密的数据；
    mJsonData:ansiString;                                //json数据；
    mStream:tMemoryStream;                                  //二进制数据；

    mhForm:HWND;
    mHostInfo:stHostInfo;                           //host连接信息；
    mDataDirection:DWORD;                            //数据传输方向
    mReplacePriceFlag:TReplacePriceFlag;
    mClientId:ansiString;                           //客户ID；
    mYzcodeMsg:ansiString;

    function convertInt(i:integer):integer;
    function VerifyPackageHeader(pHeader:PPackageHeader):boolean;           //数据包校验；

    procedure copyData(pData:pointer;dataSize: DWORD);
    procedure ParsePackage(i:integer);                            //解析数据包
    procedure CaptrueHostInfo(ip:ansiString;port:word); //捕获服务器地址，端口；
    function isMyHost(ip:ansiString;port:word):boolean; //判断是否是pp服务器数据包
    //procedure setHostInfo(ip:ansiString;port:word);
    procedure getPriceCode(jsonData:ansiString);
    procedure getCurPrice(jsonData:ansiString;var curPrice:ansiString);
    procedure getPriceCode2(yzCodeMsg:ansiString);
    //procedure getCurPrice(jsonData:ansiString;var curPrice:ansiString);
    //--------------------------------------------------------------------------------------
    procedure setHostInfo(Host:stHostInfo);
    procedure setReplacePriceFlag(ReplacePriceFlag:TReplacePriceFlag);
    procedure setClientId(clientId:ansiString);
    procedure SetFormHandle(hForm:HWND);
    procedure SetPriceCode(priceCode:ansiString);
    procedure setRequestData(RequestData:ansiString);
    procedure setRequestHeader(RequestHeader:stPackageHeader);
  protected
    procedure Execute; override;
  public
    constructor Create(hForm:HWND); overload;
    destructor Destroy;override;

    procedure MergePackage(socketHeader:stSocketHeader;pData:pointer);        //组合包
    procedure ReplacePrice(var Buf; len:Integer);
    procedure ReplaceRequestAndPrice(s: TSocket; var Buf; len, flags: Integer);


    property DataFalg:TDataFlag read mDataFlag;
    property CryptedData:ansiString read mCryptedData;
    property JsonData:ansiString read mJsonData;
    property Stream:tMemoryStream read mStream;
    property YzCodeMsg:ansiString read mYzCodeMsg;

    property Host:stHostInfo read mHostInfo write setHostInfo;                                  // write setHostInfo
    property ReplacePriceFlag:TReplacePriceFlag read mReplacePriceFlag write setReplacePriceFlag;
    property ClientId:ansiString read mClientId write setClientId;
    property hForm:HWND read mhForm write SetFormHandle;                                  // write setHostInfo
    property PriceCode:ansiString read mPriceCode write SetPriceCode;
    property basePrice:ansiString read mbasePrice;
    property RequestData:ansiString read mRequestData write setRequestData;
    property RequestHeader:stPackageHeader read mRequestHeader write setRequestHeader;
  end;

implementation
uses
  uHookSocketProcessor,uConfig,uFuncs,uLog,json,uMyjoson;

constructor TDataPackageParser.Create(hForm:HWND);
begin
  inherited Create(false);
  bProcess:=true;                                              //程序开始时启动线程，直到程序结束；
  mFlash:=tFlash.Create(uConfig.flashfile);
  mhForm:=hForm;
  mHeaderSize:=sizeof(stPackageHeader);
  mStream:=tMemoryStream.Create;
  mReplacePriceFlag:=TReplacePriceFlag.fReplaceOne;
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
    //Log('mProcess<mCount:'+inttostr(mProcess)+'    '+inttostr(mCount));
    if(mProcess<mCount)then
    begin
      Parsepackage(mProcess);
      postMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),0);
      mProcess:=mProcess+1;
    end else
    begin
      if(mMergeWorkingFlag<>fBuzy)and(mCount>0)and(mMergeStateFlag<>fCopyHeaderComplete)then
      begin
        mCount:=0;
        mProcess:=0;
      end;
      sleep(1000);
    end;
  end;
end;
procedure TDataPackageParser.ReplaceRequestAndPrice(s: TSocket; var Buf; len, flags: Integer);
var
  header:stPackageHeader;
  oldData,newData:ansiString;
  pData,pBuf:pointer;
  dwSize,dwDataSize:DWORD;
begin
  if(len<mHeaderSize)then exit;
  pBuf:=nil;
  pData:=nil;
try
  move(Buf,header,mHeaderSize);
  if not VerifyPackageHeader(@header) then exit;
  if(header.ordHigh<>2)or(header.ordLow<>2)then exit;
  if(mReplacePriceFlag=fReplaceDouble)then
  begin
    oldData:=mRequestData;
    if(oldData='')or (mPriceData='')or(clientId='')then
    begin
      Log(format('ReplaceRequestAndPrice:oldData:%s    mPriceData:%s    clientId:%s',[oldData,mPriceData,clientId]));
      exit;
    end;
    newData:=mFlash.replaceRequest(mPriceData,oldData,clientId);
    dwSize:=mRequestHeader.dwSize;
    dwDataSize:=mRequestHeader.dwDataSize;
    if(dwDataSize<>length(newData))or(dwSize<>mHeaderSize+length(newData))then
    begin
      Log('mRequestHeader.dwDataSize<>length(newDAta).');
      exit;
    end;
    mRequestHeader.dwSize:=convertInt(mRequestHeader.dwSize);
    mRequestHeader.dwDataSize:=convertInt(mRequestHeader.dwDataSize);
    getmem(pBuf,dwSize);
    copymemory(pBuf,@mRequestHeader,mHeaderSize);
    pData:=pointer(DWORD(pBuf)+mHeaderSize);
    copymemory(pData,@newData[1],length(newData));

    if(original_Send(s,pBuf^,dwSize,flags)<=0)then
    begin
      Log('original_Send mRequest:false.');
      exit;
    end;
    Log('ReplaceDouble:oldData'+oldData);
    Log('ReplaceDouble:newData'+newData);
  end;
  if(mReplacePriceFlag=fReplaceOne)or(mReplacePriceFlag=fReplaceDouble)then
  begin
    setLength(oldData,header.dwDataSize);
    pData:=pointer(DWORD(@Buf)+mHeaderSize);
    copymemory(@oldData[1],pData,header.dwDataSize);
    newData:=mFlash.getNewData(mPriceData,oldData,clientId,mPriceCode);
    copymemory(pData,@newData[1],header.dwDataSize);
    Log('ReplacePrice:oldData'+oldData);
    Log('ReplacePrice:newData'+newData);
  end;
finally
  if(pBuf<>nil)then freemem(pBuf);
end;
end;
procedure TDataPackageParser.ReplacePrice(var Buf; len:Integer);
var
  header:stPackageHeader;
  oldData,newData:ansiString;
  pData:pointer;
begin
  if(len<mHeaderSize)then exit;
try

  move(Buf,header,mHeaderSize);
  if not VerifyPackageHeader(@header) then exit;
  if(header.ordHigh<>2)or(header.ordLow<>2)then exit;
  if(mReplacePriceFlag=fReplaceOne)then
  begin
    setLength(oldData,header.dwDataSize);
    pData:=pointer(DWORD(@Buf)+mHeaderSize);
    copymemory(@oldData[1],pData,header.dwDataSize);
    newData:=mFlash.getNewData(mPriceData,oldData,clientId,mPriceCode);
    copymemory(pData,@newData[1],header.dwDataSize);
    Log('ReplacePrice:oldData'+oldData);
    Log('ReplacePrice:newData'+newData);
  end;
finally

end;
end;

procedure TDataPackageParser.MergePackage(socketHeader:stSocketHeader;pData:pointer);        //组合包
begin
  CaptrueHostInfo(socketHeader.remoteAddr,socketHeader.remotePort);
  if not isMyHost(socketHeader.remoteAddr,socketHeader.remotePort) then exit;
  mDataDirection:=socketHeader.dwDirection;
  mMergeWorkingFlag:=fbuzy;
  copyData(pData,socketHeader.dwDataSize);
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
    dataSize2:=mDataPackageArr[mCount].header.dwSize-mHeaderSize;         //数据包大小 ；
    if(dataSize<dataSize2)then   //数据未接收完全；
    begin
      Log('MergePackage:fCopyDataHalf');
      mMergeStateFlag:=fCopyNone;
      exit;
    end;
    copymemory(@mDataPackageArr[mCount].data[0],pdata,dataSize2);
    mDataPackageArr[mCount].dataDirection:=mdataDirection;
    mMergeStateFlag:=fCopyDataComplete;
    pdata2:=pointer(DWORD(pData)+dataSize2);
    dataSize2:=dataSize-dataSize2;

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
    mHostInfo.ip:='180.153.38.219';
    mHostInfo.Port:=8300;
    postMessage(mhform, WM_PACKAGE_PARSER,cardinal(TDataFlag.fHostInfo),0);
  end;
  mHostInfo.ip:='180.153.38.219';
  mHostInfo.Port:=8300;
end;
function TDataPackageParser.isMyHost(ip:ansiString;port:word):boolean;
begin
  result:=false;
  if(ip<>mHostInfo.ip)then exit;
  if(port<>mHostInfo.port)then exit;
  result:=true;
end;


 {
procedure TDataPackageParser.setHostInfo(ip:ansiString;port:word);
begin
  mHostInfo.ip:=ip;
  mHostInfo.port:=port;
end;
 }
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
  //cryptedData,jsonData:ansiString;
  pData:pointer;
  dataSize:DWORD;
  pOut:PoutData;
begin
try
  pHeader:=PPackageHeader(@mDataPackageArr[i].header);
  pData:=pointer(@mDataPackageArr[i].data[0]);
  mDataFlag:=fNone;
  if(pHeader^.ordHigh=1) and (pHeader^.ordLow=1)then                //上线1-1
  begin
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_SEND)then mDataFlag:=fOnlineRequest;
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_RECV)then mDataFlag:=fOnlineOK;
  end;
  if(pHeader^.ordHigh=3) and (pHeader^.ordLow=1)then                //实时价格
  begin
    mDataFlag:=fTimePrice;
    setLength(mcryptedData,pHeader^.dwDataSize);
    copymemory(@cryptedData[1],pData,pHeader^.dwDataSize);
    mPriceData:=cryptedData;
    mjsonData:=mflash.decryptTimeData(cryptedData);
    mcryptedData:=cryptedData;
    Log('ParsePackage:mPriceData:'+mPriceData);
    Log('ParsePackage:cryptedData:'+cryptedData);
    getCurPrice(mjsonData,mBasePrice);
  end;
  if(pHeader^.ordHigh=2) and (pHeader^.ordLow=1)then                //请求验证码
  begin
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_SEND)then
    begin
     mDataFlag:=fYzCodeRequest;
    end;
    if(mDataPackageArr[i].dataDirection=DATA_DIRECTION_RECV)then mDataFlag:=fImageMsgOK;
  end;
  if(pHeader^.ordHigh=2) and (pHeader^.ordLow=4)then                //请求验证码 下载
  begin
    mDataFlag:=fImageDownRequest;
  end;
  if(pHeader^.ordHigh=4) and (pHeader^.ordLow=1)then                //下载 验证码
  begin
    mDataFlag:=fImageDownOK;
  end;
  if(pHeader^.ordHigh=2) and (pHeader^.ordLow=2)then                //下载 验证码
  begin
    mDataFlag:=fSubmitYzCode;
  end;
  if(mDataFlag<>fNone)or(mDataFlag<>fHostInfo)then
  begin
    if(mDataFlag<>fTimePrice)then
    begin
      setLength(mcryptedData,pHeader^.dwDataSize);
      copymemory(@mcryptedData[1],pData,pHeader^.dwDataSize);
      mjsonData:=mflash.decryptData(cryptedData);
    end;
    if(mDataFlag=fYzCodeRequest)then
    begin
      mRequestData:=cryptedData;
      copymemory(@mRequestHeader,pHeader,mHeaderSize);
    end;
    pOut:=new(PoutData);
    zeromemory(pOut,sizeof(stOutData));
    pOut^.DataFlag:=DWORD(mDataFlag);
    strcopy(pOut^.cryptedData,pansiChar(cryptedData));
    strcopy(pOut^.JsonData,pansiChar(jsonData));
    if(mDataFlag=fImageMsgOK)then
    begin
      getPriceCode(mjsonData);
      getPriceCode2(mcryptedData);
    end;
    if(mDataFlag=fImageDownOK)then
    begin
      dataSize:=pHeader^.dwSize-pHeader^.dwDataSize-mHeaderSize;
      if(dataSize>0)then
      begin
        pData:=pointer(DWORD(pdata)+pHeader^.dwDataSize);
        uFuncs.saveTofile(getFileName(uConfig.datadir,'yzcode','.png'),pData,dataSize);

        getmem(pOut^.pByteData,dataSize);
        copymemory(pOut^.pByteData,pData,dataSize);
        pOut^.dwByteSize:=dataSize;
      end;
    end;
    sendMessage(mhform, WM_PACKAGE_PARSER,cardinal(mDataFlag),integer(pOut));
    if(pOut^.pByteData<>nil)then freeMem(pOut^.pByteData);
    dispose(pOut);
  end;
except
  uFuncs.saveTofile(getFileName(uConfig.datadir,inttostr(i)+'packageParseErr','.txt'),pHeader,mHeaderSize);
  uFuncs.saveTofile(getFileName(uConfig.datadir,inttostr(i)+'packageParseErr','.txt'),pData,pHeader^.dwDataSize);
end;
end;
//-----------------------------------------内部功能---------------------------------------------
procedure TDataPackageParser.getCurPrice(jsonData:ansiString;var curPrice:ansiString);
var
  myJson:TMyJson;
begin
  myJson:=TmyJson.Create(jsonData);
  curPrice:=myjson.getValue(11);
  myJson.Free;
end;
procedure TDataPackageParser.getPriceCode2(yzCodeMsg:ansiString);
begin
try
  mPriceCode:=mflash.getPriceCode(yzCodeMsg);
finally

end;
end;
procedure TDataPackageParser.getPriceCode(jsonData:ansiString);
var
  jsonObject,jsonObject2: TJSONObject;
begin
try
  jsonObject:=TJSONObject.ParseJSONValue(jsonData) as TJSONObject;
  jsonObject2:=TJSONObject(jsonObject.GetValue('response'));
  jsonObject2:=TJSONObject(jsonObject2.GetValue('data'));
  mYzcodeMsg:=jsonObject2.Values['prompt'].ToString;
  mPriceCode:=jsonObject2.Values['expression'].ToString;
  mPriceCode:=replacestr(mPriceCode,'"','');
finally
  jsonObject.Free;
end;
end;
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
//-----------------------------------------属性---------------------------------------------
procedure TDataPackageParser.setClientId(clientId:ansiString);
begin
  mClientId:=clientId;
end;

procedure TDataPackageParser.setHostInfo(Host:stHostInfo);
begin
  mHostInfo:=Host;
end;
procedure TDataPackageParser.setReplacePriceFlag(ReplacePriceFlag:TReplacePriceFlag);
begin
   mReplacePriceFlag:=ReplacePriceFlag;
end;
procedure TDataPackageParser.SetPriceCode(priceCode:ansiString);
begin
  mPriceCode:=priceCode;
end;

procedure TDataPackageParser.SetFormHandle(hForm:HWND);
begin
  mHForm:=hForm;
end;

procedure TDataPackageParser.setRequestData(RequestData:ansiString);
begin
  mRequestData:=RequestData;
end;
procedure TDataPackageParser.setRequestHeader(RequestHeader:stPackageHeader);
begin
  mRequestHeader:=RequestHeader;
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
      mMergeStateFlag:=fCopyDataComplete;
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
}
