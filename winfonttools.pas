unit winfonttools;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils;

type

  { TWinFontRecord }

  TWinFontRecord = class(TObject)
  public
    logfont  : TLogFontW;
    metrics  : TNEWTEXTMETRICEXW;
    fileName : WideString; // todo?
    name     : WideString;
    destructor Destroy; override;
  end;

  TWinFont = class(TObject)
  end;

  TPtSize = record
    cx : double;
    cy : double;
  end;


  { TWinMeasure }

  TWinMeasure = class(TObject)
  protected
    function SelectFont(fnt: TWinFontRecord; sizePt: double): Boolean;
  public
    dc     : HDC;
    PtToLog : double;
    LogToPt : double;
    fonts  : TList;
    lastf  : HFont;
    lastlogf : TLogFontW;
    constructor Create;
    destructor Destroy; override;
    procedure RefreshFonts;
    procedure ClearFonts;
    function FindFont(const fntName: WideString): TWinFontRecord; // case-sensitive
    function MeasureText(const text: WideString; const fnt: TWinFontRecord; sizePt: double): TPtSize;
  end;

implementation

function isSameLogFont(const a,  b: TLogFontW): Boolean;
begin
  Result := CompareMem(@a, @b, sizeof(a));
end;

{ TWinFontRecord }

destructor TWinFontRecord.Destroy;
begin
  inherited Destroy;
end;

{ TWinMeasure }

function TWinMeasure.SelectFont(fnt: TWinFontRecord; sizePt: double): Boolean;
var
  f : HFONT;
  lf : TLogFontW;
  pf : HFONT;
begin
  FillChar(lf, sizeof(lf), 0);
  lf.lfFaceName := fnt.logfont.lfFaceName;
  lf.lfWidth := 0;
  lf.lfHeight := -Round(sizePt * PtToLog);

  f := CreateFontIndirectW(lf);
  pf := SelectObject(dc, f);
  if (pf <> 0) and (pf <> INVALID_HANDLE_VALUE) then
    DeleteObject(pf);
  lastf := f;
  lastlogf := lf;
  Result := true;
end;

constructor TWinMeasure.Create;
var
  mm : integer;
const
  TextScale = 1.0; // for better accuracy, it's possible to scale the font
                   // However, due to rounding the scale font might give different results
                   // Then an attempt to draw the text
begin
  inherited Create;
  fonts:=TList.Create;
  //dc := CreateDCW('DISPLAY', nil, nil, nil);
  dc := CreateCompatibleDC(0);
  //SetGraphicsMode(dc, GM_ADVANCED);
  writeln( GetDeviceCaps(dc, LOGPIXELSX ));
  mm := GetMapMode(dc);
  //writeln('mm = ', mm);
  case mm of
    { Logical units are mapped to arbitrary units with equally scaled axes;
      that is, one unit along the x-axis is equal to one unit along the y-axis.
      Use the SetWindowExtEx and SetViewportExtEx functions to specify
      the units and the orientation of the axes. Graphics device interface
      makes adjustments as necessary to ensure the x and y units remain
      the same size. (When the windows extent is set, the viewport will be
      adjusted to keep the units isotropic).}
    MM_ISOTROPIC,
      { Logical units are mapped to arbitrary units with arbitrarily scaled axes.
        Use the SetWindowExtEx and SetViewportExtEx functions to specify the units,
        orientation, and scaling required. }
    MM_ANISOTROPIC: begin
      SetWindowExtEx(dc, 20, 20, nil);
      PtToLog := 20;
    end;

    { Each logical unit is mapped to 0.001 inch.
      Positive x is to the right; positive y is up. }
    MM_HIENGLISH: PtToLog := (1 / 72) / 0.001;

    { Each logical unit is mapped to 0.01 inch. Positive x is to the right; positive y is up. }
    MM_LOENGLISH: PtToLog := (1 / 72) / 0.01;

    { Each logical unit is mapped to 0.01 millimeter. Positive x is to the right; positive y is up. }
    //MM_HIMETRIC:

    { Each logical unit is mapped to 0.1 millimeter. Positive x is to the right; positive y is up. }
    //MM_LOMETRIC: PtToLog := 72 / GetDeviceCaps(dc, LOGPIXELSY);

    { Each logical unit is mapped to one device pixel.
      Positive x is to the right; positive y is down. }
    MM_TEXT: PtToLog := GetDeviceCaps(dc, LOGPIXELSY) / 72 * TextScale;

    { Each logical unit is mapped to one twentieth of a printer's point
      (1/1440 inch, also called a "twip"). Positive x is to the right;
      positive y is up }
    MM_TWIPS: PtToLog := 20;
  else
    PtToLog := 1;
  end;
  LogToPt := 1 / PtToLog;
end;

destructor TWinMeasure.Destroy;
begin
  ClearFonts;
  DeleteDC(dc);
  if lastf <> 0 then DeleteObject(lastf);
  fonts.Free;
  inherited Destroy;
end;

function EnumFontFamExProc(
  var logfont : TEnumLogFontExW;
  var fontmet : TNewTextMetricExW;
  FontType: longint;
  lParam: LPARAM): integer; stdcall;
var
  f  : TWinFontRecord;
  m  : TWinMeasure;
begin
  Result := 1;
  if FontType <> TRUETYPE_FONTTYPE then Exit; // only allow true type

  m := TWinMeasure(lParam);

  f := TWinFontRecord.Create;
  f.logfont := logfont.elfLogFont;
  f.metrics := fontmet;
  f.name := logfont.elfFullName;
  m.fonts.Add(f);
end;

procedure TWinMeasure.RefreshFonts;
var
  log : TLogFontW;
begin
  ClearFonts;
  FillChar(log, sizeof(log), 0);
  EnumFontFamiliesExW(dc, log, @EnumFontFamExProc, LPARAM(Self), 0);
end;

procedure TWinMeasure.ClearFonts;
var
  i : integer;
begin
  for i:=0 to fonts.Count-1 do
    TObject(fonts[i]).Free;
  fonts.Clear;
end;

function TWinMeasure.FindFont(const fntName: WideString): TWinFontRecord;
var
  i : integer;
begin
  for i:=0 to fonts.Count-1 do begin
    Result := TWinFontRecord(fonts[i]);
    if Result.name = fntName then Exit;
  end;
  Result := nil;
end;

function TWinMeasure.MeasureText(const text: WideString;
  const fnt: TWinFontRecord; sizePt: double): TPtSize;
var
  sz : TSize;
begin
  SelectFont(fnt, sizePt);
  sz.cx := 0;
  sz.cy := 0;
  if length(text)>0 then
    if not GetTextExtentPoint32W(dc, @text[1], length(text), @sz) then
    begin
      Result.cx := -1;
      Result.cy := -1;
      Exit;
    end;
  Result.cx := sz.cx * LogToPt;
  Result.cy := sz.cy * LogToPt;
end;

end.

