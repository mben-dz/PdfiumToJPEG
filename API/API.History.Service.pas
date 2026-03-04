unit API.History.Service;

interface

uses
  API.Interfaces, API.History.Repository, System.SysUtils;

type
  THistoryService = class(TInterfacedObject, iHistoryService)
  private
    FRepository: iHistoryRepository;
  public
    constructor Create;
    procedure LogConversion(const aFileName: string; aPageCount: Integer; const aOutputFolder: string);
    function GetHistory: TArray<THistoryRecord>;
  end;

implementation

constructor THistoryService.Create;
begin
  FRepository := THistoryRepository.Create;
end;

procedure THistoryService.LogConversion(const aFileName: string; aPageCount: Integer; const aOutputFolder: string);
var
  LRecord: THistoryRecord;
begin
  LRecord.FileName := aFileName;
  LRecord.PageCount := aPageCount;
  LRecord.ConversionDate := Now;
  LRecord.OutputFolder := aOutputFolder;
  FRepository.Add(LRecord);
end;

function THistoryService.GetHistory: TArray<THistoryRecord>;
begin
  Result := FRepository.GetAll;
end;

end.
