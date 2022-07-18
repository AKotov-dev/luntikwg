unit PingTRD;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process, Graphics, ComCtrls;

type
  CheckPing = class(TThread)
  private

    { Private declarations }
  protected
  var
    PingStr: TStringList;

    procedure Execute; override;
    procedure ShowStatus;

  end;

implementation

uses unit1;

{ TRD }

procedure CheckPing.Execute;
var
  PingProcess: TProcess;
begin
  try
    FreeOnTerminate := True; //Уничтожать по завершении
    PingStr := TStringList.Create;

    PingProcess := TProcess.Create(nil);
    PingProcess.Executable := 'bash';

    while not Terminated do
    begin
      PingProcess.Parameters.Clear;
      PingProcess.Parameters.Add('-c');
      PingProcess.Parameters.Add(
        // 'ping -c 2 google.com &> /dev/null && [[ $(ip -br a | grep wg[[:digit:]]) ]] && echo "yes" || echo "no"');
        '[[ $(fping google.com) && $(ip -br a | grep wg[[:digit:]]) ]] && echo "yes" || echo "no"');

      PingProcess.Options := [poUsePipes, poWaitOnExit];

      PingProcess.Execute;
      PingStr.LoadFromStream(PingProcess.Output);
      Synchronize(@ShowStatus);

      //Вывод лога WireGuard

      PingProcess.Parameters.Clear;
      PingProcess.Parameters.Add('-c');
      PingProcess.Parameters.Add(
        'dmesg --level=debug | grep wireguard: | tail -n 20 > /var/log/luntikwg.log');
      PingProcess.Execute;

      Sleep(500);
    end;

  finally
    PingStr.Free;
    PingProcess.Free;
    Terminate;
  end;
end;

procedure CheckPing.ShowStatus;
begin
  Application.ProcessMessages;
  if Trim(PingStr[0]) = 'yes' then
  begin
    MainForm.Shape1.Brush.Color := clLime;
    MainForm.ProgressBar1.Style := pbstNormal;
    MainForm.ProgressBar1.Visible := False;
  end
  else
    MainForm.Shape1.Brush.Color := clYellow;
  MainForm.Shape1.Repaint;
end;

end.
