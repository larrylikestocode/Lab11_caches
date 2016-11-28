      .text
      .global _start

my_array_A:
           .double 1.1
           .double 1.2
           .double 2.1
           .double 2.2

my_array_B:
           .double 1.48
           .double 1.57
           .double 2.78
           .double 3.74
array_size:
           .word 2
_start:

      LDR R10, =my_array_A  // R10 has the address of the my_array_A
      LDR R11, =my_array_B  // R11 has the address of the my_array_B
      LDR R9, =result_array // R9 has the address of the result_array
      LDR R12, =array_size  // R12 has the address of size of the array N
      LDR R7, [R12] // r7 has the size of the array

      MOV R0, #0    // i = 0 initially
L1:   MOV R1, #0    // j = 0 initially
      //MOV R10, #0   //S
L2:   MOV R2, #0    // K = 0 initially

SUM: .double 0.0
      LDR R8, =SUM // R8 has the address of the
      .word 0xED984B00//FLDD D4, [R8,#0] //D4 has the value of sum 0.0, for every loop in J, we clear the sum


L3:   MUL R6, R2, R7
      ADD R4, R1, R6  // R4(temp address) = k*N +j
      ADD R4, R11, R4, LSL #3  // temp address * 8
      .word 0xED945B00//FLDD D5,[R4,#0] // store the value in array B to D5

      MUL R6, R0, R7
      ADD R5, R2, R6  // R5(temp address) = i*N+k
      ADD R5, R10, R5, LSL #3 // temp address *8
      .word 0xED956B00//FLDD D6,[R5,#0] // store the value in array A to D6

      .word 0xEE257B06//FMULD D7, D5, D6 //multiply the two value from A and B arrays
      .word 0xEE344B07//FADDD D4, D4, D7 // sum = sum + result of the multiply
      ADD R2,R2,#1  //k = k+1
      CMP R2, R7
      BLT L3        //if(k<N) go to L3

      MUL R6, R0, R7
      ADD R3, R1, R6// address = i*size(row) +j
      //alternatively  MUL R3, R0, R7 - i*n
      //ADD R3, R3, R1 -  +j
      ADD R3, R9, R3, LSL #3
      .word 0xED834B00//FSTD  D4, [R3, #0]  //store the value to the result_array

      ADD R1, R1, #1 // j = j + 1
      CMP R1, R7  //(if j<N) go to L2
      BLT L2
      ADD R0, R0, #1 // i = i + 1
      CMP R0, R7 // if(i<N) go TO L1
      BLT L1

      end:  B end         //wait here












result_array:
              .double 0.0
              .double 0.0
              .double 0.0
              .double 0.0
