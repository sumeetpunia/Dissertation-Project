// main.c
#include <stdio.h>

void watchDirectory(const char* folder, const char* outfile);

int main(int argc, char* argv[]) {
    if (argc != 3) {
        printf("Usage: winWatcher.exe <folder> <outfile>\n");
        return 1;
    }

    watchDirectory(argv[1], argv[2]);
    return 0;
}
