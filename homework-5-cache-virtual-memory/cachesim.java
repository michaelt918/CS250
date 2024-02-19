import java.io.*;
import java.util.Scanner;

public class cachesim {
    private static int indexBits;
    private static int blockOffsetBits;
    private static int timeCount;
    private static CacheBlock[][] cache;
    private static int[] mem = new int[1 << 24];
    private static String file;
    private static int cacheSizeB;
    private static int ways;
    private static int blockSizeB;
    private static int frames;
    private static int sets;

    public static void main(String[] args) throws FileNotFoundException {
        file = args[0];
        int cacheSizeKB = Integer.parseInt(args[1]);
        cacheSizeB = cacheSizeKB << 10;
        ways = Integer.parseInt(args[2]);
        blockSizeB = Integer.parseInt(args[3]);
        frames = cacheSizeB / blockSizeB;
        sets = frames / ways;
        indexBits = log(sets);
        blockOffsetBits = log(blockSizeB);
        initializeCache(sets, ways);
        simulateCache(file);
    }

    private static int ones(int N) {
        return (1 << N) - 1;
    }

    private static int log(int number) {
        int count = 0;
        while (number != 1) {
            number >>= 1;
            count++;
        }
        return count;
    }

    private static int lowerBits(int N, int lower) {
        return N & ones(lower);
    }

    private static class CacheBlock {
        int tag;
        boolean valid;
        int time;
    }

    private static void initializeCache(int sets, int ways) {
        cache = new CacheBlock[sets][ways];
        for (int i = 0; i < sets; i++) {
            for (int j = 0; j < ways; j++) {
                cache[i][j] = new CacheBlock();
                cache[i][j].time = 0;
                cache[i][j].valid = false;
                cache[i][j].tag = -1;
            }
        }
    }

    private static void simulateCache(String file) throws FileNotFoundException {
        Scanner scanner = new Scanner(new File(file));
        while (scanner.hasNext()) {
            timeCount++;
            String[] stuff = scanner.nextLine().split(" ");
            String operation = stuff[0];
            int address = Integer.parseInt(stuff[1].substring(2), 16);
            int size = Integer.parseInt(stuff[2]);
            int addressCopy = address;
            addressCopy >>= blockOffsetBits;
            int index = lowerBits(addressCopy, indexBits);
            int tag = addressCopy >> indexBits;
            boolean hit = false;

            for (int i = 0; i < ways; i++) {
                if (cache[index][i].valid && cache[index][i].tag == tag) {
                    hit = true;
                    cache[index][i].time = timeCount;
                    break;
                }
            }

            if ("store".equals(operation)) {
                for (int i = 0; i < size; i++) {
                    mem[address + i] = Integer.parseInt(stuff[3].substring(2*i, 2*i+2), 16);
                }
                System.out.printf("%s 0x%x %s\n", operation, address, hit ? "hit" : "miss");
            } else {
                if (hit) {
                    System.out.printf("%s 0x%x hit ", operation, address);
                    for (int i = 0; i < size; i++) {
                        System.out.printf("%02x", mem[address + i]);
                    }
                    System.out.println();
                } else {
                    int min = (1 << 25) - 1;
                    int minSet = -1;
                    int minIndex = -1;
                    for (int i = 0; i < ways; i++) {
                        if (cache[index][i].time < min) {
                            minSet = index;
                            minIndex = i;
                            min = cache[index][i].time;
                        }
                    }
                    cache[minSet][minIndex].time = timeCount;
                    cache[minSet][minIndex].tag = tag;
                    cache[minSet][minIndex].valid = true;

                    System.out.printf("%s 0x%x miss ", operation, address);
                    for (int i = 0; i < size; i++) {
                        System.out.printf("%02x", mem[address + i] & 0xFF);
                    }
                    System.out.println();
                }
            }
        }
        scanner.close();
    }

}