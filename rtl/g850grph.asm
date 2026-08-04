; =========================================================================
; === PC-G850 Graphics run-time library ===================================
; =========================================================================

; =====================================================================
; g850_box
;   Input:  Stack #2 (ix+4) = X1
;           Stack #1 (ix+2) = Y1
;           L = X2 
;           E = Y2 
;           C = Color
; =====================================================================
g850_box:
        call __load_rect_args
        call __sort_coords
        ld   a, (__bx_x1)
        ld   (__bx_cur), a
__bx_h_loop:
        ld   a, (__bx_cur)
        ld   l, a
        ld   a, (__bx_y1)
        ld   e, a
        ld   a, (__bx_color)
        ld   c, a
        call g850_plot
        ld   a, (__bx_cur)
        ld   l, a
        ld   a, (__bx_y2)
        ld   e, a
        ld   a, (__bx_color)
        ld   c, a
        call g850_plot
        ld   a, (__bx_cur)
        ld   hl, __bx_x2
        cp   (hl)
        jr   z, __bx_v_setup
        inc  a
        ld   (__bx_cur), a
        jr   __bx_h_loop
__bx_v_setup:
        ld   a, (__bx_y1)
        ld   (__bx_cur), a
__bx_v_loop:
        ld   a, (__bx_x1)
        ld   l, a
        ld   a, (__bx_cur)
        ld   e, a
        ld   a, (__bx_color)
        ld   c, a
        call g850_plot
        ld   a, (__bx_x2)
        ld   l, a
        ld   a, (__bx_cur)
        ld   e, a
        ld   a, (__bx_color)
        ld   c, a
        call g850_plot
        ld   a, (__bx_cur)
        ld   hl, __bx_y2
        cp   (hl)
        jp   z, __exit_2args
        inc  a
        ld   (__bx_cur), a
        jr   __bx_v_loop
	
	
; =====================================================================
; g850_circle
;   Input:  Stack #1 (ix+2) = X
;           L = Y
;           E = Radius
;           C = Color
; =====================================================================
g850_circle:
        push ix
        ld   ix, 2
        add  ix, sp
        ld   a, (ix+2)
        ld   (__cx_xc), a
        ld   a, l
        ld   (__cx_yc), a
        ld   a, e
        ld   (__cx_r), a
        ld   a, c
        ld   (__cx_color), a
        pop  ix
        ld   a, (__cx_r)
        ld   b, a  
        ld   c, 0  
        ld   l, a
        ld   h, 0  
__cx_loop:
        ld   a, b
        cp   c
        jp   c, __exit_1arg 
        call __cx_plot_8
        ld   e, c    
        ld   d, 0    
        sla  e
        rl   d       
        inc  de      
        or   a       
        sbc  hl, de  
        inc  c
        bit  7, h              
        jr   z, __cx_loop_next 
        dec  b                 
        ld   e, b              
        ld   d, 0              
        sla  e
        rl   d                 
        add  hl, de            
__cx_loop_next:
        jp   __cx_loop
__cx_plot_8:
        push bc
        push hl                
        ld   a, (__cx_xc)
        add  a, b
        ld   l, a
        ld   a, (__cx_yc)
        add  a, c
        ld   e, a
        call __cx_clip_plot
        ld   a, (__cx_xc)
        add  a, b
        ld   l, a
        ld   a, (__cx_yc)
        sub  c
        ld   e, a
        call __cx_clip_plot
        ld   a, (__cx_xc)
        sub  b
        ld   l, a
        ld   a, (__cx_yc)
        add  a, c
        ld   e, a
        call __cx_clip_plot
        ld   a, (__cx_xc)
        sub  b
        ld   l, a
        ld   a, (__cx_yc)
        sub  c
        ld   e, a
        call __cx_clip_plot
        ld   a, (__cx_xc)
        add  a, c
        ld   l, a
        ld   a, (__cx_yc)
        add  a, b
        ld   e, a
        call __cx_clip_plot
        ld   a, (__cx_xc)
        add  a, c
        ld   l, a
        ld   a, (__cx_yc)
        sub  b
        ld   e, a
        call __cx_clip_plot
        ld   a, (__cx_xc)
        sub  c
        ld   l, a
        ld   a, (__cx_yc)
        add  a, b
        ld   e, a
        call __cx_clip_plot
        ld   a, (__cx_xc)
        sub  c
        ld   l, a
        ld   a, (__cx_yc)
        sub  b
        ld   e, a
        call __cx_clip_plot
        pop  hl
        pop  bc
        ret
__cx_clip_plot:
        ld   a, l
        cp   144
        ret  nc
        ld   a, e
        cp   48
        ret  nc
        push hl
        push de
        push bc
        ld   a, (__cx_color)
        ld   c, a 
        call g850_plot
        pop  bc
        pop  de
        pop  hl
        ret


; =====================================================================
; g850_draw
;   Input:  Stack #1 = X1
;           Stack #2 = Y1
;           L = X2
;           E = Y2
;           C = Color (0 (white) / 1 (Black))
; =====================================================================
g850_draw:
        call __load_rect_args
        ld   a, (__dr_x2)
        ld   hl, __dr_x1
        sub  (hl)
        jr   nc, __opt3_dx_pos
        neg
        ld   (__dr_dx), a
        ld   a, -1
        ld   (__dr_step_x), a
        jr   __opt3_dx_done
__opt3_dx_pos:
        ld   (__dr_dx), a
        ld   a, 1
        ld   (__dr_step_x), a
__opt3_dx_done:
        ld   a, (__dr_y2)
        ld   hl, __dr_y1
        sub  (hl)
        jr   nc, __opt3_dy_pos
        neg
        ld   (__dr_dy), a
        ld   a, -1
        ld   (__dr_step_y), a
        jr   __opt3_dy_done
__opt3_dy_pos:
        ld   (__dr_dy), a
        ld   a, 1
        ld   (__dr_step_y), a
__opt3_dy_done:
        ld   a, (__dr_dx)
        ld   hl, __dr_dy
        cp   (hl)
        jr   c, __opt3_y_major
__opt3_x_major:
        ld   a, (__dr_dx)
        srl  a
        ld   (__dr_err), a
__opt3_x_loop:
        ld   a, (__dr_x1)
        ld   l, a
        ld   a, (__dr_y1)
        ld   e, a
        ld   a, (__dr_color)
        ld   c, a
        call g850_plot
        ld   a, (__dr_x1)
        ld   hl, __dr_x2
        cp   (hl)
        jp   z, __exit_2args
        ld   hl, __dr_step_x
        add  a, (hl)
        ld   (__dr_x1), a
        ld   a, (__dr_err)
        ld   hl, __dr_dy
        sub  (hl)
        jr   nc, __opt3_x_loop_save
        ld   b, a
        ld   a, (__dr_y1)
        ld   hl, __dr_step_y
        add  a, (hl)
        ld   (__dr_y1), a
        ld   a, b
        ld   hl, __dr_dx
        add  a, (hl)
__opt3_x_loop_save:
        ld   (__dr_err), a
        jr   __opt3_x_loop
__opt3_y_major:
        ld   a, (__dr_dy)
        srl  a
        ld   (__dr_err), a
__opt3_y_loop:
        ld   a, (__dr_x1)
        ld   l, a
        ld   a, (__dr_y1)
        ld   e, a
        ld   a, (__dr_color)
        ld   c, a
        call g850_plot
        ld   a, (__dr_y1)
        ld   hl, __dr_y2
        cp   (hl)
        jp   z, __exit_2args
        ld   hl, __dr_step_y
        add  a, (hl)
        ld   (__dr_y1), a
        ld   a, (__dr_err)
        ld   hl, __dr_dx
        sub  (hl)
        jr   nc, __opt3_y_loop_save
        ld   b, a
        ld   a, (__dr_x1)
        ld   hl, __dr_step_x
        add  a, (hl)
        ld   (__dr_x1), a
        ld   a, b
        ld   hl, __dr_dy
        add  a, (hl)
__opt3_y_loop_save:
        ld   (__dr_err), a
        jr   __opt3_y_loop
	
	
; =====================================================================
; g850_fillbox
;   Input:  Stack #2 (ix+4) = X1
;           Stack #1 (ix+2) = Y1
;           L = X2
;           E = Y2
;           C = Color
; =====================================================================
g850_fillbox:
        call __load_rect_args
        call __sort_coords
        ld   a, (__fb_color)
        or   a
        jr   nz, __fb_col_black
        xor  a
        jr   __fb_col_done
__fb_col_black:
        ld   a, 0FFh
__fb_col_done:
        ld   (__fb_col_byte), a
        call __setup_fill_masks
__fb_x_loop:
        call __fill_column
        ld   a, (__fb_cur_x)
        ld   hl, __fb_x2
        cp   (hl)
        jp   z, __exit_2args
        inc  a
        ld   (__fb_cur_x), a
        jr   __fb_x_loop
	
	
; =====================================================================
; g850_fillpattern
;   Input:  Stack #2 (ix+4) = X1
;           Stack #1 (ix+2) = Y1
;           L = X2
;           E = Y2
;           C = Color
; =====================================================================
g850_fillpattern:
        call __load_rect_args
        call __sort_coords
        call __setup_fill_masks
__fp_x_loop:
        ld   a, (__fp_cur_x)
        and  7
        ld   e, a
        ld   d, 0
        ld   hl, (__current_pattern_ptr)
        add  hl, de
        ld   b, (hl)
        ld   a, (__fp_color)
        or   a
        jr   nz, __fp_no_inv
        ld   a, b
        cpl
        ld   b, a
__fp_no_inv:
        ld   a, b
        ld   (__fp_col_byte), a
        call __fill_column
        ld   a, (__fp_cur_x)
        ld   hl, __fp_x2
        cp   (hl)
        jp   z, __exit_2args
        inc  a
        ld   (__fp_cur_x), a
        jr   __fp_x_loop


; =====================================================================
; g850_fillscreen
;   Input:  L = Color (0 (white) / 1 (Black))
; =====================================================================
g850_fillscreen:
        ld   a,l
        neg
        ld   hl,__vram
        ld   (hl),a
        ld   de,__vram+1
        ld   bc,863
        ldir
        ret

	
; =====================================================================
; g850_fillshape
;   Input:  L = X
;           E = Y
;           C = Color (0 (white) / 1 (Black))
; =====================================================================
g850_fillshape:
        ld   a, l
        ld   (__fs_start_x), a
        ld   a, e
        ld   (__fs_start_y), a
        ld   a, c
        ld   (__fs_color), a
        push bc             
        call g850_getdotcolor
        pop  bc
        ld   a, l
        ld   (__fs_target_color), a
        cp   c
        ret  z                 
        ld   hl, __fs_stack
        ld   (__fs_sp), hl
        ld   a, (__fs_start_x)
        ld   b, a
        ld   a, (__fs_start_y)
        ld   c, a
        call __fs_push_seed
__fs_main_loop:
        call __fs_pop_seed
        ret  c
        push bc
        ld   l, b
        ld   e, c
        call g850_getdotcolor
        pop  bc
        ld   a, (__fs_target_color)
        cp   l
        jp   nz, __fs_main_loop
        ld   d, b
__fs_scan_left:
        ld   a, d
        or   a
        jr   z, __fs_left_found
        dec  d
        push bc
        push de
        ld   l, d
        ld   e, c
        call g850_getdotcolor
        ld   a, (__fs_target_color)
        cp   l
        pop  de
        pop  bc
        jr   z, __fs_scan_left
        inc  d
__fs_left_found:
        ld   h, b
__fs_scan_right:
        ld   a, h
        cp   143
        jr   z, __fs_right_found
        inc  h
        push bc
        push de
        push hl
        ld   l, h
        ld   e, c
        call g850_getdotcolor
        ld   a, (__fs_target_color)
        cp   l
        pop  hl
        pop  de
        pop  bc
        jr   z, __fs_scan_right
        dec  h    
__fs_right_found:
        push bc
        push de
        push hl
__fs_fill_segment:
        push bc
        push de
        push hl
        ld   l, d
        ld   e, c
        ld   a, (__fs_color)
        ld   c, a
        call g850_plot
        pop  hl
        pop  de
        pop  bc
        ld   a, h
        cp   d
        jr   z, __fs_fill_done
        inc  d
        jr   __fs_fill_segment
__fs_fill_done:
        pop  hl
        pop  de
        pop  bc
        ld   a, c
        or   a
        jr   z, __fs_skip_up
        dec  a              
        call __fs_scan_line
__fs_skip_up:
        ld   a, c
        cp   47
        jr   z, __fs_skip_down
        inc  a               
        call __fs_scan_line
__fs_skip_down:
        jp   __fs_main_loop
__fs_scan_line:
        push bc
        push de
        push hl
        ld   c, a
        ld   b, 0
__fs_scan_line_loop:
        push bc
        push de
        push hl
        ld   l, d
        ld   e, c
        call g850_getdotcolor
        ld   a, (__fs_target_color)
        cp   l
        jr   z, __fs_is_target
        pop  hl
        pop  de
        pop  bc
        ld   b, 0
        jr   __fs_scan_line_next
__fs_is_target:
        pop  hl
        pop  de
        pop  bc
        ld   a, b
        or   a
        jr   nz, __fs_scan_line_next
        push bc
        ld   b, d
        call __fs_push_seed
        pop  bc
        ld   b, 1
__fs_scan_line_next:
        ld   a, h
        cp   d
        jr   z, __fs_scan_line_end
        inc  d
        jr   __fs_scan_line_loop
__fs_scan_line_end:
        pop  hl
        pop  de
        pop  bc
        ret
__fs_push_seed:
        push hl
        ld   hl, (__fs_sp)
        ld   (hl), b
        inc  hl
        ld   (hl), c
        inc  hl
        ld   (__fs_sp), hl
        pop  hl
        ret
__fs_pop_seed:
        push hl
        ld   hl, (__fs_sp)
        ld   de, __fs_stack
        or   a                  
        sbc  hl, de             
        jr   z, __fs_stack_empty
        ld   hl, (__fs_sp)
        dec  hl
        ld   c, (hl)       
        dec  hl
        ld   b, (hl)       
        ld   (__fs_sp), hl 
        pop  hl
        or   a             
        ret
__fs_stack_empty:
        pop  hl
        scf                
        ret
	
	
; =====================================================================
; g850_getdotcolor
;   Input:  L = X (0..143)
;           E = Y (0..47)
;   Output: L = Color (0 (white) / 1 (Black))
; =====================================================================
g850_getdotcolor:
        call __prep_vram_and_mask
        ld   a,(hl)
        ld   b,a
        ld   a,(__px_mask)
        and  b
        jr   z,__dot_white
        ld   l,1
        ret
__dot_white:
        ld   l,0
        ret
	
	
; =====================================================================
; g850_getpattern
;   Input: HL = Address of TPattern (var P)
;   Output: Load from __current_pattern
; =====================================================================
g850_getpattern:
        ld   de, hl                
        ld   hl, __current_pattern
        jr   __copy_8_bytes


; =====================================================================
; g850_getmask
;   Input: HL = Address of TPattern (var P)
;   Output: Load from __current_pattern
; =====================================================================
g850_getmask:
        ld   de, hl                
        ld   hl, __mask_pattern 
        jr   __copy_8_bytes


; =====================================================================
; g850_pattern (8x8)
;   Input:  HL = Address of TPattern (var P)
; =====================================================================
g850_pattern:
        ld   de, (__current_pattern_ptr)
        jr   __copy_8_bytes


; =====================================================================
; g850_mask (8x8)
;   Input:  HL = Address of TPattern (var P)
; =====================================================================
g850_mask:
        ld   de, (__mask_pattern_ptr)
__copy_8_bytes:
        ld   bc, 8                
        ldir                      
        ret


; =====================================================================
; g850_getsprite
;   Input:  L = X, E = Y
;   Output: Save to __current_pattern 
; =====================================================================
g850_getsprite:
        ld   a, l
        ld   (__gs_x), a
        ld   a, e
        ld   (__gs_y), a
        ld   hl, (__current_pattern_ptr)
        ld   (__gs_pat_ptr), hl   
        ld   b, 8                 
__gs_col_loop:
        push bc
        ld   hl, 0                
        ld   a, (__gs_x)
        cp   144
        jr   nc, __gs_store       
        ld   a, (__gs_y)
        ld   c, a
        and  7
        ld   (__gs_shift), a      
        ld   a, c
        srl  a
        srl  a
        srl  a
        ld   (__gs_page), a       
        cp   6
        jr   nc, __gs_read_h      
        ld   a, (__gs_x)
        ld   c, a
        ld   a, (__gs_page)
        call __calc_vram_addr
        ld   a, (hl)
        ld   (__gs_data_l), a
        jr   __gs_read_h_cont
__gs_read_h:
        xor  a
        ld   (__gs_data_l), a
__gs_read_h_cont:
        ld   a, (__gs_page)
        inc  a
        cp   6
        jr   nc, __gs_shift_start 
        ld   d, a                 
        ld   a, (__gs_x)
        ld   c, a
        ld   a, d
        call __calc_vram_addr
        ld   h, (hl)              
        ld   a, (__gs_data_l)
        ld   l, a                 
        jr   __gs_do_shift
__gs_shift_start:
        ld   h, 0                 
        ld   a, (__gs_data_l)
        ld   l, a                 
__gs_do_shift:
        ld   a, (__gs_shift)
        or   a
        jr   z, __gs_store    
        ld   b, a
__gs_shift_loop:
        srl  h                    
        rr   l                    
        djnz __gs_shift_loop
__gs_store:
        ld   a, l
        ld   hl, (__gs_pat_ptr)
        ld   (hl), a              
        inc  hl
        ld   (__gs_pat_ptr), hl   
        ld   a, (__gs_x)
        inc  a
        ld   (__gs_x), a
        pop  bc
        djnz __gs_col_loop
        ret                       


; =====================================================================
; g850_plot
;   Input:  L = X (0..143)
;           E = Y (0..47)
;           C = Color
; =====================================================================
g850_plot:
        ld   a, c
        ld   (__px_color), a
        call __prep_vram_and_mask
        ld   a,(__px_color)
        or   a
        jr   z,__do_preset
__do_pset:
        ld   a,(hl)
        ld   b,a
        ld   a,(__px_mask)
        or   b
        ld   (hl),a
        ret
__do_preset:
        ld   a,(__px_mask)
        cpl
        and  (hl)
        ld   (hl),a
        ret


; =====================================================================
; g850_putsprite (8x8)
;   Input:  L = X
;           E = Y
;           C = UseMask (0 = unuse, 1 = use)
; =====================================================================
g850_putsprite:
        ld   a, l   
        ld   (__ps_x), a
        ld   a, e      
        ld   (__ps_y), a
        ld   a, c               
        ld   (__ps_use_mask), a
        ld   b, 8      
        ld   hl, (__current_pattern_ptr)
        ld   (__ps_pat_ptr), hl
        ld   hl, (__mask_pattern_ptr)
        ld   (__ps_mask_ptr), hl
__ps_col_loop:
        push bc              
        ld   a, (__ps_x)
        cp   144
        jp   nc, __ps_next_col  
        ld   a, (__ps_y)
        ld   c, a
        and  7
        ld   b, a
        ld   a, c
        srl  a
        srl  a
        srl  a
        ld   (__ps_page), a
        ld   hl, (__ps_mask_ptr)
        ld   a, (hl)
        ld   hl, (__ps_pat_ptr)
        ld   e, (hl)
        cpl                     
        ld   l, a
        ld   h, 0
        push hl                 
        ld   l, e
        ld   h, 0
        ld   a, b
        or   a
        jr   z, __ps_shift_done
__ps_shift_loop:
        add  hl, hl
        ex   (sp), hl
        add  hl, hl
        ex   (sp), hl
        djnz __ps_shift_loop
__ps_shift_done:
        ld   (__ps_data_l), hl
        pop  de
        ld   a, e
        cpl
        ld   (__ps_mask_l), a
        ld   a, d
        cpl
        ld   (__ps_mask_h), a
        ld   a, (__ps_page)
        cp   6
        jr   nc, __ps_draw_page2
        ld   a, (__ps_x)     
        ld   c, a            
        ld   a, (__ps_page)  
        call __calc_vram_addr   
        ld   a, (__ps_use_mask)
        or   a
        jr   z, __ps_draw_p1_nomask
        ld   a, (__ps_mask_l)
        and  (hl)
        ld   d, a
        ld   a, (__ps_data_l)
        or   d
        ld   (hl), a
        jr   __ps_draw_page2
__ps_draw_p1_nomask:
        ld   a, (__ps_data_l)
        or   (hl)
        ld   (hl), a
__ps_draw_page2:
        ld   a, (__ps_page)
        inc  a
        cp   6
        jr   nc, __ps_next_col
        ld   a, (__ps_x)      
        ld   c, a             
        ld   a, (__ps_page)
        inc  a                
        call __calc_vram_addr    
        ld   a, (__ps_use_mask)
        or   a
        jr   z, __ps_draw_p2_nomask
        ld   a, (__ps_mask_h)
        and  (hl)
        ld   d, a
        ld   a, (__ps_data_h)
        or   d
        ld   (hl), a
        jr   __ps_next_col
__ps_draw_p2_nomask:
        ld   a, (__ps_data_h)
        or   (hl)
        ld   (hl), a
__ps_next_col:
        ld   hl, (__ps_pat_ptr)
        inc  hl
        ld   (__ps_pat_ptr), hl
        ld   hl, (__ps_mask_ptr)
        inc  hl
        ld   (__ps_mask_ptr), hl
        ld   a, (__ps_x)
        inc  a
        ld   (__ps_x), a
        pop  bc
        dec  b
        jp   nz, __ps_col_loop
        ret


; =====================================================================
; g850_repaintlcd
; =====================================================================
g850_repaintlcd:
        ld   c, 0B0h
        ld   hl, __vram
__rpl_page_loop:
        ld   a, c
        out  (40h), a
        xor  a
        out  (40h), a
        ld   a, 10h
        out  (40h), a
        ld   b, 144
        ld   d, c
        ld   c, 41h
__rpl_lcd_loop:
        outi
        jr   nz, __rpl_lcd_loop
        ld   c, d
        inc  c
        ld   a, c
        cp   0B6h
        jr   nz, __rpl_page_loop
        ret


; =====================================================================
; g850_restorebg
; =====================================================================
g850_restorebg:
        ld   hl, (__bg_vram_addr)
        ld   de, __vram   
        ld   bc, 864      
        ldir              
        ret


; =====================================================================
; g850_savebg
; =====================================================================
g850_savebg:
        ld   hl, __vram    
        ld   de, (__bg_vram_addr) 
        ld   bc, 864       
        ldir               
        ret


; =====================================================================
; g850_UpdateLCD
;   Input:  Stack #1 (ix+2) = X1
;           L = Y1
;           E = X2
;           C = Y2
; =====================================================================
g850_updatelcd:
        push ix
        ld   ix, 2
        add  ix, sp
        ld   a, (ix+2)
        call __upd_clip_x
        ld   (__upd_x1), a
        ld   a, l
        call __upd_clip_y
        ld   (__upd_y1), a
        ld   a, e
        call __upd_clip_x
        ld   (__upd_x2), a
        ld   a, c
        call __upd_clip_y
        ld   (__upd_y2), a
        pop  ix
        call __sort_coords
        ld   a, (__upd_y1)
        srl  a 
        srl  a 
        srl  a
        ld   (__upd_p1), a
        ld   a, (__upd_y2)
        srl  a 
        srl  a 
        srl  a
        ld   (__upd_p2), a
        ld   a, (__upd_p1)
        ld   (__upd_cur_p), a
__upd_page_loop:
        ld   a, (__upd_cur_p)
        or   0B0h
        out  (40h), a
        ld   a, (__upd_x1)
        and  0Fh
        out  (40h), a
        ld   a, (__upd_x1)
        srl  a 
        srl  a 
        srl  a 
        srl  a
        or   10h
        out  (40h), a
        ld   a, (__upd_x1)
        ld   c, a
        ld   a, (__upd_cur_p)
        call __calc_vram_addr
        ld   a, (__upd_x1)
        ld   b, a
        ld   a, (__upd_x2)
        sub  b
        inc  a
        ld   b, a
        ld   c, 41h
__upd_lcd_loop:
        outi
        jr   nz, __upd_lcd_loop
        ld   a, (__upd_cur_p)
        ld   b, a
        ld   a, (__upd_p2)
        cp   b
        jp   z, __exit_1arg
        inc  b
        ld   a, b
        ld   (__upd_cur_p), a
        jr   __upd_page_loop
__upd_clip_x:
        cp   192
        jr   c, __clip_x_pos
        xor  a
        ret
__clip_x_pos:
        cp   144
        ret  c
        ld   a, 143
        ret
__upd_clip_y:
        cp   192
        jr   c, __clip_y_pos
        xor  a
        ret
__clip_y_pos:
        cp   48
        ret  c
        ld   a, 47
        ret


; =====================================================================
; g850_get_vram_addr
;   Output: HL = Address
; =====================================================================
g850_get_vram_addr:
        ld   hl, __vram
        ret


; =====================================================================
; g850_get_bg_addr
;   Output: HL = Address
; =====================================================================
g850_get_bg_addr:
        ld   hl, (__bg_vram_addr)
        ret


; =====================================================================
; g850_get_pattern_addr
;   Output: HL = Address
; =====================================================================
g850_get_pattern_addr:
        ld   hl, (__current_pattern_ptr)
        ret


; =====================================================================
; g850_get_mask_addr
;   Output: HL = Address
; =====================================================================
g850_get_mask_addr:
        ld   hl, (__mask_pattern_ptr)
        ret


; =====================================================================
; g850_setbgaddr
;   Input: HL = Address
; =====================================================================
g850_setbgaddr:
        ld   (__bg_vram_addr), hl
        ret	


; =====================================================================
; g850_set_pattern_addr
;   Input: HL = Address
; =====================================================================
g850_set_pattern_addr:
        ld   (__current_pattern_ptr), hl
        ret


; =====================================================================
; g850_set_mask_addr
;   Input: HL = Address
; =====================================================================
g850_set_mask_addr:
        ld   (__mask_pattern_ptr), hl
        ret	

; =====================================================================
; Misc Routine
; =====================================================================
__load_rect_args:
        push ix
        ld   ix, 4
        add  ix, sp
        ld   a, (ix+4)
        ld   (__gr_scratchpad+0), a
        ld   a, (ix+2)
        ld   (__gr_scratchpad+1), a
        ld   a, l
        ld   (__gr_scratchpad+2), a
        ld   a, e
        ld   (__gr_scratchpad+3), a
        ld   a, c
        ld   (__gr_scratchpad+4), a
        pop  ix
        ret
__sort_coords:
        ld   a, (__gr_scratchpad+0)
        ld   hl, __gr_scratchpad+2
        cp   (hl)
        jr   c, __sc_skip_x
        jr   z, __sc_skip_x
        ld   b, (hl)
        ld   (hl), a
        ld   a, b
        ld   (__gr_scratchpad+0), a
__sc_skip_x:
        ld   a, (__gr_scratchpad+1)
        ld   hl, __gr_scratchpad+3
        cp   (hl)
        jr   c, __sc_skip_y
        jr   z, __sc_skip_y
        ld   b, (hl)
        ld   (hl), a
        ld   a, b
        ld   (__gr_scratchpad+1), a
__sc_skip_y:
        ret
__calc_vram_addr:
        ld   h, 0
        ld   l, a
        add  hl, hl
        add  hl, hl
        add  hl, hl
        add  hl, hl
        ld   d, h
        ld   e, l
        add  hl, hl
        add  hl, hl
        add  hl, hl
        add  hl, de
        ld   d, 0
        ld   e, c
        add  hl, de
        ld   de, __vram
        add  hl, de
        ret
__exit_2args:
        pop  hl
        pop  bc
        pop  bc
        jp   (hl)
__exit_1arg:
        pop  hl
        pop  bc
        jp   (hl)
__setup_fill_masks:
        ld   a, (__gr_scratchpad+0)
        ld   (__gr_scratchpad+5), a
        ld   a, (__gr_scratchpad+1)
        srl  a 
        srl  a 
        srl  a
        ld   (__gr_scratchpad+7), a
        ld   a, (__gr_scratchpad+3)
        srl  a 
        srl  a 
        srl  a
        ld   (__gr_scratchpad+8), a
        ld   a, (__gr_scratchpad+1)
        and  7
        ld   e, a
        ld   d, 0
        ld   hl, __fp_top_mask_tbl
        add  hl, de
        ld   a, (hl)
        ld   (__gr_scratchpad+9), a
        ld   a, (__gr_scratchpad+3)
        and  7
        ld   e, a
        ld   d, 0
        ld   hl, __fp_bot_mask_tbl
        add  hl, de
        ld   a, (hl)
        ld   (__gr_scratchpad+10), a
        ret
__fill_column:
        ld   a, (__gr_scratchpad+7) 
        ld   hl, __gr_scratchpad+8  
        cp   (hl)
        jr   nz, __fc_multi_page
__fc_single_page:
        ld   a, (__gr_scratchpad+9) 
        ld   hl, __gr_scratchpad+10 
        and  (hl)
        ld   b, a
        ld   a, (__gr_scratchpad+5) 
        ld   c, a
        ld   a, (__gr_scratchpad+7) 
        call __calc_vram_addr
        ld   a, b
        cpl
        and  (hl)
        ld   e, a
        ld   a, (__gr_scratchpad+6) 
        and  b
        or   e
        ld   (hl), a
        ret
__fc_multi_page:
        ld   a, (__gr_scratchpad+5)
        ld   c, a
        ld   a, (__gr_scratchpad+7)
        call __calc_vram_addr
        ld   a, (__gr_scratchpad+9)
        ld   d, a
        cpl
        and  (hl)
        ld   e, a
        ld   a, (__gr_scratchpad+6)
        and  d
        or   e
        ld   (hl), a
        ld   a, (__gr_scratchpad+7)
        inc  a
        ld   b, a
        ld   a, (__gr_scratchpad+8)
        cp   b
        jr   z, __fc_bottom_page
__fc_mid_loop:
        ld   de, 144
        add  hl, de
        ld   a, (__gr_scratchpad+6)
        ld   (hl), a
        inc  b
        ld   a, (__gr_scratchpad+8)
        cp   b
        jr   nz, __fc_mid_loop
__fc_bottom_page:
        ld   a, (__gr_scratchpad+5)
        ld   c, a
        ld   a, (__gr_scratchpad+8)
        call __calc_vram_addr
        ld   a, (__gr_scratchpad+10)
        ld   d, a
        cpl
        and  (hl)
        ld   e, a
        ld   a, (__gr_scratchpad+6)
        and  d
        or   e
        ld   (hl), a
        ret
__prep_vram_and_mask:
        ld   a,l
        ld   (__x_raw),a
        ld   a,e
        srl  a
        srl  a
        srl  a
        ld   (__y_page),a
        ld   b,a
        ld   a,e
        and  7
        push hl
        ld   hl,__mask_table
        ld   d,0
        ld   e,a
        add  hl,de
        ld   a,(hl)
        ld   (__px_mask),a
        pop  hl
        ld   l,b  
        ld   h,0  
        add  hl,hl
        add  hl,hl
        add  hl,hl
        add  hl,hl
        ld   c,l
        ld   b,h  
        add  hl,hl
        add  hl,hl
        add  hl,hl
        add  hl,bc
        ld   a,(__x_raw)
        ld   e,a
        ld   d,0      
        add  hl,de    
        ld   de,__vram
        add  hl,de    
        ret
	
	
; =====================================================================
; Shared Scratchpad
; =====================================================================
__gr_scratchpad: .ds 11

; --- g850_box ---
__bx_x1      equ __gr_scratchpad + 0
__bx_y1      equ __gr_scratchpad + 1
__bx_x2      equ __gr_scratchpad + 2
__bx_y2      equ __gr_scratchpad + 3
__bx_color   equ __gr_scratchpad + 4
__bx_cur     equ __gr_scratchpad + 5

; --- g850_circle ---
__cx_xc      equ __gr_scratchpad + 0
__cx_yc      equ __gr_scratchpad + 1
__cx_r       equ __gr_scratchpad + 2
__cx_color   equ __gr_scratchpad + 3

; --- g850_draw ---
__dr_x1      equ __gr_scratchpad + 0
__dr_y1      equ __gr_scratchpad + 1
__dr_x2      equ __gr_scratchpad + 2
__dr_y2      equ __gr_scratchpad + 3
__dr_color   equ __gr_scratchpad + 4
__dr_dx      equ __gr_scratchpad + 5
__dr_dy      equ __gr_scratchpad + 6
__dr_step_x  equ __gr_scratchpad + 7
__dr_step_y  equ __gr_scratchpad + 8
__dr_err     equ __gr_scratchpad + 9

; --- g850_fillbox & g850_fillpattern ---
__fb_color   equ __gr_scratchpad + 4
__fb_cur_x   equ __gr_scratchpad + 5
__fb_col_byte equ __gr_scratchpad + 6
__fb_x2      equ __gr_scratchpad + 2
__fp_color   equ __gr_scratchpad + 4
__fp_cur_x   equ __gr_scratchpad + 5
__fp_col_byte equ __gr_scratchpad + 6
__fp_x2      equ __gr_scratchpad + 2

; --- g850_fillshape ---
__fs_start_x equ __gr_scratchpad + 0
__fs_start_y equ __gr_scratchpad + 1
__fs_color   equ __gr_scratchpad + 2
__fs_target_color equ __gr_scratchpad + 3
__fs_sp      equ __gr_scratchpad + 4

; --- g850_getsprite ---
__gs_x       equ __gr_scratchpad + 0
__gs_y       equ __gr_scratchpad + 1
__gs_page    equ __gr_scratchpad + 2
__gs_shift   equ __gr_scratchpad + 3
__gs_pat_ptr equ __gr_scratchpad + 4
__gs_data_l  equ __gr_scratchpad + 6

; --- g850_putsprite ---
__ps_x       equ __gr_scratchpad + 0
__ps_y       equ __gr_scratchpad + 1
__ps_page    equ __gr_scratchpad + 2
__ps_data_l  equ __gr_scratchpad + 3
__ps_data_h  equ __gr_scratchpad + 4
__ps_pat_ptr equ __gr_scratchpad + 5
__ps_mask_l  equ __gr_scratchpad + 7
__ps_mask_h  equ __gr_scratchpad + 8
__ps_mask_ptr equ __gr_scratchpad + 9

; --- g850_updatelcd ---
__upd_x1     equ __gr_scratchpad + 0
__upd_y1     equ __gr_scratchpad + 1
__upd_x2     equ __gr_scratchpad + 2
__upd_y2     equ __gr_scratchpad + 3
__upd_p1     equ __gr_scratchpad + 4
__upd_p2     equ __gr_scratchpad + 5
__upd_cur_p  equ __gr_scratchpad + 6


; =====================================================================
; Local Scratchpad
; =====================================================================
__x_raw:        .db 0
__y_page:       .db 0
__px_color:     .db 0
__px_mask:      .db 0           
__ps_use_mask:  .ds 1
__mask_table:   .db  001h, 002h, 004h, 008h, 010h, 020h, 040h, 080h
__current_pattern_ptr: .dw __current_pattern
__mask_pattern_ptr:    .dw __mask_pattern
__current_pattern:     .db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
__mask_pattern:     .db 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
__fp_top_mask_tbl: .db 0FFh, 0FEh, 0FCh, 0F8h, 0F0h, 0E0h, 0C0h, 080h
__fp_bot_mask_tbl: .db 001h, 003h, 007h, 00Fh, 01Fh, 03Fh, 07Fh, 0FFh
__fs_stack:     .ds 128
__vram:         .ds 864 
__bg_vram_addr: .ds 2
