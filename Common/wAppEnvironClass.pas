unit wAppEnvironClass;

interface

uses System.Classes,
     ServiceClasses,
     System.Generics.Collections,
     u_AppLogClass,
 {$IFDEF MSWINDOWS}
   wMessagesHook,
  {$IFDEF FMX}
    FMX.Platform.Win,
  {$ENDIF}
    u_MMFClass,
 {$ENDIF}
 w_iniSettings;

type
 /// <summary>
 ///    ��������� ��� ������������� (������� �����. ������) ���������� ���������� -
 ///             ��������, ID, ����� ���� ���� � ������...
 ///    (���. ��� �������������)
 /// </summary>
 TwAppEnvironParams=record
   Id:Integer; // � ������ �������� InstallTraffic
   guIDStr:string;  /// GUID ������
   ///
   /// <summary>
   ///     ������� �������� ��������� (���� ����) - ���������� ��� Name
   /// </summary>
   ShortName:string;
   /// <summary>
   ///     ������ �������� ��������� - ���� ����� ����� �� ��������...
   ///      ������ ��������� �������� � ���� ������� � ���������
   ///    (��� �� ��� ����������� � InsallTraffi� ��� ��� ��� �������
   /// </summary>
   Name:string;
   ///
   Caption:string;  /// ��������� ����. ����
   /// <summary>
   ///      ��� MMFClass: ����� ����������
   /// </summary>
   /// <summary>
   ///     ��� ��������� ���� - ����� ����� ��������� - �� ������� "-" ��� �������
   /// </summary>
   CaptionLeftPart:string;
   /// <summary>
   ///    �������� ������ ��� ������
   /// </summary>
   versionVisPrecision:integer;
   ///
   ApHandle:NativeUInt;
   /// <summary>
   ///     ��� MMFClass: ���� � ��� ������ ���� ���� FMTMainForm  � ��������� FM
   /// </summary>
   mpIdentStr,wndClassNames:string;
   /// <summary>
   ///     �������� ������ �� ��������� � ����� ��������� (��. Verify...)
   /// </summary>
   winSendRStr:string;
   winSendRegime:Integer; // ��� ������� - ���������...
   /// <summary>
   ///    true - �� ��������� ����� ��� �������� ������ �� ������� ������� �������
   ///    (���������, ����� ��� ��� ��������� ������ ���� Application ��� ��������� handle
   ///  only Windows
   /// </summary>
   winHomeRVerifyFlag:Boolean;
   /// <summary>
   ///    ���� ��������������� ����������� Hook ��� ���������� � ���� - ������ Windows!
   /// </summary>
   winAutoHookFlag:boolean;
   /// <summary>
   ///    ��� ini ����� ��������� (��� ����� �� � �����������) -- ���� ������ - �� <app>.ini
   /// </summary>
   iniFileName:string;
   /// <summary>
   ///    ������� ����� ��� ����������� � ini-����� �������  ��������. ����� �� 4 �� 12
   /// </summary>
   iniCodeKey:string;
   /// <summary>
   ///   ����� - �� ������� �������� �������������� ini-����  1..24 ��� ~~
   /// </summary>
   iniShift:Integer;
   /// <summary>
   ///     ����� MyApp  ��� ���� ���� \software\MyApp\ ��� ������ � �������� - ���. � Updater
   /// </summary>
   runAppName:string;
   ///
   CopyRightStr,PublisherStr:string;
   /// <summary>
   ///     ������ �������� (����� ���.) �������� �������� ��� �������� ����������� � ���������
   /// </summary>
   CompanyDirectoryPart:string;
   /// <summary>
   ///    ��������� - �������� ��������
   /// </summary>
   CompanyName:string;
 end;



 TwAppEnvironment=class(TObject)
  private
   _CreateFlag,_DestroyFlag:Boolean;
   FParams:TwAppEnvironParams;
   FAppPath:string;
   FAppFileName:string;
   FFullAppName:string;
   FUserPath:string;
   FRegime,FAppState:integer;
   FAutoRunFlag:Boolean;
   FTickCount:Cardinal;
   FBugReportCaption:string;
   procedure SetRegime(Value:Integer);
   procedure SetAppState(Value:Integer);
   procedure SetAutoRunFlag(Value:Boolean);
   function GetEnabledMessageHooks:boolean;
   ///
   function GetGlobalDataStr(Index:String):string;
   procedure SetGlobalDataStr(Index,Value:String);
   function GetGlobalDataFlag(Index:String):boolean;
   procedure SetGlobalDataFlag(Index:string; Value:boolean);
   function GetGlobalDataInt(Index:String):Integer;
   procedure SetGlobalDataInt(Index:string; Value:integer);

   procedure SetBugReportCaption(Value:string);
  private
   FStartDT:TDateTime;
  protected
   /// <summary>
  ///    �������� � ����������� ����������� (������)
  ///    (������ ����� ��������� ����� ������� (� ��������� �����), ������� ������������� StringList ������������
  ///    (��. �������� GlobalDataString)
  /// </summary>
   GlobalData:TDictionary<String,String>;
  ///
   /// <summary>
   ///       ������� ������/��������� ���� � ������ ����� - ��������� � AppLogItems
   ///       ���������� ������ �� ���� ��� ����-��, �������� � madExcept ������:
   ///  Arec.LogRegime=0  - ��� ����� ������ ����  =1 - ��� �������� ����������� ������ ����
   ///  ARec.State=0  - ��� �����������  =1 ���������(���������)
   /// </summary>
 //  procedure DoSetLogData(const ARec:TAppLoggingItem);
  /// <summary>
  ///     ������� ���������� JointItem  ��� ��������
  ///     (Joint ������������ � TAppLoggingItems - ��� ��������� ����� ��� ����������� �� �����.)
  /// </summary>
  // procedure DoJointOperation(aOpSign:Integer; const ARec:TJointRecord);
  public
  MadExceptEnabled:Boolean;
  ///
  /// <summary>
  ///   ���������� � ���������� �� � �.�. - �������������.
  /// </summary>
  ServiceInfo:TFMServiceClass;
  ///
  /// <summary>
  ///    ��������� � �������� ������� ��� ����������� - ���� ������ �� ���������
  /// </summary>
  AppLogItems:TAppLoggingItems; // ������ �� ���������� ������ ��� �����������-
 ///   ������ ��������� ����� � ������������
  ///
  {$IFDEF MSWINDOWS}
    /// <summary>
    ///    ������ �� ���������� Message (������ Win)
    /// </summary>
     InstAppMsgr:TMDataHandling; // ������ �� ���������� ����������
  {$ENDIF}
  ///
  /// <summary>
  ///    ������ �� ���������� ������ ������-����������  ini-����� ��� ��������� ��������
  ///    ���� �������� ��� win � ����� ������������
  /// </summary>
  Ini:TwiniSettings;
  /// <summary>
   ///     ���. ������ ������������ � Ini-����� (��� ���������� �������)
   /// </summary>
  iniUserIndex:integer;
   /// <summary>
   ///     ���. ��� ������������ � Ini-����� (���������)
   /// </summary>
   iniUserLogin:string;
   /// <summary>
   ///    id - ���. ������������ ��������� (������ �� ����) - ��� ��������. �������� - ���������.
   /// </summary>
   iniUserId:Cardinal;
  ///
   constructor Create(const App_Params:TwAppEnvironParams);
   destructor Destroy; override;
  ///
  /// <summary>
  ///   ������ - ����������� ��� ���������������� ������ ��� (���� ������� "=" Action - ����� �� ���� LabelDesc-������)
  ///  -------- (��������� ��� ��������� ������)
  /// </summary>
   procedure setLog(const aActionAndLabelDesc:string; aLvl:integer=1; aValue:Double=1);
  ///
   /// <summary>
   ///     ������ - ������ ��������� ��������� ��� �����. �����
   /// </summary>
   procedure SetJoint(const aJntName,aJntdata:string);
   /// <summary>
   ///    ������ - ��������� �������� ����� �����. ����
   /// </summary>
   procedure ClearJoint(const aJntName:string);
  ///
  {$IFDEF MSWINDOWS}
  /// <summary>
  ///     �������� �� ������� ������������ ��������� � Windows -
  /// ���� ����� - �� ������ false   ����� ������� ������ ������� � ��� �������
  /// </summary>
  function VerifyRepetition(const ASendStr:string; sendRegimeSign:Integer=4):Boolean;
  ///
   ///  ������
   /// <summary>
   ///  Windows  -  ��������� (�������) ��������� - hook ��� ���� � ����������
   /// </summary>
    procedure InitMessageHook;
   /// <summary>
    ///    Windows - ������ ����������� �������
    /// </summary>
    procedure ClearMessageHook;
    /// <summary>
    ///    �������� ����:
    /// </summary>
    procedure SetMessEvent(App_Event:TAppMsgEvent; Wind_Event:TWinMessageEvent);
   ///
  {$ELSE}
   ///
   function VerifyRepetition(const ASendStr:string; sendRegimeSign:Integer=4):Boolean;
   procedure InitMessageHook;
   procedure ClearMessageHook;
   ///
  {$ENDIF}
    /// <summary>
    ///    ������ - ������ � iniSettings
    /// <param name="aShortRegime">
    ///   28 - ����� ������������(1C)    26 - ����� ������������ (Roaming)
    ///   35 - ����� ���� ������������� (C:/ProgramData)
    ///   5 - ��� ���������(05)
    ///   46 - ����� ���������(2e)
    ///
    /// </param>
    /// <param name="aCreateFlag">
    ///     ��������� ��� ��� - ���� ���
    /// </param>
    /// </summary>
   class function GetUserSpecPath(const aSubDir:string; aShortRegime:Integer; aCreateFlag:Boolean=true):String;
  /// <summary>
  ///    ������� ������� ��������� (���� ���� ������) � ������������ ���������� ������ wtTRace
  ///    (���� ��� MadExcept - �� ���������� ���������� ��� Application.DoException
  ///  ������:
  ///  {IFDEF ANALYTICS_ACCESS}
  ///    if (Assigned(Ancs)) then
  ///       begin
  ///          Ancs.AbbApplicationInfo:=AGlParams;
  ///          Ancs.RedirectExceptions;
  ///       end;
  //// {ENDIF}
  /// </summary>
  ///  procedure AssignExceptionToAnalytics(const AGlParams:string);
  /// <summary>
  ///     ��������� � ini-���� ������, ���������� � ServiceInfo � �������� ������
  /// </summary>
  procedure SaveServiceInfoToIni(aSaveRegime:Integer=1);
  ///
  /// <summary>
  ///    �������� ����� ������� � ������� ������
  /// </summary>
  procedure SetTime;
  /// <summary>
  ///     ������� ������� �� �������� (�������) ��� �� ���������� ������� � ��������� SetTime;
  /// </summary>
  function GetDeltaTime:TDateTime;
  ///
  ///
  /// <summary>
  ///      ������ - ������� event � ���������
  ///  ������:
  ///   procedure TwAppEnvironment.SendTrackEvent(const ACategory,aAction,aLabel:string; aValue:single; ARegime:integer=0);
  /// begin
  ///   {IFDEF ANALYTICS_ACCESS}
  ///      if Assigned(Ancs) then
  ///        Ancs.TrackEvent(ACategory,aAction,aLabel,aValue,ARegime);
  ///   {ENDIF}
  /// end;
  /// </summary>
  ///  procedure SendTrackEvent(const ACategory,aAction,aLabel:string; aValue:single; ARegime:integer=0);
  ///
  property Params:TwAppEnvironParams read FParams;
  ///
  /// <summary>
  ///    ����� �������� ������ � ��������� - ��������� ��� ������� ����� � ���������
  /// </summary>
  property StartDateTime:TDateTime read FStartDT;
  /// <summary>
  ///   ���� � ��������� - (��� Android ���� � DocumentPath �����
  /// </summary>
  property AppPath:string read FAppPath;
  /// <summary>
  ///     ��� ����� ���������� ��� ���� � ��� ���������� �����
  /// </summary>
  property AppFileName:string read FAppFileName;
  /// <summary>
  ///     ���� � ��� ��������� - ������ (������� ������������ �� � Win)
  /// </summary>
  property FullAppName:string read FFullAppName;
  /// <summary>
  ///    ���� ��� �������� ������������ (������ Roaming ��� ���������)
  /// </summary>
  property UserPath:string read FUserPath;
  property Regime:integer read FRegime write SetRegime;
  /// <summary>
  ///    �������. �������������� ���� -- ��������� ���������� (����� ���. � �����������)
  /// </summary>
  property AppState:integer read FAppState write SetAppState;
  property AutoRunFlag:Boolean read FAutoRunFlag write SetAutoRunFlag;
  /// <summary>
  ///    ��������� - ���� �� ��������� ��������� �����
  /// </summary>
  property EnabledMessageHooks:boolean read GetEnabledMessageHooks;
  /// <summary>
  ///    �������� - ��� ��������������� ���������� ��� ����������� �������� �� ����� ������
  ///    (������ ������ ����� - ���������� �������� � ���� - ����� ����� ���� �������������)
  /// </summary>
  property globalDataString[Index:string]:string read GetGlobalDataStr write SetGlobalDataStr;
  /// <summary>
  ///    ��. globalDataString - ����. �������  �����
  /// </summary>
  property globalDataFlag[Index:string]:Boolean read GetGlobalDataFlag write SetGlobalDataFlag;
    /// <summary>
  ///    ��. globalDataString - ����. �������  �����
  /// </summary>
  property globalDataInt[Index:string]:integer read GetGlobalDataInt write SetGlobalDataInt;
  /// <summary>
  ///     �������� ������ ��� TRace - ������ - ��������� ��� ��� bugReport
  /// </summary>
  property BugReportCaption:string read FBugReportCaption write SetBugReportCaption;
 end;


implementation

 uses
  {$IFNDEF FMX}
    Vcl.Forms,
  {$ENDIF}
   System.SysUtils;

 procedure TwAppEnvironment.SetRegime(Value:Integer);
  begin
   if Value<>FRegime then
    begin
     FRegime:=Value;
     SetJoint('rg',IntToStr(FRegime));
    end;
  end;

procedure TwAppEnvironment.SetAppState(Value: Integer);
begin
    if Value<>FAppState then
    begin
     FAppState:=Value;
     SetJoint('appState',IntToStr(FAppState));
    end;
end;

procedure TwAppEnvironment.SetAutoRunFlag(Value:Boolean);
  begin
   if Value<>FAutoRunFlag then
     FAutoRunFlag:=Value;
   if FAutoRunFlag then SetJoint('Auto','1')
   else SetJoint('Auto','0');
  end;

 function TwAppEnvironment.GetEnabledMessageHooks:boolean;
  begin
    ///
    Result:=false;
    {$IFDEF MSWINDOWS}
      Result:=(TMessageHook.Hook>0);
    {$ENDIF}
  end;

  function TwAppEnvironment.GetGlobalDataFlag(Index: String): boolean;
  var LV:string;
begin
 Result:=False;
 if Index='' then exit;
 GlobalData.TryGetValue(Index,LV);
 result:=(UpperCase(LV)='TRUE') or (LV='1');
end;

function TwAppEnvironment.GetGlobalDataInt(Index: String): Integer;
  var LV:string;
begin
 Result:=-1;
 if Index='' then exit;
 GlobalData.TryGetValue(Index,LV);
 TryStrToInt(LV,Result);
end;

function TwAppEnvironment.GetGlobalDataStr(Index:String):string;
   begin
    Result:='';
    if Index='' then exit;
    GlobalData.TryGetValue(Index,Result);
   end;

  class function TwAppEnvironment.GetUserSpecPath(const aSubDir: string;
  aShortRegime: Integer; aCreateFlag: Boolean): String;
  var LSubDir:string;
begin
  LSubDir:=IncludeTrailingPathDelimiter(aSubDir);
  Result:=GetAppUserLocalDataPath(LSubDir,aShortRegime,aCreateFlag);
end;

procedure TwAppEnvironment.SetGlobalDataFlag(Index:string; Value: boolean);
begin
  if Index='' then exit;
  GlobalData.AddOrSetValue(Index,BoolToStr(Value,True));
end;

procedure TwAppEnvironment.SetGlobalDataInt(Index: string; Value: integer);
begin
  if Index='' then exit;
  GlobalData.AddOrSetValue(Index,IntToStr(Value));
end;

procedure TwAppEnvironment.SetGlobalDataStr(Index,Value:String);
   begin
     if Index='' then exit;
     GlobalData.AddOrSetValue(Index,Value);
   end;

 procedure TwAppEnvironment.SetBugReportCaption(Value:string);
  begin
    FBugReportCaption:=Value;
  end;



 constructor TwAppEnvironment.Create(const App_Params:TwAppEnvironParams);
 var i,j:Integer;
  begin
   if _CreateFlag then Exit;
   inherited Create;
   _CreateFlag:=True;
   _DestroyFlag:=False;
   ///
   FStartDT:=Now;
   ///
   GlobalData:=TDictionary<String,String>.Create;
   iniUserIndex:=0;
   iniUserLogin:='';
   iniUserId:=0;
   ///
   FTickCount:=TThread.GetTickCount;
   ///
    Assert((App_Params.Id>0),'TwAppEnvironment.Create - not define AppParams fields!');
    inherited Create;
    FParams:=App_Params;
    if (FParams.Name='') then
       FParams.Name:=FParams.ShortName;
    ///
    if FParams.iniFileName='' then
       FParams.iniFileName:=Concat(GetAppOnlyFileName,'.ini');
    if FParams.iniCodeKey='' then
       FParams.iniCodeKey:=Concat('M','1','18','5');
    if (FParams.iniShift<1) or (FParams.iniShift>99) then
        FParams.iniShift:=5;
    if FParams.winSendRegime<=0 then FParams.winSendRegime:=4;
    FAppPath:=ExtractFilePath(ParamStr(0));
    ///
    /// ������� �������� ��� � - ���� ��������� MadExcept - �� �������� ��� ����
    AppLogCreate('DefD');
    AppLogItems:=AppLog;
    AppLogItems.OnSetData:=nil;
   // AppLogItems.OnSetData:=DoSetLogData;
    AppLogItems.OnSetJoint:=nil;
    ///
    MadExceptEnabled:=False;
    ///  ������� � ��������� ���� -- ������ App, OS � ������...
    ServiceInfo:=TFMServiceClass.Create;
    /// �������� ������ ����� ��������� - ���� ��� ������ �������
    if FParams.CaptionLeftPart='' then
       begin
         i:=Pos(' - ',FParams.Caption);
         if i<=0 then FParams.CaptionLeftPart:=FParams.Caption
         else
             FParams.CaptionLeftPart:=Copy(FParams.Caption,1,i);
         // ������� ����� ������
         if ServiceInfo.appVersionStr<>'' then
          begin
           //FParams.CaptionLeftPart:=Concat(FParams.CaptionLeftPart,' (v.',ServiceInfo.appVersionStr,')');
         { FParams.CaptionLeftPart:=Concat(FParams.CaptionLeftPart,' ',
              ServiceInfo.GetAppVersionString(FParams.versionVisPrecision));
              }
          end;
       end;
    ///
    ///  �������� ���� ��� ����� ������ �� ���������� �� ������ � OS ����������
    AppLogItems.DescInformation:=ServiceInfo.appVersionAbb+','+ServiceInfo.DevInfoDesc;
    ///
    ///  ��������� - ���������. ����������� (������� 2 ���������� TAppAnalytics ��� ������)
   // Ancs:=TwAnalytics.Create(nil);
   // Ancs.LogItems:=AppLogItems; // ! �������� ����� � ��������� - �.�. �������� ����� ���������
    ///
    /// �������� Instance
    {$IFDEF MSWINDOWS}
      if FParams.winHomeRVerifyFlag=true then
       begin
         // ������ �������� � ����. ����������� �������
         // -->  InstAppMsgr:=MFHandling;
         VerifyRepetition(FParams.winSendRStr,FParams.winSendRegime);
       end;
     /// ��������� ���� - ���� ����� �������� ��� ���
     InstAppMsgr:=nil;
     if FParams.winAutoHookFlag then
       begin
           InitMessageHook;
       end;
    {$ENDIF}
    ///
    if Assigned(iniSettings)=false then
       iniSettings:=TwIniSettings.Create;
    Self.Ini:=iniSettings; // !
    // ����� ������� ����������� ���� ��� ����� �������� � �.�.  - �� ������ w_iniSettings
    FappFileName:=GetAppOnlyFileName;
    /// �������, �� ParamStr(0) ���-�� �������� � � �������� ����...  %
    FFullAppName:=ParamStr(0);
    ///
    /// ���� ��� �������� � ����� ����� - ������� ��� �� ����� ���������
    CreateAppUserPath(FAppFileName);
    /// ��������� ���� �� ������� � ����������� � ������
    FUserPath:=GetAppUserPath(FAppFileName);
    ///
    ///

    ///  ��������� ��������� ��� Trace -- ��� ������ ��� ��������
   // Trace.BugReportName:=Concat(ServiceInfo.appVersionStr,'|',ServiceInfo.userName,'|',
   //                      DateTimeToStr(Now));
   // Trace.SetPt('aAppEnv','initTrace',False); // �������. �����
    /// ������ ��������� ��� ����� ��������
    iniSettings.SetParams(FUserPath+FParams.iniFileName,FParams.iniCodeKey,FParams.iniShift);
    ///
    FRegime:=0;
    {$IFDEF MSWINDOWS}
        try
        if (ParamCount >= 1) and (ParamStr(1)<>'') then
         begin
          i:=Pos('UNINSTALL',Uppercase(ParamStr(1)));
          j:=Pos('INSTALL',Uppercase(ParamStr(1)));
          if ((i=1) or (i=2)) and (Pos('.',ParamStr(1))<=0) then FRegime:=-1
          else
            if ((j=1) or (j=2)) and (Pos('.',ParamStr(1))<=0) then FRegime:=1
            else FRegime:=0;
        end;
       except
       end;
    {$ENDIF}
    ///
  end;

 destructor TwAppEnvironment.Destroy;
  begin
    if _DestroyFlag=true then Exit;
    _DestroyFlag:=True;
     if Assigned(Self.Ini) then
      begin
        if Self.Ini=iniSettings then iniSettings:=nil;
        Self.Ini.Free;
      end;
    {$IFDEF MSWINDOWS}
        ClearMessageHook;
     ///
     if Assigned(InstAppMsgr) then
                   begin
                     if InstAppMsgr=MFHandling then MFHandling:=nil;
                     InstAppMsgr.Free;
                   end;
    {$ENDIF}
    ///
     GlobalData.Free;
    ///
    if Assigned(AppLogItems) then
       AppLogFree;
    AppLogItems:=nil;
    if Assigned(ServiceInfo) then ServiceInfo.Free;
    ///
    inherited Destroy;
  end;

  procedure TwAppEnvironment.setLog(const aActionAndLabelDesc:string; aLvl:integer=1; aValue:Double=1);
  var j,k:integer;
      LAction,Ldesc:string;
   begin
      if Assigned(AppLogItems) then
       begin
         k:=Length(aActionAndLabelDesc);
         j:=Pos('=',aActionAndLabelDesc);
         LAction:='LA';
         Ldesc:=aActionAndLabelDesc;
         if (j>0) and (j<k-1) then
          begin
            LAction:=Copy(aActionAndLabelDesc,1,j);
            Ldesc:=Copy(aActionAndLabelDesc,j+1,k-j-1);
          end;
         j:=AppLogItems.PDataEx('Logs',LAction,Ldesc,aLvl,aValue);
         if j<0 then
          begin
            /// �� ���������� � ���
          end;
       end;
   end;

   procedure TwAppEnvironment.SetJoint(const aJntName,aJntdata:string);
    begin
      if Assigned(AppLogItems) then
         AppLogItems.Joint[aJntName]:=aJntdata;
    end;

   procedure TwAppEnvironment.ClearJoint(const aJntName:string);
     begin
        if Assigned(AppLogItems) then
         AppLogItems.DeleteJoint(aJntName);
     end;


 {$IFDEF MSWINDOWS}
 function TwAppEnvironment.VerifyRepetition(const ASendStr:string; sendRegimeSign:Integer=4):Boolean;
 var LSendStr:string;
  begin
    Result:=False;
    Assert(not(Assigned(MFHandling)),'TwAppEnvironment.VerifyRepetition - MFHandling is Assigned - not correct!');
    if FParams.ApHandle=0 then
      begin
       {$IFDEF FMX}
        FParams.ApHandle:=FMX.Platform.Win.ApplicationHWND;
       {$ELSE}
         FParams.ApHandle:=Application.Handle;
       {$ENDIF}
      end;
    Assert(FParams.ApHandle<>0,'TwAppEnvironment.VerifyRepetition: not Define Params.ApHandle=0!');
    LSendStr:=ASendStr;
    if LSendStr='' then
       LSendStr:=FParams.winSendRStr;
    ///
    MFHandling:=TMDataHandling.Create(FParams.ApHandle,FParams.mpIdentStr,
                                         FParams.wndClassNames);
    InstAppMsgr:=MFHandling;
    Result:=MFHandling.FirstFlag;
    if (Result=false) and (LSendStr<>'') then /// ������ ��� ������ ������ - ���
     begin
        MFHandling.lpBaseAddress^.sRegime:=sendRegimeSign;
        InstAppMsgr.SendDataStr(ASendStr);
     end;
    ///
  end;

   procedure TwAppEnvironment.InitMessageHook;
    begin
         TMessageHook.InitMsgHook;
    end;

   procedure TwAppEnvironment.ClearMessageHook;
    begin
         TMessageHook.Clear;
    end;

   procedure TwAppEnvironment.SetMessEvent(App_Event:TAppMsgEvent; Wind_Event:TWinMessageEvent);
    begin
      if @Wind_Event<>nil then
         Active_WinUserMessageEvent:=Wind_Event;
      if @App_Event<>nil then
         Active_AppMsgEvent:=App_Event;
    end;


 {$ELSE}
 function TwAppEnvironment.VerifyRepetition(const ASendStr:string; sendRegimeSign:Integer=4):Boolean;
  begin
   Result:=true;
  end;

 procedure TwAppEnvironment.InitMessageHook;
  begin
   //
  end;
 ///
 procedure TwAppEnvironment.ClearMessageHook;
  begin
   //
  end;
 {$ENDIF}

 procedure TwAppEnvironment.SaveServiceInfoToIni(aSaveRegime:Integer=1);
 const L_sect='Info';
  begin
    if Assigned(ServiceInfo)=false then Exit;
    if Assigned(Ini) then
     try
      Ini.WriteString(L_sect,'USER',ServiceInfo.UserName);
      Ini.WriteString(L_sect,'USER_CAT',ServiceInfo.UserCategoryAbb);
      Ini.WriteInteger(L_sect,'USER',ServiceInfo.UserCatType);
      except
     end;
  end;

procedure TwAppEnvironment.SetTime;
 begin
   FTickCount:=TThread.GetTickCount;
 end;

function TwAppEnvironment.GetDeltaTime:TDateTime;
var LCount:Cardinal;
 begin
   LCount:=TThread.GetTickCount;
   Result:=(LCount-FTickCount)/MSecsPerSec/SecsPerDay;
 end;

end.
