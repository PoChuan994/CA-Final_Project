#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define BITS_PER_TEST_DATA 64
#define TEST_DATA_NUMS 3

// 生成隨機的 0 或 1
int generateRandomBit() {
    return rand() % 2;
}

// 生成指定長度的隨機二進制字串
void generateRandomBinaryString(char *binaryString, int length) {
    for (int i = 0; i < length; ++i) {
        binaryString[i] = generateRandomBit() + '0';
    }
    binaryString[length] = '\0';
}

// 將二進制字串轉換為16進制表示法
void binaryToHex(char *binaryString, char *hexString) {
    for (int i = 0; i < BITS_PER_TEST_DATA; i += 4) {
        // 取得4位二進制數字
        int binaryValue = 0;
        for (int j = 0; j < 4; ++j) {
            binaryValue = (binaryValue << 1) | (binaryString[i + j] - '0');
        }

        // 轉換為16進制數字
        if (binaryValue < 10) {
            hexString[i / 4] = '0' + binaryValue;
        } else {
            hexString[i / 4] = 'A' + (binaryValue - 10);
        }
    }
    hexString[BITS_PER_TEST_DATA / 4] = '\0';
}

int main() {
    // 使用時間作為隨機數種子
    srand((unsigned int)time(NULL));

    char temp1[9];
    char temp2[9];

    FILE *fptr;
    fptr = fopen("input.s", "w");
    fprintf(fptr, ".data \n");

    // 產生3組64位元的隨機二進制字串
    for (int i = 0; i < TEST_DATA_NUMS; ++i) {
        char binaryString[BITS_PER_TEST_DATA + 1];
        char hexString[BITS_PER_TEST_DATA / 4 + 1];

        generateRandomBinaryString(binaryString, BITS_PER_TEST_DATA);
        binaryToHex(binaryString, hexString);

        // spilt the hexString into upper bits and lower bits
        memcpy(temp1, hexString, 8);
        temp1[8] = '\0';
        memcpy(temp2, hexString+8, 8);
        temp2[8] = '\0';

        fprintf(fptr, "\tt");
        fprintf(fptr, "%d",i);
        fprintf(fptr, "_u: .word: ");
        // fprintf(fptr, "%s", hexString);
        fprintf(fptr, "%s", temp1);
        fprintf(fptr, "\t\t # upper bits of test data");
        fprintf(fptr, "%d", i);
        fprintf(fptr, "\n");
        fprintf(fptr, "\tt");
        fprintf(fptr, "%d",i);
        fprintf(fptr, "_l: .word: ");
        // fprintf(fptr, "%s", hexString);
        fprintf(fptr, "%s", temp2);
        fprintf(fptr, "\t\t # upper bits of test data");
        fprintf(fptr, "%d", i);
        fprintf(fptr, "\n");
    }

    fprintf(fptr,"\tTEST_DATA_NUMS: .word ");
    fprintf(fptr, "%d", 3);
    fclose(fptr);

    return 0;
}