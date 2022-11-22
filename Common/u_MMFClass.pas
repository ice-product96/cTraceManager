unit u_MMFClass;
/// �������� ����������� ���������� ���������� - ������ Windows!
///  �.�. ����������� MapFile  -- ��������� �������� ������ ������������� �������
///  �� ������ ���������� � ������ � ���� ������ � ������� ��������� (������ Win)
///
interface

uses  Winapi.Windows, Winapi.messages, SysUtils, Classes;


/// <summary>
///    ��������� ��� �������� ������ ����� ����
/// </summary>
const Def_MemFileSize=127;
      Def_MemMessageID=WM_USER+86;

type
 /// <summary>
 ///   ��� ������ ��� �������� ����� mapFile
 /// </summary>
 TMFRecord=record
   AppHandle:NativeUInt;
   sRegime:integer;
   DataStrPtr:array[0..32767] of WideChar;
 end;
 pTMFRecord=^TMFRecord;


 /// <summary>
 ///   ����� �������� � ������������ ���������� (�������� ������ ������ 1 ���.
 ///   � ��������� (���� �����������, ��� ��� ��������) � ������ ������ � �������
 ///     (���. ��������� ����� TMFRecord - ����� MapFile - ������ ������ ��������� 32767)
 /// </summary>
 TMDataHandling=class
  private
   FAppHandle:NativeUInt;
   FinitFlag:Boolean;  // false - ���� ����� �� ������� ������� / �������
   FMemFileSize:Integer;
   FMessageID:Cardinal; //
   FMfilename:string;
   /// <summary>
   ///    ������ ���� ���� ��� ������ ��� �������� ��������� -
   ///    ����� ��� ���� Firemonkey  ����� ��������� ������� FM �.� ���� ����.����� Main (TMain) -> FMTMain
   /// </summary>
   FWNames:TStrings;
   MemHnd: hWnd;
   /// <summary>
   ///       ����� - ��� ����������� - ���. ������ � ���������
   /// </summary>
   FRegime,FRparam:Integer;

   /// <summary>
   ///    ��������� �� �� ������ ��� ��������� ��� �����������
   /// </summary>
   FFirstFlag:Boolean;
  // F_firstBaseRecord:TMFRecord;
  protected
   function FindWindowAndPost(app_Handle:HWND):Boolean;
  public
   LastErrCode:cardinal;
   lpBaseAddress: pTMFRecord;
   ///
   constructor Create(ApHandle:NativeUInt; const mpIdentStr, wndClassNames:string);
   destructor Destroy; override;
   function SendDataStr(const AStr:string):Boolean;
   function GetDataStr:string;  // ��� ����� - ���� ���
  ///
  property InitFlag:boolean read FinitFlag;
  property FirstFlag:boolean read FFirstFlag;
  property AppHandle:NativeUInt read FAppHandle;
  property MessageID:Cardinal read FMessageID;
  property Regime:Integer read FRegime write FRegime;
  property RParam:Integer read FRparam write FRparam;
end;


var  MFHandling:TMDataHandling=nil;


implementation

uses System.StrUtils;

function TMDataHandling.FindWindowAndPost(app_Handle:HWND):Boolean;
var il:integer;
    Lwin: hWnd;
 begin
  Result:=False;
  Lwin:=0;
  il:=0;
  while il<FWNames.Count do
   begin
     if Trim(FWNames.Strings[il])<>'' then
              begin
                Lwin:=FindWindowExW(GetAncestor(app_Handle, GA_PARENT), 0,
                  PChar(Trim(FWNames.Strings[il])),nil);
                if Lwin>0 then
                  Break;
              end;
     Inc(il);
    end;
   if Lwin>0 then
    begin
      PostMessageW(LWin,FMessageID,FRegime,FRparam);
      Result:=True;
    end;
 end;

constructor TMDataHandling.Create(ApHandle:NativeUInt; const mpIdentStr, wndClassNames:string);
  begin
    FRegime:=0;
    FRparam:=0;
    FinitFlag:=False;
    FFirstFlag:=False;
    lpBaseAddress:=nil;
    FMemFileSize:=Def_MemFileSize;
    FMessageID:=Def_MemMessageID;
    //
    FAppHandle:=ApHandle;
    if mpIdentStr<>'' then FMfilename:=Trim(mpIdentStr)
    else
     begin
      FMfilename :=ParamStr(0);
      FMfilename := ReplaceText(FMfilename,'\', '/');
     end;
    ///
    FWNames:=TStringList.Create;
    FWNames.CommaText:=wndClassNames;
       if FWNames.Count<=0 then
          FWNames.Append(wndClassNames);
    ///
    MemHnd := CreateFileMapping(hWnd($FFFFFFFF), nil, PAGE_READWRITE, 0,
    FMemFileSize, PChar(FMfilename));
    LastErrCode:=GetLastError;
    if (LastErrCode=ERROR_FILE_INVALID) or (LastErrCode=ERROR_INVALID_HANDLE) or
        (LastErrCode=ERROR_DISK_FULL) then Exit;
    ///
    if MemHnd=0 then Exit;
    ///
    if (LastErrCode <> ERROR_ALREADY_EXISTS) then
     begin
       FFirstFlag:=True;
       lpBaseAddress :=MapViewOfFile(MemHnd, FILE_MAP_ALL_ACCESS, 0, 0, 0);
       if lpBaseAddress <> nil then
        begin
             lpBaseAddress^.AppHandle:=FAppHandle;
          FinitFlag:=True;
        end;
      end
     else
       begin
          lpBaseAddress := MapViewOfFile(MemHnd, FILE_MAP_ALL_ACCESS, 0, 0, 0);
           if lpBaseAddress <> nil then
            begin
              FinitFlag:=True;
            end;
       end;
   { if lpBaseAddress <> nil then
       UnMapViewOfFile(lpBaseAddress);
       }
  end;

 destructor TMDataHandling.Destroy;
  begin
    if lpBaseAddress <> nil then
       UnMapViewOfFile(lpBaseAddress);
    if MemHnd<>0 then CloseHandle(MemHnd);
    FreeAndNil(FWNames);
    inherited Destroy;
  end;

 function TMDataHandling.SendDataStr(const AStr:string):Boolean;
  begin
    Result:=False;
    if (lpBaseAddress <> nil) and (lpBaseAddress^.AppHandle<>0) then
     begin
      // lpBaseAddress^.DataStr;
       StringToWideChar(AStr,lpBaseAddress^.DataStrPtr,SizeOf(lpBaseAddress^.DataStrPtr));
       Sleep(12);
       Result:=FindWindowAndPost(lpBaseAddress^.AppHandle);
     end;
  end;

 function TMDataHandling.GetDataStr:string;  // ��� ����� - ���� ���
  begin
    Result:='';
    if (lpBaseAddress <> nil) then
     begin
       Result:=WideCharToString(lpBaseAddress^.DataStrPtr);
     end;
  end;

 initialization

 finalization

 if Assigned(MFHandling) then
    FreeAndNil(MFHandling);

end.
