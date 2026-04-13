#include <stdio.h>

extern int add(int a, int b, int c);
extern int sub(int a, int b);

int main() {
    int result1 = add(4, 6, 2);
    int result2 = sub(10, 5);

    printf("Add result: %d\n", result1);
    printf("Sub result: %d\n", result2);

    return 0;
}
