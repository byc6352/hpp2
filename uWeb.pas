unit uWeb;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, Vcl.AppEvnts,ActiveX,uFuncs,uConfig
  ,jpeg, Comobj, MSHTML,strutils, Vcl.ExtCtrls,UrlMon;

type
  Tstate=record
    enterSys:boolean;//打开浏览器没
    VirtualSys:boolean;//模拟系统吗
    autoPP:boolean;//启动自动抢拍吗
  end;
  TfWeb = class(TForm)
    wb1: TWebBrowser;
    ApplicationEvents1: TApplicationEvents;
    Panel2: TPanel;
    wb2: TWebBrowser;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure wb1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure wb2BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure wb1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool);
    procedure wb1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
  private
    { Private declarations }
    mIsRct:boolean;
    //paramPos1:tPoint;//参数坐标
    //**********************************抢拍策略**************************************************

    procedure getParam(Msg: tagMSG);//获取参数
    procedure GenerateJPEGfromBrowser(browser: iWebBrowser2;
                                  jpegFQFilename: string; srcHeight:
                                  integer; srcWidth: integer;
                                  tarHeight: integer; tarWidth: integer);
    procedure mouseClick(pos:tPoint);
    procedure keyPress(k:char);
    procedure inputstring(s:string);
    function getClientIdFromCookie(pageCookie:string):string;
  public
    { Public declarations }
    appName,appVersion:string;//系统名称，版本号
    state:Tstate;//系统状态
    rctParam,rctForm,rctPrice,rctInputPrice,rctSubmitPrice,rctInputVerificationCode,rctSubmitVerificationCode:tRect; //控件坐标参数
    rctInputAddPrice,rctSubmitAddPrice:tRect; //控件坐标参数
    mPrice:integer; //当前价格
    mIsSubmitPrice,mIsSubmitVerifiCode:boolean;//是否提交价格，是否提交验证码
    mIsAddPrice:boolean;//是否已加价
    mIsSubmitPrice1,mIsSubmitVerifiCode1:boolean;//是否提交价格，是否提交验证码
    //**********************************抢拍策略**************************************************
    mFinishTime:tDatetime;//抢拍线束时间点
    mRemainSec,mRemainSec1:integer;//剩下的秒数
    virtalAddr,GPaddr,mVerCode:string;//地址,验证码
    mAddPrice:integer;//加价幅度
    mRequestVerCodeTime:integer;//出价时间点
    mSubmitVerCodeTime:integer;//提交服务器时间点
    configFile:string;//当前配置文件；
    token:string;
    mVerg,mVerm:tstrings;//验证码；
    mclientId,mbidnumber:string;//客户id
    mPage:string;                //当前网页地址
    procedure strategy1();
    procedure Initstrategy1();
    procedure strategy1Test();//测试抢拍策略1
    procedure SaveScreen();
    procedure AddPriceStrategy();
    procedure InitAddPriceStrategy();
    procedure AutoPriceStrategy();
    procedure PriceStrategy();
    procedure setCookie(cookie:string);
  end;

var
  fWeb: TfWeb;

implementation
uses
  uMain,uHookweb,uDown;
{$R *.dfm}
procedure TfWeb.setCookie(cookie:string);
var
  doc:IHTMLDocument2;
  html_bid_user:ihtmlinputelement;
  ss:tstrings;
  i:integer;
begin
try
  ss:=tstringlist.Create;
  ss.Delimiter:=';';
  ss.DelimitedText:=cookie;
  doc:=fweb.wb1.Document as IHTMLDocument2;
  for I := 0 to ss.Count-1 do
  begin
    doc.cookie:=ss[i];
  end;

  //wb1.Refresh;
  html_bid_user:=(doc.all.item('bidnumber',0) as ihtmlinputelement);
  html_bid_user.value:=fmain.edtBidnumber.Text;
  html_bid_user:=(doc.all.item('bidpassword',0) as ihtmlinputelement);
  html_bid_user.value:='1234';
finally

end;
end;
function TfWeb.getClientIdFromCookie(pageCookie:string):string;
var
  i:integer;
  ss:tstrings;
  s:string;
procedure getBidnumber(s:string;var bidnumber:string);
var
  j:integer;
begin
  j:=pos('bidnumber',lowercase(s));
  if(j<=0)then exit;
  j:=pos('=',s);
  if(j<=0)then exit;
  bidnumber:=rightstr(s,length(s)-j);
end;
procedure getClientId(s:string;var ClientId:string);
var
  j:integer;
begin
  j:=pos(lowercase('clientId'),lowercase(s));
  if(j<=0)then exit;
  j:=pos('=',s);
  if(j<=0)then exit;
  ClientId:=rightstr(s,length(s)-j);
end;
begin
  result:='';
  if length(pageCookie)=0 then  exit;
try
  ss:=tstringlist.Create;
  ss.Delimiter:=';';
  ss.DelimitedText:=pageCookie;
  if ss.Count<=0 then exit;
  for I := 0 to ss.Count-1 do
  begin
    getBidnumber(ss[i],mBidnumber);
    getClientId(ss[i],mClientId);
  end;
  result:=mClientId;
finally
  ss.Free;
end;
end;
procedure TfWeb.SaveScreen();
var
  bmp:tbitmap;
  filename:string;
begin
  filename:=uConfig.webdir+'\'+uFuncs.getDateFilename+'.bmp';
  bmp:=uFuncs.captureScreen(0,0,screen.Width,screen.Height);
  bmp.SaveToFile(filename);
  bmp.Destroy;
end;
procedure TfWeb.getParam(Msg: tagMSG);//获取参数
var
  pos1,pos2: TPoint;
  bmp:tbitmap;
begin
  if(fMain.chkGetParam.Checked=false)then exit;
  if IsChild(wb1.Handle, Msg.Hwnd)=false then exit;
  if(Msg.message = WM_LBUTTONDOWN)then begin
    GetCursorPos(pos1); //得到光标位置
    pos2.X:=0;pos2.Y:=0;
    rctParam:=rect(pos1,pos2);
    mIsRct:=true;
  end;
  if(Msg.message = WM_LBUTTONUP)then begin
    mIsRct:=false;
    GetCursorPos(pos2); //得到光标位置
    rctParam.BottomRight:=pos2;
    bmp:=uFuncs.captureScreen(rctParam.Left,rctParam.Top,rctParam.Right,rctParam.Bottom);
    fMain.imgGetParam.Picture.Bitmap.Assign(bmp);
    fMain.edtGetParam.Text:=inttostr(rctParam.Left)+','+inttostr(rctParam.Top)+','+inttostr(rctParam.Right)+','+inttostr(rctParam.Bottom);
  end;
end;
procedure TfWeb.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  pos: TPoint;
begin
  if IsChild(wb1.Handle, Msg.Hwnd) and (Msg.message = WM_MOUSEMOVE) and (fmain.chkGetParam.Checked=true) then
  begin
    GetCursorPos(pos); //得到光标位置
    //fMain.lbPos.Caption:='当前坐标：'+inttostr(pos.X)+','+inttostr(pos.Y);
    fMain.StatusBar1.Panels[2].Text:='当前坐标：'+inttostr(pos.X)+','+inttostr(pos.Y);
    if(mIsRct)then begin
      rctParam.BottomRight:=pos;
      //Canvas.Rectangle(rctParam);
      fweb.Canvas.Rectangle(rctParam);
    end;
  end;
  getParam(msg);
end;

procedure TfWeb.FormCreate(Sender: TObject);
begin
  fWeb.Left:=Round(Screen.width/2);
  fWeb.top:=Round(Screen.height/8);
  fWeb.width:=Round(Screen.width/2);
  fWeb.height:=Round(Screen.Height/4*3);
  //if not assigned(mDowns) then mDowns:=tstringlist.Create;

end;

procedure TfWeb.FormShow(Sender: TObject);
begin


  fWeb.Left:=rctForm.Left;
  fWeb.top:=rctForm.Top;
  fWeb.width:=rctForm.Width;
  fWeb.height:=rctForm.Height;
    //窗口置顶
  BringWindowToTop(fweb.handle);
  //SetWindowPos(fweb.handle,HWND_TOPMOST,rctForm.Left,rctForm.Top,rctForm.Width,rctForm.Height,SWP_NOMOVE  or  SWP_NOSIZE);
  //wb1.Navigate('http://test.alltobid.com/moni/gerenbid.html');
  fweb.Canvas.Pen.Width:=2;
  fweb.Canvas.Pen.Style:=psDash;
  fweb.Canvas.Pen.Color:=clred;
  fweb.Canvas.Pen.Mode:=pmcopy;
end;

procedure TfWeb.wb1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
begin
  uHookweb.state:=STAT_BROWSING;
  //uDown.pause;
  //bar1.Panels[0].Text:='正在加载页面...';
end;

procedure TfWeb.wb1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
var
  ms: TMemoryStream;
  page_cookie:string;
  doc: IHTMLDocument2;
  Web  : iWebBrowser2;
  tmpX,
  tmpY : integer;
begin
  if not Assigned(wb1.Document) then Exit;
  if(Wb1.ReadyState<>READYSTATE_COMPLETE)then exit;
  if(uHookweb.state=STAT_IDLE)then exit;
  uHookweb.state:=STAT_IDLE;

  fWeb.width:=wb1.width;
  fWeb.height:=wb1.Height;
  //uDown.start();
  //doc:=wb1.Document as IHTMLDocument2;
  {
  ms := TMemoryStream.Create;
  (wb1.Document as IPersistStreamInit).Save(TStreamAdapter.Create(ms), True);
  ms.Position := 0;
  filename:=uConfig.webdir+'\'+uFuncs.getDateFilename+'.txt';
  ms.SaveToFile(filename);
  ms.Free;
  filename:=leftstr(filename,length(filename)-4)+'.jpg';
  with wb1 do
  begin
    Document.QueryInterface(IHTMLDocument2, doc);
    Web := wb1.ControlInterface;
    tmpX := wb1.Height;
    tmpY := wb1.Width;
    //Height := OleObject.Document.ParentWindow.Screen.Height;
    //Width := OleObject.Document.ParentWindow.Screen.Width;
    GenerateJPEGfromBrowser(Web, filename,
                            Height, Width,
                            Height, Width);
    //Height := tmpX;
    //Width := tmpY;
  end;
  }

  //mPage:=doc.url;
  //mSite:=doc.domain;
  //mProtocol:=doc.protocol;
  //if(mProtocol='HyperText Transfer Protocol with Privacy')then mProtocol:='https://' else mProtocol:='http://';
  //if(pos(mPage,mDowns.Text)<=0)then mDowns.Add(mPage);
  //downloadFilesThread();
  doc:=wb1.Document as IHTMLDocument2;
  mPage:=doc.url;
  fmain.memInfo.lines.Add(mPage);
  fmain.memInfo.lines.Add('cookie:'+doc.cookie);
  fmain.edtPage.Text:=mPage;
  if(pos('bid.htm',mPage)>0)then
  begin
  page_cookie:=doc.cookie;

  if(length(page_cookie)>0)then
  begin
    fmain.edtCookie.Text:=page_cookie;
    getClientIdFromCookie(page_cookie);
    if(length(mClientId)>0) then
      fmain.edtClientId.Text:=mClientId;
    if(length(mBidnumber)>0) then
    begin
      fmain.edtBidnumber.Text:=mBidnumber;
      fmain.mHookSocketProcessor.DataPackage.ClientId:=mClientId;
    end;
  end;
  end;
end;
procedure TfWeb.wb1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
  var Cancel: WordBool);
begin
ppDisp := wb2.Application; // 新的窗口先指向WebBrowser2
end;

procedure TfWeb.wb2BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
begin
  wb1.Navigate(string(URL)); // 再指回WebBrowser1
  Cancel := True;
end;

procedure TfWeb.GenerateJPEGfromBrowser(browser: iWebBrowser2;
                                  jpegFQFilename: string; srcHeight:
                                  integer; srcWidth: integer;
                                  tarHeight: integer; tarWidth: integer);
var
  sourceDrawRect: TRect;
  targetDrawRect: TRect;
  sourceBitmap  : TBitmap;
  targetBitmap  : TBitmap;
  aJPG          : TJPEGImage;
  aViewObject   : IViewObject;
begin { GenerateJPEGfromBrowser }
  sourceBitmap := TBitmap.Create;
  targetBitmap := TBitmap.Create;
  aJPG := TJPEGImage.Create;
  try
    try
      sourceDrawRect := Rect(0, 0, srcWidth, srcHeight);
      sourceBitmap.Width := srcWidth;
      sourceBitmap.Height := srcHeight;

      aViewObject := browser as IViewObject;

      if aViewObject=nil then
        Exit;

      OleCheck(aViewObject.Draw(DVASPECT_CONTENT, 1, nil, nil,
                               fWeb.Handle,
                               sourceBitmap.Canvas.Handle,
                               @sourceDrawRect, nil, nil, 0));

      // Resize the src bitmap to the target bitmap
      // Need to make thumbnails instead of full size?
      // set the target size here..
      targetDrawRect := Rect(0, 0, tarWidth, tarHeight);
      targetBitmap.Height := tarHeight;
      targetBitmap.Width := tarWidth;
      targetBitmap.Canvas.StretchDraw(targetDrawRect, sourceBitmap);

      // Create a JPEG from the Bitmap and save it
      aJPG.Assign(targetBitmap);

      aJPG.SaveToFile(jpegFQFilename)
    finally
      aJPG.Free;
      sourceBitmap.Free;
      targetBitmap.Free
    end; { try }

  except
    // error handler code
  end; { try }
end; { GenerateJPEGfromBrowser }

//**********************************抢拍策略**************************************************
procedure TfWeb.Initstrategy1();
begin
  mIsSubmitPrice:=false;
  mIsSubmitVerifiCode:=false;
end;
{-------------------------------------------------------------------------
 抢拍策略1：
}
procedure TfWeb.strategy1();
const
  REMAIN_SEC_SUBMIT_PRICE:integer=15;//出价时间点
  REMAIN_SEC_SUBMIT_VERCODE:integer=5;//提交验证码时间点
var
  inputPrice:integer; //计算得到的价格
begin
  if(mRemainSec<REMAIN_SEC_SUBMIT_PRICE) and (mIsSubmitPrice=false)then //开始提交价格：
  begin
    mIsSubmitPrice:=true;
    //1.输入价格；
    inputPrice:=mPrice+mAddPrice;
    mouseClick(rctInputPrice.CenterPoint);
    inputstring(inttostr(inputPrice));
    //2.点击提交
    mouseClick(rctSubmitPrice.CenterPoint);
    //3.点击输入验证码文本框：
    mouseClick(rctInputVerificationCode.CenterPoint);
  end;
  if(mRemainSec<REMAIN_SEC_SUBMIT_VERCODE) and (mIsSubmitVerifiCode=false)then //开始提交验证码：
  begin
    mIsSubmitVerifiCode:=true;
    //点击提交
    mouseClick(rctSubmitVerificationCode.CenterPoint);
  end;
end;
{-------------------------------------------------------------------------
 抢拍策略1：
}
procedure TfWeb.strategy1Test();
const
  REMAIN_SEC_SUBMIT_PRICE:integer=15;//出价时间点
  REMAIN_SEC_SUBMIT_VERCODE:integer=5;//提交验证码时间点
var
  inputPrice:integer; //计算得到的价格
begin
  if(mRemainSec1<REMAIN_SEC_SUBMIT_PRICE) and (mIsSubmitPrice1=false)then //开始提交价格：
  begin
    mIsSubmitPrice1:=true;
    //1.输入价格；
    inputPrice:=mPrice+mAddPrice;
    mouseClick(rctInputPrice.CenterPoint);
    inputstring(inttostr(inputPrice));
    //2.点击提交
    mouseClick(rctSubmitPrice.CenterPoint);
    //3.点击输入验证码文本框：
    mouseClick(rctInputVerificationCode.CenterPoint);
  end;
  if(mRemainSec1<REMAIN_SEC_SUBMIT_VERCODE) and (mIsSubmitVerifiCode1=false)then //开始提交验证码：
  begin
    mIsSubmitVerifiCode1:=true;
    //点击提交
    mouseClick(rctSubmitVerificationCode.CenterPoint);
  end;
end;
//点击鼠标：包含移动
procedure TfWeb.mouseClick(pos:tPoint);
begin
  SetCursorPos(pos.X,pos.Y);
  Mouse_Event(MOUSEEVENTF_LEFTDOWN,pos.X,pos.Y,0,0);
  Mouse_Event(MOUSEEVENTF_LEFTUP,pos.X,pos.Y,0,0);
end;
//模拟键盘输入
procedure TfWeb.keyPress(k:char);
begin
  keybd_event(ord(k), MapVirtualKey(ord(k), 0), 0, 0);
  keybd_event(ord(k), MapVirtualKey(ord(k), 0), KEYEVENTF_KEYUP, 0);
end;
//模拟键盘输入字符串
procedure TfWeb.inputstring(s:string);
var
  i:integer;
  k:char;
begin
  for i:=1 to length(s) do
  begin
    k:=s[i];
    keyPress(k);
  end;
end;
//**********************************加价抢拍策略**************************************************
procedure TfWeb.InitAddPriceStrategy();
begin
  mIsAddPrice:=false;
  mIsSubmitPrice:=false;
  mIsSubmitVerifiCode:=false;
end;
{-------------------------------------------------------------------------
 加价抢拍策略1：
}
procedure TfWeb.AddPriceStrategy();
const
  REMAIN_SEC_SUBMIT_PRICE:integer=15;//出价时间点
  REMAIN_SEC_SUBMIT_VERCODE:integer=5;//提交验证码时间点
var
  pos:tPoint;
begin
  if(mIsAddPrice=false)then begin //1.输入加价值
     mIsAddPrice:=true;
     mouseClick(rctInputAddPrice.CenterPoint);
     inputstring(inttostr(mAddPrice));
  end;
  if(mRemainSec<mRequestVerCodeTime) and (mIsSubmitPrice=false)then //开始提交价格：
  begin
    mIsSubmitPrice:=true;
    //1.点击加价按钮；
    mouseClick(rctSubmitAddPrice.CenterPoint);
    sleep(10);
    //2.点击提交
    mouseClick(rctSubmitPrice.CenterPoint);
    sleep(1000);
    //3.点击输入验证码文本框：
    mouseClick(rctInputVerificationCode.CenterPoint);
  end;
  if(mRemainSec<mSubmitVerCodeTime) and (mIsSubmitVerifiCode=false)then //开始提交验证码：
  begin
    mIsSubmitVerifiCode:=true;
    //4.点击提交
    getCursorPos(pos);
    mouseClick(pos);
    sleep(10);
    mouseClick(rctSubmitVerificationCode.CenterPoint);
  end;
end;
{-------------------------------------------------------------------------
 全自动抢拍策略1：
}
procedure TfWeb.AutoPriceStrategy();
const
  REMAIN_SEC_SUBMIT_PRICE:integer=15;//出价时间点
  REMAIN_SEC_SUBMIT_VERCODE:integer=5;//提交验证码时间点
var
  pos:tPoint;
begin
  if(mIsAddPrice=false)then begin //1.输入加价值
     mIsAddPrice:=true;
     mouseClick(rctInputAddPrice.CenterPoint);
     inputstring(inttostr(mAddPrice));
  end;
  if(mRemainSec<mRequestVerCodeTime) and (mIsSubmitPrice=false)then //开始提交价格：
  begin
    mIsSubmitPrice:=true;
    //1.点击加价按钮；
    mouseClick(rctSubmitAddPrice.CenterPoint);
    sleep(10);
    //2.点击提交
    mouseClick(rctSubmitPrice.CenterPoint);
    sleep(1000);
    //3.点击输入验证码文本框：
    mouseClick(rctInputVerificationCode.CenterPoint);
    //4.输入验证码(文本框)：
    inputstring(mVerCode);
    //5.点击提交验证码按钮:
    mouseClick(rctSubmitVerificationCode.CenterPoint);
  end;

end;

{-------------------------------------------------------------------------
 加价+自动抢拍策略1：
}
procedure TfWeb.PriceStrategy();
var
  pos:tPoint;
begin
  if(mIsAddPrice=false)then begin //1.输入加价值
     mIsAddPrice:=true;
     mouseClick(rctInputAddPrice.CenterPoint);
     inputstring(inttostr(mAddPrice));
  end;
  if(mRemainSec<mRequestVerCodeTime) and (mIsSubmitPrice=false)then //开始提交价格：
  begin
    mIsSubmitPrice:=true;
    //1.点击加价按钮；
    mouseClick(rctSubmitAddPrice.CenterPoint);
    sleep(10);
    //2.点击提交
    mouseClick(rctSubmitPrice.CenterPoint);
    //sleep(1000);

  end;
  if(mRemainSec<mSubmitVerCodeTime) and (mIsSubmitVerifiCode=false)then //开始提交验证码：
  begin
    mIsSubmitVerifiCode:=true;
    //3.点击输入验证码文本框：
    mouseClick(rctInputVerificationCode.CenterPoint);
    //4.如果验证码不为空，则输入验证码；
    if(fmain.chkVerCode.Checked) then fweb.mVerCode:=trim(fmain.edtVerCode.Text) else fweb.mVerCode:='';
    if(mVerCode<>'')then inputstring(mVerCode) else fmain.memInfo.Lines.Add('验证码为空！');
    //5.点击提交
    getCursorPos(pos);
    mouseClick(pos);
    sleep(10);
    mouseClick(rctSubmitVerificationCode.CenterPoint);
    keybd_event(VK_RETURN, MapVirtualKey(VK_RETURN, 0), 0, 0); //
  end;

  end;

{
  bDownFiles:boolean;//下载工作线程变量；
  mDowns:tstrings;
  mPage,mSite,mProtocol:string;//主页URL ，站点URL, 协议(http://,https://),工作目录
function DownloadToFile(Source, Dest: string): Boolean; //uses urlmon;
procedure downloadfile(url:string); //下载指定链接的文件
function url2file(url:string):string;//链接转换为本地文件路径
function getSite(url:string):string;//获取主站地址；
procedure downloadFilesThread();//下载子线程；




//------------------------------------------下载线程区------------------------------------------
function ThreadProc(param: LPVOID): DWORD; stdcall;
var
  i,k:integer;//当前下载序号
  url:string;
begin
  i:=0;
  k:=0;
  while bDownFiles do begin
    if(i>=mDowns.Count)then begin sleep(1000);continue;end;
    url:=mDowns[i];
    //PostMessage(fMain.Handle, WM_DOWN_WORK,0,i);
    downloadfile(url);
    i:=i+1;
  end;
  //PostMessage(fMain.Handle, WM_DOWN_WORK,1,i);
  Result := 0;
end;

procedure downloadFilesThread();
var
  threadId: TThreadID;
begin
  if(bDownFiles)then exit;
  bDownFiles:=true;
  CreateThread(nil, 0, @ThreadProc, nil, 0, threadId);
end;

//------------------------------------------公共函数区----------------------------------------------
//uses urlmon;
function DownloadToFile(Source, Dest: string): Boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(source), PChar(Dest), 0, nil) = 0;
  except
    Result := False;
  end;
end;
//下载指定链接的文件
procedure downloadfile(url:string);
var
  localpath,remotepath:string;
begin
  remotepath:=url;
  if pos('/',remotepath)=1 then remotepath:=mProtocol+msite+remotepath;
  localpath:=url2file(remotepath);
  if(fileexists(localpath))then exit;
  DownloadToFile(remotepath,localpath);
end;
//链接转换为本地文件路径
function url2file(url:string):string;
var
  p,i:integer;
  s,dir,fullDir:string; //forcedirectories(mWorkDir);
begin
  s:=url;
  p:=pos('/',s);
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);  //去除http头部
  if(dir='https:')then s:=rightstr(s,length(s)-8);  //去除https头部
  p:=pos('/',s);
  dir:=leftstr(s,p-1);
  if(dir<>msite)then s:=msite+s;  //添加主站地址
  fullDir:=uconfig.webdir;  //程序工作目录；
  p:=pos('/',s);
  while p>0 do begin
    dir:=leftstr(s,p-1);
    fullDir:=fullDir+'\'+dir;
    if(not directoryexists(fullDir))then forcedirectories(fullDir);  //创建本地文件目录
    s:=rightstr(s,length(s)-length(dir)-1);
    p:=pos('/',s);
  end;
  p:=pos('?',s);  //排除链接里面?后面的内容；
  if(p>0)then s:=leftstr(s,p-1);
  result:=fullDir+'\'+s;
end;
//获取主站地址；
function getSite(url:string):string;
var
  dir,s:string;
  p:integer;
begin
  s:=url;
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);
  if(dir='https:')then s:=rightstr(s,length(s)-8);
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  s:=leftstr(s,p-1);
  result:=s;
end;




}
initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
end.
