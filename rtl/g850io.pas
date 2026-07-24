(* ===================================================================== *)
(* === G850 I/O run-time library ======================================= *)
(* ===================================================================== *)

{$l g850io.asm}

type
  TIFMode = (ifmNormal, ifmPIO, ifmUART);
  TIOMode = (iomOutput, iomInput);
  TPin = (bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7);
  TIOLevel = (iolLow, iolHigh);


{ DigitalRead }
function DigitalRead(Pin: TPin): TIOLevel; register; external 'g850_digitalread';

{ DigitalWrite }
procedure DigitalWrite(Pin: TPin; Value: TIOLevel); register; external 'g850_digitalWrite';

{ PinMode }
procedure PinMode(Pin: TPin; Mode: TIOMode); register; external 'g850_pinmode';

{ SetIFMode }
procedure SetIFMode(Mode: TIFMode); register; external 'g850_setifmode';

