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

    pos.X = cols - rows / 2;
    pos.Y = rows / 2 - 1;

    int colCord = cols - rows + 1;
    int rowCord = 1;

    int direction = 0; // 0 - left/down, 1 - right/up
    while (colCord < 81 && rowCord < 25)
    {
        // Move horizontally
        if (colCord < 81)
        {
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
        }
        if (rowCord < 24)
        {
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
    }
    COORD endPos = {0, rows};
    SetConsoleCursorPosition(hout, endPos);
    getchar();
    return 0;
}