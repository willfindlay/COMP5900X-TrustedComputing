int my_fn(int foo)
{
    return foo * foo;
}

int main()
{
    int (*fn_ptr)(int) = &my_fn;
    fn_ptr(42);
}
