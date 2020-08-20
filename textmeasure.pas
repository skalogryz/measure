unit textmeasure;

interface

uses
  {$ifdef mswindows}
  Windows,
  {$endif}
  Types;

type
  TFontStyle = set of (fsBold, fsItalic);

  TFontInfo = record
    Name    : WideString;
    Size    : double; // size if half points
    Style   : TFontStyle;
  end;

  TFloatSize = record
    cx : double;
    cy : double;
  end;

  { TSysTextAPI }

  TSysTextAPI = class
    function MeasureText(const text: WideString; const fnt: TFontInfo): TFloatSize; virtual; abstract;
  end;

  TTextMeasure = record
    size : TFloatSize;
  end;

function MeasureText(const text: WideString; const font: TFontInfo; var Res: TTextMeasure): Boolean;

var
  SysTextAPI : TSysTextAPI = nil;

procedure RegisteSysTextAPI(api: TSysTextAPI);

implementation

procedure RegisteSysTextAPI(api: TSysTextAPI);
begin
  if not Assigned(SysTextAPI) then SysTextAPI.Free;
  SysTextAPI := api;
end;

function MeasureText(const text: WideString; const font: TFontInfo; var Res: TTextMeasure): Boolean;
begin
  Result := Assigned(SysTextAPI);
  if not Result then Exit;
  Res.size := SysTextAPI.MeasureText(text, font);
end;

initialization

finalization
  if Assigned(SysTextAPI) then SysTextAPI.Free;

end.
