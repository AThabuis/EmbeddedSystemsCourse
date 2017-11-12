/* Authors : Antoine Laurens, Adrien Thabuis, Hugo Viard
* this file is the code for the demonstration of the PWM module
*/

#include <inttypes.h>
#include <unistd.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"

// adresses to write to
#define ENABLE_PWM_ADDR 0b000
#define PERIOD_ADDR 0b001
#define DUTY_CYCLE_ADDR 0b010
#define POLARITY_ADDR 0b011
#define CLK_DIVIDER_MSB_ADDR 0b100
#define CLK_DIVIDER_LSB_ADDR 0b101

#define SYS_FREQ 50000000 // system freq of 50 MHz
#define CLK_DIVIDER 1000
#define ACTIVE_LOW 0
#define ACTIVE_HIGH 1
#define ONE_SECOND 1000000

void enablePWM(void){
    IOWR_8DIRECT(PWM_MODULE_0_BASE, ENABLE_PWM_ADDR, 0x01);
}

void disablePWM(void){
    IOWR_8DIRECT(PWM_MODULE_0_BASE, ENABLE_PWM_ADDR, 0x00);
}

void setClockDivider(int divider){

    int MSB = divider & 0xFF00; // get the first 8 most significant bits
    int LSB = divider & 0x00FF; // get the 8 least significant bits
    IOWR_8DIRECT(PWM_MODULE_0_BASE, CLK_DIVIDER_MSB_ADDR, MSB);
    IOWR_8DIRECT(PWM_MODULE_0_BASE, CLK_DIVIDER_LSB_ADDR, LSB);
}

int setPeriod(int periodInMS,int clkDivider){
    int periodInTicks = SYS_FREQ / clkDivider / 1000 * periodInMS;
    IOWR_8DIRECT(PWM_MODULE_0_BASE, PERIOD_ADDR, periodInTicks);
    return periodInTicks;
}

void setDutyCycle(int percentage,int periodInTicks){
    int duty_cycle = periodInTicks / percentage;
    IOWR_8DIRECT(PWM_MODULE_0_BASE, DUTY_CYCLE_ADDR, duty_cycle);
}

void setPolarity(int polarity){
    IOWR_8DIRECT(PWM_MODULE_0_BASE, POLARITY_ADDR, polarity);
}


int main(void)
{

    int periodInTicks = 0;
    enablePWM();

    while(1)
    {
        setClockDivider(CLK_DIVIDER);
        int periodInTicks = setPeriod(20,CLK_DIVIDER);
        setDutyCycle(25,periodInTicks);
        setPolarity(ACTIVE_HIGH);

        usleep(ONE_SECOND);

        periodInTicks = setPeriod(2,CLK_DIVIDER);
        setDutyCycle(50,periodInTicks);
        setPolarity(ACTIVE_HIGH);

        usleep(ONE_SECOND);

        periodInTicks = setPeriod(20,CLK_DIVIDER);
        setDutyCycle(75,periodInTicks);
        setPolarity(ACTIVE_HIGH);

        usleep(ONE_SECOND);

        periodInTicks = setPeriod(20,CLK_DIVIDER);
        setDutyCycle(75,periodInTicks);
        setPolarity(ACTIVE_LOW);

        usleep(ONE_SECOND);

    }
}
