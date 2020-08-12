program testlayout;

{$mode objfpc}{$H+}

uses
  heaptrc,
  Windows,
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, logtext, papertext, logtextutils, textlayoututils
  ,textmeasure, winfonttools
  { you can add units after this };

procedure FillDocument(doc: TLogDocument);
var
  c : TLogSection;
  p : TLogParagraph;
begin
  c := doc.AddSection;
  p := c.AddParagraph;
  p.AddText('hello');
end;

procedure RunTest;
var
  doc: TLogDocument;
begin
  doc:=TLogDocument.Create;
  try
    FillDocument(doc);
    FillNilFontDoc(doc);

  finally
    doc.Free;
  end;
end;

procedure RunTestSplit(const w: WideString='hello  world');
var
  i : integer;
  s, e: integer;
begin
  i := 1;
  while NextWord(w, i, s, e) do begin
    writeln('"',Copy(w, s, e-s+1),'"');
  end;
end;

procedure RunDC;
var
  m   : TWinMeasure;
  i   : integer;
  wf  : TWinFontRecord;
  arf : TWinFontRecord;
  sz  : TPtSize;
begin
  m := TWinMeasure.Create;
  try
    m.RefreshFonts;
    arf := nil;
    for i:=0 to m.fonts.Count-1 do begin
      wf := TWinFontRecord(m.fonts[i]);
      //writeln( wf.name,' ',wf.logfont.lfHeight,' ', wf.logfont.lfWidth );
      if (UpCase(wf.name) = 'ARIAL') then
      begin
        writeln(wf.name);
        arf := wf;
      end;
    end;
    if Assigned(arf) then begin
      // 22x16
      sz := m.MeasureText('i', arf, 72 );
      writeln('size: ', sz.cx:0:3,' ',sz.cy:0:3) ;
    end;
  finally
    m.Free;
  end;
end;

begin
  //RunTest;
  //RunTestSplit();
  RunDC;
end.

