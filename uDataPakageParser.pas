unit uDataPakageParser;

interface
uses
  windows,classes,winsock2,sysutils,strutils,uFlash,messages;

const
  WM_PACKAGE_PARSER = WM_USER+1004;               //���ݰ�������Ϣ
  PACKAGE_DATA_MAX_SIZE=2048;                    //����������ݴ�С ��
  PACKAGE_LINK_MAX_COUNT=16;                    //����ճ��������� ��
type
  TDataFlag=(fHostInfo,fOnlineRequest,fOnlineOK,fTimePrice);    //���ݱ�ʶ��fTimePrice:ʵʱ�۸�����
  TMergeFlag=(fbuzy,fNone,fHeader,fComplete);               //��ϰ������־��æ���ް�����ͷ��������
  //--------------------------------------ҵ���߼� ��ͷ----------------------------------------
  PPackageHeader=^stPackageHeader;
  stPackageHeader=packed record
    dwSize:DWORD;
    header:array[0..11] of byte;
    ordHigh:byte;
    ordLow:byte;
    dwDataSize:DWORD;
  end;
  stDataPackage=packed record                              //��
    header:stPackageHeader;
    data:array[0..PACKAGE_DATA_MAX_SIZE-1] of byte;
  end;
  stHostInfo=record                       //������������Ϣ��
    s:TSocket;                            //�����������Ϣ
    ip:ansiString;
    port:WORD;
  end;
  //-------------------------------------------------------------------------------------------
  TDataPackageParser = class(TThread)                      //��������
  private
    bProcess:BOOLEAN;                                   //�߳����п���
    mCount,mProcess:integer;                                       //���ݰ������������������
    mDataPackageArr:array[0..PACKAGE_LINK_MAX_COUNT-1] of  stDataPackage;    //���ݰ���
    mHeaderSize:DWORD;                                     //��ͷ��С ��
    mMergeFlag:TMergeFlag;                                     //��ϰ���������
    mhForm:HWND;
    mFlash:tFlash;
    mfData:TDataFlag;                                     //��������
    cryptedData:ansiString;                               //���ܵ����ݣ�
    jsonData:ansiString;                                //json���ݣ�
    pByteData:pointer;                                  //���������ݣ�
    mHostInfo:stHostInfo;                           //host������Ϣ��
    function convertInt(i:integer):integer;
    function VerifyPackageHeader(pHeader:PPackageHeader):boolean;           //���ݰ�У�飻

    procedure CopyData(pHeader:PPackageHeader;pdata:pointer;dataSize:DWORD);
  protected
    procedure Execute; override;
  public
    constructor Create(hForm:HWND); overload;
    destructor Destroy;
    procedure MergePackage(dataDirection,dataSize: DWORD;pData:pointer);
    procedure inputData(s: TSocket;dataDirection,dataSize: DWORD;pData:pointer);
    procedure CaptrueHostInfo(ip:ansiString;port:word); //�����������ַ���˿ڣ�
    function isMyHost(ip:ansiString;port:word):boolean; //�ж��Ƿ���pp���������ݰ�
    property Host:stHostInfo read mHostInfo;
  end;

implementation
uses
  uHookSocketProcessor,uConfig,uFuncs,uLog;

constructor TDataPackageParser.Create(hForm:HWND);
begin
  inherited Create(false);
  bProcess:=true;                                              //����ʼʱ�����̣߳�ֱ�����������
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
  if(pHeader=nil)then //��һ������Ϊ��ͷ��
  begin
    pHeader2:=PPackageHeader(pdata);
    if not VerifyPackageHeader(PPackageHeader(pData)) then exit;
    copymemory(@mDataPackageArr[mCount].header,pData,mHeaderSize);
    CopyData(@mDataPackageArr[mCount].header,pData,dataSize);
  end
  else begin         //��һ������Ϊ���ݣ�
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
  if mMergeFlag=fHeader then                 //���ܽ��յ�����
  begin
    CopyData(@mDataPackageArr[mCount].header,pData,dataSize);
  end
  else begin //�а�ͷ����
    if(dataSize<mHeaderSize)then exit else
    if(dataSize=mHeaderSize)then                 //���յ���ͷ
    begin
      if not VerifyPackageHeader(PPackageHeader(pData)) then exit;          //У���ͷ��
      copymemory(@mDataPackageArr[mCount].header,pData,mHeaderSize);
      mMergeFlag:=fHeader;
      exit;
    end else
    if(dataSize>mHeaderSize)then                  //������
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
//������ڣ�
procedure TDataPackageParser.inputData(s: TSocket;dataDirection,dataSize: DWORD;pData:pointer);
begin

end;
procedure TDataPackageParser.CaptrueHostInfo(ip:ansiString;port:word); //�����������ַ���˿ڣ�
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

function TDataPackageParser.VerifyPackageHeader(pHeader:PPackageHeader):boolean;           //���ݰ�У�飻
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
//-----------------------------------------�ڲ�����---------------------------------------------
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
