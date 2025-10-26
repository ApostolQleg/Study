#include <stdio.h>
#include <stdlib.h>

char *get_string();

int main(void)
{
    printf("What's your name? ");
    char *name = get_string();
    printf("Hello, %s!\n", name);
    free(name);
    name = NULL;
    return 0;
}

char *get_string()
{
    char *input = malloc(100);
    scanf("%s", input);
    return input;
}
