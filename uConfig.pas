unit uConfig;

interface
uses
  Vcl.Forms,System.SysUtils;
const
  WORK_DIR:string='pp'; // 工作目录
  WEB_DIR:string='web'; // 保存网页的子目录名
  WEB_CACHE='cache';
  DATA_DIR:string='data'; // 保存数据的目录
  APP_DIR:string='app'; // app的目录
  XML_FILE:string='config.xml';//xml配置参数文件
  XML_FILE_G:string='configg.xml';//xml配置参数文件
  BAIDU_APP_ID:string='16197183';
  BAIDU_API_KEY:string='5G4tOXwCGG5buEFPrZGGykal';
  BAIDU_SECRET_KEY:string='ceAs9I9xHUzrxs0OWfEBed2HnA4CerLS';
  VER_G:string='vg.dat';
  VER_M:string='vm.dat';
  LOG_NAME:string='ppLog.txt';
  SWF_NAME:ansiString='crypt.swf';        //flash文件
  SOCKET_NAME:ansiString='socket.dat'; //socket数据文件
  FFMPEG_NAME:ansiString='ffmpeg.exe'; //socket数据文件
  MMCFG_NAME:ansiString='mm.cfg'; //log配置文件
var
  workdir,webdir,datadir,appdir:string;// 工作目录,保存网页的子目录
  configFile,configFile2,verg,verm,webCache,socketFile,flashfile,logfile,ffmpegFile,mmcfgFile:string;//xml配置参数文件

  isInit:boolean=false;
  procedure init();
implementation
uses
  uxml;
procedure init();
var
    me:String;
begin
  isInit:=true;
  me:=application.ExeName;
  workdir:=extractfiledir(me)+'\'+WORK_DIR;
  if(not DirectoryExists(workdir))then ForceDirectories(workdir);
  webdir:=workdir+'\'+WEB_DIR;
  if(not DirectoryExists(webdir))then ForceDirectories(webdir);
  webCache:=webdir+'\'+WEB_CACHE;
  if(not directoryexists(webCache))then forcedirectories(webCache);
  datadir:=workdir+'\'+DATA_DIR;
  if(not directoryexists(datadir))then forcedirectories(datadir);
  appdir:=workdir+'\'+APP_DIR;
  if(not directoryexists(appdir))then forcedirectories(appdir);
  configFile:=workdir+'\'+XML_FILE;
  configFile2:=workdir+'\'+XML_FILE_G;
  verg:=workdir+'\'+VER_G;
  verm:=workdir+'\'+VER_M;
  if(not fileexists(configFile))then uxml.createXml;
  logfile:=datadir+'\'+LOG_NAME;
  socketFile:=datadir+'\'+SOCKET_NAME;
  flashfile:= workdir+'\'+SWF_NAME;
  ffmpegFile:=appdir+'\ffmpeg\'+FFMPEG_NAME;
  mmcfgFile:=workdir+'\'+MMCFG_NAME;
end;
begin
  init();
end.
