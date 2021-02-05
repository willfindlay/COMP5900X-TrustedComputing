const unsigned long kaddr = 0xffffffffb7031310UL;  // extern long saved_magic

inline void clflush(volatile void *p)
{
    asm volatile("clflush (%0)" ::"r"(p));
}

inline unsigned long rdtsc()
{
    unsigned long a, d;
    asm volatile("rdtsc" : "=a"(a), "=d"(d));
    return a | ((unsigned long)d << 32);
}

int main()
{
    return 0;
}
