unit main;

interface

uses
 Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types, Vcl.Graphics,
 Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, blcksock, winsock;

resourcestring
 rsStart = 'Запустить';
 rsStop  = 'Остановить';

type
  {"Слушающий поток". Ожидает запрос на подключение и управляет потоками
  для работы с клиентами}
 TListenerThread = class(TThread)
 private
  FSocket:     TTCPBlockSocket;//объект сокета
  FThreadList: TList;
  procedure ClearFinishedThreads;
  //список дескрипторов потоков для работы с клиентами
 protected
  procedure Execute; override;
 public
  constructor Create(ASyspended: boolean{; const AIP,APort: string});
  destructor Destroy; override;
  property Socket: TTCPBlockSocket Read FSocket;
 end;

 //Поток для работы с отдельным клиентом
 TTCPThread = class(TThread)
 private
  FSocket: TTCPBlockSocket;
  {Обрабатывает полученные от клиента данные и отправляет их обратно}
  procedure ProcessingData(const AData: string);
 protected
  procedure Execute; override;
 public
  //ASocket - дескриптор сокета из очереди подключений.
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
 //завершаем все работающие потоки
 FThreadList.Pack;
 while FThreadList.Count > 0 do
 begin
  T := TTCPThread(FThreadList.Extract(FThreadList.Last));
  T.Terminate;
  T.WaitFor;
  T.Free;
 end;
 //освобождаем память
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
 FSocket.CreateSocket;//создаем новый сокет
 //связываем сокет с локальным адресом
 //выбор номера порта оставляем на усмотрение Synapse
 FSocket.Bind('127.0.0.1', '104');
 if FSocket.LastError = 0 then //связываение с локальным адресом прошло успешно
  FSocket.Listen //переходим в режим ожидания
 else
  raise Exception.Create(FSocket.LastErrorDesc);
 //ошибка связывания - показываем её пользователю
 repeat
  if FSocket.CanRead(100) then //можем произвести чтение
  begin
   //получаем дескриптор сокета и создаем новый поток для клиента
   T := TTCPThread.Create(True, FSocket.Accept);
   //определяем обработчик события ONStatus для нового потока
   T.Socket.OnStatus := FSocket.OnStatus;
   //добавляем указатель на поток в список
   FThreadList.Add(pointer(T));
   //запускаем поток на выполнение
   T.Start;
  end;
  ClearFinishedThreads;
 until Terminated;
 //"гуляем" по циклу до тех пор, пока пользователь не остановит
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
 //работаем пока не поступит сигнал на остановку
 while not Terminated do
 begin
  //есть данные ожидающие чтения
  if FSocket.WaitingData > 0 then
  begin
   //получаем данные
   s := FSocket.RecvPacket(2000);
   //ошибок при получении данных не было
   if FSocket.LastError = 0 then
    ProcessingData(S);//обрабатываем данные
  end;
  if FSocket.Disconnected or IsSocketDisconnected(FSocket) then
   Break;
  Sleep(10);//"спим" 10 миллисекунд
 end;
end;

procedure TTCPThread.ProcessingData(const AData: string);
begin
 //есть какой-то текст
 if Length(AData) > 0 then
  FSocket.SendString(ReverseString(AData));
 //переворачиваем строку и отправляем обратно клиенту
end;

initialization
 ReportMemoryLeaksOnShutdown := True;

end.
