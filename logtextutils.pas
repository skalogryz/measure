unit logtextutils;

{$ifdef fpc}{$mode delphi}{$H+}{$endif}

interface

uses
  logtext;

procedure FillNilFont(l: TLogText; defFont: TLogFont);
procedure FillNilFontPara(p: TLogParagraph; defFont: TLogFont);
procedure FillNilFontDoc(l: TLogDocument; defFont: TLogFont = nil);

implementation

procedure FillNilFont(l: TLogText; defFont: TLogFont);
begin
  while Assigned(l) do begin
    if not Assigned(l.style) and not Assigned(l.font) then
      l.font := defFont;
    l:=l.next;
  end;
end;

procedure FillNilFontPara(p: TLogParagraph; defFont: TLogFont);
begin
  while Assigned(p) do begin
    FillNilFont(p.firstText, defFont);
    p:=p.next;
  end;
end;

procedure FillNilFontDoc(l: TLogDocument; defFont: TLogFont);
var
  f : TLogFont;
  s : TLogSection;
begin
  if not Assigned(l) or not Assigned(l.section) then Exit;

  if l.fonts.Count=0 then begin
    f := l.AddFont;
    f.name := 'Arial';
    f.size := 10;
  end else
    f := TLogFont(l.fonts[0]);

  s := l.section;
  while (s<>nil) do begin
    FillNilFontPara(s.par, f);
    s := s.next;
  end;
end;

end.
