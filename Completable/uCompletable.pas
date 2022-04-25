unit uCompletable;

interface

uses System.Classes, System.SysUtils, Winapi.Windows,
  System.Generics.Collections, System.TypInfo, System.Rtti;

type
  TComplectable<T> = class
  type
    TOnComplete = procedure(var AValue: T) of object;
    TExecuteMeth = function: T of object;

  class var
    InstanceList: TObjectList<TObject>;
    Finalizing: Boolean;
  private
    class constructor Create;
    class destructor Destroy;
  private
    FThread: TThread;
    FExecuteMeth: TExecuteMeth;
    FOnComplete: TOnComplete;
    FValue: T;
    FException: Exception;
    FHasOwner: Boolean;
    FOwner: TObject;
  private
    procedure DoComplete;
    procedure DoHandleException;
    procedure DoDestroy;
    function NeedCallEvent: Boolean;
  public
    constructor Create(const AExecuteMeth: TExecuteMeth); overload;
    constructor Create(AOwner: TObject;
      const AExecuteMeth: TExecuteMeth); overload;
    destructor Destroy; override;
    function Subscribe(AOnConmplete: TOnComplete): TComplectable<T>;
  end;

implementation

{ TComplectable<T> }

constructor TComplectable<T>.Create(const AExecuteMeth: TExecuteMeth);
begin
  FExecuteMeth := AExecuteMeth;
  InstanceList.Add(Self);
end;

class constructor TComplectable<T>.Create;
begin
  Finalizing := False;
  InstanceList := TObjectList<TObject>.Create;
end;

constructor TComplectable<T>.Create(AOwner: TObject;
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
  InstanceList.Free;
end;

procedure TComplectable<T>.DoComplete;
begin
  if Assigned(FOnComplete) then
  begin
    FOnComplete(FValue);
    if PTypeInfo(System.TypeInfo(T)).Kind = tkClass then
      PObject(@FValue)^ := nil;
  end;
end;

procedure TComplectable<T>.DoDestroy;
begin
  InstanceList.Remove(Self);
end;

procedure TComplectable<T>.DoHandleException;
begin
  if Assigned(FException) then
    ShowException(FException, nil);
end;

function TComplectable<T>.NeedCallEvent: Boolean;
begin
  Result := (((FHasOwner) and (Assigned(FOwner))) or (not FHasOwner)) and
    (not Finalizing);
end;

function TComplectable<T>.Subscribe(AOnConmplete: TOnComplete)
  : TComplectable<T>;
begin
  Result := Self;
  if not Assigned(FExecuteMeth) then
    raise Exception.Create('Execute method not assigned');

  FException := nil;
  FOnComplete := AOnConmplete;
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

end.
