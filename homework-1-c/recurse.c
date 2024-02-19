#include <stdio.h>
#include <stdlib.h>

int f(int n) {
    if (n == 0) {
        return 2;
    }
    return 3 * (n - 1) + f(n - 1) + 1;
}

int main(int argc, char *argv[]) {

    if (argc != 2){
        return EXIT_FAILURE;
    }

    int N = atoi(argv[1]);

    if (N < 0) {
        return EXIT_FAILURE;
    }

    int result = f(N);
    printf("%d\n", result);

    return EXIT_SUCCESS;
}