/*--------------------------------------------------------------------*/
/* mywcflat.s                                                         */
/* Author: Kritin Vongthongsri                                        */
/*--------------------------------------------------------------------*/

        .section .rodata

printfFormatStr:
        .string "%7ld %7ld %7ld\n"

/*--------------------------------------------------------------------*/
        
        .section .data

lPower:
        .quad   0
        
lWordCount:
        .quad   0
        
lCharCount:     
        .quad   0

lLineCount:
        .quad   0
                                                                                                 
iInWord:
        .word   FALSE
        
/*--------------------------------------------------------------------*/

        .section .bss

iChar:
        .skip   4
        
/*--------------------------------------------------------------------*/

        .section .text

        //--------------------------------------------------------------
        // Write to stdout counts of how many lines, words, and characters
        // are in stdin. A word is a sequence of non-whitespace characters.
        // Whitespace is defined by the isspace() function. Return 0. */
        // int main(void)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16
        .equ    FALSE, 0
        .equ    TRUE, 1

        .global main

main:

        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

charLoop:       
        
        // if ((iChar = getchar()) == EOF) goto charLoopEnd)
        bl      getchar
        adr     x1, iChar
        str     w0, [x1]
        cmp     w0, -1
        beq     charLoopEnd

        // lCharCount++;
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // if (!isspace(iChar)) goto elseNotSpace
        adr     x0, iChar
        ldr     w0, [x0]
        bl      isspace
        cbz     w0, elseNotSpace

        // if (!iInWord) goto nullCheck
        adr     x0, iInWord
        ldr     w0, [x0]
        cbz     w0, nullCheck

        //lWordCount++
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        
        // iInWord = FALSE
        adr     x0, iInWord
        mov     w1, FALSE
        str     w1, [x0]
        
        // goto nullCheck
        b       nullCheck
        
elseNotSpace:

        // if (iInWord) goto nullCheck 
        adr     x0, iInWord
        ldr     w0, [x0]
        cbnz    w0, nullCheck

        // iInWord = TRUE
        adr     x0, iInWord
        mov     w1, TRUE
        str     w1, [x0]
        
nullCheck:
        
        // if (iChar != '\n') goto charLoop;
        adr     x0, iChar
        ldr     w0, [x0]
        cmp     w0, 10
        bne     charLoop

        // lLineCount++ 
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        
        // goto charLoop
        b       charLoop

charLoopEnd:
        
        // if (!iInWord) goto print
        adr     x0, iInWord
        ldr     w0, [x0]
        cbz     w0, print
        
        //lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]
        
print:
        
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, printfFormatStr
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf

        // Epilog and return 0;
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
