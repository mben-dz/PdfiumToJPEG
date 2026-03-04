program PdfToJPEG;

uses
  System.StartUpCopy,
  FMX.Forms,
  API.Connection in 'API\API.Connection.pas' {DMConnection: TDataModule},
  Main.View in 'Main.View.pas' {MainView},
  API.Interfaces in 'API\API.Interfaces.pas',
  API.Pdfium.Core in 'API\API.Pdfium.Core.pas',
  API.PdfExtractor in 'API\API.PdfExtractor.pas',
  API.History.Repository in 'API\API.History.Repository.pas',
  API.History.Service in 'API\API.History.Service.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMConnection, DMConnection);
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
