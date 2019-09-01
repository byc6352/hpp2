unit uWeb;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw, Vcl.AppEvnts,ActiveX,uFuncs,uConfig
  ,jpeg, Comobj, MSHTML,strutils, Vcl.ExtCtrls;

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
    procedure strategy1();
    procedure Initstrategy1();
    procedure strategy1Test();//测试抢拍策略1
    procedure SaveScreen();
    procedure AddPriceStrategy();
    procedure InitAddPriceStrategy();
    procedure AutoPriceStrategy();
    procedure PriceStrategy();
  end;

var
  fWeb: TfWeb;

implementation
uses
  uMain;
{$R *.dfm}
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

procedure TfWeb.wb1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
var
  ms: TMemoryStream;
  filename:string;
  IDoc1: IHTMLDocument2;
  Web  : iWebBrowser2;
  tmpX,
  tmpY : integer;
begin
  if not Assigned(wb1.Document) then Exit;
  ms := TMemoryStream.Create;
  (wb1.Document as IPersistStreamInit).Save(TStreamAdapter.Create(ms), True);
  ms.Position := 0;
  filename:=uConfig.webdir+'\'+uFuncs.getDateFilename+'.txt';
  ms.SaveToFile(filename);
  ms.Free;
  filename:=leftstr(filename,length(filename)-4)+'.jpg';
  with wb1 do
  begin
    Document.QueryInterface(IHTMLDocument2, IDoc1);
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
  fWeb.width:=wb1.width;
  fWeb.height:=wb1.Height;
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

end.
