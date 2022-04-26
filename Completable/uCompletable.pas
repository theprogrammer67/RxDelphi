unit uCompletable;

interface

uses System.Classes, System.SysUtils, Winapi.Windows,
  System.Generics.Collections, System.TypInfo;

type
  TComplectable<T> = class
  type
    TExecuteMeth = function: T of object;
    TOnComplete = procedure(var AValue: T) of object;
    TOnError = procedure(E: Exception) of object;

  class var
    Instances: TObjectList<TObject>;
    Finalizing: Boolean;
  private
    class constructor Create;
    class destructor Destroy;
  private
    FThread: TThread;
    FExecuteMeth: TExecuteMeth;
    FOnComplete: TOnComplete;
    FOnError: TOnError;
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
  public
    constructor Create(const AExecuteMeth: TExecuteMeth); overload;
    constructor Create(AOwner: IInterfaceComponentReference;
      const AExecuteMeth: TExecuteMeth); overload;
    destructor Destroy; override;
    function Subscribe(AOnConmplete: TOnComplete): TComplectable<T>; overload;
    function Subscribe(AOnConmplete: TOnComplete; AOnError: TOnError)
      : TComplectable<T>; overload;
  end;

implementation

{ TComplectable<T> }

constructor TComplectable<T>.Create(const AExecuteMeth: TExecuteMeth);
begin
  FExecuteMeth := AExecuteMeth;
  Instances.Add(Self);
end;

class constructor TComplectable<T>.Create;
begin
  Finalizing := False;
  Instances := TObjectList<TObject>.Create;
end;

constructor TComplectable<T>.Create(AOwner: IInterfaceComponentReference;
  const AExecuteMeth: TExecuteMeth);
begin
  FHasOwner := True;
  FOwner := AOwner;
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
  if Assigned(FOnComplete) then
  begin
    FOnComplete(FValue);
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
    if Assigned(FOnError) then
      FOnError(FException)
    else
      ShowException(FException, nil);
  end;
end;

function TComplectable<T>.NeedCallEvent: Boolean;
begin
  Result := ((FHasOwner) and (Assigned(FOwner)) or (not FHasOwner)) and
    (not Finalizing);
end;

function TComplectable<T>.Subscribe(AOnConmplete: TOnComplete;
  AOnError: TOnError): TComplectable<T>;
begin
  if not Assigned(FExecuteMeth) then
    raise Exception.Create('Execute method not assigned');

  Result := Self;
  FException := nil;
  FOnComplete := AOnConmplete;
  FOnError := AOnError;

  FThread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        try
          FValue := FExecuteMeth;
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

function TComplectable<T>.Subscribe(AOnConmplete: TOnComplete)
  : TComplectable<T>;
begin
  Result := Subscribe(AOnConmplete, nil);
end;

end.
