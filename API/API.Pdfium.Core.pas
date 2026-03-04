unit API.Pdfium.Core;

interface

uses
  System.SysUtils, Winapi.Windows;

type
  FPDF_DOCUMENT = Pointer;
  FPDF_PAGE = Pointer;
  FPDF_BITMAP = Pointer;

var
  FPDF_InitLibrary: procedure; cdecl;
  FPDF_DestroyLibrary: procedure; cdecl;
  FPDF_LoadDocument: function(file_path: PAnsiChar; password: PAnsiChar): FPDF_DOCUMENT; cdecl;
  FPDF_CloseDocument: procedure(document: FPDF_DOCUMENT); cdecl;
  FPDF_GetPageCount: function(document: FPDF_DOCUMENT): Integer; cdecl;
  FPDF_LoadPage: function(document: FPDF_DOCUMENT; page_index: Integer): FPDF_PAGE; cdecl;
  FPDF_ClosePage: procedure(page: FPDF_PAGE); cdecl;
  FPDF_GetPageWidth: function(page: FPDF_PAGE): Double; cdecl;
  FPDF_GetPageHeight: function(page: FPDF_PAGE): Double; cdecl;
  FPDFBitmap_Create: function(width, height: Integer; alpha: Integer): FPDF_BITMAP; cdecl;
  FPDFBitmap_FillRect: procedure(bitmap: FPDF_BITMAP; left, top, width, height: Integer; color: Cardinal); cdecl;
  FPDF_RenderPageBitmap: procedure(bitmap: FPDF_BITMAP; page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer; rotate: Integer; flags: Integer); cdecl;
  FPDFBitmap_GetBuffer: function(bitmap: FPDF_BITMAP): Pointer; cdecl;
  FPDFBitmap_GetStride: function(bitmap: FPDF_BITMAP): Integer; cdecl;
  FPDFBitmap_Destroy: procedure(bitmap: FPDF_BITMAP); cdecl;

function LoadPdfium: Boolean;

implementation

var
  HLib: HMODULE = 0;

function LoadPdfium: Boolean;
begin
  if HLib <> 0 then
    Exit(True);

  HLib := LoadLibrary('pdfium.dll');
  if HLib = 0 then
    Exit(False);

  @FPDF_InitLibrary := GetProcAddress(HLib, 'FPDF_InitLibrary');
  @FPDF_DestroyLibrary := GetProcAddress(HLib, 'FPDF_DestroyLibrary');
  @FPDF_LoadDocument := GetProcAddress(HLib, 'FPDF_LoadDocument');
  @FPDF_CloseDocument := GetProcAddress(HLib, 'FPDF_CloseDocument');
  @FPDF_GetPageCount := GetProcAddress(HLib, 'FPDF_GetPageCount');
  @FPDF_LoadPage := GetProcAddress(HLib, 'FPDF_LoadPage');
  @FPDF_ClosePage := GetProcAddress(HLib, 'FPDF_ClosePage');
  @FPDF_GetPageWidth := GetProcAddress(HLib, 'FPDF_GetPageWidth');
  @FPDF_GetPageHeight := GetProcAddress(HLib, 'FPDF_GetPageHeight');
  @FPDFBitmap_Create := GetProcAddress(HLib, 'FPDFBitmap_Create');
  @FPDFBitmap_FillRect := GetProcAddress(HLib, 'FPDFBitmap_FillRect');
  @FPDF_RenderPageBitmap := GetProcAddress(HLib, 'FPDF_RenderPageBitmap');
  @FPDFBitmap_GetBuffer := GetProcAddress(HLib, 'FPDFBitmap_GetBuffer');
  @FPDFBitmap_GetStride := GetProcAddress(HLib, 'FPDFBitmap_GetStride');
  @FPDFBitmap_Destroy := GetProcAddress(HLib, 'FPDFBitmap_Destroy');

  if Assigned(FPDF_InitLibrary) then
    FPDF_InitLibrary;

  Result := True;
end;

initialization
finalization
  if HLib <> 0 then
  begin
    if Assigned(FPDF_DestroyLibrary) then
      FPDF_DestroyLibrary;
    FreeLibrary(HLib);
  end;

end.
