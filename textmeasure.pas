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
    Name       : WideString;
    SizeHalfPt : Integer; // size if half points
    Style      : TFontStyle;
  end;

  TTextMeasure = record

  end;

function MeasureText(const text: WideString; const font: TFontInfo; var Res: TTextMeasure): Boolean;

implementation

function MeasureText(const text: WideString; const font: TFontInfo; var Res: TTextMeasure): Boolean;
begin
end;

end.
