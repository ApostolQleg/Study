#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("\e[2J\e[47m\e[12;73H ");
    char *directions[2][2] = {{"\e[2D", "\e[1C\e[1D"}, {"\e[1B\e[1D", "\e[1A\e[1D"}};
    int hor_length = 61;
    int ver_length = 1;
    int direction = 0;
    do
    {
        for (int i = 0; i < hor_length; i++)
        {
            printf("%s*", directions[0][direction]);
            usleep(1000);
            fflush(stdout);
        }
        hor_length++;

        for (int i = 0; i < ver_length; i++)
        {
            printf("%s*", directions[1][direction]);
            usleep(1000);
            fflush(stdout);
        }
        ver_length++;
        direction = !direction;
    } while (hor_length < 80 || ver_length < 24);
    printf("\e[0m\e[25;1H");
    return 0;
}