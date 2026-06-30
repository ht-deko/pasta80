(* ===================================================================== *)
(* === G850 run-time library =========================================== *)
(* ===================================================================== *)

{$i system.pas}
{$l g850.asm}

const
  ScreenWidth  = 24;
  ScreenHeight = 6;
  LineBreak    = #13#10;

procedure _putc; register; inline
(
  $3E / $20 /        (* LD A,' '   *)
  $16 / $00 /        (* LD D,0     *)
  $1E / $00 /        (* LD E,0     *)
  $CD / $62 / $BE    (* CALL BE62h *)
);

procedure _putcn; register; inline
(
  $3E / $20 /        (* LD A,' '   *)
  $06 / $90 /        (* LD B,144   *)
  $16 / $00 /        (* LD D,0     *)
  $1E / $00 /        (* LD E,0     *)
  $CD / $EE / $BF    (* CALL BFEEh *)
);

function _puts(var s: string): Byte; register; inline
(
                     (* HL := @s   *)
  $23 /              (* INC HL     *)
  $06 / $01 /        (* LD B,1     *)
  $16 / $00 /        (* LD D,0     *)
  $1E / $00 /        (* LD E,0     *)
  $CD / $F1 / $BF /  (* CALL BFF1h *)
  $69                (* LD L,C     *)
);

procedure _gprint(var buf: Byte); register; inline
(
                     (* HL := @buf *)
  $06 / $08 /        (* LD B,8     *)
  $16 / $00 /        (* LD D,0     *)
  $1E / $00 /        (* LD E,0     *)
  $CD / $D0 / $BF    (* CALL BFD0h *)
);

{ Clear LCD }
procedure Cls;
begin
  _putcn;
end;

{ Print a single character to the LCD }
procedure PutChar(x, y: Byte; c: Char);
var
  p: array [0..8] of Byte absolute _putc;
begin
  p[1] := Ord(c);
  p[3] := y;
  p[5] := x;
  _putc;
end;

{ Repeatedly print a single character to the LCD }
procedure PutChars(x, y: Byte; c: Char; n: Byte);
var
  p: array [0..10] of Byte absolute _putcn;
begin
  p[1] := Ord(c);
  p[3] := n;
  p[5] := y;
  p[7] := x;
  _putcn;
end;
  
{ Print a string to the LCD }  
function PutString(x, y: Byte; s: string): Byte;
var
  p: array [0..8] of Byte absolute _puts;
begin
  p[2] := Length(s);
  p[4] := y;
  p[6] := x;
  PutString := _puts(s);
end;

{ Print graphics to LCD }  
procedure GPrint(x, y: Byte; var buf: byte; l: byte);
var
  p: array [0..8] of Byte absolute _gprint;
begin
  p[1] := l;
  p[3] := y;
  p[5] := x;
  _gprint(buf);
end;

{ Tests if a key has been pressed (no wait) }
function Inkey: Byte; register; inline
(
  $CD / $53 / $BE /  (* CALL BE53h *)
  $6F                (* LD L,A     *)
);

{ Reads a character from the keyboard (wait) }
function GetChar: Byte; register; inline
(
  $CD / $FD / $BC /  (* CALL BCFDh *)
  $6F                (* LD L,A     *)
);

{ Power Off }
procedure PowerOff; register; inline
(
  $CD / $2D / $BD    (* CALL BD2Dh *)
);

end.
