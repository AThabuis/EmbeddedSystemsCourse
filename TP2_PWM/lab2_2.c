/* Authors : Antoine Laurens, Adrien Thabuis, Hugo Viard
* this file is the code for the demonstration of the PWM module
*/

#include <stdio.h>
#include <inttypes.h>
#include <unistd.h>
#include "system.h"
#include "io.h"

// adresses to write to
#define ENABLE_PWM_ADDR 0//0b000
#define PERIOD_ADDR 1//0b001
#define DUTY_CYCLE_ADDR 2//0b010
#define POLARITY_ADDR 3//0b011
#define CLK_DIVIDER_MSB_ADDR 4//0b100
#define CLK_DIVIDER_LSB_ADDR 5//0b101

#define SYS_FREQ 50000000 // system freq of 50 MHz
#define CLK_DIVIDER 1000
#define ACTIVE_LOW 0
#define ACTIVE_HIGH 1
#define ONE_SECOND 1000000



void enablePWM(void){
    IOWR_8DIRECT(PWMPORT_0_BASE, ENABLE_PWM_ADDR, 0x01);
}

void disablePWM(void){
    IOWR_8DIRECT(PWMPORT_0_BASE, ENABLE_PWM_ADDR, 0x00);
}

void setClockDivider(int division_factor){

    int MSB = division_factor & 0xFF00; // get the first 8 most significant bits
    MSB = MSB >> 8; // put the bits in the LSB to write to the register
    int LSB = division_factor & 0x00FF; // get the 8 least significant bits
    IOWR_8DIRECT(PWMPORT_0_BASE, CLK_DIVIDER_MSB_ADDR, MSB);
    IOWR_8DIRECT(PWMPORT_0_BASE, CLK_DIVIDER_LSB_ADDR, LSB);
}

int setPeriod(int periodInMS,int clkDivider){
    int periodInTicks = SYS_FREQ / clkDivider / 1000 * periodInMS;
    IOWR_8DIRECT(PWMPORT_0_BASE, PERIOD_ADDR, periodInTicks);
    return periodInTicks;
}

void setDutyCycle(int percentage,int periodInTicks){

    int duty_cycle = (double)periodInTicks / (100.0/(double)percentage);
    IOWR_8DIRECT(PWMPORT_0_BASE, DUTY_CYCLE_ADDR, duty_cycle);
}

void setPolarity(int polarity){
    IOWR_8DIRECT(PWMPORT_0_BASE, POLARITY_ADDR, polarity);
}


int main(void)
{
    enablePWM();
    int read_debugg1 = 0;
    int read_debugg2 = 0;
    int read_debugg3 = 0;
    int read_debugg4 = 0;

	while(1)
	{

        read_debugg1 = IORD_8DIRECT(PWMPORT_0_BASE, ENABLE_PWM_ADDR);
        read_debugg2 = IORD_8DIRECT(PWMPORT_0_BASE, PERIOD_ADDR);
        read_debugg3 = IORD_8DIRECT(PWMPORT_0_BASE, DUTY_CYCLE_ADDR);
        read_debugg4 = IORD_8DIRECT(PWMPORT_0_BASE, POLARITY_ADDR);

        printf("Enable = %d, Period = %d, DutyCycle = %d, Polarity = %d\n",
                read_debugg1, read_debugg2, read_debugg3, read_debugg4);

        setClockDivider(CLK_DIVIDER);
        periodInTicks = setPeriod(2,CLK_DIVIDER);
        setDutyCycle(25,periodInTicks);
        setPolarity(ACTIVE_LOW);

        usleep(ONE_SECOND);

        periodInTicks = setPeriod(2,CLK_DIVIDER);
        setDutyCycle(50,periodInTicks);
        setPolarity(ACTIVE_HIGH);

        usleep(ONE_SECOND);

        periodInTicks = setPeriod(2,CLK_DIVIDER);
        setDutyCycle(75,periodInTicks);
        setPolarity(ACTIVE_HIGH);

        usleep(ONE_SECOND);

        periodInTicks = setPeriod(2,CLK_DIVIDER);
        setDutyCycle(75,periodInTicks);
        setPolarity(ACTIVE_LOW);

        usleep(ONE_SECOND);

    }
}
