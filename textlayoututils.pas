unit textlayoututils;

{$ifdef fpc}{$mode delphi}{$H+}{$endif}

interface

const
  CHAR_TAB                = #$09;
  CHAR_TAB_UTF8           = CHAR_TAB;
  CHAR_SPACE              = #$20;
  CHAR_SPACE_UTF8         = CHAR_SPACE;
  CHAR_NONBREAKSPACE      = #$00A0;
  CHAR_NONBREAKSPACE_UTF8 = #$C2#$C2A0;

function NextWord(const w: WideString; var idx: integer): Boolean; overload;
function NextWord(const w: WideString; var idx: integer; out stIdx, endIdx: Integer): Boolean; overload;
function isWordBreak(const w: WideChar): Boolean;

implementation

function isWordBreak(const w: WideChar): Boolean;
begin
  Result := (w = CHAR_TAB) or (w = CHAR_SPACE);
end;

function NextWord(const w: WideString; var idx: integer; out stIdx, endIdx: Integer): Boolean;
begin
  if idx = 0 then idx:=1;
  Result := (idx<=length(w));
  if not Result then begin
    stIdx := idx;
    endIdx := idx;
    Exit;
  end;

  stIdx := idx;
  if (isWordBreak(w[idx])) then
    while (idx <= length(w)) and isWordBreak(w[idx]) do
      inc(idx)
  else
    while (idx <= length(w)) and not isWordBreak(w[idx]) do
      inc(idx);
  endIdx := idx-1;
end;

function NextWord(const w: WideString; var idx: integer): Boolean; overload;
var
  s,e : integer;
begin
  Result := NextWord(w, idx, s, e);
end;

end.
