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
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    function Execute: TTestValue1;
    procedure Complete(var AValue: TTestValue1);
  public
    { Public declarations }
  end;

var
  frmSecond: TfrmSecond;

implementation

{$R *.dfm}

procedure TfrmSecond.btn1Click(Sender: TObject);
begin
  TComplectable<TTestValue1>.Create(frmSecond, Execute).Subscribe(Complete);
end;

procedure TfrmSecond.Complete(var AValue: TTestValue1);
begin
  ShowMessage(AValue.Name);
  FreeAndNil(AValue);
end;

function TfrmSecond.Execute: TTestValue1;
begin
  Result := TTestValue1.Create;
  try
    Result.Name := 'Oleg';
    Result.Age := 22;
    Sleep(3000);
    // raise Exception.Create('Error Message');
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
