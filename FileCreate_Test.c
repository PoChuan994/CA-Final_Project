#include <stdio.h>

int main() {
    FILE *fptr;
    fptr = fopen("input.s", "w");
    fprintf(fptr, ".data \n");
    for (int i = 0; i < 3; i++) {
        fprintf(fptr, "\tt");
        fprintf(fptr, "%d",i);
        fprintf(fptr, "_u: .word 0xffffffff\t\t# upper bits of test data");
        fprintf(fptr, "%d", i);
        fprintf(fptr, "\n");
        fprintf(fptr, "\tt");
        fprintf(fptr, "%d",i);
        // fprintf(fptr, "_l: .word 0xffffffff\n");
        fprintf(fptr, "_l: .word 0xffffffff\t\t# lower bits of test data");
        fprintf(fptr, "%d", i);
        fprintf(fptr, "\n");
    }
    fprintf(fptr,"\tTEST_DATA_NUMS: .word ");
    fprintf(fptr, "%d", 3);
    fclose(fptr);
}