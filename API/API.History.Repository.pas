unit API.History.Repository;

interface

uses
  API.Interfaces,
  API.Connection,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  System.SysUtils,
  Data.DB;

type
  THistoryRepository = class(TInterfacedObject, iHistoryRepository)
  public
    procedure Add(const aRecord: THistoryRecord);
    function GetAll: TArray<THistoryRecord>;
  end;

implementation

procedure THistoryRepository.Add(const aRecord: THistoryRecord);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := DMConnection.GetConnection;
    LQuery.SQL.Text :=
      'INSERT INTO ConversionHistory (FileName, PageCount, ConversionDate, OutputFolder) ' +
      'VALUES (:FileName, :PageCount, :ConversionDate, :OutputFolder)';
    LQuery.ParamByName('FileName').AsString := aRecord.FileName;
    LQuery.ParamByName('PageCount').AsInteger := aRecord.PageCount;
    LQuery.ParamByName('ConversionDate').AsDateTime := aRecord.ConversionDate;
    LQuery.ParamByName('OutputFolder').AsString := aRecord.OutputFolder;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function THistoryRepository.GetAll: TArray<THistoryRecord>;
var
  LQuery: TFDQuery;
  LCount: Integer;
begin
  SetLength(Result, 0);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := DMConnection.GetConnection;
    LQuery.SQL.Text := 'SELECT * FROM ConversionHistory ORDER BY Id DESC';
    LQuery.Open;

    LCount := 0;
    while not LQuery.Eof do
    begin
      SetLength(Result, LCount + 1);
      Result[LCount].Id := LQuery.FieldByName('Id').AsInteger;
      Result[LCount].FileName := LQuery.FieldByName('FileName').AsString;
      Result[LCount].PageCount := LQuery.FieldByName('PageCount').AsInteger;
      Result[LCount].ConversionDate := LQuery.FieldByName('ConversionDate').AsDateTime;
      Result[LCount].OutputFolder := LQuery.FieldByName('OutputFolder').AsString;
      Inc(LCount);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

end.
