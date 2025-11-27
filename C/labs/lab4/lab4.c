#include <stdio.h>

int search(double diag[], int n, double x)
{
    int L = 0, R = n - 1;
    while (L < R)
    {
        int M = (L + R) / 2;
        if (diag[M] <= x)
        {
            R = M;
        }
        else
        {
            L = M + 1;
        }
    }
    if (diag[L] == x)
        return L;
    else
        return -1;
}

int main()
{
    int n;
    printf("Enter matrix size n (for A[n,n]): ");
    scanf("%d", &n);

    double A[n][n];
    printf("Enter matrix elements (main diagonal sorted in non-increasing order):\n");

    for (int i = 0; i < n; i++)
    {
        printf("Row %d:\n", i + 1);
        for (int j = 0; j < n; j++)
        {
            scanf("%lf", &A[i][j]);
        }
    }

    double diag[n];
    for (int i = 0; i < n; i++)
        diag[i] = A[i][i];

    double x;
    printf("Enter value X to search for on main diagonal: ");
    scanf("%lf", &x);

    int pos = search(diag, n, x);

    if (pos != -1)
        printf("Found X on main diagonal at position (row %d, column %d)\n", pos + 1, pos + 1);
    else
        printf("X not found on the main diagonal\n");

    return 0;
}