#include <stdio.h>
#include <unistd.h>

int main()
{
    char *hello = "Hello, World!\n";
    while (*hello != '\0')
    {
        printf("%c", *hello++);
        usleep(50000); // Sleep for 50 milliseconds
    }
    return 0;
}