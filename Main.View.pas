unit Main.View;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Layouts,
  FMX.TabControl,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.Grid,
  FMX.Objects,
  System.Threading,
  System.IOUtils,
  API.Interfaces,
  API.Pdfium.Core,
  API.PdfExtractor,
  API.History.Service,
  System.Rtti;

const
  cPages_OutputFolder = 'Pages_Output';

type
  TMainView = class(TForm)
    LayoutTop: TLayout;
    lblPdf: TLabel;
    edtPdfPath: TEdit;
    btnBrowsePdf: TButton;
    lblOutput: TLabel;
    edtOutputPath: TEdit;
    BtnConvert: TButton;
    pbProgress: TProgressBar;
    lblProgress: TLabel;
    TabControl1: TTabControl;
    TabPreview: TTabItem;
    TabHistory: TTabItem;
    FlowLayout: TFlowLayout;
    StrGrid: TStringGrid;
    dlgOpen: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowsePdfClick(Sender: TObject);
    procedure BtnConvertClick(Sender: TObject);
  private
    procedure SetupGrid;
    procedure LoadHistory;
    procedure OnProgress(const aCurrent, aTotal: Integer; const aFileName: string);
  public
  end;

var
  MainView: TMainView;

implementation

{$R *.fmx}

procedure TMainView.FormCreate(Sender: TObject);
begin
  SetupGrid;
  LoadHistory;
  if not LoadPdfium then
    ShowMessage('pdfium.dll not found. Please place it in the application folder to enable conversion.');
end;

procedure TMainView.SetupGrid;
var
  LCol: TStringColumn;
begin
  StrGrid.ClearColumns;

  LCol := TStringColumn.Create(StrGrid);
  LCol.Header := 'ID';
  LCol.Width := 50;
  StrGrid.AddObject(LCol);

  LCol := TStringColumn.Create(StrGrid);
  LCol.Header := 'File Name';
  LCol.Width := 200;
  StrGrid.AddObject(LCol);

  LCol := TStringColumn.Create(StrGrid);
  LCol.Header := 'Pages';
  LCol.Width := 60;
  StrGrid.AddObject(LCol);

  LCol := TStringColumn.Create(StrGrid);
  LCol.Header := 'Date';
  LCol.Width := 150;
  StrGrid.AddObject(LCol);

  LCol := TStringColumn.Create(StrGrid);
  LCol.Header := 'Output Folder';
  LCol.Width := 300;
  StrGrid.AddObject(LCol);
end;

procedure TMainView.LoadHistory;
var
  LService: iHistoryService;
  LHistory: TArray<THistoryRecord>;
  i: Integer;
begin
  LService := THistoryService.Create;
  LHistory := LService.GetHistory;

  StrGrid.RowCount := Length(LHistory);
  for i := 0 to High(LHistory) do
  begin
    StrGrid.Cells[0, i] := LHistory[i].Id.ToString;
    StrGrid.Cells[1, i] := TPath.GetFileName(LHistory[i].FileName);
    StrGrid.Cells[2, i] := LHistory[i].PageCount.ToString;
    StrGrid.Cells[3, i] := DateTimeToStr(LHistory[i].ConversionDate);
    StrGrid.Cells[4, i] := LHistory[i].OutputFolder;
  end;
end;

procedure TMainView.btnBrowsePdfClick(Sender: TObject);
begin
  dlgOpen.Filter := 'PDF Files (*.pdf)|*.pdf';
  if dlgOpen.Execute then
  begin
    edtPdfPath.Text := dlgOpen.FileName;
    edtOutputPath.Text := TPath.Combine(TPath.GetDirectoryName(dlgOpen.FileName), cPages_OutputFolder);
  end;
end;

procedure TMainView.OnProgress(const aCurrent, aTotal: Integer; const aFileName: string);
begin
  TThread.Queue(nil,
    procedure
    var
      LImage: TImage;
    begin
      pbProgress.Max := aTotal;
      pbProgress.Value := aCurrent;
      lblProgress.Text := Format('Converting %d of %d...', [aCurrent, aTotal]);

      LImage := TImage.Create(FlowLayout);
      LImage.Parent := FlowLayout;
      LImage.Width := 150;
      LImage.Height := 200;
      LImage.Margins.Rect := TRectF.Create(5,5,5,5);
      LImage.WrapMode := TImageWrapMode.Fit;
      LImage.Bitmap.LoadFromFile(aFileName);
    end);
end;

procedure TMainView.BtnConvertClick(Sender: TObject);
var
  LPdfPath, LOutPath: string;
begin
  LPdfPath := edtPdfPath.Text;
  LOutPath := edtOutputPath.Text;

  if not FileExists(LPdfPath) then
  begin
    ShowMessage('Please select a valid PDF file.');
    Exit;
  end;

  btnConvert.Enabled := False;

  // Clear preview
  for var i := FlowLayout.ChildrenCount - 1 downto 0 do
    FlowLayout.Children[i].Free;

  pbProgress.Value := 0;

  TTask.Run(
    procedure
    var
      LExtractor: iPdfExtractor;
      LService: iHistoryService;
      LCount: Integer;
    begin
      try
        LExtractor := TPdfExtractor.Create;
        LCount := LExtractor.GetPageCount(LPdfPath);

        if LExtractor.ExtractToJpeg(LPdfPath, LOutPath, OnProgress) then
        begin
          LService := THistoryService.Create;
          LService.LogConversion(LPdfPath, LCount, LOutPath);

          TThread.Queue(nil,
            procedure
            begin
              ShowMessage('Conversion complete!');
              LoadHistory;
              TabControl1.ActiveTab := TabPreview;
            end);
        end;
      finally
        TThread.Queue(nil,
          procedure
          begin
            btnConvert.Enabled := True;
          end);
      end;
    end);
end;

end.
