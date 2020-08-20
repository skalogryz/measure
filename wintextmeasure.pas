unit wintextmeasure;

interface

uses
  winfonttools, textmeasure;

type

  { TWinTextAPI }

  TWinTextAPI = class(TSysTextAPI)
    winmsr: TWinMeasure;
    constructor Create;
    destructor Destroy; override;
    function MeasureText(const text: WideString; const fnt: TFontInfo): TFloatSize; override;
  end;

implementation

{ TWinTextAPI }

constructor TWinTextAPI.Create;
begin
  inherited Create;
  winmsr := TWinMeasure.Create;
end;

destructor TWinTextAPI.Destroy;
begin
  winmsr.Free;
  inherited Destroy;
end;

function TWinTextAPI.MeasureText(const text: WideString; const fnt: TFontInfo): TFloatSize;
var
  f : TWinFontRecord;
  res : TPtSize;
begin
  if (winmsr.fonts.Count = 0) then winmsr.RefreshFonts;
  f := winmsr.FindFont(fnt.Name);
  if not Assigned(f) then begin
    Result.cx:=0;
    Result.cy:=0;
    Exit;
  end;
  res := winmsr.MeasureText(text, f, fnt.Size);
  Result.cx := res.cx;
  Result.cy := res.cy;
end;

initialization
  RegisteSysTextAPI(TWinTextAPI.Create)

end.
