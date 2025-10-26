#include <stdio.h>
#include <math.h>

int main(void)
{
    int n;
    printf("Enter n: ");
    scanf("%d", &n);
    double P = 1.0;
    int ops = 0; // початкова кількість операцій = 0

    for (int i = 1; i <= n; i++) // +1 для <=, +1 для ++ (+2 операції на кожну ітерацію)
    {
        int S = 0;

        for (int j = 1; j <= i; j++) // +1 для <=, +1 для ++ (+2 операції на кожну ітерацію)
        {
            S += (2 * j) + 1; // +1 для +, +1 для *, +1 для +=
            ops += 5;         // +5 до кількості операцій
        }

        P *= (2 * i * log(i + 3)) / S; // +2 для *, +1 для ln, +1 для +, +1 для /, +1 для *=
        ops += 8;                      // +8 до кількості операцій
    }

    printf("P = %.7lf\nNumber of operations: %d\n", P, ops);
    return 0;
}