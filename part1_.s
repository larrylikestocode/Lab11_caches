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
        MOV R1, #0x00100000        //base of array
        MOV R2, #0X100             //Iterations of inner loop
        MOV R3, #2                 //Iterations of outer loop
        MOV R4, #0                 //i = 0 (outer loop counter)

L_outer_loop:
        MOV R5, #0                 //J = 0 (inner loop counter)

L_inner_loop:
        LDR R6, [R1, R5, LSL #6]  //read data from memory
        ADD R5, R5, #1            //j = j+1
        CMP R5, R2                //compare j with 256
        BLT L_inner_loop          //branch if less than
        ADD R4, R4, #1            //i = i +1
        CMP R4, R3                //compare i with 2
        BLT L_outer_loop          //

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
