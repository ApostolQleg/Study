#include "cs50.h"
#include <math.h>
#include <stdio.h>

void checksum(int sum, long num);

int main(void)
{
    long num = 0;
    long power = 0;
    int sum = 0;
    int sum1 = 0;
    int sum2 = 0;
    do
    {
        num = get_long("Number: ");
    }
    while (num < 1);

    for (int i = 1; power < num; i++)
    {
        power = pow(10, i);
        long digit = num % power;
        digit = 10 * ((digit - (digit % (power / 10))) % power) / power;
        if (i % 2 == 0)
        {
            digit = digit * 2;
            if (digit > 9)
            {
                digit = ((digit - (digit % 10)) / 10) + (digit % 10);
                sum1 = sum1 + digit;
            }
            else
            {
                sum1 = sum1 + digit;
            }
        }
        else
        {
            sum2 = sum2 + digit;
        }
        sum = sum1 + sum2;
    }
    checksum(sum, num);
}
void checksum(int sum, long num)
{
    if (sum % 10 == 0)
    {
        if (num >= pow(10, 14) && num < pow(10, 15))
        {
            num = (num / pow(10, 13));
            if (num == 34 || num == 37)
            {
                printf("AMEX\n");
            }
            else
            {
                printf("INVALID\n");
            }
        }
        else if (num >= pow(10, 12) && num < pow(10, 13))
        {
            num = (num / pow(10, 12));
            if (num == 4)
            {
                printf("VISA\n");
            }
            else
            {
                printf("INVALID\n");
            }
        }
        else if (num >= pow(10, 15) && num < pow(10, 16))
        {
            num = (num / pow(10, 14));
            if (num > 39 && num < 50)
            {
                printf("VISA\n");
            }
            else if (num > 50 && num < 56)
            {
                printf("MASTERCARD\n");
            }
            else
            {
                printf("INVALID\n");
            }
        }
        else
        {
            printf("INVALID\n");
        }
    }
    else
    {
        printf("INVALID\n");
    }
}
