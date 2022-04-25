unit ufmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, uCompletable;

type
  TTestValue = class
  public
    Name: string;
    Age: Integer;
  end;

  TfrmMain = class(TForm)
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
  private
    function Execute: TTestValue;
    procedure Complete(const AValue: TTestValue);
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

procedure TfrmMain.Complete(const AValue: TTestValue);
begin
  ShowMessage(AValue.Name);
  AValue.Free;
end;

function TfrmMain.Execute: TTestValue;
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

end.
