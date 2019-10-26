unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,uWeb,strutils, Vcl.ComCtrls,uXml,uconfig,
  Vcl.ExtCtrls, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,jpeg, IdCoderMIME,uAuth,
  IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,dateUtils,uFuncs,
  IdHTTP, IdUDPBase, IdUDPClient, IdSNTP,uHookweb,uData,uLog,uTryDown,uDataDown,shellapi,
  uHookSocketProcessor,uDataPakageParser,uMyJoson, Vcl.Imaging.pngimage;
   //webhook
type
  TfMain = class(TForm)
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    Timer2: TTimer;
    IdSNTP1: TIdSNTP;
    Page1: TPageControl;
    TabSheet1: TTabSheet;
    tsInfo: TTabSheet;
    GroupBox1: TGroupBox;
    edtForm: TLabeledEdit;
    GroupBox3: TGroupBox;
    imgPrice: TImage;
    edtPrice: TLabeledEdit;
    btnPriceSave: TButton;
    btnPriceUpdate: TButton;
    chkFwebOnTop: TCheckBox;
    btnFormUpdate: TButton;
    btnFormSave: TButton;
    edtInputPriceParam: TLabeledEdit;
    btnUpdateInputPriceParam: TButton;
    btnSaveInputPriceParam: TButton;
    edtSubmitPriceParam: TLabeledEdit;
    btnUpdateSubmitPriceParam: TButton;
    btnSaveSubmitPriceParam: TButton;
    edtSubmitVerificationCodeParam: TLabeledEdit;
    btnUpdateSubmitVerificationCodeParam: TButton;
    btnSaveSubmitVerificationCodeParam: TButton;
    edtInputVerificationCodeParam: TLabeledEdit;
    btnUpdateInputVerifyCodeParam: TButton;
    btnSaveInputVerifyCodeParam: TButton;
    btnTestInputPriceParam: TButton;
    btnTestInputVerifyCodeParam: TButton;
    btnTestSubmitPriceParam: TButton;
    btnTestSubmitVerificationCodeParam: TButton;
    edtInputAddPriceParam: TLabeledEdit;
    btnUpdateInputAddPriceParam: TButton;
    btnSaveInputAddPriceParam: TButton;
    btnTestInputAddPriceParam: TButton;
    edtSubmitAddPriceParam: TLabeledEdit;
    btnUpdateSubmitAddPriceParam: TButton;
    btnSaveSubmitAddPriceParam: TButton;
    btnTestSubmitAddPriceParam: TButton;
    edtFinishTime: TLabeledEdit;
    btnUpdateFinishTime: TButton;
    chkVerCode: TCheckBox;
    edtVerCode: TEdit;
    GroupBox4: TGroupBox;
    imgGetParam: TImage;
    chkGetParam: TCheckBox;
    edtGetParam: TLabeledEdit;
    GroupBox5: TGroupBox;
    btnToken: TButton;
    edtToken: TEdit;
    GroupBox2: TGroupBox;
    cmbStrategy: TComboBox;
    memStrategySay: TMemo;
    edtAddPrice: TLabeledEdit;
    edtRequestVercodeTime: TLabeledEdit;
    edtSubmitVerCodeTime: TLabeledEdit;
    GroupBox6: TGroupBox;
    edtVirtualSysAddr: TLabeledEdit;
    edtGPsysAddr: TLabeledEdit;
    btnVirtual: TButton;
    btnGP: TButton;
    btnAutoPP: TButton;
    btnTestPP: TButton;
    memInfo: TMemo;
    chkPrice: TCheckBox;
    tsAddFuncs: TTabSheet;
    GroupBox7: TGroupBox;
    rbtnUpdateNo: TRadioButton;
    rbtnUpdateOKandRequestPrice: TRadioButton;
    rbtnUpdateOKPrice: TRadioButton;
    edtClientId: TLabeledEdit;
    edtPriceCode: TLabeledEdit;
    cmbSelSys: TComboBox;
    edtBidnumber: TLabeledEdit;
    edtCurPrice: TLabeledEdit;
    edtHostIP: TLabeledEdit;
    edtHostPort: TLabeledEdit;
    lbImageMsg: TLabel;
    imgYzCode: TImage;
    edtRequestData: TLabeledEdit;
    Panel1: TPanel;
    GroupBox8: TGroupBox;
    edtRemotePath: TLabeledEdit;
    edtExtFilename: TLabeledEdit;
    btnDownVerCode: TButton;
    edtVideoTimeLength: TLabeledEdit;
    btnRecordScreen: TButton;
    btnSave: TButton;
    btnSetSysTime: TButton;
    btnRestoreSysTime: TButton;
    btnRestartpackageParser: TButton;
    btnTest: TButton;
    GroupBox9: TGroupBox;
    edtNewUrl: TEdit;
    btnRedectUrl: TButton;
    btnSetCookie: TButton;
    edtCookie: TLabeledEdit;
    edtPage: TLabeledEdit;
    lbYzCodeContent: TLabel;
    btnUpdateIP: TButton;
    procedure btnVirtualClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnGPClick(Sender: TObject);
    procedure btnFormUpdateClick(Sender: TObject);
    procedure btnFormSaveClick(Sender: TObject);
    procedure btnPriceUpdateClick(Sender: TObject);
    procedure btnPriceSaveClick(Sender: TObject);
    procedure btnAutoPPClick(Sender: TObject);
    procedure btnUpdateFinishTimeClick(Sender: TObject);
    procedure btnSaveInputPriceParamClick(Sender: TObject);
    procedure btnSaveSubmitPriceParamClick(Sender: TObject);
    procedure btnSaveInputVerifyCodeParamClick(Sender: TObject);
    procedure btnSaveSubmitVerificationCodeParamClick(Sender: TObject);
    procedure btnUpdateInputPriceParamClick(Sender: TObject);
    procedure btnUpdateSubmitPriceParamClick(Sender: TObject);
    procedure btnUpdateInputVerifyCodeParamClick(Sender: TObject);
    procedure btnUpdateSubmitVerificationCodeParamClick(Sender: TObject);
    procedure btnTestPPClick(Sender: TObject);
    procedure btnTestInputPriceParamClick(Sender: TObject);
    procedure btnTestSubmitPriceParamClick(Sender: TObject);
    procedure btnTestInputVerifyCodeParamClick(Sender: TObject);
    procedure btnTestSubmitVerificationCodeParamClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure btnTokenClick(Sender: TObject);
    procedure edtSubmitVerificationCodeParamChange(Sender: TObject);
    procedure btnUpdateInputAddPriceParamClick(Sender: TObject);
    procedure btnSaveInputAddPriceParamClick(Sender: TObject);
    procedure btnTestInputAddPriceParamClick(Sender: TObject);
    procedure btnUpdateSubmitAddPriceParamClick(Sender: TObject);
    procedure btnSaveSubmitAddPriceParamClick(Sender: TObject);
    procedure btnTestSubmitAddPriceParamClick(Sender: TObject);
    procedure cmbStrategyChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDownVerCodeClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cmbSelSysChange(Sender: TObject);
    procedure btnSetSysTimeClick(Sender: TObject);
    procedure btnRestoreSysTimeClick(Sender: TObject);
    procedure btnRestartpackageParserClick(Sender: TObject);
    procedure rbtnUpdateNoClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnRecordScreenClick(Sender: TObject);
    procedure btnRedectUrlClick(Sender: TObject);
    procedure btnSetCookieClick(Sender: TObject);
    procedure btnUpdateIPClick(Sender: TObject);
  private
    { Private declarations }

    procedure getParamsToCtl(configFile:string);
    procedure setParamsToWeb();
    function baiduIdentify(bmp:Tbitmap):string;overload;
    function baiduIdentify(mem: TMemoryStream):string;overload;
    function getRectFromStr(s:string):tRect;
    procedure getPrice();
    procedure saveStrategy(configFile:string);
    procedure httpMessage(var MSG:TMessage); message WM_CAP_WORK;
    procedure downMessage(var MSG:TMessage); message WM_DOWN_FILE;
    procedure socketMessage(var MSG:TMessage); message WM_SOCKET_PROCESS;
    procedure PackageMessage(var msg:TMessage); message WM_PACKAGE_PARSER;
    procedure getVerCode(url:string);
    procedure AppException(Sender: TObject; E: Exception);
    procedure showYzcodePng(pData:pointer;dwSize:DWORD);
    procedure backupFlashLog();
    procedure setMMcfg();
  public
    { Public declarations }
    mHookSocketProcessor:tHookSocketProcessor;
  end;

var
  fMain: TfMain;
  iDown:integer;//下载指针
  function URLEncode(msg:String):String;
  function captureScreen(x1:integer;y1:integer;x2:integer;y2:integer):tbitmap;
  function initEndTime():string;
function DownFileFromServer(const url,localFileName:string):boolean;
implementation

{$R *.dfm}
uses
  json,ShlObj,uFlash,uSpeecher;
procedure TfMain.setMMcfg();
var
  userdir,mmcfgFileName:String;
begin
  if(not fileExists(uConfig.mmcfgFile))then exit;
  userdir:=GetSystemPath(CSIDL_PROFILE);
  mmcfgFileName:=userdir+'\'+uConfig.MMCFG_NAME;
  if(not fileExists(mmcfgFileName))then
  begin
    copyFile(pchar(uConfig.mmcfgFile),pchar(mmcfgFileName),true);
  end;
end;
procedure TfMain.backupFlashLog();
var
  logFile,newFile:String;
begin
  logFile:=GetEnvironmentVariable('APPDATA');
  logFile:=logFile+'\Macromedia\Flash Player\Logs\flashlog.txt';
  newFile:=uFuncs.getFilename(uConfig.datadir,'flashlog','.txt');
  if(fileExists(logFile))then
  begin
    copyfile(pchar(logFile),pchar(newFile),false);
  end;
end;
procedure TfMain.PackageMessage(var msg:TMessage);
var
  DataFlag:TdataFlag;
  jsonObject,jsonObject2: TJSONObject;
  pOut:pOutData;
  jsonData,yzCodeMsg:ansiString;
begin
try
  DataFlag:=TdataFlag(msg.WParam);
  pOut:=POutData(msg.lParam);
  if(pOut=nil)and(DataFlag<>fHostInfo)then exit;
  case DataFlag of
  fHostInfo:
    begin
      edtHostIP.Text:=mHookSocketProcessor.DataPackage.host.ip;
      edtHostPort.Text:=inttostr(mHookSocketProcessor.DataPackage.host.port);
      exit;
    end;//fHostInfo
  fOnlineRequest:
    begin
      memInfo.Lines.Add('-----OnlineRequest-----');
      memInfo.Lines.Add(pOut^.cryptedData);
      memInfo.Lines.Add(pOut^.jsonData);
    end;
  fOnlineOK:
    begin
      memInfo.Lines.Add('-----OnlineOK-----');
      memInfo.Lines.Add(pOut^.cryptedData);
      memInfo.Lines.Add(pOut^.jsonData);
    end;
  fTimePrice:
    begin
      edtCurPrice.Text:=mHookSocketProcessor.DataPackage.basePrice;
      if(edtCurPrice.Text<>'')then
        fWeb.mPrice:=strtoint( edtCurPrice.Text);
    end;
  fYzCodeRequest:
    begin
      memInfo.Lines.Add('-----fYzCodeRequest-----');
      memInfo.Lines.Add(pOut^.cryptedData);
      memInfo.Lines.Add(pOut^.jsonData);
      edtRequestData.Text:=mHookSocketProcessor.DataPackage.Requestdata;
    end;
  fImageMsgOK:
    begin
      memInfo.Lines.Add('-----fImageMsgOK-----');
      memInfo.Lines.Add(pOut^.cryptedData);
      memInfo.Lines.Add(pOut^.jsonData);
      lbImageMsg.Caption:=mHookSocketProcessor.DataPackage.yzCodeMsg;
      edtpriceCode.Text:=mHookSocketProcessor.DataPackage.PriceCode;
      speecher.say(mHookSocketProcessor.DataPackage.yzCodeMsg);
    end;
  fImageDownRequest:
    begin
      memInfo.Lines.Add('-----fImageDownRequest-----');
      memInfo.Lines.Add(pOut^.cryptedData);
      memInfo.Lines.Add(pOut^.jsonData);
    end;
  fImageDownOK:
    begin
      memInfo.Lines.Add('-----fImageDownOK-----');
      memInfo.Lines.Add(pOut^.cryptedData);
      memInfo.Lines.Add(pOut^.jsonData);
      showYzcodePng(pOut^.pByteData,pOut^.dwByteSize);
    end;
  fSubmitYzCode:
    begin
      memInfo.Lines.Add('-----fSubmitYzCode-----');
      memInfo.Lines.Add(pOut^.cryptedData);
      memInfo.Lines.Add(pOut^.jsonData);
    end;
  end;
finally

end;
end;
procedure TfMain.rbtnUpdateNoClick(Sender: TObject);
begin
  if(rbtnUpDateNo.Checked)then
    mHookSocketProcessor.DataPackage.ReplacePriceFlag:=TReplacePriceFlag.fReplaceNone;
  if(rbtnUpDateOKPrice.Checked)then
    mHookSocketProcessor.DataPackage.ReplacePriceFlag:=TReplacePriceFlag.fReplaceOne;
  if(rbtnUpDateOKandRequestPrice.Checked)then
    mHookSocketProcessor.DataPackage.ReplacePriceFlag:=TReplacePriceFlag.fReplaceDouble;
end;
procedure TfMain.showYzcodePng(pData:pointer;dwSize:DWORD);
var
  stream:tmemoryStream;
begin
try
  stream:=tMemoryStream.create;
  stream.Write(pData^,dwSize);
  stream.Position:=0;
  lbYzCodeContent.Caption:=baiduIdentify(stream);
  stream.Position:=0;
  imgYzCode.Picture.LoadFromStream(stream);

finally
  stream.Free;
end;
end;
{
procedure TfMain.showYzcodePng(pData:pointer;dwSize:DWORD);
var
  stream,stream2:tmemoryStream;
  myimg: TImage;
  myjpg: TJPEGImage;
begin
try
  stream:=tMemoryStream.create;
  stream2:=tMemoryStream.create;
  stream.Write(pData^,dwSize);
  stream.Position:=0;
  myimg := TImage.Create(self);
  myimg.Picture.LoadFromStream(stream);
  myjpg := ConvertPICintoJPG(myimg.Picture,  myimg.Picture.Width, myimg.Picture.Height);
  myjpg.SaveToStream(stream2);
  stream2.Position:=0;
  lbYzCodeContent.Caption:=baiduIdentify(stream2);
  stream2.Position:=0;
  imgYzCode.Picture.LoadFromStream(stream2);

finally
  stream.Free;
  stream2.Free;
  myimg.Free;
end;
end;
}
procedure TfMain.socketMessage(var msg:TMessage);
var
  myJson:TMyJson;
begin
  with mHookSocketProcessor do
  begin
  {
    case outData.fDataType of
    TFDataType.fOnlineRequest:
      begin
        memInfo.Lines.Add('-----OnlineRequest-----');
        memInfo.Lines.Add(outData.cryptedData);
        memInfo.Lines.Add(outData.jsonData);
      end;
    TFDataType.fOnlineOK:
      begin
        memInfo.Lines.Add('-----OnlineOK-----');
        memInfo.Lines.Add(outData.cryptedData);
        memInfo.Lines.Add(outData.jsonData);
      end;
    TFDataType.fTimePrice:
      begin
        memInfo.Lines.Add('-----TimePrice-----');
        memInfo.Lines.Add(outData.cryptedData);
        memInfo.Lines.Add(outData.jsonData);
        myJson:=TmyJson.Create(outData.jsonData);
        edtCurPrice.Text:=myjson.getValue(11);
        fWeb.mPrice:=strtoint( edtCurPrice.Text);

      end;
    end;
    }
  end;
end;
function DownFileFromServer(const url,localFileName:string):boolean;
var
  ss: tstrings;
  mm: TMemoryStream;
  IdHTTP2:TIdHTTP;
  IdSSLIOHandlerSocketOpenSSL2:TIdSSLIOHandlerSocketOpenSSL;
function isUtf8():boolean;
var
  responseInfo,responseData:string;
  //bUtf8,bText:boolean; //Content-Type: text
begin
  result:=false;
  responseInfo:=idhttp2.Response.CharSet;
  if(responseInfo<>'')then begin
    responseInfo:=lowercase(responseInfo);
    if(pos(lowercase('UTF-8'),responseInfo)>0)then begin result:=true;exit;end;
  end;
end;
begin
  result:=false;
  ss:=nil;
  IdSSLIOHandlerSocketOpenSSL2:=nil;
  try
    IdHTTP2 := TIdHTTP.create(nil);
    mm:=TMemoryStream.Create;
    if(pos(lowercase('https://'),lowercase(url))>0)then begin
      IdSSLIOHandlerSocketOpenSSL2 := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      IdHTTP2.IOHandler := IdSSLIOHandlerSocketOpenSSL2;
    end;
    //IdHTTP2.IOHandler:=nil else IdHTTP2.IOHandler:=dm.IdSSLIOHandlerSocketOpenSSL1;
    IdHTTP2.HandleRedirects := True; //[hoInProcessAuth,hoKeepOrigProtocol,hoForceEncodeParams]
  try
    //if(pos('http://',url)>0)then idhttp1.IOHandler:=nil else idhttp1.IOHandler:=dm.IdSSLIOHandlerSocketOpenSSL1;
    //IdHTTP1.HandleRedirects := True; //[hoInProcessAuth,hoKeepOrigProtocol,hoForceEncodeParams]
    IdHTTP2.ReadTimeout:= 10*60*1000;
    IdHTTP2.ConnectTimeout := 10*60*1000;
    IdHTTP2.get(url,mm);
    mm.Position:=0;
    //IdHTTP1
    if(isUtf8())then begin
      ss:=tstringlist.Create;
      ss.LoadFromStream(mm,TEncoding.UTF8);
      ss.SaveToFile(localFileName,Tencoding.UTF8);
    end else begin
      mm.SaveToFile(localFileName);
    end;
    result:=true;
    Log(format('IdHTTP2 down file suc:url: %s.   localFileName:%s.',[url,localFileName]));
  except
    on E: Exception do
    begin
      Log(format('IdHTTP2 down file fail: %s.raise by:%s.',[url,e.Message]));
      //raise Exception.CreateFmt('IdHTTP1 down file fail: %s.raise by:%s.',[url,e.Message]);
    end;
  end;
  finally
    if(assigned(IdHTTP2))then IdHTTP2.Free;
    if(assigned(ss))then ss.Free;
    if(assigned(mm))then mm.Free;
    if(assigned(IdSSLIOHandlerSocketOpenSSL2))then IdSSLIOHandlerSocketOpenSSL2.Free;
  end;
end;
procedure TfMain.AppException(Sender: TObject; E: Exception);
begin
  //Application.ShowException(E);
  //Application.Terminate;
  Log(e.Message);
end;


procedure TfMain.getVerCode(url:string);
var
  filename,vercode:string;
  i:integer;
begin
   if(fweb.state.autoPP=true and chkVerCode.Checked=true)then begin
    i:=ReversePos('/',url);
    filename:=midstr(url,i+1,length(url)-i-4);
    if TryStrToInt(Trim(filename),i) then begin
      if(fweb.state.VirtualSys) then
        vercode:=fweb.mVerm[i-1]
      else
        vercode:=fweb.mVerg[i-1];
      fweb.mVerCode:=vercode;
      edtvercode.Text:=vercode;
    end;
  end;
end;
procedure TfMain.downMessage(var msg:TMessage);
var
  i,j:integer;
begin
  i:=msg.LParam;
  j:=msg.WParam;
  case j of
  0:meminfo.Lines.Add('down fal：'+inttostr(i)+'['+datas[i].ObjectName+']');
  1:meminfo.Lines.Add('down suc：'+inttostr(i)+'['+datas[i].ObjectName+']');
  2:meminfo.Lines.Add('down suc：'+inttostr(i));
  3:meminfo.Lines.Add('down end：'+inttostr(i));
  end;
end;
procedure TfMain.httpMessage(var msg:TMessage);
var
  len,flag:integer;
  p:pointer;
  say,data:ansistring;

begin
  flag:=msg.LParam;
  len:=msg.WParam;
  case flag of
  0:begin
      say:='发送数据：'+inttostr(len);
      //data:=gSend;
    end;
  1:begin
      say:='接收数据：'+inttostr(len);
      //data:=gRecv;
    end;
  2:begin
      say:='URL：';
      data:=uData.datas[idata-1].ObjectName;
      //addDown();
      if(fweb.state.VirtualSys)then getVerCode(data);
    end;
  end;
  memInfo.Lines.Add(say);
  memInfo.Lines.Add(data);
  //statusbar1.Panels[0].Text:=data;
end;
function initEndTime():string;
//const
  //END_TIME='11:30:00';
var
  w:word;//每月第几个星期；
  d:word;//当前是星期几；
  r:integer;//时间比较结果
  END_TIME_t:ttime; //11:30:00
  endDateTime,dayString,datetimeString:string;
  fmt: TFormatSettings;
  endDateTimeT:tdatetime;
  END_TIME:string;//END_TIME='11:30:00';
begin
  GetLocaleFormatSettings(GetThreadLocale, fmt);
  END_TIME:='11'+fmt.TimeSeparator+'30'+fmt.TimeSeparator+'00';
   w := WeekOfTheMonth(now()); //3
   d:=DayOfTheWeek(Now);
   END_TIME_t:=strtotime(END_TIME);
   r:= CompareTime(now(), END_TIME_t);     //1
   if (w=3) and (d=6) and (r=-1) then begin
     dayString:='yyyy'+fmt.DateSeparator+'mm'+fmt.DateSeparator+'dd ';
     DateTimeToString(endDateTime, dayString, now());
     endDateTime:=endDateTime+END_TIME;

   end else begin
     endDateTimeT:=IncMinute(now(),5);
     datetimeString:='yyyy'+fmt.DateSeparator+'mm'+fmt.DateSeparator+'dd hh:nn:00';
     DateTimeToString(endDateTime, datetimeString, endDateTimeT);
   end;
   result:=endDateTime;
   //edit1.text:=endDateTime;
end;
procedure TfMain.saveStrategy(configFile:string);
var
  say:string;
begin

  say:='离拍卖结束前'+edtRequestVercodeTime.Text+'秒提交一个加'+inttostr(fweb.mAddPrice)+'的价格；';
  memStrategySay.Text:='策略'+inttostr(cmbStrategy.ItemIndex+1)+'说明： '+#13#10+say;

  if(cmbStrategy.ItemIndex=0) then begin
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy1','requestvercodetime',edtRequestVercodeTime.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy1','submitpricetime',edtSubmitVercodeTime.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy1','addprice',edtAddPrice.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy1','',say);
  end else if(cmbStrategy.ItemIndex=1) then begin
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy2','requestvercodetime',edtRequestVercodeTime.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy2','submitpricetime',edtSubmitVercodeTime.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy2','addprice',edtAddPrice.Text);
    uXml.setXmlNodeValue(uConfig.configFile,'pp.strategy.strategy2','',say);
  end else if(cmbStrategy.ItemIndex=2) then begin
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy3','requestvercodetime',edtRequestVercodeTime.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy3','submitpricetime',edtSubmitVercodeTime.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy3','addprice',edtAddPrice.Text);
    uXml.setXmlNodeValue(configFile,'pp.strategy.strategy3','',say);
  end;
end;
procedure TfMain.btnAutoPPClick(Sender: TObject);
var
  say:string;
begin
try
  if(btnAutoPP.Caption='自动抢拍')then
  begin
    if(fweb.state.enterSys=false)then
    begin
      say:='必须先进入抢拍系统，才能开始抢拍！';
      showmessage(say);
      exit;
    end;
    btnAutoPP.Caption:='停止抢拍';
    fweb.state.autoPP:=true;
    setParamsToWeb();
    fweb.initAddPriceStrategy();
    saveStrategy(fweb.configFile);//保存策略参数
    if(fweb.state.VirtualSys)then
      begin
        say:='当前状态：模拟抢拍系统，已打开自动抢拍';
        statusbar1.Panels[0].Text:=say;
        exit;
      end else begin
         say:='当前状态：国拍抢拍系统，已打开自动抢拍';
        statusbar1.Panels[0].Text:=say;
      end;
  end else begin
    btnAutoPP.Caption:='自动抢拍';
    fweb.state.autoPP:=false;
    chkPrice.Checked:=false;
    if(fweb.state.VirtualSys)then
    begin
      say:='当前状态：模拟抢拍系统，已停止自动抢拍';
      statusbar1.Panels[0].Text:=say;
      exit;
    end else begin
       say:='当前状态：国拍抢拍系统，已停止自动抢拍';
      statusbar1.Panels[0].Text:=say;
    end;
  end;
finally
  if(say<>'')then
    speecher.say(say);
end;

end;

procedure TfMain.btnDownVerCodeClick(Sender: TObject);
var
  remoteName,ExtFileName:string;
begin
  if(btnDownVerCode.Caption='下载')then begin
  remoteName:=trim(edtRemotePath.Text);
  ExtFileName:=trim(edtExtFileName.text);
  if(remoteName[length(remoteName)]<>'/')then
    uTryDown.tryDownloadFiles(remoteName)
  else
    uTryDown.tryDownloadFiles(remoteName,ExtFileName);
    btnDownVerCode.Caption:='停止';
  end else begin
    uTryDown.bDownFiles:=false;
    btnDownVerCode.Caption:='下载';
  end;
end;

procedure TfMain.btnFormSaveClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.form','',trim(edtForm.text));
end;

procedure TfMain.btnFormUpdateClick(Sender: TObject);
begin
  fweb.rctForm:=getRectFromStr(edtForm.text);
  MoveWindow(fWeb.Handle,fweb.rctForm.left,fweb.rctForm.Top,fweb.rctForm.Width,fweb.rctForm.Height,true);
end;

procedure TfMain.btnGPClick(Sender: TObject);
var
  rctWeb:tRect;
  say:string;
begin
  if(not uAuth.authorize())then exit;
  fweb.configFile:=uConfig.configFile2;
  getParamsToCtl(fweb.configFile);
  cmbStrategy.ItemIndex:=0;
  cmbStrategy.OnChange(sender);
  setParamsToWeb();
  fWeb.Show;
  //https://paimai2.alltobid.com/bid/921b37e877a843279394ee48585fdc48/login.htm
  //fWeb.wb1.Navigate('https://paimai.alltobid.com'); //https://paimai.alltobid.com
  //fWeb.wb1.Navigate('https://paimai2.alltobid.com/bid/921b37e877a843279394ee48585fdc48/login.htm');
  //https://paimai2.alltobid.com/bid/b901b3c0ba414c3bb7c08761aedbff50/login.htm
  //webhook.HookWebAPI;
  say:='当前状态：国拍抢拍系统，未打开自动抢拍';
  fWeb.wb1.Navigate(fweb.GPaddr);
  //状态显示：
  fweb.state.enterSys:=true;
  fweb.state.VirtualSys:=false;
  fweb.state.autoPP:=false;
  statusbar1.Panels[0].Text:=say;
  btnVirtual.Enabled:=false;
  //rctWeb:=rect(900,20,1860,780);
  //MoveWindow(fWeb.Handle,rctWeb.left,rctWeb.Top,rctWeb.Width,rctweb.Height,true);
  speecher.say(say);
end;

procedure TfMain.btnPriceSaveClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.price','',trim(edtPrice.text));
end;

procedure TfMain.btnPriceUpdateClick(Sender: TObject);
begin
  fweb.rctPrice:=getRectFromStr(edtPrice.text);
end;

procedure TfMain.btnRecordScreenClick(Sender: TObject);
var
  cmd,mp4,recordTime:String;
begin
  mp4:=uFuncs.getFilename(uConfig.datadir,'video','.mp4');
  recordTime:=trim(edtvideoTimeLength.Text);
  recordTime:=inttostr(strtoint(recordTime)*60);
  //cmd:='ffmpeg -y -f gdigrab  -t 3600 -r 25 -i desktop -vcodec libx264 -s 1920x1080 123.mp4';
  //cmd:=uConfig.ffmpegFile+' -y -f gdigrab  -t '+recordTime+' -r 25 -i desktop -vcodec libx264 -s 1920x1080 '+mp4;
  cmd:=' -y -f gdigrab  -t '+recordTime+' -r 25 -i desktop -vcodec libx264 -s 1920x1080 '+mp4;
  ShellExecute(Handle,'open',pchar(uConfig.ffmpegFile),pchar(cmd),nil,1);
end;

procedure TfMain.btnRedectUrlClick(Sender: TObject);
begin
  fweb.wb1.Navigate(trim(edtNewUrl.Text));
end;

procedure TfMain.btnRestartpackageParserClick(Sender: TObject);
begin
  mHookSocketProcessor.restartPackageParser(fmain.Handle);
end;

procedure TfMain.btnRestoreSysTimeClick(Sender: TObject);
begin
  IdSNTP1.Host:='time.windows.com';
  IdSNTP1.SyncTime ;
end;

procedure TfMain.btnSaveClick(Sender: TObject);
var
  txt:string;
begin
  txt:=uData.saveData;
  if txt<>'' then
  ShellExecute(Handle,'open','notepad.exe',pchar(txt),nil,1);
  txt:=uData.saveHeader;
  if txt<>'' then
  ShellExecute(Handle,'open','notepad.exe',pchar(txt),nil,1);
end;

procedure TfMain.btnSaveInputAddPriceParamClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.inputaddprice','',trim(edtInputAddPriceParam.text));
end;

procedure TfMain.btnSaveInputPriceParamClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.inputprice','',trim(edtInputPriceParam.text));
end;

procedure TfMain.btnSaveInputVerifyCodeParamClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.inputvercode','',trim(edtInputVerificationCodeParam.text));
end;

procedure TfMain.btnSaveSubmitAddPriceParamClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.submitaddprice','',trim(edtSubmitAddPriceParam.text));
end;

procedure TfMain.btnSaveSubmitPriceParamClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.submitprice','',trim(edtSubmitPriceParam.text));
end;

procedure TfMain.btnSaveSubmitVerificationCodeParamClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.submitvercode','',trim(edtSubmitVerificationCodeParam.text));
end;

procedure TfMain.btnSetCookieClick(Sender: TObject);

begin
  //doc:=fweb.wb1.Document as IHTMLDocument2;
  fweb.setCookie(trim(edtCookie.Text));
end;

procedure TfMain.btnSetSysTimeClick(Sender: TObject);
var
  systemtime:Tsystemtime;
  DateTime:TDateTime;
begin
  DateTime:=StrToDateTime('2019/09/22 11:00:00');   //获得时间（TDateTime格式）
  DateTimeToSystemTime(DateTime,systemtime);   //把Delphi的TDateTime格式转化为API的TSystemTime格式
  SetLocalTime(SystemTime);

end;

procedure TfMain.btnTestClick(Sender: TObject);
var
  flash:tFlash;
  s:string;
begin
//+p6NrEhDib/orReHwsdou9mzI0RGkqYGiBSk4VKIy2aqMjXTXKLpyiBcr8ATcwN82NEGcvRLDKcO8hyLkT/ENzCEI=
  //s:='JjoEfeJWMBRcHXr6LWkrNXbRdpfiywDXQQfsbmOvYv+bzCosM368a7BywOluoQWs/ty0JfXXsVst9cE83MAxOM+'+
  //'JGndpC2EL8nwoAOlkSIKunSWbm4zsT3phGlT3nt0JI2Bo58QN0xnnJKa+Kb+BxCFqA17jNhWdCfczeoBVgUmDdiS1DGkRrr'+
  //'bwikIqQQ9Qzz+L/0HADhMRNmo2UwVePsPEV0iJaZdlvwa+8jMCF3PGfaDfx6HNycs43SCNKyzyk6lNhgo1Z1Ay9HRD9e16Y'+
  //'y5P3efCOKM9VUntQiaEuy6ruk3czyrwQGp31sABVZyiD7PHsVpeLrk/dhW3DZDupbB+RGaUmDl2ZLJwcr5UcwQanftfdMYq'+
  //'vBA5IKlXRfL+Z2MbZgjwOrw/yosEXIL6jWVRRA29kajxSz3W9m8cfzYr0XrKg080Xw==';
  s:=edtRemotePath.Text;
  flash:=tFlash.create(uconfig.flashfile);
  ShowMessage(flash.getPriceCode(s));
  flash.Free;
//ShowMessage(GetEnvironmentVariable('APPDATA'));
end;

procedure TfMain.btnTestInputAddPriceParamClick(Sender: TObject);
var
  ss:tstrings;
  x1,y1,x2,y2:integer;
begin
  ss:=tstringlist.Create;
  ss.CommaText:=trim(edtInputAddPriceParam.Text);
  x1:=strtoint(ss[0]);
  y1:=strtoint(ss[1]);
  x2:=strtoint(ss[2]);
  y2:=strtoint(ss[3]);
  imgGetParam.Picture.Bitmap.Assign(uFuncs.captureScreen(x1,y1,x2,y2));

end;

procedure TfMain.btnTestInputPriceParamClick(Sender: TObject);
var
  ss:tstrings;
  x1,y1,x2,y2:integer;
begin
  ss:=tstringlist.Create;
  ss.CommaText:=trim(edtInputPriceParam.Text);
  x1:=strtoint(ss[0]);
  y1:=strtoint(ss[1]);
  x2:=strtoint(ss[2]);
  y2:=strtoint(ss[3]);
  imgGetParam.Picture.Bitmap.Assign(uFuncs.captureScreen(x1,y1,x2,y2));
end;

procedure TfMain.btnTestInputVerifyCodeParamClick(Sender: TObject);
var
  ss:tstrings;
  x1,y1,x2,y2:integer;
begin
  ss:=tstringlist.Create;
  ss.CommaText:=trim(edtInputVerificationCodeParam.Text);
  x1:=strtoint(ss[0]);
  y1:=strtoint(ss[1]);
  x2:=strtoint(ss[2]);
  y2:=strtoint(ss[3]);
  imgGetParam.Picture.Bitmap.Assign(uFuncs.captureScreen(x1,y1,x2,y2));

end;

procedure TfMain.btnTestPPClick(Sender: TObject);
begin
  fweb.InitAddPriceStrategy;
  if(btnTestPP.Caption='测试抢拍') then begin
    btnTestPP.Caption:='停止测试';
    setParamsToWeb();
    fweb.mRemainSec:=20;
    timer2.Enabled:=true;
    timer1.Enabled:=false;
  end else begin
    btnTestPP.Caption:='测试抢拍';
    fweb.mRemainSec:=2000;
    timer2.Enabled:=false;
    timer1.Enabled:=true;
  end;

end;

procedure TfMain.btnTestSubmitAddPriceParamClick(Sender: TObject);
var
  ss:tstrings;
  x1,y1,x2,y2:integer;
begin
  ss:=tstringlist.Create;
  ss.CommaText:=trim(edtSubmitAddPriceParam.Text);
  x1:=strtoint(ss[0]);
  y1:=strtoint(ss[1]);
  x2:=strtoint(ss[2]);
  y2:=strtoint(ss[3]);
  imgGetParam.Picture.Bitmap.Assign(uFuncs.captureScreen(x1,y1,x2,y2));

end;

procedure TfMain.btnTestSubmitPriceParamClick(Sender: TObject);
var
  ss:tstrings;
  x1,y1,x2,y2:integer;
begin
  ss:=tstringlist.Create;
  ss.CommaText:=trim(edtSubmitPriceParam.Text);
  x1:=strtoint(ss[0]);
  y1:=strtoint(ss[1]);
  x2:=strtoint(ss[2]);
  y2:=strtoint(ss[3]);
  imgGetParam.Picture.Bitmap.Assign(uFuncs.captureScreen(x1,y1,x2,y2));

end;

procedure TfMain.btnTestSubmitVerificationCodeParamClick(Sender: TObject);
var
  ss:tstrings;
  x1,y1,x2,y2:integer;
begin
  ss:=tstringlist.Create;
  ss.CommaText:=trim(edtSubmitVerificationCodeParam.Text);
  x1:=strtoint(ss[0]);
  y1:=strtoint(ss[1]);
  x2:=strtoint(ss[2]);
  y2:=strtoint(ss[3]);
  imgGetParam.Picture.Bitmap.Assign(uFuncs.captureScreen(x1,y1,x2,y2));

end;

procedure TfMain.btnTokenClick(Sender: TObject);
var
  str1: tstringlist;
  memstr: TStringStream;
  i: integer;
  ss,token,getTime: string;
begin
  btnToken.Enabled:= false;
  screen.Cursor:= crhourglass;
  memstr:= TStringStream.Create('');
  idhttp1.ReadTimeout:= 15000;
  idhttp1.ConnectTimeout := 15000;
  try
    IdHTTP1.get('https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=5G4tOXwCGG5buEFPrZGGykal&client_secret=ceAs9I9xHUzrxs0OWfEBed2HnA4CerLS',memstr);
  except
    showmessage('获取token出错');
    memstr.Free;
    btnToken.Enabled:=true;
    exit;
  end;
  ss:= memstr.DataString;
  //token 提取
  i:= pos('access_token',ss);
  if i=0 then begin
    showmessage('取得的token为空');; //获取授权出错
    memstr.Free;
    btnToken.Enabled:=true;
    exit;
  end;
  token:= copy(ss,i,255);
  delete(token,1,pos(':',token));
  delete(token,1,pos('"',token));
  token:= copy(token,1,pos('"',token)-1);

  edtToken.Text:= token;
  fweb.token:=token;
  //保存
  DateTimeToString(gettime,'yyyy-mm-dd',now());
  uXml.setXmlNodeValue(uconfig.configFile,'pp.token','gettime',gettime);
  uXml.setXmlNodeValue(uconfig.configFile,'pp.token','',token);
  uXml.setXmlNodeValue(uconfig.configFile2,'pp.token','gettime',gettime);
  uXml.setXmlNodeValue(uconfig.configFile2,'pp.token','',token);
  memstr.Free;
  btntoken.Enabled:=true;
  screen.Cursor:= crdefault;
end;

procedure TfMain.btnUpdateInputAddPriceParamClick(Sender: TObject);
begin
   fweb.rctInputAddPrice:=getRectFromStr(edtInputAddPriceParam.text);
end;

procedure TfMain.btnUpdateFinishTimeClick(Sender: TObject);
begin
  fweb.mFinishTime:=strtodatetime(trim(edtFinishTime.Text)); //
  //fweb.mFinishTime:=VarToDateTime(trim(edtFinishTime.Text));
  speecher.say('结束时间是：'+trim(edtFinishTime.Text));
  showmessage('更新成功！');
end;

procedure TfMain.btnUpdateInputPriceParamClick(Sender: TObject);
begin
  fweb.rctInputPrice:=getRectFromStr(edtInputPriceParam.text);
end;

procedure TfMain.btnUpdateInputVerifyCodeParamClick(Sender: TObject);
begin
  fweb.rctInputVerificationCode:=getRectFromStr(edtInputVerificationCodeParam.text);
end;

procedure TfMain.btnUpdateIPClick(Sender: TObject);
var
  say:string;
  host:sthostInfo;
begin
  host.ip:=trim(edtHostIp.Text);
  host.port:=strtoint(trim(edtHostPort.Text));
  mHookSocketProcessor.DataPackage.Host:=host;
  say:='更新成功！';
  speecher.say(say);
  showmessage(say);
end;

procedure TfMain.btnUpdateSubmitAddPriceParamClick(Sender: TObject);
begin
  fweb.rctSubmitAddPrice:=getRectFromStr(edtSubmitAddPriceParam.text);
end;

procedure TfMain.btnUpdateSubmitPriceParamClick(Sender: TObject);
begin
  fweb.rctSubmitPrice:=getRectFromStr(edtSubmitPriceParam.text);
end;

procedure TfMain.btnUpdateSubmitVerificationCodeParamClick(Sender: TObject);
begin
  fweb.rctSubmitVerificationCode:=getRectFromStr(edtSubmitVerificationCodeParam.text);
end;

procedure TfMain.btnVirtualClick(Sender: TObject);
begin
  fweb.configFile:=uConfig.configFile;
  getParamsToCtl(uConfig.configFile);
  setParamsToWeb();
  fWeb.Show;
  //fWeb.wb1.Navigate('http://test.alltobid.com/moni/gerenbid.html');
  //webhook.HookWebAPI;
  fWeb.wb1.Navigate(fweb.virtalAddr);
  //状态显示：
  fweb.state.enterSys:=true;
  fweb.state.VirtualSys:=true;
  fweb.state.autoPP:=false;
  statusbar1.Panels[0].Text:='当前状态：模拟抢拍系统，未打开自动抢拍';
  btnGP.Enabled:=false;
  if not Assigned(fweb.mVerg) then fweb.mVerg:=tstringlist.Create;
  if not Assigned(fweb.mVerm) then fweb.mVerm:=tstringlist.Create;
  fweb.mVerm.Clear;
  fweb.mVerm.LoadFromFile(uconfig.verm);
end;
procedure TfMain.cmbSelSysChange(Sender: TObject);
begin
  edtGpSysAddr.Text:=cmbSelSys.Items[cmbSelSys.ItemIndex];
end;

procedure TfMain.cmbStrategyChange(Sender: TObject);
var
  say:string;
begin
  if(fweb.configFile='')then fweb.configFile:=uConfig.configFile;
case cmbStrategy.ItemIndex of
0:
  begin
    edtRequestVerCodeTime.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy1','requestvercodetime');
    edtSubmitVerCodeTime.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy1','submitpricetime');
    edtAddPrice.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy1','addprice');
    say:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy1');
  end;
1:
  begin
    edtRequestVerCodeTime.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy2','requestvercodetime');
    edtSubmitVerCodeTime.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy2','submitpricetime');
    edtAddPrice.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy2','addprice');
    say:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy2');
  end;
2:
  begin
    edtRequestVerCodeTime.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy3','requestvercodetime');
    edtSubmitVerCodeTime.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy3','submitpricetime');
    edtAddPrice.Text:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy3','addprice');
    say:=uXml.GetXMLNodeValue(fweb.configFile,'pp.strategy.strategy3');
  end;
end;
  memStrategySay.Text:='策略'+inttostr(cmbStrategy.ItemIndex+1)+'说明： '+#13#10+say;

end;

procedure TfMain.edtSubmitVerificationCodeParamChange(Sender: TObject);
begin

end;

{-----------------------------------------------------------------------------------
将参数写入到浏览器窗体中;
}
procedure TfMain.setParamsToWeb();
begin
  //edtPrice.Text:=uXml.GetXMLNodeSpecialValue(uConfig.configFile,'pp.pos.form') ;
  fweb.rctForm:=getRectFromStr(edtForm.text);
  fweb.rctPrice:=getRectFromStr(edtPrice.text);

  fweb.rctInputPrice:=getRectFromStr(edtInputPriceParam.text);
  fweb.rctSubmitPrice:=getRectFromStr(edtSubmitPriceParam.text);
  fweb.rctInputVerificationCode:=getRectFromStr(edtInputVerificationCodeParam.text);
  fweb.rctSubmitVerificationCode:=getRectFromStr(edtSubmitVerificationCodeParam.text);

  fweb.rctInputAddPrice:=getRectFromStr(edtInputAddPriceParam.text);
  fweb.rctSubmitAddPrice:=getRectFromStr(edtSubmitAddPriceParam.text);

  fweb.mFinishTime:=strtodatetime(trim(edtFinishTime.Text));

  fweb.mAddPrice:=strtoint(trim(edtAddPrice.Text)); //
  fweb.mRequestVerCodeTime:=strtoint(trim(edtRequestVercodeTime.Text)); //
  fweb.mSubmitVerCodeTime:=strtoint(trim(edtSubmitVercodeTime.Text));
  if(chkVerCode.Checked) then fweb.mVerCode:=trim(edtVerCode.Text) else fweb.mVerCode:='';

  fweb.virtalAddr:=trim(edtVirtualSysAddr.Text);
  fweb.GpAddr:=trim(edtGpSysAddr.Text);
  fweb.token:=trim(edttoken.Text);
end;
{-----------------------------------------------------------------------------------
从xml文件获取参数写入到控件中;
}
procedure TfMain.getParamsToCtl(configFile:string);
begin
  fWeb.appName:=uXml.GetXMLNodeValue(configFile,'pp.app') ;
  fWeb.appversion:=uXml.GetXMLNodeValue(configFile,'pp.app','version') ;

  edtForm.Text:=uXml.GetXMLNodeSpecialValue(configFile,'pp.pos.form') ;
  edtPrice.Text:=uXml.GetXMLNodeSpecialValue(configFile,'pp.pos.price') ;

  edtInputPriceParam.Text:=uXml.GetXMLNodeValue(configFile,'pp.pos.inputprice') ;
  edtSubmitPriceParam.Text:=uXml.GetXMLNodeValue(configFile,'pp.pos.submitprice') ;
  edtInputVerificationCodeParam.Text:=uXml.GetXMLNodeValue(configFile,'pp.pos.inputvercode') ;
  edtSubmitVerificationCodeParam.Text:=uXml.GetXMLNodeValue(configFile,'pp.pos.submitvercode') ;

  edtInputAddPriceParam.Text:=uXml.GetXMLNodeValue(configFile,'pp.pos.inputaddprice') ;
  edtSubmitAddPriceParam.Text:=uXml.GetXMLNodeValue(configFile,'pp.pos.submitaddprice') ;

  edtToken.Text:=uXml.GetXMLNodeValue(configFile,'pp.token') ;
end;
procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //uDown.stop;
  backupFlashLog();
  uDataDown.stop;
  btnSaveClick(sender);
  IdSNTP1.Host:='time.windows.com';
  IdSNTP1.SyncTime ;
  //mHookSocketProcessor.Suspend();
  //mHookSocketProcessor.free;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  SetMyGlobalEnvironment();
  Application.OnException := AppException;
  //Set8087CW(Longword($133f));
  IEEmulator(11001);
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  //btnSetSysTimeClick(sender);

  fMain.Top:=0;
  fMain.Left:=0;
  fweb.configFile:=uConfig.configFile;
  getParamsToCtl(uConfig.configFile);
  cmbStrategy.ItemIndex:=0;
  cmbStrategy.OnChange(sender);
  edtFinishTime.Text:=initendTime();
  setParamstoWeb();
  self.Caption:=fweb.appName+'v'+fweb.appVersion+'联系QQ1409232611微信：byc6352';
  statusbar1.Panels[2].Text:='当前屏幕分辨率：'+inttostr(screen.Width)+','+inttostr(screen.Height);
  //状态显示：
  fweb.state.enterSys:=false;
  fweb.state.VirtualSys:=true;
  fweb.state.autoPP:=false;
  statusbar1.Panels[0].Text:='当前状态：未进入系统';
  //statusbar1.Panels[0].Text:=uFuncs.GetDateFormatSep;
  IdSNTP1.Host:='time.windows.com';
  IdSNTP1.SyncTime ;

  TWinControl(fweb.Wb2).Visible:=False;

  uHookweb.hform:=fmain.Handle;
  uHookweb.bHook:=true;
  //uDown.start(uConfig.webCache,fmain.Handle);
  uDataDown.start(uConfig.webCache,fmain.Handle);
  page1.ActivePageIndex:=0;
  mHookSocketProcessor := THookSocketProcessor.getInstance(fmain.Handle);
  setMMcfg();
  uSpeecher.Speecher:=TSpeecher.Create(fmain.Handle);
  uSpeecher.Speecher.Token:=fweb.token;
  uSpeecher.Speecher.PlayVolum:=1;

end;

procedure TfMain.Timer1Timer(Sender: TObject);
var
  s:string;
  r:integer;
begin
  fweb.mRemainSec:=SecondsBetween(now(),fweb.mFinishTime);
  r := CompareDateTime(fweb.mFinishTime,now()); //1
  if(fweb.state.autoPP)then begin
    if(r=-1)then
     if(btnAutoPP.Caption='停止抢拍')then
      btnAutoPP.Click();
  end else begin
    if(fweb.mRemainSec<=20)and(fweb.state.enterSys=true or fweb.state.VirtualSys=true)and(r=1)then
       if(btnAutoPP.Caption='自动抢拍')then btnAutoPP.Click();
  end;
  DateTimeToString(s,'yyyy-mm-dd-hh-nn ss ',now());
  s:='当前时间：'+s;
  if(r=1)then s:=s+'剩余：'+inttostr(fweb.mRemainSec) else s:=s+'剩余：-'+inttostr(fweb.mRemainSec);
  statusbar1.Panels[1].Text:=s;
  getPrice();
  //if(fweb.Visible=true and chkFwebOnTop.Checked=true)then BringWindowToTop(fweb.handle);
  if(fWeb.state.autoPP)then begin
    fWeb.PriceStrategy();
    //fWeb.strategy1();//执行策略1
    //if(cmbStrategy.ItemIndex=0)then
    //  fWeb.AutoPriceStrategy
    //else
    //  fWeb.AddPriceStrategy();
    //fweb.SaveScreen();
  end;
end;
procedure TfMain.Timer2Timer(Sender: TObject);
begin
  fweb.mRemainSec:=fweb.mRemainSec-1;
  //fweb.AddPricestrategy;
  fweb.PriceStrategy;
  if(fweb.mRemainSec<=0)then begin
    btnTestPP.Click();
  end;
end;

function TfMain.getRectFromStr(s:string):tRect;
var
  i:integer;
  s1,s0:string;
  ss:tstrings;

begin
  s0:=trim(s);
  i:=pos(',',s0);
  ss:=tstringlist.Create;
  while(i>0)do
  begin
    s1:=midstr(s0,1,i-1);
    ss.Add(s1);
    delete(s0,1,i);
    i:=pos(',',s0);
    if(i<=0)then ss.Add(s0);
  end;
  result:=rect(strtoint(ss[0]),strtoint(ss[1]),strtoint(ss[2]),strtoint(ss[3]));
  ss.Free;
end;
procedure TfMain.getPrice();
var
  bmp:tbitmap;
  price:string;
begin
  if(chkPrice.Checked=false)then exit;
  bmp:=captureScreen(fweb.rctPrice.Left,fweb.rctPrice.Top,fweb.rctPrice.Right,fweb.rctPrice.Bottom);
  imgPrice.Picture.Bitmap.Assign(bmp);
  price:=trim(baiduIdentify(bmp));
  if(length(price)<=6) and (length(price)>=5) then begin
    fweb.mPrice:=strtoint(price);
    statusbar1.Panels[2].Text:='当前最低成交价：'+price;
  end;
  //fmain.Caption:='沪拍牌助手v1.0 '+mPrice;
end;
function TfMain.baiduIdentify(mem: TMemoryStream):string;
var
  iddec:TIdEncoderMIME;
  ss,url: string;
  str1: tstringlist;
  memstr: TStringStream;
  h: integer;
  jpg: tjpegimage;
begin
  idhttp1.ReadTimeout:= 65000;
  idhttp1.ConnectTimeout := 65000;
  memstr:= TStringStream.Create;
  mem.Position:= 0;
  iddec:=TIdEncoderMIME.Create;
  ss:= iddec.Encode(mem);  //  *******
  //mem.Free;
  //提交
  str1:= tstringlist.Create;
  str1.Add('image='+ URLEncode(ss));
      //str1.savetoFile('d:\c.txt');
  //url:= 'https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token=24.26acc87472fcf0fbf17bccacfda77abf.2592000.1560126599.282335-9533039';
  //url:= 'https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token='+fweb.token;
  //url:= 'https://aip.baidubce.com/rest/2.0/ocr/v1/accurate?access_token='+fweb.token;
  url:= 'https://aip.baidubce.com/rest/2.0/ocr/v1/webimage?access_token='+fweb.token;
  idhttp1.Request.ContentType:= 'application/x-www-form-urlencoded';
  try
    idhttp1.Post( url,str1,memstr);
    memstr.Position:= 0;
    ss:= memstr.Encoding.UTF8.GetString(memstr.Bytes);
    meminfo.Lines.Add(ss);
  finally
    memstr.Free;
    str1.Free;
    iddec.Free;
  end;
  h:= pos('words":',ss);
  if h >0 then
      begin
       while h>0 do
        begin
         delete(ss,1,h+6);
         delete(ss,1,pos('"',ss));
         result:=copy(ss,1,pos('"',ss)-1);
         h:= pos('words":',ss);
        end;
      end else
  result:=ss;
end;
function TfMain.baiduIdentify(bmp:Tbitmap):string;
var
  mem: TMemoryStream;
  iddec:TIdEncoderMIME;
  ss,url: string;
  str1: tstringlist;
  memstr: TStringStream;
  h: integer;
  jpg: tjpegimage;
begin
  idhttp1.ReadTimeout:= 65000;
  idhttp1.ConnectTimeout := 65000;

  //bmp:=tbitmap.Create;
  //bmp.LoadFromFile('D:\works\delphi\ocr\maxprice.bmp');
  mem:= TMemoryStream.Create;
  memstr:= TStringStream.Create;
  //jpg:= tjpegimage.Create;
  //jpg.Assign(bmp);
  //jpg.LoadFromFile('D:\works\delphi\ocr\maxprice.jpg');
  //jpg.Compress;
  //jpg.SaveToStream(mem);
  //mem.LoadFromFile('D:\works\delphi\ocr\maxprice.bmp');
  bmp.SaveToStream(mem);
  mem.Position:= 0;
  //mem.SaveToFile('d:\a.jpg');
  iddec:=TIdEncoderMIME.Create;
  ss:= iddec.Encode(mem);  //  *******
  mem.Free;
  //提交
  str1:= tstringlist.Create;
  str1.Add('image='+ URLEncode(ss));
      //str1.savetoFile('d:\c.txt');
  //url:= 'https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token=24.26acc87472fcf0fbf17bccacfda77abf.2592000.1560126599.282335-9533039';
  url:= 'https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic?access_token='+fweb.token;
  idhttp1.Request.ContentType:= 'application/x-www-form-urlencoded';
  try
    idhttp1.Post( url,str1,memstr);
    memstr.Position:= 0;
    ss:= memstr.Encoding.UTF8.GetString(memstr.Bytes);
    meminfo.Lines.Add(ss);
  finally
    memstr.Free;
    str1.Free;
    iddec.Free;
  end;
  h:= pos('words":',ss);
  if h >0 then
      begin
       while h>0 do
        begin
         delete(ss,1,h+6);
         delete(ss,1,pos('"',ss));
         result:=copy(ss,1,pos('"',ss)-1);
         h:= pos('words":',ss);
        end;
      end else
  result:=ss;
end;
function URLEncode(msg:String):String;
var
 I:Integer;
begin
Result:='';
for I := 1 to Length(msg) do begin
   if msg[I] in ['a'..'z', 'A'..'Z', '0'..'9'] then
       Result := Result + msg[I]
      else
       Result := Result + '%' + IntToHex(ord(msg[I]), 2);
 end;

end;
function captureScreen(x1:integer;y1:integer;x2:integer;y2:integer):tbitmap;
var
  dc:HDC;
  bmp:tbitmap;
  fullCanvas:TCanvas;
begin
  dc:=GetDC(0);
  fullCanvas:=TCanvas.Create;
  fullCanvas.Handle:=dc;
  bmp:=TBitmap.Create;
  try
    bmp.Width:=abs(x2-x1);
    bmp.Height:=abs(y2-y1);
    bmp.Canvas.CopyRect(Rect(0,0,bmp.Width,bmp.Height),fullCanvas,Rect(x1,y1,x2,y2));
    //bmp.SaveToFile('c:\tmp\1.bmp');
  finally
  end;
  result:=bmp;
end;


{
  function MergeUrl(ServerName,ObjectName:string;ServerPort:DWORD):string;//组合url
  procedure addDown();

 procedure addDown();
var
  url,ServerName,ObjectName:string;
  ServerPort:DWORD;
begin
  while iDown<uData.iData do
  begin
    ServerName:=uData.datas[iDown].ServerName;
    ObjectName:=uData.datas[iDown].ObjectName;
    ServerPort:=uData.datas[iDown].ServerPort;
    url:=MergeUrl(ServerName,ObjectName,ServerPort);
    iDown:=iDown+1;
    if(url='')then continue;
    uDown.addUrl(url);
  end;

end;
function MergeUrl(ServerName,ObjectName:string;ServerPort:DWORD):string;//组合url
var
  protocol:string;
begin
  result:='';
  if(servername='')or(serverport=0)then exit;
  if(ObjectName[1]<>'/')then exit;
  protocol:='http';
  //if(ObjectName2[1]<>'/')then ObjectName2:='/'+ObjectName;
  case ServerPort of
  80:begin
    result:=protocol+'://'+ServerName+ObjectName;
  end;
  443:begin
    protocol:='https';
    result:=protocol+'://'+ServerName+ObjectName;
  end;
  else begin
    result:=protocol+'://'+ServerName+':'+inttostr(ServerPort)+ObjectName;
  end;
  end;
end;

}
end.
