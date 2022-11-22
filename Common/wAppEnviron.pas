unit wAppEnviron;

///  ����� ���������� ��������� ������ ��������� � ������ ������� �������
///  (����� ������������ ����������� ������� �������� ����������� ����� ����)

interface

uses System.Classes, wAppEnvironClass;

var appEnv:TwAppEnvironment=nil;
    appParams:TwAppEnvironParams;

/// <summary>
///      ����� �� �������� �������� ����������� - ���. �������� ����. ������� � ���� �����������
/// </summary>
procedure appEnvironCreateWithParams;

/// <summary>
///     ��� ����������� ������� ������� � ��������� ��������� � nil
///     (���� ������ ������ ���� ���� ����������� � �������� � ��������)
/// </summary>
procedure appEnvironFree;

 /// <summary>
 ///      ����������� ���. ��������� - ��� ����������� ������
 ///      �������� ����� ������� apCommand='' -��� ����������� - ����� 'log' - ������ �����. ��� ������� ����
 /// </summary>
 procedure appSetPt(const aptName,aValue:string; const apCommand:string='');
 /// <summary>
 ///      ����������� ���. ��������� - ��� ����������� ������
 ///     ������ ����� ������� �� �����
 /// </summary>
 procedure appDeletePt(const aptName:string);
 /// <summary>
 ///      ������� ��� �������� ������ � ������ -������ appSetPt
 /// <param name="aDeleteFlag">
 ///     true - ��� �� ������� ����� (������ ����������� ��������)
 /// </param>
 /// </summary>
 procedure appPt(const aptName,aValue:string; const apCommand:string=''; aDeleteFlag:Boolean=false);
 /// <summary>
 ///    �������� ��������� ����������� �� �������
 ///   (����. ������������� ����������, ���� ����������� ����, �� ���� ����� � �����������)
 /// </summary>
 procedure appTraceState(aNewState:boolean);
 ///
 /// <summary>
 ///    ������ ��������� ��������� ��� madExcept �� ���������� appEnv
 /// </summary>
 procedure appInitDefaultTrace(const addPrx:string='');
 ///
 /// <summary>
 ///     ��� ������� ��� �����������
 /// </summary>
 type
  TTraceExternalLogEvent=procedure(const aCommand,aMsgData:String) of object;
 /// <summary>
 ///     ��������� ��������� �� ��������� �������
 /// </summary>
 procedure appDefineTraceLogEvent(AEvent:TTraceExternalLogEvent);

implementation

{$IFDEF madExcept}
 uses System.SysUtils, u_wMadExcept;
{$ENDIF}

///////////////////////////////////////////////////////////////////////
////
///
procedure appEnvironCreateWithParams;
 begin
  Assert(Assigned(appEnv)=false,'appCreateWithParams - repeat Create Singleton!');
  Assert(appParams.Id<>0,'appCreateWithParams - not fiill appParams - Id=0!');
  appEnv:=TwAppEnvironment.Create(appParams);
  /// a ������ �������!  ���� ���������� ��������� ������� ����� ��������
  appParams:=appEnv.Params; // !
 end;

procedure appEnvironFree;
 begin
  if (Assigned(appEnv)=false) then
      appEnv:=nil
  else
   try
     appEnv.Free;
    finally
     appEnv:=nil;
   end;
 end;


 procedure appSetPt(const aptName,aValue:string; const apCommand:string='');
  begin
    {$IFDEF madExcept}
     { if (Assigned(appEnv)) and (Assigned(wTrace)) and (wTrace.Enabled=true) then
         wTrace.SetPt(aptName,aValue,apLogFlag)
      else
      }
       if Assigned(wTrace) then
          wtrace.SetPt(aptName,aValue,apCommand);
    {$ENDIF}
  end;

 procedure appDeletePt(const aptName:string);
  begin
    {$IFDEF madExcept}
     { if (Assigned(appEnv)) and (Assigned(wTrace)) and (wTrace.Enabled=true) then
         wTrace.DeletePt(aptName)
      else
      }
       if Assigned(wTrace) then
          wtrace.DeletePt(aptName);
    {$ENDIF}
  end;

procedure appPt(const aptName,aValue:string; const apCommand:string=''; aDeleteFlag:Boolean=false);
 begin
   appSetPt(aptName,aValue,apCommand);
   if aDeleteFlag=true then
      appDeletePt(aptName); // � ���� ������ - ����� ������ appSetPt - ������ � �����������, ����� ���������
 end;

 procedure appTraceState(aNewState:boolean);
  begin
    {$IFDEF madExcept}
     { if (Assigned(appEnv)) and (Assigned(wTrace)) then
         wTrace.Enabled:=aNewState
      else
      }
       if Assigned(wTrace) then
          wTrace.Enabled:=aNewState;
    {$ENDIF}
  end;


 procedure appInitDefaultTrace(const addPrx:string='');
  begin
    {$IFDEF madExcept}
      if (Assigned(appEnv)) and (Assigned(wTrace)) then
        begin
          ///
          wTrace.BugReportName:=Concat(addPrx,appEnv.ServiceInfo.appVersionStr,
                         '|',appEnv.ServiceInfo.userName,'|',
                          DateTimeToStr(Now));
          wTrace.SetPt('aAppEnv','initTrace',''); // �������. �����
        end;
    {$ENDIF}
  end;

procedure appDefineTraceLogEvent(AEvent:TTraceExternalLogEvent);
 begin
   {$IFDEF madExcept}
      if (Assigned(wTrace)) then
        begin
           wTrace.OnExternalLogEvent:=AEvent;
        end;
    {$ENDIF}
 end;

initialization

  appEnv:=nil;
  appParams.Id:=0;
  appParams.CaptionLeftPart:='';
  appParams.winSendRStr:='';
  appParams.ApHandle:=0;
  appParams.versionVisPrecision:=3; // !
  appParams.winHomeRVerifyFlag:=False;
  appParams.mpIdentStr:='COMCOMBODEFAULT';
  appParams.CompanyDirectoryPart:='';
  appParams.CompanyName:='';

finalization

// !
  appEnvironFree;

end.
