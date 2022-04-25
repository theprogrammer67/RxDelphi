unit uCompletable;

interface

uses System.Classes, System.SysUtils, Winapi.Windows, Vcl.Dialogs;

type
  ICompletable<T> = interface
    ['{FDB9282B-84DE-4A80-8B77-2203711352ED}']
  end;

  TComplectable<T> = class(TInterfacedObject, ICompletable<T>)
  type
    TOnComplete = procedure(const AValue: T) of object;
    TExecuteMeth = function: T of object;
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

var
  InstanceArray: TArray<TObject>;
  Finalizing: Boolean;

procedure AddInstance(AInstance: TObject);
procedure RemoveInstance(AInstance: TObject);

implementation

procedure AddInstance(AInstance: TObject);
begin
  SetLength(InstanceArray, Length(InstanceArray) + 1);
  InstanceArray[High(InstanceArray)] := AInstance;
end;

procedure ClearInstances;
var
  I: Integer;
begin
  for I := High(InstanceArray) downto Low(InstanceArray) do
    FreeAndNil(InstanceArray[I]);
  SetLength(InstanceArray, 0);
end;

procedure RemoveInstance(AInstance: TObject);
var
  I: Integer;
begin
  for I := Low(InstanceArray) to High(InstanceArray) do
    if AInstance = InstanceArray[I] then
      InstanceArray[I] := nil;
end;

{ TComplectable<T> }

constructor TComplectable<T>.Create(const AExecuteMeth: TExecuteMeth);
begin
  FExecuteMeth := AExecuteMeth;
  AddInstance(Self);
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
  // FThread.DisposeOf;
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
  inherited;
end;

procedure TComplectable<T>.DoComplete;
begin
  if Assigned(FOnComplete) then
    FOnComplete(FValue);
  // FreeAndNil(FThread);
end;

procedure TComplectable<T>.DoDestroy;
begin
  RemoveInstance(Self);
  Free;
end;

procedure TComplectable<T>.DoHandleException;
begin
  if Assigned(FException) then
    ShowException(FException, nil);
  // MessageBox(0, PWideChar(FException.ToString), 'Exception',
  // MB_OK or MB_ICONERROR);
  // FreeAndNil(FThread);
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

initialization

Finalizing := False;
SetLength(InstanceArray, 0);

finalization

Finalizing := True;
ClearInstances;

end.
