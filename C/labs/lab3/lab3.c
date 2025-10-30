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
    int rows = 24;
    int cols = 80;

    int rowCord = rows / 2 - 1;
    int colCord = cols - rowCord - 2;

    pos.X = colCord;
    pos.Y = rowCord;

    colCord = colCord - rowCord;
    rowCord = rows / 2 - rowCord;

    int direction = 0; // 0 - left/down, 1 - right/up
    while (colCord < 80 || rowCord < 24)
    {
        // Move horizontally
        for (int i = 0; i < colCord; i++)
        {
            SetConsoleCursorPosition(hout, pos);
            printf("*");
            usleep(1000);
            fflush(stdout);
            if (direction == 0)
                pos.X--;
            else
                pos.X++;
        }
        colCord++;

        // Move vertically
        for (int i = 0; i < rowCord; i++)
        {
            SetConsoleCursorPosition(hout, pos);
            printf("*");
            usleep(1000);
            fflush(stdout);
            if (direction == 0)
                pos.Y++;
            else
                pos.Y--;
        }
        rowCord++;
        direction = !direction;
    }

    COORD endPos = {0, rows};
    SetConsoleCursorPosition(hout, endPos);
    getchar();
    return 0;
}