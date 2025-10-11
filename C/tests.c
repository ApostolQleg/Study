#include <stdio.h>
#include <math.h>

int main(void)
{
    int n;
    printf("Enter n: ");
    scanf("%d", &n);
    double P = 1.0;
    int count = 0;

    for (int i = 1; i <= n; i++)
    {
        double S = 0;

        for (int j = 1; j <= i; j++)
        {
            S += j * sin(j) + j;
            count += 6;
        }

        P *= i * sqrt(i) / S;
        count += 6;
    }

    printf("P = %.7lf\nNumber of operations: %d\n", P, count);
    return 0;
}