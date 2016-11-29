
    .text
    .global _start


_start:
        BL CONFIG_VIRTUAL_MEMORY

        //Step 1-3: configure PMN0 to count cycles
        MOV R0, #0                 //write 0 into R0 then PMSELR
        MCR p15, 0, R0, c9, c12, 5 //write 0 into PMSELR selects PMN0
        MOV R1,#0x11               //Event 0x11 is CPU cycles
        MCR p15, 0, R1, c9, c13, 1 //Write 0x11 into PMXEVTPER (PMN0 measure CPU cycles)

        //Configure PMN1 to count cache misses
        MOV R0, #1                 //write 1 into R0 then PMSELR
        MCR p15, 0, R0, c9, c12, 5 //write 1 into PMSELR selects PMN1
        MOV R1, #0x3               //Event 0x3 is Level 1 data cache misses
        MCR p15, 0, R1, C9, C13, 1//Write 0x3 into PMXEVTPER(PMN1 measure Level 1 data cache misses )

        //Configure PMN2 to count number of load insttruction excuted
        MOV R0, #2                //write 2 into R0 then PMSELR
        MCR p15, 0, R0, c9, c12, 5 //Write 2 in to PMSELR selects PMN2
        MOV R1, #0x6              //Event 0x6 is number of insttructions excuted
        MCR p15, 0, R1, c9, c13, 1//Write 0x6 into PMXEVTPER(PMN2 measure number of load insttruction excuted )



        //Step 4: enable PMN0, PMN1, PMN2
        MOV R0, #111                 //PMN0 is bit 0 of PMCNTENSET
        MCR p15, 0, R0, c9, c12, 1 //Setting bit 0 of PMCNTENSET enables PMN0

        //Step 5:clear all counters and start counters
        MOV R0, #3                 //bits 0(start counters) and 1(reset counters)
        MCR p15, 0, R0, c9, c12, 0 //Setting PMCR to 3

        //Step 6: code we wish to profile using hardware counters

               array_size:
                              .word 128


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
        // Step 7: stop counters
        MOV R0, #0
        MCR p15, 0, R0, c9, c12, 0 //write 0 t PMCR to stop counters


        //Step 8 - 10 Select PMN0 and read out result into R3
        MOV R0, #0                 //PMN0
        MCR p15, 0, R0, c9, c12, 5 //Write 0 to PMSELR
        MRC p15, 0, R3, c9, c13, 2 //Read PMXEVCNTR into R3

        MOV R0, #1                //PMN1
        MCR p15, 0, R0, c9, c12, 5 //Write 1 to PMSELR
        MRC P15, 0, R7, c9, c13, 2 //Read PMXEVCNTR into R7

        MOV R0, #2               //PMN2
        MCR p15, 0, R0, c9, c12, 5 //Write 2 to PMSELR
        MRC p15, 0, R8, c9, c13, 2 //Read PMXEVCNTR into R8



end:   B end                       //wait here
