unit wMessagesHook;
/// <summary>
///   FMX: ������ ��������� ��������� ��������� (Windows)
///     ������ - ��������� � ���� ���������� Application ���������� �����������
///    1 - ��� ����� ����������  1 - ��� ���� (��������).
///    ��������� events, �������� ���� ������� �� ��������� � �������� �� ����� (������������ ������ ��� ���)
///   �.�.  ������ Singleton  - �� ������������ ��������� ������� �������� - �����������
/// </summary>
///
interface

uses  WinApi.Windows,WinApi.Messages;

type
    TMessageHook = class abstract(TObject)
      strict private
       class var
        FHook : THandle;
      public
        class procedure  InitMsgHook();
        class destructor Destroy();
        class procedure Clear();
        class property Hook : THandle read FHook;
    end;

 TWinMessageEvent=procedure(var aMess:TMessage; var aCFlag:boolean) of object;
 TAppMsgEvent=procedure(msm:PMsg; var aCFlag:boolean) of object;
/// <summary>
///     ������� ���� - ��������� ������ ��� ��������. ������� ����
/// </summary>
var Active_WinUserMessageEvent:TWinMessageEvent=nil;
///
/// <summary>
///  ������� ������ ���������� � ���� ����
///  (�� ������������� ���� ��������� ���������� ��������!
/// </summary>
var Active_AppMsgEvent:TAppMsgEvent=nil;
///
///  ! �� �������� �� �������� ���� ��� �� Destroy �������� ������� �� Nil !


implementation
uses
 {$IFDEF FMX}
 fmx.Forms, fmx.Platform.Win;
 {$ELSE}
  vcl.Forms;
 {$ENDIF}


    function F_MsgHookProc(nCode : integer; wParam : WParam; lParam : LPARAM):LResult; stdcall;
    var m : PMsg;
        msg : TMessage;
        {$IFDEF FMX}
         cf : TCommonCustomForm;
        {$ELSE}
         cf: TForm;
        {$ENDIF}
         LCFlag,LCWinFlag:Boolean;
      //  cf : TForm;
    begin
      LCWinFlag:=True;
        if nCode = HC_ACTION then begin
             m := PMsg(lParam);
             if Assigned(Active_AppMsgEvent) then
               begin
                 LCFlag:=True;
                 Active_AppMsgEvent(m,LCFlag);
                 if LCFlag=False then Exit;
               end;
             ///
             if (m.message >= WM_USER) and (m.message <= WM_APP) then begin
               {$IFDEF FMX}
                cf := Fmx.Platform.Win.FindWindow(m.hwnd);
               {$ELSE}
                cf:=Application.MainForm;
               {$ENDIF}
                ///
                if assigned(cf) then begin
                    msg.Msg := m.message;
                    msg.WParam := m.wParam;
                    msg.LParam := m.lParam;
                    msg.Result := 0;
                    LCWinFlag:=True;
                    if Assigned(Active_WinUserMessageEvent) then
                       Active_WinUserMessageEvent(msg,LCWinFlag);
                   // if LCWinFlag then
                     try
                        cf.Dispatch(msg);
                      except
                     end;
                end;
             end;
        end;
       if LCWinFlag then
        result := CallNextHookEx(TMessageHook.Hook,
                                 nCode, wParam, lParam);
    end;

class procedure TMessageHook.InitMsgHook();
begin
    FHook := SetWindowsHookEx(WH_GETMESSAGE, F_MsgHookProc, 0, GetCurrentThreadId());
end;

class procedure TMessageHook.Clear();
 begin
   if FHook > 0 then
        UnhookWindowsHookEx(FHook);
 end;

class destructor TMessageHook.Destroy();
begin
    if FHook > 0 then
        UnhookWindowsHookEx(FHook);
end;
end.
