unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,uWeb,strutils, Vcl.ComCtrls,uXml,uconfig,
  Vcl.ExtCtrls, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,jpeg, IdCoderMIME,uAuth,
  IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,dateUtils,uFuncs,
  IdHTTP, IdUDPBase, IdUDPClient, IdSNTP,webhook;

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
  private
    { Private declarations }
    procedure getParamsToCtl(configFile:string);
    procedure setParamsToWeb();
    function baiduIdentify(bmp:Tbitmap):string;
    function getRectFromStr(s:string):tRect;
    procedure getPrice();
    procedure saveStrategy(configFile:string);
    procedure httpMessage(var MSG:TMessage); message WM_CAP_WORK;
    procedure getVerCode(url:string);
  public
    { Public declarations }

  end;

var
  fMain: TfMain;
  function URLEncode(msg:String):String;
  function captureScreen(x1:integer;y1:integer;x2:integer;y2:integer):tbitmap;
  function initEndTime():string;
  function ReversePos(SubStr, S: String): Integer;
implementation

{$R *.dfm}
function ReversePos(SubStr, S: String): Integer;
var
  i : Integer;
begin
  i := Pos(ReverseString(SubStr), ReverseString(S));
  if i > 0 then i := Length(S) - i - Length(SubStr) + 2;
  Result := i;
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
      data:=gSend;
    end;
  1:begin
      say:='接收数据：'+inttostr(len);
      data:=gRecv;
    end;
  2:begin
      say:='URL：'+inttostr(len);
      data:=gUrl;
      if(pos(data,mDowns.Text)<=0)then mDowns.Add(data);
      getVerCode(data);
    end;
  end;
  memInfo.Lines.Add(say);
  if(length(data)<500)then
    memInfo.Lines.Add(data);
  statusbar1.Panels[0].Text:=say;
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
begin

  if(btnAutoPP.Caption='自动抢拍')then
  begin
    if(fweb.state.enterSys=false)then
    begin
      showmessage('必须先进入抢拍系统，才能开始抢拍！');
      exit;
    end;
    btnAutoPP.Caption:='停止抢拍';
    fweb.state.autoPP:=true;
    setParamsToWeb();
    fweb.initAddPriceStrategy();
    saveStrategy(fweb.configFile);//保存策略参数
    if(fweb.state.VirtualSys)then
      begin
        statusbar1.Panels[0].Text:='当前状态：模拟抢拍系统，已打开自动抢拍';
        exit;
      end else begin
        statusbar1.Panels[0].Text:='当前状态：国拍抢拍系统，已打开自动抢拍';
      end;
  end else begin
    btnAutoPP.Caption:='自动抢拍';
    fweb.state.autoPP:=false;
    chkPrice.Checked:=false;
    if(fweb.state.VirtualSys)then
    begin
      statusbar1.Panels[0].Text:='当前状态：模拟抢拍系统，已停止自动抢拍';
      exit;
    end else begin
      statusbar1.Panels[0].Text:='当前状态：国拍抢拍系统，已停止自动抢拍';
    end;
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
  webhook.HookWebAPI;
  fWeb.wb1.Navigate(fweb.GPaddr);
  //状态显示：
  fweb.state.enterSys:=true;
  fweb.state.VirtualSys:=false;
  fweb.state.autoPP:=false;
  statusbar1.Panels[0].Text:='当前状态：国拍抢拍系统，未打开自动抢拍';
  btnVirtual.Enabled:=false;
  //rctWeb:=rect(900,20,1860,780);
  //MoveWindow(fWeb.Handle,rctWeb.left,rctWeb.Top,rctWeb.Width,rctweb.Height,true);
end;

procedure TfMain.btnPriceSaveClick(Sender: TObject);
begin
  uXml.SetXMLNodeSpecialValue(fweb.configFile,'pp.pos.price','',trim(edtPrice.text));
end;

procedure TfMain.btnPriceUpdateClick(Sender: TObject);
begin
  fweb.rctPrice:=getRectFromStr(edtPrice.text);
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
  webhook.HookWebAPI;
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
procedure TfMain.FormShow(Sender: TObject);
begin
  fMain.Top:=0;
  fMain.Left:=0;
  fweb.configFile:=uConfig.configFile;
  getParamsToCtl(uConfig.configFile);
  cmbStrategy.ItemIndex:=0;
  cmbStrategy.OnChange(sender);
  edtFinishTime.Text:=initendTime();
  setParamstoWeb();
  self.Caption:=fweb.appName+'v'+fweb.appVersion+'联系QQ1409232611';
  statusbar1.Panels[2].Text:='当前屏幕分辨率：'+inttostr(screen.Width)+','+inttostr(screen.Height);
  //状态显示：
  fweb.state.enterSys:=false;
  fweb.state.VirtualSys:=true;
  fweb.state.autoPP:=false;
  statusbar1.Panels[0].Text:='当前状态：未进入系统';
  //statusbar1.Panels[0].Text:=uFuncs.GetDateFormatSep;
  IdSNTP1.Host:='time.windows.com';
  IdSNTP1.SyncTime ;
  webhook.hform:=fmain.Handle;
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
end.
