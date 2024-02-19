#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Building {
    char name[64];
    float square_footage;
    float energy_usage;
    float efficiency;
} Building;

int compare_function(const void *a, const void *b) {
    Building *buildingA = (Building *)a;
    Building *buildingB = (Building *)b;
    
    if(buildingA->efficiency > buildingB->efficiency) return -1;
    if(buildingA->efficiency < buildingB->efficiency) return 1;
    return strcmp(buildingA->name, buildingB->name);
}


int main(int argc, char *argv[]) {
    if (argc != 2) {
        return EXIT_FAILURE;
    }

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) {
        return EXIT_FAILURE;
    }

    Building *buildings = NULL;
    int count = 0;

    while (1) {
        char name[64];
        int square_footage;
        float energy_usage;
        
        if (fscanf(fp, "%s", name) != 1) break;
        if (strcmp(name, "DONE") == 0) break;
        fscanf(fp, "%d", &square_footage);
        fscanf(fp, "%f", &energy_usage);

        buildings = (Building *)realloc(buildings, (count + 1) * sizeof(Building));
        strcpy(buildings[count].name, name);
        buildings[count].square_footage = (float)square_footage;
        buildings[count].energy_usage = energy_usage;

        if (square_footage == 0 || energy_usage == 0.0f) {
            buildings[count].efficiency = 0.0f;
        } else {
            buildings[count].efficiency = energy_usage / square_footage;
        }
        
        count++;
    }

    fclose(fp);
    
    if (count == 0) {
        printf("BUILDING FILE IS EMPTY\n");
        return EXIT_SUCCESS;
    }

    qsort(buildings, count, sizeof(Building), compare_function);

    for (int i = 0; i < count; ++i) {
        printf("%s %.6f\n", buildings[i].name, buildings[i].efficiency);
    }
    
    free(buildings);
    
    return EXIT_SUCCESS;
}
