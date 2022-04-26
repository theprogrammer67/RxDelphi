program RxTest;

uses
  Vcl.Forms,
  ufmMain in 'ufmMain.pas' {frmMain},
  uCompletable in '..\uCompletable.pas',
  ufmSecond in 'ufmSecond.pas' {frmSecond};

{$R *.res}

begin
{$IFDEF DEBUG}
  // ��� ����������� ������ ������, ���� ��� ����
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
