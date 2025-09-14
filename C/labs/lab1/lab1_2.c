#include <stdio.h>

int main(void) {
    int x;
    int y;
    printf("Enter x: ");
    scanf("%i", &x);
    if (x > -15 && x <= 3) {
        y = 4 * x * x + 2;
        printf("y(x) = %i\n", y);
    }
    else if (x <= -30 || x > 20){
        y = 3 / 4 * x * x * x - 5;
        printf("y(x) = %i\n", y);
    }
    else {
        printf("function does not exist\n");
    }
}