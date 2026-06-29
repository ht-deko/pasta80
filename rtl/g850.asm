;
; Print character to screen
;
__putc:
		ret
    
;
; Print string to screen
;
__puts:
		ret
		
;
; New line
;
__newline:
                ret

;
; Read Key
;
__readkey:
                ret

;
; Get Line
;
__getline:
                ret


;
; Startup
;
__init:         
                call    main

;
; Shutdown
;
__done:         rst     0

