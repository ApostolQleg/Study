#include <stdio.h>

int main()
{
    int n;
    printf("Enter matrix size n (for A[n,n]): ");
    scanf("%d", &n);

    int A[n][n];

    for (int i = 0; i < n; i++)
    {
        printf("Row %d:\n", i + 1);
        for (int j = 0; j < n; j++)
        {
            scanf("%d", &A[i][j]);
        }
    }

    for (int i = 1; i < n; i++)
    {
        int T = A[i][i];
        int L = 0, R = i;

        while (L < R)
        {
            int j = (L + R) / 2;
            if (A[j][j] < T)
                R = j;
            else
                L = j + 1;
        }

        for (int k = i - 1; k >= R; k--)
        {
            A[k + 1][k + 1] = A[k][k];
        }

        A[R][R] = T;
    }

    printf("\nMatrix after sorting main diagonal (non-increasing order):\n");
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < n; j++)
        {
            printf("%d ", A[i][j]);
        }
        printf("\n");
    }

    return 0;
}