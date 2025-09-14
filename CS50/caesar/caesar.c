#include "cs50.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool only_digits(string s);
char rotate(char c, int key);

int main(int argc, string argv[])
{
    if (argc != 2 || only_digits(argv[1]) == false)
    {
        printf("Usage: ./caesar key\n");
        return 1;
    }
    else
    {
        int key = atoi(argv[1]) % 26;
        string plaintext = get_string("plaintext: ");
        string ciphertext = plaintext;
        for (int i = 0, len = strlen(ciphertext); i < len; i++)
        {
            ciphertext[i] = rotate(plaintext[i], key);
        }
        printf("ciphertext: %s\n", ciphertext);
        return 0;
    }
}

bool only_digits(string s)
{
    for (int i = 0, len = strlen(s); i < len; i++)
    {
        if (isdigit(s[i]) == false)
        {
            return false;
        }
    }
    return true;
}

char rotate(char c, int key)
{
    if (isalpha(c))
    {
        if (isupper(c))
        {
            if (isupper(c + key) == false)
            {
                c -= 26;
            }
        }
        else if (islower(c))
        {
            if (islower(c + key) == false)
            {
                c -= 26;
            }
        }
        c += key;
    }
    return c;
}
