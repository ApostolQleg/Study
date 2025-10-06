#include <stdio.h>
#include <math.h>

int main(void)
{
    int n;
    printf("Enter n: ");
    scanf("%d", &n);
    double P = 1.0; // +1 для ініціалізацій P
    int S = 0;      // +1 для ініціалізації S
    int ops = 3;    // +1 для ініціалізації i; початкова кількість операцій = 3

    for (int i = 1; i <= n; i++) // +1 для <=, +1 для ++ (+2 операції на кожну ітерацію)
    {
        S += (2 * i) + 1;              // +1 для +, +1 для *, +1 для =
        P *= (2 * i * log(i + 3)) / S; // +2 для *, +1 для ln, +1 для +, +1 для /, +1 для =
        ops += 11;                     // +11 до кількості операцій
    }
    printf("P = %.7lf\n", P);
    printf("Number of operations: %d\n", ops);
    return 0;
}