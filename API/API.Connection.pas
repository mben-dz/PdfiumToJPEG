unit API.Connection;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait,
  Data.DB,
  FireDAC.Comp.Client;

type
  TDMConnection = class(TDataModule)
    FDConnection: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure SetupDatabase;
  public
    function GetConnection: TFDConnection;
  end;

var
  DMConnection: TDMConnection;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses System.IOUtils;

procedure TDMConnection.DataModuleCreate(Sender: TObject);
begin
  SetupDatabase;
end;

function TDMConnection.GetConnection: TFDConnection;
begin
  Result := FDConnection;
end;

procedure TDMConnection.SetupDatabase;
var
  LDBPath: string;
begin
  LDBPath := TPath.Combine(TPath.GetDocumentsPath, 'PdfToJPEG_MBen.db');
  FDConnection.Params.Clear;
  FDConnection.Params.Add('DriverID=SQLite');
  FDConnection.Params.Add('Database=' + LDBPath);
  FDConnection.Connected := True;

  FDConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS ConversionHistory (' +
    '  Id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    '  FileName TEXT, ' +
    '  PageCount INTEGER, ' +
    '  ConversionDate DATETIME, ' +
    '  OutputFolder TEXT' +
    ')');
end;

end.
