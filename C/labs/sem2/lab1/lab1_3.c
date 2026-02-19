#include <stdio.h>
#include <math.h>

/*
 * Рекурсивна функція: члени ряду на спуску, сума на поверненні.
 * i - поточний крок
 * n - цільова кількість членів ряду
 * x - аргумент
 * current_F - значення поточного (i-го) члена ряду, обчислене на спуску
 */
double sum_mixed_recursive(int i, int n, double x, double current_F)
{
    // Базовий випадок: якщо досягли n-го члена, повертаємо його значення,
    // оскільки це останній елемент, який потрібно додати до суми.
    if (i == n)
    {
        return current_F;
    }

    // Спуск: обчислюємо наступний член ряду F_{i+1}
    int next_i = i + 1;
    double next_F = -current_F * x * (3.0 * next_i - 5.0) / (3.0 * next_i - 3.0);

    // Робимо рекурсивний виклик, передаючи туди щойно обчислений next_F
    double remaining_sum = sum_mixed_recursive(next_i, n, x, next_F);

    // Підйом: додаємо поточний член до суми, яку повернув наступний виклик
    return current_F + remaining_sum;
}

/*
 * Функція-обгортка
 */
double calculate_sum_mixed(int n, double x)
{
    if (n < 1)
    {
        return 0.0;
    }
    // За умовою F_1 = 1, тому передаємо 1.0 як початковий член ряду
    return sum_mixed_recursive(1, n, x, 1.0);
}

int main()
{
    int n;
    double x;

    printf("Enter the number of terms (n >= 1): ");
    scanf("%d", &n);

    if (n < 1)
    {
        printf("Error: n must be a positive integer.\n");
        return 1;
    }

    printf("Enter the value of x (|x| < 1):     ");
    scanf("%lf", &x);

    if (fabs(x) >= 1.0)
    {
        printf("Error: |x| must be strictly less than 1.\n");
        return 1;
    }

    // Обчислення суми ряду рекурсивним алгоритмом (спуск-підйом)
    double result = calculate_sum_mixed(n, x);

    // Обчислення точного значення функції
    double exact_value = 1.0 / cbrt(1.0 + x);

    // Обчислення похибки
    double error = fabs(result - exact_value);

    printf("\nYou entered n = %d,\nand x = %.8f\n", n, x);

    printf("\nResults:\n");
    printf("The sum of the first %d terms of the series (Mixed):    %.8f\n", n, result);
    printf("The exact value of 1 / cbrt(1 + x):                    %.8f\n", exact_value);
    printf("Absolute error:                                        %.8f\n", error);

    return 0;
}