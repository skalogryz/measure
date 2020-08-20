unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Types,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Math, Win32Int,

  wintextmeasure,
  textmeasure,
  textlayoututils;

type
  TTextElement = class(TObject)
    subText    : WideString;
    isSpace    : Boolean;
    spaceCount : Integer;
    sizeInfo   : TTextMeasure;
    left       : double;
    top        : double;
    next       : TTextElement;
  end;
  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    function PtToPixel(p: double): Integer;
  public
    line : TTextElement;
    procedure ProcessText(const txt: string);
    function SplitText(const wS: WideString): TTextElement;
    procedure MeasureElements(el: TTextElement);
    procedure PlaceText(el: TTextElement; ptWidthMax: double; leftOfs : double = 0);
  end;

var
  Form1: TForm1;

implementation

const
  TestFontName = 'Arial'; //'Arial';
  TestfontSize = 11; // 11;

{$R *.lfm}

procedure FreeElements(t: TTextElement);
var
  p: TTextElement;
begin
  while Assigned(t) do begin
    p := t.Next;
    t.Free;
    t:=p;
  end;
end;

{ TForm1 }

procedure TForm1.Memo1Change(Sender: TObject);
begin
  ProcessText(Memo1.Text);
  PaintBox1.Invalidate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Font.Name := TestFontName;
  Memo1.Font.Size := TestfontSize;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  x, y : integer;
  yy   : integer;
  w, h : integer;
  t    : TTextElement;
  u8   : string;
  sz   : TSize;
begin
  if not Assigned(line) then Exit;

  t:=line;
  PaintBox1.Canvas.Font.Name:=TestFontName;
  PaintBox1.Canvas.Font.Size:=TestfontSize;
  PaintBox1.Canvas.Brush.Style:=bsClear;
  PaintBox1.Canvas.Pen.Style := psSolid;
  while Assigned(t) do begin
    x := PtToPixel(t.left);
    y := PtToPixel(t.top);
    w := PtToPixel(t.sizeInfo.size.cx);
    h := PtToPixel(t.sizeInfo.size.cy);
    u8 := utf8encode(t.subText);
    PaintBox1.Canvas.TextOut(x,y,u8);
    if t.isSpace then
      PaintBox1.Canvas.Pen.Color := clGreen
    else
      PaintBox1.Canvas.Pen.Color := clBlue;
    PaintBox1.Canvas.Rectangle(x,y, x+w, y+h);
    writeln('msr = ', w,' ',h);


    yy := y + 20;
    PaintBox1.Canvas.TextOut(x,yy,u8);
    sz := PaintBox1.Canvas.TextExtent(u8);

    PaintBox1.Canvas.Rectangle(x,yy, x +sz.cx, yy+sz.cy);
    writeln('ext = ', sz.cx,' ',sz.cy);
    t:=t.next;
  end;
end;

function TForm1.PtToPixel(p: double): Integer;
begin
  Result := Round( p/72 * PixelsPerInch);
end;

procedure TForm1.ProcessText(const txt: string);
var
  ws  : WideString;
  ne  : TTextElement;
begin
  ws := UTF8Decode(txt);
  ne := SplitText(ws);
  FreeElements(line);
  line := ne;
  MeasureElements(line);
  PlaceText(line, MaxInt);
end;

function TForm1.SplitText(const wS: WideString): TTextElement;
var
  i   : integer;
  s,e : integer;
  ne  : TTextElement;
  te  : TTextElement;
  fe  : TTextElement;
begin
  i:=1;
  fe := nil;
  te := nil;
  writeln('---- begin');
  while NextWord(ws, i, s, e) do begin
    ne := TTextElement.Create;
    ne.subText := Copy(ws, s, e-s+1);
    writeln(s,' ',e,': ',ne.subText);
    ne.isSpace := (ne.subText[1] = CHAR_SPACE);
    ne.spaceCount := length(ne.subText);
    if fe = nil then
      fe := ne
    else
      te.next := ne;
    te := ne;
  end;
  writeln('---- end');
  Result := fe;
end;

procedure TForm1.MeasureElements(el: TTextElement);
var
  f : TFontInfo;
begin
  f.Name := TestFontName;
  f.Size := TestFontSize;
  f.Style := [];
  while Assigned(el) do begin
    MeasureText(el.subText, f, el.sizeInfo);
    el := el.next;
  end;
end;

procedure TForm1.PlaceText(el: TTextElement; ptWidthMax: double;  leftOfs: double);
var
  x, y : double;
  maxy : double;
begin
  x:=leftOfs;
  y:=0;
  maxy := 0;
  while Assigned(el) do begin
    el.left := x;
    maxy := Max(el.sizeInfo.size.cy, maxy);
    x := x + el.sizeInfo.size.cx;
    if (x > ptWidthMax) then begin
      x := leftOfs;
      y := y+ maxy;
    end;
    el := el.Next;
  end;
end;

end.

