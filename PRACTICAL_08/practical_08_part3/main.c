#include "stdio.h"

int main()
{
    int a;

    //Prints the value of a.
    //%d is a placeholder for an integer.
    //Since a is uninitialized, this will print random/undefined value.
    // Call to printf function a is substituted for %d
    printf("Value of a is %d\n", a);

    // Scope
    {
        a = 10;
        printf("Value of a is %d\n", a);
    }

    // Scope
    {
        a = 100;
        printf("Value of a is %d\n", a);
    }

    printf("Value of a is %d\n", a);
    //0 means successful execution.
    return 0;
}

