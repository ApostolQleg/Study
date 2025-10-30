#include <stdio.h>
#include <windows.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc < 2 || (argv[1] == "--terminal") != 0)
    {
        system("start lab3.exe --terminal");
        return 0;
    }

    HANDLE hout = GetStdHandle(STD_OUTPUT_HANDLE);
    COORD pos;
    const int rows = 24;
    const int cols = 80;

    int left = 0, right = cols - 1;
    int top = 0, bottom = rows - 1;

    int hor_length = 61;
    int ver_length = 1;
    int direction = 0;
    system("cls");

    while (left <= right && top <= bottom)
    {
        // рух вправо
        for (int x = left; x <= right; x++)
        {
            pos.X = x;
            pos.Y = top;
            SetConsoleCursorPosition(hout, pos);
            putchar('*');
            fflush(stdout);
            usleep(1000);
        }
        top++;
        if (top > bottom) break;

        // рух вниз
        for (int y = top; y <= bottom; y++)
        {
            pos.X = right;
            pos.Y = y;
            SetConsoleCursorPosition(hout, pos);
            putchar('*');
            fflush(stdout);
            usleep(1000);
        }
        right--;
        if (left > right) break;

        // рух вліво
        for (int x = right; x >= left; x--)
        {
            pos.X = x;
            pos.Y = bottom;
            SetConsoleCursorPosition(hout, pos);
            putchar('*');
            fflush(stdout);
            usleep(1000);
        }
        bottom--;
        if (top > bottom) break;

        // рух вгору
        for (int y = bottom; y >= top; y--)
        {
            pos.X = left;
            pos.Y = y;
            SetConsoleCursorPosition(hout, pos);
            putchar('*');
            fflush(stdout);
            usleep(1000);
        }
        left++;
    }
    COORD endPos = {0, rows};
    SetConsoleCursorPosition(hout, endPos);
    getchar();
    return 0;
}