#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char mem[1<<24];
int cacheSize;
int ways;
int blockSize;
int frames;
int sets;
int indexSize;
int blockOffsetSize;
int currentTime;

int log(int number){
    int count = 0;
    while(number != 1){
        number = number >> 1;
        count++;
    }
    return count;    
}
int ones(int N){
    return ((1<<N)-1);
}
int lowerBits(int N, int lower){
   return (N & ones(lower));

}
int ridLower(int N, int lower){
    return (N >> lower);
}
int XandY(int X, int lower, int Y){
    return ((lowerBits(X, lower))|(Y << lower));

}

struct CacheBlock { 
  int tag;           
  char valid;   
  int aTime;    
}; 

struct CacheBlock** myArray;

void assembleCache(int sets, int ways){
    myArray = (struct CacheBlock**)malloc(sets * sizeof(struct CacheBlock*));
    for (int i = 0; i < sets; i ++ ){
        myArray[i] = (struct CacheBlock*) malloc(ways * sizeof(struct CacheBlock));
        for (int j = 0; j < ways; j ++ ){
            myArray[i][j].aTime = 0;
            myArray[i][j].valid = 0;
            myArray[i][j].tag = -1;
        }
        
    }
}
void fileRead(const char* file){
    FILE *f = fopen(file, "r");
    char opp[10];
    int address;
    int size;
    int data;
    

    while (fscanf(f, "%s", opp) != EOF) { 
        int hit = 0;
        currentTime++;    
        fscanf(f, "%x", &address);   
        int save = address;
        int blockOffset = lowerBits(address, blockOffsetSize);
        address = address >> blockOffsetSize;
        int index = lowerBits(address, indexSize);
        int tag = address >> indexSize;

        for (int i = 0; i < ways; i++){
            if(myArray[index][i].valid == 1){
                if(myArray[index][i].tag == tag){
                    hit = 1;
                    myArray[index][i].aTime = currentTime;
                    break;
                }
            }
        }
        address = save;
        fscanf(f, "%d", &size);          
        if (strcmp(opp, "store") == 0){
            for(int i =0; i < size; i++){
                fscanf(f, "%2hhx", &mem[address + i]);
                // printf("%2hhx", mem[address +i]);
            }
            // printf("\n");
            if (hit == 0){
                printf("%s 0x%x miss\n", opp, address);
                
            }
            else{
                printf("%s 0x%x  hit\n", opp, address);
            }
        }
        else{
            if (hit == 1){
            
                printf("%s 0x%x", opp, address);
                printf(" hit ");                  
                for (int i = 0; i < size; i++)
                {
                    printf("%02hhx", mem[address + i]);
                }
                printf("\n");
            }
            else{
                int min = ((1<<25) - 1);
                int minSets;
                int minI;
                for (int i = 0; i < ways; i++){
                    if(myArray[index][i].aTime < min){
                        min = myArray[index][i].aTime;
                        minSets = index;
                        minI = i;
                    }
                }
                myArray[minSets][minI].aTime = currentTime;
                myArray[minSets][minI].tag = tag;
                myArray[minSets][minI].valid = 1;

                printf("%s 0x%x", opp, address);       
                printf(" miss ");                  
                for (int i = 0; i < size; i++)
                {
                    printf("%02hhx", mem[address + i]);
                }
                printf("\n");
            }
        }
        hit = 0;
    }
    fclose(f);
    return;
}

int main(int argc, char const *argv[])
{
    sscanf(argv[2], "%d", &cacheSize);
    sscanf(argv[3], "%d", &ways);
    sscanf(argv[4], "%d", &blockSize);
    cacheSize = cacheSize * 1024;
    frames = cacheSize / blockSize;
    sets = frames / ways;
    indexSize = log(sets);
    blockOffsetSize = log(blockSize);
    assembleCache(sets, ways);
    fileRead(argv[1]);
    return 0;

}