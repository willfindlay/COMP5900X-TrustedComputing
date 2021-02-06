#include <stdio.h>

#define BITS_PER_LONG 64
#define SIZE          256
int i = 0;
int arr[SIZE] = {};

static inline unsigned long
array_index_mask_nospec(unsigned long index, unsigned long size)
{
    return ~(long)(index | (size - 1UL - index)) >> 63;
}

static inline unsigned long
sanitize_address(unsigned long index, unsigned long size)
{
    return index & array_index_mask_nospec(index, size);
}

int main()
{
    i = 0;
    i &= ~(long)(i | (SIZE - 1UL - i)) >> 63;
    printf("i = %d\n", i);

    i = 10;
    i &= ~(long)(i | (SIZE - 1UL - i)) >> 63;
    printf("i = %d\n", i);

    i = 255;
    i &= ~(long)(i | (SIZE - 1UL - i)) >> 63;
    printf("i = %d\n", i);

    i = 256;
    i &= ~(long)(i | (SIZE - 1UL - i)) >> 63;
    printf("i = %d\n", i);

    i = 300;
    i &= ~(long)(i | (SIZE - 1UL - i)) >> 63;
    printf("i = %d\n", i);

    i = 30000;
    i &= ~(long)(i | (SIZE - 1UL - i)) >> 63;
    printf("i = %d\n", i);

    return 0;
}
