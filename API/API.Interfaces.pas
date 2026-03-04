unit API.Interfaces;

interface

uses
  System.Generics.Collections;

type
  TOnProgress = reference to procedure(const aCurrent, aTotal: Integer; const aFileName: string);

  THistoryRecord = record
    Id: Integer;
    FileName: string;
    PageCount: Integer;
    ConversionDate: TDateTime;
    OutputFolder: string;
  end;

  iPdfExtractor = interface
    ['{CE615C9C-47E4-48E6-B9D4-5EB188CAAB1B}']
    function ExtractToJpeg(const aPdfPath, aOutputFolder: string; aOnProgress: TOnProgress = nil): Boolean;
    function GetPageCount(const aPdfPath: string): Integer;
  end;

  iHistoryRepository = interface
    ['{B839AF17-A6C1-4D0C-B0DB-DCB6A4C62622}']
    procedure Add(const aRecord: THistoryRecord);
    function GetAll: TArray<THistoryRecord>;
  end;

  iHistoryService = interface
    ['{2DBBA1A4-0B96-4F4B-AEB1-1A4C4EA27B04}']
    procedure LogConversion(const aFileName: string; aPageCount: Integer; const aOutputFolder: string);
    function GetHistory: TArray<THistoryRecord>;
  end;

implementation

end.
