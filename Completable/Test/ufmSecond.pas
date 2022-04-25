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


  TForm3 = class(TForm)
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
  private
    function Execute: TTestValue1;
    procedure Complete(var AValue: TTestValue1);
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.btn1Click(Sender: TObject);
begin
  TComplectable<TTestValue1>.Create(Self, Execute).Subscribe(Complete);
end;

procedure TForm3.Complete(var AValue: TTestValue1);
begin
  ShowMessage(AValue.Name);
  FreeAndNil(AValue);
end;

function TForm3.Execute: TTestValue1;
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

end.