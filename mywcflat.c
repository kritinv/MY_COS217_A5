/*--------------------------------------------------------------------*/
/* mywcflat.c                                                         */
/* Author: Kritin Vongthongsri                                        */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>


/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
charLoop:
   if ((iChar = getchar()) == EOF) goto charLoopEnd;
   lCharCount++;
   if (!isspace(iChar)) goto elseNotSpace;
   if (!iInWord) goto nullCheck;
   lWordCount++;
   iInWord = FALSE;   
   goto nullCheck;
elseNotSpace:
   if (iInWord) goto nullCheck;
   iInWord = TRUE;
nullCheck:
   if (iChar != '\n') goto charLoop;
   lLineCount++;
   goto charLoop; 
charLoopEnd:
   if (!iInWord) goto print;
   lWordCount++;
print:
   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
