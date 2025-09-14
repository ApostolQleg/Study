#include "cs50.h"
#include <stdio.h>

int calc(int coins);

int main(void)
{
    int change;
    do
    {
        change = get_int("Change owed: ");
    }
    while (change < 0);

    int c = calc(change);
    printf("%i\n", c);
}

int calc(int coins)
{
    int c = 0;
    while (coins >= 25)
    {
        coins -= 25;
        c++;
    }
    while (coins >= 10)
    {
        coins -= 10;
        c++;
    }
    while (coins >= 5)
    {
        coins -= 5;
        c++;
    }
    c = c + coins;
    return c;
}
