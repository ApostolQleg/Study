#include <stdio.h>
#include <math.h>

/* * Рекурсивна функція для обчислення на рекурсивному спуску.
 * i - поточний крок
 * n - цільова кількість членів ряду
 * x - аргумент
 * current_F - значення поточного (i-го) члена ряду
 * current_sum - накопичена сума перших i членів ряду
 */
double sum_descent_recursive(int i, int n, double x, double current_F, double current_sum)
{
    // Базовий випадок: якщо обчислили всі n членів, повертаємо накопичену суму
    if (i == n)
    {
        return current_sum;
    }

    int next_i = i + 1;
    double next_F = -current_F * x * (3.0 * next_i - 5.0) / (3.0 * next_i - 3.0);

    // Робимо рекурсивний виклик для наступного кроку, оновлюючи поточний член та суму
    return sum_descent_recursive(next_i, n, x, next_F, current_sum + next_F);
}

/*
 * Функція-обгортка для ініціалізації початкових значень
 */
double calculate_sum_descent(int n, double x)
{
    if (n < 1)
    {
        return 0.0;
    }
    // За умовою F_1 = 1, тому на першому кроці (i=1) поточний F = 1.0 і сума = 1.0
    return sum_descent_recursive(1, n, x, 1.0, 1.0);
}

int main()
{
    int n;
    double x;

    printf("Enter the number of terms in the series (n >= 1): ");
    scanf("%d", &n);

    if (n < 1)
    {
        printf("Error: n must be a positive integer.\n");
        return 1;
    }

    printf("Enter the value of x (|x| < 1): ");
    scanf("%lf", &x);

    if (fabs(x) >= 1.0)
    {
        printf("Error: |x| must be strictly less than 1.\n");
        return 1;
    }

    // Обчислення суми ряду рекурсивним алгоритмом
    double result = calculate_sum_descent(n, x);

    // Обчислення точного значення функції: 1 / cbrt(1 + x)
    double exact_value = 1.0 / cbrt(1.0 + x);

    // Обчислення похибки
    double error = fabs(result - exact_value);

    printf("\nYou entered n = %d,\nand x = %.8f\n", n, x);

    printf("\nResults:\n");
    printf("The sum of the first %d terms of the series (Descent): %.8f\n", n, result);
    printf("The exact value of 1 / cbrt(1 + x):     %.8f\n", exact_value);
    printf("Absolute error:                    %.8f\n", error);

    return 0;
}