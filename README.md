# Introduction
- More detailed implementation information is at [here](https://hackmd.io/@c3qLIGuDRtWykAmg5L50Ww/CA-Final/https%3A%2F%2Fhackmd.io%2F%40c3qLIGuDRtWykAmg5L50Ww%2FCA-Final-Intro)
- This project completed the requirements listed bellow:
  - Improved the performance and functionality from [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1).
  - Dynamically generated the test data.
  - Analyzed the CPU stalls to improve the performance according to the analysis.
  - Utilized RISC-V ISA instruction effectively.
- This project achieve half execution time than that of [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1)
# Implementation Result
## Execution comparison:
  - Using the following commands to compare the clock cycle times of [Final Project](https://github.com/PoChuan994/CA-Final_Project/) and [Computer Architecture HW1].(https://github.com/PoChuan994/Computer-Architecture-Homework-1)
    ```shell=
    ./Ripes-v2.2.6-linux-x86_64.AppImage  --src ~/CA/Final/CA-Final_Project/CA-Final_Project/final.s --mode cli -t asm --proc RV32_5S --cycles
    ./Ripes-v2.2.6-linux-x86_64.AppImage  --src ~/CA/HW1/Computer-Architecture-Homework-1/CA_HW1_V2.s --mode cli -t asm --proc RV32_5S --cycles
    ```
  - Clock cycle time comparison:
    |  | Rework HW1(modified) | HW1 |
    | -------- | -------- | -------- |
    | **clock cycles**     | [1261](https://hackmd.io/_uploads/SJWADPWKp.png) |    [2570](https://hackmd.io/_uploads/H1okOvWFa.png) |
## WorkFlow Comparison
- The workflow of [Final Project](https://github.com/PoChuan994/CA-Final_Project/) is shown in the graph below.
  ```mermaid
  graph LR;
  A(main_for_loop)-->|if int i < TEST_DATA_NUMS|B(fs)-->|jal|C(clz)--->|jalr|B;
  A-->|if int i >= TEST_DATA_NUMS|Z(Exit);
  B--->|if not found|C;
  B--->|if found|D(output<br/>print result);
  D--->A;
  ```
- The workflow of [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1) is shown in the graph below.
  ``` mermaid
  graph LR;
  A(main)--->B(main_for_loop)--->|jal|C(fs)--->D{x_equal_0_check};
  B--->Z(Exit);
  D--->|bne|E(x_not_equal_0)--->|jal|H(CLZ);
  H--->|jalr ra|E
  D--->F(x_equal_0)--->G(fs_end);
  E--->|if specified string not found<br/>j|D;
  E--->|if specified string found<br/>j|G;
  G--->|jalr ra|B;
  ```
- The `jump` and `branch` instructions in [Final Project](https://github.com/PoChuan994/CA-Final_Project/) are significantly less than that in [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1).
# Performance Analysis of [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1)
## Clock Cycle Analysis
- In the ideal case without any CPU stall, numbers of clock cycles should be equal to the numbers of executed instructions plus 4.
- In [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1):
  - CPU stalls occurred 54 times.
    | Cycles | Executed instructions | CPI |
    | :--------: | :--------: | :--------: |
    | 346     | 288     | 1.2     |
## Input Data Preprocessing Analysis
- ALL CPU stalls occurred due to control hazards, such as `jalr`, `beq`, `bgeu`, and other jump and branch-relative instructions.
- Obviosly, the workflow in [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1) is inefficient, resulting in frequent usage of jump and branch instructions accompanied by many CPU stalls, especially with a large amount of test data.
- If the test data is all 0-bits, I terminate the search for the string and return -1; otherwise, I continue searching for the string as the code below.
```assembly=
x_equal_0_check:
bne    a1, zero, x_not_equal_to_0    # a1 is the upper bits of test data
bne    a2, zero, x_not_equal_to_0    # a2 is the lower bits of test data

x_equal_0:
addi    a0, zero, -1        # set the return value as -1 if the bits of test data are all 0
j    fs_end
        
x_not_equal_to_0:
```
- However,since almost none of the test data is all 0-bits, the frequent execution of `branch` instructions **makes the code execution inefficient**.
- This part has room for reducing the number of `branch` instructions taken and CPU stalls occurring, especially when dealing with numerous test data.
# Improvement
## I. Dynamically load the test data
- In [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1):
    - There are only fixed 3 test data.
    - I set the `s2` register to 3 to record the number of test data and used it to control for loop. 
        ```assembly
        addi    s2, zero, 3
        ```
- In `Rework Homework1`:
    - I load the value of `TEST_DATA_NUMS` which generated from C code into `s2` register.
        ```assembly
        lw    s2, TEST_DATA_NUMS
        ```
### II. Remove the check for `if all bits of  test data are 0`
- Because almost none of the test data is **0**, the check will frequently increase 2 or  4 extra CPU stall.
    ```assembly
    x_equal_0_check:
        bne    a1, zero, x_not_equal_0
        bne    a2, zero, x_not_equal_0
    ```
- As removing `x_equal_0_check`, I combined the functions of `x_equal_0_`, `x_not_equal_0`, `fs`, and `fs_end` together.
### III. Remove the 'overflow/underflow detection' in `CLZ`
- I modified the assembly code of CLZ to ensure that no overflow or underflow will occur in the process.
- I used 5 times overflow detection and 1 times underflow detection in [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1)
