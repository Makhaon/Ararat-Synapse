unit main;

interface

uses
 Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types, Vcl.Graphics,
 Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, blcksock, winsock;

resourcestring
 rsStart = '���������';
 rsStop  = '����������';

type
  {"��������� �����". ������� ������ �� ����������� � ��������� ��������
  ��� ������ � ���������}
 TListenerThread = class(TThread)
 private
  FSocket:     TTCPBlockSocket;//������ ������
  FThreadList: TList;
  procedure ClearFinishedThreads;
  //������ ������������ ������� ��� ������ � ���������
 protected
  procedure Execute; override;
 public
  constructor Create(ASyspended: boolean{; const AIP,APort: string});
  destructor Destroy; override;
  property Socket: TTCPBlockSocket Read FSocket;
 end;

 //����� ��� ������ � ��������� ��������
 TTCPThread = class(TThread)
 private
  FSocket: TTCPBlockSocket;
  {������������ ���������� �� ������� ������ � ���������� �� �������}
  procedure ProcessingData(const AData: string);
 protected
  procedure Execute; override;
 public
  //ASocket - ���������� ������ �� ������� �����������.
  constructor Create(ASyspended: boolean; ASocket: integer);
  destructor Destroy; override;
  property Socket: TTCPBlockSocket Read FSocket;
 end;

type
 Tfmain = class(TForm)
  Label1:    TLabel;
  lbAddress: TLabel;
  Button1:   TButton;
  memLog:    TMemo;
  procedure Button1Click(Sender: TObject);
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
 private
  Server: TListenerThread;
  procedure ServerStatus(Sender: TObject; Reason: THookSocketReason; const Value: string);
 public
  { Public declarations }
 end;

var
 fmain: Tfmain;

implementation

uses StrUtils;

{$R *.dfm}

procedure Tfmain.Button1Click(Sender: TObject);
begin
 if Button1.Caption = rsStart then
 begin
  Server := TListenerThread.Create(True);
  Server.Socket.OnStatus := ServerStatus;
  Server.Socket.SetLinger(True, 10);
  Server.Start;
  Button1.Caption := rsStop;
 end
 else
 begin
  Server.Terminate;
  Server.WaitFor;
  FreeAndNil(Server);
  Button1.Caption := rsStart;
 end;
end;

{ TListenerThread }

constructor TListenerThread.Create(ASyspended: boolean);
begin
 FSocket := TTCPBlockSocket.Create;
 FThreadList := TList.Create;
 inherited Create(ASyspended);
end;

destructor TListenerThread.Destroy;
var
 T: TTCPThread;
begin
 //��������� ��� ���������� ������
 FThreadList.Pack;
 while FThreadList.Count > 0 do
 begin
  T := TTCPThread(FThreadList.Extract(FThreadList.Last));
  T.Terminate;
  T.WaitFor;
  T.Free;
 end;
 //����������� ������
 FThreadList.Free;
 FSocket.Free;
 inherited;
end;

procedure TListenerThread.ClearFinishedThreads;
var
 i: integer;
begin
 for i := 0 to FThreadList.Count - 1 do
  if (TTCPThread(FThreadList[i]) <> nil) and TTCPThread(FThreadList[i]).Finished then
  begin
   TTCPThread(FThreadList[i]).Free;
   FThreadList[i] := nil;
  end;
end;

procedure TListenerThread.Execute;
var
 T: TTCPThread;
begin
 FSocket.CreateSocket;//������� ����� �����
 //��������� ����� � ��������� �������
 //����� ������ ����� ��������� �� ���������� Synapse
 FSocket.Bind('127.0.0.1', '104');
 if FSocket.LastError = 0 then //����������� � ��������� ������� ������ �������
  FSocket.Listen //��������� � ����� ��������
 else
  raise Exception.Create(FSocket.LastErrorDesc);
 //������ ���������� - ���������� � ������������
 repeat
  if FSocket.CanRead(100) then //����� ���������� ������
  begin
   //�������� ���������� ������ � ������� ����� ����� ��� �������
   T := TTCPThread.Create(True, FSocket.Accept);
   //���������� ���������� ������� ONStatus ��� ������ ������
   T.Socket.OnStatus := FSocket.OnStatus;
   //��������� ��������� �� ����� � ������
   FThreadList.Add(pointer(T));
   //��������� ����� �� ����������
   T.Start;
  end;
  ClearFinishedThreads;
 until Terminated;
 //"������" �� ����� �� ��� ���, ���� ������������ �� ���������
 FSocket.CloseSocket;
end;

procedure Tfmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if Assigned(Server) then
 begin
  Server.Terminate;
  Server.WaitFor;
  Server.Free;
 end;
end;

procedure Tfmain.ServerStatus(Sender: TObject; Reason: THookSocketReason; const Value: string);
begin
 case Reason of
  HR_Bind:
  begin
   memLog.Lines.Add('Bind: ' + Value);
   lbAddress.Caption := Server.Socket.GetLocalSinIP + ':' + IntToStr(Server.Socket.GetLocalSinPort);
  end;
  HR_CanRead: memLog.Lines.Add('Can Read');
  HR_CanWrite: memLog.Lines.Add('Can Write');
  HR_Listen: memLog.Lines.Add('Listen');
  HR_Accept: memLog.Lines.Add('Accept ' + Server.Socket.GetRemoteSinIP);
  HR_ReadCount: memLog.Lines.Add('Read Count ' + Value);
  HR_WriteCount: memLog.Lines.Add('Write Count ' + Value);
  HR_Wait: memLog.Lines.Add('Wait');
  HR_Error: memLog.Lines.Add('Error ' + Server.Socket.LastErrorDesc);
  HR_SocketClose:
  begin
   memLog.Lines.Add('Socket close');
   if Sender is TTCPBlockSocket then
    TTCPBlockSocket(Sender).Disconnected := True;
  end;
 end;
end;

{ TTCPThread }

constructor TTCPThread.Create(ASyspended: boolean; ASocket: integer);
begin
 FSocket := TTCPBlockSocket.Create;
 FSocket.Socket := ASocket;
 FSocket.GetSins;
 inherited Create(ASyspended);
end;

destructor TTCPThread.Destroy;
begin
 FSocket.Free;
 inherited;
end;

function IsSocketDisconnected(ASocket: TTCPBlockSocket): boolean;
begin
 Result := (ASocket.Socket = INVALID_SOCKET) or ((ASocket.WaitingData = 0) and ASocket.CanRead(0));
end;

procedure TTCPThread.Execute;
var
 S: string;
begin
 //�������� ���� �� �������� ������ �� ���������
 while not Terminated do
 begin
  //���� ������ ��������� ������
  if FSocket.WaitingData > 0 then
  begin
   //�������� ������
   s := FSocket.RecvPacket(2000);
   //������ ��� ��������� ������ �� ����
   if FSocket.LastError = 0 then
    ProcessingData(S);//������������ ������
  end;
  if FSocket.Disconnected or IsSocketDisconnected(FSocket) then
   Break;
  Sleep(10);//"����" 10 �����������
 end;
end;

procedure TTCPThread.ProcessingData(const AData: string);
begin
 //���� �����-�� �����
 if Length(AData) > 0 then
  FSocket.SendString(ReverseString(AData));
 //�������������� ������ � ���������� ������� �������
end;

initialization
 ReportMemoryLeaksOnShutdown := True;

end.
