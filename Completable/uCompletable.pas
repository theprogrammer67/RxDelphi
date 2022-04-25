unit uCompletable;

interface

uses System.Classes, System.SysUtils, Winapi.Windows;

type
  ICompletable<T> = interface
    ['{FDB9282B-84DE-4A80-8B77-2203711352ED}']
  end;

  TComplectable<T> = class(TInterfacedObject, ICompletable<T>)
  type
    TOnComplete = procedure(const AValue: T) of object;
    TExecuteMeth = function: T of object;
  private
    FExecuteMeth: TExecuteMeth;
    FOnComplete: TOnComplete;
    FValue: T;
  private
    procedure DoComplete;
    procedure DoException(AError: string);
  public
    constructor Create(const AExecuteMeth: TExecuteMeth);
    function Subscribe(AOnConmplete: TOnComplete): TComplectable<T>;
  end;

implementation

  { TComplectable<T> }

constructor TComplectable<T>.Create(const AExecuteMeth: TExecuteMeth);
begin
  FExecuteMeth := AExecuteMeth;
end;

procedure TComplectable<T>.DoComplete;
begin
  if Assigned(FOnComplete) then
    FOnComplete(FValue);
end;

procedure TComplectable<T>.DoException(AError: string);
begin
  MessageBox(0, PWideChar(AError), 'Exception', MB_OK or MB_ICONERROR);
end;

function TComplectable<T>.Subscribe(AOnConmplete: TOnComplete)
  : TComplectable<T>;
begin
  Result := Self;
  if not Assigned(FExecuteMeth) then
    raise Exception.Create('Execute method not assigned');

  FOnComplete := AOnConmplete;
  TThread.CreateAnonymousThread(
    procedure
    var
      LError: string;
    begin
      try
        FValue := FExecuteMeth;
        TThread.Synchronize(nil, DoComplete);
      except
        LError := Exception(ExceptObject).ToString;
        TThread.Queue(nil,
          procedure
          begin
            DoException(LError)
          end);
      end;
    end).Start;
end;

end.
