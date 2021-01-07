unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, blcksock, Vcl.StdCtrls;

resourcestring
  rsConnected = '����������';

const
  cReadTimeout = 10000;

type
  Tfmain = class(TForm)
    Label1: TLabel;
    edAddress: TEdit;
    Label2: TLabel;
    edPort: TEdit;
    btnConnect: TButton;
    Label3: TLabel;
    edRequestString: TEdit;
    Label4: TLabel;
    lbResponseStr: TLabel;
    dtnSend: TButton;
    Button1: TButton;
    procedure btnConnectClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure dtnSendClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Client: TTCPBlockSocket;
  public
    { Public declarations }
  end;

var
  fmain: Tfmain;

implementation

{$R *.dfm}

procedure Tfmain.btnConnectClick(Sender: TObject);
begin
  Client:=TTCPBlockSocket.Create;//������� ������
  Client.RaiseExcept:=True;//���������� ��� ���������� Winsock
  Client.Connect(edAddress.Text,edPort.Text);//������� ����������� � ��������
  ShowMessage(rsConnected);
end;

procedure Tfmain.Button1Click(Sender: TObject);
begin
 Client.CloseSocket;
end;

procedure Tfmain.dtnSendClick(Sender: TObject);
begin
  Client.SendString(edRequestString.Text);//���������� ������ �� ������
  lbResponseStr.Caption:=Client.RecvPacket(cReadTimeout)//������� �������� �����
end;

procedure Tfmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Client.Free;
end;

initialization
  ReportMemoryLeaksOnShutdown:=True;

end.
