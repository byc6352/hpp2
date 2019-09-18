unit uLog;

interface
uses windows,sysutils,uConfig;
procedure init();
procedure Log(txt:string);
var
  tf:TextFile;
implementation
procedure init();
begin
  if not uConfig.isInit then uConfig.init();
  AssignFile(tf,uconfig.logfile);
  if(not fileexists(uconfig.logfile))then
    Rewrite(tF)  //会覆盖已存在的文件
  else
    Append(tF);  //打开准备追加
end;
procedure Log(txt:string);
var
  t:string;
begin
  t:=FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', Now);
  WriteLn(tf,t);
  WriteLn(tf,txt);
  flush(tf);
end;
initialization
  {初始化部分}
  {程序启动时先执行,并顺序执行}
  {一个单元的初始化代码运行之前,就运行了它使用的每一个单元的初始化部分}
   init();
finalization
  {结束化部分,程序结束时执行}
  CloseFile(tF);
end.
