unit ufmSecond;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uCompletable, Vcl.StdCtrls;

type
  TTestValue1 = class
  public
    Name: string;
    Age: Integer;
  end;

  TfrmSecond = class(TForm)
    btnExecuteSuccess: TButton;
    btnExecuteError: TButton;
    procedure btnExecuteSuccessClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExecuteErrorClick(Sender: TObject);
  private
    function ExecuteSuccess: TTestValue1;
    function ExecuteError: TTestValue1;
    procedure Complete(var AValue: TTestValue1);
  public
    { Public declarations }
  end;

var
  frmSecond: TfrmSecond;

implementation

{$R *.dfm}

procedure TfrmSecond.btnExecuteErrorClick(Sender: TObject);
begin
  TComplectable<TTestValue1>.Create(frmSecond, ExecuteError)
    .Subscribe(Complete);
end;

procedure TfrmSecond.btnExecuteSuccessClick(Sender: TObject);
begin
  TComplectable<TTestValue1>.Create(frmSecond, ExecuteSuccess)
    .Subscribe(Complete);
end;

procedure TfrmSecond.Complete(var AValue: TTestValue1);
begin
  ShowMessage(AValue.Name);
  FreeAndNil(AValue);
end;

function TfrmSecond.ExecuteError: TTestValue1;
begin
  Result := TTestValue1.Create;
  try
    Result.Name := 'Oleg';
    Result.Age := 22;
    Sleep(3000);
    raise Exception.Create('Error Message 1');
  except
    Result.Free;
    raise;
  end;
end;

function TfrmSecond.ExecuteSuccess: TTestValue1;
begin
  Result := TTestValue1.Create;
  try
    Result.Name := 'Oleg';
    Result.Age := 22;
    Sleep(3000);
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmSecond.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmSecond := nil;
end;

end.
