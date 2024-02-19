#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {

    if (argc != 2){
        return EXIT_FAILURE;
    }

    int N = atoi(argv[1]);
    if (N <= 0) {
        return EXIT_FAILURE;
    }

    for (int i = 1; i < N + 1; i++) {
        printf("%d\n", 7 * i);
    }

    return EXIT_SUCCESS;
}