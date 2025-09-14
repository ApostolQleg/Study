#include "cs50.h"
#include <stdio.h>

void pp(int spcs, int brcs);

int main(void)
{
    int h;
    do
    {
        h = get_int("Height: ");
    }
    while (h < 1);

    for (int i = 0; i < h; i++)
    {
        int j = i + 1;
        pp(h - j, j);
    }
}

void pp(int spcs, int brcs)
{
    for (int i = 0; i < spcs; i++)
    {
        printf(" ");
    }
    for (int j = 0; j < brcs; j++)
    {
        printf("#");
    }
    printf("  ");

    for (int j = 0; j < brcs; j++)
    {
        printf("#");
    }
    printf("\n");
}
