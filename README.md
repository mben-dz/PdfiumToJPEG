# PdfToJPEG

A cross-platform desktop application built with **Delphi FMX** that converts PDF files into high-quality JPEG images — one image per page — with a live preview, conversion history, and a clean tabbed UI.

---

## ✨ Features

- 📄 **PDF to JPEG conversion** — renders each PDF page as a full-resolution JPEG image
- 🖼️ **Live preview panel** — thumbnail previews appear in real-time as pages are converted
- 📊 **Conversion history** — every conversion is logged to a local SQLite database and displayed in a sortable grid
- ⚙️ **2× render resolution** — pages are rendered at double size for sharper output
- 🔄 **Background threading** — conversion runs on a background thread; the UI stays responsive throughout
- 🗄️ **SQLite persistence** — history is stored locally via FireDAC, no server required
- 🧱 **Clean layered architecture** — separated into Interfaces, Repository, Service, and Extractor units

---

## 🖥️ Video:

https://github.com/user-attachments/assets/be72af91-79ad-42ab-92e0-861011d52d12

---

## 🏗️ Architecture

The project follows a layered architecture with interface-based dependency injection:

```
┌─────────────────────────────────┐
│          Main.View (FMX UI)     │
└────────────┬────────────────────┘
             │
     ┌───────▼────────┐
     │  iHistoryService│  ◄──  THistoryService
     └───────┬─────────┘
             │
     ┌───────▼──────────────┐
     │  iHistoryRepository  │  ◄──  THistoryRepository (FireDAC / SQLite)
     └──────────────────────┘

     ┌──────────────────┐
     │  iPdfExtractor   │  ◄──  TPdfExtractor (pdfium.dll)
     └──────────────────┘

     ┌──────────────────┐
     │  API.Pdfium.Core │  ◄──  Dynamic DLL loader for pdfium
     └──────────────────┘

     ┌──────────────────┐
     │  API.Connection  │  ◄──  TDMConnection (FireDAC DataModule)
     └──────────────────┘
```

### Unit Overview

| Unit | Responsibility |
|---|---|
| `Main.View` | FMX form — UI, user interaction, threading |
| `API.Interfaces` | Shared types, records, and interface definitions |
| `API.Connection` | FireDAC DataModule; creates and exposes the SQLite connection |
| `API.Pdfium.Core` | Dynamically loads `pdfium.dll` and exposes its function pointers |
| `API.PdfExtractor` | Implements `iPdfExtractor`; renders PDF pages to JPEG via pdfium |
| `API.History.Repository` | Implements `iHistoryRepository`; raw SQLite read/write |
| `API.History.Service` | Implements `iHistoryService`; business logic over the repository |

---

## 🚀 Getting Started

### Prerequisites

- [Delphi](https://www.embarcadero.com/products/delphi) (tested with Delphi 12.3.3.3 Athens)
- FireMonkey (FMX) — included with Delphi
- FireDAC with SQLite driver — included with Delphi
- `pdfium.dll` — see [below](https://github.com/bblanchon/pdfium-binaries)

### Getting pdfium.dll

The app depends on Google's [PDFium](https://pdfium.googlesource.com/pdfium/) library for rendering.

1. Download a pre-built Windows binary from [bblanchon/pdfium-binaries](https://github.com/bblanchon/pdfium-binaries)
2. Extract and place `pdfium.dll` in the same folder as your compiled executable
3. The app will show a warning on startup if the DLL is missing — conversion will be disabled

### Build & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/PdfToJPEG.git
   ```
2. Open `PdfToJPEG.dproj` in Delphi
3. Build and run (`F9`)
4. Place `pdfium.dll` next to the compiled `.exe`

---

## 📖 Usage

1. Click **Browse** and select a PDF file
2. The output folder defaults to `Pages_Output` (relative to the exe); change it if needed
3. Click **Convert**
4. Watch the **Preview** tab populate with thumbnails as pages are rendered
5. Switch to the **History** tab to see a log of all past conversions

Output files are saved as `Page_1.jpg`, `Page_2.jpg`, etc. inside the chosen output folder.

---

## 🗄️ Database

Conversion history is stored in a SQLite database file at:

```
%DOCUMENTS%\PdfToJPEG_MBen.db
```

Schema:

```sql
CREATE TABLE ConversionHistory (
  Id             INTEGER PRIMARY KEY AUTOINCREMENT,
  FileName       TEXT,
  PageCount      INTEGER,
  ConversionDate DATETIME,
  OutputFolder   TEXT
);
```

---

## 📁 Project Structure

```
PdfToJPEG/
├── PdfToJPEG.dpr          # Project file
├── Main.View.pas           # Main FMX form
├── Main.View.fmx           # Form layout
├── API/
│   ├── API.Connection.pas          # FireDAC DataModule
│   ├── API.Interfaces.pas          # Interfaces & shared types
│   ├── API.Pdfium.Core.pas         # pdfium.dll loader
│   ├── API.PdfExtractor.pas        # PDF → JPEG renderer
│   ├── API.History.Repository.pas  # SQLite repository
│   └── API.History.Service.pas     # History service
└── README.md
```

---

## 🤝 Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgements

- [PDFium](https://pdfium.googlesource.com/pdfium/) — PDF rendering engine by Google
- [bblanchon/pdfium-binaries](https://github.com/bblanchon/pdfium-binaries) — pre-built PDFium Windows binaries
- [Embarcadero Delphi](https://www.embarcadero.com/products/delphi) — RAD IDE and FMX framework
