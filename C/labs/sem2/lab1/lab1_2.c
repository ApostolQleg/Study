#include <stdio.h>
#include <math.h>

// Створюємо структуру для зберігання члена ряду та суми
typedef struct
{
    double F;
    double sum;
} SeriesData;

/*
 * Рекурсивна функція для обчислення на рекурсивному поверненні (зі struct).
 * i - поточний крок
 * x - аргумент
 */
SeriesData sum_ascent_recursive(int i, double x)
{
    SeriesData data;

    // Базовий випадок: доходимо до початку ряду (i = 1)
    if (i == 1)
    {
        data.F = 1.0;
        data.sum = 1.0;
        return data;
    }

    // Спуск: Спочатку робимо рекурсивний виклик для попереднього кроку (i - 1)
    data = sum_ascent_recursive(i - 1, x);

    // Підйом: Тепер data.F містить значення F_{i-1}.
    // Обчислюємо поточний F_i та додаємо його до загальної суми.
    data.F = -data.F * x * (3.0 * i - 5.0) / (3.0 * i - 3.0);
    data.sum += data.F;

    return data;
}

/*
 * Функція-обгортка
 */
double calculate_sum_ascent(int n, double x)
{
    if (n < 1)
    {
        return 0.0;
    }

    // Отримуємо результат у вигляді структури
    SeriesData result = sum_ascent_recursive(n, x);

    return result.sum; // Повертаємо лише потрібну нам суму
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

    // Обчислення суми ряду на поверненні
    double result = calculate_sum_ascent(n, x);

    // Обчислення точного значення функції
    double exact_value = 1.0 / cbrt(1.0 + x);

    // Обчислення похибки
    double error = fabs(result - exact_value);

    printf("\nYou entered n = %d,\nand x = %.8f\n", n, x);

    printf("\nResults:\n");
    printf("The sum of the first %d terms of the series (Ascent): %.8f\n", n, result);
    printf("The exact value of 1 / cbrt(1 + x):    %.8f\n", exact_value);
    printf("Absolute error:                   %.8f\n", error);

    return 0;
}