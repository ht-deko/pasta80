(* ===================================================================== *)
(* === G850 run-time library =========================================== *)
(* ===================================================================== *)

{$i system.pas}
{$l g850.asm}

const
  ScreenWidth  = 24;
  ScreenHeight = 6;
  LineBreak    = #13#10;
  
type
  TKeyArray= array[0..9] of Byte;  
  TIFMode = (ifmNormal, ifmPIO, ifmUART);
  TIOMode = (iomOutput, iomInput);
  TPin = (bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7);
  TIOLevel = (iolLow, iolHigh);
  
(* --------------------------------------------------------------------- *)
(* --- Internal functions ---------------------------------------------- *)
(* --------------------------------------------------------------------- *)
  
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

procedure _writepixels(var buf: Byte); register; inline
(
                     (* HL := @buf *)
  $06 / $08 /        (* LD B,1     *)
  $16 / $00 /        (* LD D,0     *)
  $1E / $00 /        (* LD E,0     *)
  $CD / $D0 / $BF    (* CALL BFD0h *)
);


procedure _readpixels(var buf: Byte); register; inline
(
                     (* HL := @buf *)
  $06 / $08 /        (* LD B,8     *)
  $16 / $00 /        (* LD D,0     *)
  $1E / $00 /        (* LD E,0     *)
  $CD / $00 / $BD    (* CALL BD00h *)
);

procedure _beep(level, length: Integer); register; external '__beep';


(* --------------------------------------------------------------------- *)
(* --- IOCS functions -------------------------------------------------- *)
(* --------------------------------------------------------------------- *)

{ Print a single character to the LCD }
procedure PutChar(x, y: Byte; c: Char); register; inline
(
  $79 /              (* LD   A,C (C = c) *)
  $53 /              (* LD   D,E (E = y) *)
  $5D /              (* LD   E,L (L = x) *)
  $CD / $62 / $BE    (* CALL BE62h       *)
);

{ Print a single character (with Symbol) to the LCD }
procedure PutChar2(x, y: Byte; c: Char); register; inline
(
  $79 /              (* LD   A,C (C = c) *)
  $53 /              (* LD   D,E (E = y) *)
  $5D /              (* LD   E,L (L = x) *)
  $CD / $5F / $BE    (* CALL BE5Fh       *)
);

{ Repeatedly print a single character to the LCD }
function PutChars(x, y: Byte; c: Char; n: Byte): Byte; register; inline
(
  $7B /              (* LD   A,E (E = c) *)
  $55 /              (* LD   D,L (L = y) *)
  $21 / $02 / $00 /  (* LD   HL,2        *)
  $39 /              (* ADD  HL,SP       *)
  $5E /              (* LD   E,(HL)      *)
  $41 /              (* LD   B,C (C = n) *)
  $CD / $EE / $BF /  (* CALL BFEEh       *)  
  $69                (* LD   L,C         *)
);

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
procedure WritePixels(x, y: Byte; var buf: byte; l: byte);
var
  p: array [0..8] of Byte absolute _writepixels;
begin
  p[1] := l;
  p[3] := y;
  p[5] := x;
  _writepixels(buf);    
end;

{ Scroll Up }
procedure ScrollUp; external '__scroll_up';

{ Scroll Down }
procedure ScrollDown(x, y: Byte); register; inline
(
  $53 /              (* LD   D,E (E = y) *)
  $5D /              (* LD   E,L (L = x) *)
  $CD / $65 / $BE    (* CALL BE65h       *)
);

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

{ Read pixel data from LCD }
procedure ReadPixels(x, y: Byte; var buf: Byte; l: Byte);
var
  p: array [0..8] of Byte absolute _readpixels;
begin
  p[1] := l;
  p[3] := y;
  p[5] := x;
  _readpixels(buf);
end;

{ Power Off }
procedure PowerOff; register; inline
(
  $CD / $2D / $BD    (* CALL BD2Dh *)
);


(* --------------------------------------------------------------------- *)
(* --- Screen and keyboard standard functions -------------------------- *)
(* --------------------------------------------------------------------- *)

(**
 * Moves the the cursor (aka printing position) to a given location. 
 *)
procedure GotoXY(X, Y: byte); register; external 'g850_gotoxy';

(**
 * Clears the screen. 
 *)
procedure ClrScr;
begin
  PutChars(0, 0, ' ', ScreenWidth * ScreenHeight);
  GotoXY(0, 0);
end;  

(**
 * This byte function returns the X-coordinate of the current cursor position.
 *)
function WhereX: byte; register; external 'g850_wherex';

(**
 * This byte function returns the Y-coordinate of the current cursor position.
 *)
function WhereY: byte; register; external 'g850_wherey';

(**
 * Returns True if a key has been pressed (and can be queried using the
 * ReadKey function), False if not.
 *)
function KeyPressed: Boolean; register; external 'g850_keypressed';

(**
 * Reads a key press and returns the corresponding ASCII character.
 *)
function ReadKey: Char;register; external 'g850_readkey';

function ReadKey2: Char;register; external 'g850_readkey2';


(* --------------------------------------------------------------------- *)
(* --- Miscellaneous functions ----------------------------------------- *)
(* --------------------------------------------------------------------- *)

{ Beep }
procedure Beep(level, length, count: Integer);
var
  i, l: Integer;
begin
  for i:=1 to count do
  begin
    _beep(level, length);
    if i < count then
      for l:=1 to 1400 do
        ;
  end;  
end;

{ Delay }
procedure Delay(ms: Integer); register; external 'g850_delay';

{ DigitalRead }
function DigitalRead(Pin: TPin): TIOLevel; register; external 'g850_digitalread';

{ DigitalWrite }
procedure DigitalWrite(Pin: TPin; Value: TIOLevel); register; external 'g850_digitalWrite';

{ InitJoystick }
procedure InitJoystick; register; external 'g850_init_joystick';

{ PinMode }
procedure PinMode(Pin: TPin; Mode: TIOMode); register; external 'g850_pinmode';

{ ScanKeyboard }
procedure ScanKeyboard(var Keys: TKeyArray); register; external 'g850_scankeyboard';

{ ReadJoystick }
function ReadJoystick: byte; register; external 'g850_read_joystick';

{ SetIFMode }
procedure SetIFMode(Mode: TIFMode); register; external 'g850_setifmode';

end.
