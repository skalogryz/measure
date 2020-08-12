unit logtext;

{$ifdef fpc}{$mode delphi}{$H+}{$endif}

interface

uses
  Classes, SysUtils;

type
  TLogFont = class(TObject)
    name  : WideString;
    size  : double; // in Pt
  end;

  TLogStyle = class(TObject)
    name  : WideString;
  end;

  TLogText = class(TObject)
  public
    style : TLogStyle;
    font  : TLogFont;
    text  : WideString;
    next  : TLogText;
  end;

  { TLogParagraph }

  TLogParagraph = class(TObject)
  public
    firstText : TLogText;
    next      : TLogParagraph;
    destructor Destroy; override;
    function AddText(const txt: WideString): TLogText; overload;
    function AddText: TLogText; overload;
  end;

  { TLogSection }

  TLogSection = class(TObject)
    next : TLogSection;
    par  : TLogParagraph;
    destructor Destroy; override;
    function AddParagraph: TLogParagraph;
  end;

  { TLogDocument }

  TLogDocument = class(TObject)
    fonts   : TList;
    styles  : TList;
    section : TLogSection;
    constructor Create;
    destructor Destroy; override;
    function AddSection: TLogSection;
    function AddFont: TLogFont;
    function AddStyle: TLogStyle;
  end;

procedure FreeParagraph(p: TLogParagraph);
procedure FreeSection(s: TLogSection);
procedure FreeText(t: TLogText);

implementation

procedure FreeText(t: TLogText);
var
  tt : TLogText;
begin
  while Assigned(t) do begin
    tt := t;
    t := t.next;
    tt.Free;
  end;
end;

procedure FreeSection(s: TLogSection);
var
  ts : TLogSection;
begin
  while Assigned(s) do begin
    ts := s;
    s := s.next;
    ts.Free;
  end;
end;

procedure FreeParagraph(p: TLogParagraph);
var
  tp : TLogParagraph;
begin
  while Assigned(p) do begin
    tp := p;
    p := p.next;
    tp.Free;
  end;
end;

{ TLogParagraph }

destructor TLogParagraph.Destroy;
begin
  FreeText(firstText);
  inherited Destroy;
end;

function TLogParagraph.AddText(const txt: WideString): TLogText;
begin
  Result := AddText();
  Result.text := txt;
end;

function TLogParagraph.AddText: TLogText;
var
  t : TLogText;
begin
  Result := TLogText.Create;
  if Assigned(firstText) then begin
    t := firstText;
    while Assigned(t.next) do
      t := t.next;
    t.next := Result;
  end else
    firstText := Result;
end;

{ TLogSection }

function TLogSection.AddParagraph: TLogParagraph;
var
  pr : TLogParagraph;
begin
  Result := TLogParagraph.Create;
  if not Assigned(par) then
    par:=Result
  else begin
    pr := par;
    while Assigned(pr.next) do
      pr:=pr.next;
    pr.next := Result;
  end;
end;

destructor TLogSection.Destroy;
begin
  FreeParagraph(par);
  inherited Destroy;
end;

{ TLogDocument }

constructor TLogDocument.Create;
begin
  fonts := TList.Create;
  styles := TList.Create;
end;

destructor TLogDocument.Destroy;
var
  i : integer;
begin
  FreeSection(section);
  for i:=0 to fonts.Count-1 do TObject(fonts[i]).free;
  for i:=0 to styles.Count-1 do TObject(styles[i]).free;
  fonts.Free;
  styles.Free;
  inherited Destroy;
end;

function TLogDocument.AddSection: TLogSection;
var
  s : TlogSection;
begin
  Result := TLogSection.Create;
  s := section;
  if not Assigned(s) then
    section := Result
  else begin
    while Assigned(s.next) do
      s:=s.next;
    s.next := Result;
  end;
end;

function TLogDocument.AddFont: TLogFont;
begin
  Result := TLogFont.Create;
  fonts.Add(Result);
end;

function TLogDocument.AddStyle: TLogStyle;
begin
  Result := TLogStyle.Create;
  styles.Add(Result);
end;

end.

