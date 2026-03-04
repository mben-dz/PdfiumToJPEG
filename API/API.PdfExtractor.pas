unit API.PdfExtractor;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, FMX.Graphics, API.Interfaces, API.Pdfium.Core;

type
  TPdfExtractor = class(TInterfacedObject, iPdfExtractor)
  public
    function ExtractToJpeg(const aPdfPath, aOutputFolder: string; aOnProgress: TOnProgress = nil): Boolean;
    function GetPageCount(const aPdfPath: string): Integer;
  end;

implementation

function TPdfExtractor.GetPageCount(const aPdfPath: string): Integer;
var
  LDoc: FPDF_DOCUMENT;
  LAnsiPath: UTF8String;
begin
  Result := 0;
  if not Assigned(FPDF_LoadDocument) then Exit;
  
  LAnsiPath := UTF8String(aPdfPath);
  LDoc := FPDF_LoadDocument(PAnsiChar(LAnsiPath), nil);
  if Assigned(LDoc) then
  begin
    Result := FPDF_GetPageCount(LDoc);
    FPDF_CloseDocument(LDoc);
  end;
end;

function TPdfExtractor.ExtractToJpeg(const aPdfPath, aOutputFolder: string; aOnProgress: TOnProgress): Boolean;
var
  LDoc: FPDF_DOCUMENT;
  LPageCount, i: Integer;
  LPage: FPDF_PAGE;
  LWidth, LHeight: Integer;
  LBitmap: FPDF_BITMAP;
  LOutBitmap: TBitmap;
  LMap: TBitmapData;
  LBuffer: Pointer;
  LStride, y: Integer;
  LFileName: string;
  LAnsiPath: UTF8String;
begin
  Result := False;
  if not Assigned(FPDF_LoadDocument) then Exit;

  LAnsiPath := UTF8String(aPdfPath);
  LDoc := FPDF_LoadDocument(PAnsiChar(LAnsiPath), nil);
  if Assigned(LDoc) then
  begin
    try
      LPageCount := FPDF_GetPageCount(LDoc);
      ForceDirectories(aOutputFolder);
      for i := 0 to LPageCount - 1 do
      begin
        LPage := FPDF_LoadPage(LDoc, i);
        if Assigned(LPage) then
        begin
          try
            LWidth := Trunc(FPDF_GetPageWidth(LPage) * 2);
            LHeight := Trunc(FPDF_GetPageHeight(LPage) * 2);
            
            LBitmap := FPDFBitmap_Create(LWidth, LHeight, 0);
            if Assigned(LBitmap) then
            begin
              try
                FPDFBitmap_FillRect(LBitmap, 0, 0, LWidth, LHeight, Cardinal($FFFFFFFF));
                FPDF_RenderPageBitmap(LBitmap, LPage, 0, 0, LWidth, LHeight, 0, 0);
                
                LBuffer := FPDFBitmap_GetBuffer(LBitmap);
                LStride := FPDFBitmap_GetStride(LBitmap);
                
                LOutBitmap := TBitmap.Create;
                try
                  LOutBitmap.SetSize(LWidth, LHeight);
                  if LOutBitmap.Map(TMapAccess.Write, LMap) then
                  begin
                    try
                      for y := 0 to LHeight - 1 do
                      begin
                        Move(PByte(NativeUInt(LBuffer) + NativeUInt(y * LStride))^, 
                             LMap.GetScanline(y)^, LWidth * 4);
                      end;
                    finally
                      LOutBitmap.Unmap(LMap);
                    end;
                  end;
                  LFileName := TPath.Combine(aOutputFolder, Format('Page_%d.jpg', [i + 1]));
                  LOutBitmap.SaveToFile(LFileName);
                  
                  if Assigned(aOnProgress) then
                    aOnProgress(i + 1, LPageCount, LFileName);
                finally
                  LOutBitmap.Free;
                end;
              finally
                FPDFBitmap_Destroy(LBitmap);
              end;
            end;
          finally
            FPDF_ClosePage(LPage);
          end;
        end;
      end;
      Result := True;
    finally
      FPDF_CloseDocument(LDoc);
    end;
  end;
end;

end.
