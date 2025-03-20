# Introduction
- More implementation detailed information is at [here](https://hackmd.io/@c3qLIGuDRtWykAmg5L50Ww/CA-Final/https%3A%2F%2Fhackmd.io%2F%40c3qLIGuDRtWykAmg5L50Ww%2FCA-Final-Intro)
- This project complete the requirements listed as bellow:
  - Improved the performance and functionality from [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1).
  - Dynamically generated the test data.
  - Analyzed the CPU stalls to improve the performance according to the analysis.
  - Utilized RISC-V ISA instruction effectively.
# Implementation Result
# Performance Analysis of [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1)
## Clock Cycle Analysis
- In the ideal case without any CPU stall, numbers of clock cycles should be equal to the numbers of executed instructions plus 4.
- In [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1):
  - CPU stalls occurred 54 times.
    | Cycles | Executed instructions | CPI |
    | :--------: | :--------: | :--------: |
    | 346     | 288     | 1.2     |
  - ALL CPU stalls occurred due to control hazards, such as `jalr`, `beq`, `bgeu`, and other jump and branch-relative instructions.
- Workflow in [Computer Architecture HW1](https://github.com/PoChuan994/Computer-Architecture-Homework-1):
  - ``` mermaid
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
- Obviosly, the data flow in my [HW1]() is inefficient, resulting in frequent usage of jump and branch instructions accompanied by many CPU stalls, especially with a large amount of test data.
## Input Data Preprocessing
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
# Reference
