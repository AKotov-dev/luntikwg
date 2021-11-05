unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Process, DefaultTranslator, XMLPropStorage, Buttons, FileUtil;

type

  { TMainForm }

  TMainForm = class(TForm)
    AutoStartCheckBox: TCheckBox;
    FileEdit: TEdit;
    OpenDialog1: TOpenDialog;
    ReStartBtn: TButton;
    Shape1: TShape;
    LoadBtn: TSpeedButton;
    StaticText2: TStaticText;
    StopBtn: TButton;
    Memo1: TMemo;
    Timer1: TTimer;
    XMLPropStorage1: TXMLPropStorage;
    procedure AutoStartCheckBoxChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure ReStartBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure StartProcess(command: string);

  private

  public

  end;

var
  MainForm: TMainForm;

implementation

uses PingTrd;

{$R *.lfm}

{ TMainForm }

//Проверка чекбокса AutoStart
function CheckAutoStart: boolean;
var
  s: ansistring;
begin
  RunCommand('/bin/bash', ['-c',
    '[[ -n $(systemctl is-enabled luntikwg | grep "enabled") ]] && echo "yes"'], s);

  if Trim(s) = 'yes' then
    Result := True
  else
    Result := False;
end;

//Общая процедура запуска команд (асинхронная)
procedure TMainForm.StartProcess(command: string);
var
  ExProcess: TProcess;
begin
  Application.ProcessMessages;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := 'bash';  //sh или xterm
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);
    //  ExProcess.Options := ExProcess.Options + [poWaitOnExit];
    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

//Вывод лога состояния
procedure TMainForm.Timer1Timer(Sender: TObject);
var
  LOG: TStringList;
begin
  if FileExists('/var/log/luntikwg.log') then
  begin
    LOG := TStringList.Create;
    LOG.LoadFromFile('/var/log/luntikwg.log');
    if LOG.Text <> Memo1.Lines.Text then
    begin
      Memo1.Lines.Assign(LOG);
      //Промотать список вниз
      Memo1.SelStart := Length(Memo1.Text);
      Memo1.SelLength := 0;
    end;
    LOG.Destroy;
  end;
end;

procedure TMainForm.ReStartBtnClick(Sender: TObject);
begin
  //Перезапуск соединения
  StartProcess(
    '/etc/luntikwg/restart-wg0');
end;

procedure TMainForm.AutoStartCheckBoxChange(Sender: TObject);
var
  s: ansistring;
begin
  Screen.Cursor := crHourGlass;
  if AutoStartCheckBox.Checked then
    RunCommand('/bin/bash', ['-c', 'systemctl enable luntikwg'], s)
  else
    RunCommand('/bin/bash', ['-c', 'systemctl disable luntikwg'], s);

  AutoStartCheckBox.Checked := CheckAutoStart;
  Screen.Cursor := crDefault;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  XMLPropStorage1.Save;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  XMLPropStorage1.Restore;
  LoadBtn.Width := FileEdit.Height;
  AutoStartCheckBox.Checked := CheckAutoStart;
end;

procedure TMainForm.LoadBtnClick(Sender: TObject);
begin
  //Копируем новый ключ и редактируем для update-resolv-conf
  if OpenDialog1.Execute then
  begin
    FileEdit.Text := OpenDialog1.FileName;
    CopyFile(OpenDialog1.FileName, '/etc/luntikwg/wg0.conf', False);
    StartProcess('/etc/luntikwg/restart-wg0');
  end;
end;

procedure TMainForm.StopBtnClick(Sender: TObject);
begin
  StartProcess('wg-quick down /etc/luntikwg/wg0.conf');
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  FCheckPingThread: TThread;
begin
  MainForm.Caption := Application.Title;

  XMLPropStorage1.FileName := '/etc/luntikwg/luntikwg.xml';

  //Загружаем модули ядра и включаем log в dmesg
  StartProcess(
    '[[ $(lsmod | grep wireguard) ]] || modprobe wireguard; echo module wireguard +p > /sys/kernel/debug/dynamic_debug/control');

  //Поток проверки пинга
  FCheckPingThread := CheckPing.Create(False);
  FCheckPingThread.Priority := tpNormal;
end;

end.