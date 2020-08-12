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
begin
  inherited Create;
  fonts:=TList.Create;
  dc := CreateDCW('DISPLAY', nil, nil, nil);

  SetMapMode(dc, MM_TWIPS);
  PtToLog := 20; // from points to
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

