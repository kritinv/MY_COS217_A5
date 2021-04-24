/*--------------------------------------------------------------------*/
/* mywcstr2.c                                                         */
/* Author: Kritin Vongthongsri                                        */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
   int i;
   char random;
   int charPerLine;
   int charPerLineCount = 0;
   int maxLines = 1000;
   int maxChar = 50000;

   charPerLine = maxChar / maxLines;
   for (i = 0; i < maxLines; i++) {
      charPerLineCount = 0;
      while (charPerLineCount < charPerLine - 1) {
         random = rand() % 0x7F;
         if (random == 0x09 || (random >= 0x20 && random <= 0x7E)) {
            putchar(random);
            charPerLineCount++;
         }
      }
      if (i != maxLines-1) {
         putchar('\n');
      }
   }
   return 0;
}
