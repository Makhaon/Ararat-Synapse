program Server;

uses
  Vcl.Forms,
  main in 'main.pas' {fmain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfmain, fmain);
  Application.Run;
end.
