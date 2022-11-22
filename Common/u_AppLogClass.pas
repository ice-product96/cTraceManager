unit u_AppLogClass;

interface

uses  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
   {$IFDEF FMX}
    FMX.Types,
   {$ELSE}

   {$ENDIF}
    System.Generics.Collections;

///////////////////////////////////////////////////////////////////////////
///
///    ����� �� ������ � ������ ���������, ������ � ������ ������������ ������ ���������
///    � �������  ��� ���������. ��������� ��������
///       Category,ActionName,LabelDesc:string[64]  64 ��� Embarcadero!
///       Value:Double;
///
///   ����� - ��������� ��������
///     SetPlace - �������� "���������" ����� - �.�. ���������� ���������
///      � ��� ���� ������ � ��� ���������
///
///   ClearPlace ����� ��������� � All
///
///   ����� ����, ���� ���������. ��-�� DescInformation - � ���� ������� ������� ����������
///   ������ �����: ��������, ������ �� ����������, OS,� �.�.   PC,WIN64,Windows 8
///
///   ����� �������� ������ Joint � ������������ ��������� � ���� ����������
///   �� ������������ ��� ����������� �����-���� ��������� ����� ��� �����������
///   ��������:
///        LogItems.Joint['AXC_RE']:='1';
///           ...��������
///        LogItems.DeleteJoint('AXC_RE');
///
///     ���� ������ ��������� ������ - �� � ������ ������������� Joint ����������
///       � ����� ���� ������ � ������ �� ������, ���� �������� ��������� �������,
///     �� ����������� �� ����������
///
///   ��� ����������� ������������ ��������� �������� State � Items
///     ���� ������ ���� �� ���� ���������� = 0  - ���� ������/������ ����, ��������,
///     ���������� � ������� ��������� - �� = 1  - ��� ��������� ��������� �������� �����
///     �.�.   ����� ��������� ��������� State  - ���� =0 �� ��������� � ��������� � 1
///
///
///    ����� ������������� ������������ ���������� ������ AppLog - ��. ����
///    � ��������� �� ��� ��������-�����������
///    (� ������� ������� ���. ������ �� ������)


 type
     /// <summary>
     ///      ������ ������� ��� �����������
     /// </summary>
     TAppLoggingItem=record
       dTime:TDateTime;
       Category,ActionName,LabelDesc:string;
       Value:Double;
       /// <summary>
       ///      0 - ������ ������� ���� �� ���� ���������� (�.�. ������ � ���� �� ����������)
       /// </summary>
       Num,State:Integer;
       Level:Integer;
       Sign:Integer;
       logRegime:Integer; // =0 - ��� ����� ������  = 1 - ��� ����������� ������
     end;

     TLogItemDataEvent=procedure(const ARec:TAppLoggingItem) of object;

     /// <summary>
     ///      ��� ����� ����������
     /// </summary>
     TJointRecord=record
      Name:string;
      Value:string;
      dTime:TDateTime;
     end;
     ///  0 - Add  1 - Modify  2 - Delete
     TJointEvent=procedure(aOpSign:Integer; const ARec:TJointRecord) of object;

     /// <summary>
     ///    ��������� � �������� ������������ ��� �����������
     /// </summary>
     TAppLoggingItems=class(TList<TAppLoggingItem>)
      private
      /// <summary>
      ///     ������ ����� ���� - ��� OS � ����� ����������
      /// </summary>
       FDescInformation:string;
       /// <summary>
       ///     ��� �������� ���������� �� ��� ��������� � ���������
       /// </summary>
       FActiveItem:TAppLoggingItem;
       /// <summary>
       ///    ������ ������� Item
       /// </summary>
       FlastIndex:Integer;
       FJointFlag:Boolean;
       FJoints:TList<TJointRecord>;
       ///
       FOnSetData:TLogItemDataEvent;
       FOnSetJoint:TJointEvent;
       ///
       function GetCurrCategory:string;
       function GetJoint(Index:string):string;
       procedure SetJoint(Index,aValue:string);
       function GetAllJoints:string;
      public
       function GetIndexOfParams(const Acategory,aAction:string):Integer;
       function AddUniqueItem(const Acategory,aAction,aLabel:string; aValue:Double; Lvl,Sign:integer):TAppLoggingItem;
       ///
       /// <summary>
       ///     ������. ����������� - ���������� ������ � ��������� ��� ������ ��� ������������ �������
       /// </summary>
       function PData(const aAction,aLabelDesc:string; aLvl:integer=1; aValue:Double=1):Integer;
       /// <summary>
       ///      ���������� � ������������ � ��������� ���� - ���. ��� �����������
       /// </summary>
       function PDataEx(const aCategory,aAction,aLabelDesc:string; aLvl:integer=1; aValue:Double=1):Integer;
       /// <summary>
       ///     ��� ���. �������� ������ ����� �������� - ���� aAction - ������ - �� �� ������ ��� 'noAction';
       /// </summary>
       procedure PValue(aValue:Double; const aAction:string='');
       ///
       procedure SetState(aIndex,aNewState:Integer);
       ///
       procedure SetStates(aState:Integer);
       /// <summary>
       ///    �������� ��� - ������ ����� �������� (������ � ������� Setstates=1)
       /// </summary>
       procedure ClearStates(aClState:Integer=1);
       /// <summary>
       ///     ������ ����������� ��� ��������� - ������
       /// </summary>
       procedure SetPlace(const aCategory,aActionName:String);
       /// <summary>
       ///     �������� ��� ���������
       /// </summary>
       procedure ClearPlace;
       ///
       function GetItemStr(aIndex:Integer; aGetRg:Integer=1):string;
       ///
       constructor Create;
       destructor Destroy; override;
       ///
       /// <summary>
       ///    �������� � ������
       /// </summary>
       procedure ViewLines(const ALines:TStrings; aViewRg:Integer=0);
       ///
       procedure DeleteJoint(const aIndex:string);
       ///
       property DescInformation:string read FDescInformation write FDescInformation;
       property LastIndex:integer read FlastIndex;
       /// <summary>
       ///      ��� �������
       /// </summary>
       property CurrCategory:string read GetCurrCategory;
       ///
       property IsJointed:Boolean read FJointFlag write FJointFlag;
       property Joint[Index: String]:string read GetJoint write SetJoint;
       /// <summary>
       ///    ���������� ������ ���� <A=1,B=2,C=ss> ��� Joints  ��� ������ - ���� �� �� ������
       /// </summary>
       property JointString:string read GetAllJoints;
       /// ��������� ���������. �������
       property OnSetData:TLogItemDataEvent read FOnSetData write FOnSetData;
       property OnSetJoint:TJointEvent read FOnSetJoint write FOnSetJoint;
     end;

 ///////////////////////////////////////
 ///
 ///   ���������� ������
 ///
 var AppLog:TAppLoggingItems=nil;

 procedure AppLogCreate(const ADescInfo:string);
 procedure AppLogFree;

implementation

///////////////////////////////////////////////////////////////////////////
/// ������� ������������ � ������������� ��� �������
function AppLoggingItem_ToString(const aRec:TAppLoggingItem; aConvertRg:Integer=0):string;
var LDiv:string;
 begin
   LDiv:='|';
   with aRec do
    begin
      Result:=Concat('T*=',DateTimeToStr(dTime),LDiv,'C*=',Category,LDiv,'A*=',ActionName,LDiv,
      'D*=',LabelDesc,LDiv,'V*=',FloatToStr(Value),LDiv,'N*=',IntToStr(Num),LDiv,
      'S*=',IntToStr(State),LDiv,'L*=',IntToStr(Level),LDiv,'R*=',IntToStr(logRegime),Ldiv,
      'G*=',IntToStr(Sign));
    end;
 end;

function JointRecordToString(const ARec:TJointRecord):string;
 begin
   Result:=Concat(ARec.Name,'=',ARec.Value,' |>',TimeToStr(ARec.dTime));
 end;

///////////////////////////////////////////////////////////////////////////
 /////////////////////
 //////////////////
 ///
 function TAppLoggingItems.GetCurrCategory:string;
  begin
    Result:=FActiveItem.Category;
  end;

 function TAppLoggingItems.GetJoint(Index:string):string;
 var i:integer;
  begin
   Result:='';
   i:=0;
   while i<FJoints.Count do
    begin
      if FJoints[i].Name=Index then
       begin
         Result:=FJoints[i].Value;
       end;
      Inc(i);
    end;
  end;

 procedure TAppLoggingItems.SetJoint(Index,aValue:string);
 var i:integer;
     LRec:TJointRecord;
     LFlag:Boolean;
  begin
   LFlag:=false;
   if Index='' then Exit;
   LRec.Name:=Index;
   LRec.dTime:=Now;
   LRec.Value:=aValue;
   i:=0;
   while i<FJoints.Count do
    begin
      if FJoints[i].Name=Index then
       begin
         FJoints[i]:=LRec;
         if Assigned(FOnSetJoint) then
            FOnSetJoint(1,FJoints[i]);
         LFlag:=True;
         Break;
       end;
      Inc(i);
    end;
   if LFlag=false then
    begin
      FJoints.Add(Lrec);
      if Assigned(FOnSetJoint) then
            FOnSetJoint(0,Lrec);
    end;
  end;

 function TAppLoggingItems.GetAllJoints:string;
 var i:Integer;
  begin
    Result:='';
    i:=0;
    if FJointFlag=false then Exit;
    while i<FJoints.Count do
     begin
       if FJoints[i].Value<>'' then
        begin
          if Result='' then
             Result:=Concat(FJoints[i].Name,':',FJoints[i].Value)
          else Result:=Concat(Result,',',FJoints[i].Name,':',FJoints[i].Value);
        end;
       Inc(i);
     end;
    if Result<>'' then
     begin
       Result:=Concat('<',Result,'>');
     end;
  end;

 function TAppLoggingItems.GetIndexOfParams(const Acategory,aAction:string):Integer;
 var i:Integer;
      LRec:TAppLoggingItem;
  begin
   Result:=-1;
   i:=0;
    while i<Count do
     begin
       LRec:=Items[i];
       if (LRec.Category=Acategory) and (LRec.ActionName=aAction) then
        begin
         Result:=i;
         Break;
        end;
       Inc(i);
     end;
  end;

 function TAppLoggingItems.AddUniqueItem(const Acategory,aAction,aLabel:string;
     aValue:Double; Lvl,Sign:integer):TAppLoggingItem;
  var i:Integer;
      LRec:TAppLoggingItem;
      LFlag:Boolean;
      L_Label:string;
  begin
   LFlag:=False;
   i:=0;
    while i<Count do
     begin
       LRec:=Items[i];
       if (LRec.Category=Acategory) and (LRec.ActionName=aAction) then
        begin
         LRec.dTime:=Now;
         if Trim(aLabel)<>'' then
           LRec.LabelDesc:=Trim(aLabel);
         LRec.Value:=aValue;
         LRec.Level:=Lvl;
         LRec.Sign:=Sign;
         LRec.State:=0; // !
         LRec.logRegime:=1;
         Items[i]:=LRec;
         LFlag:=True;
         Break;
        end;
       Inc(i);
     end;
    ///
    if LFlag then Result:=LRec
    else
     begin
       LRec.Num:=Count;
       LRec.dTime:=Now;
       LRec.Category:=Acategory;
       LRec.ActionName:=aAction;
       L_Label:=Trim(aLabel);
       LRec.LabelDesc:=L_Label;
       LRec.Value:=aValue;
       LRec.Level:=Lvl;
       LRec.Sign:=Sign;
       LRec.State:=0; // !
       LRec.logRegime:=0;
       Add(Lrec);
       Result:=LRec;
     end;
  end;

 function TAppLoggingItems.PData(const aAction,aLabelDesc:string; aLvl:integer=1; aValue:Double=1):Integer;
 var LRec:TAppLoggingItem;
     LAction:string;
  begin
    if aAction='' then LAction:=FActiveItem.ActionName else LAction:=aAction;
    Lrec:=AddUniqueItem(FActiveItem.Category,LAction,aLabelDesc,aValue,aLvl,0);
    Result:=GetIndexOfParams(LRec.Category,LRec.ActionName);
    if Assigned(FOnSetData) then
       FOnSetData(LRec);
    FlastIndex:=Result;
  end;

 function TAppLoggingItems.PDataEx(const aCategory,aAction,aLabelDesc:string; aLvl:integer=1; aValue:Double=1):Integer;
 var LRec:TAppLoggingItem;
     Lcat,LAction:string;
  begin
    if aCategory='' then Lcat:=FActiveItem.Category else Lcat:=Trim(aCategory);
    if Lcat='' then Lcat:='All';
    if aAction='' then LAction:=FActiveItem.ActionName else LAction:=aAction;
    if LAction='' then LAction:='dA';
    Lrec:=AddUniqueItem(LCat,LAction,aLabelDesc,aValue,aLvl,0);
    Result:=GetIndexOfParams(LRec.Category,LRec.ActionName);
    if Assigned(FOnSetData) then
       FOnSetData(LRec);
    FlastIndex:=Result;
  end;


 procedure TAppLoggingItems.PValue(aValue:Double; const aAction:string='');
 var i:Integer;
     LRec:TAppLoggingItem;
     LAction:string;
  begin
    if aAction='' then LAction:=FActiveItem.ActionName else LAction:=aAction;
    i:=GetIndexOfParams(FActiveItem.Category,LAction);
    if i<0 then
     PData(LAction,'',1,aValue)
    else begin
      LRec:=Items[i];
      LRec.dTime:=Now;
      LRec.Value:=aValue;
      LRec.State:=0;
      LRec.logRegime:=1;
      Items[i]:=LRec;
      if Assigned(FOnSetData) then
         FOnSetData(LRec);
    end;
    FlastIndex:=i;
  end;

 procedure TAppLoggingItems.SetState(aIndex,aNewState:Integer);
 var LRec:TAppLoggingItem;
  begin
    if (aIndex>=0) and (aIndex<Count) then
     begin
       LRec:=Items[aIndex];
       LRec.State:=aNewState;
       Items[aIndex]:=LRec;
     end;
  end;

 procedure TAppLoggingItems.SetStates(aState:Integer);
 var i:integer;
     LRec:TAppLoggingItem;
  begin
    i:=0;
    while i<Count do
     begin
       LRec:=Items[i];
       LRec.State:=aState;
       Items[i]:=LRec;
       Inc(i);
     end;
  end;

 procedure TAppLoggingItems.ClearStates(aClState:Integer=1);
  begin
    SetStates(aClState);
  end;

 procedure TAppLoggingItems.SetPlace(const aCategory,aActionName:String);
  begin
    FActiveItem.dTime:=Now;
    FActiveItem.Category:=aCategory;
    FActiveItem.ActionName:=Trim(aActionName);
    if FActiveItem.ActionName='' then
       FActiveItem.ActionName:='';
    FActiveItem.Sign:=1;
  end;

 procedure TAppLoggingItems.ClearPlace;
  begin
   FActiveItem.Category:='All';
   FActiveItem.ActionName:='';
   FActiveItem.Sign:=0;
  end;

 function TAppLoggingItems.GetItemStr(aIndex:Integer; aGetRg:Integer=1):string;
 var LRec:TAppLoggingItem;
     Ldiv,LVs:string;
  begin
    Result:='';
    LDiv:=',';
    if (aIndex>=0) and (aIndex<Count) then
     begin
       LVs:=StringReplace(FloatToStrF(LRec.Value,ffFixed,5,2),FormatSettings.DecimalSeparator,'.',[]);
       LRec:=Items[aIndex];
       case aGetRg of
       0: Result:=Concat(LRec.Category,Ldiv,LRec.ActionName,Ldiv,LRec.LabelDesc,Ldiv,
                      IntToStr(LRec.Level),LDiv,FloatToStrF(LRec.Value,ffFixed,5,3));
       1: Result:=Concat(LRec.Category,Ldiv,LRec.ActionName,Ldiv,LRec.LabelDesc,Ldiv,
                      IntToStr(LRec.Level));
       5: if LRec.LabelDesc<>'' then
             Result:=Concat(LRec.LabelDesc,Ldiv,IntToStr(LRec.Level))
          else Result:=Concat('L',IntToStr(LRec.Level));
       end
     end;
  end;

 constructor TAppLoggingItems.Create;
  begin
    inherited;
    FOnSetData:=nil;
    FOnSetJoint:=nil;
    FlastIndex:=-1;
    FDescInformation:='PC';
    ClearPlace; // !
    FJointFlag:=True;
    FJoints:=TList<TJointRecord>.Create;
  end;

 destructor TAppLoggingItems.Destroy;
  begin
    FJoints.Free;
    inherited
  end;

 procedure TAppLoggingItems.ViewLines(const ALines:TStrings; aViewRg:Integer=0);
 var i,j:Integer;
     LCat,LS:string;
     LRec:TAppLoggingItem;
     LList:TStrings;
  begin
   ALines.Clear;
   LList:=TStringList.Create;
   try
    ALines.Add('*LOGS*');
    i:=0;
    while i<Count do
     begin
       Lcat:=Items[i].Category;
       if LList.IndexOf(Lcat)<0 then
          LList.Add(Lcat);
       Inc(i);
     end;
    j:=0;
    while j<LList.Count do
     begin
       i:=0;
       ALines.Add('*CATEGORY='+LList.Strings[i]);
       while i<Count do
        begin
          if Items[i].Category=LList.Strings[j] then
           begin
             LS:='  '+AppLoggingItem_ToString(Items[i]);
             ALines.Add(LS);
           end;
          Inc(i);
        end;
      Inc(j);
     end;
    ALines.Add('*JOINS*');
    j:=0;
    while j<FJoints.Count do
     begin
       ALines.Add(JointRecordToString(FJoints.Items[i]));
       Inc(j);
     end;
   finally
     LList.Free;
   end;
  end;

 procedure TAppLoggingItems.DeleteJoint(const aIndex:string);
 var i:Integer;
  begin
   i:=0;
   while i<FJoints.Count do
    begin
      if FJoints[i].Name=aIndex then
       begin
         if Assigned(FOnSetJoint) then
            FOnSetJoint(2,FJoints[i]);
         FJoints.Delete(i);
         Break;
       end;
      Inc(i);
    end;
  end;

/////////////////////////////////////////////////////////////////////
///
///
 procedure AppLogCreate(const ADescInfo:string);
  begin
    if Assigned(AppLog)=false then
     begin
       AppLog:=TAppLoggingItems.Create;
     end;
    AppLog.DescInformation:=ADescInfo;
  end;

 procedure AppLogFree;
   begin
    if Assigned(AppLog) then
     begin
       AppLog.Free;
       AppLog:=nil;
     end;
   end;

end.
