; =========================================================================
; === PC-G850 run-time library ============================================
; =========================================================================

; -------------------------------------------------------------------------
; --- Low-level routines expected by the compiler -------------------------
; -------------------------------------------------------------------------

;
; Startup
;
__init:         
                xor  a
                ld   (__cur_x),a
                ld   (__cur_y),a
                call    main
;
; Shutdown
;
__done:         
                rst     0

;
; New line
;
__newline:
                xor  a
                ld   (__cur_x),a
                ld   hl,__cur_y
                inc  (hl)
                ld   a,(hl)
                cp   6
                jr   c,__nl_done
                call __scroll_up
                ld   a,5
                ld   (__cur_y),a
__nl_done:
                ret
;
; Print character to screen
;
__putc:
                push ix
                ld   hl,__cur_y
                ld   d,(hl)
                ld   hl,__cur_x
                ld   e,(hl)
                call 0be62h
                ld   hl,__cur_x
                inc  (hl)
                ld   a,(hl)
                cp   24
                jr   c,__putc_done
                xor  a
                ld   (__cur_x),a
                ld   hl,__cur_y
                inc  (hl)
                ld   a,(hl)
                cp   6
                jr   c,__putc_done
                call __scroll_up
                ld   a,5
                ld   (__cur_y),a                
__putc_done:
                pop ix
                ret    
;
; Print string to screen
;
__puts:
                ld      b,(hl)
                inc     b
                jr      __putschk
__putsloop:     
                ld      a,(hl)
                push    hl
                push    bc
                call    __putc
                pop     bc
                pop     hl
__putschk:      
                inc     hl
                djnz    __putsloop
                ret
                
;
; Get Line
;
__getline:
                ld      hl,__linebuf
                ld      (__lineptr),hl
                xor     a
                ld      (__linelen),a
__readline1:
                call    __checkbreak
                call    0be53h
                or      a               
                jr      z, __readline1
                call    0bcfdh
                call    0be56h
                cp      ' '
                jr      c, __readline2
                ld      hl,(__lineptr)
                ld      (hl),a
                inc     hl
                ld      (__lineptr),hl
                ld      hl,__linelen
                inc     (hl)
                call    __putc
                jp      __readline1
__readline2:
                cp      8
                jr      nz,__readline3
                ld      hl,__linelen
                ld      a,(hl)
                or      a
                jr      z,__readline1
                dec     (hl)
                ld      hl,(__lineptr)
                dec     hl
                ld      (__lineptr),hl
                ld      hl,__cur_x
                ld      a,(hl)
                or      a
                jr      z,__readline1
                dec     (hl)
                ld      a,' '
                call    __putc
                ld      hl,__cur_x
                dec     (hl)
                jp      __readline1             
__readline3:
                cp      13
                jr      nz,__readline1
                ld      hl,(__lineptr)
                ld      (hl),0
                ld      hl,__linebuf
                ld      (__lineptr),hl
                call    __newline
                ret
                
;       
; Check Break
;
__checkbreak:
                in      a,(1Fh)
                bit     7,a
                ret     z
                jp      __done

; -------------------------------------------------------------------------
; --- Routines that implement a Pascal procedure or function --------------
; -------------------------------------------------------------------------

;
; Scroll Up
;
__scroll_up:
                call 0bfebh
                ret
                
;
; Show Register
;
__regout:
                call 0bd03h
                ret

;
; Input to Register A
;
__reginp_a:
                call 0bd09h
                ret

;
; Input to Register HL
;
__reginp_hl:
                call 0bd0fh
                ret
                
;
; Beep
;
__beep:
                ld   (__blen),de
                ld   h,0
                ld   de,22
                call __bmul8
                ld   de,166
                add  hl,de
                ld   b,h
                ld   c,l
                srl  h
                rr   l
                srl  h
                rr   l
                srl  h
                rr   l
                srl  b
                rr   c
                srl  b
                rr   c
                srl  b
                rr   c
                srl  b
                rr   c
                srl  b
                rr   c
                srl  b
                rr   c
                srl  b
                rr   c
                or   a
                sbc  hl,bc
                ld   (__bhalf),hl
                ld   de,(__blen)
                ld   a,d
                or   e
                jr   z,__bexit    
__bloop:
                ld   a,0c0h
                out  (18h),a
                call __bwait_half
                ld   a,00h
                out  (18h),a
                call __bwait_half
                dec  de
                ld   a,d
                or   e
                jr   nz,__bloop
                ret
__bwait_half:
                ld hl,(__bhalf)
__bwait_l:
                dec hl
                ld a,h
                or l
                jr nz,__bwait_l
                ret
__bmul8:
                ld   b,l
                ld   hl,0
__bmul8_l:
                add  hl,de
                djnz __bmul8_l
                ret
__bhalf:  
                dw 0
__blen:   
                dw 0
__bexit:    
                ret

g850_gotoxy:
                ld   a,l
                ld   (__cur_x),a
                ld   a,e
                ld   (__cur_y),a
                ret

g850_wherex:
                ld   a,(__cur_x)
                ld   l,a
                ret
        
g850_wherey:
                ld   a,(__cur_y)
                ld   l,a
                ret

g850_readkey:
__rk_loop:
                call    __checkbreak
                call    0be53h
                or      a               
                jr      z, __rk_loop
                call    0bcfdh
                call    0be56h
                ld      l, a
                ret

g850_readkey2:
__rk_loop2:
                call    __checkbreak
                call    0be53h
                or      a               
                jr      z, __rk_loop2
                call    0bcc4h
                ld      l, a
                ret     
                
__internal_key_scan:
                ld      hl, __KeyBuffer
                ld      d, 01h
                ld      b, 8
__scan11:
                ld      a, d
                out     (11h), a
                in      a, (10h)
                ld      (hl), a
                inc     hl
                sla     d
                djnz    __scan11
                xor     a
                out     (11h), a
                ld      d, 01h
                ld      b, 2
__scan12:
                ld      a, d
                out     (12h), a
                in      a, (10h)
                ld      (hl), a
                inc     hl
                sla     d
                djnz    __scan12
                xor     a
                out     (12h), a
                ret

g850_scankeyboard:
                push    hl
                call    __internal_key_scan
                pop     de
                ld      hl, __KeyBuffer
                ld      bc, 10
                ldir
                ret

g850_keypressed:
                call    __internal_key_scan
                ld      hl, __KeyBuffer
                ld      b, 10
                ld      a, 0
__check_loop:
                or      (hl)
                inc     hl
                djnz    __check_loop
                ld      l, 0
                jr      z, __ret
                ld      l, 1
__ret:
                ret
                
g850_init_joystick:
                ld      a, 01h
                out     (60h), a
                ld      a, 0FFh
                out     (61h), a
                ret
    
g850_read_joystick:
                in      a, (62h)
                ld      l, a
                ret    
                
                
g850_setifmode:
                ld a, l
                out     (60h), a                         
                xor a
                ld (__io_shadow), a
                ret
                
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
		
g850_delay:     
                ld a, h
                or l
                ret z
__delay_outer:
                ld bc, 307
__delay_inner:
                dec bc
                ld a, b
                or c
                jr nz, __delay_inner
                dec hl
                ld a, h
                or l
                jr nz, __delay_outer
                ret			         

; =====================================================================
; Local Scratchpad
; =====================================================================
__cur_x:        .db 0
__cur_y:        .db 0
__KeyBuffer:    .ds 10
__io_shadow:    .db 0
