unit u_wCodeTrace;
///
///  Обновленный вариант модуля от 2022 года - добавлена возможность выбора порта для логирования
///

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, idUdpClient, IdGlobal, IdException;

type
  TCodeTraceItem = class(TPersistent)
  public
  /// <summary>
  ///      имя команды
  /// </summary>
    CommandName: string;
  /// <summary>
  ///     режим отработки
  /// </summary>
    CommandRegime: Integer;
    MessData: string;
    DTime: TDatetime;
    TraceID: string;
  public
    class function GetCommandRegime(const aComName: string): integer;
    class function GetCommandName(aComRegime: integer): string;
    function GetCommandParams(const aParamsIdent: string = 'DATA'): string;
    function ExtractDataFromString(const aDataStr: string): boolean;
    /// <summary>
    ///    получить описание в виде строки для отчета
    /// </summary>
    function DataToString(agetDataRegime: integer = 1): string;
    procedure Assign(Source: TPersistent); override;
    constructor Create(const aCommand, aMsgData: string; aTraceID: string = '');
    constructor CreateFromString(const aData: string);
    /// <summary>
    ///     создание с помощью копии
    /// </summary>
    constructor CreateFrom(const aSource: TCodeTraceItem);
    function IsEmpty: boolean;
  end;
//////////////////////////////////////
///
///  with Indy
///

  TUdpCodeTraceSocket = class(TObject)
  private
    FLastErrorStr: string;
    FUdpRegime: integer;
    FUdpClient: TIdUdpClient;
  public
    constructor Create(udp_Regime: integer; aOpenFlag: Boolean = true);
    destructor Destroy; override;
    function SendString(const AStr: string): boolean;
    procedure setUdpClient(const aHost: string; aport: Integer);
    property UdpClient: TIdUdpClient read FUdpClient;
  end;

///////////////////////////////////////
/// <summary>
///    Управление логированием - центральный синглтон
/// </summary>
  TCodeTraceManager = class(TObject)
  private
    F_ItemTickCount: Cardinal;
    FItemsEnabled: boolean;
    FSignsEnabled: Boolean;
    FMaxItemsCount: integer;
    FSocket: TUDpCodeTraceSocket;
   /// <summary>
   ///    список всех логов - объекты
   /// </summary>
    FItems: TObjectList<TCodeTraceItem>;
   /// <summary>
   ///    условия логирования - набор
   /// </summary>
    FSigns: TDictionary<string, Boolean>;
    FEnabled: boolean;
    FTraceId: string;
    procedure SetItemsEnabled(Value: boolean);
  public
    property Socket: TUDpCodeTraceSocket read FSocket;
    property Items: TObjectList<TCodeTraceItem> read FItems;
    property Signs: TDictionary<string, Boolean> read FSigns;
  public
    procedure ResetSocket(const aNewHost: string; aNewPort: Integer);
    procedure SendCommand(const aCommand, aMsgData: string; aTraceID: string = '');
    procedure SendSignCommand(const aSignNames, aCommand, aMsgData: string);
   /// <summary>
   ///
   /// </summary>
    constructor Create(aTrRegime: integer);
    destructor Destroy; override;
    property Enabled: boolean read FEnabled write FEnabled;
    property SignsEnabled: boolean read FSignsEnabled write FSignsEnabled;
    property ItemsEnabled: boolean read FItemsEnabled write SetItemsEnabled;
    property ItemsMaxCount: integer read FMaxItemsCount write FMaxItemsCount;
    property TraceId: string read FTraceId write FTraceId;
  end;

 /// <summary>
 ///     заполнить список из предустановленных команд - сервис
 ///     (вернет кол-во команд)
 /// </summary>
function ct_FillCommandsList(aRegime: integer; const aItems: TStrings): integer;


{$IFNDEF LINK_PRO}
 /// логирование  -- Синглтон ---
var
  wCode: TCodeTraceManager = nil;
   /// <summary>
  /// логировать с командами вида enter exit mote warn err
  /// </summary>

procedure wLog(const aCommand, aMsgData: string; const aSignNames: string = '');
/// <summary>
/// логировать исключительную ситуацию
/// </summary>

procedure wLogE(const aPlaceStr: string; aE: Exception);
{$ENDIF}


///////////////////////
///
///  логирование:
// wCode.Enabled := Environ.globalDataFlag['W_DEBUG'];
///
///  пример вызова:
///  wLog('app','Home');
///  wLog('quit','exit_RUN_App');
///
///   wLog('>','MainFrm_Do_BeforeLostConnection');
///    вход-выход процедуры-метода
///    wLog('n','MainFrm_Do_BeforeLostConnection_SET_DISABLED');
///    wLog('+','post_mpSgtin');
///    wLog('i','post_mpSgtin');
///    wLog('i','KKK='+IntToStr(KKK));
///   wLog('<','MainFrm_Do_BeforeLostConnection');
///

implementation

uses
  System.Variants, DateUtils;

{ TCodeTraceItem }

const
  wct_Commands =
    'user:,enter:,exit:,warn:,err:,note:,req:,info:,exclam:,opt:,app:,next:,prev:,clear:,minus:,plus:,quit:,traceid:';

function ct_FillCommandsList(aRegime: integer; const aItems: TStrings): integer;
begin
  Result := -1;
  if Assigned(aItems) = false then
    exit;
  if aRegime in [0, 1] then
    aItems.CommaText := wct_Commands;
  Result := aItems.Count;
end;

procedure TCodeTraceItem.Assign(Source: TPersistent);
var
  LSrc: TCodeTraceItem;
begin
  if (Assigned(Source) = false) and (Source is TCodeTraceItem = false) then
    exit;
  LSrc := TCodeTraceItem(Source);
  CommandName := LSrc.CommandName;
  CommandRegime := LSrc.CommandRegime;
  MessData := LSrc.MessData;
  DTime := LSrc.DTime;
end;

constructor TCodeTraceItem.Create(const aCommand, aMsgData: string; aTraceID: string);
begin
  inherited Create;
  CommandRegime := TCodeTraceItem.GetCommandRegime(aCommand);
  CommandName := TCodeTraceItem.GetCommandName(CommandRegime);
  MessData := Trim(aMsgData);
  TraceID := aTraceID;
  DTime := Now;
end;

constructor TCodeTraceItem.CreateFrom(const aSource: TCodeTraceItem);
begin
  inherited Create;
  CommandRegime := -1;
  CommandName := 'empty:';
  DTime := Now;
  MessData := '';
  Assign(aSource);
end;

function TCodeTraceItem.IsEmpty: boolean;
begin
  Result := (CommandRegime = -1) or (CommandName = '') or ((CommandName =
    'empty:') and (MessData = ''));
end;

constructor TCodeTraceItem.CreateFromString(const aData: string);
begin
  inherited Create;
  ExtractDataFromString(aData);
  DTime := Now;
end;

function TCodeTraceItem.DataToString(agetDataRegime: integer): string;
begin
  FormatSettings.LongTimeFormat := 'hh:nn:ss.zzz';
  case agetDataRegime of
    1:
      Result := Concat(CommandName, ' ', MessData, ' TIME=', TimeToStr(DTime,
        FormatSettings));
    2:
      Result := Concat(CommandName, '=', MessData);
  else
    Result := CommandName;
  end;
end;

function TCodeTraceItem.ExtractDataFromString(const aDataStr: string): boolean;
var
  LCom, LDs, LS, LId: string;
  i: integer;
begin
  LDs := '';
  LId := '';
  i := Pos(':', aDataStr);
  if (i > 1) then
  begin
    LCom := Copy(aDataStr, 1, i);
    if i < Length(aDataStr) then
      LDs := Copy(aDataStr, i + 1, Length(aDataStr) - i);
  end
  else
  begin
    LCom := 'user:';
    LDs := aDataStr;
  end;
  i := pos('-!', aDataStr);
  if i > 1 then
  begin
    LId := Copy(aDataStr, i + 2, Length(aDataStr) - i);
    TraceID := LId;
  end;

  CommandRegime := TCodeTraceItem.GetCommandRegime(LCom);
  CommandName := TCodeTraceItem.GetCommandName(CommandRegime);
  i := Pos(' TIME=', LDs);
  if (i > 0) and (i < Length(LDs) - 6) then
  begin
    LS := Copy(LDs, i + 6, Length(LDs) - 6 - i);
    LDs := Trim(Copy(LDs, 1, i));
    TryStrToDateTime(LS, DTime);
  end;
  MessData := LDs;
end;

class function TCodeTraceItem.GetCommandName(aComRegime: integer): string;
var
  LList: TStrings;
begin
  Result := '';
  LList := TStringList.Create;
  try
    LList.CommaText := wct_Commands;
    if (aComRegime >= 0) and (aComRegime < LList.Count) then
      Result := LList.Strings[aComRegime];
  finally
    LList.Free;
  end;
end;

function TCodeTraceItem.GetCommandParams(const aParamsIdent: string = 'DATA'): string;
var
  i, j, LL, iL: integer;
  LIdentStr: string;
begin
  Result := '';
  j := 0;
  LIdentStr := Concat(aParamsIdent, '=[');
  LL := Length(LIdentStr);
  i := Pos(LIdentStr, MessData);
  if i > 0 then
  begin
    iL := Length(MessData);
    while iL > i + LL do
    begin
      if MessData[iL] = ']' then
      begin
        j := iL;
        break;
      end;
      Dec(iL);
    end;
  end;
  if (i > 0) and (j > i + LL) then
    Result := Copy(MessData, i + LL, j - i - LL);
end;

class function TCodeTraceItem.GetCommandRegime(const aComName: string): integer;
var
  LCommand: string;
  LChar: Char;
  LList: TStrings;
  i: integer;
begin
  Result := -1;
  LCommand := Trim(lowerCase(aComName));
  if LCommand = '' then
    exit;
  /// нач. замена
  LChar := LCommand[1];
  if Length(LCommand) = 1 then
    case LChar of
      'e':
        LCommand := 'err';
      'w':
        LCommand := 'warn';
      '!':
        LCommand := 'exclam';
      'i':
        LCommand := 'info';
      'c', 'a':
        LCommand := 'app';
      '>':
        LCommand := 'enter';
      '<':
        LCommand := 'exit';
      '?', 'r':
        LCommand := 'req';
      'l', 'n':
        LCommand := 'note';
      '+':
        LCommand := 'plus';
      '-':
        LCommand := 'minus';
      'o':
        LCommand := 'opt';
      '.', ',':
        LCommand := 'user';
      'q':
        LCommand := 'quit';
      't':
        LCommand := 'traceid';
    end;
  /// синонимы
  if (Pos('error', LCommand) = 1) then
    LCommand := 'err'
  else if (Pos('warning', LCommand) = 1) then
    LCommand := 'warn'
  else if (Pos('exc', LCommand) = 1) then
    LCommand := 'exclam'
  else if (Pos('command', LCommand) = 1) then
    LCommand := 'app';
  //
  if LCommand[Length(LCommand)] <> ':' then
    LCommand := Concat(LCommand, ':');
  ///
  LList := TStringList.Create;
  try
    LList.CommaText := wct_Commands;
    i := 0;
    while i < LList.Count do
    begin
      if POs(LList.Strings[i], LCommand) = 1 then
      begin
        Result := i;
        break;
      end;
      Inc(i);
    end;
  finally
    LList.Free;
  end;
end;



{ TCodeTraceManager }

constructor TCodeTraceManager.Create(aTrRegime: integer);
begin
  inherited Create;
  FEnabled := true;
  FMaxItemsCount := 0;
  FSignsEnabled := False;
  if aTrRegime = 1 then
    FItemsEnabled := true
  else
    FItemsEnabled := False;
  FItems := TObjectList<TCodeTraceItem>.Create(true);
  FSigns := TDictionary<string, Boolean>.Create;
  FSocket := TUdpCodeTraceSocket.Create(0);
  F_ItemTickCount := TThread.GetTickCount;
end;

destructor TCodeTraceManager.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  FSocket.Free;
  FSigns.Free;
  inherited;
end;

procedure TCodeTraceManager.ResetSocket(const aNewHost: string; aNewPort: Integer);
var
  L_port: integer;
begin
  FSocket.Free;
  FSocket := TUdpCodeTraceSocket.Create(0, False);
  FSocket.setUdpClient(aNewHost, aNewPort);
  L_port := FSocket.UdpClient.Port;
  L_port := L_port;
end;

procedure TCodeTraceManager.SendCommand(const aCommand, aMsgData: string;
  aTraceID: string);
var
  LItem: TCodeTraceItem;
  LCommand, LMsgData, L_err: string;
  LCa: Double;
  LProfFlag: boolean;
   // LS:string;
begin
  if FEnabled = false then
    exit;
  L_err := '';

  LCommand := Trim(aCommand);
  LMsgData := aMsgData;
 /// работа с профайлером - найти разницу между пред. вызовом
  LProfFlag := (Pos('*PROF', LMsgData) > 0);
  if LProfFlag then
  begin
    LCa := 0.001 * (TThread.GetTickCount - F_ItemTickCount);
    LMsgData := StringReplace(aMsgData, '*PROF', 'DELTA=' + FloatToStr(LCa), []);
    F_ItemTickCount := TThread.GetTickCount;
  end
  else
  begin
    if Pos('*STOP', LMsgData) > 0 then
    begin
      LCa := 0.001 * (TThread.GetTickCount - F_ItemTickCount);
      LMsgData := StringReplace(aMsgData, '*STOP', 'DELTA=' + FloatToStr(LCa), []);
    end;
    if Pos('*START', LMsgData) > 0 then
    begin
      LMsgData := StringReplace(aMsgData, '*START', '', []);
      F_ItemTickCount := TThread.GetTickCount;
    end;
  end;
 ///
  LItem := TCodeTraceItem.Create(LCommand, LMsgData, aTraceID);
  try
    if LItem.CommandName = '' then
    begin
    // для неописанных команд (или некорректных)
      LItem.CommandName := 'user:';
      LItem.MessData := Concat('(', LCommand, ')> ', LItem.MessData);
    end;
    if FItemsEnabled then
    try
      FItems.Add(LItem);
      if (FMaxItemsCount > 0) and (FItems.Count > FMaxItemsCount) then
        FItems.Delete(0); // !
    except
      on E: Exception do
        L_err := E.ClassName + ' : ' + E.Message;
    end;
   // send
    if FSocket.FUdpClient.Connected = false then
      FSocket.FUdpClient.Connect;
  ///  в сокет идут уже команды со скорректированным именем и данными
    if FSocket.FUdpClient.Connected = true then
    begin
      FSocket.SendString(LItem.DataToString(1));
     { LS:=Wide(LItem.MessData);
      Socket.SendString(Concat(LItem.CommandName,LS));
      }
    end;
   ///
  finally
    if FItemsEnabled = false then
      LItem.Free;
  end;
end;

procedure TCodeTraceManager.SendSignCommand(const aSignNames, aCommand, aMsgData: string);
var
  LFindSignFlag: Boolean;
  LLIst: TStringList;
  i: integer;
  LS: string;
begin
  if FSignsEnabled = false then
    SendCommand(aCommand, aMsgData, TraceId)
  else
  begin
    LFindSignFlag := false;
    LLIst := TStringList.Create;
    try
      LLIst.CommaText := aSignNames;
      i := 0;
      while i < LLIst.Count do
      begin
        LS := Trim(lowerCase(LLIst.Strings[i]));
        if (LS <> '') and (FSigns.ContainsKey(LS)) and (FSigns.Items[LS] = true) then
        begin
          LFindSignFlag := true;
          break;
        end;
        Inc(i);
      end;
      ///
    finally
      LLIst.Free;
    end;
    ///
    if LFindSignFlag then
      SendCommand(aCommand, aMsgData, TraceId);
  end;
end;

procedure TCodeTraceManager.SetItemsEnabled(Value: boolean);
begin
  if Value = false then
    FItems.Clear;
  FItemsEnabled := Value;
end;

{ TUdpCodeTraceSocket }

constructor TUdpCodeTraceSocket.Create(udp_Regime: integer; aOpenFlag: Boolean = true);
begin
  inherited Create;
  FUdpRegime := udp_Regime;
  FUdpClient := TIdUdpClient.Create(nil);
  FUdpClient.Port := 25678;
  FUdpClient.Host := '127.0.0.1';
  FUdpClient.Host := 'localhost';
  if aOpenFlag then
    FUdpClient.Active := true;
 // FUdpClient.ReceiveTimeout:=5000;
end;

destructor TUdpCodeTraceSocket.Destroy;
begin
  FUdpClient.Disconnect;
  FreeAndNil(FUdpClient);
  inherited;
end;

procedure TUdpCodeTraceSocket.setUdpClient(const aHost: string; aport: Integer);
begin
  if Assigned(FUdpClient) then
  begin
    FUdpClient.Disconnect;
    FreeAndNil(FUdpClient);
  end;
  FUdpClient := TIdUdpClient.Create(nil);
  if aport > 0 then
    FUdpClient.Port := aport
  else
    FUdpClient.Port := 25678;
  if aHost <> '' then
    FUdpClient.Host := aHost
  else
    FUdpClient.Host := 'localhost';
  FUdpClient.Active := true;
end;

function TUdpCodeTraceSocket.SendString(const AStr: string): boolean;
begin
  Result := false;
  try
    FUdpClient.Send(AStr, IndyTextEncoding(encUTF8));
    Result := true;
  except
         // may generate EIdPackageSizeTooBig exception if the message is too long
    on e: EIdPackageSizeTooBig do
    begin
      FLastErrorStr := e.Message;
    end;
  end;
end;

{$IFNDEF LINK_PRO}
/// логирование
procedure wLog(const aCommand, aMsgData: string; const aSignNames: string = '');
begin
  if Assigned(wCode) then
    if aSignNames = '' then
      wCode.SendCommand(aCommand, aMsgData, wcode.TraceId)
    else
      wCode.SendSignCommand(aCommand, aMsgData, aSignNames);
end;

procedure wLogE(const aPlaceStr: string; aE: Exception);
begin
  if Assigned(wCode) then
    wCode.SendCommand('error:', aPlaceStr + ': Class=' + aE.ClassName + '; ' +
      aE.Message + ' ' + aE.StackTrace, wcode.TraceId);
end;
{$ENDIF}

initialization

{$IFNDEF LINK_PRO}
  wCode := TCodeTraceManager.Create(0);
  wCode.Enabled := False;
 {$ENDIF}
///




finalization

{$IFNDEF LINK_PRO}
  wCode.Free;
 {$ENDIF}

end.

