#include <errno.h>
/*
   + * sbrk -- changes heap size size. Get nbytes more
   + *         RAM. We just increment a pointer in what's
   + *         left of memory on the board.
   + */

/* Provided by the linker script.  */
extern char __heap_start[] __attribute__ ((aligned (8)));
extern char __heap_end[] __attribute__ ((aligned (8)));

void *
sbrk (int nbytes)
{
  static char *heap = __heap_start;
  char *base = heap;
  char *new_heap = heap + nbytes;
  
  if (nbytes < 0 || new_heap > __heap_end)
    {
      errno = ENOMEM;
      return (void *)-1;
    }
  heap = new_heap;
  return base;
}
