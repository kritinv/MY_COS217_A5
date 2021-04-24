/*--------------------------------------------------------------------*/
/* bigintadd.s                                                        */
/* Author: Kritin Vongthongsri                                        */
/*--------------------------------------------------------------------*/

#include "bigint.h"
#include "bigintprivate.h"
#include <string.h>
#include <assert.h>

//----------------------------------------------------------------------

        .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss

//----------------------------------------------------------------------        

        .section .text

        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ BIGINT_LARGER_STACK_BYTECOUNT, 32

BigInt_larger:

        // Prolog (long lLarger)
        sub     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        str     x30, [sp]    // Save x30
        str     x0, [sp, 16] // Save lLength1
        str     x1, [sp, 8]  // Save lLength2

        // if (lLength1 <= lLength2) goto else1
        ldr     x0, [sp, 16]
        ldr     x1, [sp, 8]
        cmp     x0, x1
        ble     else1

        // lLarger = lLength1
        ldr     x0, [sp, 16]
        str     x0, [sp, 24]

        // goto endif1          
        b       endif1

else1:
        
        // lLarger = lLength2
        ldr     x0, [sp, 8]
        str     x0, [sp, 24]

endif1:
        
        // return lLarger
        ldr     x30, [sp] // Restore x30
        add     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        ret


        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum. oSum should
        // be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if
        // an overflow occurred, and 1 (TRUE) otherwise. 
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    BIGINT_ADD_STACK_BYTECOUNT, 64

        // Enumerated constants
        .equ    FALSE, 0
        .equ    TRUE, 1

        // Local variable stack offets
        .equ    LSUMLENGTH, 8
        .equ    LINDEX, 16
        .equ    ULSUM, 24
        .equ    ULCARRY, 32

        // Parameter stack offsets
        .equ    OSUM, 40
        .equ    OADDEND2, 48
        .equ    OADDEND1, 56

        // Structure field offsets
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8

        // Max digit
        .equ    MAX_DIGITS, 32768

        .global BigInt_add
        
BigInt_add:

        // Prolog (long lLarger)
        sub     sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        str     x30, [sp] // Save x30
        str     x0, [sp, OADDEND1] // Save oAddend1
        str     x1, [sp, OADDEND2] // Save oAddend2
        str     x2, [sp, OSUM]  // Save oSum
        
        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength)
        ldr     x0, [sp, OADDEND1]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, OADDEND2]
        ldr     x1, [x1, LLENGTH]
        bl      BigInt_larger
        str     x0, [sp, LSUMLENGTH]

        // if (oSum->lLength <= lSumLength) goto endif2
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        ble     endif2

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long))
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        mov     x1, 0
        mov     x3, MAX_DIGITS
        mov     x4, 8
        mul     x2, x3, x4
        bl      memset

endif2:
        
        // ulCarry = 0
        mov     x0, 0
        str     x0, [sp, ULCARRY] 
        
        // lIndex = 0
        mov     x0, 0
        str     x0, [sp, LINDEX]

loop:

        // if (lIndex >= lSumLength) goto endloop
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bge     endloop

        // ulSum = ulCarry
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]

        // ulCarry = 0
        mov     x0, 0
        str     x0, [sp, ULCARRY]

        // ulSum += oAddend1->aulDigits[lIndex]
        ldr     x0, [sp, OADDEND1]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        add     x1, x1, x0
        str     x1, [sp, ULSUM]

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif3
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND1]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x1, [x1, x2, lsl 3]
        cmp     x0, x1
        bhs     endif3

        // ulCarry = 1
        mov     x0, 1
        str     x0, [sp, ULCARRY]

endif3:

        // ulSum += oAddend2->aulDigits[lIndex]
        ldr     x0, [sp, OADDEND2]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LINDEX]
        ldr     x0, [x0, x1, lsl 3]
        ldr     x1, [sp, ULSUM]
        add     x1, x1, x0
        str     x1, [sp, ULSUM]

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif4
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND2]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        ldr     x1, [x1, x2, lsl 3]
        cmp     x0, x1
        bhs     endif4

        // ulCarry = 1
        mov     x0, 1
        str     x0, [sp, ULCARRY]

endif4:
        
        // oSum->aulDigits[lIndex] = ulSum
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OSUM]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        str     x0, [x1, x2, lsl 3]
        
        // lIndex++
        ldr     x0, [sp, LINDEX]
        add     x0, x0, 1
        str     x0, [sp, LINDEX]
        
        // goto loop
        b       loop

endloop:

        // if (ulCarry != 1) goto endif5
        ldr     x0, [sp, ULCARRY]
        mov     x1, 1
        cmp     x0, x1
        bne     endif5

        // if (lSumLength != MAX_DIGITS) goto endif6
        ldr     x0, [sp, LSUMLENGTH]
        mov     x1, MAX_DIGITS
        cmp     x0, x1
        bne     endif6
        
        // return FALSE
        mov     x0, FALSE
        ldr     x30, [sp] // Restore x30
        add     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        ret

endif6:
        
        // oSum->aulDigits[lSumLength] = 1
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        ldr     x1, [sp, LSUMLENGTH]
        mov     x2, 1
        str     x2, [x0, x1, lsl 3]
        
        //lSumLength++
        ldr     x0, [sp, LSUMLENGTH]
        add     x0, x0, 1
        str     x0, [sp, LSUMLENGTH]

endif5:
        
        // oSum->lLength = lSumLength
        ldr     x0, [sp, OSUM]
        mov     x1, LLENGTH
        add     x0, x0, x1
        ldr     x2, [sp, LSUMLENGTH]
        str     x2, [x0, x1, lsl 3]

        // return TRUE;
        mov     x0, TRUE
        ldr     x30, [sp] // Restore x30
        add     sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        ret

    
