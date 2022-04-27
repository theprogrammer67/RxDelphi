unit ufmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, uCompletable, ufmSecond, System.Generics.Collections;

type
  TTestValue = class
  public
    Name: string;
    Age: Integer;
  end;

  TfrmMain = class(TForm)
    btnExecuteSuccess: TButton;
    btnShowForm: TButton;
    btnExecuteError: TButton;
    procedure btnExecuteSuccessClick(Sender: TObject);
    procedure btnShowFormClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnExecuteErrorClick(Sender: TObject);
  private
    function ExecuteSuccess: TTestValue;
    function ExecuteError: TTestValue;
    procedure Complete(AValue: TTestValue);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnExecuteErrorClick(Sender: TObject);
begin
//   TComplectable<TTestValue>
//   .Create(Self, ExecuteError)
//   .Subscribe(
//     procedure(AValue: TTestValue)
//     begin
//       Complete(AValue);
//     end,
//     procedure(E: Exception)
//     begin
//       ShowMessage(E.Message);
//     end);

  TComplectable<TTestValue>
    .Create(Self, ExecuteError)
    .Subscribe(Complete);
end;

procedure TfrmMain.btnExecuteSuccessClick(Sender: TObject);
begin
//   TComplectable<TTestValue>
//    .Create(Self, ExecuteSuccess)
//    .Subscribe(
//      procedure(AValue: TTestValue)
//      begin
//        Complete(AValue);
//      end);

  TComplectable<TTestValue>
    .Create(Self, ExecuteSuccess)
    .Subscribe(Complete);
end;

procedure TfrmMain.btnShowFormClick(Sender: TObject);
begin
  if not Assigned(frmSecond) then
  begin
    frmSecond := TfrmSecond.Create(nil);
    frmSecond.Show;
  end
  else
    FreeAndNil(frmSecond);
end;

procedure TfrmMain.Complete(AValue: TTestValue);
begin
  ShowMessage(AValue.Name);
  FreeAndNil(AValue);
end;

function TfrmMain.ExecuteError: TTestValue;
begin
  Result := TTestValue.Create;
  try
    Result.Name := 'Igor';
    Result.Age := 55;
    Sleep(3000);
    raise Exception.Create('Error Message');
  except
    Result.Free;
    raise;
  end;
end;

function TfrmMain.ExecuteSuccess: TTestValue;
begin
  Result := TTestValue.Create;
  try
    Result.Name := 'Igor';
    Result.Age := 55;
    Sleep(3000);
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(frmSecond);
end;

end.
