; Test Score Calculator
; Author: [The Squad]

            .ORIG x3000

MAIN        JSR INIT_STACK
            JSR INPUT_SCORES
            JSR FIND_MIN_MAX
            JSR CALC_AVG
            JSR DISPLAY_RESULTS
            HALT

; Data Section

SCORES      .BLKW 5
MIN         .FILL #0
MAX         .FILL #0
AVG         .FILL #0
PROMPT      .STRINGZ "Enter score (0-100): "
MIN_MSG     .STRINGZ "\nMin: "
MAX_MSG     .STRINGZ "\nMax: "
AVG_MSG     .STRINGZ "\nAvg: "
GRADE_MSG   .STRINGZ " ("
NL          .STRINGZ ")\n"

; Subroutines

INIT_STACK  LD R6, STACK_BASE
            RET
STACK_BASE  .FILL x4000

INPUT_SCORES
            ST R7, SAVE_R7_IN
            AND R1, R1, #0      ; i = 0
            LD R2, SCORES_PTR
            
INPUT_LOOP  LEA R0, PROMPT
            PUTS
            
            ; Input tens digit
            GETC
            OUT
            JSR ASCII_TO_NUM
            ADD R3, R0, #0
            
            ; Input ones digit
            GETC
            OUT
            JSR ASCII_TO_NUM
            
            ; Combine digits (R3*10 + R0)
            ADD R4, R3, R3      ; 2*R3
            ADD R4, R4, R4      ; 4*R3
            ADD R4, R4, R4      ; 8*R3
            ADD R4, R4, R3      ; 9*R3
            ADD R4, R4, R3      ; 10*R3
            ADD R0, R4, R0
            
            STR R0, R2, #0
            ADD R2, R2, #1
            ADD R1, R1, #1
            ADD R3, R1, #-5     ; i < 5?
            BRn INPUT_LOOP
            
            LD R7, SAVE_R7_IN
            RET

ASCII_TO_NUM
            ADD R0, R0, #-16
            ADD R0, R0, #-16
            ADD R0, R0, #-16
            RET

FIND_MIN_MAX
            ST R7, SAVE_R7_MM
            LD R1, SCORES_PTR
            LDR R2, R1, #0      ; min
            LDR R3, R1, #0      ; max
            AND R4, R4, #0      ; i=0
            
MM_LOOP     LDR R0, R1, #0
            
            ; Check min
            NOT R5, R0
            ADD R5, R5, #1
            ADD R5, R2, R5      ; min - score
            BRn NOT_MIN
            ADD R2, R0, #0      ; new min
NOT_MIN     
            ; Check max
            NOT R5, R0
            ADD R5, R5, #1
            ADD R5, R3, R5      ; max - score
            BRzp NOT_MAX
            ADD R3, R0, #0      ; new max
NOT_MAX     
            ADD R1, R1, #1
            ADD R4, R4, #1
            ADD R5, R4, #-5
            BRn MM_LOOP
            
            ST R2, MIN
            ST R3, MAX
            LD R7, SAVE_R7_MM
            RET

CALC_AVG    ST R7, SAVE_R7_AVG
            LD R1, SCORES_PTR
            AND R2, R2, #0      ; sum=0
            AND R3, R3, #0      ; i=0
            
SUM_LOOP    LDR R0, R1, #0
            ADD R2, R2, R0
            ADD R1, R1, #1
            ADD R3, R3, #1
            ADD R4, R3, #-5
            BRn SUM_LOOP
            
            ; Division by 5
            AND R0, R0, #0      ; quotient=0
DIV_LOOP    ADD R0, R0, #1
            ADD R2, R2, #-5
            BRzp DIV_LOOP
            ADD R0, R0, #-1     ; fix overshoot
            ST R0, AVG
            LD R7, SAVE_R7_AVG
            RET

DISPLAY_RESULTS
            ST R7, SAVE_R7_DISP
            LEA R0, MIN_MSG
            PUTS
            LD R0, MIN
            JSR DISPLAY_NUM
            LD R0, MIN          ; Explicitly load MIN before grade display
            JSR DISPLAY_GRADE
            
            LEA R0, MAX_MSG
            PUTS
            LD R0, MAX
            JSR DISPLAY_NUM
            LD R0, MAX          ; Explicitly load MAX before grade display
            JSR DISPLAY_GRADE
            
            LEA R0, AVG_MSG
            PUTS
            LD R0, AVG
            JSR DISPLAY_NUM
            LD R0, AVG          ; Explicitly load AVG before grade display
            JSR DISPLAY_GRADE
            
            LD R7, SAVE_R7_DISP
            RET

DISPLAY_NUM
            ST R7, SAVE_R7_NUM
            ADD R1, R0, #0
            
            ; Check for 100
            ADD R0, R1, #-16
            ADD R0, R0, #-16
            ADD R0, R0, #-16
            ADD R0, R0, #-16
            ADD R0, R0, #-16
            ADD R0, R0, #-16    ; -96
            ADD R0, R0, #-4     ; -100
            BRnp NOT_100
            LD R0, ASCII_1
            OUT
            LD R0, ASCII_0
            OUT
            OUT
            BRnzp NUM_DONE
            
NOT_100     AND R0, R0, #0
TENS_LOOP   ADD R0, R0, #1
            ADD R1, R1, #-10
            BRzp TENS_LOOP
            
            ADD R0, R0, #-1
            ADD R1, R1, #10
            ADD R2, R0, #0
            
            ; Print tens digit if >0
            BRz ONES_DIGIT
            LD R3, ASCII_0
            ADD R0, R2, R3
            OUT
            
ONES_DIGIT  LD R3, ASCII_0
            ADD R0, R1, R3
            OUT
            
NUM_DONE    LD R7, SAVE_R7_NUM
            RET

DISPLAY_GRADE
            ST R7, SAVE_R7_GRADE
            ST R0, TEMP_SCORE    ; Store the score value
            LEA R0, GRADE_MSG
            PUTS
            
            ; Load the score value
            LD R1, TEMP_SCORE
            
            ; Check for A (>=90)
            ADD R1, R1, #0       ; Make sure R1 is positive
            LD R2, NEG_90        ; Load -90
            ADD R2, R1, R2       ; score - 90
            BRn CHECK_B           ; If negative, grade < 90
            LD R0, A_GRADE
            OUT
            BRnzp GRADE_DONE
            
CHECK_B     ; Check for B (>=80)
            LD R2, NEG_80        ; Load -80
            ADD R2, R1, R2       ; score - 80
            BRn CHECK_C           ; If negative, grade < 80
            LD R0, B_GRADE
            OUT
            BRnzp GRADE_DONE
            
CHECK_C     ; Check for C (>=70)
            LD R2, NEG_70        ; Load -70
            ADD R2, R1, R2       ; score - 70
            BRn CHECK_D           ; If negative, grade < 70
            LD R0, C_GRADE
            OUT
            BRnzp GRADE_DONE
            
CHECK_D     ; Check for D (>=60)
            LD R2, NEG_60        ; Load -60
            ADD R2, R1, R2       ; score - 60
            BRn F_GRADE           ; If negative, grade < 60
            LD R0, D_GRADE
            OUT
            BRnzp GRADE_DONE
            
F_GRADE     LD R0, F_GRADE_VAL
            OUT
            
GRADE_DONE  LEA R0, NL
            PUTS
            LD R7, SAVE_R7_GRADE
            RET

; Constants

ASCII_0     .FILL x30
ASCII_1     .FILL x31
A_GRADE     .FILL x41
B_GRADE     .FILL x42
C_GRADE     .FILL x43
D_GRADE     .FILL x44
F_GRADE_VAL .FILL x46
NEG_90      .FILL #-90
NEG_80      .FILL #-80
NEG_70      .FILL #-70
NEG_60      .FILL #-60

; Save Registers and Temporary Storage

SAVE_R7_IN  .BLKW 1
SAVE_R7_MM  .BLKW 1
SAVE_R7_AVG .BLKW 1
SAVE_R7_DISP .BLKW 1
SAVE_R7_NUM .BLKW 1
SAVE_R7_GRADE .BLKW 1
TEMP_SCORE  .BLKW 1             ; Added temporary storage for score

SCORES_PTR  .FILL SCORES

            .END