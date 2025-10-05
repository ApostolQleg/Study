#include <stdio.h>
#include <math.h>

int main(void)
{
    double n;
    printf("Enter n: ");
    scanf("%lf", &n);
    double P = 1.0;
    int operations = 0;
    for (int i = 1; i <= n; i++)
    {
        int S = 0;
        for (int j = 1; j <= i; j++)
        {
            S += (2 * j) + 1;
            operations += 3; // 1 для додавання, 1 для множення, 1 для присвоєння
        }
        P *= (2 * i * log(i + 3)) / S;
        operations += 6; // 2 для множення, 1 для ln, 1 для додавання, 1 для ділення, 1 для присвоєння
    }
    printf("P = %.7lf\n", P);
    printf("Number of operations: %d\n", operations);
    return 0;
}