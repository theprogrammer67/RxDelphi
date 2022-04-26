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
    btn1: TButton;
    btn2: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    function Execute: TTestValue;
    procedure Complete(var AValue: TTestValue);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btn1Click(Sender: TObject);
begin
  TComplectable<TTestValue>.Create(Self, Execute).Subscribe(Complete);
end;

procedure TfrmMain.btn2Click(Sender: TObject);
begin
  if not Assigned(frmSecond) then
  begin
    frmSecond := TfrmSecond.Create(nil);
    frmSecond.Show;
  end
  else
    FreeAndNil(frmSecond);
end;

procedure TfrmMain.Complete(var AValue: TTestValue);
begin
  ShowMessage(AValue.Name);
  FreeAndNil(AValue);
end;

function TfrmMain.Execute: TTestValue;
begin
  Result := TTestValue.Create;
  try
    Result.Name := 'Igor';
    Result.Age := 55;
    Sleep(3000);
    // raise Exception.Create('Error Message');
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
