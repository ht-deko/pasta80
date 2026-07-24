; =========================================================================
; === PC-G850 I/O run-time library ========================================
; =========================================================================

; =====================================================================
; g850_setifmode
;   Input:  L = Mode 
; =====================================================================
g850_setifmode:
                ld a, l
                out (60h), a                         
                xor a
                ld (__io_shadow), a
                ret
                
		
; =====================================================================
; g850_pinmode
;   Input:  L = Pin 
;           E = Mode 
; =====================================================================
g850_pinmode:
                ld a, 1
                ld b, l
                inc b
                jr __check_shift
__shift_loop:
                add a, a
__check_shift:
                djnz __shift_loop
                ld c, a
                ld a, e
                or a
                jr z, __mode_0
__mode_1:
                ld a, (__io_shadow)
                or c
                jr __write_out
__mode_0:
                ld a, c
                cpl
                ld c, a
                ld a, (__io_shadow)
                and c
__write_out:
                out (61h), a
                ld (__io_shadow), a
                ret             
                
                
; =====================================================================
; g850_digitalread
;   Input:  L = Pin 
;   Output:  L = Value 
; =====================================================================
g850_digitalread:
                ld a, 1
                ld b, l
                inc b
                jr __dr_check_shift
__dr_shift_loop:
                add a, a
__dr_check_shift:
                djnz __dr_shift_loop
                ld c, a
                in a, (62h)
                and c
                ld l, 0
                jr z, __dr_return
                ld l, 1
__dr_return:
                ret    

		
; =====================================================================
; g850_digitalWrite
;   Input:  L = Pin 
;           E = Value 
; =====================================================================
g850_digitalWrite:
                ld a, 1
                ld b, l
                inc b
                jr __dw_check_shift
__dw_shift_loop:
                add a, a
__dw_check_shift:
                djnz __dw_shift_loop
                ld c, a
                ld a, e
                or a
                jr z, __dw_mode_0
__dw_mode_1:
                in a, (62h)
                or c
                jr __dw_write_out
__dw_mode_0:
                in a, (62h)
                ld b, a
                ld a, c
                cpl
                and b
__dw_write_out:
                out (62h), a
                ret
		
; =====================================================================
; Local Scratchpad
; =====================================================================

__io_shadow:    .db 0
		