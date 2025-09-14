#include "cs50.h"
#include <stdio.h>

void pr(int spaces, int bricks);

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
        pr(h - j, j);
    }
}

void pr(int spaces, int bricks)
{
    for (int i = 0; i < spaces; i++)
    {
        printf(" ");
    }
    for (int j = 0; j < bricks; j++)
    {
        printf("#");
    }
    printf("\n");
}
