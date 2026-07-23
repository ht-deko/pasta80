(* ===================================================================== *)
(* === G850 Graphics run-time library ================================== *)
(* ===================================================================== *)

{$l g850grph.asm}

const
  ScreenWidthPixels  = 144;
  ScreenHeightPixels = 48;

type
  TColor = (clWhite, clBlack);
  TPattern = array [0..7] of Byte;

// =====================================================================
//
// <!> IMPORTANT <!>
// All graphics functions (Plot, Draw, Box, PutSprite, etc.) operate 
// strictly on the off-screen buffer (VRAM).
// Call RepaintLCD() at the end of your main loop to flip the screen.
//
// =====================================================================
 
procedure Box(X1, Y1, X2, Y2: Byte; Color: TColor); register; external 'g850_box';
procedure Circle(X, Y, Radius: Byte; Color: TColor); register; external 'g850_circle';
procedure Draw(X1, Y1, X2, Y2: Byte; Color: TColor); register; external 'g850_draw';
procedure FillBox(X1, Y1, X2, Y2: Byte; Color: TColor); register; external 'g850_fillbox';
procedure FillPattern(X1, Y1 ,X2, Y2: Byte; Color: TColor); register; external 'g850_fillpattern';
procedure FillScreen(Color: TColor); register; external 'g850_fillscreen';
procedure FillShape(X, Y: Byte; FillColor: TColor); register; external 'g850_fillshape';
function GetBGAddr: Integer; register; external 'g850_get_bg_addr';
function GetDotColor(X, Y: Byte): TColor; register; external 'g850_getdotcolor';
procedure GetMask(var P: TPattern); register; external 'g850_getmask';
function GetMaskAddr: Integer; register; external 'g850_get_mask_addr';
procedure GetPattern(var P: TPattern); register; external 'g850_getpattern';
function GetPatternAddr: Integer; register; external 'g850_get_pattern_addr';
procedure GetSprite(X, Y: Byte); register; external 'g850_getsprite';
function GetVramAddr: Integer; register; external 'g850_get_vram_addr';
procedure Mask(var P: TPattern); register; external 'g850_mask';
procedure Pattern(var P: TPattern); register; external 'g850_pattern';
procedure Plot(x, y: byte; mode: TColor); register; external 'g850_plot';
procedure PutSprite(X, Y: Byte; UseMask: Boolean); register; external 'g850_putsprite';
procedure RepaintLCD; external 'g850_repaintlcd';
procedure RestoreBG; external 'g850_restorebg';
procedure SaveBG; external 'g850_savebg';
procedure SetBGAddr(adr: Integer); register; external 'g850_setbgaddr';
procedure UpdateLCD(X1, Y1, X2, Y2: Byte); register; external 'g850_updatelcd';


// ---------------------------------------------------------------------
// Helper Routines
// ---------------------------------------------------------------------

function GetBGAddrXY(x, y: byte): Integer;
begin
  GetBGAddrXY := GetBGAddr + y * ScreenWidthPixels + x;
end;

function GetVramAddrXY(x, y: byte): Integer;
begin
  GetVramAddrXY := GetVramAddr + y * ScreenWidthPixels + x;
end;
