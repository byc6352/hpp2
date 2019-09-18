unit uFuncs;

interface
uses
   System.SysUtils,windows, Vcl.Graphics,system.classes;

function getDateFilename():string;
function captureScreen(x1:integer;y1:integer;x2:integer;y2:integer):tbitmap;
function GetDateFormatSep():string;

implementation
  function getDateFilename():string;
  var
    s:string;
  begin
    DateTimeToString(s,'yyyymmddhhnnsss',now());
    result:=s;
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
function GetDateFormatSep():string;
var
  SysFrset: TFormatSettings;
begin
  Result:='';
  GetLocaleFormatSettings(GetUserDefaultLCID, SysFrset);
  Result:=SysFrset.DateSeparator;  //DateSeparator当前系统日期分隔符
end;
end.
