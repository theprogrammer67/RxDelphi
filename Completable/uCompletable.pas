unit uCompletable;

interface

uses System.Classes, System.SysUtils, Winapi.Windows,
  System.Generics.Collections, System.TypInfo;

type
  TComplectable<T> = class
  type
    TExecuteMeth = function: T of object;
    TExecuteFunc = TFunc<T>;
    TOnCompleteMeth = procedure(AValue: T) of object;
    TOnCompleteProc = TProc<T>;
    TOnErrorMeth = procedure(E: Exception) of object;
    TOnErrorProc = reference to procedure(E: Exception);

  class var
    Instances: TObjectList<TObject>;
    Finalizing: Boolean;
  private
    class constructor Create;
    class destructor Destroy;
  private
    FThread: TThread;
    FExecuteFunc: TExecuteFunc;
    FOnCompleteProc: TOnCompleteProc;
    FOnErrorProc: TOnErrorProc;
    FValue: T;
    FException: Exception;
    FHasOwner: Boolean;
    [weak]
    FOwner: IInterfaceComponentReference;
  private
    procedure DoComplete;
    procedure DoHandleException;
    procedure DoDestroy;
    function NeedCallEvent: Boolean;
    procedure SetOwner(const Value: IInterfaceComponentReference);
  public
    constructor Create; overload;
    destructor Destroy; override;
  public
    constructor Create(const AExecuteFunc: TExecuteFunc); overload;
    constructor Create(const AExecuteMeth: TExecuteMeth); overload;

    constructor Create(AOwner: IInterfaceComponentReference;
      const AExecuteMeth: TExecuteMeth); overload;
    constructor Create(AOwner: IInterfaceComponentReference;
      const AExecuteFunc: TExecuteFunc); overload;

    function Subscribe(AOnConmpleteProc: TOnCompleteProc)
      : TComplectable<T>; overload;
    function Subscribe(AOnConmpleteMeth: TOnCompleteMeth)
      : TComplectable<T>; overload;

    function Subscribe(AOnConmpleteProc: TOnCompleteProc;
      AOnErrorProc: TOnErrorProc): TComplectable<T>; overload;
    function Subscribe(AOnConmpleteMeth: TOnCompleteMeth;
      AOnErrorMeth: TOnErrorMeth): TComplectable<T>; overload;
  private
    property Owner: IInterfaceComponentReference read FOwner write SetOwner;
  end;

implementation

{ TComplectable<T> }

constructor TComplectable<T>.Create(const AExecuteMeth: TExecuteMeth);
begin
  Create(
    function: T
    begin
      Result := AExecuteMeth;
    end);
end;

class constructor TComplectable<T>.Create;
begin
  Finalizing := False;
  Instances := TObjectList<TObject>.Create;
end;

constructor TComplectable<T>.Create(AOwner: IInterfaceComponentReference;
const AExecuteMeth: TExecuteMeth);
begin
  Owner := AOwner;
  Create(AExecuteMeth);
end;

destructor TComplectable<T>.Destroy;
begin
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;

  if PTypeInfo(System.TypeInfo(T)).Kind = tkClass then
    FreeAndNil(PObject(@FValue)^);

  inherited;
end;

class destructor TComplectable<T>.Destroy;
begin
  Finalizing := True;
  Instances.Free;
end;

procedure TComplectable<T>.DoComplete;
begin
  if Assigned(FOnCompleteProc) then
  begin
    FOnCompleteProc(FValue);
    // „тобы FValue не уничтожилс€ при уничтожении Self (TComplectable)
    if PTypeInfo(System.TypeInfo(T)).Kind = tkClass then
      PObject(@FValue)^ := nil;
  end;
end;

procedure TComplectable<T>.DoDestroy;
begin
  Instances.Remove(Self);
end;

procedure TComplectable<T>.DoHandleException;
begin
  if Assigned(FException) then
  begin
    if Assigned(FOnErrorProc) then
      FOnErrorProc(FException)
    else
      ShowException(FException, nil);
  end;
end;

function TComplectable<T>.NeedCallEvent: Boolean;
begin
  Result := ((FHasOwner) and (Assigned(FOwner)) or (not FHasOwner)) and
    (not Finalizing);
end;

procedure TComplectable<T>.SetOwner(const Value: IInterfaceComponentReference);
begin
  FHasOwner := True;
  FOwner := Value;
end;

function TComplectable<T>.Subscribe(AOnConmpleteMeth: TOnCompleteMeth;
AOnErrorMeth: TOnErrorMeth): TComplectable<T>;
begin
  Result := Subscribe(
    procedure(AValue: T)
    begin
      AOnConmpleteMeth(AValue);
    end,
    procedure(E: Exception)
    begin
      AOnErrorMeth(E);
    end);
end;

function TComplectable<T>.Subscribe(AOnConmpleteMeth: TOnCompleteMeth)
  : TComplectable<T>;
begin
  Subscribe(
    procedure(AValue: T)
    begin
      AOnConmpleteMeth(AValue);
    end);
end;

function TComplectable<T>.Subscribe(AOnConmpleteProc: TOnCompleteProc;
AOnErrorProc: TOnErrorProc): TComplectable<T>;
begin
  if not Assigned(FExecuteFunc) then
    raise Exception.Create('Execute function not assigned');

  Result := Self;
  FException := nil;
  FOnCompleteProc := AOnConmpleteProc;
  FOnErrorProc := AOnErrorProc;

  FThread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        try
          FValue := FExecuteFunc;
          if NeedCallEvent then
            TThread.Synchronize(nil, DoComplete);
        except
          FException := Exception(ExceptObject);
          if NeedCallEvent then
            TThread.Synchronize(nil, DoHandleException);
        end;
      finally
        if not Finalizing then
          TThread.Queue(nil, DoDestroy);
      end;
    end);
  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

function TComplectable<T>.Subscribe(AOnConmpleteProc: TOnCompleteProc)
  : TComplectable<T>;
begin
  Result := Subscribe(AOnConmpleteProc, nil);
end;

constructor TComplectable<T>.Create(AOwner: IInterfaceComponentReference;
const AExecuteFunc: TExecuteFunc);
begin
  Owner := AOwner;
  Create(AExecuteFunc);
end;

constructor TComplectable<T>.Create(const AExecuteFunc: TExecuteFunc);
begin
  FExecuteFunc := AExecuteFunc;
  Create;
end;

constructor TComplectable<T>.Create;
begin
  Instances.Add(Self);
end;

end.
